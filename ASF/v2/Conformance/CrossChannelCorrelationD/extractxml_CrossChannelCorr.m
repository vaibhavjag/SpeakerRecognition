% test file for Cross Channel CorrelationD
% only tested for Windows

addpath(['../../Matlab-XM/CrossChannelCorrelationD\']);

filename = fullfile('..','..','..','Signals','Music','DemoBad.wav');
[data, fs] = wavread (filename);
szXMLOut = 'Correlation_Test.xml';
channels = [];
channels = [1 2];
CrossChannelCorrelationD(data,fs,channels,szXMLOut); %write XML File
%CrossChannelCorrelationD(data,fs,channels) %without XML Output
