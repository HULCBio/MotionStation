function [varargout] = recycle(varargin)
%RECYCLE   Set option to move deleted files to recycle folder.
%   The purpose of the RECYCLE function is to help the DELETE
%   function determine whether the deleted files should be 
%   moved to the recycle bin on the PC and Macintosh, moved
%   to a temporary folder on Unix, or deleted.
%
%   OLDSTATE = RECYCLE(STATE) sets the recycle option to the one
%   specified by STATE.  STATE can be either 'on' or 'off'. The 
%   default value of STATE is 'off'. OLDSTATE is the state of 
%   recycle prior to being set to STATE.  
%
%   STATUS = RECYCLE returns the current state of the RECYCLE 
%   function.  It can be either 'on' or 'off'.  
%
%   See also DELETE.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.4 $  $Date: 2004/03/17 20:05:31 $
%   Built-in function.

if nargout == 0
  builtin('recycle', varargin{:});
else
  [varargout{1:nargout}] = builtin('recycle', varargin{:});
end
