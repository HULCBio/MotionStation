function varargout = dsolve(varargin)
%DSOLVE Symbolic solution of ordinary differential equations.
%   DSOLVE('eqn1','eqn2', ...) accepts symbolic equations representing
%   ordinary differential equations and initial conditions.  Several
%   equations or initial conditions may be grouped together, separated
%   by commas, in a single input argument.
%
%   By default, the independent variable is 't'. The independent variable
%   may be changed from 't' to some other symbolic variable by including
%   that variable as the last input argument.
%
%   The letter 'D' denotes differentiation with respect to the independent
%   variable, i.e. usually d/dt.  A "D" followed by a digit denotes
%   repeated differentiation; e.g., D2 is d^2/dt^2.  Any characters
%   immediately following these differentiation operators are taken to be
%   the dependent variables; e.g., D3y denotes the third derivative
%   of y(t). Note that the names of symbolic variables should not contain
%   the letter "D".
%
%   Initial conditions are specified by equations like 'y(a)=b' or
%   'Dy(a) = b' where y is one of the dependent variables and a and b are
%   constants.  If the number of initial conditions given is less than the
%   number of dependent variables, the resulting solutions will obtain
%   arbitrary constants, C1, C2, etc.
%
%   Three different types of output are possible.  For one equation and one
%   output, the resulting solution is returned, with multiple solutions to
%   a nonlinear equation in a symbolic vector.  For several equations and
%   an equal number of outputs, the results are sorted in lexicographic
%   order and assigned to the outputs.  For several equations and a single
%   output, a structure containing the solutions is returned.
%
%   If no closed-form (explicit) solution is found, an implicit solution is
%   attempted.  When an implicit solution is returned, a warning is given.
%   If neither an explicit nor implicit solution can be computed, then a
%   warning is given and the empty sym is returned.  In some cases involving
%   nonlinear equations, the output will be an equivalent lower order
%   differential equation or an integral.
%
%   Examples:
%
%      dsolve('Dx = -a*x') returns
%
%        ans = exp(-a*t)*C1
%
%      x = dsolve('Dx = -a*x','x(0) = 1','s') returns
%
%        x = exp(-a*s)
%
%      y = dsolve('(Dy)^2 + y^2 = 1','y(0) = 0') returns
% 
%        y =
%        [  sin(t)]
%        [ -sin(t)]
%
%      S = dsolve('Df = f + g','Dg = -f + g','f(0) = 1','g(0) = 2')
%      returns a structure S with fields
%
%        S.f = exp(t)*cos(t)+2*exp(t)*sin(t)
%        S.g = -exp(t)*sin(t)+2*exp(t)*cos(t)
%
%      Y = dsolve('Dy = y^2*(1-y)')
%      Warning: Explicit solution could not be found; implicit solution returned.
%      Y =
%      t+1/y-log(y)+log(-1+y)+C1=0
%
%      dsolve('Df = f + sin(t)', 'f(pi/2) = 0')
%      dsolve('D2y = -a^2*y', 'y(0) = 1, Dy(pi/a) = 0')
%      S = dsolve('Dx = y', 'Dy = -x', 'x(0)=0', 'y(0)=1')
%      S = dsolve('Du=v, Dv=w, Dw=-u','u(0)=0, v(0)=0, w(0)=1')
%      w = dsolve('D3w = -w','w(0)=1, Dw(0)=0, D2w(0)=0')
%      y = dsolve('D2y = sin(y)'); pretty(y)
%
%   See also SOLVE, SUBS.

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 1.37.4.3 $  $Date: 2004/04/16 22:21:57 $

narg = nargin;

% The default independent variable is t.
x = 't';

if (narg==0) | all(varargin{narg}==' ')
   warning('symbolic:dsolve:warnmsg3','Empty equation')
   varargout{1} = sym([]);
   return
end

% Pick up the independent variable, if specified.
if all(varargin{narg} ~= '='),
   x = varargin{narg}; narg = narg-1;
end
% Concatenate equation(s) and initial condition(s) inputs into SYS.
sys = varargin{1};
for k = 2: narg
   sys = [sys ', ' varargin{k}];
end

% Break SYS into pieces. Each such piece, Dstr, begins with the first
% character following a "D" and ends with the character preceding the
% next consecutive "D". Loop over each Dstr and do the following:
%   o add to the list of dependent variables
%   o replace derivative notation. E.g., "D3y" --> "(D@@3)y"
%
% A dependent variable is defined as a variable that is preceded by "Dk",
% where k is an integer.
%
% new_sys looks like:  eqn(s), initial condition(s)  (i.e., no brackets)
% var_set looks like: { x(t), y2(t), ... }           (i.e., with brackets)

