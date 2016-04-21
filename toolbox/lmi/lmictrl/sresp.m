% resp = sresp(sys,f)
%                                      -1
% Returns the response  D + C (j*f*E-A)  B  of a system
% SYS at the frequency f.  The realization (A,B,C,D,E)
% of SYS should be specified with LTISYS.
%
% See also  LTISYS.

% Author: P. Gahinet  6/94
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $

function resp = sresp(sys,f)

if nargin~=2,
  error('usage:  resp = sresp(sys,f)');
elseif ~islsys(sys),
  error('SYS must be a SYSTEM matrix');
end

[a,b,c,d,e]=ltiss(sys);
resp=d+c/(sqrt(-1)*f*e-a)*b;
