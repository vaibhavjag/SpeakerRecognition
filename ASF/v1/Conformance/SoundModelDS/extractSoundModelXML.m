% To run this script from the Matlab-XM directory (the startup directory)
% type:
%
% >>addpath('../Conformance/SoundModelDS');
% >>extractSoundModelXML

% SoundModelDS uses a text file that contains a list of files to use as
% training data. In this case it is a single file.
SM=SoundModelDS('../Conformance/SoundModelDS/SoundModelFileList.txt',10,10,...
    'hiEdge',8000,'loEdge',62.5,'octaveResolution','1/4',...
    'outputFile','../Conformance/SoundModeldS/mkcJazzTrio_SMds.xml');
