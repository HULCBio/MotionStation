function optimset(this,varargin)
% Sets optimization options for Response Optimization project.

%   $Revision: 1.1.6.3 $ $Date: 2004/04/11 00:46:19 $
%   Copyright 1986-2003 The MathWorks, Inc.
try
   set(this.OptimOptions,varargin{:})
catch
   rethrow(lasterror)
end