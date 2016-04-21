function NEWf = subs(OLDf,OLDexpr,NEWexpr,swap)
%SUBS   Symbolic substitution.  Also used to evaluate expressions numerically.
%   SUBS(S) replaces all the variables in the symbolic expression S with
%   values obtained from the calling function, or the MATLAB workspace.
%   
%   SUBS(S,NEW) replaces the free symbolic variable in S with NEW.
%   SUBS(S,OLD,NEW) replaces OLD with NEW in the symbolic expression S.
%   OLD is a symbolic variable, a string representing a variable name, or
%   a string (quoted) expression. NEW is a symbolic or numeric variable
%   or expression.  That is, SUBS(S,OLD,NEW) evaluates S at OLD = NEW.
%
%   If OLD and NEW are cell arrays of the same size, each element of OLD is
%   replaced by the corresponding element of NEW.  If S and OLD are scalars
%   and NEW is an array or cell array, the scalars are expanded to produce
%   an array result.  If NEW is a cell array of numeric matrices, the
%   substitutions are performed elementwise (i.e., subs(x*y,{x,y},{A,B})
%   returns A.*B when A and B are of class DOUBLE).  If S is an expression
%   of N symbolic variables x1,x2,...,xN and Y1,Y2,...,YN are matrices of 
%   class DOUBLE, then subs(S,{x1,x2,...,xN},{Y1,Y2,...YN}) returns output
%   of class DOUBLE.
%
%   If SUBS(S,OLD,NEW) does not change S, then SUBS(S,NEW,OLD) is tried.
%   This provides backwards compatibility with previous versions and 
%   eliminates the need to remember the order of the arguments.
%   SUBS(S,OLD,NEW,0) does not switch the arguments if S does not change.
%
%   Examples:
%     Single input:
%       Suppose a = 980 and C1 = 3 exist in the workspace.
%       The statement
%          y = dsolve('Dy = -a*y')
%       produces
%          y = exp(-a*t)*C1
%       Then the statement
%          subs(y)
%       produces
%          ans = 3*exp(-980*t)
%
%     Single Substitution:
%       subs(a+b,a,4) returns 4+b.
%
%     Multiple Substitutions:
%       subs(cos(a)+sin(b),{a,b},{sym('alpha'),2}) returns
%       cos(alpha)+sin(2)
%   
%     Scalar Expansion Case: 
%       subs(exp(a*t),'a',-magic(2)) returns
%
%       [   exp(-t), exp(-3*t)]
%       [ exp(-4*t), exp(-2*t)]
%
%     Multiple Scalar Expansion:
%       subs(x*y,{x,y},{[0 1;-1 0],[1 -1;-2 1]}) returns
%         0  -1
%         2   0
%
%   See also SUBEXPR.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.39.4.2 $  $Date: 2004/04/16 22:23:10 $

OLDf = sym(OLDf);
% Find the list of symbolic variables in OLDf that do NOT contain pi.
vars = findsym(OLDf);
% If OLDf has no symbolic variables, just return OLDf.
if isempty(vars), NEWf = double(OLDf); return, end
% Make vars a sym and place vars in a cell VaR.
VaR = num2cell(sym([ '[' vars ']' ]));
% Compute the number of symbolic variables (excluding pi).
nvars = length(VaR);

