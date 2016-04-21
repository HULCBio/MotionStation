function B = loadobj(A)
%AXISOBJ/LOADOBJ Load axisobj object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.5.4.1 $  $Date: 2004/01/15 21:11:44 $

if strcmp(class(A),'axisobj')
   B=A;
else % object definition has changed
   % or the parent class definition has changed?
   try
      A = rmfield(A,'Draggable');
      HGObj = A.scribehgobj;
      A = rmfield(A,'scribehgobj');
      B = class(A,'axisobj',HGObj);  
   catch
      disp(lasterr)
      warning('Incompatible version of .fig file.');
   end

end
