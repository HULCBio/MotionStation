function varargout = sbswitch(varargin)
%SBSWITCH Function switch-yard.
%        SBSWITCH('FOO',ARG1,ARG2,...) is the same as
%        FOO(ARG1,ARG2,...).  This provides access to private
%        functions for Handle Graphics callbacks.

%        Copied from IMSWITCH.
%   Copyright 1988-2002 The MathWorks, Inc.
%        $Revision: 1.8 $  $Date: 2002/04/15 00:03:53 $

if (nargout == 0)
  feval(varargin{:});
else
  [varargout{1:nargout}] = feval(varargin{:});
end
