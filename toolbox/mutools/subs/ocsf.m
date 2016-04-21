% function [u,t]=ocsf(u,a)
%
%  *****  UNTESTED SUBROUTINE  *****
%
% Given a matrix A in complex schur form, OCSF finds
%  T = U'*A*U such that T is A with its eigenvalues
%  rearranged into increasing order of real parts.
%
%  See Also: ORSF

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function [u,t]=ocsf(u,a)
% 1990 version
t=a;
[n,m]=size(a);
if n~=m
  disp('the A matrix is not square')
  return
end;
if any(abs(triu(a',1)))
  disp('A is not in complex schur form')
  return
end
ia=1;id=1;ib=n-1;il=1;
while il~=0,
  il=0;
  for i=ia:id:ib,
    tii=t(i,i);tioio=t(i+1,i+1);
    if real(tii)>real(tioio),
      [s,r]=qr([t(i,i+1);tioio-tii]);
      t(1:i+1,i:i+1)=t(1:i+1,i:i+1)*s;
      t(i:i+1,i:n)=s'*t(i:i+1,i:n);
      u(1:n,i:i+1)=u(1:n,i:i+1)*s;
      t(i:i+1,i:i+1)=[tioio,t(i,i+1);0 tii];
      il=i;
    end;
  end;
  ib=ia;id=-id;ia=il+id;
end;

%
%