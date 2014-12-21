function Y = SoundClassificationModelDS(DIR, Nstates, Ncomps, varargin)

% Y = SoundClassificationModelDS(dir, nS, nB [, OPTIONAL ARGS])
%                                                                    
% Train multiple SoundModelDS using Baum-Welch re-estimation.
%
%Inputs:
%
% DIR - root directory for training data (contains sub-directories of individual class data)
% nS - number of initial model states for each HMM [10]
% nB  - number of basis functions to extract [10]
%
% The following variables are optional, and are specified using
% 'parameter' value pairs on the command line.
%
%    'hopSize'          'PT10N1000F'
%    'loEdge'            62.5,      
%    'hiEdge'            16000,     
%    'octaveResolution'  '1/8'
%    'outputFile'         'SoundClassificationModel'
%    'sequenceHopSize'      '',
%    'sequenceFrameLength'  ''
%
% Outputs:
%
% Y - cell array of SoundModelDS structures, one per sound class
%
% Copyright (C) 1999-2002 Michael A. Casey, All Rights Reserved.


if nargin<1 printErrorMsg;end

if nargin<3 Ncomps = 10; end
if nargin < 2 Nstates = 5; end
% Convert command line arguments to numerical arguments
if isstr(Ncomps) Ncomps=str2num(Ncomps); end;
if isstr(Nstates) Nstates=str2num(Nstates); end;

% Handle optional arguments
vargs = h_SoundModelOptions(varargin)
hopSize = vargs.hopSize;
attributegrp.hiEdge = vargs.hiEdge;
if(isstr(attributegrp.hiEdge))
   attributegrp.hiEdge = str2num(attributegrp.hiEdge);
end
attributegrp.loEdge = vargs.loEdge;
if(isstr(attributegrp.loEdge))
   attributegrp.loEdge = str2num(attributegrp.loEdge);
end
attributegrp.octaveResolution = vargs.octaveResolution;
outputFile = vargs.outputFile;
if(isempty(outputFile))
   MODEL_NAME = 'SoundClassificationModelDS';
else
   MODEL_NAME = outputFile;
end
TRAIN_LIST_NAME = [MODEL_NAME '_TrainList.txt'];
makeSoundDataLists(DIR, MODEL_NAME);

% Get directory structures for each sound class
D = dir(DIR);k=0;
for i=1:length(D)
   if(D(i).isdir & ~(D(i).name(1) == '.'))
      k=k+1;
      soundDir(k)=D(i);
   end
end

fprintf('MODELING SOUNDS:\n\n');
for i=1:k
   fprintf('\t[%d] %s\n',i,soundDir(i).name);
end
fprintf('\nModel: %s \n',MODEL_NAME) ;

if(k>0)
   
   % Loop over sound classes, train HMM models
   for i=1:k
      X=[];
      % Make training and testing lists (cross-validation data)
      soundName = fullfile( DIR, soundDir(i).name) ;
      fprintf('\nModeling sounds: %s\n', soundName);
      if(nargin < 4)
         crossValidateLists( soundName, [MODEL_NAME]) ;
      end
      
      % Architecture independent filename construction
      sfxfilename = fullfile( soundName, TRAIN_LIST_NAME );
      
      % Train SoundModelDS for each sound class
      fprintf('\n%s HMM Train Model...',soundDir(i).name);
      Y{i} = SoundModelDS ( sfxfilename, Nstates, Ncomps,...
         'loEdge',attributegrp.loEdge,...
         'hiEdge',attributegrp.hiEdge,...
         'octaveResolution',attributegrp.octaveResolution,...
         'hopSize',hopSize,...
         'soundName',soundDir(i).name,...
         'sequenceHopSize',vargs.sequenceHopSize,...
         'sequenceFrameLength',vargs.sequenceFrameLength) ;
      fprintf('Det=%f\n', det( inv(Y{i}.C(:,:,1)) ) );
   end
   
   TRAIN_PREFIX = [MODEL_NAME '_TRAIN'];
   fprintf('...saving HMM CLASSIFIER to %s...\n', TRAIN_PREFIX);
   save(fullfile(DIR,[TRAIN_PREFIX]), 'Y');
   writeclassifierXML(Y, fullfile(DIR,[TRAIN_PREFIX '.mp7']));
   
else
   fprintf('\nBummer! No sound directories found\n');
end

function sfxfiles = readsfxfiles(sfxfilename)

% READSFXFILES - read a text file into a cell array of file names  
%     sfxfiles = readsfxfiles(icfilename)                          
fid = fopen(sfxfilename, 'rt');
if fid<=0
   error(['Unable to open ' sfxfilename ' as a text file']);
