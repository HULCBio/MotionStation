function varargout = phasedelay(b,a,varargin)
%PHASEDELAY Phase delay of a digital filter.
%   [PHI,W] = PHASEDELAY(B,A,N) returns the N-point phase delay response
%   vector PHI and the N-point frequency vector W in radians/sample of
%   the filter:
%               jw               -jw              -jmw 
%        jw  B(e)    b(1) + b(2)e + .... + b(m+1)e
%     H(e) = ---- = ------------------------------------
%               jw               -jw              -jnw
%            A(e)    a(1) + a(2)e + .... + a(n+1)e
%   given numerator and denominator coefficients in vectors B and A. The
%   phase response is evaluated at N points equally spaced around the
%   upper half of the unit circle. If N isn't specified, it defaults to
%   512.
%
%   [PHI,W] = PHASEDELAY(B,A,N,'whole') uses N points around the whole unit circle.
%
%   PHI = PHASEDELAY(B,A,W) returns the phase delay response at frequencies 
%   designated in vector W, in radians/sample (normally between 0 and pi).
%
%   [PHI,F] = PHASEDELAY(B,A,N,Fs) and [PHI,F] = PHASEDELAY(B,A,N,'whole',Fs) return 
%   phase delay vector F (in Hz), where Fs is the sampling frequency (in Hz).
%   
%   PHI = PHASEDELAY(B,A,F,Fs) returns the phase delay response at the 
%   frequencies designated in vector F (in Hz), where Fs is the sampling 
%   frequency (in Hz).
%
%   PHASEDELAY(B,A,...) with no output arguments plots the phase delay response of
%   the filter in the current figure window.
%
%   EXAMPLE #1:
%     b=fircls1(54,.3,.02,.008);
%     phasedelay(b)
%
%   EXAMPLE #2:
%     [b,a] = ellip(10,.5,20,.4);
%     phasedelay(b,a,512,'whole')
%
%   See also FREQZ, PHASEZ, ZEROPHASE, GRPDELAY and FVTOOL.

%   Author(s): V.Pellissier, R. Losada
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.2.4.3 $  $Date: 2004/04/13 00:18:11 $ 

error(nargchk(1,5,nargin));

if nargin == 1, 
   a = 1; % Assume FIR
end

if nargin <= 2,
   varargin = {};
end

[phi,w,s] = phasez(b,a,varargin{:});

% Compute the correct frequency vector to divide by
if strcmpi(s.xunits,'rad/sample'),
    wdiv = w;
else
    wdiv = 2*pi*w/s.Fs;
end

phd = dividenowarn(-phi,wdiv);

% Parse outputs
switch nargout,
case 0,
    % Plot when no output arguments are given
    phasedelayplot(phd,w,s);
case 1,
    varargout = {phd};
case 2,
    varargout = {phd,w};
case 3,
    varargout = {phd,w,s};
end


%-------------------------------------------------------------------------------
function phasedelayplot(phd,w,s)

% Cell array of the standard frequency units strings (used for the Xlabels)
frequnitstrs = getfrequnitstrs;
switch lower(s.xunits),
case 'rad/sample',
    xlab = frequnitstrs{1};
    w    = w./pi; % Scale by pi in the plot
case 'hz',
    xlab = frequnitstrs{2}; 
case 'khz',
    xlab = frequnitstrs{3};
case 'mhz',
    xlab = frequnitstrs{4}; 
case 'ghz',
    xlab = frequnitstrs{5};
otherwise
    xlab = s.xunits;
end

plot(w,phd);
xlabel(xlab);
ylabel('Phase delay (samples)');
grid on;

% [EOF]
