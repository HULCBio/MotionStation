function y = mfun(fun,varargin)
%MFUN   Numeric evaluation of a Maple function.
%   MFUN('fun',p1,p2,...,pk), where 'fun' is the name of a Maple 
%   function and the p's are numeric quantities corresponding to fun's 
%   parameters.  The last parameter specified may be a matrix. All other 
%   parameters must be the type specified by the Maple function.
%   MFUN numerically evaluates 'fun' with the specified parameters
%   and returns MATLAB doubles. Any singularity in 'fun' is returned 
%   as NaN.
%
%   Example:
%      x = 0:0.1:5.0;
%      y = mfun('FresnelC',x)
%
%   MFUN is not available in the Student Edition.
%
%   See also MFUNLIST, MHELP.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.24.4.2 $  $Date: 2004/04/16 22:23:27 $

if isequal(lower(fun),'hypergeom')
   y = hypergeom(varargin{:});
   return
end

currd = digits;
d = 16;
digits(d);

a = [];
for k = 1:length(varargin)-1
   a = [a ',' char(sym(varargin{k}))];
end;
if ~isempty(a), a = [a(2:end) ',']; end;

x = varargin{length(varargin)};
if isstr(x), x = eval(x); end

siz = size(x);
x = x(:).';
nans = find(isnan(x));
x(nans) = 0;

% format arguments for integer and real x
if all(imag(x) == 0)
   if all(x == fix(x))
      form = ['%' int2str(d) '.0f,'];
   else
      form = ['%' int2str(d+6) '.' int2str(d) 'e,'];
   end
   y = sprintf(form,x);

% format arguments for complex x
else
   form = ['%' int2str(d+6) '.' int2str(d) 'e'];
   y = sprintf([form '#' form '*i,'],[real(x); abs(imag(x))]);
   p = find(y == '#');

   % add the correct signs for imaginary parts
   s = find(imag(x) >= 0);
   if any(s)
      y(p(s)) = setstr('+'*ones(1,length(s)));
   end
   s = find(imag(x) < 0);
   if ~isempty(s) & any(s)
      y(p(s)) = setstr('-'*ones(1,length(s)));
   end
end

% additional format for the Maple MEX file
y(length(y)) = [];
y = ['[' y ']'];

[r,st] = maple(['evalf(map(s->' fun '(' a 's),' y '))']); 

emsg = 'error(''argument type not yet available.'')';
if st == 0
   r = eval(r,emsg);
   r(nans) = NaN;
   y = reshape(r,siz);

elseif st == 1
   warning('symbolic:mfun:warnmsg1','Maple result too long.  String truncated.')
   y = r;

elseif st == 2

   % singularities in r
   if findstr(r,'division by zero') | findstr(r,'NaN')
      y = [',' y(2:length(y)-1) ','];  % use commas as delimiters for ALL elements
      c = find(y == ',');
      u = NaN*ones(1,prod(siz));

      for k = 2:length(c)
         r = y( c(k-1)+1 : c(k)-1 );
         [r,st] = maple(['evalf(' fun '(' a r '))']);
         if isempty(findstr(r,'division by zero')) | findstr(r,'NaN') ...
            u(k-1) = eval(r,emsg);
         end
      end

      u(nans) = NaN;
      y = reshape(u,siz);

   % Overflow
   elseif findstr(r,'too large')
      y = [',' y(2:length(y)-1) ','];  % use commas as delimiters for ALL elements
      c = find(y == ',');
      u = Inf*ones(1,prod(siz));

      for k = 2:length(c)
         r = y( c(k-1)+1 : c(k)-1 );
         [r,st] = maple(['evalf(' fun '(' a r '))']);
         if isempty(findstr(r,'too large')), u(k-1) = eval(r,emsg); end
      end

      u(nans) = NaN;
      y = reshape(u,siz);

   else
      error('symbolic:mfun:errmsg2',r)
   end

% Other error messages
elseif st == 3
   error('symbolic:mfun:errmsg3',r)
elseif st == 5
   warning('symbolic:mfun:warnmsg2','Maple(quit, done or stop) ignored.')
end

digits(currd);
