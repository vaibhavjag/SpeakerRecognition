addpath('../');
startup
% === TODO: replace '..' by dirup (Mac compatibility)
addpath('../../Matlab-XM/h_Common')
addpath('../../Matlab-XM/h_XMLoutput')
addpath('../../Matlab-XM/AudioSpectrumSpreadD')

% === Only works on Linux (a bit on Windows, not on Mac)

audiosignal = [SOUNDDIR 'Music' filesep 'a-a-c_song_mono.wav'];
xmlfile 		= getxmlfilename(audiosignal);
[AudioSpectrumSpreadmono,XMLFile] = AudioSpectrumSpreadD(audiosignal,'PT10N1000F',1,xmlfile);


audiosignal = [SOUNDDIR 'Music' filesep 'a-a-c_song_stereo.wav'];
xmlfile 		= getxmlfilename(audiosignal);
[AudioSpectrumSpreadstereo,XMLFile] = AudioSpectrumSpreadD(audiosignal,'PT10N1000F',1,xmlfile);
