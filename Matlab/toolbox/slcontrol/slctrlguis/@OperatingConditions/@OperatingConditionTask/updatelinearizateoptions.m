function updatelinearizateoptions(this)
% UPDATELINEARIZATIONOPTIONS - Updates the linearization portion of the
% operating condition object with the variables that are specified in the
% workspace
%
%  Author(s): John Glass
%  Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2004/03/10 21:52:04 $

if strcmpi(this.options.LinearizationAlgorithm,'numericalpert')
    %% This value must be a scalar
    this.options.NumericalPertRel = LocalCheckValidScalar(this.OptimChars.NumericalPertRel);
    %% Evaluate only if not empty.  Otherwise return []
    if ~isempty(this.OptimChars.NumericalXPert)
        this.options.NumericalXPert = evalin('base',this.OptimChars.NumericalXPert);
    else
        this.options.NumericalXPert = [];
    end
    if ~isempty(this.OptimChars.NumericalUPert)
        this.options.NumericalUPert = evalin('base',this.OptimChars.NumericalUPert);
    else
        this.options.NumericalUPert = [];
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalCheckValidScalar Check for valid workspace scalar variable
function value = LocalCheckValidScalar(str)

try
    value = evalin('base',str);
catch
    value = [];
    return
end

if (~isa(value,'double') || length(value) ~= 1)
    lasterr(sprintf('The variable %s must be a double of length 1'),...
            'slcontrol:OptimizationOptions:InvalidLength');
    value = [];
end