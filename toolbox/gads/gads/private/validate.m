function [gl,ff,o]  = validate(gLength,fitness,o)
%VALIDATE validates the contents of the fitness function, genome length and options struct.
%   [gLength,fitness, OUT] = VALIDATE(GenomeLength,FitnessFcn,IN) validates the FitnessFcn, GenomeLength and 
%   the structure IN. OUT is a structure which have all the fields in IN and it gets other 
%   fields like FitnessFcn, GenomeLength, etc.
%
%   This function is private to GA.

%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.26.6.3 $  $Date: 2004/03/18 17:59:34 $

msg = nargchk(3,3,nargin);
if ~isempty(msg)
    error('MATLAB:Validate:numInputs', ...
          'VALIDATE requires one structure of the format created by GAOPTIMSET.');
end

%We need to validate ALL the information, bundle them all
o.FitnessFcn   = fitness;
o.GenomeLength = gLength;
%gaoptimset does not return 2 fields, which need to be validated
options = gaoptimset;
options.FitnessFcn = [];
options.GenomeLength = [];

%Does the options structure contain the right fields?
template = fieldnames(options);
oFields = fieldnames(o);

f = find(0 == ismember(template,oFields));
if(~isempty(f))
    msg = sprintf('The field "%s" is missing from the gaoptimset Structure.\n',template{f});
    error('gads:VALIDATE:missingField',msg);
end

f = find(0 == ismember(oFields,template));
if(~isempty(f))
    msg = sprintf('There is an unexpected field "%s" in the gaoptimset Structure.\n',oFields{f});
    warning('gads:VALIDATE:unexpectedField',msg);
end

% range check each field
validNumberofVariables(o.GenomeLength);
stringSet('PopulationType',o.PopulationType,{'doubleVector','custom','bitString'});

positiveIntegerArray('PopulationSize',o.PopulationSize);
realUnitScalar('CrossoverFraction',o.CrossoverFraction);
nonNegInteger('EliteCount',o.EliteCount);
o = rangeCorrection(o,'PopInitRange');
populationCheck(o);

positiveInteger('MigrationInterval',o.MigrationInterval);
realUnitScalar('MigrationFraction',o.MigrationFraction);
stringSet('MigrationDirection',o.MigrationDirection,{'both','forward'});
stringSet('Display',o.Display,{'off','none','iter','final','diagnose'});
stringSet('Vectorized',o.Vectorized,{'on','off'});

positiveInteger('Generations',o.Generations);
positiveScalar('TimeLimit',o.TimeLimit);
positiveInteger('StallGenLimit',o.StallGenLimit);
positiveScalar('StallTimeLimit',o.StallTimeLimit);
realScalar('FitnessLimit',o.FitnessLimit);

positiveInteger('PlotInterval',o.PlotInterval);
% These functions not only VALIDATE, they seperate ftns from args for
% speed.
o = functionHandleOrCell(o,'FitnessFcn',o.FitnessFcn);
o = functionHandleOrCell(o,'FitnessScalingFcn',o.FitnessScalingFcn);
o = functionHandleOrCell(o,'SelectionFcn',o.SelectionFcn);
o = functionHandleOrCell(o,'CrossoverFcn',o.CrossoverFcn);
o = functionHandleOrCell(o,'MutationFcn',o.MutationFcn);
o = functionHandleOrCell(o,'CreationFcn',o.CreationFcn);

if ~isempty(o.HybridFcn)
    o = functionHandleOrCell(o,'HybridFcn',o.HybridFcn);
end

% protect against Elite Count greater than population Size.
if ( o.EliteCount >= sum(o.PopulationSize) )
    msg = sprintf('Elite count must be less than Population Size.');
    error('gads:VALIDATE:EliteCountGTPop',msg);
end

% this special case takes an array of function cells
o = functionHandleOrCellArray(o,'PlotFcns',o.PlotFcns);
o = functionHandleOrCellArray(o,'OutputFcns',o.OutputFcns);

%Assign all the outputs;
ff = o.FitnessFcn;
gl = o.GenomeLength;
%Remove these fields we added in options
o=rmfield(o,{'FitnessFcn','GenomeLength'});

