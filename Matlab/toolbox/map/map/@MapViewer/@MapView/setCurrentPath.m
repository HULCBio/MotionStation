function setCurrentPath(this,filename)

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/08/01 18:15:01 $

[pathstr,name,ext,versn] = fileparts(filename);
if isempty(pathstr)
  f = which(filename);
  [pathstr,name,ext,versn] = fileparts(f);
end
this.CurrentPath = [pathstr filesep];

