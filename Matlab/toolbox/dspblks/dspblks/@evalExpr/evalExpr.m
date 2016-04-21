function obj = evalExpr(varargin)
%evalExpr Construct an expression-evaluation object.
%   EVALEXPR(EXPR) constructs an inline function object from the
%   MATLAB expression contained in the string EXPR.  The input
%   arguments are automatically determined by searching EXPR
%   for variable names. If no variable exists, 'x'
%   is used.
%
%   EVALEXPR(EXPR, ARG1, ARG2, ...) constructs an inline
%   function whose input arguments are specified by the
%   strings ARG1, ARG2, ...  Multicharacter symbol names may
%   be used.
%
%   EVALEXPR(EXPR, N), where N is a scalar, constructs an
%   inline function whose input arguments are 'x', 'P1',
%   'P2', ..., 'PN'.
%
%   Examples:
%     g = evalExpr('t^2')
%     g = evalExpr('sin(2*pi*f + theta)')
%     g = evalExpr('sin(2*pi*f + theta)', 'f', 'theta')
%     g = evalExpr('x^P1', 1)
%
%   See also INLINE.

%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/11/14 02:47:10 $

% Object fields
% .expr       string containing function definition
% .inputExpr  eval string to assign inputs to formal parameters
% .args       string matrix containing formal parameter list
% .isEmpty    flag indicating inline called with no arguments
% .numArgs    number of formal parameters
% .version    Class version number

% Construct default object
obj.expr = '';
obj.inputExpr = '';
obj.args = '';
obj.isEmpty = 1;
obj.numArgs = 0;
obj.version = 1.0;

if (nargin > 0) && ~ischar(varargin{1}),
  error('Input must be a string.');
end

% Get input expression and formal parameters
if (nargin == 1),
  % INLINE(EXPR)
  obj.isEmpty = 0;
  % Use heuristics to get formal parameters
  obj.expr = strtrim(varargin{1});
  % Take care of the case:  inline('2').
  obj.args = char(symvar(obj.expr));
  if isempty(obj.args),
     obj.args = 'x';
  end
  obj.numArgs = size(obj.args,1);
elseif (nargin > 1),
  if ~isstr(varargin{2}),
    % INLINE(EXPR, N)
    N = varargin{2};
    N = N(1);
    obj.isEmpty = 0;
    obj.expr = strtrim(varargin{1});
    obj.numArgs = N+1;
    obj.args = 'x';
    for k = 1:N
      obj.args = strvcat(obj.args, sprintf('P%d',k));
    end
  else
    % INLINE(EXPR, ARG1, ARG2, ...)
    % Formal parameters have been specified explicitly
    obj.isEmpty = 0;
    obj.expr = strtrim(varargin{1});
    obj.args = strvcat(varargin{2:end});
    obj.numArgs = nargin - 1;
  end
end

for k = 1:obj.numArgs
  obj.inputExpr = sprintf('%s %s = INLINE_INPUTS_{%d};', ...
      obj.inputExpr, deblank(obj.args(k,:)), k);
end

obj = class(obj, 'evalExpr');

% -------------------------------------------------------------------------
function s = strtrim(s)
%STRTRIM Remove leading and trailing spaces
if ~isempty(s)
  c = find(~isspace(s));
  s = s(min(c):max(c));
end

% =========================================================================
% symbolic variable/expression parser
% =========================================================================

% -------------------------------------------------------------------------
function vars = symvar(s)
%SYMVAR Determine the symbolic variables in an expression.
%   SYMVAR(S) searches the string S for identifiers other than 'i', 'j',
%   'pi', 'inf', 'nan', 'eps' and common functions.  The variables are
%   returned as a cell array of strings. If no such variable exists,
%   the empty cell array {} is returned. 
%
%   Properly handles subscripted arrays.
%
%   Example
%      symvar('cos(pi*x - beta1)') returns {'beta1';'x'}
%
%   See also FINDSTR.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.1 $ $Date: 2002/11/14 02:47:10 $

if isempty(s), vars = {}; return, end

% Filter these out because they are constants not variables.
filter = {'i','j','pi','inf','Inf','nan','NaN','eps'};

% Before starting, rip out blanks followed by left parentheses,
% as this will not hurt the search for identifiers, but it will
% make it easier to find function names.
[b,e] = findrun(s==' ');
if ~isempty(b)
   if e(end)==length(s)
      e(end) = [];
      b(end) = [];
   end
   t = s(e+1)=='(';
   if any(t)
      b = b(t);
      e = e(t);
      t = makerun(b,e,length(s));
      s(t) = [];
   end
