function o = ddeget(options,name,default,flag)
%DDEGET  Get DDE OPTIONS parameters.
%   VAL = DDEGET(OPTIONS,'NAME') extracts the value of the named property
%   from integrator options structure OPTIONS, returning an empty matrix if
%   the property value is not specified in OPTIONS. It is sufficient to type
%   only the leading characters that uniquely identify the property. Case is
%   ignored for property names. [] is a valid OPTIONS argument.
%   
%   VAL = DDEGET(OPTIONS,'NAME',DEFAULT) extracts the named property as
%   above, but returns VAL = DEFAULT if the named property is not specified
%   in OPTIONS. For example
%   
%       val = ddeget(opts,'RelTol',1e-4);
%   
%   returns val = 1e-4 if the RelTol property is not specified in opts.
%   
%   See also DDESET, DDE23.

%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 1.3.4.2 $  $Date: 2003/10/21 11:55:37 $

% undocumented usage for fast access with no error checking
if (nargin == 4) && isequal(flag,'fast')
   o = getknownfield(options,name,default);
   return
end

if nargin < 2
  error('MATLAB:ddeget:NotEnoughInputs', 'Not enough input arguments.');
end
if nargin < 3
  default = [];
end

if ~isempty(options) && ~isa(options,'struct')
  error('MATLAB:ddeget:Arg1NotStruct',...
        'First argument must be an options structure created with DDESET.');
end

if isempty(options)
  o = default;
  return;
end

Names = [
         'AbsTol      '    
         'Events      '
         'InitialStep '
         'InitialY    '
         'Jumps       '
         'MaxStep     '
         'NormControl '
         'OutputFcn   '
         'OutputSel   '
         'RelTol      '
         'Stats       '         
                       ];

names = lower(Names);

lowName = lower(name);
j = strmatch(lowName,names);
if isempty(j)               % if no matches
  error('MATLAB:ddeget:InvalidPropName',...
        ['Unrecognized property name ''%s''.  ' ...
         'See DDESET for possibilities.'], name);
elseif length(j) > 1            % if more than one match
  % Check for any exact matches (in case any names are subsets of others)
  k = strmatch(lowName,names,'exact');
  if length(k) == 1
    j = k;
  else
    msg = sprintf('Ambiguous property name ''%s'' ', name);
    msg = [msg '(' deblank(Names(j(1),:))];
    for k = j(2:length(j))'
      msg = [msg ', ' deblank(Names(k,:))];
    end
    msg = sprintf('%s).', msg);
    error('MATLAB:ddeget:AmbiguousPropName', msg);
  end
end

if any(strcmp(fieldnames(options),deblank(Names(j,:))))
  o = options.(deblank(Names(j,:)));
  if isempty(o)
    o = default;
  end
else
  o = default;
end

% --------------------------------------------------------------------------
function v = getknownfield(s, f, d)
%GETKNOWNFIELD  Get field f from struct s, or else yield default d.

if isfield(s,f)   % s could be empty.
  v = subsref(s, struct('type','.','subs',f));
  if isempty(v)
    v = d;
  end
else
  v = d;
end

