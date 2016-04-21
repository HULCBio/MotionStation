function [varargout] = nargchk(varargin)
%NARGCHK Validate number of input arguments. 
%   MSGSTRUCT = NARGCHK(LOW,HIGH,N,'struct') returns an appropriate error
%   message structure if N is not between LOW and HIGH. If N is in the
%   specified range, the message structure is empty. The message structure
%   has at a minimum two fields, 'message' and 'identifier'.
%
%   MSG = NARGCHK(LOW,HIGH,N) returns an appropriate error message string if
%   N is not between LOW and HIGH. If it is, NARGCHK returns an empty matrix. 
%
%   MSG = NARGCHK(LOW,HIGH,N,'string') is the same as 
%   MSG = NARGCHK(LOW,HIGH,N).
% 
%   Example
%      error(nargchk(1, 3, nargin, 'struct'))
%
%   See also NARGOUTCHK, NARGIN, NARGOUT, INPUTNAME, ERROR.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.12.4.3 $  $Date: 2003/11/06 15:42:09 $
%   Built-in function.

if nargout == 0
  builtin('nargchk', varargin{:});
else
  [varargout{1:nargout}] = builtin('nargchk', varargin{:});
end
