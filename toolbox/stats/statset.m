function options = statset(varargin)
%STATSET Create/alter STATS options structure.
%   OPTIONS = STATSET('PARAM1',VALUE1,'PARAM2',VALUE2,...) creates a
%   statistics options structure OPTIONS in which the named parameters have
%   the specified values.  Any unspecified parameters are set to [].  When
%   you pass OPTIONS to a statistics function, a parameter set to []
%   indicates that the function uses its default value for that parameter.
%   Case is ignored for parameter names, and unique partial matches are
%   allowed.  NOTE: For parameters that are string-valued, the complete
%   string is required for the value; if an invalid string is provided, the
%   default is used.
%
%   OPTIONS = STATSET(OLDOPTS,'PARAM1',VALUE1,...) creates a copy of
%   OLDOPTS with the named parameters altered with the specified values.
%
%   OPTIONS = STATSET(OLDOPTS,NEWOPTS) combines an existing options
%   structure OLDOPTS with a new options structure NEWOPTS.  Any parameters
%   in NEWOPTS with non-empty values overwrite the corresponding old
%   parameters in OLDOPTS.
%
%   STATSET with no input arguments and no output arguments displays all
%   parameter names and their possible values, with defaults shown in {}
%   when the default is the same for all functions that use that option.
%   Use STATSET(STATSFUNCTION) (see below) to see function-specific
%   defaults for a specific function.
%
%   OPTIONS = STATSET (with no input arguments) creates an options
%   structure OPTIONS where all the fields are set to [].
%
%   OPTIONS = STATSET(STATSFUNCTION) creates an options structure with all
%   the parameter names and default values relevant to the optimization
%   function named in STATSFUNCTION.  STATSET sets parameters in OPTIONS to
%   [] for parameters that are not valid for STATSFUNCTION.  For example,
%   statset('factoran') or statset(@factoran) returns an options structure
%   containing all the parameter names and default values relevant to the
%   function 'factoran'.
%
%   STATSET parameters:
%      Display     - Level of display [ off | notify | final ]
%      MaxFunEvals - Maximum number of objective function evaluations
%                    allowed [ positive integer ]
%      MaxIter     - Maximum number of iterations allowed [ positive integer ]
%      TolBnd      - Parameter bound tolerance [ positive scalar ]
%      TolFun      - Termination tolerance for the objective function
%                    value [ positive scalar ]
%      TolX        - Termination tolerance for the parameters [ positive scalar ]
%      GradObj     - Objective function can return a gradient vector as a
%                    second output [ off | on ]
%      DerivStep   - Relative difference used in finite difference derivative
%                    calculations.  May be a scalar or the same size as the
%                    parameter vector [ positive scalar or vector ]
%      FunValCheck - Check for invalid values, such as NaN or Inf, from
%                    the objective function [ off | on ]
%
%   See also STATGET.

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 1.3.6.8 $  $Date: 2004/04/04 03:42:20 $

% Print out possible values of properties.
if (nargin == 0) && (nargout == 0)
    fprintf('                Display: [ off | notify | final ]\n');
    fprintf('            MaxFunEvals: [ positive integer ]\n');
    fprintf('                MaxIter: [ positive integer ]\n');
    fprintf('                 TolBnd: [ positive scalar ]\n');
    fprintf('                 TolFun: [ positive scalar ]\n');
    fprintf('                   TolX: [ positive scalar ]\n')
    fprintf('                GradObj: [ off | on ]\n')
    fprintf('              DerivStep: [ positive scalar or vector ]\n')
    fprintf('            FunValCheck: [ off | on ]\n')
    fprintf('\n');
    return;
end

options = struct('Display', [], 'MaxFunEvals', [], 'MaxIter', [], ...
                 'TolBnd', [], 'TolFun', [], 'TolX', [], 'GradObj', [], ...
                 'DerivStep', [], 'FunValCheck', []);

% If a function name/handle was passed in, then return the defaults.
if nargin == 1
    arg = varargin{1};
    if (ischar(arg) || isa(arg,'function_handle'))
        if isa(arg,'function_handle')
            arg = func2str(arg);
        end
        % Display is off by default.  The individual fitters have their own
        % warning/error messages that can be controlled via IDs.  The
        % optimizers print out text when display is on, but do not generate
        % warnings or errors per se.
        options.Display = 'off';
        switch lower(arg)
        case 'factoran'
            options.MaxFunEvals = 400;
            options.MaxIter = 100;
            options.TolFun = 1e-8;
            options.TolX = 1e-8;
        case {'normfit' 'lognfit' 'gamfit' 'bisafit' 'invgfit' 'logifit'...
              'loglfit' 'nakafit'} % these use statsfminbx
            options.MaxFunEvals = 200;
            options.MaxIter = 100;
            options.TolBnd = 1e-6;
            options.TolFun = 1e-8;
            options.TolX = 1e-8;
        case {'evfit' 'wblfit'} % these use fzero (gamfit sometimes does too)
            options.TolX = 1e-6;
        case {'nbinfit' 'ricefit' 'tlsfit'} % these use fminsearch
            options.MaxFunEvals = 400;
            options.MaxIter = 200;
            options.TolBnd = 1e-6;
            options.TolFun = 1e-6;
            options.TolX = 1e-6;
        case 'nlinfit'
            options.MaxIter = 200;
            options.TolFun = 1e-8;
            options.TolX = 1e-8;
            options.DerivStep = eps^(1/3);
        case 'mlecustom'
            options.MaxFunEvals = 400;
            options.MaxIter = 200;
            options.TolBnd = 1e-6;
            options.TolFun = 1e-6;
            options.TolX = 1e-6;
            options.GradObj = 'off';
            options.DerivStep = eps^(1/3);
            options.FunValCheck = 'on';
        case 'mlecov'
            options.GradObj = 'off';
            options.DerivStep = eps^(1/4);
        case 'mdscale'
            options.MaxIter = 200;
            options.TolFun = 1e-6;
            options.TolX = 1e-6;
        otherwise
            error('stats:statset:BadFunctionName',...
                  'No default options available for the function ''%s''.',arg);
        end
        return
	end
