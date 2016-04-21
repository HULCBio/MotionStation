function indexhelper(demosroot,callback,product,label,file)
% INDEXHELPER A helper function for the demos index page.

% Matthew J. Simoneau, January 2004
% Copyright 1984-2004 The MathWorks, Inc.
% $Revision: 1.1.6.1 $  $Date: 2004/03/02 21:46:51 $

if isempty(file)
   body = '';
   base = '';
else
   fullpath = fullfile(demosroot,file);
   f = fopen(fullpath);
   if (f == -1)
      error('Could not open "%s".',fullpath);
   end
   body = fread(f,'char=>char')';
   fclose(f);
   base = ['file:///' fullpath];
end
   
if isempty(callback)
   web(fullpath,'-helpbrowser')
else
   demowin(callback,product,label,body,base)
end