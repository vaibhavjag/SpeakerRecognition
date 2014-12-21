%#####################################################################################
%##  Function: AudioSignalQualityDS.m;  describes signal quality of an audio file   ##  
%#####################################################################################
%
%   function AudioSignalQualityDS(auData,fs,channels,GivenName,szXMLout)
%
%   AudioSignalQualityD describes the audio signal quality  
%   of an AudioSegment
%
%   auData  	= inputmatrix of audiostream N channels in columns
%   fs 	 		= Samplerate of audiostream
%   channels    = channel to analyze (if empty all channels are used)
%   GivenName 	= Name of Operator
%   szXMLout    = name of output XML-file. if not given no XML-output
%
%   Written By Stefan Kudras
%   Version 1.0 March 2002
%	Version 2.0 August 2002 by Stefan Kudras handling of multichannel data described in 15398-5 (MDS)Amd.1
%	Version 2.1 January 2003 by Stefan Kudras XML data output as AudioLLDVectorType


function  AudioSignalQualityD(auData,fs,channels,GivenName,szXMLout)

BNL_M = BackgroundNoiseLevelD(auData,fs,channels);

[RD, msc] = RelativeDelayD(auData,fs,channels);

B = BalanceD(auData,channels);

DC = DCOffsetD(auData,channels);

C = CrossChannelCorrelationD(auData,fs,channels);

IM = IsOriginalMono(auData,fs,channels);

BW = BandwidthD(auData,fs,channels);

dclips = getDigitalClips(auData,channels);
[ErrLengthDclips dummy] = size(dclips);

SH = getSampleHolds(auData,channels);
[ErrLengthSH dummy] = size(SH);

DZ = getDigitalZeros(auData,channels);
[ErrLengthDZ dummy] = size(DZ);

clicks = getClicks(auData,channels);
[ErrLengthClicks dummy] = size(clicks);


% XML-Output
if nargin > 4
display(sprintf ('XML_Output file: %s',szXMLout));
% XML-Output
fid = fopen(szXMLout,'w');

xout = '<?xml version="1.0" encoding="iso-8859-1"?>';
fprintf(fid, '%s\n',xout);

