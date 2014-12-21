addpath('../');
startup
% === TODO: replace '..' by dirup (Mac compatibility)
addpath('../../Matlab-XM/h_Common')
addpath('../../Matlab-XM/h_XMLoutput')
addpath('../../Matlab-XM/AudioSpectrumEnvelopeD')

% === Only works on Linux (a bit on Windows, not on Mac)

attributegrp=struct('loEdge',62.5,'hiEdge',16000,'octaveResolution','1/8');

audiosignal = [SOUNDDIR 'Music' filesep 'a-a-c_song_mono.wav'];
xmlfile 		= getxmlfilename(audiosignal);
[AudioSpectrumEnvelopemono, attributegrp, XMLFile, map] = AudioSpectrumEnvelopeD(audiosignal,'PT10N1000F',attributegrp,1,xmlfile);


audiosignal = [SOUNDDIR 'Music' filesep 'a-a-c_song_stereo.wav'];
xmlfile 		= getxmlfilename(audiosignal);
[AudioSpectrumEnvelopestereo, attributegrp, XMLFile, map] = AudioSpectrumEnvelopeD(audiosignal,'PT10N1000F',attributegrp,1,xmlfile);
