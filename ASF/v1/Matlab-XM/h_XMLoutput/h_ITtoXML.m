function fileName=...
   HITtoXML(LogAttackTime, SpectralCentroid, TemporalCentroid, HarmonicSpectralCentroid, HarmonicSpectralDeviation, HarmonicSpectralSpread, HarmonicSpectralVariation, fileName)

% This function generates the XML file containing the description of the TemporalCentroid
% It returns the name of the genrated XML file
% TCValue contains the value of the Temporal Centroid

% Written by Thibaut Sacreste
% Based on ISO/IEC CD 15938-4
%
% Version 1.0 
% created 18/03/2002

defaultFileName='InstrumentTimbre.xml';
Mpeg7_wrapper='Mpeg7_wrapper.xml';

if ~exist('fileName')
   fileName=defaultFileName;
elseif isempty(fileName)
   fileName=defaultFileName;
end       

%--------------------------
%creation of the xml file:
try
   xmlFile=fopen(fileName,'w');  %opens the file in write mode
catch
   error(lasterr);
end    

%-------------------------
%XML generation:

%Mpeg7 wrapper:
try
   mpeg7File=fopen(Mpeg7_wrapper,'r');  %opens the file containing the Mpeg7 wrapper
catch
   error(lasterr);
end    

%copies the wrapper in the new XML file:
while ~feof(mpeg7File)
   line=fgets(mpeg7File);
   fprintf(xmlFile,'%s',line);
end    
fclose(mpeg7File);

tmp(1).tag 	= 'LogAttackTime';
tmp(1).value= num2str(LogAttackTime);
tmp(1).type = 'scalar';

tmp(2).tag 	= 'SpectralCentroid';
tmp(2).value= num2str(SpectralCentroid);
tmp(2).type = 'scalar';

tmp(3).tag 	= 'TemporalCentroid';
tmp(3).value= num2str(TemporalCentroid);
tmp(3).type = 'scalar';

tmp(4).tag 	= 'HarmonicSpectralCentroid';
tmp(4).value= num2str(HarmonicSpectralCentroid);
tmp(4).type = 'scalar';

tmp(5).tag 	= 'HarmonicSpectralDeviation';
tmp(5).value= num2str(HarmonicSpectralDeviation);
tmp(5).type = 'scalar';

tmp(6).tag 	= 'HarmonicSpectralSpread';
tmp(6).value= num2str(HarmonicSpectralSpread);
tmp(6).type = 'scalar';

tmp(7).tag 	= 'HarmonicSpectralVariation';
tmp(7).value= num2str(HarmonicSpectralVariation);
tmp(7).type = 'scalar';


%Descriptor generation:
%line='<AudioDescriptionScheme xsi:type="mpeg7:InstrumentTimbreType">';
line='<DescriptionUnit xsi:type="mpeg7:InstrumentTimbreType">';
fprintf(xmlFile,'\t%s\n',line);

for l=1:length(tmp)
   fprintf(xmlFile,'\t\t<%s>\n', 	tmp(l).tag);
   fprintf(xmlFile,'\t\t<%s>', 		tmp(l).type);
   fprintf(xmlFile,'%s', 				tmp(l).value);
   fprintf(xmlFile,'</%s>\n', 		tmp(l).type);
   fprintf(xmlFile,'\t\t</%s>\n', 	tmp(l).tag);
end

%line='</AudioDescriptionScheme>';
line='</DescriptionUnit>';
fprintf(xmlFile,'\t%s\n',line);

line='</Mpeg7>';
fprintf(xmlFile,'%s\n',line);

fclose(xmlFile);

