% test file for BalanceD
% only tested for Windows

addpath(['../../Matlab-XM/BalanceD\']);

filename = fullfile('..','..','..','Signals','Music','DemoBad.wav');
[data, fs] = wavread (filename);
szXMLOut = 'Balance_Test.xml';
channels = [];
channels = [1 2];
BalanceD(data,channels,szXMLOut); %write XML File
%BalanceD(data,channels) %without XML Output
