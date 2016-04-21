function val = statget(options,name,default,flag)
%STATGET Get STATS options parameter value.
%   VAL = STATGET(OPTIONS,'NAME') extracts the value of the named parameter
%   from statistics options structure OPTIONS, returning an empty matrix if
%   the parameter value is not specified in OPTIONS.  Case is ignored for
%   parameter names, and unique partial matches are allowed.
%   
%   VAL = STATGET(OPTIONS,'NAME',DEFAULT) extracts the named parameter, but
%   returns DEFAULT if the named parameter is not specified (is []) in
%   OPTIONS.
%   
%   See also STATSET.

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 1.2.4.2 $  $Date: 2004/03/02 21:49:32 $

if nargin < 2
    error('stats:statget:TooFewInputs',...
          'Requires at least two input arguments.');
elseif nargin < 3
    default = [];
end

% Undocumented usage for fast access with no error checking.
if nargin == 4 && isequal('fast',flag)
    val = statgetfast(options,name,default);
    return
end

if ~isempty(options) && ~isa(options,'struct')
    error('stats:statget:InvalidOptions',...
          'First argument must be an options structure created with STATSET.');
end

if isempty(options)
    val = default;
    return;
end

names = ['Display    '; 'MaxFunEvals'; 'MaxIter    '; ...
         'TolBnd     '; 'TolFun     '; 'TolX       ';
         'GradObj    '; 'DerivStep  '; 'FunValCheck'];
lowNames = lower(names);

lowName = lower(name);
j = strmatch(lowName,lowNames);
if numel(j) == 1 % one match
    name = deblank(names(j,:));
elseif numel(j) > 1 % more than one match
    % Check for any exact matches (in case any names are subsets of others)
    k = strmatch(lowName,lowNames,'exact');
    if numel(k) == 1
        name = deblank(names(k,:));
    else
        matches = deblank(names(j(1),:));
        for k = j(2:end)', matches = [matches ', ' deblank(names(k,:))]; end
        error('stats:statget:BadParameter',...
              'Ambiguous parameter name ''%s'' (%s)', name, matches);
    end
else %if isempty(j) % no matches
    error('stats:statget:BadParameter',...
        'Unrecognized parameter name ''%s''.  See STATSET for choices.', name);
end

val = options.(name);
if isempty(val)
    val = default;
end


%------------------------------------------------------------------
function value = statgetfast(options,name,defaultopt)
%STATGETFAST Get STATS OPTIONS parameter with no error checking.
%   VAL = STATGETFAST(OPTIONS,FIELDNAME,DEFAULTOPTIONS) will get the value
%   of the FIELDNAME from OPTIONS with no error checking or fieldname
%   completion.  If the value is [], it gets the value of the FIELDNAME from
%   DEFAULTOPTIONS, another OPTIONS structure which is  probably a subset
%   of the options in OPTIONS.

if isempty(options)
    value = defaultopt.(name);
else
    value = options.(name);
    if isempty(value)
        value = defaultopt.(name);
    end
end
