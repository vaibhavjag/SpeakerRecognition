function gmm = mapAdapt(dataList, ubmFilename, tau, config)
% MAP-adapts a speaker specific GMM gmmFilename from UBM ubmFilename using
% features in dataList. The MAP relevance factor can be specified via tau.
% Adaptation of all GMM hyperparameters are supported. 
%
% Inputs:
%   - dataList    : ASCII file containing adaptation feature file name(s) 
%                   or a cell array containing feature(s). Feature files 
%					must be in uncompressed HTK format.  
%   - ubmFilename : file name of the UBM or a structure containing 
%					the UBM hyperparameters that is,
%					(ubm.mu: means, ubm.sigma: covariances, ubm.w: weights)
%   - tau         : the MAP adaptation relevance factor (19.0)
%   - config      : any sensible combination of 'm', 'v', 'w' to adapt 
%                   mixture means (default), covariances, and weights
%   - gmmFilename : the output speaker specific GMM file name (optional)
%
% Outputs:
%   - gmm		  : a structure containing the GMM hyperparameters
%					(gmm.mu: means, gmm.sigma: covariances, gmm.w: weights)
%
% References:
%   [1] D.A. Reynolds, T.F. Quatieri, and R.B. Dunn, "Speaker verification 
%       using adapted Gaussian mixture models," Digital Signal Process., 
%       vol. 10, pp. 19-41, Jan. 2000.
%
%
% Omid Sadjadi <s.omid.sadjadi@gmail.com>
% Microsoft Research, Conversational Systems Research Center

    if ( nargin < 3 ), 
        tau = 19.0; % MAP adaptation relevance factor
    end
    if ( nargin < 4 ), config = ''; end;

    if ischar(tau), tau = str2double(tau); end

    if isempty(config), config = 'm'; end

    if isstruct(ubmFilename),
        ubm = ubmFilename;
    else
        error('oh dear! ubmFilename should be either a string or a structure!');
    end

    gmm = ubm;

    if ~iscell(dataList),
        error('Oops! dataList should be a cell array!');
    end
    nfiles = length(dataList);

    N = 0; F = 0; S = 0;
    for file = 1 : nfiles,
        [n, f, s] = expectation(dataList{file}, ubm);
        N = N + n; F = F + f; S = S + s;
    end

    if any(config == 'm'),
        alpha = N ./ (N + tau); % tarde-off between ML mean and UBM mean
        m_ML = bsxfun(@rdivide, F, N);
        m = bsxfun(@times, ubm.mu, (1 - alpha)) + bsxfun(@times, m_ML, alpha); 
        gmm.mu = m;
    end

    if any(config == 'v'),
        alpha = N ./ (N + tau);
        v_ML = bsxfun(@rdivide, S, N);
        v = bsxfun(@times, (ubm.sigma+ubm.mu.^2), (1 - alpha)) + bsxfun(@times, v_ML, alpha) - (m .* m); 
        gmm.sigma = v;
    end

    if any(config == 'w'),
        alpha = N ./ (N + tau);
        w_ML = N / sum(N);
        w = bsxfun(@times, ubm.w, (1 - alpha)) + bsxfun(@times, w_ML, alpha); 
        w = w / sum(w);
        gmm.w = w;
    end
end


function [N, F, S, llk] = expectation(data, gmm)
% compute the sufficient statistics
    [post, llk] = postprob(data, gmm.mu, gmm.sigma, gmm.w(:));
    N = sum(post, 2)';
    F = data * post';
    S = (data .* data) * post';
end

function [post, llk] = postprob(data, mu, sigma, w)
% compute the posterior probability of mixtures for each frame
    post = gaussmixp(data, mu, sigma, w);
    llk  = logsumexp(post, 1);
    post = exp(bsxfun(@minus, post, llk));
end


function y = logsumexp(x, dim)
% compute log(sum(exp(x),dim)) while avoiding numerical underflow
    xmax = max(x, [], dim);
    y    = xmax + log(sum(exp(bsxfun(@minus, x, xmax)), dim));
    ind  = find(~isfinite(xmax));
    if ~isempty(ind)
        y(ind) = xmax(ind);
    end
end