%-------------------------------------------------------------------
% any positive integer
function positiveInteger(property,value)
valid =  isreal(value) && isscalar(value) && (value > 0) && (value == floor(value));
if(~valid)
   msg = sprintf('The field ''%s'' must contain a positive integer.',property);
   error('gads:VALIDATE:PostiveInteger:notPosInteger',msg);
end
%-------------------------------------------------------------------
% any nonnegative integer
function nonNegInteger(property,value)
valid =  isreal(value) && isscalar(value) && (value >= 0) && (value == floor(value));
if(~valid)
    msg = sprintf('The field ''%s'' must contain a non negative integer.',property);
    error('gads:VALIDATE:NonNegInteger:negativeNum',msg);
end
%-------------------------------------------------------------------
% any positive integer
function positiveScalar(property,value)
valid =  isreal(value) && isscalar(value) && (value > 0);
if(~valid)
    msg = sprintf('The field ''%s'' must contain a positive Scalar.',property);
    error('gads:VALIDATE:PositiveScalar:notPosScalar',msg);
end
%-------------------------------------------------------------------
function positiveIntegerArray(property,value)
allValid = true;
for i = 1:length(value)
    valid =  isreal(value(i)) && (value(i) == floor(value(i)));
    allValid = allValid && valid;
end

if(~valid)
    msg = sprintf('The field ''%s'' must contain a positive integer.',property);
    error('gads:VALIDATE:POSITIVEINTEGERARRAY:notPosIntegerArray',msg);
end
%-------------------------------------------------------------------
% A scalar on the interval [0,1]
function realUnitScalar(property,value)
valid = isreal(value) && isscalar(value) && (value >= 0) && (value <= 1);
if(~valid)
    msg = sprintf('The field ''%s'' must contain a scalar on the interval (0,1)',property);
    error('gads:VALIDATE:REALUNITSCALAR:notScalarOnUnitInterval',msg);
end
%-------------------------------------------------------------------
% A scalar
function realScalar(property,value)
valid = isreal(value) && isscalar(value);
if(~valid)
    msg = sprintf('The field ''%s'' must contain a scalar',property);
    error('gads:VALIDATE:REALSCALAR:notScalar',msg);
end
%-------------------------------------------------------------------
% Number of variables
function validNumberofVariables(GenomeLength)
valid =  isnumeric(GenomeLength) && isscalar(GenomeLength)&& (GenomeLength > 0) ...
         && (GenomeLength == floor(GenomeLength));
if(~valid)
   msg = sprintf('Number of variables (NVARS) must be a positive number.');
   error('gads:VALIDATE:validNumberofVariables:notValidNvars',msg);
end

%-------------------------------------------------------------------------
% if it's a scalar fcn handle or a cellarray starting with a fcn handle and
% followed by something other than a fcn handle, return parts, else empty
function [handle,args] =  isFcn(x)
  handle = [];
  args = {};
%If x is a cell array with additional arguments, handle them
if iscell(x) && ~isempty(x)
    args = x(2:end);
    handle = x{1};
else
    args = {};
    handle = x;
end
%Only function_handle or inlines are allowed
if  ~(isa(handle,'inline') || isa(handle,'function_handle'))
    handle = [];
end

%-------------------------------------------------------------------
% a function Handle or a cell array starting with a function handle.
function options = functionHandleOrCell(options,property,value)
[handle,args] = isFcn(value);

if(~isempty(handle)) && (isa(handle,'inline') || isa(handle,'function_handle'))
    options.(property) = handle;
    options.([property 'Args']) = args;
    return
end

if strcmp(property,'FitnessFcn')
    msg = sprintf('The fitness function must be a function handle.');
else
    msg = sprintf('The field ''%s'' must contain a function handle.',property);
end

error('gads:VALIDATE:FUNCTIONHANDLEORCELL:needHandleOrInline',msg);

%---------------------------------------------------------------------
% the most complex one. A fcn handle, a handle plus args, or an array of
% same.
function options = functionHandleOrCellArray(options,property,value)

