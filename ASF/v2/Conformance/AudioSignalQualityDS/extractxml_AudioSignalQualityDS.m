% test file for AudioSignalQualityDS
% only tested for Windows

clear all;
close all;
addpath(['../../Matlab-XM/AudioSignalQualityDS\']);
addpath(['../../Matlab-XM/h_AudioSignalQuality\']);
addpath(['../../Matlab-XM/BackgroundNoiseLevelD\']);
addpath(['../../Matlab-XM/BalanceD\']);
addpath(['../../Matlab-XM/RelativeDelayD\']);
addpath(['../../Matlab-XM/DCOffsetD\']);
addpath(['../../Matlab-XM/CrossChannelCorrelationD\']);
addpath(['../../Matlab-XM/BandwidthD\']);


filename = fullfile('..','..','..','Signals','Music','DemoBad.wav');
[data, fs] = wavread (filename);
givenName = 'Joerg Bitzer';
szXMLOut = 'AudioSignalQualityDS_Test.xml';
channels = [];
channels = [1 2];
AudioSignalQualityDS(data,fs,channels,givenName,szXMLOut); %write XML File
%AudioSignalQualityDS(data,fs,givenName,channels) %without XML Output