xout = '<!-- ##################################################################### 	                -->';
fprintf(fid, '%s\n',xout);
xout = '<!-- Definition of AudioSignalQuality DS                                         	        -->';
fprintf(fid, '%s\n',xout);
xout = '<!-- ##################################################################### 	                -->';
fprintf(fid, '%s\n',xout);
xout = '<!-- <complexType name="AudioSignalQualityType"												-->';
fprintf(fid, '%s\n',xout);
xout = '<!--    <complexContent>																	-->';
fprintf(fid, '%s\n',xout);
xout = '<!--       <extension base="mpeg7:AudioDSType">										        -->';
fprintf(fid, '%s\n',xout);
xout = '<!--          <sequence>																	-->';
fprintf(fid, '%s\n',xout);
xout = '<!--             <element name="Operator" type="mpeg7:PersonType" minOccurs="0"/>			-->';
fprintf(fid, '%s\n',xout);
xout = '<!--             <element name="UsedTool" type="mpeg7:CreationToolType" minOccurs="0"/>	    -->';
fprintf(fid, '%s\n',xout);
xout = '<!--             <element name="BackgroundNoiseLevel" type="mpeg7:BackgroundNoiseLevelType"/>  -->';
fprintf(fid, '%s\n',xout);
xout = '<!--             <element name="RelativeDelay" type="mpeg7:RelativeDelayType"/>	            -->';
fprintf(fid, '%s\n',xout);
xout = '<!--             <element name="Balance" type="mpeg7:BalanceType"/>			                -->';
fprintf(fid, '%s\n',xout);
xout = '<!--             <element name="DcOffset" type="mpeg7:DcOffsetType"/>			            -->';
fprintf(fid, '%s\n',xout);
xout = '<!--             <element name="CrossChannelCorrelation" type="mpeg7:CrossChannelCorrelationType"/>		-->';
fprintf(fid, '%s\n',xout);
xout = '<!--             <element name="Bandwidth" type="mpeg7:BandwidthType"/>		                -->';
fprintf(fid, '%s\n',xout);
xout = '<!--             <element name="TransmissionTechnology" type="mpeg7:TransmissionTechnologyType" minOccurs="0"/>	-->';
fprintf(fid, '%s\n',xout);
xout = '<!--             <element name="ErrorEventList" minOccurs="0">                              -->';
fprintf(fid, '%s\n',xout);
xout = '<!--               <complexType>                                                            -->';
fprintf(fid, '%s\n',xout);
xout = '<!--                  <sequence>                                                            -->';
fprintf(fid, '%s\n',xout);
xout = '<!--                    <element name="ErrorEvent" type="mpeg7:ErrorEventType" minOccurs="0" maxOccurs="unbounded"/>                              -->';
fprintf(fid, '%s\n',xout);
xout = '<!--                  </sequence>                                                           -->';
fprintf(fid, '%s\n',xout);
xout = '<!--               </complexType>                                                           -->';
fprintf(fid, '%s\n',xout);
xout = '<!--             </element>                                                                 -->';
fprintf(fid, '%s\n',xout);
xout = '<!--          </sequence>																	-->';
fprintf(fid, '%s\n',xout);
xout = '<!--             <attribute name="IsOriginalMono" type="boolean"/>							-->';
fprintf(fid, '%s\n',xout);
xout = '<!--             <attribute name="BroadcastReady" type="boolean" use="optional"/>			-->';
fprintf(fid, '%s\n',xout);
xout = '<!--       </extension>																		-->';
fprintf(fid, '%s\n',xout);
xout = '<!--    </complexContent>																	-->';
fprintf(fid, '%s\n',xout);
xout = '<!-- </complexType>																			-->';
fprintf(fid, '%s\n\n',xout);


xout = '<Mpeg7 xmlns="urn:mpeg:mpeg7:schema:2001" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="urn:mpeg:mpeg7:schema:2001 .\AudioQ-2001.xsd">';
fprintf(fid, '%s\n',xout);

xout = strcat('	<DescriptionUnit xsi:type="AudioSignalQualityType" IsOriginalMono="',num2str(IM), '" BroadcastReady="1">');
fprintf(fid, '%s\n',xout);

xout = '		<Operator>';
fprintf(fid, '%s\n',xout);
xout = '			<Name>';
fprintf(fid, '%s\n',xout);
xout = strcat(' 				<GivenName>', GivenName, '</GivenName>');
fprintf(fid,'%s\n',xout);
xout = '			</Name>';
fprintf(fid, '%s\n',xout);
xout = '		</Operator>';
fprintf(fid, '%s\n\n',xout);

xout = '		<UsedTool>';
fprintf(fid, '%s\n',xout);
xout = '			<Tool/>';
fprintf(fid, '%s\n',xout);
xout = '		</UsedTool>';
fprintf(fid, '%s\n\n',xout);


xout = strcat(' 		<BackgroundNoiseLevel channels ="',num2str(channels,'%1d '),'">');
fprintf(fid,'%s\n',xout);
xout = strcat(' 			<Vector>', num2str(BNL_M), '</Vector>');
fprintf(fid,'%s\n',xout);
xout = strcat(' 		</BackgroundNoiseLevel>');
fprintf(fid,'%s\n\n',xout);

xout = strcat(' 		<RelativeDelay  Confidence="', num2str(msc),'" channels ="',num2str(channels,'%1d '),'">');
fprintf(fid,'%s\n',xout);
xout = strcat(' 			<Vector>', num2str(RD), '</Vector>');
fprintf(fid,'%s\n',xout);
xout = strcat(' 		</RelativeDelay>');
fprintf(fid,'%s\n\n',xout);

