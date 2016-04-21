function dsys = co2di(csys,alpha)
%  function dsys = co2di(csys,alpha)
%
%   Transforms continuous-time system into a discrete-time
%   system with a bilinear transformation, defined as
%
%                  1     z-1
%           s = ------- -----
%                alpha   z+1
%
%                                                 j
%   Note that the point z=j gets mapped to s = -------
%                                               alpha
%
%   If ALPHA>0, then the right-half plane (for s) is mapped
%   outside the unit disk (for z), preserving the stability
%   characteristics.
%----------------------------------------------------------
%   WARNING: This is (unfortunate choice) not the same
%       transformation as that used in DI2CO.  In DI2CO, the
%       transformation below,
%
%                      z-1
%           s = alpha -----
%                      z+1
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


  [mtype,mrows,mcols,mnum] = minfo(csys);
  if strcmp(mtype,'syst')
    if nargin == 1
      alpha = 1;
    elseif nargin == 2
      if alpha <= 0
        error('ALPHA must be positive')
        return
      end
    end
    fix = [eye(mnum) sqrt(2*alpha)*eye(mnum);...
            sqrt(2*alpha)*eye(mnum) alpha*eye(mnum)];
    dsys = pss2sys(starp(fix,sys2pss(csys),mnum,mnum),mnum);
  elseif strcmp(mtype,'cons')
      dsys = csys;
  elseif strcmp(mtype,'empt')
      dsys = [];
  else
    error('Input variable is not a SYSTEM matrix')
    return
  end