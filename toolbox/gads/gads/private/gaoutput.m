function [state,options,optchanged] = gaoutput(FitnessFcn,options,state,flag)
%GAOUTPUT Helper function that manages the output functions for GA.
%
%   [STATE, OPTIONS, OPTCHANGED] = ...
%   GAOUTPUT(FitnessFcn, options, state, flag) runs each of the display
%   functions in the options.OutputFcns cell array.
%
%   this is a helper function called by ga between each generation, and is
%   not typicaly called directly.

%   Copyright 2004 The MathWorks, Inc. 
%   $Revision: 1.3 $  $Date: 2004/01/16 16:50:59 $


% get the functions and return if there are none
optchanged = false;
functions = options.OutputFcns;
if(isempty(functions))
    return
end

% call each output function
args = options.OutputFcnsArgs;
for i = 1:length(functions)
    [state,optnew,changed] = feval(functions{i},options,state,flag,args{i}{:});
    if ~isempty(state.StopFlag)
        return;
    end
    if changed %If changes are not duplicates, we will get all the changes
       options = optnew;
       optchanged = true;
    end
end
