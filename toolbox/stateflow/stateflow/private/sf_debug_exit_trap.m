function sf_debug_exit_trap

% Copyright 2003 The MathWorks, Inc.

trapStatus = sf('DebugTrap', 'status');

if (trapStatus == 2)  % At prompt
    mInstance = com.mathworks.jmi.Matlab;
    mInstance.evalNoOutput('sf(''DebugTrap'', ''exit'');');
elseif (trapStatus == 1)  % In the loop but not at prompt
    sf('DebugTrap', 'exit');
end
