function csys = di2co(dsys,alpha)
% function csys = di2co(dsys,alpha)
%
%   Transforms discrete-time system into a continuous-time
%   system with a bilinear transformation, defined as
%
%                    s + alpha
%           z =  -  -----------
%                    s - alpha
%
%   Note that the point s = j alpha gets mapped to z = j.
%   If ALPHA>0, then the right-half plane (for s) is mapped
%   outside the unit disk (for z), preserving the stability
%   characteristics.
%----------------------------------------------------------
%   WARNING: This is (unfortunate choice) not the same
%       transformation as that used in CO2DI.  In CO2DI, the
%       transformation below,
%
%                    s + (1/alpha)
%           z =  -  --------------
%                    s - (1/alpha)
%
%   is used.  Hence, for any SYSTEM matrix SYS, and any
%   ALPHA, it follows that
%
%       SYS    and    CO2DI(DI2CO(SYS, 1/ALPHA), ALPHA)
%
%   are equal.
%
%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.8.2.3 $


  [mtype,mrows,mcols,mnum] = minfo(dsys);
  if strcmp(mtype,'syst')
    if nargin == 1
      alpha = 1;
    elseif nargin == 2
      if alpha <= 0
        error('ALPHA must be positive')
        return
      end
    end
    fix = [-alpha*eye(mnum) -sqrt(2*alpha)*eye(mnum);...
           -sqrt(2*alpha)*eye(mnum) -eye(mnum)];
%   -----------  the following also works  ------------
%   fix = [-alpha*eye(mnum) sqrt(2*alpha)*eye(mnum);...
%          sqrt(2*alpha)*eye(mnum) -eye(mnum)];
%   ---------------------------------------------------
    csys = pss2sys(starp(fix,sys2pss(dsys),mnum,mnum),mnum);
  elseif strcmp(mtype,'cons')
    csys = dsys;
  else
    error('Input variable is not a SYSTEM matrix')
  end