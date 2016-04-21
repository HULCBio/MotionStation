function [stop,optold,optchanged] = psoutput(OutputFcns, OutputFcnArgs,optimval,optold,flag)
%PSOUTPUT Helper function that manages the output functions.
%
%   [STATE, OPTNEW,OPTCHNAGED] = PSOUTPUT(OPTIMVAL,OPTOLD,FLAG) runs each of 
%   the output functions in the options.OutputFcn cell array.
%
%   Private to PFMINLCON, PFMINBND, PFMINUNC.

%   Copyright 2004 The MathWorks, Inc. 
%   $Revision: 1.7 $  $Date: 2004/01/16 16:50:45 $

%Initialize
stop   = false;
optchanged = false;

% get the functions and return if there are none
if(isempty(OutputFcns))
    return
end


% call each output function
    for i = 1:length(OutputFcns)
        [stop ,optnew , changed ] = feval(OutputFcns{i},optimval,optold,flag,OutputFcnArgs{i}{:});
        if stop
            return;
        end
        if changed  %If changes are not duplicates, we will get all the changes
            optold = optnew;
            optchanged = true;
        end
    end
    

