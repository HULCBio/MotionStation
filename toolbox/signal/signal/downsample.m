function y = downsample(x,N,varargin)
%DOWNSAMPLE Downsample input signal.
%   DOWNSAMPLE(X,N) downsamples input signal X by keeping every
%   N-th sample starting with the first. If X is a matrix, the
%   downsampling is done along the columns of X.
%
%   DOWNSAMPLE(X,N,PHASE) specifies an optional sample offset.
%   PHASE must be an integer in the range [0, N-1].
%
%   See also UPSAMPLE, UPFIRDN, INTERP, DECIMATE, RESAMPLE.

%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/15 01:16:49 $

y = updownsample(x,N,'Down',varargin{:});

% [EOF] 
