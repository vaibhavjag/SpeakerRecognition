function h_SoundModelToXML(Y,outputFile)
% h_SoundModelToXML(SoundModelDS, filename)
%    - generates an XML file for SoundModelDS
%
% Author: Michael A. Casey
% Language: Matlab
% Based on ISO/IEC FDIS 15938-4
%
% Version 2.0 
% created 12/08/2003

Mpeg7_wrapper='Mpeg7_wrapper.xml';

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

%	<Model xsi:type="SoundClassificationModelType">
%			<SoundModel id="ID6" numOfStates="1">
%				<Transitions mpeg7:dim="20 20">
	
fprintf(xmlFile, '\t<Description xsi:type="ModelDescriptionType">\n');
[p,name,e]=fileparts(Y.soundName);
fprintf(xmlFile, '\t\t<Model xsi:type="SoundModelType" id="%s" numOfStates="%d">',name,size(Y.T,1));
fprintf(xmlFile, '\n\t\t\t<Transitions mpeg7:dim="%d %d">\n', size(Y.T,1), size(Y.T,1));
for k=1:size(Y.T,1)
   fprintf(xmlFile, '\t\t\t\t');
   fprintf(xmlFile, '%6.3f ', Y.T(k,:));
   fprintf(xmlFile, '\n');
end
fprintf(xmlFile, '\t\t\t</Transitions>\n');
%               <State>
%					<Label>
%						<Term termID="1.1"/>
%					</Label>
%				</State>
%				<DescriptorModel>
%					<Descriptor xsi:type="mpeg7:AudioSpectrumProjectionType">
%						<SeriesOfVector totalNumOfSamples="200"/>
%					</Descriptor>
%					<Field>SeriesOfVector</Field>
%				</DescriptorModel>

for k=1:size(Y.T,1)
   fprintf(xmlFile, '\t\t\t<State>\n');
   fprintf(xmlFile, '\t\t\t\t<Label>\n\t\t\t\t\t<Term termID="%d"/>\n\t\t\t\t</Label>\n',k);
   fprintf(xmlFile, '\t\t\t</State>\n');
end
fprintf(xmlFile, '\t\t\t<DescriptorModel>\n');
fprintf(xmlFile, '\t\t\t\t<Descriptor xsi:type="mpeg7:AudioSpectrumProjectionType">\n');
fprintf(xmlFile, '\t\t\t\t\t<SeriesOfVector totalNumOfSamples="%d"/>',floor(median(Y.numFrames)));
fprintf(xmlFile, '\n\t\t\t\t</Descriptor>\n');
fprintf(xmlFile, '\t\t\t\t<Field>SeriesOfVector</Field>');
fprintf(xmlFile, '\n\t\t\t</DescriptorModel>\n');

for m=1:size(Y.S,2)

   
 
%				<ObservationDistribution xsi:type="mpeg7:GaussianDistributionType">
%					<Mean mpeg7:dim="1 21"> 1.245  7.299  0.942 -3.185 -0.486 -0.552 -0.101 -0.373 -0.127 -0.159 -0.120 -0.064 -0.010 -0.088 -0.063  0.007  0.068 -0.038 -0.013  0.007  0.030 </Mean>
%					<CovarianceInverse mpeg7:dim="21 21">
   fprintf(xmlFile, '\t\t\t<ObservationDistribution xsi:type="mpeg7:GaussianDistributionType">\n');
   fprintf(xmlFile, '\t\t\t\t<Mean mpeg7:dim="1 %d">', size(Y.M,2));
   fprintf(xmlFile, '%6.3f ', Y.M(m,:) );
   fprintf(xmlFile, '</Mean>\n');
   
   fprintf(xmlFile, '\t\t\t\t<CovarianceInverse mpeg7:dim="%d %d">\n', size(Y.C(:,:,m),1),size(Y.C(:,:,m),2));
   C = Y.C(:,:,m);
   for l=1:size(C,1)
      fprintf(xmlFile, '\t\t\t\t\t'); 
      fprintf(xmlFile, '%6.3f ', C(l,:)); % inv(K)
      fprintf(xmlFile, '\n');
   end
   fprintf(xmlFile, '\t\t\t\t</CovarianceInverse>\n');
   fprintf(xmlFile, '\t\t\t</ObservationDistribution>\n');
end
%				<SoundClassLabel>
%					<Term/>
%				</SoundClassLabel>
%				<SpectrumBasis loEdge="62.5" hiEdge="8000" octaveResolution="1/4">
%					<SeriesOfVector hopSize="PT10N1000F" totalNumOfSamples="1" vectorSize="31">
%						<Raw mpeg7:dim="31 20">

   fprintf(xmlFile, '\t\t\t<SoundClassLabel>\n\t\t\t\t<Term termID="128.130.166"/>\n\t\t\t</SoundClassLabel>');
   fprintf(xmlFile, '\t\t\t<SpectrumBasis loEdge="62.5" hiEdge="8000" octaveResolution="1/4">\n');
fprintf(xmlFile, ...
   '\t\t\t<SeriesOfVector hopSize="PT10N1000F" totalNumOfSamples="1" vectorSize="%d">\n', size(Y.V,1));
fprintf(xmlFile, '\t\t\t\t<Raw mpeg7:dim="%d %d">\n', size(Y.V,1),size(Y.V,2));

for l=1:size(Y.V,1)
   fprintf(xmlFile,'\t\t\t\t\t');
   fprintf(xmlFile,'%6.3f ', Y.V(l,:));
   fprintf(xmlFile,'\n');
end
%				</Raw>
%					</SeriesOfVector>
%				</SpectrumBasis>

fprintf(xmlFile, '\t\t\t\t</Raw>\n');
fprintf(xmlFile, '\t\t\t</SeriesOfVector>\n');
fprintf(xmlFile, '\t\t\t</SpectrumBasis>\n');


%			</SoundModel>
%		</Model>
%	</Description>
%</Mpeg7>

fprintf(xmlFile, '\t\t</Model>\n');
fprintf(xmlFile, '\t</Description>\n');
fprintf(xmlFile, '</Mpeg7>\n');
fclose(xmlFile);
