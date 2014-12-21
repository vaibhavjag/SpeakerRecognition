% test file for BackgroundNoiseLevelD
% only tested for Windows

addpath(['../../Matlab-XM/BackgroundNoiseLevelD\']);

filename = fullfile('..','..','..','Signals','Music','DemoBad.wav');
[data, fs] = wavread (filename);
szXMLOut = 'BNL_Test.xml';
channels = [];
channels = [1 2];
BackgroundNoiseLevelD(data,fs,channels,szXMLOut); %write XML File
%BackgroundNoiseLevelD(data,fs,channels) %without XML Output
