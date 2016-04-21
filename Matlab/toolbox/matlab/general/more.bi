function [varargout] = more(varargin)
%MORE   Control paged output in command window.
%   MORE OFF disables paging of the output in the MATLAB command window.
%   MORE ON enables paging of the output in the MATLAB command window.
%   MORE(N) specifies the size of the page to be N lines.
%
%   When MORE is enabled and output is being paged, advance to the next
%   line of output by hitting the RETURN key;  get the next page of
%   output by hitting the spacebar. Press the "q" key to exit out
%   of displaying the current item.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.10.4.1 $  $Date: 2003/06/09 05:58:18 $
%   Built-in function.

if nargout == 0
  builtin('more', varargin{:});
else
  [varargout{1:nargout}] = builtin('more', varargin{:});
end
