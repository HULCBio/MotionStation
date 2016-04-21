function nag_on_initialize
% NAG_ON_INITIALIZE - Produce an warning message that 
% instrumentation is not supported while a chart is
% called at initialization

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/03/23 03:00:28 $
disp('The Model coverage tool does not currently support coverage');
disp('information pertaining to Stateflow chart execution performed'); 
disp('at initialization.  Recorded coverage information will not'); 
disp('be accurate for these constructs');
