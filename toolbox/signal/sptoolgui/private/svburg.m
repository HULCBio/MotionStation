function [errstr,P,f] = svburg(x,Fs,valueArray)
%SVBURG spectview Wrapper for Burg method.
%  [errstr,P,f] = SVBURG(x,Fs,valueArray) computes the power spectrum P
%  at frequencies f using the parameters passed in via valueArray:
%
%   valueArray entry     Description
%    ------------         ----------
%          1                Order
%          2                Nfft

%   Copyright 1988-2002 The MathWorks, Inc.
% $Revision: 1.8 $

errstr = '';
P = [];
f = [];

order = valueArray{1};
nfft  = valueArray{2};
evalStr = '[P,f] = pburg(x,order,nfft,Fs);';

err = 0;
eval(evalStr,'err = 1;')
if err,
    errstr = {'Sorry, couldn''t evaluate pburg; error message:'
               lasterr };
    return
end

[P,f] = svextrap(P,f,nfft);

