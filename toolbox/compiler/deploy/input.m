function str = input(prompt, strflag)
% INPUT Read (but do not EVAL) input.
% This function replaces MATLAB's regular INPUT statement in compiled
% applications.

% Copyright 2004 The MathWorks, Inc.

    nargchk(1,2,nargin);
    if nargin == 2
        if strflag == 's'
            str = readline(prompt, 1);
        else
            error('MCR:INPUT:BadInput', ...
                  'The second argument to input (if supplied) must be ''s''.');
        end
    else
        str = readline(prompt);
    end
