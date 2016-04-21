function execute(hThis)

% Copyright 2002 The MathWorks, Inc.

try 
  feval(hThis.Function,hThis.Varargin{:});
catch
  err = lasterr; 
  error(sprintf('Can not execute command: %s',err));
  empty(hThis); 
end