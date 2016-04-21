function varargout = impz(b,a,N,Fs)
%IMPZ Impulse response of digital filter
%   [H,T] = IMPZ(B,A) computes the impulse response of the filter B/A 
%   choosing the number of samples for you, and returns the response in 
%   column vector H and a vector of times (or sample intervals) in T 
%   (T = [0 1 2 ...]').
%
%   [H,T] = IMPZ(B,A,N) computes N samples of the impulse response.
%   If N is a vector of integers, the impulse response is computed
%   only at those integer values (0 is the origin).
%
%   [H,T] = IMPZ(B,A,N,Fs) computes N samples and scales T so that
%   samples are spaced 1/Fs units apart.  Fs is 1 by default.
%
%   [H,T] = IMPZ(B,A,[],Fs) chooses the number of samples for you and scales
%   T so that samples are spaced 1/Fs units apart.
%
%   IMPZ with no output arguments plots the impulse response using
%   STEM(T,H) in the current figure window.
%
%   See also IMPULSE in the Controls Toolbox for continuous systems.

%   Author(s): T. Krauss, 7-27-93
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.13 $  $Date: 2002/08/26 19:43:32 $

error(nargchk(1,4,nargin))
if nargin < 2, a = 1;  end
if nargin < 4, Fs = 1; end

M = 0;  NN = [];
if nargin<=4
    if nargin<3, N=[]; end
    if isempty(N),
        % if not specified, determine the length 
        N = impzlength(b,a,.00005);
    elseif length(N)>1    % vector of indices
        NN = round(N);
        N = max(NN)+1;
        M = min(min(NN),0);   
    end
end

t = (M:(N-1))';
h = filter(b,a,double(t==0));
if ~isempty(NN),
    h = h(NN-M+1);
    t = t(NN-M+1);
end
t = t/Fs;

if nargout,
    varargout = {h, t};
else    
    timezplot(t,h,Fs,'Impulse');
end

% [EOF]
