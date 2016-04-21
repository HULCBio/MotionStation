function [varargout] = nargout(varargin)
%NARGOUT Number of function output arguments.
%   Inside the body of a user-defined function, NARGOUT returns the
%   number of output arguments that were used to call the function.
%
%   NARGOUT('fun') returns the number of declared outputs for the
%   M-file function 'fun'.  The number of arguments is negative if the
%   function has a variable number of output arguments.
%
%   See also NARGIN, VARARGOUT, NARGCHK, NARGOUTCHK, MFILENAME.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 5.16.4.2 $  $Date: 2004/04/10 23:29:55 $
%   Built-in function.

if nargout == 0
  builtin('nargout', varargin{:});
else
  [varargout{1:nargout}] = builtin('nargout', varargin{:});
end
