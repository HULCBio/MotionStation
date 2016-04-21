function varargout = zerophase(Hq,varargin)
%ZEROPHASE Quantized filter Z-transform zero-phase response.
%   [Hr,W] = zerophase(Hq,N) returns length N zero-phase response 
%   vector Hr and the frequency vector W in radians/sample of the
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
%   [Hr,W,CPhi] = ZEROPHASE(Hq,N,'whole') uses N points around the whole unit
%   circle. It also returns the continuous phase response CPhi.
%
%   [...] = ZEROPHASE(Hq,W) returns the zero-phase response at frequencies
%   designated in the vector W, in radians/sample (normally between 0
%   and pi).
%
%   [...] = ZEROPHASE(Hq,N,Fs) and [Hr,F] = FREQZ(Hq,N,'whole',Fs) given a
%   sampling frequency Fs in Hz, return a frequency vector F in Hz.
%   
%   [...] = ZEROPHASE(Hq,F,Fs) returns the zero-phase response at the
%   frequencies designated in the vector F, in Hz.
%
%   [Hr,W,CPhi,Href] = ZEROPHASE(Hq,...) or [Hr,F,CPhi,Href,CPhiref] = ZEROPHASE(Hq,...)
%   returns the zero-phase response vector Href and the continuous phase 
%   response vector CPhiref calculated from the unquantized reference 
%   coefficients in Hq.
%
%   ZEROPHASE(Hq,...) with no output arguments plots the magnitude and
%   continuous phase of the filter in the current figure window.
%
%   For additional parameters, see SIGNAL/ZEROPHASE.
%
%   Example:
%     [b,a] = butter(3,.4);
%     Hq = qfilt('df2t',{b,a});
%     zerophase(Hq)
%
%   See also QFILT, QFILT/FREQZ, QFILT/NLM, FVTOOL.

%   Author: V. Pellissier
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/04/20 21:19:21 $

[bq,aq,br,ar] = qfilt2tf(Hq);

wa=warning;
warning off signal:zerophase:syntaxChanged

[h,w,cphi] = zerophase(bq,aq,varargin{:});
[hr,w,cphir,opts] = zerophase(br,ar,varargin{:});

warning(wa);

% Parse outputs
if nargout,
	varargout = {h,w,cphi,hr,cphir,opts};
else,
    zerophaseplot([h(:) hr(:)],w);
end


%--------------------------------------------------------------------------------------------
function zerophaseplot(h,w)

s.xunits  = 'rad/sample'; 
s.yunits  = 'db';
s.plot    = 'mag';
s.fvflag  = 0;
s.yphase  = 'degrees';

freqzplot(h ,w(:), s, 'zerophase');
legend('Quantized response','Reference response',0)

    
% [EOF]
