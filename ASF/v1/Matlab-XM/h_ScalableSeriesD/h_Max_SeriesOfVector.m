function maxValues = Max_SeriesOfVector(auData, totalSampleNum, scalingRatio, elementNum, weight_flag, weight, write_flag)

%%% File: Max_SeriesOfVector.m
%%
%% --------------  ---------------
%%
%% The function of this subroutine is series of maxima of groups of samples. 
%% Number of rows must equal elementNum, number of columns must equal 'dim' 
%% in FloatMatrixType, or 0 if Raw is present.
%%
%% 
%% Definition:
%%
%% N = P*Q (?)
%% P -> scaleRatio, Q -> rescaleFactor 
%% maxValue = \max_{i=1+(k-1)*N}^{kN} x_i
%% x -> audata
%% If Weight present, ignore samples with zero weight. 
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
if len == 1
   sumElement = elementNum;
else
   sumElement = sum(elementNum);
end
maxValues = zeros(sumElement, vectorSize);


if weight_flag == 0
   if len == 1 & scalingRatio(len) == 1& write_flag == 1
      x = strcat('<Max/>');
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
            if columnNum == 0
              for j = 1:vectorSize
              	sn_segment = auData(rowNumOld:rowNum,j);
               maxValues(i,j) = max(sn_segment);
              end
           elseif columnNumOld == 0
              for j = 1:columnNum
              	sn_segment = auData(rowNumOld:rowNum+1,j);
               maxValues(i,j) = max(sn_segment);
              end
              for j = columnNum+1:vectorSize
                sn_segment = auData(rowNumOld:rowNum,j);
                maxValues(i,j) = max(sn_segment);
              end
           else
              for j = 1:columnNumOld
                sn_segment = auData(rowNumOld+1:rowNum+1,j);
 					 maxValues(i,j) = max(sn_segment);
              end
              for j = columnNumOld+1:columnNum
                sn_segment = auData(rowNumOld:rowNum+1,j);
 					 maxValues(i,j) = max(sn_segment);
              end
			     for j = columnNum+1:vectorSize
                sn_segment = auData(rowNumOld:rowNum,j);
 					 maxValues(i,j) = max(sn_segment);
              end
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
      [rows, columns] = size(maxValues);
      x = strcat('	<Max dim = "', num2str(rows), '	', num2str(columns),'">');
      fprintf(fid, '%s ',x);
      for i = 1:rows-1
      	x = strcat(num2str(maxValues(i, 1:vectorSize)));
         fprintf(fid, '	%s \n',x);
      end
      x = strcat(num2str(maxValues(rows, 1:vectorSize)));
      x = strcat(x, '</Max>');
      fprintf(fid, '	%s \n',x);
	end
else
  	if len == 1 & scalingRatio(len) == 1& write_flag == 1
      x = strcat('<Max/>');
      fprintf(fid, '%s\n ',x);
   else
      if sum(weight) == 0
         maxValues = zeros(sumElement, vectorSize);
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
                  for l = 1:elementNum(k)
                     weightTmp(l,1:vectorSize) = weight(1+(l-1)*vectorSize+lastWL:l*vectorSize+lastWL);
                  end
                  for j = 1:vectorSize
                     sn_segment = auData(rowNumOld:rowNum,j);
                     l = 1;
                     for m = 1:elementNum(k)
                        if weightTmp(m,j)~= 0
                           sn_seg(l) = sn_segment(m);
                           l = l+1;
                        end
                     end
               		maxValues(i,j) = max(sn_seg(1:l-1));
                  end
                  lastWL = lastWL + scalingRatio(k);
               elseif columnNum ~= 0 & columnNumOld == 0
                  for l = 1:elementNum(k)-1
                     weightTmp(l,1:vectorSize) = weight(1+(l-1)*vectorSize+lastWL:l*vectorSize+lastWL);
                  end
                  lastWL = lastWL + (elementNum(k)-1)*vectorSize; 
                  weightTmp(elementNum(k),1:columnNum) = weight(lastWL+1:lastWL+columnNum);
                  lastWL = lastWL + columnNum;
              		for j = 1:columnNum
                     sn_segment = auData(rowNumOld:rowNum+1,j);
                     l = 1;
                     for m = 1:elementNum(k)
                        if weightTmp(m,j)~= 0
                           sn_seg(l) = sn_segment(m);
                           l = l+1;
                        end
                     end
               		maxValues(i,j) = max(sn_seg(1:l-1));
              		end
              		for j = columnNum+1:vectorSize
                     sn_segment = auData(rowNumOld:rowNum,j);
                     l = 1;
                     for m = 1:elementNum(k)-1
                        if weightTmp(m,j)~= 0
                           sn_seg(l) = sn_segment(m);
                           l = l+1;
                        end
                     end
               		maxValues(i,j) = max(sn_seg(1:l-1));
                  end
               else
                  weightTmp(1,1:columnNumOld)= zeros(1,columnNumOld);
                  weightTmp(1,columnNumOld+1:vectorSize) = weight(1+lastWL:lastWL+vectorSize-columnNumOld);
                  lastWL = lastWL + vectorSize-columnNumOld;
                  for l = 2:elementNum(k)-1
                     weightTmp(l,1:vectorSize) = weight(1+(l-1)*vectorSize+lastWL:l*vectorSize+lastWL);
                  end
                  lastWL = lastWL + (elementNum(k)-2)*vectorSize; 
                  weightTmp(elementNum(k),1:columnNum) = weight(lastWL+1:lastWL+columnNum);
                  lastWL = lastWL + columnNum;
                  for j = 1:columnNumOld
                     sn_segment = auData(rowNumOld+1:rowNum+1,j);
                     l = 1;
                     for m = 2:elementNum(k)
                        if weightTmp(m,j)~= 0
                           sn_seg(l) = sn_segment(m);
                           l = l+1;
                        end
                     end
               		maxValues(i,j) = max(sn_seg(1:l-1));
              		end
              		for j = columnNumOld+1:columnNum
                     sn_segment = auData(rowNumOld:rowNum+1,j);
                     l = 1;
                     for m = 1:elementNum(k)
                        if weightTmp(m,j)~= 0
                           sn_seg(l) = sn_segment(m);
                           l = l+1;
                        end
                     end
               		maxValues(i,j) = max(sn_seg(1:l-1)); 
              		end
			     		for j = columnNum+1:vectorSize
                     sn_segment = auData(rowNumOld:rowNum,j);
                     l = 1;
                     for m = 1:elementNum(k)-1
                        if weightTmp(m,j)~= 0
                           sn_seg(l) = sn_segment(m);
                           l = l+1;
                        end
                     end
               		maxValues(i,j) = max(sn_seg(1:l-1)); 
              		end
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
      [rows, columns] = size(maxValues);
      x = strcat('	<Max dim = "', num2str(rows), '	', num2str(columns),'">');
      fprintf(fid, '%s ',x);
      for i = 1:rows-1
      	x = strcat(num2str(maxValues(i, 1:vectorSize)));
         fprintf(fid, '	%s \n',x);
      end
      x = strcat(num2str(maxValues(rows, 1:vectorSize)));
      x = strcat(x, '</Max>');
      fprintf(fid, '	%s \n',x);
	end
end
