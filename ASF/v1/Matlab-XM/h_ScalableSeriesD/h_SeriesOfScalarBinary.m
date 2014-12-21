function [varianceScalewiseValues, rootFirstValues] = SeriesOfScalarBinary(auData, scalingRatio,elementNum)

%%% File: SeriesOfScalarBinary.m
%%
%% --------------  ---------------
%%
%% The function of this subroutine is to write series of scalar
%% with a uniform power-of-two ScaleRatio in a XML file.
%% The restriction to a power-of-two ratio eases the comparison 
%% of series with different ScaleRatios. It also allows an additional 
%% scaling operation to be defined (scalewise variance), and allows 
%% the data to be coded in "rootFirst" format
%%
%% <!-- ##################################################################### -->
%% <!-- Definition of abstract SeriesOfScalarBinaryType                       -->
%% <!-- ##################################################################### -->
%% <complexType name="SeriesOfScalarBinaryType" base="mpeg7:SeriesOfScalarType"
%%               derivedBy="extension">
%%    <element name="VarianceScalewise" type="mpeg7:FloatMatrixType"
%%             minOccurs="0"/>
%%    <attribute name="rootFirst" type="boolean" use="default" value="false"/>
%% </complexType>
%%
%% Function:
%% SeriesOfScalarBinary: A representation of a series of scalar values scaled by 
%%                       a power of two factor.
%% Outputs:
%% VarianceScalewise:    Optional array of arrays of scalewise variance coefficients. 
%%								 Scalewise variance is a decomposition of the variance into 
%%                       a series of coefficients, each of which describes the variability 
%%                       at a particular scale. There are log2(ratio) such coefficients. 
%%                       Number of rows must equal 'NumElements', number of columns must 
%%                       equal the number of coefficients of the scalewise variance.
%% rootFirst:            Optional flag. If true, the series are recorded in "root-first" format. 
%%								 This format is defined below. In brief: the recorded series starts 
%%                       with the grand mean of the original series, and the subsequent values 
%%                       provide a progressively refined description from which the entire series 
%%                       can be reconstructed.
%% Inputs:
%% auData:               Incoming signal
%% scaligRatio:          Scale factor
%% elementNum:           Elements Number
%%
%% (N3704)
%%
%%
%% Copyright (c), IME, All Rights Reserved
%%
%% Author: Dong Yan Huang
%% Version: 1.0  Time: 28 October 2000 (N3489)
%% Last Modified: 27 Mar 2001 (N3704)

%if nargin < 5, error('constr requires five input arguments'); end
%if nargin < 6, weight_flag = 0; weight= []; end
%global fid;

fid = fopen('SeriesOfScalarBinary.xml','w');
x='<!-- ##################################################################### -->';
fprintf(fid, '%s\n',x);
x='<!-- Definition of abstract SeriesOfScalarBinaryType                       -->';
fprintf(fid, '%s\n',x);
x='<!-- ##################################################################### -->';
fprintf(fid, '%s\n',x);
x='<complexType name="SeriesOfScalarBinaryType" base="mpeg7:SeriesOfScalarType"';
fprintf(fid, '%s\n',x);
x='               derivedBy="extension">';
fprintf(fid, '%s\n',x);
x='    <element name="VarianceScalewise" type="mpeg7:FloatMatrixType"';
fprintf(fid, '%s\n',x);
x='             minOccurs="0"/>';
fprintf(fid, '%s\n',x);
x='    <attribute name="rootFirst" type="boolean" use="default" value="false"/>';
fprintf(fid, '%s\n',x);
x=' </complexType>';
fprintf(fid, '%s\n',x);

rootFirst = 0;
totalSampleNum = length(auData);
x = '<AudioSegment idref="102">';
fprintf(fid, '%s\n',x);
x = ' <!-- MediaTime, etc. -->';
fprintf(fid, '%s\n',x);
% <AudioPower>
x = '	<HopSize timeunit="PT1N44000F">1</HopSize>';
fprintf(fid,'%s\n',x);

if rootFirst == 1
   x = strcat(' 	<Value rootFirst="true" totalSampleNum="', num2str(totalSampleNum), '">');
   fprintf(fid,'%s\n',x);
   x= strcat('			<Scaling ratio="', num2str(scalingRatio), '" elementNum="', num2str(elementNum),'"/>');
   fprintf(fid,'%s\n',x);
   rootFirstValues = h_rootFirst_SeriesOfScalarBinary(auData,scalingRatio, elementNum);
   varianceScalewiseValues = [];
	x = strcat('			<Mean>', num2str(rootFirstValues),'</Mean>');
   fprintf(fid,'%s\n',x);    
   x ='	</Value>';
   fprintf(fid,'%s\n',x);
   %fprintf(fid, '%s \n',x);
   x = strcat('</AudioSegment>');
   fprintf(fid, '%s \n',x);
else
   x = strcat('	<Value totalSampleNum="',num2str(totalSampleNum), '">');
   fprintf(fid,'%s\n',x);
   x = strcat('		<Scaling ratio="',num2str(scalingRatio),'" elementNum="',num2str(elementNum),'"/>');
   fprintf(fid,'%s\n',x);
   rootFirstValues = h_rootFirst_SeriesOfScalarBinary(auData,scalingRatio, elementNum);
   varianceScalewiseValues= h_SWVariance_SeriesOfScalarBinary(auData,scalingRatio, elementNum);
   x = strcat('			<Mean>',  num2str(rootFirstValues(1)), ' </Mean>');
   fprintf(fid, '%s \n',x);
   x = strcat(' 			<VarianceScalewise dim="', num2str(size(varianceScalewiseValues)), ' ">', num2str(varianceScalewiseValues));
   fprintf(fid, '%s \n',x);
   x ='                  </VarianceScalewise>';
   fprintf(fid, '%s \n',x);
	x = '</Value>';
   fprintf(fid, '%s \n',x);
	x = strcat('</AudioSegment>');
	fprintf(fid, '%s \n',x);
end
fclose(fid);


