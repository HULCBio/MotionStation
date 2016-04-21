function [varargout] = delete(varargin)
%DELETE Delete file or graphics object.
%   DELETE file_name  deletes the named file from disk.  Wildcards
%   may be used.  For example, DELETE *.p deletes all P-files from the
%   current directory. 
%
%   Use the functional form of DELETE, such as DELETE('file') when the
%   file name is stored in a string.
%
%   DELETE checks the status of the RECYCLE option to determine whether
%   the file should be moved to the recycle bin on PC and Macintosh,
%   moved to a temporary folder on Unix, or deleted.  
%
%   DELETE(H) deletes the graphics object with handle H. If the object
%   is a window, the window is closed and deleted without confirmation.
%
%   See also RECYCLE.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2003/06/09 05:57:53 $
%   Built-in function.

if nargout == 0
  builtin('delete', varargin{:});
else
  [varargout{1:nargout}] = builtin('delete', varargin{:});
end