var_set = '{';   % string representing Maple set of dependent variables

% Add dummy "D" so that last Dstr acts like all Dstr's
d = setdiff(find(sys=='D'),strfind(sys,'Dirac('));
d(end+1) = length(sys)+1;

new_sys = sys(1:d(1)-1);   % SYS rewritten with (D@@k)y notation

for kd = 1:length(d)-1
   Dstr = sys(d(kd)+1:d(kd+1)-1);
   iletter = find(isletter(Dstr));    % index to letters in Dstr

   % Replace Dky with (D@@k)y
   if isempty(iletter)
       error('symbolic:dsolve:InvalidVariableName','D is a reserved variable name.')
   elseif iletter(1)==1    % First derivative case (Dy)
      new_sys = [new_sys '(D' Dstr(1:iletter(1)-1) ')' Dstr(iletter(1):end)];
   else
      new_sys = [new_sys '(D@@' Dstr(1:iletter(1)-1) ')' Dstr(iletter(1):end)];
   end

   % Store the dependent variable. Find this variable by looking at the
   % characters following the derivative order and pulling off the first
   % consecutive chunk of alphanumeric characters.
   Dstr1 = Dstr(iletter(1):end);
   ialphanum = find(~isalphanumunder(Dstr1),1,'first');
   if isempty(ialphanum), ialphanum = length(Dstr1) + 1; end
   var_set = [var_set Dstr1(1:ialphanum-1) ','];
end

% Get rid of duplicate entries in var_set
var_set = strrep(var_set, ',,' , ',');
var_set(end) = '}';
var_set = maple([var_set ' intersect ' var_set]);

% Generate var_str, the Maple string representing the set of dependent
%    variables.
% Replace all dependent variables with their functional equivalents,
%    i.e., replace y -> (y)(x).

% Break the system string into its equation and initial condition parts.
% This is done by looking for the first occurrence of "y(", where y is a
% dependent variable.
indx_ic = length(new_sys);   % points to starting character of ic string
ic_str = [];                 % initialize the initial condition string
eq_str = new_sys;            % initialize the equation string
var_str = '{';                          % Maple set of dependent variables
vars = [',' var_set(2:end-1) ','];      % preceding comma delimits variable
vars(find(vars==' '))=[];               % deblank
kommas = find(vars==',');

for k = 1: length(kommas)-1
   v = vars(kommas(k)+1:kommas(k+1)-1);  % v is a dependent variable
   if isequal(v,'C')
      error('symbolic:dsolve:errmsg1','Can not use C as a variable in DSOLVE.')
   end

   % Add to set of dependent variables.
   var_str = [var_str v '(' x '),'];

   % Look for first occurrence of "v(". If it's before the first occurrence
   % of the previous dependent variable, change value of indx_ic and
   % shorten the equation string.
   indx = findstr(eq_str, [v '(']);
   %remove instances where v is not entire variable name
   indx(isalphanumunder(eq_str(indx-1))) = [];
   if isempty(indx), indx = indx_ic; end
   indx_ic = min(indx_ic,indx(1));
   eq_str = new_sys(1:min(indx_ic));
end

% Finish var_str
var_str(end) = '}';

% Stuff after the last comma belongs in the initial condition string
if indx_ic < length(new_sys)
   last_comma = max(find(eq_str==','));
   ic_str = new_sys(last_comma:end);
   eq_str = eq_str(1: last_comma-1);
end

% In the equation string, replace all occurrences of "y" with "(y)(x)".
for j = 1:length(kommas)-1
   v = vars(kommas(j)+1:kommas(j+1)-1);
   m = length(v);
   e = length(eq_str);
   %remove instances where v is not entire variable name
   indx = findstr(eq_str, v);
   indx(isalphanumunder(eq_str(indx-1))|isalphanumunder(eq_str(indx-1))) = [];
   for k = fliplr(indx)
      if k+m > e | ~isvarname(eq_str(k:k+m))
         eq_str = [eq_str(1:k-1) '(' v ')(' x ')' eq_str(k+m:end)];
      end
   end
end

% In the ic string, replace all occurrences of "y" with "(y)".
for j = 1:length(kommas)-1
   v = vars(kommas(j)+1:kommas(j+1)-1);
   m = length(v);
   e = length(ic_str);
   for k = fliplr(findstr(v,ic_str))
      if k+m > e | ~isvarname(ic_str(k:k+m))
         ic_str = [ic_str(1:k-1) '(' v ')' ic_str(k+m:end)];
      end
   end
end

