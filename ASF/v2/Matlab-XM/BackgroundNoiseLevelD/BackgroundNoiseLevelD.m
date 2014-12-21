%##################################################################################
%##  Function: BackgroundNoiseLevelD.m;  describes the Background Noise Level    ##
%##################################################################################
%
%   function [BNL] = BackgroundNoiseLevelD(auData,fs,channels,szXMLout)
%
%
%   auData   = inputmatrix of audiostream N channels in columns
%   fs       = sample frequency of the signal
%   channels = channel to analyze (if empty all channels are used)
%   szXMLout = name of output XML-file. if not given no XML-output
%
%   BNL   = row-vector with Background Noise Level  for each channel
%          
%      Unit:	dB
%      Range: 	[-100, 100]
%
%   Written By Joerg Bitzer
%   Version 1.0 7. Sep 2001
%   Modified 10. Sep 2001 processing for multi channel signals
%	Version 2.0 March 2002 by Stefan Kudras
%	Version 2.1 April 2002 by Joerg Bitzer
%	Version 2.2 August 2002 by Joerg Bitzer handling of multichannel data described in 15398-5 (MDS)Amd.1
%	Version 2.3 January 2003 by Stefan Kudras XML data output as AudioLLDVectorType


function [BNL] = BackgroundNoiseLevelD(auData,fs,channels,szXMLout)

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


%calculation of maximum peak in signal
maxPeak = max(abs(auData));
maxPeak_dB = 20*log10(maxPeak);

%set blocklength
BlockLen_ms = 5;
BlockLen = fix(fs*BlockLen_ms*0.001);
Blocks = fix(lengthx/BlockLen);

%calculate the power of each block in all channels
for idx = 1:nChannels
   for kk = 1:Blocks
      ActSigPow(kk,idx) = mean(auData((kk-1)*BlockLen+1:(kk)*BlockLen,idx).^2);
   end
end

%find block with minimum mean power for each channel (without zero blocks)
%figure; plot(10*log10(ActSigPow))
[I,J] = find(ActSigPow==0);%find zero blocks
ActSigPow(I,J)=1;				%set zero blocks to 1
minPow = min(ActSigPow);
minPow_dB = 10*log10(minPow);

BNL = minPow_dB-maxPeak_dB;


if nargin > 3
display(sprintf ('XML_Output file: %s',szXMLout));
% XML-Output
fid = fopen(szXMLout,'w');

xout = '<?xml version="1.0" encoding="iso-8859-1"?>';
fprintf(fid, '%s\n',xout);

xout = '<!-- #####################################################################  -->';
fprintf(fid, '%s\n',xout);
xout = '<!-- Definition of BackgroundNoiseLevel D                                               -->';
fprintf(fid, '%s\n',xout);
xout = '<!-- #####################################################################  -->';
fprintf(fid, '%s\n',xout);
xout = '<!-- <complexType name="BackgroundNoiseLevelType"                                       -->';
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

xout = strcat('	<DescriptionUnit xsi:type="BackgroundNoiseLevelType" channels ="',num2str(channels,'%1d '),'">');
fprintf(fid, '%s\n',xout);

xout = strcat('		<Vector>', num2str(BNL), '</Vector>');
fprintf(fid,'%s\n',xout);

xout = '	</DescriptionUnit>';
fprintf(fid, '%s\n',xout);

xout = '</Mpeg7>';
fprintf(fid, '%s\n',xout);


%% Close file 
fclose(fid);

end

