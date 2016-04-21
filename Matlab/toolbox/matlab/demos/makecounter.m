function countfcn = makecounter(initvalue)
%MAKECOUNTER Used by NESTEDDEMO.
% This function returns a handle to a customized nested function 'getCounter'.
% initvalue specifies the initial value of the counter whose's handle is returned.

% Copyright 1984-2004 The MathWorks, Inc. 
% $Revision: 1.1.6.2 $  $Date: 2004/03/02 21:46:55 $

currentCount = initvalue; % Initial value
countfcn = @getCounter;   % Return handle to getCounter

    function count = getCounter
        % This function increments the variable 'currentCount', when it
        % gets called (using its function handle) .
        currentCount = currentCount + 1;
        count = currentCount;
    end
end
