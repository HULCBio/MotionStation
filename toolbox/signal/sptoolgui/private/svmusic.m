function [errstr,P,f] = svmusic(x,Fs,valueArray)
%SVMUSIC spectview Wrapper for MUSIC method.
%  [errstr,P,f] = svmusic(x,Fs,valueArray) computes the power spectrum P
%  at frequencies f using the parameters passed in via valueArray:
%
%   valueArray entry     Description
%    ------------         ----------
%          1                Signal Subspace dimension
%          2                Threshold
%          3                Nfft
%          4                Nwind
%          5                Window - integer
%                           index into        
%                   {'bartlett' 'blackman' 'boxcar' 'chebwin' ...
%                       'hamming' 'hanning' 'kaiser' 'triang'}
%          6                Window parameter (for chebwin and kaiser)
%          7                overlap - integer
%          8                Correlation matrix checkbox
%          9                Eigenvector weights checkbox

%   Copyright 1988-2002 The MathWorks, Inc.
% $Revision: 1.8 $

errstr = '';
P = [];
f = [];

sdim = valueArray{1};
thres = valueArray{2};
nfft = valueArray{3};
noverlap = valueArray{7};

windowList = {'bartlett' 'blackman' 'boxcar' 'chebwin' ...
              'hamming' 'hanning' 'kaiser' 'triang'};

switch valueArray{5}
case {4,7}
    windStr = ...
    'window = feval(windowList{valueArray{5}},valueArray{4},valueArray{6});';
otherwise
    windStr = 'window = feval(windowList{valueArray{5}},valueArray{4});';
end

err = 0;
eval(windStr,'err = 1;')
if err
    errstr = {'Sorry, couldn''t evaluate window function; error message:'
               lasterr };
    return
end

if valueArray{8} == 1
    corrStr = ',''corr''';
else
    corrStr = '';
end
if valueArray{9} == 1
    evStr = ',''ev''';
else
    evStr = '';
end

evalStr = ['[P,f] = pmusic(x,[sdim thres],nfft,Fs,window,noverlap' corrStr evStr ');'];

err = 0;
eval(evalStr,'err = 1;')
if err
    errstr = {'Sorry, couldn''t evaluate pmusic; error message:'
               lasterr };
    return
end

[P,f] = svextrap(P,f,nfft);

