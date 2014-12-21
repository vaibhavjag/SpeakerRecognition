function fileName=ASEtoXML(ASEValues,loEdge,hiEdge,octaveResolution,hopSize,fileName)

% This function generates the XML file containing the description of the AudioSpectrumEnvelope
% It returns the name of the genrated XML file
% ASEValues is a MxN matrix with
% M=number of audio frames
% N=number of frequency bands

% Written by Thibaut Sacreste
% Based on ISO/IEC WD 15938-4
%
% Version 1.0 
% created 15/03/2002

defaultFileName='AudioSpectrumEnvelope.xml';
Mpeg7_wrapper='Mpeg7_wrapper.xml';

if ~exist('fileName')
    fileName=defaultFileName;
elseif isempty(fileName)
        fileName=defaultFileName;
end       

%--------------------------
%determines the number of samples 
%and the number of frequency bands
[totalNumOfSamples numBands]=size(ASEValues);


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
line='<DescriptionUnit xsi:type="mpeg7:AudioSpectrumEnvelopeType"';
fprintf(xmlFile,'\t%s\n',line);

line=['loEdge="' num2str(loEdge) '"'];
fprintf(xmlFile,'\t\t%s\n',line);

line=['hiEdge="' num2str(hiEdge) '"'];
fprintf(xmlFile,'\t\t%s\n',line);

line=['octaveResolution="' octaveResolution '">'];
fprintf(xmlFile,'\t\t%s\n',line);

line=['<SeriesOfVector totalNumOfSamples="' num2str(totalNumOfSamples) '"'];
fprintf(xmlFile,'\t\t%s\n',line);

line=['vectorSize="' num2str(numBands) '"'];
fprintf(xmlFile,'\t\t\t%s\n',line);

line=['hopSize="' hopSize '">'];
fprintf(xmlFile,'\t\t\t%s\n',line);
					  
line='<Scaling ratio="1"';
fprintf(xmlFile,'\t\t\t%s\n',line);

line=['numOfElements="' num2str(totalNumOfSamples) '"/>'];
fprintf(xmlFile,'\t\t\t\t%s\n',line);

line=['<Raw mpeg7:dim="' num2str(totalNumOfSamples) ' ' num2str(numBands) '">'];
fprintf(xmlFile,'\t\t\t%s\n',line);	

%AudioSpectrumEnvelope values:
for i=0:totalNumOfSamples-1
    fprintf(xmlFile,'\t\t\t\t');
    for j=1:numBands
      value=num2str(ASEValues(i*numBands+j)); 
      fprintf(xmlFile,'%s ',value);
    end  
    fprintf(xmlFile,'\n');
end    
			 		
line='</Raw>';
fprintf(xmlFile,'\t\t\t%s\n',line);

line='</SeriesOfVector>';
fprintf(xmlFile,'\t\t%s\n',line);

line='</DescriptionUnit>';
fprintf(xmlFile,'\t%s\n',line);

%Mpeg7 end tag:
line='</Mpeg7>';
fprintf(xmlFile,'%s\n',line);

fclose(xmlFile);

