% function syshat = sfrwtbld(sys,wt1,wt2)
%
%   Calculate the stable part of (WT1~)*SYS*(WT2~)
%   The routine is used with SFRWTBAL to obtain a possible
%   SYSHAT as follows:
%
%    >>[sys1,sig1] = sfrwtbal(sys,wt1,wt2);
%    >>sys1hat = strunc(sys1,k)
%   or
%    >>sys1hat = hankmr(sys1,sig1,k)
%    >>syshat = sfrwtbld(sys1hat,wt1,wt2);
%
%   The resulting error can be assessed with a direct frequency
%   response calculation.
%
%   See also: HANKMR, SDECOMP, SFRWTBAL, SNCFBAL, SRELBAL, SYSBAL,
%             SRESID, and TRUNC.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $


function syshat=sfrwtbld(sys1hat,wt1,wt2);

% initial consistency checks.
if nargin <2
  disp('usage: syshat = sfrwtbld(sys,wt1,wt2);')
   return
end

[systype,p,m,n]= minfo(sys1hat);
if nargin==2, wt2=eye(m); end
[wt1type,p1,m1,n1]= minfo(wt1);
[wt2type,p2,m2,n2]= minfo(wt2);
if m1~=p1 | m1~=p
  error('WT1 should be square compatible with SYS')
  return
end
if m2~=p2 | m2~=m
  error('WT2 should be square compatible with SYS')
  return
end

syshat = sdecomp(mmult(cjt(wt1),mmult(sys1hat,cjt(wt2))));
%
%