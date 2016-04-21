function [ahat,bhat,aci,bci] = unifit(x,alpha)
%UNIFIT Parameter estimates for uniformly distributed data.
%   UNIFIT(X,ALPHA) Returns the maximum likelihood estimates (MLEs) of the  
%   parameters of the uniform distribution given the data in the vector, X.  
%
%   [AHAT,BHAT,ACI,BCI] = UNIFIT(X,ALPHA) gives MLEs and 
%   100(1-ALPHA) percent confidence intervals given the data.
%   ALPHA is optional. By default ALPHA = 0.05 which corresponds
%   to 95% confidence intervals. 
%
%   See also UNIFCDF, UNIFINV, UNIFPDF, UNIFRND, UNIFSTAT, MLE. 

%   B.A. Jones 1-30-95
%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.8.2.1 $  $Date: 2004/01/24 09:37:18 $

if nargin < 2 
    alpha = 0.05;
end
[m,n]= size(x);
ahat = min(x);
bhat = max(x);

tmp = (bhat - ahat)./alpha.^(1./m);
aci = [bhat - tmp; ahat];
bci = [bhat; ahat + tmp];
