function SeriesOfVectorEnd()

%%% File: SeriesOfVectorEnd.m
%%
%% --------------  ---------------
%%
%% The function of this subroutine is to close XML file 
%% for SeriesOfVector
%% 
%% 
%% (N3704)
%%
%%
%% Copyright (c), IME, All Rights Reserved
%%
%% Author: Dong Yan Huang
%% Version: 1.0  Time: 28 October 2000 (N3489)
%% Last Modified: 27 Mar 2001 (N3704)
global fid;

x = strcat('</Value>');
fprintf(fid, '%s \n',x);
x = strcat('</AudioSegment>');
fprintf(fid, '%s \n',x);

fclose(fid);

