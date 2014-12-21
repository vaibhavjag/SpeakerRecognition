function covarianceValues = Covariance_SeriesOfVector(auData, totalSampleNum, scalingRatio, elementNum, weight_flag, weight, write_flag)

%%% File: Covariance_SeriesOfVector.m
%%
%% --------------  ---------------
%%
%% The function of this subroutine is Series of covariance matrices of groups of vector samples. 
%% This is a three-dimensional matrix. Number of rows must equal elementNum, number of columns 
%% and number of pages must both equal 'dim' in FloatMatrixType, or 0 if Raw is present.  
%% If Covariance is present, Mean must also be present. 
%%
%%
%% 
%% Definition:
%%
%% N = P*Q (?)
%% P -> scaleRatio, Q -> rescaleFactor 
%% CovarianceValue = 1/N(\sum_{i=1+(k-1)*N}^{kN} (x_i - \bar{x}_1)^2 (x_j - \bar{x}_j)^2
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
%covSize = min(rows, vectorSize);
covarianceValues = zeros(sumElement, rows, vectorSize);


%if weight_flag == 0
   if len == 1 & scalingRatio(len) == 1& write_flag == 1
      x = strcat('<Covariance/>');
      fprintf(fid, '%s\n ',x);
   else
      k = 1;
      len = length(scalingRatio);
      while k <= len
         for i = 1:elementNum(k)
            rowNum = floor(i*scalingRatio(k)/vectorSize);
            m = 1;
            n = 1;
            for j=1:rowNum-1
            	s = auData(j, 1:vectorSize);
               for l=j+1:rowNum
                  s1 = auData(l, 1:vectorSize);
                  x = cov(s,s1)
                  %m
                  %n
                  covarianceValues(i,m,n) = x(1,2);
                  n = n+1;
						if n > 10
                  	m = m+1;
                  	n = n-10;              
                  end  
               end
            end
            for j = 1:vectorSize-1
               s = auData(1:rowNum, j);
               for l = j+1:vectorSize
                  s1 = auData(1:rowNum,l);
                  x = cov(s,s1);
                  %m
                  %n
                  covarianceValues(i,m,n) = x(1,2);
                  n = n+1;
					   if n > 10
                   m = m+1;
                   n = n-10;
                  end   
                end
             end
         if write_flag == 1
          		x = strcat('<Scaling ratio="',num2str(scalingRatio(k)),'" elementNum="',num2str(elementNum(k)),'"/>');
             	fprintf(fid, '%s\n ',x);
         end
			k=k+1;
      end
      %[elementNum, rows, columns] = size(covarianceValues)
      %covarianceValues
      x = strcat('	<Covariance dim = "', num2str(m), '	', num2str(columns),'">');
      fprintf(fid, '%s ',x);
      for i = 1:elementNum
      	for j = 1:m-1
      		x = strcat(num2str(covarianceValues(i, j, 1:vectorSize)));
         	fprintf(fid, '	%s \n',x);
         end
      end
      x = strcat(num2str(covarianceValues(elementNum, m, 1:vectorSize)));
      x = strcat(x, '</Covariance>');
      fprintf(fid, '	%s \n',x);
   end
   % Don't understand the definition of covariance, so for the weight part, I will implement when
   % I understand the covariance for a matrix
%else
%  	if len == 1 & scalingRatio(len) == 1& write_flag == 1
%      x = strcat('<Variance/>');
%      fprintf(fid, '%s\n ',x);
%   else
%      if sum(weight) == 0
%         covarianceValues = zeros(sumElement, vectorSize);
%	  	else
%         k = 1;
%         len = length(scalingRatio);
%      end
%      [rows, columns] = size(varianceValues);
%      x = strcat('	<Variance dim = "', num2str(rows), '	', num2str(columns),'">');
%      fprintf(fid, '%s ',x);
%      for i = 1:rows-1
%      	x = strcat(num2str(varianceValues(i, 1:vectorSize)));
%         fprintf(fid, '	%s \n',x);
%      end
%      x = strcat(num2str(varianceValues(rows, 1:vectorSize)));
%      x = strcat(x, '</Variance>');
%      fprintf(fid, '	%s \n',x);
%	end
end
