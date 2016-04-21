function [errstr,P,f] = svmcov(x,Fs,valueArray)
%SVMCOV spectview Wrapper for Modified Covariance method.
%  [errstr,P,f] = SVMCOV(x,Fs,valueArray) computes the power spectrum P
%  at frequencies f using the parameters passed in via valueArray:
%
%   valueArray entry     Description
%    ------------         ----------
%          1                Order
%          2                Nfft

%   Copyright 1988-2002 The MathWorks, Inc.
% $Revision: 1.8 $ $Date: 2002/04/14 23:59:53 $

errstr = '';
P = [];
f = [];

order = valueArray{1};
nfft  = valueArray{2};
evalStr = '[P,f] = pmcov(x,order,nfft,Fs);';

err = 0;
eval(evalStr,'err = 1;')
if err,
    errstr = {'Sorry, couldn''t evaluate pmcov; error message:'
               lasterr };
    return
end

[P,f] = svextrap(P,f,nfft);

