function Raw = Raw_SeriesOfVector(auData,totalSampleNum)

%%% File: Raw_SeriesOfVector.m
%%
%% -----------------------------
%%
%% The function of this subroutine is to series of unscaled samples 
%% (full resolution). Use only if Scaling is absent to indicate the 
%% entire series. 
%% (N3704)
%%
%%
%% Copyright (c), IME, All Rights Reserved
%%
%% Author: Dong Yan Huang
%% Version: 1.0  Time: 28 October 2000 (N3489)
%% Last Modified: 27 Mar 2001 (N3704)

%%if nargin < 5, error('constr requires five input arguments'); end
%%if nargin < 6, weight_flag = 0; weight= []; end
 global fid;

 [rows, columns] = size(auData);
 vectorSize = columns;

 Raw = auData;
 x = strcat('	<Raw dim = "', num2str(rows), '	', num2str(columns),'">');
 fprintf(fid, '%s ',x);
 %N = floor(totalSampleNum/vectorSize);
 for i = 1:rows
  	if i*vectorSize >= totalSampleNum
      t1 = totalSampleNum - (i-1)*vectorSize;
   	x = strcat(num2str(auData(i, 1:t1)));  
      x = strcat(x, '</Raw>');
      fprintf(fid, '	%s \n',x);
   else
      x = strcat(num2str(auData(i, 1:vectorSize)));
      fprintf(fid, '	%s \n',x);
   end
end
 


