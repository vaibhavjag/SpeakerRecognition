function fileName=AudioSpectrumBasisToXML(V,vargs)
% AudioSpectrumBasisToXML(AudioSpectrumBasisD, filename, [Optional Args]); 
%    - generates an XML file for AudioSpectrumBasisD
%
% AudioSignature values is a MxN matrix with
% M=number of Signature vectors
% N=number of frequency bands
%
% The following variables are optional, and are specified using
% ['parameter', value pairs] on the command line.
%   
%    'JADE'                0            - flag to indicate use of ICA
%    'hopSize'            'PT10N1000F'  - AudioSpectrumEnvelopeD hopSize
%    'loEdge'              62.5,        - AudioSpectrumEnvelopeD low Hz
%    'hiEdge'              16000,       - AudioSpectrumEnvelopeD high Hz
%    'octaveResolution'    '1/8'        - AudioSpectrumEnvelopeD resolution
%    'outputFile'           ''          - Filename for Model output [stem+mp7.xml]


% Author: Michael A. Casey
% Language: Matlab
% Based on ISO/IEC FDIS 15938-4
%
% Version 2.0 
% created 12/08/2003

Mpeg7_wrapper='Mpeg7_wrapper.xml';

if ~isempty(vargs.outputFile)
        fileName=vargs.outputFile;
end       

%--------------------------
%determines the number of sample vectors 
%and the number of frequency bands
[vectorSize totalNumOfSamples ]=size(V);

%--------------------------
%creation of the xml file:
try
    xmlFile=fopen(vargs.outputFile,'w');  %opens the file in write mode
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

%<Description xsi:type="ContentEntityType">
%		<MultimediaContent xsi:type="AudioType">
%			<Audio xsi:type="AudioSegmentType">
%				<MediaTime>
%					<MediaTimePoint>T00:00:00</MediaTimePoint>
%					<MediaDuration>PT15S450N1000F</MediaDuration>
%				</MediaTime>
%				<AudioDescriptor xsi:type="AudioWaveformType">

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

line='<AudioDescriptor ';
fprintf(xmlFile,'\t%s',line);

line=['loEdge="' num2str(vargs.loEdge) '" hiEdge="'  num2str(vargs.hiEdge) '" octaveResolution="' vargs.octaveResolution '" xsi:type="AudioSpectrumBasisType">'];
fprintf(xmlFile,'%s\n',line);
%<SeriesOfVector hopSize="PT500N1000F" totalNumOfSamples="30" vectorSize="5">
%						<Raw mpeg7:dim="5 10 30">

line=['<SeriesOfVector hopSize = "' vargs.hopSize '" vectorSize="' num2str(vectorSize) '" totalNumOfSamples="' num2str(totalNumOfSamples) '" >'];
fprintf(xmlFile,'\t\t%s\n',line);

line=['<Scaling ratio="1" numOfElements="' num2str(totalNumOfSamples) '"/>'];
fprintf(xmlFile,'\t\t%s\n',line);

line=['<Raw mpeg7:dim="' num2str(totalNumOfSamples) ' ' num2str(vectorSize) '">'];
fprintf(xmlFile,'\t\t\t%s\n',line);	


%AudioSpectrumEnvelopeD raw values:
for i=1:totalNumOfSamples
    value=num2str(V(:,i)'); 
    fprintf(xmlFile,'\t\t\t\t%s\n',value);
end    
			 		
line='</Raw>';
fprintf(xmlFile,'\t\t\t%s\n',line);

line='</SeriesOfVector>';
fprintf(xmlFile,'\t\t%s\n',line);

line='</AudioDescriptor>';
fprintf(xmlFile,'\t%s\n',line);

line='</Audio>';
fprintf(xmlFile,'\t%s\n',line);

line='</MultimediaContent>';
fprintf(xmlFile,'\t%s\n',line);

line='</Description>';
fprintf(xmlFile,'\t%s\n',line);

%Mpeg7 end tag:
line='</Mpeg7>';
fprintf(xmlFile,'%s\n',line);

fclose(xmlFile);

