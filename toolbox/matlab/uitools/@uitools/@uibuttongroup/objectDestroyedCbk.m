function objectDestroyedCbk(src, evd)

% Copyright 2003 The MathWorks, Inc.

% Remove all listeners.
listeners = get(src, 'Listeners');
delete([listeners{:}]);
