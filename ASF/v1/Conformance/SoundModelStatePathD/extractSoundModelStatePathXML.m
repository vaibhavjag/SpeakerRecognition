% To run this script from the Matlab-XM directory (the startup directory)
% type:
%
% >>addpath('../Conformance/SoundModelDS');
% >>addpath('../Conformance/SoundModelStatePathD');
% >>extractSoundModelXML
% >>extractSoundModelStatePathXML
filename = '../Conformance/Signals/Music/mkcJazzTrio.wav';
[SMSP,logLike]=SoundModelStatePathD(filename,SM,'loEdge',62.5,'hiEdge',8000,...
    'octaveResolution','1/4','hopSize','PT10N1000F',...
    'outputFile','../Conformance/SoundModelStatePathD/mkcJazzTrio_SMSPd.xml');
