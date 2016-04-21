function varargout = commprivate(varargin)
%COMMPRIVATE This function allows access to the functions in the private dir.
%        COMMPRIVATE('FOO',ARG1,ARG2,...) is the same as
%        FOO(ARG1,ARG2,...).  

%     Copyright 1996-2002 The MathWorks, Inc.
%     $Revision: 1.6 $  $Date: 2002/03/27 00:06:30 $

if (nargout == 0)
  feval(varargin{:});
else
  [varargout{1:nargout}] = feval(varargin{:});
end
