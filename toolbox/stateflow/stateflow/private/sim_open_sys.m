function sim_open_sys(modelH)
%SIM_OPEN_SYS( MODELH )

%   Jay R. Torgerson
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.11.2.1 $  $Date: 2004/04/15 01:00:24 $

pause(.001); % truly bizarr!  if you remove this line, simulink resizes the explorer!!!
open_system(modelH);
