function tic
%TIC Start a stopwatch timer.
%   The sequence of commands
%       TIC, operation, TOC
%   prints the number of seconds required for the operation.
%
%   See also TOC, CLOCK, ETIME, CPUTIME.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.11.4.1 $  $Date: 2003/10/16 04:52:00 $

% Note that tic is implemented as a builtin function for efficiency. Any changes
% to this file will not change the behavior of tic. This file is provided as
% an example of how to use the 'global' keyword only.

% TIC simply stores CLOCK in a global variable.
global TICTOC
TICTOC = clock;
