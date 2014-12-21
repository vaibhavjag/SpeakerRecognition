function fileName=SMSPtoXML(Path,hopSize,fileName)

% This function generates the XML file containing the description of the
% SoundModelStatePath
% It returns the name of the genrated XML file
% Values is a N vector with
% N=number of state path samples
defaultFileName='SoundModelStatePath.xml';
Mpeg7_wrapper='Mpeg7_wrapper.xml';

if ~exist('fileName')
    fileName=defaultFileName;
elseif isempty(fileName)
    fileName=defaultFileName;
end       

%--------------------------
%determines the number of samples 
[totalNumOfSamples]=length(Path);


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

%Descriptor generation:
line='<DescriptionUnit xsi:type="mpeg7:SoundModelStatePathType">';
fprintf(xmlFile,'\t%s\n',line);

line=['<SeriesOfScalar totalNumOfSamples="' num2str(totalNumOfSamples) '"'];
fprintf(xmlFile,'\t\t%s\n',line);

line=['hopSize="' hopSize '">'];
fprintf(xmlFile,'\t\t\t%s\n',line);

line='<Scaling ratio="1"';
fprintf(xmlFile,'\t\t\t%s\n',line);

line=['numOfElements="' num2str(totalNumOfSamples) '"/>'];
fprintf(xmlFile,'\t\t\t\t%s\n',line);

line=['<Raw mpeg7:dim="' num2str(totalNumOfSamples) '">'];
fprintf(xmlFile,'\t\t\t%s\n',line);	

%AudioSpectrumEnvelope values:
fprintf(xmlFile,'\t\t\t\t');
for j=1:length(Path)
    value=num2str(Path(j)); 
    fprintf(xmlFile,'%s ',value);
end  
fprintf(xmlFile,'\n');

line='</Raw>';
fprintf(xmlFile,'\t\t\t%s\n',line);

line='</SeriesOfScalar>';
fprintf(xmlFile,'\t\t%s\n',line);

line='</DescriptionUnit>';
fprintf(xmlFile,'\t%s\n',line);

%Mpeg7 end tag:
line='</Mpeg7>';
fprintf(xmlFile,'%s\n',line);

fclose(xmlFile);

