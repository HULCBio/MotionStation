% poles = spol(sys)
%
% Returns the poles of the system SYS
%
% See also  LTISYS.

% Author: P. Gahinet  6/94
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $

function poles = spol(sys)

[a,b,c,d,e]=ltiss(sys);
if max(max(abs(e-eye(size(e))))) > 0,
   poles=eig(a,e);
else
   poles=eig(a);
end
