function [Path, loglike] = SoundModelStatePathD(filename, arg2, varargin)
%[Path,loglike]=SoundModelStatePathD(soundfilename, arg2 [,OPTIONAL ARGS]) 
%
% Compute HMM State Path and log likelihood of sequence data
%
% Inputs:
% soundfilename - filename of input sound (.wav or .au)
% arg2 - SoundModelDS structure or filename of binary SoundModelDS instance (.mat)
%
% The following variables are optional, and are specified using
% 'parameter' value pairs on the command line.
%
%    'hopSize'          'PT10N1000F'
%    'loEdge'            62.5,      
%    'hiEdge'            16000,     
%    'octaveResolution'  '1/8'
%    'sequenceHopSize'     '',
%    'sequenceFrameLength' ''
%    'outputFile'         ''
%
% Outputs
%
% Path - hidden Markov model optimal state path for sequence
% loglike - log-likelihood of sequence
%

% Copyright (C) 2002 Michael A. Casey, All Rights Reserved

if nargin<1 printErrorMsg;end
vargs = h_SoundModelOptions(varargin);
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

% Read WAV file and compute AudioSpectrumEnvelope
if(isstr(filename))
    fprintf('AudioSpectrumEnvelopeD %s\n',filename);
    ASE = AudioSpectrumEnvelopeD(filename, hopSize, attributegrp ) ;
else
    ASE=filename;
end

% If arg2 is a string then read the SoundModelDS instance file
if isstr(arg2)
   load(arg2);
else
   Y=arg2;
   clear arg2;
end

% Project AudioSpectrumEnvelope Data
X = AudioSpectrumProjectionD(ASE,Y.V);
% Scale envelope to model's range
X(:,1)=X(:,1)/Y.maxEnv;
% Calculate the viterbi path and log likelihood of the sequence
% Calculate instantaneous observation probabilities
DataScale=Y.scale;

if(isempty(vargs.sequenceHopSize))
    [loglike,Path]=viterbi(Y.T,Y.S,Y.M,Y.C,X*DataScale);
else
% Resample sequences if sequenceHopSize is set
% This allows "on-line" decoding of HMMs with a fixed-length sample window
   nF = size(X,1);
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
   
   clear loglike;
   for k = 1:numSequences
      [loglike(k),Path{k}]=viterbi(Y.T,Y.S,Y.M,Y.C,X(indices(k,1):indices(k,2),:)*DataScale);
   end
end

if(~isempty(outputFile))
    [p,name,e]=fileparts(Y.soundName);
   h_SoundModelStatePathToXML(Path, [outputFile], name);
end

