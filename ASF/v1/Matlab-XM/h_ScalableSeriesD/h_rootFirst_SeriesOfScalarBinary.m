function rootFirstValues = rootFirst_SeriesOfScalarBinary(auData,scalingRatio, elementNum)

%%  File: rootFirst_SeriesOfScalarBinary.m
%%
%%  The function of this subroutine is to rearrange the coefficients which represent
%%  the original series in in a "coarse-first, fine-last" fashion. 
%%
%%  Root first format is defined only for SeriesOfScalarBinaryType (uniform sampling 
%%  with power-of-two ratio).  
%%  Based on the previous binary mean tree, the coefficients of yk the root first 
%%  series are calculated as:
%%     y_1 = \bar{x}_1^m;
%%     y_2 = \bar(x}_1^{m-1} - \bar{x}_2^{m-1};
%%     y_3 = \bar{x}_1^{m-2} - \bar{x}_2^{m-2}; y_4 = \bar{x}_3^{m-2} - \bar{x}_4^{m-2}
%%     ...
%%  The binary mean tree (and therefore the original series) can be reconstructed from 
%%  this series:
%%     \bar{x}_1^m = y_1;
%%     \bar(x}_1^{m-1} = \bar{x}_1^m + y_2/2; \bar{x}_2^{m-1} = \bar{x}_1^m - y_2/2;
%%     ...
%%  The first coefficient y_1  is the grand mean. The second y_2  is the difference 
%%  between the means of the first and second half of the series, from which these 
%%  two means can be calculated, etc. rootFirst format may be useful to transmit a 
%%  description over a slow network, for example to display a progressively-refined 
%%  image of the descriptor. 
%%  Root First format is defined only for the 'mean' field. If 'rootFirst' is true, 
%%  only the 'mean' field is allowed.
%% 
%% Copyright (c), IME, All Rights Reserved
%%
%% Author: Dong Yan Huang
%% Version: 1.0  Time: 28 August 2000 (N3489)
%% Last modified: 27 Mar 2001 (N3704)


totalSampleNum = length(auData);

lenData = scalingRatio*elementNum;
meanValues = [];
if totalSampleNum < lenData
	N = floor(totalSampleNum/scalingRatio);
   for i = 1:N
     	sn_segment = auData(1+(i-1)*scalingRatio:i*scalingRatio);
     	meanValues = [meanValues mean(sn_segment)];
  	end
     	N1 = N*scalingRatio;
      sn_segment = auData(N1+1:totalSampleNum);
      meanValues = [meanValues, mean(sn_segment)];
else
   for i = 1:elementNum
      sn_segment = auData(1+(i-1)*scalingRatio:i*scalingRatio);
 		meanValues = [meanValues mean(sn_segment)];
   end
end
%meanValues
rootFirstValues = [];
x = zeros(1,2);
m = log2(elementNum);
i = 0;
a = pow2(i);
x(2) = mean(meanValues(1:elementNum));
rootFirstValues = [rootFirstValues x(2)-x(1)];
i = i+1;
while i <= m
   a = pow2(i);
   N1 = elementNum/a; 
	for j = 1:i
      if N1 == 1
         for k = 1:2
            t1 = k + (j-1)*2;
            x(k) = meanValues(t1);
         end
     else
         for k = 1:2
         	t1 = 1+(k-1)*N1+(j-1)*N1;
         	t2 = k*N1+(j-1)*N1;
            x(k) = mean(meanValues(t1:t2));
         end
      end
      rootFirstValues = [rootFirstValues x(2)-x(1)];
   end
   i=i+1;
end
