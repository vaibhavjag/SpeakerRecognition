% To run this script from the Matlab-XM directory (the startup directory)
% type:
%
% >>addpath('../Conformance/SoundModelDS');
% >>addpath('../Conformance/SoundModelStateHistogramD');
% >>extractSoundModelXML
% >>extractSoundModelStateHistogramXML
filename = '../Conformance/Signals/Music/mkcJazzTrio.wav';
[SMSH] = SoundModelStateHistogramD(filename,SM,'sequenceHopSize',10,'sequenceFrameLength',200,'outputFile','../Conformance/SoundModelStateHistogramD/mkcJazzTrio_SMSHd.xml');

