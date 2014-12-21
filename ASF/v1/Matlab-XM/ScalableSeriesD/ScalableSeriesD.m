function scaledData = ScalableSeries(auData, totalSampleNum, scaledRatio, rescaledFactor, elementNum, weight_flag,weight)

%%% File: ScalableSeries.m
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

if nargin < 5, error('constr requires five input arguments'); end
if nargin < 6, weight_flag = 0; weight= []; end

%% Initialization
%totalSampleNum = length(auData);
scalingRatio = scaledRatio*rescaledFactor;
scaledSeriesSize = scalingRatio*elementNum; 
N=scalingRatio;
scaledData = zeros(1,scaledSeriesSize);

if weight_flag == 0
   if scaledRatio == 1
      scaledData = auData(1:scaledSeriesSize);
   else
      j = 1;
      for i = 1:N:scaledSeriesSize
         scaledData(j) = auData(i);
         j=j+1;
      end
   end
else
   if scaledRatio == 1
      sn = weight.*auData;
      scaledData = sn(1:scaledSeriesSize);
	else
      sn = weight.*auData;
      j = 1;
      for i = 1:N:scaledSeriesSize
        scaledData(j) = sn(i);
        j=j+1;
      end
   end;
end;

fid = fopen('scalingseries.xml','w');
x='<!-- ##################################################################### -->';
fprintf(fid, '%s\n',x);
x= '<!-- Definition of abstract ScalableSeriesType                             -->';
fprintf(fid, '%s\n',x);
x= '<!-- ##################################################################### -->';
fprintf(fid, '%s\n',x);
x='<complexType name="ScalableSeriesType" abstract="true">';
fprintf(fid, '%s\n',x);
x='<element name="Scaling" minOccurs="0" maxOccurs="unbounded">';
fprintf(fid, '%s\n',x);
x='<complexType>';
fprintf(fid, '%s\n',x);
x='<attribute name="ratio" type="positiveInteger" use="required"/>';
fprintf(fid, '%s\n',x);
x='<attribute name="elementNum" type="positiveInteger" use="required"/>';
fprintf(fid, '%s\n',x);
x='</complexType>';
fprintf(fid, '%s\n',x);
x='</element>';
fprintf(fid, '%s\n',x);
x='<attribute name="totalSampleNum" type="positiveInteger" use="required"/>';
fprintf(fid, '%s\n',x);
x='</complexType>';
fprintf(fid, '%s\n',x);

x = strcat('<Value totalSampleNum ="', num2str(totalSampleNum),'">'); 
fprintf(fid, '%s\n',x);
if scaledRatio == 1
   x = strcat('<Raw>');
   fprintf(fid, '%s ',x);
   N = floor(totalSampleNum/20);
   for i = 1:N
      x = strcat(num2str(auData(1+(i-1)*20:i*20)));
      if i*20 == totalSampleNum
         x = strcat(x, '</Raw>');
         fprintf(fid, '%s \n',x);
      else
         fprintf(fid, '%s \n',x);
      end
   end
   N1 = totalSampleNum - N*20;
   if N1 ~= 0
      x = strcat(num2str(auData(N1:totalSampleNum)), '</Raw>');
      fprintf(fid, '%s \n',x);
   end
end 
x = strcat('</Value>');
fprintf(fid, '%s \n',x);

fclose(fid);

