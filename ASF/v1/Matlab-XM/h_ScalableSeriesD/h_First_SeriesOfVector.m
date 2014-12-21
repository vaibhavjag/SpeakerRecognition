function firstValues = First_SeriesOfVector(auData, totalSampleNum, scalingRatio, elementNum, write_flag)

%%% File: First_SeriesOfVector.m
%%
%% --------------  ---------------
%%
%% The function of this subroutine is Series of first 
%% of groups of samples. Size of the vector should equal 
%% elementNum, or 0 if Raw is present.
%% 
%% Definition:
%%
%% N = P*Q (?)
%% P -> scaleRatio, Q -> rescaleFactor 
%% FirstValue = \first_{i=1+(k-1)*N}^{kN} x_i
%% x -> audata
%% ignore when Weight present,  
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
firstValues = zeros(sumElement, vectorSize);

if len == 1 & scalingRatio(len) == 1& write_flag == 1
	x = strcat('<First/>');
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
               firstValues(i,j) = sn_segment(1);
              end
           elseif columnNumOld == 0
              for j = 1:columnNum
              	sn_segment = auData(rowNumOld:rowNum+1,j);
               firstValues(i,j) = sn_segment(1);
              end
              for j = columnNum+1:vectorSize
                sn_segment = auData(rowNumOld:rowNum,j);
                firstValues(i,j) = sn_segment(1);
              end
           else
              for j = 1:columnNumOld
                sn_segment = auData(rowNumOld+1:rowNum+1,j);
 					 firstValues(i,j) = sn_segment(1);
              end
              for j = columnNumOld+1:columnNum
                sn_segment = auData(rowNumOld:rowNum+1,j);
 					 firstValues(i,j) = sn_segment(1);
              end
			     for j = columnNum+1:vectorSize
                sn_segment = auData(rowNumOld:rowNum,j);
 					 firstValues(i,j) = sn_segment(1);
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
	[rows, columns] = size(firstValues);
	x = strcat('	<First dim = "', num2str(rows), '	', num2str(columns),'">');
	fprintf(fid, '%s ',x);
	for i = 1:rows-1
		x = strcat(num2str(firstValues(i, 1:vectorSize)));
   	fprintf(fid, '	%s \n',x);
	end
	x = strcat(num2str(firstValues(rows, 1:vectorSize)));
	x = strcat(x, '</First>');
	fprintf(fid, '	%s \n',x);

end
 
    
       

   
