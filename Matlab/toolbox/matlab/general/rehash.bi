function [varargout] = rehash(varargin)
%REHASH  Refresh function and file system caches.
%   REHASH with no inputs performs the same refresh operations that are done
%   each time the MATLAB prompt is displayed--namely, for any non-toolbox
%   directories on the path, the list of known files is updated, the list of
%   known classes is revised, and the timestamps of loaded functions are
%   checked against the files on disk.  The only time one should need to use
%   this form is when writing out files programmatically and expecting
%   MATLAB to find them before reaching the next MATLAB prompt.
% 
%   REHASH PATH is the same as REHASH except that it unconditionally reloads
%   all non-toolbox directories.  This is exactly the same as the behavior of
%   PATH(PATH).  This form should be unnecessary unless you are running
%   MATLAB in an environment where it is unable to tell that a directory has
%   changed.  When this situation arises, MATLAB displays a warning upon
%   startup.
%
%   REHASH TOOLBOX is the same as REHASH PATH except that it unconditionally
%   reloads all directories, including all toolbox directories.  This
%   form should be unnecessary unless you are modifying files in toolbox
%   directories.
%
%   REHASH PATHRESET is the same as REHASH PATH except that it also
%   forces any shadowed functions to be replaced by any shadowing functions.
%
%   REHASH TOOLBOXRESET is the same as REHASH TOOLBOX except that it also
%   forces any shadowed functions to be replaced by any shadowing functions.
%
%   REHASH TOOLBOXCACHE will update the toolbox cache file on disk.
%   Type "help toolbox_path_cache" for additional info.
%
%   See also PATH, ADDPATH, RMPATH, SAVEPATH.

%   CGN, August 1997

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.12.4.2 $  $Date: 2004/03/17 20:05:32 $

%   Built-in function.

if nargout == 0
  builtin('rehash', varargin{:});
else
  [varargout{1:nargout}] = builtin('rehash', varargin{:});
end