if nargin == 1
   % Determine which variables are in the MATLAB workspace and
   % place them in the cell OLDexpr.  Similarly, place the values of 
   % variables in the MATLAB workspace into the cell NEWexpr.

   for k = 1:nvars
      eflag(k) = evalin('caller',['exist(''' char(VaR{k}) ''',''var'')']);
      if ~eflag(k)
         eflag(k) = 2*evalin('base',['exist(''' char(VaR{k}) ''',''var'')']);
      end
   end
   j = find(eflag);
   OLDexpr = VaR(j);
   for k = 1:length(j)
      if eflag(k) == 1
         NEWexpr{k} = evalin('caller',char(VaR{j(k)}));
      else
         NEWexpr{k} = evalin('base',char(VaR{j(k)}));
      end
   end
end

if nargin == 2
   NEWexpr = OLDexpr;
   OLDexpr = findsym(OLDf,1);
   if isempty(OLDexpr), OLDexpr = 'x'; end
end

% Flag for Maple substitution.
mapflag = 0;  
% Check for appropriate forms of input.
msg = inputchk(OLDf,OLDexpr,NEWexpr);
if ~isempty(msg), error('symbolic:sym:subs:errmsg1',msg), end

% Case 0.  OLDexpr and NEWexpr are both character strings.
if ( isa(OLDexpr,'char') & ~iscell(OLDexpr) ) & ...
   ( isa(NEWexpr,'char') & ~iscell(NEWexpr) )
   NEWf = sym(idrep(char(OLDf),OLDexpr,NEWexpr));
   if nargin < 4, swap = 1; end
   if isequal(NEWf,OLDf) & swap & ~nochange(NEWf,OLDexpr,NEWexpr)
      NEWf = sym(idrep(char(OLDf),NEWexpr,OLDexpr));
   end
   return;
end

if ( isa(OLDexpr,'char') & ~iscell(OLDexpr) ), OLDexpr = sym(OLDexpr); end
if ( isa(NEWexpr,'char') & ~iscell(NEWexpr) ), NEWexpr = sym(NEWexpr); end

% Case 1.  OLDexpr and NEWexpr are 1-by-1 variables.
if ( all(size(OLDexpr) == 1) & all(size(NEWexpr) == 1) )
   if isa(OLDexpr,'cell'), OLDexpr = OLDexpr{1}; end
   if isa(NEWexpr,'cell'), NEWexpr = NEWexpr{1}; end
   if isa(NEWexpr,'double')
      NeW_t = idrep(char(OLDf),char(OLDexpr),'NEWexpr');
      eval('NEWf = eval(vectorize(map2mat(NeW_t)));' , 'mapflag = 1;');
   end
   if (mapflag == 1) | ~isa(NEWexpr,'double')
      % First test whether the substitution tries to evaluate a
      % Maple procedure (like D, C, etc.)
      proctest = maple(['whattype(eval(subs(' char(sym(OLDexpr)) ' = ' ...
            char(sym(NEWexpr)) ',' char(OLDf) ')));']);
      % If it is a procedure, then do NOT eval . . .
      if length(findstr(proctest,'procedure'))
         [res,stat] = maple(['(subs(' char(sym(OLDexpr)) ' = ' ...
               char(sym(NEWexpr)) ',' char(OLDf) '));']);
      % . . . otherwise, evaluate the statement.
      else
         [res,stat] = maple(['eval(subs(' char(sym(OLDexpr)) ' = ' ...
               char(sym(NEWexpr)) ',' char(OLDf) '));']);
      end
      if stat  % If maple encounters a singularity or error.
         error('symbolic:sym:subs:errmsg2',res)
      else
         NEWf = sym(res);
      end
   end

% Case 2.  OLDexpr is a 1-by-1 while NEWexpr is an m-by-n.
elseif all(size(OLDexpr) == 1)
   % If NEWexpr is a double, then substitute the string 'NEWexpr'
   % for OLDexpr in OLDf and then do a MATLAB eval on OLDf('NEWexpr') with NEWexpr.
   if isa(NEWexpr,'double') & (nvars == 1)
      try
         NEWf = eval(vectorize(maple(['eval(subs(' char(sym(OLDexpr)) ...
          ' = NEWexpr,' char(OLDf) '));' ])));
      catch
         if ~isa(NEWexpr,'cell'), NEWexpr = num2cell(NEWexpr); end
      % Define a function F corresponding to the symbolic expression OLDf.
         maple(['F := ' char(sym(OLDexpr)) ' -> ' char(OLDf)]);
         if isempty(NEWexpr)
            NEWf = map2mat(maple('map','F',char(sym([]))));
            NEWf = double(sym(NEWf));
         else
            NEWf = double(sym(maple('map','F',char(sym([NEWexpr{:}])))));
            NEWf = reshape(NEWf,size(NEWexpr));
         end
         % Clear F from the Maple workspace.
         maple( 'F := ''F'';');
      end
   else
      if ~isa(NEWexpr,'cell'), NEWexpr = num2cell(NEWexpr); end
      % Define a function F corresponding to the symbolic expression OLDf.
      maple(['F := ' char(sym(OLDexpr)) ' -> ' char(OLDf)]);
         if isempty(NEWexpr)
            NEWf = sym(map2mat(maple('map','F',char(sym([])))));
         else
            NEWf = sym(maple('map','F',char(sym([NEWexpr{:}]))));
            NEWf = reshape(NEWf,size(NEWexpr));
         end
      % Clear F from the Maple workspace.
      maple( 'F := ''F'';');
   end

% Case 3. OLDexpr = {x1,x2,...,xn} or  OLDexpr = [x1,x2,...,xn]
%   and  NEWexpr = {y1,y2,...yn} or NEWexpr = [y1,y2,...yn].
elseif ( length(OLDexpr) == length(NEWexpr) )
   if ~iscell(OLDexpr), OLDexpr = num2cell(OLDexpr); end
   if ~iscell(NEWexpr), NEWexpr = num2cell(NEWexpr); end
   % Determine whether the all if the elements of NEWexpr are doubles or chars.
   for j = 1:length(NEWexpr)
      TdouB(j) = isa(NEWexpr{j},'double');
      TdoubY(j) = isa(NEWexpr{j},'char'); TdoubX(j) = isa(OLDexpr{j},'char');
      SiZCeLl(j,:) = size(NEWexpr{j});
      % Label the substitution cells.
      eval(['CaQ' int2str(j) ' = NEWexpr{j};']);
      % Create a cell of 'string' labels.
      CaQ{j} = ['CaQ' int2str(j)];
   end
   if (nvars == length(NEWexpr)) & all(TdouB)
      for j = 1:length(NEWexpr), SiZCeLl(j,:) = size(NEWexpr{j}); end
      if ~isequal(repmat(SiZCeLl(1,:),size(SiZCeLl,1),1),SiZCeLl)
         error('symbolic:sym:subs:errmsg3',['Elements of the substitution cell array' ...
                 ' must be of the same size.']);
      end
      NEWf = maple(['eval(subs(' celleqn(OLDexpr,CaQ) ',' char(OLDf) '));']);
      if findstr(NEWf,'matrix') | findstr(NEWf,'vector') | findstr(NEWf,'array')
         NEWf = map2mat(NEWf);
      end
      eval('NEWf = eval(vectorize(NEWf));','mapflag = 1;');
      if (mapflag == 1)
         NEWf = maple(['eval(subs(' celleqn(OLDexpr,NEWexpr) ',' char(OLDf) '));']);
         NEWf = sym(maple('evalm',strrep(NEWf,'MATRIX','array')));
      end
   elseif (all(TdoubY) | all(TdoubX))
      NEWf = char(OLDf);
      for j = 1:length(NEWexpr)
         NEWf = idrep(char(NEWf),char(sym(OLDexpr{j})),char(sym(NEWexpr{j})));
         NEWf = sym(map2mat(maple('evalm',NEWf)));
      end
   else
      if isempty(vars), vars = 'x'; end
      for j = 1:length(OLDexpr)
         vars = idrep(vars,char(sym(OLDexpr{j})),char(sym(NEWexpr{j})));
      end
      eval('NEWf = sym(vecsubs(OLDf,OLDexpr,symcll(vars)));' , 'mapflag = 1;' );
      if mapflag == 1
         NEWf = maple(['eval(subs(' celleqn(OLDexpr,NEWexpr) ',' char(OLDf) '));']);
         NEWf = sym(maple('evalm',strrep(NEWf,'MATRIX','array')));
      end
   end
else
   NEWf = OLDf;
end

if nargin < 4, swap = 1; end
if isequal(NEWf,OLDf) & swap & ~nochange(NEWf,OLDexpr,NEWexpr)
   NEWf = subs(OLDf,NEWexpr,OLDexpr,0);
end

%-------------------

function Z = celleqn(X,Y)
% CELLEQN Takes the elements of the cells X = {x1,x2,...,xn}
%   and Y = {y1,y2,...,yn} and creates a list of Maple equations
%   {x1 = y1,x2 = y2, ... , xn = yn}.

% Be sure that X and Y are cells.
if ~iscell(X), X = num2cell(X); end
if ~iscell(Y), Y = num2cell(Y); end

if ~(all(size(X) == size(Y)))
   error('symbolic:sym:subs:errmsg4','The input cells must be of the same size.')
end

for j = 1:length(X)
   Z{j} = [ char(X{j}) ' = ' char(sym(Y{j})) ',' ];
end

Z = [Z{:}]; k = findstr(Z, ','); Z(k(end)) = [];
Z = [ '{' Z '}' ];

%-------------------------

function v = charcll(vars)
%CHARCLL Takes a comma separated list and returns a cell of chars.

k = [-1 find(commas(vars) == 1) length(vars)+1];
for i = 1:length(k)-1,
   v{i} = vars(k(i)+2:k(i+1)-1);
end

%-------------------------

function c = commas(s)
%COMMAS  COMMAS(s) is true for commas not inside parentheses.
p = cumsum((s == '(') - (s == ')'));
c = (s == ',') & (p == 0);

%-------------------------

function s = idrep(s1,s2,s3)
%IDREP Replaces all occurences of s2 in the string s1 by s3.
%   For example, idrep(x*exp(x*y),x,W) returns W*exp(W*y).

% Take care of trivial cases:
%   s2 > s1
%   s1 is empty
%   s2 is empty
if (length(s2) > length(s1)) | isempty(s2) | isempty(s1),
  s=s1;
  return;
end;

% Place non-identifiers at the beginning and end of the string.
s=[]; s1 = [ '#' s1 '#' ];
% Find all occurrences of s2 in s1
s2len=length(s2);
s2pos=findstr(s1,s2);

% Enclose s3 in parens.
s3 = ['(' s3 ')'];

% Build resulting string
s1pos=1;
for i=1:length(s2pos),
  if ~isalphanum(s1(s2pos(i)-1)) & ~isalphanum(s1(s2pos(i)+s2len))
     s=[s,s1(s1pos:s2pos(i)-1),s3];
     s1pos=s2pos(i)+s2len;
  end
end;
s=[s,s1(s1pos:length(s1))];
% Remove the #'s at the beginning and end of s.
s(1) = []; s(end) = [];

%-------------------------

function B = isalphanum(S)
%ISALPHANUM True for alpha-numeric characters.
%   For a string S, ISALPHANUM returns 1 for alpha-numeric
%   characters (or underscores) and 0 otherwise.
%   Example:
%      S = 'x*exp(x - y) + cosh(x*z^2)';
%      isalphanum(S)  returns
%      (1,0,1,1,1,0,1,0,0,0,1,0,0,0,0,1,1,1,1,0,1,0,1,0,1,0)

B = isletter(S) | (S >= '0' & S <= '9') | (S == '_');

%-------------------------

function msg = inputchk(f,x,y)
%INPUTCHK Generate error message for invalid cases
%  There are six possible legal cases
%  1) Inputs are cell arrays of the same length.
%  2) Inputs are sym arrays of the same size.
%  3) x is a scalar sym and sym(y) is legal
%  4) x is a scalar sym and y is a cell array
%  5) x and y are both single strings.
%  6) x is a varname string and y is a single string or sym(y) is legal.

msg = '';

if isa(x,'sym') & length(x)==1
  if ischar(y) & size(y,1)~=1,
    msg = 'String substitutions require 1-by-m strings.';
  end
elseif ischar(x) & ischar(y) & ...
      (length(sym(x))~=1 | length(sym(y))~=1) & isvarname(char(x))
  msg = 'String substitutions require 1-by-m strings.';
elseif (ischar(x) | isa(x,'sym')) & isvarname(char(x))
  if ischar(y) & size(y,1)~=1,
    msg = 'String substitutions require 1-by-m strings.';
  end
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

function n = nochange(expr,OLDexpr,NEWexpr)
% NOCHANGE returns 0 if a Symbolic Substitution does not
%   change the expression.
%   NOCHANGE(expr,OLD,NEW) is 0 if the symbolic variables
%   in both OLDexpr and NEWexpr are NOT symbolic variables
%   in expr.
%   Examples:  NOCHANGE(x^2,y,z)  returns  0
%              NOCHANGE(x^2,x,z)  returns  1.

% Determine whether the variables in OLDexpr are valid 
% symbolic variables in expr.
vartest = [ '{' findsym(sym(expr)) '}' ];
if ~isa(OLDexpr,'cell'), OLDexpr = num2cell(sym(OLDexpr)); end
if ~isa(NEWexpr,'cell'), NEWexpr = num2cell(sym(NEWexpr)); end
varold = []; varnew = [];
for j = 1:length(OLDexpr)
   t = findsym(sym(OLDexpr{j}));
   if ~isempty(t)
      varold = [varold t ','];
   end
end
if ~isempty(varold)
   varold(end) = [];
end
varold = [ '{' varold '}' ];
for j = 1:length(NEWexpr)
   t = findsym(sym(NEWexpr{j}));
   if ~isempty(t)
      varnew = [varnew t ','];
   end
end
if ~isempty(varnew)
   varnew(end) = [];
end
varnew = [ '{' varnew '}' ];
vartest = maple([ vartest ' intersect ' ...
          maple([ varold ' union ' varnew ]) ]);
n = isequal(vartest,'{}');

%-------------------------

function v = symcll(vars)
%SYMCLL Takes a comma separated list and returns a cell of syms.

k = [-1 find(commas(vars) == 1) length(vars)+1];
for i = 1:length(k)-1,
   v{i} = sym(vars(k(i)+2:k(i+1)-1));
end

%-------------------------

function r = vecsubs(f,x,y)
%VECSUBS Substitutes a vector of variables y for x in f.
%    If f = (f1(x), f2(x), ... , fn(x)) with x and y 1-by-1 syms
%    then VECSUBS(f,x,y) returns (f1(y), f2(y), ... , fn(y)).
%    If f = f(x) with x = (x1, x2, ..., xn) and y = (y1,y2,...,yn)
%    then VECSUBS(f,x,Y) produces f(y) = f(y1,y2, ... ,yn).  
%    Moreover, all multiplication, division, and exponentiation is
%    vectorized (i.e., f = x1*x2 means that VECSUBS(f,{x1,x2},{y1,y2})
%    returns y1.*y2).

vars = findsym(f);
if isempty(vars), vars = 'x'; end
v = charcll(vars);
F = strrep(vectorize(f),'],[' , ';'); 
Fv = strrep(F,'array([','');
Fv = strrep(Fv,'matrix([','');
Fv = strrep(Fv,'])','');
F = inline(Fv,v{:});
r = F(y{:});
