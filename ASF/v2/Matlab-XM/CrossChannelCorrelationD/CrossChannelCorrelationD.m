%##########################################################################################
%##  Function: CrossChannelCorrelationD.m;  describes correlation between channels       ##
%##########################################################################################
%
%   function [C] = CrossChannelCorrelationD(auData,fs,channels,szXMLout)
%
%   CrossChannelCorrelationD describes the cross correlation between two or more  
%   channels of an AudioSegment
%
%   auData 	 = inputmatrix of audiostream N channels in columns
%   fs 		 = Samplerate of audiostream
%   channels = channel to analyze (if empty all channels are used)
%   szXMLout = name of output XML-file. if not given no XML-output
%
%   C = row-vektor, cross correlation for each channel
%
%       Unit:	-
%       Range:	[-1,1]
%
%   Written By Stefan Kudras
%   Version 1.0 Sep 2001
%   Version 1.1 Oct 2001, blockwise calculation of data
%   Version 1.2 Nov 2001, new normalization of cross correlation
%	Version 2.0 March 2002 XML Output
%	Version 2.1 August 2002 by Stefan Kudras handling of multichannel data described in 15398-5 (MDS)Amd.1
%	Version 2.2 January 2003 by Stefan Kudras XML data output as AudioLLDVectorType


function [C] = getCrossChannelCorrelationD(auData,fs,channels,szXMLout)

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

% calculation of correlation
blockSize_ms = 50;							%blocksize in ms
blockSize = fix(blockSize_ms/1000*fs);		%blocksize in samples
blocks = fix(lengthx/blockSize);			%nr of blocks
meanCorrelation = zeros(1,nChannels-1);	    %initialization

for idx = 1:blocks
   blockx = auData((idx-1)*blockSize+1:(idx-1)*blockSize+blockSize,:); %actual block
   if max(abs(blockx))~=0
      blockx = blockx ./ (ones(blockSize,1)*max(abs(blockx)));	%normalized block
   end
   akf_1 = xcorr(blockx(:,1));
   maxco_1 = akf_1(blockSize);				%maximum autocorrelation of 1. channel
   for n=2:nChannels
      akf_n = xcorr(blockx(:,n));
    	maxco_n = akf_n(blockSize);			%maximum autocorrelation of n-th channel
      maxco = sqrt(maxco_1*maxco_n);		%mean maximum of autocorrelations
      co = xcorr(blockx(:,1),blockx(:,n));  %calcualtion of cross correlation
      if maxco~=0
         co = co(blockSize)/maxco;			%normalized cross correlation
      end
		meanCorrelation(n-1) = meanCorrelation(n-1) + co;
   end
end

C = meanCorrelation ./ blocks;


if nargin > 3
display(sprintf ('XML_Output file: %s',szXMLout));
% XML-Output
fid = fopen(szXMLout,'w');

xout = '<?xml version="1.0" encoding="iso-8859-1"?>';
fprintf(fid, '%s\n',xout);

xout = '<!-- #####################################################################  -->';
fprintf(fid, '%s\n',xout);
xout = '<!-- Definition of CrossChannelCorrelation D                                -->';
fprintf(fid, '%s\n',xout);
xout = '<!-- #####################################################################  -->';
fprintf(fid, '%s\n',xout);
xout = '<!-- <complexType name="CrossChannelCorrelationType"                        -->';
fprintf(fid, '%s\n',xout);
xout = '<!--    <complexContent>                                                    -->';
fprintf(fid, '%s\n',xout);
xout = '<!--       <extension base="mpeg7:AudioLLDVectorType"/>                     -->';
fprintf(fid, '%s\n',xout);
xout = '<!--    </complexContent>                                                   -->';
fprintf(fid, '%s\n',xout);
xout = '<!-- </complexType>                                                         -->';
fprintf(fid, '%s\n\n',xout);


xout = '<Mpeg7 xmlns="urn:mpeg:mpeg7:schema:2001" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="urn:mpeg:mpeg7:schema:2001 .\AudioQ-2001.xsd">';
fprintf(fid, '%s\n',xout);

xout = strcat('	<DescriptionUnit xsi:type="CrossChannelCorrelationType" channels ="',num2str(channels,'%1d '),'">');
fprintf(fid, '%s\n',xout);

xout = strcat('		<Vector>', num2str(C), '</Vector>');
fprintf(fid,'%s\n',xout);

xout = '	</DescriptionUnit>';
fprintf(fid, '%s\n',xout);

xout = '</Mpeg7>';
fprintf(fid, '%s\n',xout);


%% Close file 
fclose(fid);

end

