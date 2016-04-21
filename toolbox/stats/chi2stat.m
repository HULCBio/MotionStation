function [m,v]= chi2stat(nu);
%CHI2STAT Mean and variance for the chi-square distribution.
%   [M,V] = CHI2STAT(NU) returns the mean and variance 
%   of the chi-square distribution with NU degrees of freedom.
%
%   A chi-square random variable, with NU degrees of freedom,
%   is identical to a gamma random variable with parameters NU/2 and 2.

%   References:
%      [1]  L. Devroye, "Non-Uniform Random Variate Generation", 
%      Springer-Verlag, 1986, pages 402-403.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.10.2.1 $  $Date: 2003/11/01 04:25:31 $

if nargin < 1, 
    error('stats:chi2stat:TooFewInputs','Requires one input argument.'); 
end

[m v] = gamstat(nu/2,2);
