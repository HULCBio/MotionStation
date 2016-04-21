function [varargout] = unloadlibrary(varargin)
%UNLOADLIBARY Unload a shared library loaded with LOADLIBRARY.
%   UNLOADLIBARY('LIBNAME') unloads the library LIBNAME that was
%   loaded with the LOADLIBRARY command.
%
%   See also LOADLIBRARY, LIBISLOADED.

%   Copyright 2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.3 $  $Date: 2003/06/09 05:58:38 $

if nargout == 0
  builtin('unloadlibrary', varargin{:});
else
  [varargout{1:nargout}] = builtin('unloadlibrary', varargin{:});
end
