function [audata, totalSampleNum, Fs, bitNum, channelNum] = h_AudioSamples(aufileName) 

%%% File: h_AudioSamples.m
%%
%% The function of this subroutine is to read audio samples from a sound file
%% and to return information such like elementNum, sampling rate Fs (sample 
%% period 1/Fs) bit number per sample and channel number. It relates to 
%% AudioSampledType, but which is abstract and never instantiated.
%%
%% 
%% 
%% 
%%
%% Copyright (c), IME, All Rights Reserved
%%
%% Author: Dong Yan Huang
%% Version: 1.0  Time: 28 August 2000 (N3489)
%% Last Modified: 27 Mar 2001 (N3704)

Extension_position = findstr(aufileName,'.');
len = length(aufileName);
fileExtension = aufileName(Extension_position:len);

if strmatch(fileExtension,'.pcm') == 1
   %% The sampling rate for all Paris5 mono PCM files
   %% is Fs = 32000 and bitNum/per sample = 16    
   fid_sn = fopen(aufileName);
   [audata, totalSampleNum] = fread(fid_sn,'short');
   Fs = 32000;
   bitNum = 16;
   channelNum = 1;
elseif strmatch(fileExtension,'.au') == 1
   [audata, Fs, bitNum] = auread(aufileName);
   [totalSampleNum, channelNum] = size(audata);
elseif strmatch(fileExtension,'.wav') == 1
   [audata, Fs, bitNum] = wavread(aufileName);
   [totalSampleNum, channelNum] = size(audata);
end
fid = fopen('AudioSampled.xml','w');
x = '<!-- ##################################################################### -->';
fprintf(fid, '%s\n',x);
x = '<!-- Definition of AudioSampledType                                        -->';
fprintf(fid, '%s\n',x);
x = '<!-- ##################################################################### -->';
fprintf(fid, '%s\n',x);
x = '<! --  <complexType name="AudioSampledType" abstract="true">               -->';
fprintf(fid, '%s\n',x);
x = '<! --    <complexContent>                                                  -->';
fprintf(fid, '%s\n',x);
x = '<! --      <extension base="mpeg7:AudioDType">                             -->';
fprintf(fid, '%s\n',x);
x = '<! --        <attribute name="hopSize" type="mpeg7:IncrDuration>           -->';
fprintf(fid, '%s\n',x);
x = '<! --      </extension>                                                    -->';
fprintf(fid, '%s\n',x);
x = '<! --    </complexContent>                                                 -->';
fprintf(fid, '%s\n',x);
x = '<! -- </complexType>                                                       -->';
fprintf(fid, '%s\n',x);

x = '<AudioSegment idref="101">';
fprintf(fid, '%s\n',x);
x = ' <!-- MediaTime, etc. -->';
fprintf(fid, '%s\n',x);
%timeunit = 1/Fs;
x = strcat('	<HopSize timeunit="PT1N', num2str(Fs), 'F">1</HopSize>');
fprintf(fid,'%s\n',x);
%x = strcat('<Value totalSampleNum="', num2str(totalSampleNum), '"', ' channelNum="', num2str(channelNum),'">');
%fprintf(fid,'%s\n',x);
%x = strcat('</Value>');
%fprintf(fid, '%s \n',x);
x = strcat('</AudioSegment>');
fprintf(fid, '%s \n',x);

fclose(fid);


