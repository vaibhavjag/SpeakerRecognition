%########################################################################
%##  Function: DCOffsetD.m;  describes DC Offset of each channel       ##
%########################################################################
%
%   function [DCOffset] = getDCOffset(auData,channels,szXMLout)
%
%   DCOffsetD describes the DC-Offset of each channel
%
%   auData   = inputmatrix of audiostream N channels in columns
%   channels = channel to analyze (if empty all channels are used)
%   szXMLout = name of output XML-file. if not given no XML-output
%
%   DCOffset = row-vektor, DCOffset of each channel
%
%        Unit:	
%        Range: 	[-1, 1]
%
%   Written By Stefan Kudras
%   Version 1.0 Sep 2001
%	Version 2.0 March 2002
%	Version 2.1 August 2002 by Stefan Kudras handling of multichannel data described in 15398-5 (MDS)Amd.1
%	Version 2.2 January 2003 by Stefan Kudras XML data output as AudioLLDVectorType


function [DCOffset] = DCOffsetD(auData,channels,szXMLout)

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

% calculation of dcoffset
DC = mean(auData)./max(abs(auData));
DCOffset = DC;
   
   
if nargin > 2
display(sprintf ('XML_Output file: %s',szXMLout));
% XML-Output
fid = fopen(szXMLout,'w');

xout = '<?xml version="1.0" encoding="iso-8859-1"?>';
fprintf(fid, '%s\n',xout);

xout = '<!-- #####################################################################  -->';
fprintf(fid, '%s\n',xout);
xout = '<!-- Definition of DcOffset D                                               -->';
fprintf(fid, '%s\n',xout);
xout = '<!-- #####################################################################  -->';
fprintf(fid, '%s\n',xout);
xout = '<!-- <complexType name="DcOffsetType"                                       -->';
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

xout = strcat('	<DescriptionUnit xsi:type="DcOffsetType" channels ="',num2str(channels,'%1d '),'">');
fprintf(fid, '%s\n',xout);

xout = strcat('		<Vector>', num2str(DC), '</Vector>');
fprintf(fid,'%s\n',xout);

xout = '	</DescriptionUnit>';
fprintf(fid, '%s\n',xout);

xout = '</Mpeg7>';
fprintf(fid, '%s\n',xout);


%% Close file 
fclose(fid);

end