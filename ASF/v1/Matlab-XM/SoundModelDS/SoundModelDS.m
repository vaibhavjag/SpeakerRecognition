function Y = SoundModelDS(TrainingDataListFile, nS, nB, varargin)

%SoundModelDS - Bayesean inference of HMM parameters from training data
%
% Y = SoundModelDS(TrainingDataListFile, nS, nB [,OPTIONAL ARGUMENTS...])
%
% INPUTS:
% TrainingDataList - filename of training data list: WAV file names (one per line).
%   nS - number of states in hidden Markov model [10]
%   nB - number of basis components to extract [10]
%
% The following variables are optional, and are specified using
% ['parameter', value pairs] on the command line.
%
%    'hopSize'            'PT10N1000F'  - AudioSpectrumEnvelopeD hopSize
%    'loEdge'              62.5,        - AudioSpectrumEnvelopeD low Hz
%    'hiEdge'              16000,       - AudioSpectrumEnvelopeD high Hz
%    'octaveResolution'    '1/8'        - AudioSpectrumEnvelopeD resolution
%    'sequenceHopSize'     '',          - HMM data window hop [whole file]
%    'sequenceFrameLength' ''           - HMM data window length [whole file]
%    'outputFile'           ''          - XML Filename for Model output
%    'soundName'            ''          - Model identifier name
%
% OUTPUTS: 
%
% outputFile.dat =  matlab struct Y.{T,S,M,C,X,maxEnv,V,p}
%
%     T - state transition matrix
%     S - initial state probability vector
%     M - stacked means matrix (1 vector per row)
%     C - stacked inverse covariances
%     V - AudioSpectrumBasis vectors
% maxEnv- scaling parameter for model decoding
%     p - training cycle likelihoods
%
% outputFile.mp7 = XML file containing MPEG-7 SoundModel description scheme
%
%
% EXAMPLE:
%
% SoundModelDS TrainList.txt 0 10 10 myModel1 octaveResolution '1/8' hopSize PT10N1000F
% 
% Copyright (C) 1999-2002 Michael A. Casey, All Rights Reserved

if nargin<1 printErrorMsg;end
if nargin<3 nB=10; end
if nargin<2 nS=10; end
if isstr(nB) nB=str2num(nB);end
if isstr(nS) nS=str2num(nS);end

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
Y.soundName = vargs.soundName;
DataScale=10; % Scaling factor to balance covariances during learning

% Read specified WAV files
fileList = readsfxfiles(TrainingDataListFile);
if(isempty(Y.soundName))
   Y.soundName = fileList{1};
end

% Calculate stacked AudioSpectrumEnvelopes of Training Data
XX=[];X=[];
nF=zeros(1,length(fileList));
for j=1:length(fileList)
   fprintf('\rAudioSpectrumEnvelopeD %s...             	    ',fileList{j});
   XX = AudioSpectrumEnvelopeD( fileList{j}, hopSize, attributegrp ) ;
   nF(j) = size(XX,1);
   X = [X;XX];
end

Y.numFrames = nF;
Y.scale = 10;

% Resample training sequences if sequenceHopSize is set
% This allows training of "on-line" HMMs with a fixed-length sample window
if(~isempty(vargs.sequenceHopSize))
   hopSize = extractTime(hopSize);
   sequenceHopSize = extractTime(vargs.sequenceHopSize);
   % Default sequence FrameLength is 3 x sequenceHopSize
   if(isempty(vargs.sequenceFrameLength))
      sequenceFrameLength = 3 * sequenceHopSize;
   else
      sequenceFrameLength = extractTime(vargs.sequenceFrameLength);	
   end
   sequenceHopSizeSamps = floor(sequenceHopSize/hopSize)
   sequenceFrameLengthSamps=floor(sequenceFrameLength/hopSize)
   
   % Test the sequenceHop variables
   if(sequenceHopSizeSamps<2)
      error('requirement that sequenceHopSize >= 2*hopSize not satisfied\n');
   end
   if(sequenceFrameLengthSamps<2)
      error('requirement that sequenceFrameLength >= 2*hopSize not satisfied\n');
   end
   
   % Remap the indices based on sequenceHopSize
   totalSequenceLength = sum(nF);
   numSequences = 1 + round((totalSequenceLength - sequenceFrameLengthSamps)/sequenceHopSizeSamps);
   for k = 1:numSequences
      indices(k,1) = (k-1)*sequenceHopSizeSamps+1;
      indices(k,2) = min(indices(k,1) + sequenceFrameLengthSamps - 1, totalSequenceLength);
   end
else
   indices = lengths_to_indices(nF);
end

