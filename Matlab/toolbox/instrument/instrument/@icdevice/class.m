function val = class(obj,varargin)
%CLASS Create object or return object class.
%
%   VAL = CLASS(OBJ) returns the class of the object OBJ.
%
%   Within a constructor method, CLASS(S,'class_name') creates an
%   object of class 'class_name' from the structure S.  This
%   syntax is only valid in a function named <class_name>.m in a
%   directory named @<class_name> (where <class_name> is the same
%   as the string passed into CLASS).  
% 
%   CLASS(S,'class_name',PARENT1,PARENT2,...) also inherits the
%   methods and fields of the parent objects PARENT1, PARENT2, ...
% 
%   See also ISA, SUPERIORTO, INFERIORTO, STRUCT.
%

%   MP 6-25-02
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.3 $  $Date: 2004/01/16 19:59:03 $

% When returning the class of an object, if the object is 1-by-1, the 
% class of the object is returned - icdevice, if the object 
% is not 1-by-1 then 'instrument' is returned.

if nargin==1
  if length(obj) > 1
     val = 'instrument';
  else
     val = builtin('class', obj);
  end
else
   try
      % Constructing the object.  Call the builtin CLASS.
      val = builtin('class', obj, varargin{:});
   catch
      rethrow(lasterror);
   end
end
