function obj = loadobj(obj)
%LOADOBJ Method to post-process FITTYPE objects after loading

%   Copyright 2001-2004 The MathWorks, Inc.
%   $Revision: 1.6.2.1 $  $Date: 2004/02/01 21:41:49 $

% Restore function handles that had to be removed during save
if ~isequal(category(obj),'custom')
   libname = obj.type;
   if ~isempty(libname)
       obj = sethandles(libname,obj);
   end
end
