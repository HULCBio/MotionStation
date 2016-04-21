function [vals, errStr] = evaluatevars(strs)
%EVALUATEVARS   Evaluate variables in the MATLAB workspace.
%
%   EVALUATEVARS will take a string (or cell array of strings)
%   representing filter coefficients or the Sampling frequency and evaluate 
%   it in the base MATLAB workspace. If the variables exist and are numeric, the 
%   workspace variables values are returned in VALS, if they do not exist, an 
%   error dialog is launched and the error message is returned in ERRSTR. 
%
%   Input:
%     strs   - String or cell array of strings from edit boxes
%
%   Outputs:
%     vals   - Values returned after evaluating the input strs in the
%              MATLAB workspace.
%     errStr - Error string returned if evaluation failed.

%   Author(s): R. Losada, P. Costa
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.9.4.2 $  $Date: 2004/04/13 00:31:37 $ 

errStr = '';
vals = {};

if  iscell(strs)
    for n = 1:length(strs), % Loop through strings
        if ~isempty(strs{n}),
            try
                vals{n} = evalin('base',['[',strs{n},']']);
                % Check that vals is a numeric array and not a string.
                if ~isnumeric(vals{n}), errStr=[strs{n} ' is not numeric.']; end     
            catch
                errStr = sprintf('The variable %s is not defined in the MATLAB workspace.', strs{n});
                break;
            end
        else
            errStr = ['Edit boxes cannot be empty.'];
            break;
        end 
    end
else
    if ~isempty(strs),
        try
            vals = evalin('base',['[',strs,']']);
            % Qfilt object is not numeric.
            if ~isa(vals,'qfilt'),
                if ~isnumeric(vals), errStr=[strs ' is not numeric.']; end
            end
        catch
            errStr = sprintf('The variable %s is not defined in the MATLAB workspace.', strs);
        end
    else
        errStr = ['Edit boxes cannot be empty.']; 
    end
end

if nargout < 2,
    error(errStr); % Top level try catch will display the error dialog.
end

% [EOF] evaluatevars.m
