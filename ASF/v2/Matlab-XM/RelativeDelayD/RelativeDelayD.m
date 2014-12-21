%##################################################################################
%##  Function: RelativeDelayD.m;  describes relative delay between channels      ##
%##################################################################################
%
%   function [RelativeDelay, msc] = RelativeDelayD(auData,fs,channels,szXMLout)
%
%   RelativeDelayD describes the relative delay between two or more channels 
%   of an AudioSegment
%
%   auData 	 = inputmatrix of audiostream N channels in columns
%   fs 		 = Samplerate of audiostream
%   channels = channel to analyze (if empty all channels are used)
%   szXMLout = name of output XML-file. if not given no XML-output
%
%   RelativeDelay = row-vektor of length nChannels-1 with relative delay for 
%                   each channel corresponding to the first channel
%   msc           = vector with confidence information
%
%		 Unit:	[ms]
%
%   Written By Stefan Kudras
%   Version 1.0 Sep 2001
%   Version 1.1 Oct 2001, blockwise calculation of data
%	Version 2.0 March 2002 XML Output
%	Version 2.1 August 2002 by Stefan Kudras handling of multichannel data described in 15398-5 (MDS)Amd.1
%	Version 2.2 January 2003 by Stefan Kudras XML data output as AudioLLDVectorType


function [RelativeDelay, msc] = RelativeDelayD(auData,fs,channels,szXMLout)

[lengthx,nChannels] = size(auData);
% Check if empty, use all channels (compatibility to V1 AudioD)
if (isempty(channels))
    channels = 1:nChannels;    
end

% Check if specified channels numbers are valid
idx = find (channels > nChannels);
channels(idx) = [];
idx = find (channels < 1);
channels(idx) = [];

% rearranging data
auData = auData(:,channels);
[lengthx,nChannels] = size(auData);

% calculation of relative delay
RD = zeros(1,nChannels-1);
blockRD = zeros(1,nChannels-1);


blockSize_ms = 50;								%blocksize in ms
blockSize = fix(blockSize_ms/1000*fs);		    %blocksize in samples
blocks = fix(lengthx/blockSize);				%nr of blocks
meanRD = zeros(1,nChannels-1);				    %initialization
maxco_1 = 0;
maxco_n = zeros(1,nChannels-1);
maxcrossco_1_n = zeros(1,nChannels-1);
msc = zeros(1,nChannels-1);

for idx = 1:blocks
    blockx = auData((idx-1)*blockSize+1:(idx-1)*blockSize+blockSize,:); 	%actual block
    akf_1 = xcorr(blockx(:,1));
    maxco_1 = max(maxco_1,akf_1(blockSize));				        %maximum autocorrelation of 1. channel
    for n=2:nChannels
        akf_n = xcorr(blockx(:,n));
        maxco_n(n-1) = max(maxco_n(n-1),akf_n(blockSize));			%maximum autocorrelation of n-th channel
        [dummy,blockRD(n-1)]=max(xcorr(blockx(:,1),blockx(:,n)));	%cross correlation
        maxcrossco_1_n(n-1) = max(maxcrossco_1_n(n-1),dummy);
        meanRD(n-1) = meanRD(n-1) + blockRD(n-1);
    end
end

RD = meanRD / blocks;	
RD = RD - blockSize; 	%delay in samples
RD = RD / (fs)*1000;    %delay in ms
RelativeDelay = RD;


for n=2:nChannels
    msc(n-1) = (maxcrossco_1_n(n-1).^2/(maxco_1*maxco_n(n-1)));
end

if nargin > 3
display(sprintf ('XML_Output file: %s',szXMLout));
% XML-Output
fid = fopen(szXMLout,'w');

xout = '<?xml version="1.0" encoding="iso-8859-1"?>';
fprintf(fid, '%s\n',xout);

xout = '<!-- #####################################################################  -->';
fprintf(fid, '%s\n',xout);
xout = '<!-- Definition of RelativeDelay D                                -->';
fprintf(fid, '%s\n',xout);
xout = '<!-- #####################################################################  -->';
fprintf(fid, '%s\n',xout);
xout = '<!-- <complexType name="RelativeDelayType"                                  -->';
fprintf(fid, '%s\n',xout);
xout = '<!--    <complexContent>                                                    -->';
fprintf(fid, '%s\n',xout);
xout = '<!--       <extension base="mpeg7:AudioLLDVectorType">                      -->';
fprintf(fid, '%s\n',xout);
xout = '<!--           <attribute name="Confidence" type="mpeg7:probabilityVector"/>  -->';
fprintf(fid, '%s\n',xout);
xout = '<!--       </extension>                                                     -->';
fprintf(fid, '%s\n',xout);
xout = '<!--    </complexContent>                                                   -->';
fprintf(fid, '%s\n',xout);
xout = '<!-- </complexType>                                                         -->';
fprintf(fid, '%s\n\n',xout);


xout = '<Mpeg7 xmlns="urn:mpeg:mpeg7:schema:2001" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="urn:mpeg:mpeg7:schema:2001 .\AudioQ-2001.xsd">';
fprintf(fid, '%s\n',xout);

xout = strcat('	<DescriptionUnit xsi:type="RelativeDelayType" Confidence="', num2str(msc),'" channels ="',num2str(channels,'%1d '),'">');
fprintf(fid,'%s\n',xout);

xout = strcat('		<Vector>', num2str(RD), '</Vector>');
fprintf(fid,'%s\n',xout);

xout = '	</DescriptionUnit>';
fprintf(fid, '%s\n',xout);

xout = '</Mpeg7>';
fprintf(fid, '%s\n',xout);


%% Close file 
fclose(fid);

end