end
sfxfiles = cell(1);
f = 1;
% One filename per line
sfxfile = fgetl(fid);
while ~isempty(sfxfile) & (sfxfile ~= -1)
   sfxfiles{f} = sfxfile;
   f=f+1;
   sfxfile = fgetl(fid);
end
fclose(fid);
sfxfiles=sfxfiles';

function makeSoundDataLists(DIR, ALT_NAME)

%makeSoundDataLists - compile training and testing data lists
%
%  makeSoundDataLists(DIR, ALT_NAME)
%
% DIR = full pathname of experiment directory
% ALT_NAME = name of experiment trial
%
% Copyright (C) 2001 Michael Casey, MERL, All Rights Reserved.

if(nargin<2)
   ALT_NAME = 'Default';
end

fprintf('%s\n',DIR);
% Get directory structures for each sound class
D = dir(DIR);k=0;
for i=1:length(D)
   if(D(i).isdir & ~(D(i).name(1) == '.'))
      k=k+1;
      soundDir(k)=D(i);
      soundName = fullfile( DIR, soundDir(k).name) ;
      crossValidateLists(soundName, ALT_NAME);
   end
end

function crossValidateLists(soundDir, ALT_NAME)

% CROSSVALIDATELISTS - make cross validation training and testing set ...
%    from an ALL_TestList.txt file
%
% crossValidateLists(soundDir)
%
% Case 1: MODEL_TrainList.txt exists - use this list as training data
% Case 2: MODEL_TrainList.txt does NOT exist
%        Creates a 70/30 split of the available data in soundDir
%
% Copyright (C) October 2000, Michael A. Casey, MERL, All Rights Reserved

if nargin < 2
   ALT_NAME = [];
end    

AllListName = fullfile(soundDir,'ALL_TestList.txt');
TrainListName = fullfile(soundDir,[ALT_NAME '_TrainList.txt']);
TestListName =  fullfile(soundDir,[ALT_NAME '_TestList.txt']);

All=dir(AllListName);
Trn=dir(TrainListName);
Tst=dir(TestListName);

if(isempty(All) & isempty(Trn) )
   TL=dir([soundDir '/*.wav']);
   for k=1:length(TL)     
      AllList{k}=fullfile(soundDir,TL(k).name);
   end
   textwrite(AllList, AllListName);
end

if(isempty(Trn))
   s = textread(AllListName, '%s\n');
   numFiles=length(s);
   p = randperm(numFiles);
   trainIndx=round(.7*numFiles); % Use 70% of data for training, 30% for testing
   
   trainers=p(1:trainIndx);
   testers=p(trainIndx+1:end);
   
   fprintf('%s #Train: %d, #Test %d\n', soundDir, length(trainers), length(testers)); 
   
   textwrite({s{trainers}}, TrainListName);
   textwrite({s{testers}}, TestListName);
end

function textwrite(S,filename)

%TEXTWRITE write cell array matrix to text file
%
% Each cell is considered a separate line

fid = fopen(filename,'w');
if(fid<0)
   error(['Cannot open file ' filename]);
end

numFiles=length(S);

for k=1:numFiles
   fprintf(fid, '%s\r\n',S{k});
end

fclose(fid);


function writeclassifierXML(Y, filename)

% WRITE CLASSIFIER XML
%
% writeclassifierXML(Y, filename)
%
% MPEG-7 XML version of writeclassifier

[nClasses, nModelTypes] = size(Y);

fid = fopen(filename, 'wt');

if(fid<0)
   error('Could mp7 not open file');
end

