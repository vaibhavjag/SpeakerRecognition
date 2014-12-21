function fileName=AudioSignatureToXML(as_mean,as_var,loEdge,hiEdge,hopSize,scaleRatio,fileName)
% This function generates the XML file containing the description of the AudioSignature Type
% It returns the name of the genrated XML file
% AudioSignature values is a MxN matrix with
% M=number of Signature vectors
% N=number of frequency bands

% Written by THorsten Kastner
% Based on ISO/IEC WD 15938-4
%
% Version 1.0 
% created 3/05/2002

defaultFileName='AudioSignature.xml';
Mpeg7_wrapper='Mpeg7_wrapper.xml';

if ~exist('fileName')
    fileName=defaultFileName;
elseif isempty(fileName)
        fileName=defaultFileName;
end       

%--------------------------
%determines the number of sample vectors 
%and the number of frequency bands
[numBands NumOfSamples ]=size(as_mean);

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
line='<DescriptionUnit xsi:type="mpeg7:AudioSignatureType" >';
fprintf(xmlFile,'\t%s\n',line);

line=['<Flatness loEdge="' num2str(loEdge) '" hiEdge="'  num2str(hiEdge) '">'];
fprintf(xmlFile,'\t%s\n',line);

totalSampleNum = scaleRatio* NumOfSamples;
line=['<SeriesOfVector vectorSize="' num2str(numBands) '" totalNumOfSamples="' num2str(totalSampleNum) '" >'];
fprintf(xmlFile,'\t\t%s\n',line);

line=['<Scaling ratio="' num2str(scaleRatio)  '" numOfElements="' num2str(NumOfSamples) '"/>'];
fprintf(xmlFile,'\t\t%s\n',line);

line=['<Mean mpeg7:dim="' num2str(NumOfSamples) ' ' num2str(numBands) '">'];
fprintf(xmlFile,'\t\t%s\n',line);	


%AudioSignature mean values:
for i=0:NumOfSamples-1
    fprintf(xmlFile,'\t\t\t');
    for j=1:numBands
      value=num2str(as_mean(i*numBands+j)); 
      fprintf(xmlFile,'%s ',value);
    end  
    fprintf(xmlFile,'\n');
end    
			 		
line='</Mean>';
fprintf(xmlFile,'\t\t\t%s\n',line);

line=['<Variance mpeg7:dim="' num2str(NumOfSamples) ' ' num2str(numBands) '">'];
fprintf(xmlFile,'\t\t\t%s\n',line);	

for i=0:NumOfSamples-1
    fprintf(xmlFile,'\t\t\t');
    for j=1:numBands
      value=num2str(as_var(i*numBands+j)); 
      fprintf(xmlFile,'%s ',value);
    end  
    fprintf(xmlFile,'\n');
end    


line='</Variance>';
fprintf(xmlFile,'\t\t\t%s\n',line);

line='</SeriesOfVector>';
fprintf(xmlFile,'\t\t%s\n',line);

line='</Flatness>';
fprintf(xmlFile,'\t\t%s\n',line);

line='</DescriptionUnit>';
fprintf(xmlFile,'\t%s\n',line);

%Mpeg7 end tag:
line='</Mpeg7>';
fprintf(xmlFile,'%s\n',line);

fclose(xmlFile);

