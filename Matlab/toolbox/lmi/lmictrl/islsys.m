%  bool = islsys(sys)
%
%  Returns 1 if SYS is a SYSTEM matrix

%  Author: P. Gahinet  6/94
%  Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $

function bool = islsys(sys)

sys=sys(:);
bool=(length(find(sys(2:length(sys))==-Inf))==1);
