function varargout = solve(varargin)
%SOLVE  Symbolic solution of algebraic equations.
%   SOLVE('eqn1','eqn2',...,'eqnN')
%   SOLVE('eqn1','eqn2',...,'eqnN','var1,var2,...,varN')
%   SOLVE('eqn1','eqn2',...,'eqnN','var1','var2',...'varN')
%
%   The eqns are symbolic expressions or strings specifying equations.  The
%   vars are symbolic variables or strings specifying the unknown variables.
%   SOLVE seeks zeros of the expressions or solutions of the equations.
%   If not specified, the unknowns in the system are determined by FINDSYM.
%   If no analytical solution is found and the number of equations equals
%   the number of dependent variables, a numeric solution is attempted.
%
%   Three different types of output are possible.  For one equation and one
%   output, the resulting solution is returned, with multiple solutions to
%   a nonlinear equation in a symbolic vector.  For several equations and
%   an equal number of outputs, the results are sorted in lexicographic
%   order and assigned to the outputs.  For several equations and a single
%   output, a structure containing the solutions is returned.
%
%   Examples:
%
%      solve('p*sin(x) = r') chooses 'x' as the unknown and returns
%
%        ans =
%        asin(r/p)
%
%      [x,y] = solve('x^2 + x*y + y = 3','x^2 - 4*x + 3 = 0') returns
%
%        x =
%        [ 1]
%        [ 3]
%
%        y =
%        [    1]
%        [ -3/2]
%
%      S = solve('x^2*y^2 - 2*x - 1 = 0','x^2 - y^2 - 1 = 0') returns
%      the solutions in a structure.
%
%        S =
%          x: [8x1 sym]
%          y: [8x1 sym]
%
%      [u,v] = solve('a*u^2 + v^2 = 0','u - v = 1') regards 'a' as a
%      parameter and solves the two equations for u and v.
%
%      S = solve('a*u^2 + v^2','u - v = 1','a,u') regards 'v' as a
%      parameter, solves the two equations, and returns S.a and S.u.
%
%      [a,u,v] = solve('a*u^2 + v^2','u - v = 1','a^2 - 5*a + 6') solves
%      the three equations for a, u and v.
%
%   See also DSOLVE.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.21.4.2 $  $Date: 2004/04/16 22:23:29 $

% Set the Explicit solution (for equations of order 4 or less)
% option on in the Maple Workspace.

maple('_EnvExplicit := true;');

% Collect input arguments together in either equation or variable lists.

eqns = [];
vars = [];
for k = 1:nargin
   v = varargin{k};
   if ~isempty(eqns) & all(isstrprop(v,'alphanum') ...
      | v == '_' | v == ',' | v == ' ')
      v(v == ' ') = [];
      vars = [vars ',' v];
   else
      [t,stat] = maple(v);
      if stat
         error('symbolic:solve:errmsg1', ...
          ''' %s '' is not a valid expression or equation.',v)
      end
      if ~isempty(t)
         eqns = [eqns ',' t];   
      end
   end
end

if isempty(eqns)
   warning('symbolic:solve:warnmsg1','List of equations is empty.')
   varargout = cell(1,nargout);
   varargout{1} = sym([]);
   return
else
   eqns(1) = '{'; eqns(end+1) = '}';
end
neqns = sum(commas(eqns)) + 1;

% Determine default variables and sort variable list.

if isempty(vars)
   vars = ['[' findsym(sym(eqns),neqns) ']'];
else
   vars(1) = '['; vars(end+1) = ']';
end
v = vars;
[vars,stat] = maple('sort',v);
if stat
   error('symbolic:solve:errmsg2', ...
      ''' %s '' is not a valid variable list.',v)
end
vars(1) = '{'; vars(end) = '}';
nvars = sum(commas(vars)) + 1;

if neqns ~= nvars
   warning('symbolic:solve:warnmsg2', ...
      '%d equations in %d variables.',neqns,nvars)
end

% Seek analytic solution.

[R,stat] = maple('solve',eqns,vars);

% If no analytic solution, seek numerical solution.
% First determine the total number of variables in the equations.
seqns = eqns;
seqns(1) = '['; seqns(end) = ']'; seqns = sym(seqns);
total_vars = length(sym([ '[' findsym(seqns) ']' ]));
% Maple's FSOLVE can only be used if the total number of variables
% (total_vars) is equal to the number of variables being solved
% for (nvars).
if (isempty(R) & (nvars == neqns)) & (nvars == total_vars)
   [R,stat] = maple('fsolve',eqns,vars);
end

if stat
   error('symbolic:solve:errmsg3',R)
end

% If still no solution, give up.

if isempty(R) | findstr(R,'fsolve')
   warning('symbolic:solve:warnmsg3','Explicit solution could not be found.');
   varargout = cell(1,nargout);
   varargout{1} = sym([]);
   return
end

% Expand any RootOf.

while ~isempty(findstr(R,'RootOf'))
   k = min(findstr(R,'RootOf'));
   p = findstr(R,'{'); p = max(p(p<k));
   q = findstr(R,'}'); q = min(q(q>k));
   s = R(p:q);
   t = s(min(findstr(s,'RootOf'))+6:end);
   e = min(find(cumsum((t=='(')-(t==')'))==0));
   % RootOf with one argument, possibly an imbedded RootOf.
   checks = s;
   [s,stat] = maple('allvalues',s,'dependent');
   if isequal(checks,s)
      s = maple('evalf',s);
   end
   if isequal(checks,s)
      error('symbolic:solve:errmsg4','Unable to find closed form solution.')
   end
   R = [R(1:p-1) s R(q+1:end)];
end

% Parse the result.

if nvars == 1 & nargout <= 1

   % One variable and at most one output.
   % Return a single scalar or vector sym.

   S = sym([]);
   c = find(commas(R) | R == '}');
   for p = find(R == '=')
      q = min(c(c>p));
      t = trim(R(p+1:q-1));  % The solution (xk)
      S = [S; sym(t)];
   end
   varargout{1} = S;

else

   % Several variables.
   % Create a skeleton structure.

   c = [1 find(commas(vars)) length(vars)];
   S = [];
   for j = 1:nvars
      v = trim(vars(c(j)+1:c(j+1)-1));
      S = setfield(S,v,[]);
   end

   % Complete the structure.

   c = [1 find(commas(R) | R == '{' | R == '}') length(R)];
   for p = find(R == '=')
      q = max(c(c<p));
      v = trim(R(q+1:p-1));  % The variable (x)
      q = min(c(c>p));
      t = trim(R(p+1:q-1));  % The solution (xk)
      S = setfield(S,v,[getfield(S,v); sym(t)]);
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
      error('symbolic:dsolve:errmsg5', ...
         '%d variables does not match %d outputs.',nvars,nargout)
   end
end

%-------------------------

function s = trim(s);
%TRIM  TRIM(s) deletes any leading or trailing blanks.
while s(1) == ' ', s(1) = []; end
while s(end) == ' ', s(end) = []; end

%-------------------------

function c = commas(s)
%COMMAS  COMMAS(s) is true for commas not inside parentheses.
p = cumsum((s == '(') - (s == ')'));
c = (s == ',') & (p == 0);
