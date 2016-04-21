function present(m)
% PRESENT  Displays model properties with more info than DISPLAY
%   PRESENT(M)

%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2001/04/06 14:22:08 $

mnam = m.Name;
if isempty(mnam)
   m.Name = inputname(1);
end

display(m)
