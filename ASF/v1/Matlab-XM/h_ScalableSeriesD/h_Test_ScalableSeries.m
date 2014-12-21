%% File Name: Test_ADs.m
%%
%% Copyright (c), IME, All Rights Reserved
%%
%% Author: Dong Yan Huang
%% Version: 1.0  Time: 28 August 2000 (N3489)
%% Last modified: 27 Mar 2001 (N3704)

clear all;
%path(path,'C:/dongyanbackup/research/data/Sqam');
%path(path,'C:/dongyanbackup/research/data/Paris5');
%path(path,'C:/dongyanbackup/research/data/phoneme');
path(path,'C:/dongyanbackup/standards/mpeg/mpeg7/ScalableSeries');
%path(path,'C:/dongyanbackup/standards/mpeg/mpeg7/AIC');
%path(path,'C:/dongyanbackup/standards/mpeg/mpeg7/CTmelody');
%path(path,'C:/dongyanbackup/standards/mpeg/mpeg7/CTtimbre');
%path(path,'C:/dongyanbackup/standards/mpeg/mpeg7/Timbre');
%path(path,'C:/dongyanbackup/standards/mpeg/mpeg7/Melody');
%path(path,'C:/dongyanbackup/standards/mpeg/mpeg7/Segment');

%path(path,'C:/dongyan/data/Sqam');
%path(path,'C:/dongyan/data/Paris5');
%path(path,'C:/dongyan/data/phoneme');
%path(path,'C:/dongyan/demos/mpeg7demos/AudioDescriptors/ScalableSeries');
%path(path,'C:/dongyan/demos/mpeg7demos/AudioDescriptors/AIC');
%path(path,'C:/dongyan/demos/mpeg7demos/AudioDescriptors/CTmelody');
%path(path,'C:/dongyan/demos/mpeg7demos/AudioDescriptors/CTtimbre');
%path(path,'C:/dongyan/demos/mpeg7demos/AudioDescriptors/Timbre');
%path(path,'C:/dongyan/demos/mpeg7demos/AudioDescriptors/Melody');
%path(path,'C:/dongyan/demos/mpeg7demos/AudioDescriptors/Segment');

clear all;

%aufileName = 'Spfe49_1.wav';
%auData = zeros(13, 10);
auData = [10  10  10  10  10  10  10  10  10  10  14  17  19  18 ...
      15  11  10  10  13  20  27  32  33  30  25  18  14  14 ...
      20  30  39  46  48  43  35  25  19  20  27  40  52  61 ...
      63  56  45  32  25  25  34  50  65  76  77  69  54  39 ...
      30  30  42  60  78  90  92  82  65  46  35  36  49  70 ...
      91  99  99  95  75  54  41  41  56  80  99  99  99  99 ...
      84  61  46  46  63  90  99  99  99  99  94  68  51  52  70  99];

%%
%% Audio Samples and information such like total samples number(totalSampleNum), sampling rate(Fs), 
%% bit number per sample (bitNum) and channel number (channelNum)
%%

%[audata, totalSampleNum, Fs, bitNum, channelNum] = h_AudioSamples(aufileName);

%%-------------------- ScalableSeriesType ------------------------------
%% An abstract type representing series of values, at full resolution or 
%% after scaling (downsampling) by a scaling operation. In the latter case 
%% the series contains a sequence of "runs" of elements sharing the same 
%% scale ratio.
%%
%% Scalable Series Parameters: (which relates to ScalableSeriesType) 
%%
%% scaling:to specify how the original samples are scaled. If absent, the 
%%         original samples are described without scaling.
%% ratio: scale ratio (number of original samples represented by each scaled 
%%        sample) common to all elements in run. The default value when Scaling 
%%        is absent is 1.
%% elementNum: number of scaled elements in run. The default value when Scaling 
%%             is absent is equal to the value of totalSampleNum.
%% totalSampleNum: total number of samples of the original series (before scaling).

