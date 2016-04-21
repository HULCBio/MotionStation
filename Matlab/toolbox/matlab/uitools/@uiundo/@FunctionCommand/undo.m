function undo(hThis)

% Copyright 2002 The MathWorks, Inc.

try 
   feval(hThis.InverseFunction,hThis.InverseVarargin{:});
catch
  err = lasterr; 
  error(sprintf('Can not undo command: %s',err));
  empty(hThis); 
end

