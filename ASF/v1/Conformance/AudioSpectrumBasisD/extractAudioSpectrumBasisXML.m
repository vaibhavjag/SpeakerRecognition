% To run this script from the Matlab-XM directory (the startup directory)
% type:
% addpath('../Conformance/AudioSpectrumBasisD');
% extractAudioSpectrumBasisXML

filename = '../Conformance/Signals/Music/mkcJazzTrio.wav';
[ASB,env] = AudioSpectrumBasisD(filename,20,...
        'hopSize','PT10N1000F','loEdge',62.5,'hiEdge',8000,'octaveResolution','1/4',...
        'outputFile','../Conformance/AudioSpectrumBasisD/mkcJazzTrio_ASBd.xml');
    