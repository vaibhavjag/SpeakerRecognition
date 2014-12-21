function fileName=SMSHtoXML(Hist,Ref,fileName)

% This function generates the XML file containing the description of the
% SoundModelStateHistogram
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
[totalNumOfSamples]=length(Hist);

%	<!-- ############################################################# -->
%	<!-- Definition of SoundModelStateHistogram D                      -->
%	<!-- ############################################################# -->
%	<complexType name="SoundModelStateHistogramType">
%		<complexContent>
%			<extension base="mpeg7:AudioDType">
%				<sequence>
%					<sequence maxOccurs="unbounded">
%						<element name="StateRef" type="anyURI"/>
%						<element name="RelativeFrequency" type="mpeg7:nonNegativeReal"/>
%					</sequence>
%					<element name="SoundModelRef" type="anyURI"/>
%				</sequence>
%			</extension>
%		</complexContent>
%	</complexType>
    
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
line='<DescriptionUnit xsi:type="mpeg7:SoundModelStateHistogramType">';
fprintf(xmlFile,'\t%s\n',line);

fprintf(xmlFile,'\t\t');
for j=1:length(Hist)
    fprintf(xmlFile,'<StateRef>%d</StateRef>\n',j);
    fprintf(xmlFile,'<RelativeFrequency>%d</RelativeFrequency>\n',Hist(j));
end  
fprintf(xmlFile,'\t<SoundModelRef>%s</SoundModelRef>\n',Ref);
fprintf(xmlFile,'\n');
line='</DescriptionUnit>';
fprintf(xmlFile,'\t%s\n',line);

%Mpeg7 end tag:
line='</Mpeg7>';
fprintf(xmlFile,'%s\n',line);

fclose(xmlFile);

