function o = gaoptimget(options,name,default,flag)
%GAOPTIMGET     Get GA  OPTIONS parameters.
%   VAL = GAOPTIMGET(OPTIONS,'NAME') extracts the value of the named parameter
%   from optimization options structure OPTIONS, returning an empty matrix if
%   the parameter value is not specified in OPTIONS.  It is sufficient to
%   type only the leading characters that uniquely identify the
%   parameter.  Case is ignored for parameter names.  [] is a valid OPTIONS
%   argument.
%   
%   VAL = GAOPTIMGET(OPTIONS,'NAME',DEFAULT) extracts the named parameter as
%   above, but returns DEFAULT if the named parameter is not specified (is [])
%   in OPTIONS.  For example
%   
%     val = gaoptimget(opts,'Generations',200);
%   
%   returns val = 200 if the TolX property is not specified in opts.
%   
%   See also GAOPTIMSET.

%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.23.4.1 $  $Date: 2004/03/09 16:15:34 $


if nargin < 2
  error('gads:GAOPTIMGET:inputarg','Not enough input arguments.');
end
if nargin < 3
  default = [];
end
if nargin < 4
   flag = [];
end

% undocumented usage for fast access with no error checking
if isequal('fast',flag)
   o = gaoptimgetfast(options,name,default);
   return
end

if ~isempty(options) && ~isa(options,'struct')
  error('gads:GAOPTIMGET:firstargerror','First argument must be an options structure created with GAOPTIMSET.');
end

if isempty(options)
  o = default;
  return;
end

optionsstruct = struct('PopulationType', [], ...
    'PopInitRange', [], ...
    'PopulationSize', [], ...
    'EliteCount', [], ...
    'CrossoverFraction', [], ...
    'MigrationDirection',[], ...
    'MigrationInterval',[], ...
    'MigrationFraction',[], ...
    'Generations', [], ...
    'TimeLimit', [], ...
    'FitnessLimit', [], ...
    'StallGenLimit', [], ...
    'StallTimeLimit', [], ...
    'InitialPopulation',[], ...
    'InitialScores', [], ...
    'PlotInterval',[], ...
    'FitnessScalingFcn', [], ...
    'SelectionFcn', [], ...
    'CrossoverFcn',[], ...
    'MutationFcn',[], ...
    'Display', [], ...
    'PlotFcns', [], ...
    'OutputFcns', [], ...
    'CreationFcn',[], ...
    'HybridFcn',[], ...
    'Vectorized',[]);      

Names = fieldnames(optionsstruct);
%[m,n] = size(Names);
names = lower(Names);

lowName = lower(name);
j = strmatch(lowName,names);
if isempty(j)               % if no matches
  error('gads:GAOPTIMGET:invalidproperty',sprintf(['Unrecognized property name ''%s''.  ' ...
                 'See GAOPTIMSET for possibilities.'], name));
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
    error('gads:GAOPTIMGET:ambiguousproperty',msg);
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
function value = gaoptimgetfast(options,name,defaultopt)
%OPTIMGETFAST Get OPTIM OPTIONS parameter with no error checking so fast.
%   VAL = OPTIMGETFAST(OPTIONS,FIELDNAME,DEFAULTOPTIONS) will get the
%   value of the FIELDNAME from OPTIONS with no error checking or
%   fieldname completion. If the value is [], it gets the value of the
%   FIELDNAME from DEFAULTOPTIONS, another OPTIONS structure which is 
%   probably a subset of the options in OPTIONS.
%

if ~isempty(options)
        value = options.(name);
else
    value = [];
end

if isempty(value)
    value = defaultopt.(name);
end


