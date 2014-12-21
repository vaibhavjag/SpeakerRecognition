addpath('../');
startup
% === TODO: replace '..' by dirup (Mac compatibility)
addpath('../../Matlab-XM/h_Common')
addpath('../../Matlab-XM/h_Harmonic')
addpath('../../Matlab-XM/h_XMLoutput')
addpath(['../../Matlab-XM/AudioFundamentalFrequencyD\'])

addpath(['../../Matlab-XM/HarmonicInstrumentTimbreDS\']);

addpath(['../../Matlab-XM/LogAttackTimeD']);
addpath(['../../Matlab-XM/HarmonicSpectralCentroidD\']);
addpath(['../../Matlab-XM/HarmonicSpectralDeviationD\']);
addpath(['../../Matlab-XM/HarmonicSpectralSpreadD\']);
addpath(['../../Matlab-XM/HarmonicSpectralVariationD\']);



% === Only works on Linux (a bit on Windows, not on Mac)
audiosignal = [SOUNDDIR 'HarmonicSounds\IrcamStudioOnLine\03Clarinette(sib)\normal' filesep 'clsb_gref_mf_do3_12.wav'];
xmlfile 		= getxmlfilename(audiosignal);
HarmonicInstrumentTimbreDS(audiosignal, 1, xmlfile);





