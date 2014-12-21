function varianceScalewiseValues = SWVariance_SeriesOfScalarBinary(auData,scalingRatio,elementNum)

%%  File: scalarwiseVariance_SeriesOfScalarBinary.m
%%
%%  The function of this subroutine is to decompose the variance into a vector of coefficients that 
%%  describe variability at different scales. The sum of these coefficients equals the variance. 
%%
%%  To calculate the scalewise variance of a set of N=2^m samples, first recursively form a binary 
%%  tree of means:
%%     \bar{x}_k^1 = (x_{2k-1} + x_{2k})/2, k = 1, \cdots, N/2;
%%     \bar{x}_k^2 = (\bar(x}_{2k-1}^1 + \bar{x}_2K^1)/2, k=1,\cdots, N/4;
%%     \bar{x}_k^m = (\bar{x}_{2k-1}^{m-1} + \bar{x}_{2k}^{m-1})/2; 
%%     ...
%%   Then calculate the coefficients:
%%    z^1 = (2/N) \sum_{k=1}^{N/2}(x_{2k-1}- x _{2k})^2/2
%%    z^2 = (4/N) \sum_{k=1}^{N/2}(x_{2k-1}^1- x_{2k}^1)^2/2
%%    z^m =  (x_{2k-1}^1- x_{2k}^1)^2/2
%% 
%% Copyright (c), IME, All Rights Reserved
%%
%% Author: Dong Yan Huang
%% Version: 1.0  Time: 28 August 2000 (N3489)
%% Last modified: 27 Mar 2001 (N3704)


totalSampleNum = length(auData);

%% Compute rootFirst
%rootFirstValues = rootFirst_SeriesOfScalarBinary(auData,scalingRatio, elementNum);

%% Compute variance scalewise

m = log2(scalingRatio*elementNum);
N = scalingRatio/2;
len = 1;
for i = 1:m
   len = len + pow2(i);
end
scalewiseValues = zeros(1,len);
len = scalingRatio*elementNum;
if totalSampleNum < len
	t1 = len - totalSampleNum;
   scalewiseValues(1:len) = [auData zeros(1, t1)];
   j = m-1;
   while j >= 0
   	N1 = pow2(j);
      for k = 1:N1
      	scalewiseValues(1, len+k) = (scalewiseValues(2*k-1 + len - pow2(j+1)) + scalewiseValues(2*k + len - pow2(j+1)))/2;
      end
      len = len + N1;
      j=j-1;
      %end
   end   
else
   scalewiseValues(1:len) = auData;
   j = m-1;
   while j >= 0
   	N1 = pow2(j);
      for k = 1:N1
      	scalewiseValues(1, len+k) = (scalewiseValues(2*k-1 + len - pow2(j+1)) + scalewiseValues(2*k + len - pow2(j+1)))/2;
      end
      len = len + N1;
      j=j-1;
   end
   %end   
end
%scalewiseValues
varianceScalewiseValues = [];
j = m;
len = 0;
while j >= 1
   N1 = pow2(j-1);
   x = 0;
   for k = 1:N1
      t1 = scalewiseValues(2*k-1 + len)-scalewiseValues(2*k + len);
		x = x +  t1^2/2;
	end
   varianceScalewiseValues = [varianceScalewiseValues 1/N1*x];
   len  = len + 2*N1;
   j = j-1;
end
%varianceScalewiseValues



