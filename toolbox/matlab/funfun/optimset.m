function options = optimset(varargin)
%OPTIMSET Create/alter OPTIM OPTIONS structure.
%   OPTIONS = OPTIMSET('PARAM1',VALUE1,'PARAM2',VALUE2,...) creates an
%   optimization options structure OPTIONS in which the named parameters have
%   the specified values.  Any unspecified parameters are set to [] (parameters
%   with value [] indicate to use the default value for that parameter when
%   OPTIONS is passed to the optimization function). It is sufficient to type
%   only the leading characters that uniquely identify the parameter.  Case is
%   ignored for parameter names.
%   NOTE: For values that are strings, correct case and the complete string
%   are required; if an invalid string is provided, the default is used.
%
%   OPTIONS = OPTIMSET(OLDOPTS,'PARAM1',VALUE1,...) creates a copy of OLDOPTS
%   with the named parameters altered with the specified values.
%
%   OPTIONS = OPTIMSET(OLDOPTS,NEWOPTS) combines an existing options structure
%   OLDOPTS with a new options structure NEWOPTS.  Any parameters in NEWOPTS
%   with non-empty values overwrite the corresponding old parameters in
%   OLDOPTS.
%
%   OPTIMSET with no input arguments and no output arguments displays all
%   parameter names and their possible values, with defaults shown in {}
%   when the default is the same for all functions that use that option -- use
%   OPTIMSET(OPTIMFUNCTION) to see options for a specific function.).
%
%   OPTIONS = OPTIMSET (with no input arguments) creates an options structure
%   OPTIONS where all the fields are set to [].
%
%   OPTIONS = OPTIMSET(OPTIMFUNCTION) creates an options structure with all
%   the parameter names and default values relevant to the optimization
%   function named in OPTIMFUNCTION. For example,
%           optimset('fminbnd')
%   or
%           optimset(@fminbnd)
%   returns an options structure containing all the parameter names and
%   default values relevant to the function 'fminbnd'.
%
%OPTIMSET PARAMETERS for MATLAB
%Display - Level of display [ off | iter | notify | final ]
%MaxFunEvals - Maximum number of function evaluations allowed
%                     [ positive integer ]
%MaxIter - Maximum number of iterations allowed [ positive scalar ]
%TolFun - Termination tolerance on the function value [ positive scalar ]
%TolX - Termination tolerance on X [ positive scalar ]
%FunValCheck - Check for invalid values, such as NaN or complex, from 
%              user-supplied functions [ {off} | on ]
%OutputFcn - Name of installable output function  [ function ]
%          This output function is called by the solver after each
%          iteration.
%
%   Note: To see OPTIMSET parameters for the OPTIMIZATION TOOLBOX
%         (if you have the Optimization Toolbox installed), type
%             help optimoptions
%
%   Examples
%     To create options with the default options for fzero
%       options = optimset('fzero');
%     To create an options structure with TolFun equal to 1e-3
%       options = optimset('TolFun',1e-3);
%     To change the Display value of options to 'iter'
%       options = optimset(options,'Display','iter');
%
%   See also OPTIMGET, FZERO, FMINBND, FMINSEARCH, LSQNONNEG.

%   Optimization Toolbox only parameters passed to OPTIMSET when the
%   Optimization Toolbox is not on the path now cause a warning (and in a
%   future release an error). To test if the toolbox is on your path, use:
%      ver('optim')

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.34.4.11 $  $Date: 2004/04/16 22:05:38 $

% Print out possible values of properties.
if (nargin == 0) && (nargout == 0)
    fprintf('                Display: [ off | on | iter | notify | final ]\n');
    fprintf('            MaxFunEvals: [ positive scalar ]\n');
    fprintf('                MaxIter: [ positive scalar ]\n');
    fprintf('                 TolFun: [ positive scalar ]\n');
    fprintf('                   TolX: [ positive scalar ]\n');
    fprintf('            FunValCheck: [ {off} | on ]\n');
    fprintf('              OutputFcn: [ function | {[]} ]\n');

    try
        optimoptions;
    catch
        lasterrstruct = lasterror;
        if strcmp(lasterrstruct.identifier, 'MATLAB:UndefinedFunction')
            % Function OPTIMOPTIONS not found, so we assume Optimization Toolbox not on path
            %   and print the "MATLAB only" fields.
            % clean up last error
            lasterr('');
        else
            rethrow(lasterror);
        end
    end

    fprintf('\n');
    return;
