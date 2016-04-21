function [errstr,P,f] = svcov(x,Fs,valueArray)
%SVCOV spectview Wrapper for Covariance method.
%  [errstr,P,f] = SVCOV(x,Fs,valueArray) computes the power spectrum P
%  at frequencies f using the parameters passed in via valueArray:
%
%   valueArray entry     Description
%    ------------         ----------
%          1                Order
%          2                Nfft

%   Copyright 1988-2002 The MathWorks, Inc.
% $Revision: 1.8 $ $Date: 2002/04/15 00:00:04 $

errstr = '';
P = [];
f = [];

order = valueArray{1};
nfft  = valueArray{2};
evalStr = '[P,f] = pcov(x,order,nfft,Fs);';

err = 0;
eval(evalStr,'err = 1;')
if err,
    errstr = {'Sorry, couldn''t evaluate pcov; error message:'
               lasterr };
    return
end

[P,f] = svextrap(P,f,nfft);

