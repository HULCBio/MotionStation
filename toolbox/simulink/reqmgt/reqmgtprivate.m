%   Copyright 1994-2004 The MathWorks, Inc.
%   $Revision: 1.1.4.2 $

function varargout = reqmgtprivate(function_name, varargin)
  
   [varargout{1:nargout}] = feval(function_name, varargin{1:end});
