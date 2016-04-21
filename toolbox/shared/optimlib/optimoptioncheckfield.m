function [validvalue, errmsg, errid, validfield] = optimoptioncheckfield(field,value)
%OPTIMOPTIONCHECKFIELD Check validity of structure field contents.
%
% This is a helper function for OPTIMSET and OPTIMGET.

%   [VALIDVALUE, ERRMSG, ERRID, VALIDFIELD] = OPTIMOPTIONCHECKFIELD('field',V)
%   checks the contents of the specified value V to be valid for the field 'field'.

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2004/03/26 13:27:22 $

% empty matrix is always valid
if isempty(value)
    validvalue = true;
    errmsg = '';
    errid = '';
    validfield = true;
    return
end

% Some fields are checked in optimset/checkfield: Display, MaxFunEvals, MaxIter,
% OutputFcn, TolFun, TolX. Some are checked in both (e.g., MaxFunEvals).
validfield = true;
switch field
    case {'TolCon','TolPCG','ActiveConstrTol',...
            'DiffMaxChange','DiffMinChange','TolXInteger','MaxTime', ...
            'NodeDisplayInterval','RelLineSrchBnd'}
        % real scalar
        [validvalue, errmsg, errid] = nonNegReal(field,value);
    case {'TolRLPFun'}
        % real scalar in the range [1.0e-9, 1.0e-5]
        [validvalue, errmsg, errid] = boundedReal(field,value,[1e-9, 1e-5]);
    case {'MaxFunEvals'}
        [validvalue, errmsg, errid] = nonNegInteger(field,value,{'100*numberofvariables'}); % fmincon
    case {'MaxIter'}
        [validvalue, errmsg, errid] = nonNegInteger(field,value,{'100000*numberofvariables'}); % bintprog
    case {'LargeScale','DerivativeCheck','Diagnostics','GradConstr','GradObj',...
            'Hessian','Jacobian','LevenbergMarquardt', 'Simplex', 'RevisedSimplex', ...
            'NoStopIfFlatInfeas','PhaseOneTotalScaling'}
        % off, on
        [validvalue, errmsg, errid] = stringsType(field,value,{'on';'off'});
    case {'PrecondBandWidth','MinAbsMax','GoalsExactAchieve','RelLineSrchBndDuration'}
        % integer including inf
        [validvalue, errmsg, errid] = nonNegInteger(field,value);
    case {'MaxPCGIter'}
        % integer including inf or default string
        [validvalue, errmsg, errid] = nonNegInteger(field,value,{'max(1,floor(numberofvariables/2))','numberofvariables'});
    case {'MaxSQPIter'}
        % integer including inf or default
        [validvalue, errmsg, errid] = nonNegInteger(field,value,'10*max(numberofvariables,numberofinequalities+numberofbounds)');
    case {'JacobPattern'}
        % matrix or default string
        [validvalue, errmsg, errid] = matrixType(field,value,'sparse(ones(jrows,jcols))');
    case {'HessPattern'}
        % matrix or default string
        [validvalue, errmsg, errid] = matrixType(field,value,'sparse(ones(numberofvariables))');
    case {'TypicalX'}
        % matrix or default string
        [validvalue, errmsg, errid] = matrixType(field,value,'ones(numberofvariables,1)');
    case {'HessMult','JacobMult','Preconditioner'}
        % function
        [validvalue, errmsg, errid] = functionType(field,value);
    case {'HessUpdate'}
        % dfp, bfgs, steepdesc
        if strcmp(value,'gillmurray')
            warning('optimlib:optimoptioncheckfield:InvalidUpdateHessType', ...
                ['OPTION.HessUpdate = ''gillmurray'' is obsolete and will be removed\n' ...
                ' in a future release of the Optimization Toolbox.\n' ...
                ' Setting options.HessUpdate = ''bfgs'' instead. Update your code to\n' ...
                ' avoid this warning.'])
            value = 'bfgs';
        end
        [validvalue, errmsg, errid] = stringsType(field,value,{'dfp' ; 'steepdesc';'bfgs'});
    case {'NonlEqnAlgorithm'}
        % dogleg, lm, gn
        [validvalue, errmsg, errid] = stringsType(field,value,{'dogleg' ; 'lm'; 'gn'});
    case {'LineSearchType'}
        % cubicpoly, quadcubic
        [validvalue, errmsg, errid] = stringsType(field,value,{'cubicpoly' ; 'quadcubic' });
    case {'MeritFunction'}
        % singleobj, multiobj
        [validvalue, errmsg, errid] = stringsType(field,value,{'singleobj'; 'multiobj' });
    case {'ShowStatusWindow'}
        % on, off, iter, final, iterplus
        [validvalue, errmsg, errid] = stringsType(field,value,{'on';'off';'none';'iter';'final';'iterplus'});
    case {'InitialHessType'}
        % identity, scaled-identity, user-supplied
        [validvalue, errmsg, errid] = stringsType(field,value,{'identity' ; 'scaled-identity'; 'user-supplied'});
    case {'InitialHessMatrix'}
        % strictly positive matrix
        [validvalue, errmsg, errid] = posMatrixType(field,value);
    case {'MaxRLPIter'}
        % integer including inf or default string
        [validvalue, errmsg, errid] = nonNegInteger(field,value,'100*numberofvariables');
    case {'MaxNodes'}
        % integer including inf or default string
        [validvalue, errmsg, errid] = nonNegInteger(field,value,'1000*numberofvariables');
    case {'BranchStrategy'}
        % mininfeas, maxinfeas
        [validvalue, errmsg, errid] = stringsType(field,value,{'mininfeas' ; 'maxinfeas'});
    case  {'NodeSearchStrategy'}
        % df, bn
        [validvalue, errmsg, errid] = stringsType(field,value,{'df' ; 'bn'});
    otherwise
        validfield = false;
        validvalue = false;
        % No need to set an error. If the field isn't valid for MATLAB or Optim,
        % will have already errored in optimset. If field is valid for MATLAB,
        % then the error will be an invalid value for MATLAB.
        errid = '';
        errmsg = '';
