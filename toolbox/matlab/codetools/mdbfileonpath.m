function varargout = mdbfileonpath(filename)
%   MDBFILEONPATH Helper function for the Editor/Debugger
%   MDBFILEONPATH is passed a string containing an absolute filename.
%   It returns:
%       a null string if the file is not on the matlab path, or
%       the filename if it is on the path
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $ 

if nargin > 0
   result = which(filename);

   fcnname = filename;
   %Be sure to escape single quotes embedded inside of the file name.
   whichargs = [ '''' strrep(fcnname, '''', '''''') ''''];
   fullpath = evalin('caller', ['which(' whichargs ')']);
   if isempty(fullpath)
       fullpath = evalin('base', ['which(' whichargs ')']);
   end
   if nargout == 0  
       disp(fullpath)
   else
       varargout{1} = fullpath;
   end
else
   if nargout == 0  
       disp('')
   else
       varargout{1} = '';
   end
end