end

% Create a struct of all the fields with all values set to 
allfields = {'Display'; 'MaxFunEvals';'MaxIter';'TolFun';'TolX'; ...
    'FunValCheck';'OutputFcn'};
try 
    % assume we have the Optimization Toolbox
    optimtbx = true;
    optimfields = optimoptiongetfields;  
    allfields = [allfields; optimfields];
catch
    lasterrstruct = lasterror;
    if strcmp(lasterrstruct.identifier, 'MATLAB:UndefinedFunction')
        % Function OPTIMOPTIONGETFIELDS not found, so we assume Optimization Toolbox not on path
        %   and use the "MATLAB only" struct.
        optimtbx = false;
        % clean up last error
        lasterr('');
    else
        rethrow(lasterror);
    end
end
% create cell array
structinput = cell(2,length(allfields));
% fields go in first row
structinput(1,:) = allfields';
% []'s go in second row
structinput(2,:) = {[]};
% turn it into correctly ordered comma separated list and call struct
options = struct(structinput{:});

numberargs = nargin; % we might change this value, so assign it
% If we pass in a function name then return the defaults.
if (numberargs==1) && (ischar(varargin{1}) || isa(varargin{1},'function_handle') )
    if ischar(varargin{1})
        funcname = lower(varargin{1});
        if ~exist(funcname)
            msg = sprintf(...
                'No default options available: the function ''%s'' does not exist on the path.',funcname);
            error('MATLAB:optimset:FcnNotFoundOnPath', msg)
        end
    elseif isa(varargin{1},'function_handle')
        funcname = func2str(varargin{1});
    end
    try 
        optionsfcn = feval(varargin{1},'defaults');
    catch
        msg = sprintf(...
            'No default options available for the function ''%s''.',funcname);
        error('MATLAB:optimset:NoDefaultsForFcn', msg)
    end
    % The defaults from the optim functions don't include all the fields
    % typically, so run the rest of optimset as if called with
    % optimset(options,optionsfcn)
    % to get all the fields.
    varargin{1} = options;
    varargin{2} = optionsfcn;
    numberargs = 2;
end

Names = allfields;
m = size(Names,1);
names = lower(Names);

i = 1;
while i <= numberargs
    arg = varargin{i};
    if ischar(arg)                         % arg is an option name
        break;
    end
    if ~isempty(arg)                      % [] is a valid options argument
        if ~isa(arg,'struct')
            error('MATLAB:optimset:NoParamNameOrStruct',...
                ['Expected argument %d to be a string parameter name ' ...
                'or an options structure\ncreated with OPTIMSET.'], i);
        end
        for j = 1:m
            if any(strcmp(fieldnames(arg),Names{j,:}))
                val = arg.(Names{j,:});
            else
                val = [];
            end
            if ~isempty(val)
                if ischar(val)
                    val = lower(deblank(val));
                end
                checkfield(Names{j,:},val,optimtbx);
                options.(Names{j,:}) = val;
            end
        end
    end
    i = i + 1;
end

% A finite state machine to parse name-value pairs.
if rem(numberargs-i+1,2) ~= 0
    error('MATLAB:optimset:ArgNameValueMismatch',...
        'Arguments must occur in name-value pairs.');
