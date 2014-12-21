function [Slope,Intercept,varargout] = LKS_SVM(x0,x1,C)


%SVC Support Vector Classification
%
%  Usage: [nsv alpha bias] = svc(X,Y,ker,C)
%
%  Parameters: X      - Training inputs
%              Y      - Training targets
%              nsv    - number of support vectors
%              alpha  - Lagrange Multipliers
%              b0     - bias term

    X = x0;
    Y = x1;
    n = size(X,1);
    D = size(X,2);
    
    H = zeros(n);  
    for i=1:n
       for j=1:n
          H(i,j) = Y(i)*Y(j)*(X(i,:)*X(j,:)');
       end
    end
    c = -ones(n,1);  

    % Add small amount of zero order regularisation to 
    % avoid problems when Hessian is badly conditioned. 
    H = H+1e-10*eye(size(H));
    
    % Set up the parameters for the Optimisation problem

    vlb = zeros(n,1);      % Set the bounds: alphas >= 0
    X0 = zeros(n,1);       % The starting point is [0 0 0   0]
    vub = C*ones(n,1);     %                 alphas <= C
    A = Y';
    b = 0;     % Set the constraint Ax = b
    [alpha] = quadprog(H,c,[],[],A,b,vlb,vub,X0,optimset('Display', 'off', 'Algorithm', 'interior-point-convex'));
    Slope = zeros(D,1);
    for j = 1:D
        Slope(j) = sum((alpha.*Y).*X(:,j));
    end    
    epsilon = C * 1e-6;
    % Compute the number of Support Vectors
    svii = alpha > epsilon;
    % find b0 from average of support vectors on margin
    % SVs on margin have alphas: 0 < alpha < C
    sVectors = X(svii,:);
    varargout = {sVectors,alpha};
    svi = find( alpha > epsilon & alpha < (C - epsilon));
    Intercept =  (1/length(svi))*sum(Y(svi) - X(svi,:)*Slope);
end