end

% Find variable character locations
c = isletter(s) | (s >= '0' & s <= '9') | s == '_';
v = isletter(s);

% Find the location of quoted strings
q = isquoted(s);
c = c & ~q;
v = v & ~q;

[cb,ce] = findrun(c);
[vb,ve] = findrun(v);

% Find beginning and end of the variables
[b,ic] = intersect(cb,vb);
e = ce(ic);

% Leave in all function names; we'll filter them out later

% Look for a '.' followed immediately by a letter.  It may be part of
% a number in scientific notation ('1.e10') or it may be the start of
% a structure field name ('str.fname').  Either way we don't want it.
d = find((s(1:end-1)=='.' & isletter(s(2:end))));
if ~isempty(d)
  [b,ib] = setdiff(b,d+1);
  e = e(ib);
end

%
% Extract variable names and put them into a cell array of strings.
% Do this by creating a sparse matrix with columns that contain
% the ascii values for the characters in each of the found names.
%

% Column to place each variable
col = zeros(size(s));
col(b) = 1;
mask = col;
mask(e+1) = -1;
mask = cumsum(mask);
col = cumsum(col) .* mask(1:length(col));

% Row for each character of the variable
row = mask;
row(e+1) = b - e - 1;
row = cumsum(row);

if any(row)
  % Make the sparse matrix, convert it to a padded string matrix
  % and then a cell array of strings.
  vars = full(sparse(row(row~=0),col(col~=0),s(logical(mask))))';
  vars(vars==0) = ' ';
  vars = cellstr(char(vars));
else
  vars = {};
end

% Filter out standard function names.
% Find the elements of vars that should be filtered out . . .
%  . . . and remove the undesired symbol names.
vars = setdiff(vars,intersect(vars,filter));
if isempty(vars),
  vars = {};
else
  vars = cellstr(vars);
end

% Produce a column output, and remove function names:
vars = RemoveFcnNames(vars(:));

% -------------------------------------------------------------------------
function LOCAL_VARIABLE_vars = RemoveFcnNames(LOCAL_VARIABLE_vars)
% Prune any entries for which a MATLAB function has been found on the path
LOCAL_VARIABLE_j=[];
for LOCAL_VARIABLE_i = 1 : length(LOCAL_VARIABLE_vars),
    switch which( LOCAL_VARIABLE_vars{LOCAL_VARIABLE_i} )
        case {'', 'variable'},
            % not found on path, or is a (local) variable
        otherwise,
            % is a function, built-in or otherwise
            LOCAL_VARIABLE_j=[LOCAL_VARIABLE_j LOCAL_VARIABLE_i];  % put on the "remove from var list" list
    end
end
LOCAL_VARIABLE_vars(LOCAL_VARIABLE_j)=[];

%------------------------------
function quotemask = isquoted(s)
% Find the location of quoted strings

c = isletter(s) | (s >= '0' & s <= '9') | s == '_';

% Beginning and end of identifiers
[db,de] = findrun(c);

% Location of quotes
q = find(s == '''');
qq = q;

% Location of closing parentheses or periods
p = find(s == ')' | s == ']' | s == '}' | s == '.');

% Find and remove any transposes from the list
inquote = 0;
k = 1;
while k <= length(q)
  % Quotes that are preceded by identifier characters, transposes, or
  % closing parentheses are transposes if we're not in a quoted string
  if ~inquote & ((~isempty(de) & any(q(k) == de+1)) | ...
                 (~isempty(p) & any(q(k) == p+1)) | ...
                 (~isempty(qq) & any(q(k) == qq+1)))
    q(k) = []; % Remove this quote from the list
  else
    k = k + 1;
    inquote = ~inquote;
  end
end

if ~isempty(q)
  if rem(length(q),2)~=0,
    error('Quotes in S are not in pairs.')
  end
  quotemask = makerun(q(1:2:end),q(2:2:end),prod(size(s)));
else
  quotemask = false(size(s));
end

%-------------------------------
function [b,e] = findrun(x)
% Find runs of like elements in a vector.

d = diff([0 x 0]);
b = find(d==1);
e = find(d==-1)-1;

%-------------------------------
function r = makerun(b,e,n)
% Make a boolean run vector of length n given beginning and end locations
r = zeros(1,n+1);
r(b) = 1;
r(e+1) = -1;
r = logical(cumsum(r));
r = r(1:n);

% [EOF] $File: $
