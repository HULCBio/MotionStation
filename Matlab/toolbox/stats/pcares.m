function [residuals,reconstructed] = pcares(x,ndim)
%PCARES Residuals from a Principal Components Analysis.
%   RESIDUALS = PCARES(X,NDIM) returns the residuals obtained by retaining
%   the first NDIM principal components of the N-by-P data matrix X.  Rows
%   of X correspond to observations, columns to variables.  NDIM is a
%   scalar and must be less than or equal to P.  RESIDUALS is a matrix of
%   the same size as X.
%
%   [RESIDUALS,RECONSTRUCTED] = PCARES(X,NDIM) returns the reconstructed
%   observations, i.e., the approximation to X obtained by retaining its
%   first NDIM principal components.
%
%   See also FACTORAN, PCACOV, PRINCOMP.

%   References:
%     [1] Jackson, J.E., A User's Guide to Principal Components
%         Wiley, 1988.
%     [2] Krzanowski, W.J., Principles of Multivariate Analysis,
%         Oxford University Press, 1988.
%     [3] Seber, G.A.F., Multivariate Observations, Wiley, 1984.

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 2.10.2.2 $  $Date: 2003/11/01 04:27:44 $

[n,p] = size(x);
r = min(n-1,p); % the maximum number of useful components

if ~isscalar(ndim)
    error('stats:pcares:BadDim','NDIM must be a scalar.');
elseif ndim > p
    error('stats:pcares:BadDim',...
    'NDIM must be less than or equal to the number of columns in X.');
elseif ndim > r
    ndim = r;
end

[coeff,score] = princomp(x,'econ');

reconstructed = repmat(mean(x,1),n,1) + score(:,1:ndim)*coeff(:,1:ndim)';
residuals = x - reconstructed;
