function simset(this,varargin)
% Sets simulation options for Response Optimization project.

%   $Revision: 1.1.6.3 $ $Date: 2004/04/11 00:46:23 $
%   Copyright 1986-2004 The MathWorks, Inc.
try
   for ct=1:length(this.Tests)
      t = this.Test(ct);
      t.SimOptions = simset(t.SimOptions,varargin{:});
   end
catch
   rethrow(lasterror)
end