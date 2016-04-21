% [a,b1,b2,c1,c2,d11,d12,d21,d22]=hinfpar(P,r)
% data = hinfpar(P,r,string)
%
% Unpacks the standard H-infinity plant
%
%                    |  a   b1   b2 |
%             P  =   | c1  d11  d12 |
%                    | c2  d21  d22 |
%
% and returns its state-space matrices  a,b1,b2,...
% The 2x1 vector R  specifies the size of D22,  that is,
% R = [ NY , NU ]  where
%     NY = # of measurements,      NU = # of controls.
% P must have been created with LTISYS.
%
% To obtain one particular state-space matrix (e.g., c1),
% set the third argument to one of the strings 'a','b1','b2',...
% For instance,    c1 = hinfpar(P,r,'c1')
%
% See also  LTISYS, LTISS.

% Author: P. Gahinet  10/93
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $

function [a,b1,b2,c1,c2,d11,d12,d21,d22]=hinfpar(sys,r,string)

[rp,cp]=size(sys);
if nargin<2,
  error('usage: [a,b1,b2,c1,c2,d11,d12,d21,d22]=hinfpar(sys,r)');
elseif ~isinf(sys(rp,cp)),
  error('P is not a system in packed form');
end

na=sys(1,cp);
p2=r(1); m2=r(2);
p1=rp-(na+p2)-1; m1=cp-(na+m2)-1;
if m1<0 | p1<0,
  error('D11 has negative dimensions according to the dimensions R of D22');
end

if nargin==2,
  [a,b1,c1,d11]=ltiss(sys);
  b2=b1(:,m1+1:m1+m2);  b1=b1(:,1:m1);
  c2=c1(p1+1:p1+p2,:); c1=c1(1:p1,:);
  d12=d11(1:p1,m1+1:m1+m2);   d21=d11(p1+1:p1+p2,1:m1);
  d22=d11(p1+1:p1+p2,m1+1:m1+m2);  d11=d11(1:p1,1:m1);
else
  a=sys(1:na,1:na); e=imag(a)+eye(na); a=real(a);
  if strcmp(string,'a'),
    a=e\a;
  elseif strcmp(string,'b1'),
    a=e\sys(1:na,na+(1:m1));
  elseif strcmp(string,'b2'),
    a=e\sys(1:na,na+m1+(1:m2));
  elseif strcmp(string,'c1'),
    a=sys(na+(1:p1),1:na);
  elseif strcmp(string,'c2'),
    a=sys(na+p1+(1:p2),1:na);
  elseif strcmp(string,'d11'),
    a=sys(na+(1:p1),na+(1:m1));
  elseif strcmp(string,'d12'),
    a=sys(na+(1:p1),na+m1+(1:m2));
  elseif strcmp(string,'d21'),
    a=sys(na+p1+(1:p2),na+(1:m1));
  elseif strcmp(string,'d22'),
    a=sys(na+p1+(1:p2),na+m1+(1:m2));
  end
end
