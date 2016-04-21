function o = optimget(options,name,default,flag)
%OPTIMGET Get OPTIM OPTIONS parameters.
%   VAL = OPTIMGET(OPTIONS,'NAME') extracts the value of the named parameter
%   from optimization options structure OPTIONS, returning an empty matrix if
%   the parameter value is not specified in OPTIONS.  It is sufficient to
%   type only the leading characters that uniquely identify the
%   parameter.  Case is ignored for parameter names.  [] is a valid OPTIONS
%   argument.
%
%   VAL = OPTIMGET(OPTIONS,'NAME',DEFAULT) extracts the named parameter as
%   above, but returns DEFAULT if the named parameter is not specified (is [])
%   in OPTIONS.  For example
%
%     val = optimget(opts,'TolX',1e-4);
%
%   returns val = 1e-4 if the TolX property is not specified in opts.
%
%   See also OPTIMSET.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.20.4.8 $  $Date: 2004/04/16 22:05:37 $

if nargin < 2
    error('MATLAB:optimget:NotEnoughInputs', 'Not enough input arguments.');
end
if nargin < 3
    default = [];
end
if nargin < 4
    flag = [];
end

% undocumented usage for fast access with no error checking
if isequal('fast',flag)
    o = optimgetfast(options,name,default);
    return
end

if ~isempty(options) && ~isa(options,'struct')
    error('MATLAB:optimget:Arg1NotStruct',...
        'First argument must be an options structure created with OPTIMSET.');
end

if isempty(options)
    o = default;
    return;
end

allfields = {'Display'; 'MaxFunEvals';'MaxIter';'TolFun';'TolX';'FunValCheck';'OutputFcn'};
try
    optimfields = optimoptiongetfields;  
    allfields = [allfields; optimfields];
catch
    lasterrstruct = lasterror;
    if strcmp(lasterrstruct.identifier, 'MATLAB:UndefinedFunction')
        % Function OPTIMOPTIONGETFIELDS not found, so we assume Optimization Toolbox not on path
        %   and use the "MATLAB only" struct.
        % clean up last error
        lasterr('');
    else
        rethrow(lasterror);
    end
end

Names = allfields;
names = lower(Names);

lowName = lower(name);
j = strmatch(lowName,names);
if isempty(j)               % if no matches
    error('MATLAB:optimget:InvalidPropName',...
        ['Unrecognized property name ''%s''.  ' ...
        'See OPTIMSET for possibilities.'], name);
elseif length(j) > 1            % if more than one match
    % Check for any exact matches (in case any names are subsets of others)
    k = strmatch(lowName,names,'exact');
    if length(k) == 1
        j = k;
    else
        msg = sprintf('Ambiguous property name ''%s'' ', name);
        msg = [msg '(' Names{j(1),:}];
        for k = j(2:length(j))'
            msg = [msg ', ' Names{k,:}];
        end
        msg = sprintf('%s).', msg);
        error('MATLAB:optimget:AmbiguousPropName', msg);
    end
end

if any(strcmp(Names,Names{j,:}))
    o = options.(Names{j,:});
    if isempty(o)
        o = default;
    end
else
    o = default;
end

%------------------------------------------------------------------
function value = optimgetfast(options,name,defaultopt)
%OPTIMGETFAST Get OPTIM OPTIONS parameter with no error checking so fast.
%   VAL = OPTIMGETFAST(OPTIONS,FIELDNAME,DEFAULTOPTIONS) will get the
%   value of the FIELDNAME from OPTIONS with no error checking or
%   fieldname completion. If the value is [], it gets the value of the
%   FIELDNAME from DEFAULTOPTIONS, another OPTIONS structure which is
%   probably a subset of the options in OPTIONS.
%

if isempty(options)
     value = defaultopt.(name);
     return;
end
% We need to know if name is a valid field of options, but it is faster to use 
% a try-catch than to test if the field exists and if the field name is
% correct. If the options structure is from an older version of the
% toolbox, it could be missing a newer field.
try
    value = options.(name);
catch
    value = [];
    lasterr('');  % clean up last error
end

if isempty(value)
    value = defaultopt.(name);
end


