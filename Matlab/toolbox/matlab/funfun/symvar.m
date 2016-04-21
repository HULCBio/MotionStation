function vars = symvar(s)
%SYMVAR Determine the symbolic variables in an expression.
%   SYMVAR(S) searches the string S for identifiers other than 'i', 'j',
%   'pi', 'inf', 'nan', 'eps' and common functions.  The variables are
%   returned as a cell array of strings. If no such variable exists,
%   the empty cell array {} is returned. 
%
%   Note:  In expressions like 'f(1)', SYMVAR interprets the symbol 'f'
%   as a function call, not as an index into a symbolic variable.
%
%   Example
%      symvar('cos(pi*x - beta1)') returns {'beta1';'x'}
%
%   See also FINDSTR.

%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 1.13.4.1 $ $Date: 2003/05/19 11:16:28 $

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

% Find opening parentheses and check to make sure they don't 
% trail a variable.  If one does, it is a treated as a function
% name and removed from b and e.
p = find(s == '(');
if ~isempty(p)
  [e,ie] = setdiff(e,p-1);
  b = b(ie);
end

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

% Produce a column output.
vars = vars(:);

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
inquote = false;
k = 1;
while k <= length(q)
  % Quotes that are preceded by identifier characters, transposes, or
  % closing parentheses are transposes if we're not in a quoted string
  if ~inquote && ((~isempty(de) && any(q(k) == de+1)) || ...
                 (~isempty(p) && any(q(k) == p+1)) || ...
                 (~isempty(qq) && any(q(k) == qq+1)))
    q(k) = []; % Remove this quote from the list
  else
    k = k + 1;
    inquote = ~inquote;
  end
end

if ~isempty(q)
  if rem(length(q),2)~=0,
    error('MATLAB:symvar:SQuotesNotPaired', 'Quotes in S are not in pairs.')
  end
  quotemask = makerun(q(1:2:end),q(2:2:end),numel(s));
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