%scaling = 1; ratio = 1; elementNum = 1; totalSampleNum = length(auData);weight_flag=0; weight=[];
%scaledData = ScalableSeries(auData, totalSampleNum, scaling, ratio, elementNum,weight_flag, weight);

%%-------------------- SeriesOfScalarType --------------------------------
%% This descriptor represents a series of scalars, at full resolution or scaled. 
%% Use this type within descriptor definitions to represent a series of feature values. 
%%
%% Scaling operations for scalar series are : raw, min, max, mean, variance,
%% random, first, last,weight
%%
if 1
   weight =  [0  0  0  0  0  0  0  0  0  0  1  1  1  1  1  1  0  0  ...
      1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  ...
      1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  ...
      1  1  1  1  1  1  1  1  1  1  1  1  1  1  1  0  0  1  1  ...
      1  1  1  1  1  0  0  0  0  1  1  1  1  1  1  0  0  0  0  ...
      1  1  1  1  1  0];

%% Set flag
SeriesOfScalarType = 1;
min_flag = 1; 
max_flag = 1; 
mean_flag = 1; 
random_flag =1; 
first_flag = 1; last_flag = 1; variance_flag=1;
write_flag = 1; % write_flag = 1 (write DDL in XML file)
                % write_flag = 0 (not write DDL in XML file)
                % write_flag = 2 (write values in XML file)
                
%% Initialization
totalSampleNum = 100;
scaledRatio = 32;
rescaledFactor = 1;
scalingRatio = scaledRatio*rescaledFactor;
elementNum = 4;

if length(weight)==0
   weight_flag = 0;
else
   weight_flag = 1;
end
h_SeriesOfScalarBegin(totalSampleNum);


if scalingRatio == 1
	Raw = h_Raw_SeriesOfScalar(auData,totalSampleNum);
end
   
if min_flag == 1
   minValues = h_Min_SeriesOfScalar(auData, scalingRatio, elementNum, weight_flag,weight, write_flag);
   write_flag = 0;
end
if max_flag == 1
   maxValues = h_Max_SeriesOfScalar(auData, scalingRatio, elementNum, weight_flag,weight, write_flag);
   write_flag = 0;   
end
if mean_flag == 1 | variance_flag == 1
   meanValues = h_Mean_SeriesOfScalar(auData, scalingRatio, elementNum, weight_flag,weight, write_flag);
   write_flag = 0;   
end
if mean_flag ==1 | variance_flag == 1
   varanceValues = h_Variance_SeriesOfScalar(auData, scalingRatio, elementNum, weight_flag,weight, write_flag);
   write_flag = 0;   
end
if weight_flag == 1
   weightValues = h_Weight_SeriesOfScalar(scalingRatio, elementNum, weight, write_flag);
   write_flag = 0;   
end
   
if first_flag == 1
   firstValues = h_First_SeriesOfScalar(auData, scalingRatio, elementNum, write_flag);
   write_flag = 0;   
end

if last_flag == 1
   lastValues = h_Last_SeriesOfScalar(auData, scalingRatio, elementNum, write_flag);
	write_flag = 0;   
end

if random_flag == 1
   randomPlace = 4;
   randomValues = h_Random_SeriesOfScalar(auData, scalingRatio, elementNum, randomPlace, write_flag);
   write_flag = 0;   
end

h_SeriesOfScalarEnd;
end

%%--------------------SeriesOfScalarBinaryType -----------------------------------
%% Use this type to instantiate a series of scalars with a uniform power-of-two ScaleRatio. 
%% The restriction to a power-of-two ratio eases the comparison of series with different 
%% ScaleRatios. It also allows an additional scaling operation to be defined (scalewise variance), 
%% and allows the data to be coded in "rootFirst" format.
if 1
totalSampleNum = 100;
scaledRatio = 32;
rescaledFactor = 1;
scalingRatio = scaledRatio*rescaledFactor;
elementNum = 4;

[varianceScalewiseValues, rootFirstValues] = h_SeriesOfScalarBinary(auData, scalingRatio,elementNum);
end

