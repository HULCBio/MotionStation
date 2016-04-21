function [varargout] = nargin(varargin)
%NARGIN Number of function input arguments.
%   Inside the body of a user-defined function, NARGIN returns
%   the number of input arguments that were used to call the
%   function. 
%
%   NARGIN('fun') returns the number of declared inputs for the
%   M-file function 'fun'.  The number of arguments is negative if the
%   function has a variable number of input arguments.
%
%   See also NARGOUT, VARARGIN, NARGCHK, NARGOUTCHK, INPUTNAME, 
%      MFILENAME.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 5.15.4.2 $  $Date: 2004/04/10 23:29:54 $
%   Built-in function.

if nargout == 0
  builtin('nargin', varargin{:});
else
  [varargout{1:nargout}] = builtin('nargin', varargin{:});
end
