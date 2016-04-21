function pretty(X,w)
%PRETTY Pretty print a symbolic expression.
%   PRETTY(S) prints the symbolic expression S in a format that 
%   resembles type-set mathematics.
%   PRETTY(S,n) uses screen width n instead of the default 79.
%
%   See also SUBEXPR, LATEX, CCODE.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.18.4.2 $  $Date: 2004/04/16 22:23:02 $

if nargin == 2
   maplemex(['interface(screenwidth=' int2str(w) ');']);
end

if all(size(X) == 1)
   % Scalar
   S = X.s;
elseif ndims(X) == 2
   % Matrix
   S = char(X);
else
   S = char(X,2);
end

maplemex('interface(prettyprint=true);');
disp(' ')
maplemex(['print(' S ');']);
maplemex('interface(prettyprint=false);');

if nargin == 2
   maplemex('interface(screenwidth=79);');
end
