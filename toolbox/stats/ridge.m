function b = ridge(y,X,k)
%RIDGE Ridge regression.
%   B = RIDGE(Y,X,K) returns the vector of regression coefficients, B.
%   Given the linear model: y = Xb, 
%   X is an n by p matrix, y is the n by 1 vector of observations and k
%   is a scalar constant.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.9.2.2 $  $Date: 2004/01/16 20:10:26 $

if  nargin < 3,              
    error('stats:ridge:TooFewInputs',...
          'Requires at least three input arguments.');      
end 

% Make sure k is a scalar.
if prod(size(k)) ~= 1
   error('stats:ridge:BadK','K must be a scalar.');
end

% Check that matrix (X) and left hand side (y) have compatible dimensions
[n,p] = size(X);

[n1,collhs] = size(y);
if n~=n1, 
    error('stats:ridge:InputSizeMismatch',...
          'The number of rows in Y must equal the number of rows in X.'); 
end 

if collhs ~= 1, 
    error('stats:ridge:InvalidData','Y must be a column vector.'); 
end

% Remove any missing values
wasnan = (isnan(y) | any(isnan(X),2));
if (any(wasnan))
   y(wasnan) = [];
   X(wasnan,:) = [];
   n = length(y);
end

% Normalize the columns of X to mean, zero, and standard deviation, one.
mx = mean(X);
stdx = std(X);
idx = find(abs(stdx) < sqrt(eps(class(stdx)))); 
if any(idx)
  stdx(idx) = 1;
end

MX = mx(ones(n,1),:);
STDX = stdx(ones(n,1),:);
Z = (X - MX) ./ STDX;
if any(idx)
  Z(:,idx) = ones(n,length(idx));
end

% Create matrix of pseudo-observations and add to the Z and y data.
pseudo = sqrt(k) * eye(p);
Zplus  = [Z;pseudo];
yplus  = [y;zeros(p,1)];

% Solve the linear system for regression coefficients.
b = Zplus\yplus;
