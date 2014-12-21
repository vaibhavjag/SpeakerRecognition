function [Raw, maxValues, minValues, rootFirstValues,varianceScalewiseValues] = AudioWaveformType(auData,totalSampleNum,scalingRatio,elementNum,weight_flag, weight, write_flag,rootFirst) 

%%% File: AudioWaveformEnvelope.m
%%
%% -------------- AudioWaveformEnvelope Description---------------
%%
%% The function of this subroutine is to display the audio waveform 
%% using a small set of values that represent extrema (min and max) 
%% of sets of samples. Min and max are stored as scalable time series 
%% within the AudioWaveformEnvelopeType.
%% 
%% 
%% 
%%
%% Copyright (c), IME, All Rights Reserved
%%
%% Author: Dong Yan Huang
%% Version: 1.0  Time: 28 October 2000 (N3489)
%% Last Modified: 27 Mar 2001 (N3704)
global fid;

hopSize = 1;


fid = fopen('AudioWaveformEnvelope.xml','w');
x = '<!-- ##################################################################### -->';
fprintf(fid, '%s\n',x);
x = '<!-- Definition of AudioWaveformEnvelopeType                               -->';
fprintf(fid, '%s\n',x);
x = '<!-- ##################################################################### -->';
fprintf(fid, '%s\n',x);
x = '<!-- <complexType name="AudioWaveformEnvelopeType">                        -->';
fprintf(fid, '%s\n',x);
x = '<!--   <complexContent>                                                    -->';
fprintf(fid, '%s\n',x);
x = '<!--      <extension base="mpeg7:AudioSampledType">                        -->';
fprintf(fid, '%s\n',x);
x = '<!--        <sequence>                                                     -->';
fprintf(fid, '%s\n',x);
x = '<!--       <element name="SeriesOfScalar" type="mpeg7:SeriesOfScalarType"/>-->';
fprintf(fid, '%s\n',x);
x = '<!--          if ScaleRatio is constant and equal to a power ot two        -->';
fprintf(fid, '%s\n',x);
x = '<!--<element name="SeriesOfScalarBinary" type="mpeg7:SeriesOfScalarBinaryType"/>-->';
fprintf(fid, '%s\n',x);
x = '<!--        </sequence>                                                     -->';
fprintf(fid, '%s\n',x);
x = '<!--      </extension>                                                      -->';
fprintf(fid, '%s\n',x);
x = '<!--    </complexContent>                                                   -->';
fprintf(fid, '%s\n',x);
x = '<!--  </complexType>                                                        -->';
fprintf(fid, '%s\n',x);

x = '<AudioSegment idref="102">';
fprintf(fid, '%s\n',x);
x = ' <!-- MediaTime, etc. -->';
fprintf(fid, '%s\n',x);
x = ' <AudioWaveformEnvelope>';
fprintf(fid, '%s\n',x);
x = strcat('  <HopSize timeunit="', num2str(hopSize), '">1</HopSize>');
fprintf(fid,'%s\n',x);

if scalingRatio == 1
   x = strcat('   <Value totalSampleNum="', num2str(totalSampleNum), '">');
   fprintf(fid,'%s\n',x);
   Raw = h_Raw_SeriesOfScalar(auData,totalSampleNum);
   maxValues = [];
   minValues = [];
   x = ' 	<Mean/>';
   fprintf(fid,'%s\n',x);
   x = ' 	<Variance/>';
   fprintf(fid,'%s\n',x);
   rootFirstValues = [];
   varianceScalewiseValues = [];
elseif rem(scalingRatio,2) == 0
   if rootFirst == 1
   	x = strcat(' 	<Value rootFirst="true" totalSampleNum="', num2str(totalSampleNum), '">');
   	fprintf(fid,'%s\n',x);
   	x= strcat('			<Scaling ratio="', num2str(scalingRatio), '" elementNum="', num2str(elementNum),'"/>');
   	fprintf(fid,'%s\n',x);
   	rootFirstValues = h_rootFirst_SeriesOfScalarBinary(auData,scalingRatio, elementNum);
   	varianceScalewiseValues = [];
		x = strcat('			<Mean>', num2str(rootFirstValues),'</Mean>');
      fprintf(fid,'%s\n',x);
      Raw = auData;
      maxValues = [];
      minValues = [];
    else
   	x = strcat('	<Value totalSampleNum="',num2str(totalSampleNum), '">');
      fprintf(fid,'%s\n',x);
   	x = strcat('		<Scaling ratio="',num2str(scalingRatio),'" elementNum="',num2str(elementNum),'"/>');
   	fprintf(fid,'%s\n',x);
   	rootFirstValues = h_rootFirst_SeriesOfScalarBinary(auData,scalingRatio, elementNum);
   	varianceScalewiseValues= h_SWVariance_SeriesOfScalarBinary(auData,scalingRatio, elementNum);
   	x = strcat('			<Mean>',  num2str(rootFirstValues(1)), ' </Mean>');
   	fprintf(fid, '%s \n',x);
   	x = strcat(' 			<VarianceScalewise dim="', num2str(size(varianceScalewiseValues)), ' ">', num2str(varianceScalewiseValues));
   	fprintf(fid, '%s \n',x);
   	x ='                  </VarianceScalewise>';
      fprintf(fid, '%s \n',x);
      Raw = auData;
      maxValues = [];
      minValues = [];
	end 
else
   x = strcat('   <Value totalSampleNum="', num2str(totalSampleNum), '">');
	fprintf(fid,'%s\n',x);
   Raw = auData;
   minValues = h_Min_SeriesOfScalar(auData, scalingRatio, elementNum, weight_flag,weight, write_flag);
   write_flag = 0;
   maxValues = h_Max_SeriesOfScalar(auData, scalingRatio, elementNum, weight_flag,weight, write_flag);
   rootFirstValues = [];
   varianceScalewiseValues = [];
end


  
  %% Close file 
x = strcat('   </Value>');
fprintf(fid, '%s \n',x);
x = ' </AudioWaveformEnvelope>';
fprintf(fid, '%s \n',x);
x = strcat('</AudioSegment>');
fprintf(fid, '%s \n',x);

fclose(fid);
