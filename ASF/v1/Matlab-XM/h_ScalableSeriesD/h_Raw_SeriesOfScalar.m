function Raw = Raw_SeriesOfScalar(auData,totalSampleNum)

%%% File: Raw_SeriesOfScalar.m
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


 Raw = auData;
 x = strcat('	<Raw>');
 fprintf(fid, '%s ',x);
 N = floor(totalSampleNum/20);
 for i = 1:N
  	x = strcat('	', num2str(auData(1+(i-1)*20:i*20)));
   if i*20 == totalSampleNum
      x = strcat(x, '</Raw>');
      fprintf(fid, '%s \n',x);
   else
      fprintf(fid, '%s \n',x);
   end
 end
 N1 = totalSampleNum - N*20;
 if N1 ~= 0
    x = strcat('	', num2str(auData(N1:totalSampleNum)), '</Raw>');
    fprintf(fid, '%s \n',x);
 end



