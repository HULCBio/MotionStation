function D = double(X)
%DOUBLE Converts symbolic matrix to MATLAB double.
%   DOUBLE(S) converts the symbolic matrix S to a matrix of double
%   precision floating point numbers.  S must not contain any symbolic
%   variables, except 'eps'.
%
%   See also SYM, VPA.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.21.4.2 $  $Date: 2004/04/16 22:22:18 $

if ~isempty(findstr('eps',char(X)))
   X = subs(X,'eps',eps);
end

d = digits;
if d ~= 32
   digits(32);
end

siz = size(X);
T = X;
[X,stat] = maple('evalf',X(:));

if stat | findstr(char(X),'NaN')
   X = T;
   for k = 1:prod(siz)
      [X(k),stat] = maple('evalf',X(k));
      if stat | findstr(char(X(k)),'NaN')
         if strcmp(X(k).s,'Error, division by zero')
            X(k) = Inf;
         else
            X(k) = NaN;
         end
      end
   end
end

if d ~= 32
   digits(d);
end

X = char(X);
X = map2mat(X);
D = reshape(eval(X),siz);

%-------------------------

function r = map2mat(r)
% MAP2MAT Maple to MATLAB string conversion.
%   Inverse of SYM/CHAR.
%   MAP2MAT(r) converts the Maple string r containing
%   matrix, vector, or array to a valid MATLAB string.
%
%   Examples: map2mat(vector([a,b,c,d])
%             returns [a,b,c,d]
%             map2mat(matrix([[a,b], [c,d]])
%             returns [a,b;c,d]
%             map2mat(array([1..x,1..x,1..x],[(1,1,1)=x,...]))
%             returns a 3-D array.

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

