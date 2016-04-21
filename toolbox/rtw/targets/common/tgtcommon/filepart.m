function piece = filepart(file,part)
% FILEPART

%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $
%   $Date: 2004/04/19 01:21:56 $

[path,name,ext] = fileparts(file);

switch part
 case 'path',
  piece = path;
 case 'name',
  piece = name;
 case 'ext',
  piece = ext;
 otherwise,
  piece = '';
end
