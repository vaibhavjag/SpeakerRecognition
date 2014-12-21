addpath('../');
startup
% === TODO: replace '..' by dirup (Mac compatibility)
addpath('../../Matlab-XM/h_Common')
addpath('../../Matlab-XM/h_Harmonic')
addpath('../../Matlab-XM/h_XMLoutput')
addpath(['../../Matlab-XM/AudioFundamentalFrequencyD\'])

addpath(['../../Matlab-XM/InstrumentTimbreDS\']);

addpath(['../../Matlab-XM/LogAttackTimeD']);
addpath(['../../Matlab-XM/SpectralCentroidD\']);
addpath(['../../Matlab-XM/TemporalCentroidD\']);

addpath(['../../Matlab-XM/HarmonicSpectralCentroidD\']);
addpath(['../../Matlab-XM/HarmonicSpectralDeviationD\']);
addpath(['../../Matlab-XM/HarmonicSpectralSpreadD\']);
addpath(['../../Matlab-XM/HarmonicSpectralVariationD\']);



% === Only works on Linux (a bit on Windows, not on Mac)
audiosignal = [SOUNDDIR 'HarmonicSounds\IrcamStudioOnLine\12Violon\pizzicato' filesep 'violin_pizzicatolv_C_natural_4_mf.wav'];
xmlfile 		= getxmlfilename(audiosignal);
InstrumentTimbreDS(audiosignal, 1, xmlfile);