% clear out any old value
options.(property) = {};
options.([property 'Args']) = {};

%if a scalar  ~cell  is passed convert to cell (for clarity, not speed)
if ~iscell(value) && isscalar(value)
     value = {value};
 end
% If value is an array of functions, it must be a cell array
for i = 1:length(value)
    candidate = value(i);
    %If any element is also a cell array
    if iscell(candidate)
        if isempty(candidate{1})
            continue;
        end
        [handle,args] = isFcn(candidate{:});
    else
        [handle,args] = isFcn(candidate);
    end
    if(~isempty(handle)) && isa(handle,'function_handle')
        options.(property){i} = handle;
        options.([property 'Args']){i} = args;
    else
        msg = sprintf('The field ''%s'' must contain a function handle.',property);
        error('gads:VALIDATE:FUNCTIONHANDLEORCELLARRAY:needHandleOrInline',msg);
    end
end
%----------------------------------------------------------------
% one of a set of strings
function stringSet(property,value,set)
for i = 1:length(set)
    if(strcmpi(value,set{i}))
        return;
    end
end

msg = sprintf('The field %s must contain one of these strings: %s %s %s %s %s',property,set{:});
error('gads:VALIDATE:STRINGSET:notCorrectChoice',msg);
%----------------------------------------------------------------
function options = rangeCorrection(options,property)

%Check the size of PopInitRange
Range = options.PopInitRange;
%check only for double data type range
if ~isa(Range,'double')
    return;
end

if size(Range,1) ~=2
    msg = sprintf('The field ''%s'' must have two rows.',property);
    error('gads:VALIDATE:RANGECORRECTION:invalidPopInitRange',msg);  
end
lb = Range(1,:);
lb = lb(:);
lenlb = length(lb);
ub = Range(2,:);
ub = ub(:);
lenub = length(ub);
nvars = options.GenomeLength; %This field was inserted

% Check maximum length
if lenlb > nvars
   warning('gads:VALIDATE:extraRange','Length of lower range is > number of variables; ignoring extra bounds.');
   lb = lb(1:nvars);   
   lenlb = nvars;
elseif lenlb < nvars
   lb = [lb; lb(end)*ones(nvars-lenlb,1)];
   lenlb = nvars;
end

if lenub > nvars
   warning('gads:VALIDATE:extraRange','Length of upper range is > number of variables; ignoring extra bounds.');
   ub = ub(1:nvars);
   lenub = nvars;
elseif lenub < nvars
   ub = [ub; ub(end)*ones(nvars-lenub,1)];
   lenub = nvars;
end
% Check feasibility of bounds
len = min(lenlb,lenub);
if any( lb( (1:len)' ) > ub( (1:len)' ) )
   count = full(sum(lb>ub));
   if count == 1
      msg=sprintf(['\nExiting due to infeasibility:  %i lower range exceeds the' ...
            ' corresponding upper range.\n'],count);
   else
      msg=sprintf(['\nExiting due to infeasibility:  %i lower range exceed the' ...
            ' corresponding upper range.\n'],count);
   end
   error('gads:validate:infesibleRange',msg);
end
% check if -inf in ub or inf in lb   
if any(eq(ub, -inf)) 
   error('gads:VALIDATE:infRange','-Inf detected in upper bound: upper bounds must be > -Inf.');
elseif any(eq(lb,inf))
   error('gads:VALIDATE:infRange','+Inf detected in lower bound: lower bounds must be < Inf.');
end

options.PopInitRange = [lb,ub]';
%------------------------------End of rangeCorrection --------------------------

function populationCheck(options)
%Perform some check if Population type is double or bitString
if strcmpi(options.PopulationType,'custom')
    return;
end
if ~isnumeric(gaoptimget(options,'InitialPopulation'))
    error('gads:VALIDATE:invalidPopulation','Invalid value for OPTIONS parameter InitialPopulation.');
end
if ~isnumeric(gaoptimget(options,'InitialScores'))
    error('gads:VALIDATE:invalidScores','Invalid value for OPTIONS parameter InitialScores.');
end
%------------------------------End of populationCheck --------------------------
