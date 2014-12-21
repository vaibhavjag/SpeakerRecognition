% test file for DCOffsetD
% only tested for Windows

addpath(['../../Matlab-XM/DCOffsetD\']);

filename = fullfile('..','..','..','Signals','Music','DemoBad.wav');
[data, fs] = wavread (filename);
szXMLOut = 'DCOffset_Test.xml';
channels = [];
channels = [1 2];
DCOffsetD(data,channels,szXMLOut); %write XML File
%DCOffsetD(data,channels) %without XML Output