end
expectval = 0;                          % start expecting a name, not a value
while i <= numberargs
    arg = varargin{i};

    if ~expectval
        if ~ischar(arg)
            error('MATLAB:optimset:InvalidParamName',...
                'Expected argument %d to be a string parameter name.', i);
        end

        lowArg = lower(arg);
        j = strmatch(lowArg,names);
        if isempty(j)                       % if no matches
            [wasinmatlab, optionname] = checkoptimonlylist(lowArg);
            if ~wasinmatlab
                error('MATLAB:optimset:InvalidParamName',...
                    'Unrecognized parameter name ''%s''.', arg);
            else
                warning('MATLAB:optimset:InvalidParamName',...
                    ['The option ''%s'' is an Optimization Toolbox option and is not\n', ...
                     'used by any MATLAB functions. This option will be ignored and not included\n', ...
                     'in the options returned by OPTIMSET. Please change your code to not use \n', ...
                     'this option as it will error in a future release.'], ...
                     optionname);
                i = i + 2; % skip this parameter and its value; go to next parameter
                continue; % skip the rest of this loop
            end
        elseif length(j) > 1                % if more than one match
            % Check for any exact matches (in case any names are subsets of others)
            k = strmatch(lowArg,names,'exact');
            if length(k) == 1
                j = k;
            else
                msg = sprintf('Ambiguous parameter name ''%s'' ', arg);
                msg = [msg '(' Names{j(1),:}];
                for k = j(2:length(j))'
                    msg = [msg ', ' Names{k,:}];
                end
                msg = sprintf('%s).', msg);
                error('MATLAB:optimset:AmbiguousParamName', msg);
            end
        end
        expectval = 1;                      % we expect a value next

    else
        if ischar(arg)
            arg = lower(deblank(arg));
        end
        checkfield(Names{j,:},arg,optimtbx);
        options.(Names{j,:}) = arg;
        expectval = 0;
    end
    i = i + 1;
end

if expectval
    error('MATLAB:optimset:NoValueForParam',...
        'Expected value for parameter ''%s''.', arg);
end

%-------------------------------------------------
function checkfield(field,value,optimtbx)
%CHECKFIELD Check validity of structure field contents.
%   CHECKFIELD('field',V,OPTIMTBX) checks the contents of the specified
%   value V to be valid for the field 'field'. OPTIMTBX indicates if 
%   the Optimization Toolbox is on the path.
%

% empty matrix is always valid
if isempty(value)
    return
end

% See if it is one of the valid MATLAB fields.  It may be both an Optim
% and MATLAB field, e.g. MaxFunEvals, in which case the MATLAB valid
% test may fail and the Optim one may pass.
validfield = true;
switch field
    case {'TolFun'} % real scalar
        [validvalue, errmsg, errid] = nonNegReal(field,value);
    case {'TolX'} % real scalar
        % this string is for LSQNONNEG
        [validvalue, errmsg, errid] = nonNegReal(field,value,'10*eps*norm(c,1)*length(c)');
    case {'Display'} % off,none,iter,final,notify,testing
        [validvalue, errmsg, errid] = displayType(field,value);
    case {'MaxFunEvals','MaxIter'} % integer including inf or default string
        % this string is for FMINSEARCH
        [validvalue, errmsg, errid] = nonNegInteger(field,value,'200*numberofvariables');
    case {'FunValCheck'} % off,on
        [validvalue, errmsg, errid] = onOffType(field,value);
    case {'OutputFcn'}% function
        [validvalue, errmsg, errid] = functionType(field,value);
    otherwise
        validfield = false;  
        validvalue = false;
        errmsg = sprintf('Unrecognized parameter name ''%s''.', field);
        errid = 'MATLAB:optimset:checkfield:InvalidParamName';
end

if validvalue 
    return;
elseif ~optimtbx && validfield  
    % Throw the MATLAB invalid value error
    error(errid, errmsg);
else % Check if valid for Optim Tbx
    [optvalidvalue, opterrmsg, opterrid, optvalidfield] = optimoptioncheckfield(field,value);
    if optvalidvalue
        return;
    elseif optvalidfield
        % Throw the Optim invalid value error
        error(opterrid, opterrmsg)
    else % Neither field nor value is valid for Optim
        % Throw the MATLAB invalid value error (can't be invalid field for
        % MATLAB & Optim or would have errored already in optimset).
        error(errid, errmsg)
    end
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
        errid = 'MATLAB:funfun:optimset:NonNegReal:negativeNum';
        errmsg = sprintf('Invalid value for OPTIONS parameter %s: must be a real non-negative scalar (not a string).',field);
    else
        errid = 'MATLAB:funfun:optimset:NonNegReal:negativeNum';
        errmsg = sprintf('Invalid value for OPTIONS parameter %s: must be a real non-negative scalar.',field);
    end
else
    errid = '';
    errmsg = '';
end

%-----------------------------------------------------------------------------------------

