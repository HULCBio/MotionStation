function obj = inline(varargin)
%INLINE Construct INLINE object.
%   INLINE(EXPR) constructs an inline function object from the
%   MATLAB expression contained in the string EXPR.  The input
%   arguments are automatically determined by searching EXPR
%   for variable names (see SYMVAR). If no variable exists, 'x'
%   is used.
%
%   INLINE(EXPR, ARG1, ARG2, ...) constructs an inline
%   function whose input arguments are specified by the
%   strings ARG1, ARG2, ...  Multicharacter symbol names may
%   be used.
%
%   INLINE(EXPR, N), where N is a scalar, constructs an
%   inline function whose input arguments are 'x', 'P1',
%   'P2', ..., 'PN'.
%
%   Examples:
%     g = inline('t^2')
%     g = inline('sin(2*pi*f + theta)')
%     g = inline('sin(2*pi*f + theta)', 'f', 'theta')
%     g = inline('x^P1', 1)
%
%   See also SYMVAR.

%   Steven L. Eddins, August 1995
%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.20.4.1 $  $Date: 2004/03/02 21:47:09 $

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

if (nargin > 0) && (~ischar(varargin{1}))
  error('Input must be a string.');
end

% Get input expression and formal parameters
if (nargin == 1)
  % INLINE(EXPR)
  obj.isEmpty = 0;
  % Use heuristics to get formal parameters
  obj.expr = strtrim(varargin{1});
  % Take care of the case:  inline('2').
  obj.args = char(symvar(obj.expr));
  if isempty(obj.args)
     obj.args = 'x';
  end
  obj.numArgs = size(obj.args,1);
elseif (nargin > 1)
  if (~ischar(varargin{2}))
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

obj = class(obj, 'inline');

%-----------------------------------------
function flag = is_variable(expr, idx, len)
%IS_VARIABLE Is a substring a legitimate variable.

varChars = [real('a'):real('z') ...
      real('A'):real('Z') ...
      real('0'):real('9') real('_')];

flag = ~ismember(expr(idx-1), varChars) & ...
    ~ismember(expr(idx+len), varChars);

%------------------------------------------
function s1 = strtrim(s)
%STRTRIM Trim spaces from string.

if isempty(s)
    s1 = s;
else
  % remove leading and trailing blanks (including nulls)
  c = find(s ~= ' ' & s ~= 0);
  s1 = s(min(c):max(c));
end