fprintf(fid, '<AudioDescriptionScheme xsi:type="SoundClassificationModelType">\n');
for k=1:nClasses
   fprintf(fid, '\t<SoundModel id="ID:SoundModel:%d">\n',k);
   fprintf(fid, '\t\t<SoundClassLabel><Term id="ID:SoundClass:%s">%s</Term></SoundClassLabel>\n', ...
      Y{k}.soundName,Y{k}.soundName);
   
   fprintf(fid, '\t\t<Initial dim="%d %d">', 1, ...
      size(Y{k}.T,1));
   fprintf(fid, '%6.3f ', Y{k}.S);
   fprintf(fid, '</Initial>\n');
   
   fprintf(fid, '\t\t<Transitions dim="%d %d">\n', size(Y{k}.T,1), ...
      size(Y{k}.T,1));
   
   for l=1:size(Y{k}.T,1)
      fprintf(fid, '\t\t\t');
      fprintf(fid, '%6.3f ', Y{k}.T(l,:));
      fprintf(fid, '\n');
   end
   fprintf(fid, '\t\t</Transitions>\n');
   
   fprintf(fid, '\t\t<DescriptorModel>\n');
   fprintf(fid, '\t\t\t<Descriptor xsi:type="mpeg7:AudioSpectrumProjectionType"/>\n');
   fprintf(fid, '\t\t\t<Field>SeriesOfVector</Field>\n');
   fprintf(fid, '\t\t</DescriptorModel>\n');
   
   for m=1:size(Y{k}.S,2)
      fprintf(fid, '\t\t<State>\n');
      fprintf(fid, '\t\t\t<Label><Term id="ID:ModelState:%d">State%d</Term></Label>\n',m,m);
      fprintf(fid, '\t\t</State>\n');
      
      fprintf(fid, '\t\t<ObservationDistribution xsi:type="mpeg7:GaussianDistributionType">\n');
      fprintf(fid, '\t\t\t<Mean dim="1 %d">', size(Y{k}.M,2));
      fprintf(fid, '%6.3f ', Y{k}.M(m,:) );
      fprintf(fid, '</Mean>\n');
      
      fprintf(fid, '\t\t\t<CovarianceInverse dim="%d %d">\n', size(Y{k}.C(:,:,m),1), ...
         size(Y{k}.C(:,:,m),2));
      C = Y{k}.C(:,:,m);
      for l=1:size(C,1)
         fprintf(fid, '\t\t\t\t'); 
         fprintf(fid, '%6.3f ', C(l,:)); % inv(K)
         fprintf(fid, '\n');
      end
      fprintf(fid, '\t\t\t</CovarianceInverse>\n');
      fprintf(fid, '\t\t\t<Determinant>\n');	
      fprintf(fid, '\t\t\t\t%f\n', det(inv(Y{k}.C(:,:,m)))); % determinant of K
      fprintf(fid, '\t\t\t</Determinant>\n');		
      fprintf(fid, '\t\t</ObservationDistribution>\n');
   end
   
   
   fprintf(fid, '\t\t<SpectrumBasis loEdge="62.5" hiEdge="8000" octaveResolution="1/4">\n');
   fprintf(fid, ...
      '\t\t\t<SeriesOfVector hopSize="PT10N1000F" totalNumOfSamples="1" vectorSize="%d %d">\n', ...
      size(Y{k}.V,1), size(Y{k}.V,2));
   fprintf(fid, '\t\t\t\t<Raw mpeg7:dim="%d %d">\n', size(Y{k}.V,1),size(Y{k}.V,2));
   
   for l=1:size(Y{k}.V,1)
      fprintf(fid,'\t\t\t\t\t');
      fprintf(fid,'%6.3f ', Y{k}.V(l,:));
      fprintf(fid,'\n');
   end
   
   fprintf(fid, '\t\t\t\t</Raw>\n');
   fprintf(fid, '\t\t\t</SeriesOfVector>\n');
   fprintf(fid, '\t\t</SpectrumBasis>\n');
   fprintf(fid, '\t</SoundModelClass>\n',k);
end
fprintf(fid, '</AudioDescriptionScheme>\n');

function printErrorMsg

fprintf(' Y = SoundClassificationModelDS(dir, Nstates, Ncomps, ClassifierName,[AttGrp, Hop])\n');
fprintf('\n');                                                                    
fprintf(' Train multiple SoundModelDS using using Baum-Welch re-estimation.\n');
fprintf('\n');
fprintf('Inputs:\n');
fprintf('\n');
fprintf(' DIR - root directory for training data (contains sub-directories of individual class data)\n');
fprintf(' Nstates - number of initial model states for each HMM [10]\n');
fprintf(' Ncomps  - number of basis functions to extract [10]\n');
fprintf(' The following variables are optional, and are specified using\n');
fprintf(' ''parameter'' value pairs on the command line.\n');
fprintf('\n');
fprintf('    ''hopSize''          ''PT10N1000F''\n');
fprintf('    ''loEdge''            62.5,      \n');
fprintf('    ''hiEdge''            16000,     \n');
fprintf('    ''octaveResolution''  ''1/8''\n');
fprintf('    ''sequenceHopSize''      '''',\n');
fprintf('    ''sequenceFrameLength''  '''',\n');
fprintf('    ''outputFile''         ''SoundClassificationModel''\n');
fprintf('\n');
fprintf(' Outputs:\n');
fprintf(' Y{:} - cell array of SoundModelDS structures, one per sound class\n');
fprintf('\n');
fprintf(' Copyright (C) 1999-2002 Michael A. Casey, All Rights Reserved.\n');
fprintf('\n');

error('');