xout = strcat(' 		<Balance channels ="',num2str(channels,'%1d '),'">');
fprintf(fid,'%s\n',xout);
xout = strcat(' 			<Vector>', num2str(B), '</Vector>');
fprintf(fid,'%s\n',xout);
xout = strcat(' 		</Balance>');
fprintf(fid,'%s\n\n',xout);

xout = strcat(' 		<DcOffset channels ="',num2str(channels,'%1d '),'">');
fprintf(fid,'%s\n',xout);
xout = strcat(' 			<Vector>', num2str(DC), '</Vector>');
fprintf(fid,'%s\n',xout);
xout = strcat(' 		</DcOffset>');
fprintf(fid,'%s\n\n',xout);

xout = strcat(' 		<CrossChannelCorrelation channels ="',num2str(channels,'%1d '),'">');
fprintf(fid,'%s\n',xout);
xout = strcat(' 			<Vector>', num2str(C), '</Vector>');
fprintf(fid,'%s\n',xout);
xout = strcat(' 		</CrossChannelCorrelation>');
fprintf(fid,'%s\n\n',xout);

xout = strcat(' 		<Bandwidth channels ="',num2str(channels,'%1d '),'">');
fprintf(fid,'%s\n',xout);
xout = strcat(' 			<Vector>', num2str(BW), '</Vector>');
fprintf(fid,'%s\n',xout);
xout = strcat(' 		</Bandwidth>');
fprintf(fid,'%s\n\n',xout);

xout = '		<TransmissionTechnology href="urn:mpeg:mpeg7:cs:TransmissionTechnologyCS:category0">';
fprintf(fid, '%s\n',xout);
xout = strcat(' 			<Name>', 'Category0 ', '</Name>');
fprintf(fid,'%s\n',xout);
xout = '		</TransmissionTechnology>';
fprintf(fid, '%s\n\n',xout);


xout = '		<ErrorEventList>';
fprintf(fid, '%s\n',xout);

for ErrNr = 1:ErrLengthDclips
	xout = '			<ErrorEvent>';
	fprintf(fid, '%s\n',xout);
	xout = '				<ErrorClass href="urn:mpeg:mpeg7:cs:ErrorClassCS:digitalclip">';
	fprintf(fid, '%s\n',xout);
	xout = strcat(' 					<Name>', 'DigitalClip','</Name>');
	fprintf(fid,'%s\n',xout);
	xout = '				</ErrorClass>';
	fprintf(fid, '%s\n',xout);
	xout = strcat('				<ChannelNo>', num2str(channels(clips(ErrNr,1))), '</ChannelNo>');
	fprintf(fid,'%s\n',xout);
	xout = '				<TimeStamp>';
	fprintf(fid, '%s\n',xout);
	xout = strcat(' 						<MediaRelIncrTimePoint mediaTimeUnit="PT1N', num2str(fs), 'F" mediaTimeBase="../../MediaLocator[1]">', num2str(clicks(ErrNr,2)), '</MediaRelIncrTimePoint>');
	fprintf(fid,'%s\n',xout);
	xout = strcat(' 						<MediaIncrDuration mediaTimeUnit="PT1N',num2str(fs),'F">', num2str(dclips(ErrNr,3)), '</MediaIncrDuration>');
	fprintf(fid,'%s\n',xout);
	xout = '				</TimeStamp>';
	fprintf(fid, '%s\n',xout);
	xout = strcat(' 				<Relevance>', num2str(1), '</Relevance>');
	fprintf(fid,'%s\n',xout);
	xout = strcat(' 				<DetectionProcess>', 'automatic', '</DetectionProcess>');
	fprintf(fid,'%s\n',xout);
	xout = strcat(' 				<Status>', 'undefined', '</Status>');
	fprintf(fid,'%s\n',xout);
	xout = '				<Comment>';
	fprintf(fid, '%s\n',xout);
	xout = '					<FreeTextAnnotation>';
	fprintf(fid, '%s\n',xout);
	xout = '						any Comment to ErrorEvent';
	fprintf(fid, '%s\n',xout);
	xout = '					</FreeTextAnnotation>';
	fprintf(fid, '%s\n',xout);
	xout = '				</Comment>';
	fprintf(fid, '%s\n',xout);
	xout = '			</ErrorEvent>';
   fprintf(fid, '%s\n\n',xout);