end

names = fieldnames(options);
lowNames = lower(names);
numNames = numel(names);

% Process OLDOPTS and NEWOPTS, if it's there.
i = 1;
while i <= nargin
    arg = varargin{i};
    % Check if we're into the param name/value pairs yet.
    if ischar(arg), break; end

    if ~isempty(arg) % [] is a valid options argument
        if ~isa(arg,'struct')
            error('stats:statset:BadInput',...
                  ['Expected argument %d to be a parameter name string or ' ...
                   'an options structure\ncreated with STATSET.'], i);
        end
        argNames = fieldnames(arg);
        for j = 1:numNames
            name = names{j};
            if any(strcmp(name,argNames))
                val = arg.(name);
                if ~isempty(val)
                    if ischar(val)
                        val = lower(deblank(val));
                    end
                    [valid, errid, errmsg] = checkparam(name,val);
                    if valid
                        options.(name) = val;
                    elseif ~isempty(errmsg)
                        error(errid,errmsg);
                    end
                end
            end
        end
    end
    i = i + 1;
end

% Done with OLDOPTS and NEWOPTS, now parse parameter name/value pairs.
if rem(nargin-i+1,2) ~= 0
    error('stats:statset:BadInput',...
          'Arguments must occur in name-value pairs.');
end
expectval = false; % start expecting a name, not a value
while i <= nargin
    arg = varargin{i};

    % Process a parameter name.
    if ~expectval
        if ~ischar(arg)
            error('stats:statset:BadParameter',...
                  'Expected argument %d to be a parameter name string.', i);
        end
        lowArg = lower(arg);
        j = strmatch(lowArg,lowNames);
        if numel(j) == 1 % one match
            name = names{j};
        elseif length(j) > 1 % more than one match
            % Check for any exact matches (in case any names are subsets of others)
            k = strmatch(lowArg,lowNames,'exact');
            if numel(k) == 1
                name = names{k};
            else
                matches = names{j(1)};
                for k = j(2:end)', matches = [matches ', ' names{k}]; end
                error('stats:statset:BadParameter',...
                      'Ambiguous parameter name ''%s'' (%s)', arg, matches);
            end
        else %if isempty(j) % no matches
            error('stats:statset:BadParameter',...
                  'Unrecognized parameter name ''%s''.', arg);
        end
        expectval = true; % expect a value next

    % Process a parameter value.
    else
        if ischar(arg)
            arg = lower(deblank(arg));
        end
        [valid, errid, errmsg] = checkparam(name,arg);
        if valid
            options.(name) = arg;
        elseif ~isempty(errmsg)
            error(errid,errmsg);
        end
        expectval = false; % expect a name next
    end
    i = i + 1;
end


%-------------------------------------------------
function [valid, errid, errmsg] = checkparam(name,value)
%CHECKPARAM Validate a STATSET parameter value.
%   [VALID,ID,MSG] = CHECKPARAM('name',VALUE) checks that the specified
%   value VALUE is valid for the parameter 'name'.
valid = true;
errmsg = '';
errid = '';

% Empty is always a valid parameter value.
if isempty(value)
    return
end

switch name
case {'TolFun','TolBnd','TolX'} % positive real scalar
    if ~isfloat(value) || ~isreal(value) || ~isscalar(value) || any(value <= 0)
        valid = false;
        errid = 'stats:statset:BadTolerance';
        if ischar(value)
            errmsg = sprintf('STATSET parameter ''%s'' must be a real positive scalar (not a string).',name);
        else
            errmsg = sprintf('STATSET parameter ''%s'' must be a real positive scalar.',name);
        end
    end
case {'Display'} % off,notify,final,iter
    values = ['off   '; 'notify'; 'final '; 'iter  '];
    if ~ischar(value) || isempty(strmatch(value,values,'exact'))
        valid = false;
        errid = 'stats:statset:BadDisplay';
        errmsg = sprintf('STATSET parameter ''%s'' must be ''off'', ''notify'', ''final'', or ''iter''.',name);
    end
case {'MaxIter' 'MaxFunEvals'} % non-negative integer, possibly inf
    if ~isfloat(value) || ~isreal(value) || ~isscalar(value) || any(value < 0)
        valid = false;
        errid = 'stats:statset:BadMaxValue';
        if ischar(value)
            errmsg = sprintf('STATSET parameter ''%s'' must be a real positive scalar (not a string).',name);
        else
            errmsg = sprintf('STATSET parameter ''%s'' must be a real positive scalar.',name);
        end
    end
case {'GradObj' 'FunValCheck'}
    values = ['off'; 'on '];
    if ~ischar(value) || isempty(strmatch(value,values,'exact'))
        valid = false;
        errid = 'stats:statset:BadFlagValue';
        errmsg = sprintf('STATSET parameter ''%s'' must be ''off'' or ''on''.',name);
    end
case 'DerivStep'
    if ~isfloat(value) || ~isreal(value) || any(value <= 0)
        valid = false;
        errid = 'stats:statset:BadDifference';
        errmsg = sprintf('STATSET parameter ''%s'' must contain real positive values.',name);
    end
otherwise
    valid = false;
    errid = 'stats:statset:BadParameter';
    errmsg = sprintf('Invalid STATSET parameter name: ''%s''.',name);
end
