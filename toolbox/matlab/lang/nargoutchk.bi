function [varargout] = nargoutchk(varargin)
%NARGOUTCHK Validate number of output arguments. 
%   MSGSTRUCT = NARGOUTCHK(LOW,HIGH,N,'struct') returns an appropriate error
%   message structure if N is not between LOW and HIGH. If N is in the
%   specified range, the message structure is empty. The message structure
%   has at a minimum two fields, 'message' and 'identifier'.
%
%   MSG = NARGOUTCHK(LOW,HIGH,N) returns an appropriate error message string if
%   N is not between LOW and HIGH. If it is, NARGOUTCHK returns an empty
%   matrix. 
%
%   MSG = NARGOUTCHK(LOW,HIGH,N,'string') is the same as 
%   MSG = NARGOUTCHK(LOW,HIGH,N).
% 
%   Example
%      error(nargoutchk(1, 3, nargout, 'struct'))
%
%   See also NARGCHK, NARGIN, NARGOUT, INPUTNAME, ERROR.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.5.4.3 $  $Date: 2003/11/06 15:42:10 $
%   Built-in function.

if nargout == 0
  builtin('nargoutchk', varargin{:});
else
  [varargout{1:nargout}] = builtin('nargoutchk', varargin{:});
end
