%##################################################################################
%##  Function: BalanceD.m;  describes relative level between channels            ##
%##################################################################################
%
%   function [B] = BalanceD(auData,channels,szXMLout)
%
%   BalanceD describes the balance level between two or more channels 
%   of an AudioSegment
%
%   auData   = inputmatrix of audiostream N channels in columns
%   channels = channel to analyze (if empty all channels are used)
%   szXMLout = name of output XML-file. if not given no XML-output
%
%   B = row-vektor of length nChannels-1 with relative level between 
%       first channel and each other channel
%
%       Unit:	dB
%       Range: 	[-100, 100]
%
%   Written By Stefan Kudras
%   Version 1.0 Sep 2001
%	Version 2.0 March 2002
%	Version 2.1 April 2002 by Joerg Bitzer
%	Version 2.2 August 2002 by Stefan Kudras handling of multichannel data described in 15398-5 (MDS)Amd.1
%	Version 2.2 January 2003 by Stefan Kudras XML data output as AudioLLDVectorType


function [Balance] = BalanceD(auData,channels,szXMLout)

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

% calculation of balance
meanpowerx = mean(auData.^2);

Balance = [];

for idx=2:nChannels
   Balance(idx-1) = 10*log10(meanpowerx(1)/meanpowerx(idx));
end


if nargin > 2
display(sprintf ('XML_Output file: %s',szXMLout));
% XML-Output
fid = fopen(szXMLout,'w');

xout = '<?xml version="1.0" encoding="iso-8859-1"?>';
fprintf(fid, '%s\n',xout);

xout = '<!-- #####################################################################  -->';
fprintf(fid, '%s\n',xout);
xout = '<!-- Definition of Balance D                                               -->';
fprintf(fid, '%s\n',xout);
xout = '<!-- #####################################################################  -->';
fprintf(fid, '%s\n',xout);
xout = '<!-- <complexType name="BalanceType"                                       -->';
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

xout = strcat('	<DescriptionUnit xsi:type="BalanceType" channels ="',num2str(channels,'%1d '),'">');
fprintf(fid, '%s\n',xout);

xout = strcat('		<Vector>', num2str(Balance), '</Vector>');
fprintf(fid,'%s\n',xout);

xout = '	</DescriptionUnit>';
fprintf(fid, '%s\n',xout);

xout = '</Mpeg7>';
fprintf(fid, '%s\n',xout);


%% Close file 
fclose(fid);

end