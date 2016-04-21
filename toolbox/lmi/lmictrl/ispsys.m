%  bool = ispsys(sys)
%
%  Returns 1 if SYS is a polytopic or parameter-dependent
%  system
%
%  See also  PSYS, PSINFO.

%  Author: P. Gahinet  6/94
%  Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $

function bool = ispsys(sys)


bool=(sys(1,1)==-Inf);
