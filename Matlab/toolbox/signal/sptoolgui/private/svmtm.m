function [errstr,P,f,Pc] = svmtm(x,Fs,valueArray,confidenceLevel)
%SVMTM spectview Wrapper for Multiple-Taper method.
%  [errstr,P,f] = svmtm(x,Fs,valueArray) computes the power spectrum P
%  at frequencies f using the parameters passed in via valueArray:
%
%   valueArray entry     Description
%    ------------         ----------
%          1                NW
%          2                Nfft
%          3                Weights - integer
%                           index into  {'adapt' 'unity' 'eigen'}      
%
%  [errstr,P,f,Pc] = svmtm(x,Fs,valueArray,confidenceLevel) also computes
%   the confidence interval Pc.

%   Copyright 1988-2002 The MathWorks, Inc.
% $Revision: 1.8 $

errstr = '';
P = [];
f = [];
Pc = [];

nw = valueArray{1};
nfft = valueArray{2};

switch valueArray{3}
case 1
    wflag = 'adapt';
case 2
    wflag = 'unity';
case 3
    wflag = 'eigen';
end

if nargin == 3
    evalStr = '[P,f] = pmtm(x,nw,nfft,Fs,wflag);';
else
    evalStr = '[P,Pc,f] = pmtm(x,nw,nfft,Fs,wflag,confidenceLevel);';
end

err = 0;
eval(evalStr,'err = 1;')
if err
    errstr = {'Sorry, couldn''t evaluate pmtm; error message:'
               lasterr };
    return
end

if nargin == 3
    [P,f] = svextrap(P,f,nfft);
else
    [P,f,Pc] = svextrap(P,f,nfft,Pc);
end

