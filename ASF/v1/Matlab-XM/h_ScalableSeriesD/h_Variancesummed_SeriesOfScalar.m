function varianceSummedValues = Variancesummed_SeriesOfVector(auData, totalSampleNum, scalingRatio, elementNum, weight_flag, weight, write_flag)

%%% File: Variancesummed_SeriesOfVector.m
%%
%% --------------  ---------------
%%
%% The function of this subroutine is series of summed variance coefficients of 
%% groups of samples. Size of array must equal elementNum, or 0 if Raw is present. 
%% If VarianceSummed is present, Mean must also be present.
%%
%% 
%% Definition:
%%
%% N = P*Q (?)
%% P -> scaleRatio, Q -> rescaleFactor 
%% varianceValue = (1/N)\sum_{j=1}^{D} \sum_{i=1+(k-1)*N}^{kN} (x_i^j - \bar{x}_1^j)^2
%% x -> audata
%% If Weight present, 
%% varianceValue = \sum_{j=1}^{D} \sum_{i=1+(k-1)*N}^{kN} w_i^j (x_i^j - \bar{x}_1^j)^2/ (\sum_{j=1}^D
%% \sum_{i = 1+(k-1)N}w_i^j
%% If all have zero weight, set to zero by convention. 
%% (N3704)
%%
%%
%% Copyright (c), IME, All Rights Reserved
%%
%% Author: Dong Yan Huang
%% Version: 1.0  Time: 28 October 2000 (N3489)
%% Last Modified: 27 Mar 2001 (N3704)

global fid;

%%if nargin < 3, error('constr requires three input arguments'); end
%%if nargin < 5, weight_flag = 0; weight= []; end


%% Initialization
[rows, columns]=size(auData);
vectorSize = columns;
len = length(scalingRatio);
varianceSummedValues =[];


if weight_flag == 0
   if len == 1 & scalingRatio(len) == 1& write_flag == 1
      x = strcat('<VarianceSummed/>');
      fprintf(fid, '%s\n ',x);
   else
      k = 1;
      len = length(scalingRatio);
      rowNumOld = 1;
      columnNumOld = 0;
      while k <= len
         for i = 1:elementNum(k)
            rowNum = floor(i*scalingRatio(k)/vectorSize);
            columnNum = i*scalingRatio(k) - rowNum*vectorSize;
            if columnNum == 0 & columnNumOld == 0
              x = 0;
              for j = 1:vectorSize
               sn_segment = auData(rowNumOld:rowNum,j);
               sn_mean = mean(sn_segment);
               for l = 1:rowNum - rowNumOld
                  x = x + (sn_segment(l) - sn_mean)^2;
               end
             end
             varianceSummedValues =[varianceSummedValues  x/scalingRatio(k)];
         elseif columnNum ~= 0 & columnNumOld == 0
              x = 0;
              for j = 1:columnNum
              	sn_segment = auData(rowNumOld:rowNum+1,j);
               sn_mean = mean(sn_segment);
               for l = 1:rowNum+1 - rowNumOld
                  x = x + (sn_segment(l) - sn_mean)^2;
               end
              end
              for j = columnNum+1:vectorSize
                sn_segment = auData(rowNumOld:rowNum,j);
                sn_mean = mean(sn_segment);
                for l = 1:rowNum - rowNumOld
                  x = x + (sn_segment(l) - sn_mean)^2;
                end
             end
             varianceSummedValues =[varianceSummedValues  x/scalingRatio(k)];
          else
             x=0;
              for j = 1:columnNumOld
                sn_segment = auData(rowNumOld+1:rowNum+1,j);
 					 sn_mean = mean(sn_segment);
                for l = 1:rowNum - rowNumOld
                  x = x + (sn_segment(l) - sn_mean)^2;
                end
              end
              for j = columnNumOld+1:columnNum
                sn_segment = auData(rowNumOld:rowNum+1,j);
 					 sn_mean = mean(sn_segment);
                for l = 1:rowNum - rowNumOld
                  x = x + (sn_segment(l) - sn_mean)^2;
                end
              end
			     for j = columnNum+1:vectorSize
                sn_segment = auData(rowNumOld:rowNum,j);
 					 sn_mean = mean(sn_segment);
                for l = 1:rowNum - rowNumOld
                  x = x + (sn_segment(l) - sn_mean)^2;
                end
              end
              varianceSummedValues =[varianceSummedValues  x/scalingRatio(k)];
           end
            rowNumOld = rowNum+1;
            columnNumOld = columnNum;
         end
         if write_flag == 1
          		x = strcat('<Scaling ratio="',num2str(scalingRatio(k)),'" elementNum="',num2str(elementNum(k)),'"/>');
             	fprintf(fid, '%s\n ',x);
         end
			k=k+1;
      end
      x = '<Variancesummed>';
     x = strcat(x, num2str(varianceSummedValues), '	<Variancesummed>');
     fprintf(fid, '	%s \n',x);
   end
else
  	if len == 1 & scalingRatio(len) == 1& write_flag == 1
      x = strcat('<Variancesummed/>');
      fprintf(fid, '%s\n ',x);
   else
      if sum(weight) == 0
         varianceValues = zeros(1,sumElement);
	  	else
         k = 1;
         len = length(scalingRatio);
         rowNumOld = 1;
         columnNumOld = 0;
         while k <= len
            lastWL = 0;
            for i = 1:elementNum(k)
               weightTmp = zeros(elementNum(k), vectorSize);
            	rowNum = floor(i*scalingRatio(k)/vectorSize);
               columnNum = i*scalingRatio(k) - rowNum*vectorSize;
               if columnNum == 0 & columnNumOld == 0
                  weig = 0;
                  for l = 1:elementNum(k)
                     weightTmp(l,1:vectorSize) = weight(1+(l-1)*vectorSize+lastWL:l*vectorSize+lastWL);
                     weig = weig + sum( weight(1+(l-1)*vectorSize+lastWL:l*vectorSize+lastWL));  
                  end
                  x = 0;
              		for j = 1:vectorSize
               		sn_segment = auData(rowNumOld:rowNum,j);
               		sn_mean = mean(sn_segment);
               		for l = 1:rowNum - rowNumOld
                  		x = x + weightTmp(l,j)*(sn_segment(l) - sn_mean)^2;
               		end
             		end
                  varianceSummedValues =[varianceSummedValues  x/weig];
						lastWL = lastWL + scalingRatio(k);
               elseif columnNum ~= 0 & columnNumOld == 0
                  weig = 0;
                  for l = 1:elementNum(k)-1
                     weightTmp(l,1:vectorSize) = weight(1+(l-1)*vectorSize+lastWL:l*vectorSize+lastWL);
                     weig = weig + sum(weight(1+(l-1)*vectorSize+lastWL:l*vectorSize+lastWL));
                  end
                  lastWL = lastWL + (elementNum(k)-1)*vectorSize; 
                  weightTmp(elementNum(k),1:columnNum) = weight(lastWL+1:lastWL+columnNum);
                  weig = weig + sum(weight(lastWL+1:lastWL+columnNum));
                  lastWL = lastWL + columnNum;
                  x = 0;
              		for j = 1:columnNum
                     sn_segment = auData(rowNumOld:rowNum+1,j);
                     sn_mean = mean(sn_segment);
               		for l = 1:rowNum + 1 - rowNumOld
                  		x = x + weightTmp(l,j)*(sn_segment(l) - sn_mean)^2;
               		end
                  end
              		for j = columnNum+1:vectorSize
                     sn_segment = auData(rowNumOld:rowNum,j);
                     sn_mean = mean(sn_segment);
               		for l = 1:rowNum + 1 - rowNumOld
                  		x = x + weightTmp(l,j)*(sn_segment(l) - sn_mean)^2;
               		end
                  end
                  varianceSummedValues =[varianceSummedValues  x/weig];
               else
                  weig = 0;
                  weightTmp(1,1:columnNumOld)= zeros(1,columnNumOld);
                  weightTmp(1,columnNumOld+1:vectorSize) = weight(1+lastWL:lastWL+vectorSize-columnNumOld);
                  weig = weig + sum(weight(1+lastWL:lastWL+vectorSize-columnNumOld));
                  lastWL = lastWL + vectorSize-columnNumOld;
                  for l = 2:elementNum(k)-1
                     weightTmp(l,1:vectorSize) = weight(1+(l-1)*vectorSize+lastWL:l*vectorSize+lastWL);
                     weig = weig + sum(weight(1+(l-1)*vectorSize+lastWL:l*vectorSize+lastWL));
                  end
                  lastWL = lastWL + (elementNum(k)-2)*vectorSize; 
                  weightTmp(elementNum(k),1:columnNum) = weight(lastWL+1:lastWL+columnNum);
                  weig = weig + sum(weight(lastWL+1:lastWL+columnNum));
                  lastWL = lastWL + columnNum;
                  x = 0;
                  for j = 1:columnNumOld
                     sn_segment = auData(rowNumOld+1:rowNum+1,j);
                     sn_mean = mean(sn_segment);
               		for l = 1:rowNum - rowNumOld
                  		x = x + weightTmp(l,j)*(sn_segment(l) - sn_mean)^2;
               		end
                  end
              		for j = columnNumOld+1:columnNum
                     sn_segment = auData(rowNumOld:rowNum+1,j);
                     sn_mean = mean(sn_segment);
               		for l = 1:rowNum + 1 - rowNumOld
                  		x = x + weightTmp(l,j)*(sn_segment(l) - sn_mean)^2;
               		end
              		end
			     		for j = columnNum+1:vectorSize
                     sn_segment = auData(rowNumOld:rowNum,j);
                     sn_mean = mean(sn_segment);
               		for l = 1:rowNum - rowNumOld
                  		x = x + weightTmp(l,j)*(sn_segment(l) - sn_mean)^2;
               		end               	
                  end
                  varianceSummedValues =[varianceSummedValues  x/weig];
           		end
            	rowNumOld = rowNum+1;
            	columnNumOld = columnNum;
         	end
         	if write_flag == 1
          		x = strcat('<Scaling ratio="',num2str(scalingRatio(k)),'" elementNum="',num2str(elementNum(k)),'"/>');
             	fprintf(fid, '%s\n ',x);
         	end
				k=k+1;
         end
      end
       x = '<Variancesummed>';
     x = strcat(x, num2str(varianceSummedValues), '	<Variancesummed>');
     fprintf(fid, '	%s \n',x);
   end
end
