%##################################################################################
%##  Function: BandwidthD.m;  describes the bandwidth of each channel            ##
%##################################################################################
%
%   function [Bandwidth] = BandwidthD(auData,fs,channels,szXMLout)
%
%   BandwidthD describes the bandwidth of each channel between 0Hz and fs/2
%
%   auData   = inputmatrix of audiostream N channels in columns
%   fs 	     = Samplerate of audiostream
%   channels = channel to analyze (if empty all channels are used)
%   szXMLout = name of output XML-file. if not given no XML-output
%
%   Bandwidth = row-vector size nChannels
%
%        Unit:	Hz
%        Range:	[0, fs/2]  
%
%   Written By Stefan Kudras
%   Version 1.0 Sep 2001
%   Version 2.0 March 2002
%	Version 2.1 August 2002 by Stefan Kudras handling of multichannel data described in 15398-5 (MDS)Amd.1
%	Version 2.2 January 2003 by Stefan Kudras XML data output as AudioLLDVectorType


function [Bandwidth] = BandwidthD(auData,fs,channels,szXMLout)

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

% calculation of bandwidth
BW = zeros(1,nChannels);

len_ms = 30;	            %framelength = 30ms
inc_ms = 10;	            %incrementlength = 10ms
len = fix(fs*len_ms/1000);	%framelength in samples
inc = fix(fs*inc_ms/1000);	%incrementlength in samples

fftsize = 2048;		        %Size of FFT
df = fs/fftsize;            %frequency resolution of FFT

window = hamming(len);

nx=lengthx;
nwin=length(len);
if (nwin == 1)
   len = len;
else
   len = nwin;
end
nf = fix((nx-len+inc)/inc);	%number of frames



for idx=1:nChannels
   
   maxPS = zeros(fftsize/2+1,1);
   
   for fr_inx=0:(nf-1)
      frame = auData((fr_inx*inc+1):(fr_inx*inc+len),idx);
      framefw = frame.*window;
	   XFW = fft(framefw,fftsize);         %FFT-Spectrum
		PS = XFW.*conj(XFW);               %Power-Spectrum
      PS = PS(1:fftsize/2+1);
      maxIndex = find(PS>maxPS);
      maxPS(maxIndex) = PS(maxIndex);
   end
   
   logMaxPS = 10*log10(maxPS);	%logarithmic maximum spectrum 
   
   %parameter to change
   fraction = 0.7;
   pborder = max(logMaxPS)-fraction*(max(logMaxPS)-min(logMaxPS));  	%powerborder for frequency bin to be in bandwidth
                                 
   %find upper limit of logarithmic maximum spectrum within the border
   for inx = fftsize/2+1:-1:1
      if logMaxPS(inx) > pborder
         hibin = inx;
         break;
      end;
   end;
   
   %calculate bandwidth in Hz for actual channel
   BW(idx)=(hibin+1)*df;
   Bandwidth = BW;
end


if nargin > 3
display(sprintf ('XML_Output file: %s',szXMLout));
% XML-Output
fid = fopen(szXMLout,'w');

xout = '<?xml version="1.0" encoding="iso-8859-1"?>';
fprintf(fid, '%s\n',xout);

xout = '<!-- #####################################################################  -->';
fprintf(fid, '%s\n',xout);
xout = '<!-- Definition of Bandwidth D                                               -->';
fprintf(fid, '%s\n',xout);
xout = '<!-- #####################################################################  -->';
fprintf(fid, '%s\n',xout);
xout = '<!-- <complexType name="BandwidthType"                                       -->';
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

xout = strcat('	<DescriptionUnit xsi:type="BandwidthType" channels ="',num2str(channels,'%1d '),'">');
fprintf(fid, '%s\n',xout);

xout = strcat('		<Vector>', num2str(BW), '</Vector>');
fprintf(fid,'%s\n',xout);

xout = '	</DescriptionUnit>';
fprintf(fid, '%s\n',xout);

xout = '</Mpeg7>';
fprintf(fid, '%s\n',xout);


%% Close file 
fclose(fid);

end