function varargout = phasez(Hq,varargin)
%PHASEZ Quantized filter Z-transform phase response.
%   [PHI,W] = PHASEZ(Hq,N) returns the N-point phase response
%   vector PHI and the N-point frequency vector W in radians/sample of the
%   transfer function:
%
%               jw               -jw              -jmw 
%        jw  B(e)    b(1) + b(2)e + .... + b(m+1)e
%     H(e) = ---- = ------------------------------------
%               jw               -jw              -jnw
%            A(e)    a(1) + a(2)e + .... + a(n+1)e
%
%   The numerator and denominator coefficients in B and A are calculated
%   from the quantized coefficients and filter structure information
%   associated with the quantized filter Hq. The phase response is
%   evaluated at N points equally spaced around the upper half of the
%   unit circle. If N isn't specified, it defaults to 512.
%
%   [PHI,W] = PHASEZ(Hq,N,'whole') uses N points around the whole unit
%   circle.
%
%   PHI = PHASEZ(Hq,W) returns the phase response at frequencies
%   designated in the vector W, in radians/sample (normally between 0
%   and pi).
%
%   [PHI,F] = PHASEZ(Hq,N,Fs) and [PHI,F] = PHASEZ(Hq,N,'whole',Fs) given a
%   sampling frequency Fs in Hz, return a frequency vector F in Hz.
%   
%   PHI = PHASEZ(Hq,F,Fs) returns the phase response at the
%   frequencies designated in the vector F, in Hz.
%
%   [PHI,W,S,PHIR] = PHASEZ(Hq,...) or [PHI,F,S,PHIR] = PHASEZ(Hq,...) 
%   returns a structure S and the phase response vector PHIR
%   calculated from the unquantized reference coefficients in Hq.  S is
%   a structure whose fields can be altered to obtain different
%   phase response plots. 
%
%   PHASEZ(Hq,...) with no output arguments plots the  unwrapped phase
%   of the filter in the current figure window.
%
%   Example:
%     [b,a] = butter(3,.4);
%     Hq = qfilt('df2t',{b,a});
%     phasez(Hq)
%
%   See also QFILT, QFILT/FREQZ, QFILT/NLM, FVTOOL. 

%   Author: V. Pellissier
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/14 15:32:20 $

[bq,aq,br,ar] = qfilt2tf(Hq);
[phi,w,s] = phasez(bq,aq,varargin{:});
phir = phasez(br,ar,varargin{:});

% Parse outputs
switch nargout,
case 0,
    s.plot = 'phase';
    h(:,:,2) = phi;
    hr(:,:,2) = phir;
    phaseplot(h,w,s,hr);
case 1,
	varargout = {phi};
case 2,
	varargout = {phi,w};
case 3,
	varargout = {phi,w,s};
case 4,
	varargout = {phi,w,s,phir};
end

%--------------------------------------------------------------------------------------------
function phaseplot(h,w,units,hr)

freqzplot([h hr],w(:),units, 'magphase');
legend('Quantized response','Reference response',0)
  
% [EOF]
