function varargout = stepz(b,a,N,Fs)
%STEPZ  Digital filter step response.
%   [S,T] = STEPZ(B,A) computes the step response of the filter B/A, choosing
%   the number of samples for you, and returns it in vector S.  The vector of
%   time samples at which S is evaluated is returned in vector T.
%
%   [H,T] = STEPZ(B,A,N) computes the first N samples of the step
%   response.
%
%   [H,T] = STEPZ(B,A,N,Fs) separates the time samples by T = 1/Fs.
%   Fs is assumed to be in Hz.
%
%   STEPZ(...) with no output arguments plots the step response.
%
%   EXAMPLE:
%     [b,a] = butter(3,.4);
%     stepz(b,a)
%
%   See also IMPZ, FREQZ, ZPLANE, GRPDELAY.

%   Author(s): R. Losada, J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.6 $ $Date: 2002/08/26 19:43:43 $

error(nargchk(1,4,nargin));
if nargin<2, a=1;   end
if nargin<3, N=[];  end
if nargin<4, Fs=[]; end

if isempty(N), 
    N=impzlength(b,a);
end
if isempty(Fs), 
    Fs = 1; 
    xlbl = 'n (samples)';
else
    xlbl = 'nT (seconds)';
end

% Form time vector
t = (0:N-1)'./Fs;

% Form input vector
x = ones(size(t));

s = filter(b,a,x);

if nargout,
    varargout = {s,t};
else
    timezplot(t,s,Fs,'Step');
end

% [EOF]
