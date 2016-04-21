function B = loadobj(A)
%WPTREE/LOADOBJ Called by load.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 29-Sep-2001.
%   Last Revision: 29-Sep-2001.
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/14 19:33:52 $

if strcmp(class(A),'wptree')
   B = A;
else 
   % object definition has changed
   % or the parent class definition has changed?
   try
       
   catch
      disp(lasterr)
   end
end
