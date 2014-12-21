function [minValues, scaledData] = ScalingSeries(auData, scaledRatio, rescaledFactor, elementNum, weight_flag, weight)

%%% File: Min_SeriesOfScalar.m
%%
%% --------------  ---------------
%%
%% The function of this subroutine is scalable series. 
%% Suppose the original series is scaled by a scale ratio of P, 
%% and this scaled series is then rescaled by a factor of Q. 
%% The result is the same as if the original series had been 
%% scaled by a scale ratio of N=PQ.
%% 
%% 
%% Definition:
%%
%% N = P*Q (?)
%% P -> scaleRatio, Q -> rescaleFactor 
%% 
%% (N3704)
%%
%%
%% Copyright (c), IME, All Rights Reserved
%%
%% Author: Dong Yan Huang
%% Version: 1.0  Time: 28 October 2000 (N3489)
%% Last Modified: 27 Mar 2001 (N3704)

if nargin < 3, error('constr requires four input arguments'); end
if nargin < 5, weight_flag = 0; weight= []; end

%% Initialization
totalSampleNum = length(auData);
scalingRatio = scaledRatio*rescaledFactor;
N=scalingRatio;
scaledSeriesSize = floor(totalSampleNum/N); 
scaledData = zeros(1,scaledSeriesSize);


if weight_flag == 0
   if scaledRatio == 1
      scaledData = auData;
   else
      j = 1;
      for i = 1:N:scaledSeriesSize
         scaledData(j) = auData(i);
         j=j+1;
      end
   end
else
   if scaledRatio == 1
      scaledData = weight.*auData;
   else
      sn = weight.*auData;
      j = 1;
      for i = 1:N:scaledSeriesSize
        scaledData(j) = sn(i);
        j=j+1;
      end
   end;
end;

   
