function [ mu,sigma ] = getGaussian( X )
    [N,D] = size(X);
    mu = sum(X)/N;
    sigma = zeros(D);
    for i =1:N
        sigma = sigma + ((X(i,:) - mu)'*(X(i,:) - mu));
    end
    sigma = sigma/N;
    sigma  = sigma + .0001 * eye(D);
end