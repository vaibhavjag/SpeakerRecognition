% test file for BackgroundNoiseLevelD
% only tested for Windows

addpath(['../../Matlab-XM/AudioBpmD\']);

filename = fullfile('..','..','..','Signals','Music','lara.wav');
[audioBpm,audioCorr,audioRel]=AudioBpmD('C:\audio\Meine Musik\tripo\lara.wav', 70, 140,'.');%write XML File lara.xml in current directory