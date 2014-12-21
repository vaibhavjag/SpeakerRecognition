%%------------------SeriesOfVectorType-------------------------------------------------
%% This descriptor represents a series of vectors
%%
clear all;

totalSampleNum = 128;
%auData = zeros(13,10);
auData(1,1:10) = [10  10  10  10  10  10  10  10  10  10];
auData(2,1:10) = [14  17  19  18  15  11  10  10  13  20];
auData(3,1:10) = [27  32  33  30  25  18  14  14  20  30];
auData(4,1:10) = [39  46  48  43  35  25  19  20  27  40];
auData(5,1:10) = [52  61  63  56  45  32  25  25  34  50];
auData(6,1:10) = [65  76  77  69  54  39  30  30  42  60];
auData(7,1:10) = [78  90  92  82  65  46  35  36  49  70];
auData(8,1:10) = [91  99  99  95  75  54  41  41  56  80];
auData(9,1:10) = [99  99  99  99  84  61  46  46  63  90];
auData(10,1:10)= [99  99  99  99  94  68  51  52  70  99];
auData(11,1:10)= [12  15  16  17  24  13  45  67  24  36];
auData(12,1:10) =[47  25  46  12  15  16  19  20  30  43];
auData(13,1:10) = [88  19  20  31  35  26  28 30   0   0];
weight =[];

SeriesOfVectorType = 1;
min_flag = 1; 
max_flag = 1; 
mean_flag = 1; 
random_flag =1; 
first_flag = 1; last_flag = 1; variance_flag=1;covariance_flag = 1;
variancesummed_flag = 1; variancesummed_flag = 1;
maxsqdist_flag = 1;


write_flag = 1; % write_flag = 1 (write DDL in XML file)
                % write_flag = 0 (not write DDL in XML file)
                % write_flag = 2 (write values in XML file)
                
%% Initialization                
totalSampleNum = 128;
scaledRatio = 32;
rescaledFactor = 1;
scalingRatio = scaledRatio*rescaledFactor;
elementNum = 4;
[rows, columns] = size(auData);
vectorSize = columns;

if length(weight)==0
   weight_flag = 0;
else
   weight_flag = 1;
end
h_SeriesOfVectorBegin(totalSampleNum, vectorSize);


if scalingRatio == 1
	Raw = h_Raw_SeriesOfVector(auData,totalSampleNum);
end
write_flag = 1;   
if min_flag == 1
   minValues = h_Min_SeriesOfVector(auData, totalSampleNum, scalingRatio, elementNum, weight_flag, weight,write_flag);
   write_flag = 0;
end
if max_flag == 1
   maxValues = h_Max_SeriesOfVector(auData, totalSampleNum, scalingRatio, elementNum, weight_flag,weight, write_flag);
   write_flag = 0;   
end
if mean_flag == 1 | variance_flag == 1 | maxsqdist_flag == 1 | variancesummed_flag == 1 | covariance_flag == 1
   meanValues = h_Mean_SeriesOfVector(auData, totalSampleNum, scalingRatio, elementNum, weight_flag,weight, write_flag);
   write_flag = 0;   
end
if random_flag == 1
  	randomPlace = 3;
   randomValues = h_Random_SeriesOfVector(auData, totalSampleNum, scalingRatio, elementNum, randomPlace, write_flag);
   write_flag = 0;   
end

if first_flag == 1
   firstValues = h_First_SeriesOfVector(auData, totalSampleNum, scalingRatio, elementNum, write_flag);
   write_flag = 0;   
end

if last_flag == 1
   lastValues = h_Last_SeriesOfVector(auData, totalSampleNum, scalingRatio, elementNum, write_flag);
	write_flag = 0;   
end

if mean_flag == 1 | variance_flag == 1 | maxsqdist_flag == 1 | variancesummed_flag == 1
   varanceValues = h_Variance_SeriesOfVector(auData, totalSampleNum, scalingRatio, elementNum, weight_flag,weight, write_flag);
   write_flag = 0;   
end
%if mean_flag == 1 |covariance_flag == 1
%   covaranceValues = Covariance_SeriesOfVector(auData, totalSampleNum, scalingRatio, elementNum, weight_flag,weight, write_flag);
%   write_flag = 0;   
%end
if mean_flag == 1 | variancesummed_flag == 1
   varanceSummedValues = h_Variancesummed_SeriesOfScalar(auData, totalSampleNum, scalingRatio, elementNum, weight_flag,weight, write_flag);
   write_flag = 0;   
end
%if mean_flag == 1 | variance_flag == 1 | maxsqdist_flag == 1 | variancesummed_flag == 1 
%   MaxSqDistValues = MaxSqDist_SeriesOfScalar(auData, scalingRatio, elementNum, weight_flag,weight, write_flag);
%  write_flag = 0;   
%end

if weight_flag == 1
   weightValues = h_Weight_SeriesOfScalar(scalingRatio, elementNum, weight, write_flag);
   write_flag = 0;   
end
h_SeriesOfVectorEnd;





