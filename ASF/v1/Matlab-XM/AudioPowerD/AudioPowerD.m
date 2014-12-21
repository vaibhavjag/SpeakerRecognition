function AudioPower_SeriesOfScalar = AudioPowerType(auData,totalSampleNum,samplingRate,scalingRatio,elementNum,weight) 

%% File: AudioPowerType.m
%%
%% ------------- AudioPowerType--------------------
%%
%% The function of this subroutine is to describe the temporally-smoothed 
%% instantaneous power (square of waveform values).
%%
%% 
%%
%% Copyright (c), IME, All Rights Reserved
%%
%% Author: Dong Yan Huang
%% Version: 1.0  Time: 28 October 2000 (N3489)
%% Last Modified: 27 Mar 2001 (N3704)
global fid;
write_flag = 1; % write_flag = 1 (write DDL in XML file)
                % write_flag = 0 (not write DDL in XML file)
                % write_flag = 2 (write values in XML file)
                
if length(weight)==0
   weight_flag = 0;
else
   weight_flag = 1;
end
hopSize = samplingRate;
sampleNum = 1024;
frameNum = floor(totalSampleNum/sampleNum);

fid = fopen('AudioPower.xml','w');
x = '<!-- ##################################################################### -->';
fprintf(fid, '%s\n',x);
x = '<!-- Definition of AudioPowerType                                          -->';
fprintf(fid, '%s\n',x);
x = '<!-- ##################################################################### -->';
fprintf(fid, '%s\n',x);
x = '<!-- <complexType name="AudioPowerType">                                   -->';
fprintf(fid, '%s\n',x);
x = '<!-- <complexContent>                                                      -->';
fprintf(fid, '%s\n',x);
x = '<-- <extension base="mpeg7:AudioSampledType">                              -->';
fprintf(fid, '%s\n',x);
x = '<-- <sequence>                                                             -->';
fprintf(fid, '%s\n',x);
x = '<-- <element name="Value" type="mpeg7:SeriesOfScalarType" maxOccurs="unbounded"/> -->';
fprintf(fid, '%s\n',x);
x = '<-- </sequence>                                                            -->';
fprintf(fid, '%s\n',x);
x = '<-- </extension>                                                           -->';
fprintf(fid, '%s\n',x);
x = '<-- </complexContent>                                                      -->';
fprintf(fid, '%s\n',x);
x = '<-- </complexType>                                                         -->';
fprintf(fid, '%s\n',x);

x = '<AudioSegment idref="102">';
fprintf(fid, '%s\n',x);
x = ' <!-- MediaTime, etc. -->';
fprintf(fid, '%s\n',x);
x = ' <AudioPower>';
fprintf(fid, '%s\n',x);
x = strcat('  <HopSize timeunit="PT1N', num2str(hopSize), '">1</HopSize>');
fprintf(fid,'%s\n',x);
x = strcat('   <Value totalSampleNum="', num2str(totalSampleNum), '">');
fprintf(fid,'%s\n',x);

sumElement = sum(elementNum);
AudioPower_SeriesOfScalar = zeros(frameNum, sumElement);
for i = 1:frameNum
   signal = auData(1+(i-1)*sampleNum:i*sampleNum);
   audioPowerData = signal.^2;
   meanValues = h_Mean_SeriesOfScalar(audioPowerData, scalingRatio, elementNum, weight_flag,weight, write_flag);
end

%% Close file 
x = strcat('   </Value>');
fprintf(fid, '%s \n',x);
x = ' </AudioPower>';
fprintf(fid, '%s \n',x);
x = strcat('</AudioSegment>');
fprintf(fid, '%s \n',x);

fclose(fid);
