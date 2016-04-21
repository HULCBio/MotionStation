% like LTISS except that a constant matrix SYS
% is interpreted as the system  [],[],[],SYS
%
% See also  LTISS.

% Author: P. Gahinet  6/94
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $

function [a,b,c,d,e]=sxtrct(P)

[rp,cp]=size(P);

if ~islsys(P),
  a = [];
  b = zeros(0,cp);
  c = zeros(rp,0);
  d = P;
  e = [];
  return
end

na=P(1,cp);
a=P(1:na,1:na); b=real(P(1:na,na+1:cp-1));
c=real(P(na+1:rp-1,1:na)); d=real(P(na+1:rp-1,na+1:cp-1));
e=imag(a);  a=real(a);

if nargout < 5 & max(max(abs(e))) > 0,
  e=e+eye(na);
  a=e\a; b=e\b;
else
  e=e+eye(na);
end
