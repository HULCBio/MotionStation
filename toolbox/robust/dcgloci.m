function [cg,ph,w] = dcgloci(varargin)
%DCGLOCI Discrete characteristic gain/phase frequency response.
%
%	DCGLOCI(A,B,C,D,Ts) or DCGLOCI(SS_,Ts) produces a Char. Gain/Phase
%       Bode plot of the complex matrix:
%                                                 -1
%                             G(w) = C(exp(jwT)I-A) B + D
%	as a function of frequency.  The Char. Gain/Phase are an extension
%	of the Bode magnitude response for MIMO system.  The frequency
%	range and number of points are chosen automatically.  For square
%	systems, DCGLOCI(A,B,C,D,'inv')	produces the Char. Gain/Phase of
%	the inverse complex matrix
%	                  -1                    -1      -1
%	                 G (w) = [ C(exp(jwT)I-A) B + D ]
%	DCGLOCI(A,B,C,D,Ts,W) or DCGLOCI(A,B,C,D,Ts,W,'inv') use the user-
%	supplied frequency vector W which must contain the frequencies, in
%	radians/sec, at which the Char. Gain/Phase response is to be
%	evaluated. Aliasing will occur at frequencies greater than the
%	Nyquist frequency (pi/Ts).  When invoked with left hand arguments,
%		[CG,PH,W] = DCGLOCI(A,B,C,D,Ts,...)
%	returns the frequency vector W and the matrices CG,PH with
%       MIN(NU,NY) columns and length(W) rows, where NU is the number of
%       inputs and NY is the number of outputs.  No plot is drawn on the
%       screen. The Char. Gain/Phase are returned in descending order.
%
%  See also LOGSPACE, SEMILOGX, DNICHOLS, DNYQUIST and DBODE.

% R. Y. Chiang & M. G. Safonov 6/29/87
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.9.4.3 $
% All Rights Reserved.
nag1=nargin;
if nargin==0, eval('dexresp(''dcgloci'',1)'), return, end

[emsg,nag1,xsflag,Ts,a,b,c,d,Ts,w,invflag]=mkargs5x('ss',varargin); error(emsg);


if nag1==7,		% Trap call to RCT function
  if ~isstr(invflag),
    eval('[cg,ph] = dcgloci2(a,b,c,d,Ts,w,invflag);')
    return
  end
end

error(nargchk(5,7,nag1));
error(abcdchk(a,b,c,d));
if ~(length(d) | (length(b) &  length(c)))
	return;
end

% Determine status of invflag
if nag1==5,
  invflag = [];
  w = [];
elseif (nag1==6)
  if (isstr(w)),
    invflag = w;
    w = [];
    [ny,nu] = size(d);
    if (ny~=nu), error('The state space system must be square when using ''inv''.'); end
  else
    invflag = [];
  end

else
  [ny,nu] = size(d);
    if (ny~=nu), error('The state space system must be square when using ''inv''.'); end
end

% Generate frequency range if one is not specified.

% If frequency vector supplied then use Auto-selection algorithm
% Fifth argument determines precision of the plot.
if ~length(w)
  w=dfrqint(a,b,c,d,Ts,30);
end

[nx,na] = size(a);
[no,ns] = size(c);
nw = max(size(w));

% Balance A
[t,a] = balance(a);
b = t \ b;
c = c * t;

% Reduce A to Hessenberg form:
[p,a] = hess(a);

% Apply similarity transformations from Hessenberg
% reduction to B and C:
b = p' * b;
c = c * p;

s = exp(sqrt(-1)*w*Ts);
I=eye(length(a));
cgg = zeros(no,length(s));
ph= cgg;
if nx > 0,
  for i=1:length(s)
      temp = eig(c*((s(i)*I-a)\b) + d);
      if ~isempty(invflag)
          temp = 1./temp;
      end
      [cgg(:,i),ind] = sort(abs(temp));
      ph(:,i) = 180./pi*imag(log(temp(ind)));
  end
else
  for i=1:length(s)
      temp = eig(d);
      if ~isempty(invflag)
          temp=1./temp;
      end
      [cgg1,ind] = sort(abs(temp));
      cgg = cgg1*ones(1,length(s));
      ph = 180./pi*imag(log(temp(ind)))*ones(1,length(s));
  end
end

cgg = cgg(no:-1:1,:);
ph  = ph(no:-1:1,:);

% If no left hand arguments then plot graph.
if nargout==0
  subplot(2,1,1)
  semilogx(w,20*log10(cgg),w,zeros(1,length(w)),'w:')
  ylabel('Char. Gain - dB')
  subplot(2,1,2)
  semilogx(w,ph,w,zeros(1,length(w)),'w:')
  xlabel('Frequency (rad/sec)')
  ylabel('Char. Phase - deg')
  return % Suppress output
end
cg = cgg;