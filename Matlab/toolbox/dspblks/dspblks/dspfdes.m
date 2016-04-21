function [a,b,c,d,h,w,s]=dspfdes(method,type,N,Wlo,Whi,Rp,Rs,Ts)
%DSPFDES Signal Processing Blockset filter design interface
% Usage:
%    [a,b,c,d,h,w,s]=dspfdes(method,type,N,Wlo,Whi,Rp,Rs,Ts);
% where:
%  a,b,c,d: State-space coefficients of filter.  Note that
%           for Classical FIR, only b is non-empty.
%        h: magnitude frequency response
%           of designed filter (for icon only)
%        w: normalized frequencies corresponding to indices of h (for icon only)
%        s: name of design function called (for icon only)
%
% If Ts is not passed, an analog filter is designed.


% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.8.4.2 $ $Date: 2004/04/12 23:05:16 $

% Defaults for return:
a=[]; b=[]; c=[]; d=[]; h=[]; w=[]; s='';



% Determine if design will be digital or analog:
analog=0;
if nargin==7,
  Ts=-1; analog=1;
elseif nargin~=8,
  error('Incorrect number of input arguments.');
end


% Default LHS for filter designs:
lhs='[a,b,c,d]';



switch method
case 'Classical FIR'
  if analog,
    error('Classical FIR is not a valid choice for analog filter designs. ');
  end
  m={'fir1',N};
  lhs='b';  % Override LHS for FIR1 (not a state-space design)


case 'Butterworth'
  m={'butter',N};
case 'Chebyshev I'
  m={'cheby1',N,Rp};
case 'Chebyshev II'
  m={'cheby2',N,Rs};
case 'Elliptic'
  m={'ellip',N,Rp,Rs};
otherwise,
  error('Unknown filter method selected');
end

switch type
case 'Lowpass',
  t={m{:},Wlo};
case 'Highpass',
  t={m{:},Wlo,'high'};
case 'Bandpass',
  t={m{:},[Wlo Whi]};
case 'Bandstop',
  t={m{:},[Wlo Whi],'stop'};
otherwise,
  error('Unknown filter type selected.');
end

if analog,
  t={t{:},'s'};
end

% Return filter design coefficients:
s=[lhs '=feval(t{:});'];
eval(s);

% Return name for icon
s=m{1};



% Compute frequency response for icon
% Recompute state-space form for digital
%   filters as required:
if analog,
  % Analog filters:
  [num,den]=ss2tf(a,b,c,d,1);
  switch type
  case {'Lowpass','Highpass'},
    ww=Wlo;
  otherwise,
    ww=sqrt(Wlo*Whi);
  end

  [h,w]=freqs(num,den,logspace(log10(ww/10),log10(10*ww),60));
  h=20*log10(abs(h));
  h=h-min(h); h=h./(max(h)+eps)*.75;

  w=20*log10(w);
  w=w-min(w); w=w./max(w);  % normalize to [0,1]

else
  % Digital filters:

  switch method
  case 'Classical FIR',
    h=abs(freqz(b,1,64));

  otherwise,
    [num,den]=ss2tf(a,b,c,d);
    h=abs(freqz(num,den,64));
    if N<=8,
      [a,b,c,d]=tf2ss(num,den);
    end
  end

  % Scale icon for display:
  h=h./max(h)*0.75;  % Scaled for icon
  w = (0:63)/63;  % normalize to [0,1]
end
