function [xmlfile] = getxmlfilename(audiosignal)

audiosignal					= strrep(audiosignal, '/', filesep);
[path, fileroot, ext] 	= fileparts(audiosignal);
xmlfile 						= ['./' fileroot '.xml'];
