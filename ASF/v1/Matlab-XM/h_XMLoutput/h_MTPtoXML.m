function fileName=h_MTPtoXML(inFileName,fileName)

% This function generates the XML file containing the description for Media
% Time Point Annotations
% It returns the name of the genrated XML file
% MTPText

defaultFileName='MTP.xml';
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

%Descriptor generation:
line='<Description xsi:type="ContentEntityType">';
fprintf(xmlFile,'\t%s\n',line);

line='<MultimediaContent xsi:type="VideoType">';
fprintf(xmlFile,'\t%s\n',line);

line='<Video>';
fprintf(xmlFile,'\t%s\n',line);

line='<TemporalDecomposition>';
fprintf(xmlFile,'\t%s\n',line);

% MEAT GOES HERE
%Mpeg7 wrapper:
try
    inFile=fopen(inFileName,'r');  %opens the annotation file
catch
    error(lasterr);
end    

while ~feof(inFile)
    annot=fgets(inFile);
    indx=find(annot==' ');
    line='<VideoSegment>';
    fprintf(xmlFile,'\t%s\n',line);
    
    line='<TextAnnotation type="scene" relevance="1" confidence="1">';
    fprintf(xmlFile,'\t%s\n',line);
    
    line=['<FreeTextAnnotation>' annot(indx(1)+1:end) '</FreeTextAnnotation>'];
    fprintf(xmlFile,'\t%s\n',line);

    line='</TextAnnotation>';
    fprintf(xmlFile,'\t%s\n',line);

    line='<MediaTime>';
    fprintf(xmlFile,'\t%s\n',line);
    mtp=str2num(annot(1:indx(1)-1));
    line='<MediaTimePoint>';
    fprintf(xmlFile,'\t%s',line);
    fprintf(xmlFile,'T');
    a=fix(str2num(annot(1:indx(1)-1))/3600);
    fprintf(xmlFile,'%02d:',a);
    a=fix(str2num(annot(1:indx(1)-1))/60);
    fprintf(xmlFile,'%02d:',a);
    a=fix(mod(str2num(annot(1:indx(1)-1)),60));
    fprintf(xmlFile,'%02d:',a);
    a=fix(mod(str2num(annot(1:indx(1)-1)),60))-a;
    fprintf(xmlFile,'%dF24',a*24);
    line='</MediaTimePoint>';
    fprintf(xmlFile,'%s\n',line); 
    
    line='</MediaTime>';
    fprintf(xmlFile,'\t%s\n',line);
    
    line='</VideoSegment>';
    fprintf(xmlFile,'%s\n',line);
end    
fclose(inFile);

line='</TemporalDecomposition>';
fprintf(xmlFile,'\t%s\n',line);

line='</Video>';
fprintf(xmlFile,'\t%s\n',line);

line='</MultimediaContent>';
fprintf(xmlFile,'\t%s\n',line);

line='</Description>';
fprintf(xmlFile,'\t%s\n',line);

%Mpeg7 end tag:
line='</Mpeg7>';
fprintf(xmlFile,'%s\n',line);

fclose(xmlFile);

