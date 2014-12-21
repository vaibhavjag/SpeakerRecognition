% test file for RelativeDelayD
% only tested for Windows

addpath(['../../Matlab-XM/RelativeDelayD\']);

filename = fullfile('..','..','..','Signals','Music','DemoBad.wav');
[data, fs] = wavread (filename);
szXMLOut = 'RelativeDelay_Test.xml';
channels = [];
channels = [1 2];
RelativeDelayD(data,fs,channels,szXMLOut); %write XML File
%RelativeDelayD(data,fs,channels) %without XML Output
