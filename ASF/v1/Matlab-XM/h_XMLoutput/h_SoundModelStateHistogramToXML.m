function fileName=h_SoundModelStateHistogramToXML(H,outputFile,modelName,hopSize)
% h_SoundModelStatePathToXML(SoundModelStateHistogramD,outputFile,soundModelID); 
%    - generates an XML file for SoundModelStateHistogramD
%
% SoundModelStateHistogramD values is a t x k matrix, t=number of time points, k = number of states
% outputFile - filename for XML output
% soundModelName - reference to model that generated this SoundModelStatePathD instance 

% Author: Michael A. Casey
% Language: Matlab
% Based on ISO/IEC FDIS 15938-4
%
% Version 2.0 
% created 12/08/2003

Mpeg7_wrapper='Mpeg7_wrapper.xml';

if ~isempty(outputFile)
        fileName=outputFile;
end       

%--------------------------
%determines the number of sample vectors 
%and the number of frequency bands
[totalNumOfSamples, vectorSize ]=size(H);

%--------------------------
%creation of the xml file:
try
    xmlFile=fopen(outputFile,'w');  %opens the file in write mode
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
line='<Description xsi:type="ContentEntityType">';
fprintf(xmlFile,'\t%s\n',line);
line='<MultimediaContent xsi:type="AudioType">';
fprintf(xmlFile,'\t\t%s\n',line);
line='<Audio xsi:type="AudioSegmentType">';
fprintf(xmlFile,'\t\t\t%s\n',line);
line='<MediaTime>';
fprintf(xmlFile,'\t\t\t\t%s\n',line);
line='<MediaTimePoint>T00:00:00</MediaTimePoint>';
fprintf(xmlFile,'\t\t\t\t\t%s\n',line);
line='<MediaDuration>PT31S675N1000F</MediaDuration>';
fprintf(xmlFile,'\t\t\t\t\t%s\n',line);
line='</MediaTime>';
fprintf(xmlFile,'\t\t\t\t%s\n',line);


fprintf(xmlFile,'\t\t<AudioDescriptor xsi:type="SoundModelStateHistogramType">\n');
% fprintf(xmlFile,'\t\t\t<SoundModelRef>\n\t\t\t%s\n\t\t\t</SoundModelRef>\n', modelName);
fprintf(xmlFile,'\t\t\t<SeriesOfVector totalNumOfSamples="%d" hopSize="%s"><Raw mpeg7:dim="%d %d">\n', totalNumOfSamples, hopSize, totalNumOfSamples,vectorSize);
for k=1:totalNumOfSamples
    fprintf(xmlFile,'\t\t\t\t');
    fprintf(xmlFile,'%d ', H(k,:));
    fprintf(xmlFile,'\n');
end
fprintf(xmlFile,'\t\t\t</Raw></SeriesOfVector>\n');
fprintf(xmlFile,'\t\t</AudioDescriptor>\n');
line='</Audio>';
fprintf(xmlFile,'\t%s\n',line);

line='</MultimediaContent>';
fprintf(xmlFile,'\t%s\n',line);

line='</Description>';
fprintf(xmlFile,'\t%s\n',line);

fprintf(xmlFile,'</Mpeg7>\n');
fclose(xmlFile);
