function [u,t] = gensig(type,tau,Tf,Ts)
%GENSIG  Periodic signal generator for time response simulations with LSIM.
%
%      [U,T] = GENSIG(TYPE,TAU)  generates a scalar signal U of class TYPE
%      and period TAU.  The following classes are supported:
%            TYPE = 'sin'        ---   sine wave
%            TYPE = 'square'     ---   square wave
%            TYPE = 'pulse'      ---   periodic pulse
%      GENSIG returns a vector T of time samples and the vector U of signal
%      values at these samples.  All generated signals have unit amplitude.
%
%      [U,T] = GENSIG(TYPE,TAU,TF,TS)  further specifies the time duration TF
%      of the signal and the spacing TS of the time samples in T.
%
%      See also  LSIM, SQUARE, SAWTOOTH.

%       Author(s): P. Gahinet, 5-14-95.
%       Copyright 1986-2002 The MathWorks, Inc. 
%       $Revision: 1.10 $

ni = nargin;
error(nargchk(2,4,ni))
if ~isstr(type),
   error('Signal TYPE must be a string.');
end
type = lower(type);

% Defaults
if ni<3 | isempty(Tf),
   % Default duration is 5 periods
   Tf = 5*tau;
end
if ni<4,
   % Default sampling is 64 = 2^6 samples per period
   Ts = tau/64;
end

% Generate t vector
t = (0:Ts:Tf)';

% Branch over various types
switch type(1:2)
case 'si'
   u = sin((2*pi/tau)*t);
case 'sq'
   u = +(rem(t,tau)>=tau/2);
case 'pu'
   u = +(rem(t,tau)<(1-1000*eps)*Ts);
end

% end gensig.m