% Convert system to rational form and solve
solflag = ''; errorflag = 0;
% Be sure that there are equal numbers of dependent variables and
% differential equations.
Eqn = eq_str; Vars = var_str;
% Save the original variable string in var_str0.
var_str0 = var_str;
% Change the Equations and Variables into sym vectors.
Eqn = sym([ '[' Eqn ']' ]);
Vars(1) = '['; Vars(end) = ']'; Vars = sym(Vars);
LE = length(Eqn); LV = length(Vars);
% If the number of equations is less than the number of variables . . .
if LE < LV
   % then reduce the number of variables.
   Vars = Vars(1:LE);
% If conversely, the number of equations exceed the number of variables . . .
elseif LE > LV
   % then produce an error.
   errorflag = 1;
end
% Turn Eqn and Vars back into Maple compatiable strings.
LV = length(Vars);
Vars = map2mat(char(Vars)); Eqn = map2mat(char(Eqn));
var_str = brackets(Vars);
if isequal(Eqn(1),'[') & isequal(Eqn(end),']')
   Eqn(1) = []; Eqn(end) = [];
   eq_str = Eqn;
end

[R,stat] = maple('dsolve', ...
   ['convert({',eq_str,ic_str,'},fraction)'], var_str, 'explicit');

if stat & errorflag
   error('symbolic:dsolve:errmsg2','There are more ODEs than variables.')
end

% If a "sum" solution is returned, try to expand the result.
if any(findstr(R,'sum'))
   r = maple('rhs',R);
   for k = fliplr(findstr(r,'sum'))
      % Find matching right parenthesis
      e = k+2+min(find(cumsum(r(k+3:end)=='(') - cumsum(r(k+3:end)==')')==0));
      s = r(k:e);  % 'sum(...)'
      % Expand RootOf
      s = maple('allvalues',s);
      % Replace each '_C1[_R]' with 'Cj'
      p = findstr(s,'_C1');
      for j = length(p):-1:1
         s = [s(1:p(j)-1) 'C' num2str(j) s(p(j)+7:end)];
      end
      % Maple combines the terms
      maple(['s := [' s '];']);
      s = maple('add','s[q]','q=1..nops(s)');
      maple(['s := ''s'';']);
      % Insert the expanded sum back into the result.
      r = [r(1:k-1) s r(e+1:end)];
   end
   R = [maple('lhs',R) ' = ' r];
end

% If a "RootOf" is returned by Maple, or if an attempt at an
% explicit solution fails, try an implicit solution.
if ~isempty(findstr(R,'RootOf')) | isempty(R)
   Rexplicit = R;  % Keep a copy of the explicit solution.
   [R,stat] = maple('dsolve', ...
   ['convert({',eq_str,ic_str,'},fraction)'], var_str, 'implicit');
   solflag = 'implicit';
   % If the implicit solution is empty, return the explicit solution.
   if isempty(R) | ~isempty(findstr(R,'RootOf'))
      R = Rexplicit;
      solflag = 'explicit';
   end
end

if stat
   error('symbolic:dsolve:errmsg3',R)
end

% If we have an implicit solution that does NOT contain a RootOf Expression...
% if isequal(solflag,'implicit') & isempty(findstr(R,'RootOf'))
if isequal(solflag,'implicit')
   % Replace expressions like y(x) by y in the Maple return.
   % Change var_str from {y(x)} to y(x).
   var_str(1) = []; var_str(end) = [];
   % Let New_var be y (i.e, strip (x) from y(x) ).
   New_var = strrep(var_str,[ '(' x ')' ], '');
   % Replace y(x) by y in R
   R = strrep(R,var_str,New_var);
   % Remove leading underscores in constants.
   R = strrep(R,'_C','C');
   warning('symbolic:dsolve:warnmsg1', ...
      'Explicit solution could not be found; implicit solution returned.');
   s = findstr(R,'{');
   if ~isempty(s)
      e = findstr(R,'}');
      v = sym([]);
      for k = 1:length(s);
         v = [v; sym(R(s(k)+1:e(k)-1))];
      end
   else
      v = sym(R);
   end
   varargout{1} = v;
   return;
end

% If no solution, give up
if isempty(R)
   warning('symbolic:dsolve:warnmsg2','Explicit solution could not be found.');
   varargout = cell(1,nargout);
   varargout{1} = sym([]);
   return
end

