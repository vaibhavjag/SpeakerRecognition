% test file for BandwidthD
% only tested for Windows

addpath(['../../Matlab-XM/BandwidthD\']);

filename = fullfile('..','..','..','Signals','Music','DemoBad.wav');
[data, fs] = wavread (filename);
szXMLOut = 'Bandwidth_Test.xml';
channels = [];
channels = [1 2];
BandwidthD(data,fs,channels,szXMLOut); %write XML File
%BandwidthD(data,fs,channels) %without XML Output
