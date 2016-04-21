function [varargout] = what(varargin)
%WHAT List MATLAB-specific files in directory.
%   The command WHAT, by itself, lists the MATLAB specific files found
%   in the current working directory.  Most data files and other
%   non-MATLAB files are not listed.  Use DIR to get a list of everything.
%
%   The command WHAT DIRNAME lists the files in directory dirname on
%   the MATLABPATH.  It is not necessary to give the full path name of
%   the directory; a MATLABPATH relative partial pathname can be
%   specified instead (see PARTIALPATH).  For example, "what general"
%   and "what matlab/general" both list the M-files in directory
%   toolbox/matlab/general.
%
%   W = WHAT('directory') returns the results of WHAT in a structure
%   array with the fields:
%       path    -- path to directory
%       m       -- cell array of m-file names.
%       mat     -- cell array of mat-file names.
%       mex     -- cell array of mex-file names.
%       mdl     -- cell array of mdl-file names.
%       p       -- cell array of p-file names.
%       classes -- cell array of class names.
%
%   See also DIR, WHO, WHICH, LOOKFOR.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.15.4.1 $  $Date: 2003/06/09 05:58:39 $
%   Built-in function.

if nargout == 0
  builtin('what', varargin{:});
else
  [varargout{1:nargout}] = builtin('what', varargin{:});
end