end %loop over ErrLengthDclips

for ErrNr = 1:ErrLengthDZ
	xout = '			<ErrorEvent>';
	fprintf(fid, '%s\n',xout);
	xout = '				<ErrorClass href="urn:mpeg:mpeg7:cs:ErrorClassCS:digitalzero">';
	fprintf(fid, '%s\n',xout);
	xout = strcat(' 					<Name>', 'DigitalZero','</Name>');
	fprintf(fid,'%s\n',xout);
	xout = '				</ErrorClass>';
	fprintf(fid, '%s\n',xout);
	xout = strcat('				<ChannelNo>', num2str(channels(DZ(ErrNr,1))), '</ChannelNo>');
	fprintf(fid,'%s\n',xout);
	xout = '				<TimeStamp>';
	fprintf(fid, '%s\n',xout);
	xout = strcat(' 						<MediaRelIncrTimePoint mediaTimeUnit="PT1N', num2str(fs), 'F" mediaTimeBase="../../MediaLocator[1]">', num2str(clicks(ErrNr,2)), '</MediaRelIncrTimePoint>');
	fprintf(fid,'%s\n',xout);
	xout = strcat(' 						<MediaIncrDuration mediaTimeUnit="PT1N',num2str(fs),'F">', num2str(DZ(ErrNr,3)), '</MediaIncrDuration>');
	fprintf(fid,'%s\n',xout);
	xout = '				</TimeStamp>';
	fprintf(fid, '%s\n',xout);
	xout = strcat(' 				<Relevance>', num2str(1), '</Relevance>');
	fprintf(fid,'%s\n',xout);
	xout = strcat(' 				<DetectionProcess>', 'automatic', '</DetectionProcess>');
	fprintf(fid,'%s\n',xout);
	xout = strcat(' 				<Status>', 'undefined', '</Status>');
	fprintf(fid,'%s\n',xout);
	xout = '				<Comment>';
	fprintf(fid, '%s\n',xout);
	xout = '					<FreeTextAnnotation>';
	fprintf(fid, '%s\n',xout);
	xout = '						any Comment to ErrorEvent';
	fprintf(fid, '%s\n',xout);
	xout = '					</FreeTextAnnotation>';
	fprintf(fid, '%s\n',xout);
	xout = '				</Comment>';
	fprintf(fid, '%s\n',xout);
	xout = '			</ErrorEvent>';
   fprintf(fid, '%s\n\n',xout);
end %loop over ErrLengthDZ