% Remove leading underscores in constants.
R = strrep(R,'_C','C');
R(R=='{') = [];
R(R=='}') = [];
R = ['[' R ']'];
% Create a list in the Maple workspace.
maple(['DList := ' R]);
nsols = length(sym(R));
% Determine the number of dependent variables and alphabetize them.
vars(1) = '['; vars(end) = ']';
svars = sym(maple('sort',vars,'lexorder'));
nvars = length(svars);
% Parse the right and left hand sides of the solutions.
S = [];
% Remove the argument from the dependent variables (i.e., y(t)
% is replaced by y, x(t) by x, etc.
Dvars = strrep(var_str0,[ '(' x ')' ],'');
% Find the list of dependent variables
Flist = maple(['indets(DList,''specfunc(anything,' Dvars ')'');']);
% Compute the number of dependent variables.
ndvars = length(findstr(Flist,',')) + 1;
if ndvars > nsols
   varargout{1} = sym(R);
   return;
end
for j = 1:nsols
   RHS{j} = ...
      sym(maple('rhs',['DList[' num2str(j) ']']));
   LHS{j} = ...
     strrep(maple('lhs',['DList[' num2str(j) ']']),[ '(' x ')' ],'');
   % Determine whether an implicit solution has been returned.
   impflag(j) = any( ~(isletter(LHS{j}) | ...
      (LHS{j} >= '0' & LHS{j} <= '9') | (LHS{j} == '_')) );
      % LHS{j} = strrep(LHS{j},'C',''); % Set all constants Cj = j.
   eqn{j} = sym([LHS{j} ' = ' char(RHS{j})]);
end

% Clear DList from the Maple workspace.
maple('DList := ''DList'';');
% n is the number of solutions per dependent variable
nvars = LV;
n = floor(nsols/nvars);
if (n == 0), n = 1; end
% Sort the left hand side alphabetically if there are more than one
% dependent variable.
if ( sum(impflag) == 0 )
   [LHS,ind] = sort(LHS);
   m = length(LHS)/n;
   RHS = RHS(ind);
elseif n~=1 & (any(impflag) == 1)
   in1 = find(impflag == 0); % Index for explicit solution.
   in2 = find(impflag == 1); % Index for implicit solution.
   rhs = [RHS{in1(:)},RHS{in2(:)}].';
   varargout{1} = rhs;
   return
else
   m = nsols;
   ind = 1:m;
end

% Sort the right hand side alphabetically.
for k = 1:m
   rhs{k} = [RHS{(1+(k-1)*n):(k*n)}].';
   lhs{k} = LHS{1+(k-1)*n};
end

% If the output contains int, make it a symbolic vector.


if nvars == 1 & nargout <= 1

   % One variable and at most one output.
   % Return a single scalar or vector sym.
   varargout{1} = rhs{1};

else

   % Form the output structure
   for j = 1:nvars
      S = setfield(S,lhs{j},rhs{j});
   end
   
   if nargout <= 1

      % At most one output, return the structure.
      varargout{1} = S;

   elseif nargout == nvars

      % Same number of outputs as variables.
      % Match results in lexicographic order to outputs.
      v = fieldnames(S);
      for j = 1:nvars
         varargout{j} = getfield(S,v{j});
      end

   else
      error('symbolic:dsolve:errmsg4', ...
         '%d variables does not match %d outputs.',nvars,nargout)
   end
end

% end

%-------------------------

function S = brackets(S)
% BRACKETS  BRACKETS(S) places commas about strings that look like
%   functions or vectors of functions.
%   BRACEKTS(f(t)) returns {f(t)} while BRACKETS([f(t),g(t)]) returns
%   {f(t),g(t)}.

if isequal(S(1),'[') & isequal(S(end),']')
   S(1) = '{'; S(end) = '}';
else
   S = [ '{' S '}' ];
end

%-------------------------

function r = map2mat(r)
% MAP2MAT Maple to MATLAB string conversion.
%   MAP2MAT(r) converts the Maple string r containing
%   matrix, vector, or array to a valid MATLAB string.
%
%   Examples: map2mat(matrix([[a,b], [c,d]])  returns
%             [a,b;c,d]
%             map2mat(array([[a,b], [c,d]])  returns
%             [a,b;c,d]
%             map2mat(vector([[a,b,c,d]])  returns
%             [a,b,c,d]

% Deblank.
r(findstr(r,' ')) = [];
% Special case of the empty matrix or vector
if strcmp(r,'vector([])') | strcmp(r,'matrix([])') | ...
   strcmp(r,'array([])')
   r = [];
else
   % Remove matrix, vector, or array from the string.
   r = strrep(r,'matrix([[','['); r = strrep(r,'array([[','[');
   r = strrep(r,'vector([','['); r = strrep(r,'],[',';');
   r = strrep(r,']])',']'); r = strrep(r,'])',']');
end

%-------------------------

function res = isalphanumunder(x)
res = isstrprop(x,'alphanum') | (x=='_');
