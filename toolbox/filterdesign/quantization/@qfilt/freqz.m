function [hh,w,units,hr] = freqz(Hq,varargin)
%FREQZ Quantized filter Z-transform frequency response.
%   [H,W] = FREQZ(Hq,N) returns the N-point complex frequency response
%   vector H and the N-point frequency vector W in radians/sample of the
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
%   associated with the quantized filter Hq. The frequency response is
%   evaluated at N points equally spaced around the upper half of the
%   unit circle. If N isn't specified, it defaults to 512.
%
%   [H,W] = FREQZ(Hq,N,'whole') uses N points around the whole unit
%   circle.
%
%   H = FREQZ(Hq,W) returns the frequency response at frequencies
%   designated in the vector W, in radians/sample (normally between 0
%   and pi).
%
%   [H,F] = FREQZ(Hq,N,Fs) and [H,F] = FREQZ(Hq,N,'whole',Fs) given a
%   sampling frequency Fs in Hz, return a frequency vector F in Hz.
%   
%   H = FREQZ(Hq,F,Fs) returns the complex frequency response at the
%   frequencies designated in the vector F, in Hz.
%
%   [H,W,S,Hr] = FREQZ(Hq,...) or [H,F,S,Hr] = FREQZ(Hq,...) also
%   returns a structure S and the frequency response vector Hr
%   calculated from the unquantized reference coefficients in Hq.  S is
%   a structure whose fields can be altered to obtain different
%   frequency response plots.  For more information see the help for
%   FREQZPLOT.
%
%   FREQZ(Hq,...) with no output arguments plots the magnitude and
%   unwrapped phase of the filter in the current figure window.
%
%   The only quantization effects accounted for in FREQZ are from the
%   quantized coefficients.  The quantization effects of the arithmetic
%   in the filter are ignored.  See QFILT/NLM for information on the
%   Noise Loading Method of estimating the frequency response that takes
%   into account the arithmetic in the filter.
%
%   Example:
%     [b,a] = butter(3,.4);
%     Hq = qfilt('df2t',{b,a});
%     freqz(Hq)
%
%   See also QFILT, QFILT/FILTER, QFILT/QFILT2TF, QFILT/NLM.

%   Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.22 $  $Date: 2002/11/21 15:51:23 $

[bq,aq,br,ar] = qfilt2tf(Hq);
[h,w,units] = freqz(bq,aq,varargin{:});
hr = freqz(br,ar,varargin{:});

if nargout==0
   freqzplot([h(:) hr(:)],w(:),units)
   subplot(211);
   legend('Quantized response','Reference response',0)
   
   % Zoom axes together
   ax = zeros(2,1);
   ax(1) = subplot(211);
   ax(2) = subplot(212);
   pmzoom(ax)
   zoom off

   % Resets the figure so that next plot does not subplot
   if ~ishold,
      set(gcf,'nextplot','replace');      
   end      
else
   hh=h;
end