for ErrNr = 1:ErrLengthSH
	xout = '			<ErrorEvent>';
	fprintf(fid, '%s\n',xout);
	xout = '				<ErrorClass href="urn:mpeg:mpeg7:cs:ErrorClassCS:samplehold">';
	fprintf(fid, '%s\n',xout);
	xout = strcat(' 					<Name>', 'SampleHold','</Name>');
	fprintf(fid,'%s\n',xout);
	xout = '				</ErrorClass>';
	fprintf(fid, '%s\n',xout);
	xout = strcat('				<ChannelNo>', num2str(channels(SH(ErrNr,1))), '</ChannelNo>');
	fprintf(fid,'%s\n',xout);
	xout = '				<TimeStamp>';
	fprintf(fid, '%s\n',xout);
	xout = strcat(' 						<MediaRelIncrTimePoint mediaTimeUnit="PT1N', num2str(fs), 'F" mediaTimeBase="../../MediaLocator[1]">', num2str(clicks(ErrNr,2)), '</MediaRelIncrTimePoint>');
	fprintf(fid,'%s\n',xout);
	xout = strcat(' 						<MediaIncrDuration mediaTimeUnit="PT1N',num2str(fs),'F">', num2str(SH(ErrNr,3)), '</MediaIncrDuration>');
	fprintf(fid,'%s\n',xout);
	xout = '				</TimeStamp>';
	fprintf(fid, '%s\n',xout);
	xout = strcat(' 				<Relevance>', num2str(1), '</Relevance>');
	fprintf(fid,'%s\n',xout);
	xout = strcat(' 				<DetectionProcess>', 'automatic', '</DetectionProcess>');
	fprintf(fid,'%s\n',xout);
	xout = strcat(' 				<Status>', 'undefined', '</Status>');
	fprintf(fid,'%s\n',xout);
	xout = '				<Comment>';
	fprintf(fid, '%s\n',xout);
	xout = '					<FreeTextAnnotation>';
	fprintf(fid, '%s\n',xout);
	xout = '						any Comment to ErrorEvent';
	fprintf(fid, '%s\n',xout);
	xout = '					</FreeTextAnnotation>';
	fprintf(fid, '%s\n',xout);
	xout = '				</Comment>';
	fprintf(fid, '%s\n',xout);
	xout = '			</ErrorEvent>';
   fprintf(fid, '%s\n\n',xout);
end %loop over ErrLengthSH

for ErrNr = 1:ErrLengthClicks
	xout = '			<ErrorEvent>';
	fprintf(fid, '%s\n',xout);
	xout = '				<ErrorClass href="urn:mpeg:mpeg7:cs:ErrorClassCS:click">';
	fprintf(fid, '%s\n',xout);
	xout = strcat(' 					<Name>', 'Click','</Name>');
	fprintf(fid,'%s\n',xout);
	xout = '				</ErrorClass>';
	fprintf(fid, '%s\n',xout);
	xout = strcat('				<ChannelNo>', num2str(channels(clicks(ErrNr,1))), '</ChannelNo>');
	fprintf(fid,'%s\n',xout);
	xout = '				<TimeStamp>';
	fprintf(fid, '%s\n',xout);
	xout = strcat(' 						<MediaRelIncrTimePoint mediaTimeUnit="PT1N', num2str(fs), 'F" mediaTimeBase="../../MediaLocator[1]">', num2str(clicks(ErrNr,2)), '</MediaRelIncrTimePoint>');
	fprintf(fid,'%s\n',xout);
	%xout = strcat(' 						<MediaIncrDuration mediaTimeUnit="PT1N',num2str(fs),'F">', num2str(clicks(ErrNr,3)), '</MediaIncrDuration>');
	%fprintf(fid,'%s\n',xout);
	xout = '				</TimeStamp>';
	fprintf(fid, '%s\n',xout);
	xout = strcat(' 				<Relevance>', num2str(1), '</Relevance>');
	fprintf(fid,'%s\n',xout);
	xout = strcat(' 				<DetectionProcess>', 'automatic', '</DetectionProcess>');
	fprintf(fid,'%s\n',xout);
	xout = strcat(' 				<Status>', 'undefined', '</Status>');
	fprintf(fid,'%s\n',xout);
	xout = '				<Comment>';
	fprintf(fid, '%s\n',xout);
	xout = '					<FreeTextAnnotation>';
	fprintf(fid, '%s\n',xout);
	xout = '						any Comment to ErrorEvent';
	fprintf(fid, '%s\n',xout);
	xout = '					</FreeTextAnnotation>';
	fprintf(fid, '%s\n',xout);
	xout = '				</Comment>';
	fprintf(fid, '%s\n',xout);
	xout = '			</ErrorEvent>';
   fprintf(fid, '%s\n\n',xout);
end %loop over ErrLengthclicks


xout = '		</ErrorEventList>';
fprintf(fid, '%s\n',xout);

xout = '	</DescriptionUnit>';
fprintf(fid, '%s\n\n',xout);

xout = '</Mpeg7>';
fprintf(fid, '%s\n',xout);


%% Close file 
fclose(fid);

end