% Record parameter data (to be recorded in the Decoder Metadata field of
% MP7 descriptor
Y.vargs = vargs;

% Calculate basis from training data AudioSpectrumEnvelope
fprintf('\nAudioSpectrumBasisD...\n');
Y.V = AudioSpectrumBasisD( X, nB );

% Extract AudioSpectrumProjection features
fprintf('\rAudioSpectrumProjectionD...\n');
X = AudioSpectrumProjectionD( X, Y.V );

% Extract spectral envelope maximum and store with model
% This step completes 'sphering' of the observation matrix
Y.maxEnv = max(X(:,1));
X(:,1) = X(:,1) / Y.maxEnv;
% TRAIN HMM
[Y.M,Cov,Y.T,Y.S,Y.p]=hmm(X*DataScale, indices, nS);
Y.C=repmat(inv(Cov),[1 1 nS]); % Unwrap Tied States
fprintf('\rSaving model %s ...\n', outputFile);
if(~isempty(outputFile))
   save(outputFile,'Y');
   h_SoundModelToXML(Y,outputFile);
end

% function [Mu,Cov,P,Pi,LL]=hmm(X,L,K,[cyc,tol]);
% 
% Gaussian Observation Hidden Markov Model
%
% X - N x p data matrix
% L - length of each sequence
% K - number of states (default 2)
% cyc - maximum number of cycles of Baum-Welch (default 100)
% tol - termination tolerance (prop change in likelihood) (default 0.0001)
%
% Mu - mean vectors
% Cov - output covariance matrix (full, tied across states)
% P - state transition matrix
% Pi - priors
% LL - log likelihood curve
%
% Iterates until a proportional change < tol in the log likelihood 
% or cyc steps of Baum-Welch

function [Mu,Cov,P,Pi,LL]=hmm(XX,T,K,cyc,tol)

MAX_SOUND=30000; % maximum sequence length in samples
lens = indices_to_lengths(T);
Tmax=min(max(lens),MAX_SOUND);
if(rem(size(XX,1),Tmax)~=0)
   % Pre-process data
   fprintf('Pre-processing...');
   X = zeros(length(T)*Tmax,size(XX,2));
   for k=1:length(T)
      startIndex=(k-1)*Tmax+1;
      endIndex=startIndex+lens(k)-1;
      X(startIndex:endIndex,:) = XX(T(k,1):T(k,2),:);
   end
else
   X = XX;
end

clear XX;
T=Tmax;
fprintf('Training...\n');
fprintf('%i log likelihood = %9.3f  ',0,-Inf);  
p=length(X(1,:));
N=length(X(:,1));

if nargin<5   tol=0.0001; end;
if nargin<4   cyc=100; end;
if nargin<3   K=2; end;
if nargin<2   T=N; end;


if (rem(N,T)~=0)
   disp('Error: Data matrix length must be multiple of sequence length T');
   return;
end;
N=N/T;

Cov=diag(diag(cov(X)));

Mu=randn(K,p)*sqrtm(Cov)+ones(K,1)*mean(X);

Pi=rand(1,K);
Pi=Pi/sum(Pi);

P=rand(K);
P=rdiv(P,rsum(P));

LL=[];
lik=0;

a=zeros(T,K);
b=zeros(T,K);
g=zeros(T,K);

B=zeros(T,K);
k1=(2*pi)^(-p/2);

for iter=1:cyc
   
   % Forward-backward  
   G=[];
   Gsum=zeros(1,K);
   Scale=zeros(T,1);
   Xi=zeros(T-1,K*K);
   
   for n=1:N
      
      iCov=inv(Cov);
      k2=k1/sqrt(det(Cov));
      for i=1:T
         for l=1:K
            d=Mu(l,:)-X((n-1)*T+i,:);
            B(i,l)=k2*exp(-0.5*d*iCov*d');
         end;
      end;
      
      scale=zeros(T,1);
      a(1,:)=Pi.*B(1,:);
      scale(1)=sum(a(1,:));
      a(1,:)=a(1,:)/scale(1);
      for i=2:T
         a(i,:)=(a(i-1,:)*P).*B(i,:);
         scale(i)=sum(a(i,:));
         a(i,:)=a(i,:)/scale(i);
      end;
      
      b(T,:)=ones(1,K)/scale(T);
      for i=T-1:-1:1
         b(i,:)=(b(i+1,:).*B(i+1,:))*(P')/scale(i); 
      end;
      
      g=(a.*b); 
      g=rdiv(g,rsum(g));
      gsum=sum(g);
      
      xi=zeros(T-1,K*K);
      for i=1:T-1
         t=P.*( a(i,:)' * (b(i+1,:).*B(i+1,:)));
         xi(i,:)=t(:)'/sum(t(:));
      end;
      
      Scale=Scale+log(scale);
      G=[G; g];
      Gsum=Gsum+gsum;
      Xi=Xi+xi;
   end;
   
   % M-Step 
   
   % outputs
   Mu=zeros(K,p);
   Mu=G'*X;
   Mu=rdiv(Mu,Gsum');
   
   % transition matrix 
   sxi=rsum(Xi')';
   sxi=reshape(sxi,K,K);
   P=rdiv(sxi,rsum(sxi));
   
   % priors
   Pi=zeros(1,K);
   for i=1:N
      Pi=Pi+G((i-1)*T+1,:);
   end
   Pi=Pi/N;
   
   % covariance
   Cov=zeros(p,p);
   for l=1:K
      d=(X-ones(T*N,1)*Mu(l,:));
      Cov=Cov+rprod(d,G(:,l))'*d;
   end;
   Cov=Cov/(sum(Gsum));
   
   oldlik=lik;
   lik=sum(Scale);
   LL=[LL lik];
   fprintf('\r%i log likelihood = %9.3f  ',iter,lik);  
   
   if (iter<=2)
      likbase=lik;
   elseif (lik<oldlik) 
      fprintf('violation');
   elseif ((lik-likbase)<(1 + tol)*(oldlik-likbase)|~finite(lik)) 
      fprintf('\n');
      break;
   end;
end

function indices=lengths_to_indices(lengths)
indices=cumsum(lengths(:));
indices=[[0; indices(1:length(indices)-1)]+1,indices];

function lens=indices_to_lengths(indices)
lens = indices(:,2)-indices(:,1) + 1;


% function Z=rdiv(X,Y)
% row division: Z = X / Y row-wise
% Y must have one column 
function Z=rdiv(X,Y)
if(length(X(:,1)) ~= length(Y(:,1)) | length(Y(1,:)) ~=1)
   disp('Error in RDIV');
   return;
end
Z=zeros(size(X));
for i=1:length(X(1,:))
   Z(:,i)=X(:,i)./Y;
end

% row sum
% function Z=rsum(X)
function Z=rsum(X)
Z=zeros(size(X(:,1)));
for i=1:length(X(1,:))
   Z=Z+X(:,i);
end

% row product
% function Z=rprod(X,Y)
function Z=rprod(X,Y)
[n m]=size(X);
if(length(Y(:,1)) ~=n  | length(Y(1,:)) ~=1)
   disp('Error in RPROD');
   return;
end
Z=X.*(Y*ones(1,m));

function sfxfiles = readsfxfiles(sfxfilename)
% READSSOUNDFILES - read a text file into a cell array of file names  
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

function t = extractTime(timeTag)
i = find(timeTag=='N');
t = [str2num(timeTag(3:i-1))/str2num(timeTag(i+1:end-1))];
function printErrorMsg

fprintf('SoundModelDS - Bayesean inference of HMM parameters from training data\n');
fprintf('\n');
fprintf(' Y = SoundModelDS(arg1, nF, nS, nB [,OPTIONAL ARGUMENTS...])\n');
fprintf('\n');
fprintf(' INPUTS:\n');
fprintf(' arg1 - t x n matrix of AudioSpectrumEnvelopes of all training data\n');
fprintf('      OR filename of list of training data file names (one per line).\n');
fprintf('   nF - vector of frame counts per training sequence [ignored if arg1 is a string]\n');
fprintf('   nS - number of states in hidden Markov model [10]\n');
fprintf('   nB - number of basis components to extract [10]\n');
fprintf('\n');
fprintf(' The following variables are optional, and are specified using\n');
fprintf(' ''parameter'' value pairs on the command line.\n');
fprintf('\n');
fprintf('    ''hopSize''          ''PT10N1000F''\n');
fprintf('    ''loEdge''            62.5,      \n');
fprintf('    ''hiEdge''            16000,     \n');
fprintf('    ''octaveResolution''  ''1/8''\n');
fprintf('    ''sequenceHopSize''     '''',\n');
fprintf('    ''sequenceFrameLength'' '''',\n');
fprintf('    ''outputFile''         ''''\n');
fprintf('    ''soundName''         ''''\n');
fprintf('\n');
fprintf(' OUTPUTS: \n');
fprintf('\n');
fprintf(' outputFile.dat =  matlab struct Y.{T,S,M,C,X,maxEnv,V,p}\n');
fprintf('\n');
fprintf('     T - state transition matrix\n');
fprintf('     S - initial state probability vector\n');
fprintf('     M - stacked means matrix (1 vector per row)\n');
fprintf('     C - stacked inverse covariances\n');
fprintf('     V - AudioSpectrumBasis vectors\n');
fprintf(' maxEnv- scaling parameter for model decoding\n');
fprintf('     p - training cycle likelihoods\n');
fprintf('\n');
fprintf(' outputFile.mp7 = XML file containing MPEG-7 SoundModel description scheme\n');
fprintf('\n');
fprintf('\n');
fprintf(' STANDALONE EXAMPLE:\n');
fprintf('\n');
fprintf(' SoundModelDS TrainList.txt 0 10 10 myModel1 octaveResolution ''1/8'' hopSize PT10N1000F\n');
fprintf(' \n');
fprintf(' Copyright (C) 1999-2002 Michael A. Casey, All Rights Reserved\n');

error('');





