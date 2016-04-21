function [errstr,P,f] = svfft(x,Fs,valueArray)
%SVFFT spectview Wrapper for FFT.
%  [errstr,P,f] = svfft(x,Fs,valueArray) computes the power spectrum P
%  at frequencies f using the parameters passed in via valueArray:
%
%   valueArray entry     Description
%    ------------         ----------
%          1                Nfft

% Copyright 1988-2002 The MathWorks, Inc.
% $Revision: 1.9 $ $Date: 2002/04/14 23:59:56 $

errstr = '';
P = [];
f = [];

err = 0;
nfft = valueArray{1};
evalStr = 'P = (abs(fft(x,nfft)).^2)./Fs./nfft; f=(0:nfft-1)''*Fs./nfft;';

eval(evalStr,'err = 1;')
if err
    errstr = {'Sorry, couldn''t evaluate fft; error message:'
               lasterr };
    return
end

[P,f] = sbswitch('svextrap',P,f,nfft);