function [valid, errmsg, errid] = nonNegInteger(field,value,string)
% Any nonnegative real integer scalar or sometimes a special string
valid =  isreal(value) && isscalar(value) && (value >= 0) && value == floor(value) ;
if nargin > 2
    valid = valid || isequal(value,string);
end
if ~valid
    if ischar(value)
        errid = 'MATLAB:funfun:optimset:nonNegInteger:notANonNegInteger';
        errmsg = sprintf('Invalid value for OPTIONS parameter %s: must be a real non-negative integer (not a string).',field);
    else
        errid = 'MATLAB:funfun:optimset:nonNegInteger:notANonNegInteger';
        errmsg = sprintf('Invalid value for OPTIONS parameter %s: must be a real non-negative integer.',field);
    end
else
    errid = '';
    errmsg = '';
end

%-----------------------------------------------------------------------------------------

function [valid, errmsg, errid] = displayType(field,value)
% One of these strings: on, off, none, iter, final, notify
valid =  ischar(value) && any(strcmp(value,{'on';'off';'none';'iter';'final';'notify';'testing'}));
if ~valid
    errid = 'MATLAB:funfun:optimset:displayType:notADisplayType';
    errmsg = sprintf('Invalid value for OPTIONS parameter %s: must be ''off'',''on'',''iter'',''notify'', or ''final''.',field);
else
    errid = '';
    errmsg = '';
end

%-----------------------------------------------------------------------------------------

function [valid, errmsg, errid] = onOffType(field,value)
% One of these strings: on, off
valid =  ischar(value) && any(strcmp(value,{'on';'off'}));
if ~valid
    errid = 'MATLAB:funfun:optimset:onOffType:notOnOffType';
    errmsg = sprintf('Invalid value for OPTIONS parameter %s: must be ''off'' or ''on''.',field);
else
    errid = '';
    errmsg = '';
end

%-----------------------------------------------------------------------------------------

function [valid, errmsg, errid] = functionType(field,value)
% Any function handle or string (we do not test if the string is a function name)
valid =  ischar(value) || isa(value, 'function_handle');
if ~valid
    errid = 'MATLAB:funfun:optimset:functionType:notAFunction';
    errmsg = sprintf('Invalid value for OPTIONS parameter %s: must be a function.',field);
else
    errid = '';
    errmsg = '';
end

%--------------------------------------------------------------------------------

function [wasinmatlab, optionname] = checkoptimonlylist(lowArg);
% Check if the user is trying to set an option that is only used by
% Optimization Toolbox functions -- this used to have no effect.
% Now it will warn. In a future release, it will error.  
names =  {...
    'ActiveConstrTol'; ...
    'NoStopIfFlatInfeas'; ...
    'BranchStrategy';  ...
    'DerivativeCheck';  ...
    'Diagnostics';  ...
    'DiffMaxChange';  ...
    'DiffMinChange';  ...
    'GoalsExactAchieve';  ...
    'GradConstr';  ...
    'GradObj';  ...
    'Hessian';  ...
    'HessMult';  ...
    'HessPattern';  ...
    'HessUpdate';  ...
    'InitialHessType';  ...
    'InitialHessMatrix';  ...
    'Jacobian';  ...
    'JacobMult';  ...
    'JacobPattern';  ...
    'LargeScale';  ...
    'LevenbergMarquardt';  ...
    'LineSearchType';  ...
    'MaxNodes';  ...
    'MaxPCGIter';  ...
    'MaxRLPIter';  ...
    'MaxSQPIter';  ...
    'MaxTime';  ...
    'MeritFunction';  ...
    'MinAbsMax';  ...
    'NodeDisplayInterval';  ...
    'NodeSearchStrategy';  ...
    'NonlEqnAlgorithm';  ...
    'PhaseOneTotalScaling'; ...
    'Preconditioner';  ...
    'PrecondBandWidth';  ...
    'RelLineSrchBnd'; ...
    'RelLineSrchBndDuration'; ...
    'ShowStatusWindow';  ...
    'Simplex';  ...
    'TolCon';  ...
    'TolPCG';  ...
    'TolRLPFun';  ...
    'TolXInteger';  ...
    'TypicalX'};
lowernames = lower(names);
k = strmatch(lowArg,lowernames);
wasinmatlab = ~isempty(k);
if wasinmatlab
    optionname = names{k};
else
    optionname = '';
end
