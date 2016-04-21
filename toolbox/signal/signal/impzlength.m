function N = impzlength(b,a, tol)
%IMPZLENGTH Length of the impulse response for a digital filter.
%   IMPZLENGTH(B,A) returns the length of the impulse response of 
%   the filter defined in vectors B and A. 
%
%   IMPZLENGTH(B,A,TOL) will specify the tolerance for greater or 
%   less accuracy.  By default, TOL = 5e-5.
%
%   See also IMPZ.

%   Author(s): P. Costa
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/04/15 01:18:30 $

error(nargchk(2,3,nargin))
if nargin < 3, tol = .00005; end

% Determine if filter is FIR
% FIR Filter Case
if signalpolyutils('isfir',b,a),
    N = length(b);
else
    indx=min(find(b~=0));
    if isempty(indx),
        delay = 0;
    else
        delay=indx-1;
    end
    p = roots(a);
    if any(abs(p)>1.0001),
        N = unstable_length(p);
    else
        N = stableNmarginal_length(p,tol,delay);
    end  
    N = max(length(a)+length(b)-1,N);
    
    % Always return an integer length
    N = floor(N);
end

%-------------------------------------------------------------------------
function N = unstable_length(p)
% Determine the length for an unstable filter
ind = find(abs(p)>1);
N = 6/log10(max(abs(p(ind))));% 1000000 times original amplitude


%-------------------------------------------------------------------------
function N = stableNmarginal_length(p,tol,delay)
% Determine the length for an unstable filter

%minimum height is .00005 original amplitude:
ind = find(abs(p-1)<1e-5);
p(ind) = -p(ind);    % treat constant as Nyquist
ind = find(abs(abs(p)-1)<1e-5);       
periods = 5*max(2*pi./abs(angle(p(ind)))); % five periods
p(ind) = [];   % get rid of unit circle poles
[maxp,maxind] = max(abs(p));
if isempty(p)   % pure oscillator
    N = periods;
elseif isempty(ind)   % no oscillation
    N = mltplcty(p,maxind)*log10(tol)/log10(maxp) + delay;
else    % some of both
    N = max(periods, ...
        mltplcty(p,maxind)*log10(tol)/log10(maxp) ) + delay;
end


%-------------------------------------------------------------------------
function m = mltplcty( p, ind, tol)
%MLTPLCTY  Multiplicity of a pole
%   MLTPLCTY(P,IND,TOL) finds the multiplicity of P(IND) in the vector P
%   with a tolerance of TOL.  TOL defaults to .001.

if nargin<3
    tol = .001;
end

[mults,indx]=mpoles(p,tol);

m = mults(indx(ind));
for i=indx(ind)+1:length(mults)
    if mults(i)>m
        m = m + 1;
    else
        break;
    end
end

% [EOF]
