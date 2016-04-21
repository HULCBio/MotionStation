function s = rmsfname(block)
%RMSFNAME returns immediate subsystem/block for requirements manager.
%   S = RMSFNAME(BLOCK) Creates a string of the form
%   subsystem/block. There must be at least one slash in BLOCK.
%   For example, 
%      n = 'clutch/Friction Mode Logic/Lockup Detection/Friction Calc/Inertia Ratio';
%      s = reqmgrGetStateflowName(n);
%      Returns 'Friction Calc/Inertia Ratio' in s.
%   Returns: success = 'immediate parent/block';  errors = all thrown.
%   Assumes model is open.

%  Author(s): M. Greenstein, 11/18/98
%  Copyright 1998-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $   $Date: 2004/04/15 00:36:44 $

levels = 1;
try
   % Put linefeeds back in, if possible.
   b = [get_param(block, 'parent') '/' get_param(block, 'name')];
catch
   b = block;
   levels = 0;
end

b = strrep(b, '//', '~~'); % Temporarily mask double slashes.
i = findstr(b, '/');
if (isempty(i))
   error('Block path must have at least one slash.');
end
j = length(i);
if (j > 1)
   j = i(j - levels) + 1;
else
   j = 1;
end
s = b(j:end); 
s = strrep(s, '~~', '//'); % Unmask double slashes.

% end function s = rmsfname(block)
