% sysinv = sinv(sys)
%
% Computes the inverse of the system of realization SYS.
% If G(s) is the transfer function of SYS, the inverse
% system has transfer function
%                     -1
%                 G(s)
%
%
% See also   LTISYS, SADD, SMULT, SSUB.

% Author: P. Gahinet  6/94
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $

function sys=sinv(sys1)

if ~islsys(sys1), error('SYS must be a SYSTEM matrix'); end

[a,b,c,d,e]=sxtrct(sys1);
[rd,cd]=size(d);

if isempty(d),
   error('This system has no input nor output');
elseif rd~=cd,
   error('The feedthrough matrix of SYS must be square and invertible');
elseif cond(d) > .01/mach_eps,
   error('The feedthrough matrix of SYS must be invertible');
end


if rd==1,
  if isempty(a),
     sys=ltisys([],[],[],inv(d));
  else
     [num,den]=ss2tf(e\a,e\b,c,d);
     sys=sbalanc(ltisys('tf',den,num));
  end
else
  d=inv(d);
  a=a-b*d*c;
  b=b*d;
  c=-d*c;
  sys=sbalanc(ltisys(a,b,c,d,e));
end
