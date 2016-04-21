function [cg,ph,w] = cgloci(varargin)
%CGLOCI Characteristic Gain/Phase frequency response of continuous systems.
%	CGLOCI(A,B,C,D) or CGLOCI(SS_) produces a Characteristic Gain/Phase
%       Bode plot of the complex matrix
%                                            -1
%                             G(jw) = C(jwI-A) B + D
%	as a function of frequency.  The Char. Gain loci are an extension
%	of Bode magnitude response for MIMO systems.  The frequency range
%	and number of points are chosen automatically.  For square
%	systems, CGLOCI(A,B,C,D,'inv') produces the Char. Gain/Phase of the
%	inverse complex matrix
%	     -1               -1      -1
%           G (jw) = [ C(jwI-A) B + D ]
%
%	CGLOCI(A,B,C,D,W) or CGLOCI(A,B,C,D,W,'inv') uses the user-supplied
%	frequency vector W which must contain the frequencies, in
%	radians/sec, at which the Char. Gain/Phase response is to be
%	evaluated. When invoked with left hand arguments,
%		[CG,PH,W] = CGLOCI(A,B,C,D,...)
%	returns the frequency vector W and the matrices CG, PH with as many
%	columns	as MIN(NU,NY) and length(W) rows, where NU is the number
%	of inputs and NY is the number of outputs.  No plot is drawn on
%	the screen.  The Char. Gain are returned in descending order.
%
%	See also: LOGSPACE,SEMILOGX,NICHOLS,NYQUIST and BODE.

% R. Y. Chiang & M. G. Safonov 6/29/87
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.10.4.3 $
% All Rights Reserved.
nag1=nargin;
if nargin==0, eval('exresp(''cgloci'',1)'), return, end

[emsg,nag1,xsflag,Ts,a,b,c,d,w,invflag]=mkargs5x('ss',varargin); error(emsg);

% discrete case (call DCGLOCI)   
if Ts, 
   [cg,ph,w] = dcgloci(varargin{:},abs(Ts));
   return
end   

% continuous case
if nag1==6,      % Trap call to RCT function
  if ~isstr(invflag)
    eval('[cg,ph] = cgloci2(a,b,c,d,w,invflag);')
    return
  end
  if ~length(invflag)
	nag1 = nag1 - 1;
  end
end

error(nargchk(4,6,nag1));
error(abcdchk(a,b,c,d));

% Detect null systems
if ~(length(d) | (length(b) &  length(c)))
       return;
end

% Determine status of invflag
if nag1==4,
  invflag = [];
  w = [];
elseif (nag1==5)
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
  w=freqint(a,b,c,d,30);
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

s = w * sqrt(-1);
I=eye(length(a));
cgg = zeros(no,length(s));
ph = cgg;
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
  temp=eig(d);
  if ~isempty(invflag)
      temp = 1./temp;
  end
  [cgg1,ind] = sort(abs(temp));
  cgg = cgg1*ones(1,length(s));
  ph(:,i) = 180./pi*imag(log(temp(ind)))*ones(1,length(s));
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
%
% -------------- End of CGLOCI.M % RYC/MGS %

