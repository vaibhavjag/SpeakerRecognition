addpath('../');
startup
% === TODO: replace '..' by dirup (Mac compatibility)
addpath('../../Matlab-XM/h_Common')
addpath('../../Matlab-XM/h_Percussive')
addpath('../../Matlab-XM/h_XMLoutput')

addpath(['../../Matlab-XM/PercussiveInstrumentTimbreDS\']);

addpath(['../../Matlab-XM/LogAttackTimeD']);
addpath(['../../Matlab-XM/SpectralCentroidD\']);
addpath(['../../Matlab-XM/TemporalCentroidD\']);


% === Only works on Linux (a bit on Windows, not on Mac)
audiosignal = [SOUNDDIR 'PercussiveSounds\SampleNet\SNARE' filesep 'MSD04.wav'];
xmlfile 		= getxmlfilename(audiosignal);
PercussiveInstrumentTimbreDS(audiosignal, 1, xmlfile);