end

%-----------------------------------------------------------------------------------------

function [valid, errmsg, errid] = nonNegReal(field,value,string)
% Any nonnegative real scalar or sometimes a special string
valid =  isreal(value) && isscalar(value) && (value >= 0) ;
if nargin > 2
    valid = valid || isequal(value,string);
end
if ~valid
    if ischar(value)
        errid = 'optimlib:optimoptioncheckfield:NonNegReal:negativeNum';
        errmsg = sprintf('Invalid value for OPTIONS parameter %s: must be a real non-negative scalar (not a string).',field);
    else
        errid = 'optimlib:optimoptioncheckfield:NonNegReal:negativeNum';
        errmsg = sprintf('Invalid value for OPTIONS parameter %s: must be a real non-negative scalar.',field);
    end
else
    errid = '';
    errmsg = '';
end
%-----------------------------------------------------------------------------------------

function [valid, errmsg, errid] = nonNegInteger(field,value,strings)
% Any nonnegative real integer scalar or sometimes a special string
valid =  isreal(value) && isscalar(value) && (value >= 0) && value == floor(value) ;
if nargin > 2
    valid = valid || any(strcmp(value,strings));
end
if ~valid
    if ischar(value)
        errid = 'optimlib:optimoptioncheckfield:notANonNegInteger';
        errmsg = sprintf('Invalid value for OPTIONS parameter %s: must be a real non-negative scalar (not a string).',field);
    else
        errid = 'optimlib:optimoptioncheckfield:notANonNegInteger';
        errmsg = sprintf('Invalid value for OPTIONS parameter %s: must be a real non-negative scalar.',field);
    end
else
    errid = '';
    errmsg = '';
end

%-----------------------------------------------------------------------------------------

function [valid, errmsg, errid] = matrixType(field,value,strings)
% Any matrix
valid =  isa(value,'double');
if nargin > 2
    valid = valid || any(strcmp(value,strings));
end
if ~valid
    if ischar(value)
        errid = 'optimlib:optimoptioncheckfield:notANonNegInteger';
        errmsg = sprintf('Invalid value for OPTIONS parameter %s: must be a matrix (not a string).',field);
    else
        errid = 'optimlib:optimoptioncheckfield:posMatrixType:notAPosMatrix';
        errmsg = sprintf('Invalid value for OPTIONS parameter %s: must be a matrix.',field);
    end
else
    errid = '';
    errmsg = '';
end

%-----------------------------------------------------------------------------------------

function [valid, errmsg, errid] = posMatrixType(field,value)
% Any positive scalar or all positive vector
valid =  isa(value,'double') && all(value > 0) && isvector(value);
if ~valid
    errid = 'optimlib:optimoptioncheckfield:posMatrixType:notAPosMatrix';
    errmsg = sprintf('Invalid value for OPTIONS parameter %s: \n must be a positive scalar or a vector with positive entries.',field);
else
    errid = '';
    errmsg = '';
end

%-----------------------------------------------------------------------------------------

function [valid, errmsg, errid] = functionType(field,value)
% Any function handle or string (we do not test if the string is a function name)
valid =  ischar(value) || isa(value, 'function_handle');
if ~valid
    errid = 'optimlib:optimoptioncheckfield:functionType:notAFunction';
    errmsg = sprintf('Invalid value for OPTIONS parameter %s: must be a function handle.',field);
else
    errid = '';
    errmsg = '';
end
%-----------------------------------------------------------------------------------------
function [valid, errmsg, errid] = stringsType(field,value,strings)
% One of the strings in cell array strings
valid =  ischar(value) && any(strcmp(value,strings));

% To print out the error message beautifully, need to get the commas and "or"s
% in all the correct places while building up the string of possible string values.
if ~valid
    allstrings = ['''',strings{1},''''];
    for index = 2:(length(strings)-1)
        % add comma and a space after all but the last string
        allstrings = [allstrings, ', ''', strings{index},''''];
    end
    if length(strings) > 2
        allstrings = [allstrings,', or ''',strings{end},''''];
    elseif length(strings) == 2
        allstrings = [allstrings,' or ''',strings{end},''''];
    end
    errid = 'optimlib:optimoptioncheckfield:stringsType:notAStringsType';
    errmsg = sprintf('Invalid value for OPTIONS parameter %s:\n must be %s.',field, allstrings);
else
    errid = '';
    errmsg = '';
end

%-----------------------------------------------------------------------------------------
function [valid, errmsg, errid] = boundedReal(field,value,bounds)
% Scalar in the bounds
valid =  isa(value,'double') && isscalar(value) && ...
    (value >= bounds(1)) && (value <= bounds(2));
if ~valid
    errid = 'optimlib:optimoptioncheckfield:boundedReal:notAboundedReal';
    errmsg = sprintf('Invalid value for OPTIONS parameter %s: \n must be a scalar in the range [%6.3g, %6.3g].', ...
        field, bounds(1), bounds(2));
else
    errid = '';
    errmsg = '';
end


