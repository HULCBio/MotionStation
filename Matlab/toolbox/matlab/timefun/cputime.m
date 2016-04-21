function [varargout] = cputime(varargin)
%CPUTIME CPU time in seconds.
%   CPUTIME returns the CPU time in seconds that has been used
%   by the MATLAB process since MATLAB started.  
%
%   For example:
%
%       t=cputime; your_operation; cputime-t
%
%   returns the cpu time used to run your_operation.            
% 
%   The return value may overflow the internal representation
%   and wrap around.
%
%   See also ETIME, TIC, TOC, CLOCK

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.8.4.2 $  $Date: 2004/04/10 23:32:13 $
%   Built-in function.

if nargout == 0
  builtin('cputime', varargin{:});
else
  [varargout{1:nargout}] = builtin('cputime', varargin{:});
end
