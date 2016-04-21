% function [sys1,sig1] = sfrwtbal(sys,wt1,wt2);
%
%   Calculates the stable part of MINV(WT1~)*SYS*MINV(wt2~)
%   and then SYS1 is a balanced realization of this, with
%   Hankel singular values SYS1. WT1 and WT2 must be stable
%   and minimum phase, square and of compatible dimensions with
%   SYS.  WT2 has the identity as default value and  SYS must
%   be stable.
%
%   SYS1(k) gives a lower bound on the achievable H-infinity
%   norm of the error MINV(WT1~)*(SYS-SYSHAT)*MINV(WT2~)
%   where SYSHAT is stable of degree K.  The routine is used
%   with SFRWTBLD to obtain a possible SYSHAT as follows:
%
%     >>[sys1,sig1] = sfrwtbal(sys,wt1,wt2);
%     >>sys1hat = strunc(sys1,k);
%   or
%     >>sys1hat = hankmr(sys1,sig1,k);
%     >>syshat = sfrwtbld(sys1hat,wt1,wt2);
%
%   The resulting error can be assessed with a direct frequency
%   response calculation.
%
%   See also: HANKMR, SFRWTBLD, SNCFBAL, SRELBAL, SYSBAL,
%             SRESID, and TRUNC.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

% Based on the algorithm of Latham and Anderson
% Systems and Control Letters, vol 5, 229:236, 1985.


function [sys1,sig1] = sfrwtbal(sys,wt1,wt2);

% initial consistency checks.
if nargin <2,
  disp('usage: [sys1,sig1] = sfrwtbal(sys,wt1,wt2);')
  return
end

[systype,p,m,n] = minfo(sys);
if nargin==2, wt2 = eye(m); end
[wt1type,p1,m1,n1] = minfo(wt1);
[wt2type,p2,m2,n2] = minfo(wt2);

if systype~='syst'
  error('SYS must be a SYSTEM matrix')
  return
end
if wt1type=='vary'
  error('WT1 must  be a SYSTEM or CONSTANT matrix')
  return
end
if wt2type=='vary'
  error('WT2 must  be a SYSTEM or CONSTANT matrix')
  return
end
if m1~=p1 | m1~=p
  error('WT1 should be square compatible with SYS')
  return
end
if m2~=p2 | m2~=m
  error('WT2 should be square compatible with SYS')
  return
end
if any(spoles(sys)>=0)
  error('SYS should be stable')
  return
end
if wt1type=='syst'
  if any(spoles(wt1)>=0)
    error('WT1 should be stable')
    return
  end
  if any(szeros(wt1)>0)
    error('WT1 should be minimum phase')
    return
  end
end %if wt1type==
if wt2type=='syst',
  if any(spoles(wt2)>=0)
    error('WT2 should be stable')
    return
  end
  if any(szeros(wt2)>0)
    error('WT2 should be minimum phase')
    return
  end
 end % if wt2type==
%
wt1=minv(cjt(wt1)); wt2=minv(cjt(wt2));
sys1=sdecomp(mmult(wt1,mmult(sys,wt2)));
[sys1,sig1]=sysbal(sys1);
%
%