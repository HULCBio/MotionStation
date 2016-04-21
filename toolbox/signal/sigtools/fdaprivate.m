function varargout = fdaprivate(varargin)
%FDAPRIVATE This function allows access to the functions in the private directory.
%        FDAPRIVATE('FOO',ARG1,ARG2,...) is the same as
%        FOO(ARG1,ARG2,...).  
%
%     Copyright 1988-2002 The MathWorks, Inc.
%     $Revision: 1.5 $  $Date: 2002/04/14 23:51:41 $

if (nargout == 0)
  feval(varargin{:});
else
  [varargout{1:nargout}] = feval(varargin{:});
end
