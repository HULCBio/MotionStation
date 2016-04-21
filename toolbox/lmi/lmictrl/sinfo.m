% [ns,ni,no] = sinfo(sys)
%
% Returns the number of states, inputs, and outputs of the
% system SYS
%
% Input:
%   SYS        system state-space data in packed form
%              (see LTISYS)
% Output:
%   NS,NI,NO   number of states, inputs, and outputs of SYS
%
%
% See also  LTISYS, LTISS.

% Author: P. Gahinet  6/94
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $


function [ns,ni,no]=sinfo(sys)

if nargin < 1,
  error('usage: sinfo(sys)');
end

[rs,cs]=size(sys);
if sys(1,1)==-Inf,
  disp(sprintf('Parameter-dependent system. Use PSINFO for more details\n'));
elseif sys(rs,cs)~=-Inf,
  if nargout,
     ns=0; [no,ni]=size(sys);
  else
     disp(sprintf('Not a system!\n'));
  end
else
  na=sys(1,cs);
  ni=cs-na-1;
  no=rs-na-1;
  if nargout==0,
    if isreal(sys),
      disp(sprintf('System with %d state(s), %d input(s), and %d output(s)\n',na,ni,no));
    else
      disp(sprintf('Descriptor system with %d state(s), %d input(s), and %d output(s)\n',na,ni,no));
    end
  else
    ns=na;
  end
end
