addpath('../');
startup
% === TODO: replace '..' by dirup (Mac compatibility)
addpath('../../Matlab-XM/h_Common')
addpath('../../Matlab-XM/h_XMLoutput')
addpath('../../Matlab-XM/AudioSpectrumFlatnessD')

% === Only works on Linux (a bit on Windows, not on Mac)

audiosignal = [SOUNDDIR 'Music' filesep 'a-a-c_song_mono.wav'];
xmlfile 		= getxmlfilename(audiosignal);
[AudioSpectrumFlatness_aac_mono lo_edge hi_edge XMLFile ] = AudioSpectrumFlatnessD(audiosignal,'PT30N1000F',250,16000,1,xmlfile);


audiosignal = [SOUNDDIR 'Music' filesep 'a-a-c_song_stereo.wav'];
xmlfile 		= getxmlfilename(audiosignal);
[AudioSpectrumFlatness_aac_stereo lo_edge hi_edge XMLFile ] = AudioSpectrumFlatnessD(audiosignal,'PT30N1000F',250,16000,1,xmlfile);