function [ll,istar,delta,logP]=viterbi(Transitions,Starts,Means,iCovariances,Observations)
% Viterbi decoder algorithm.
[N,N] = size(Transitions);
[T,d] = size(Observations);
logP = hmm_logprob_obs_given_state(Observations, Means, iCovariances);
logA = log_quiet(Transitions);
% Initialization
delta = zeros(T,N); psi = zeros(T,N);
delta(1,:) = log_quiet(Starts) + logP(1,:);
% Recursion
for t = 2:T
   for j = 1:N
      [maxp,psi(t,j)] = max(delta(t-1,:) + logA(:,j)');
      delta(t,j) = maxp + logP(t,j);
   end
end
% Termination
[ll,maxi] = max(delta(T,1:N));
istar(T) = maxi;
% Path backtracking
for t = (T - 1):-1:1
   istar(t) = psi(t+1,istar(t+1));
end

function ret = hmm_logprob_obs_given_state(Observations, Means, iCovariances)
% computes the probability of each observation given in OBSERVATIONS
% conditional on each state in the HMM model given by MEANS and inverse COVARIANCES.
n = size(Means, 1);
if isempty(iCovariances),
   % Discrete case
   ret = zeros(length(Observations), n);
   Means=log(Means);
   for j = 1:n,
      ret(:, j) = Means(j, Observations)';
   end;
else
   ret = zeros(size(Observations, 1), n);
   for j = 1:n,
      ret(:, j) = B3log(Observations, iCovariances(:,:,j), Means(j,:));
   end
end

function y=log_quiet(x)

mask = find(x==0);
fill=ones(size(mask));
x(mask)=fill;
y=log(x);
y(mask)=-Inf.*fill;

% function logprobs = B3log(X,iCovariance,Mean)
% log of a multivariate Gaussian; X is a column vector(s)
% takes pains to return a real value for ill-conditioned covariance matrix

function logprobs = B3log(X,icovariance,mean)

persistent CONSTANTS_INITIALIZED REALMIN REALMAX LOG2PI EPSILON
if isempty(CONSTANTS_INITIALIZED),
   REALMIN = realmin;
   REALMAX = realmax;
   EPSILON = 1e-50;
   LOG2PI = log(2.*pi);
   CONSTANTS_INITIALIZED = 1;
end;

% Remove dimensions w/infinite variance
% In the production version of this code, you will not have to do this
bad=find(~isfinite(diag(icovariance)));	
if ~isempty(bad)
   icovariance(bad,:)=[]; 
   if isempty(icovariance), error('B3: entire covariance matrix is bad'); end;
   icovariance(:,bad)=[]; X(:,bad)=[]; mean(:,bad)=[]; 
end;

% Compute determinant, 
idtr=det(icovariance);

if idtr>0, 
   log_idtr=log(idtr);
else
   % Fix determinant if there were numerical problems
   % In the production version of this code, you will not have to do this
   log_idtr=sum(log(max(EPSILON,eig(icovariance)))); 
end;

[T,d] = size(X);

if d~=size(mean,2)
   error('B3log: error, data and mean do not agree in dimensionality'); 
end

if nargin>2, 
   % case of nonzero mean
   logprobs = -0.5 .* (mahalonobis(X,icovariance,mean) + d.*LOG2PI - log_idtr);
else
   % case of zero mean
   logprobs = -0.5 .* (mahalonobis(X,icovariance) + d.*LOG2PI - log_idtr);
end

function distance=mahalonobis(x,icov,mean)
%distance=mahalonobis(x,icov,mean) Compute mahalonobis distance from the mean.
%
% X=vadd(-mean,x); distance=sum((X*icov).*X,2);
X=vadd(-mean,x); 
distance=sum((X*icov).*X,2);

function res=vadd(a,b)

% Add a and b.  
% If they differ in dimension, repeatedly add one to the other.
% Assumes that the smaller operand is a vector.

[r1,c1]=size(a);
[r2,c2]=size(b);
r=max(r1,r2);
c=max(c1,c2);

if r1==r2, 
   res=zeros(r,c); 
   if r<c,
      for i=1:r1, res(i,:)=a(i,:)+b(i,:); end;
   elseif c1==c2
      res=a+b;
   elseif c1==1, 
      for i=1:c2, res(:,i)=b(:,i)+a; end; 
   else
      for i=1:c1, res(:,i)=a(:,i)+b; end; 
   end
elseif c1==c2,
   res=zeros(r,c); 
   if c<r,
      for i=1:c1, res(:,i)=a(:,i)+b(:,i); end;
   elseif r1==1, 
      for i=1:r2, res(i,:)=b(i,:)+a; end; 
   else 
      for i=1:r1, res(i,:)=a(i,:)+b; end; 
   end
elseif (r1==1)&(c2==1), 
   res=tsum(b,a);
elseif (r2==1)&(c1==1), 
   res=tsum(a,b);
else error('vadd: incompatible sizes');
end;

function M=tsum(v1,v2) % tensor sum of two vectors, v1->cols; v2->rows

r=length(v1);
c=length(v2);
M=zeros(r,c);
for i=1:r, a=v1(i); for j=1:c, M(i,j)=a+v2(j); end; end;

function t = extractTime(timeTag)
i = find(timeTag=='N');
t = [str2num(timeTag(3:i-1))/str2num(timeTag(i+1:end-1))];

function indices=lengths_to_indices(lengths)
indices=cumsum(lengths(:));
indices=[[0; indices(1:length(indices)-1)]+1,indices];

function lens=indices_to_lengths(indices)
lens = indices(:,2)-indices(:,1) + 1;



function writeStatePathXML(P,fname,hopSize)

fid = fopen(fname, 'wt');
if(fid<0)
   error('Could not open file\n');
end

a=length(P);
fprintf(fid,'<AudioDescriptor xsi:type="SoundModelStatePathType">\n');
fprintf(fid,'\t<StatePath><SeriesOfScalar totalNumOfSamples="%d" hopSize="%s">\n', ...
   a, hopSize);
fprintf(fid,'\t\t');
fprintf(fid,'%d ', P);
fprintf(fid,'\n\t</SeriesOfScalar></StatePath>\n');
fprintf(fid,'\t<SoundModelRef>%s</SoundModelRef>\n', 'ID6');
fprintf(fid,'</AudioDescriptor>');
fclose(fid);

function printErrorMsg
fprintf('[Path,loglike]=SoundModelStatePathD(arg1, arg2 [,OPTIONAL ARGS])\n'); 
fprintf('\n'); 
fprintf(' Compute HMM State Path\n'); 
fprintf('\n'); 
fprintf(' Inputs:\n'); 
fprintf(' arg1 - AudioSpectrumEnvelope or filename of input sound (.wav)\n'); 
fprintf(' arg2 - SoundModelDS structure or filename of binary SoundModelDS instance (.mat)\n'); 
fprintf('\n'); 
fprintf(' The following variables are optional, and are specified using\n'); 
fprintf(' ''parameter'' value pairs on the command line.\n'); 
fprintf('\n'); 
fprintf('    ''hopSize''          ''PT10N1000F''\n'); 
fprintf('    ''loEdge''            62.5,      \n'); 
fprintf('    ''hiEdge''            16000,     \n'); 
fprintf('    ''octaveResolution''  ''1/8''\n'); 
fprintf('    ''sequenceHopSize''    '''',\n');
fprintf('    ''sequenceFrameLength'' '''',\n');
fprintf('    ''outputFile''         ''''\n'); 
fprintf('\n'); 
fprintf(' Outputs\n'); 
fprintf('\n'); 
fprintf(' Path - hidden Markov model optimal state path for sequence\n'); 
fprintf(' loglike - log-likelihood of sequence\n'); 
fprintf('\n'); 
fprintf(' Copyright (C) 2002 Michael A. Casey, All Rights Reserved\n'); 

error('');

