function v = vectorize(s)
%VECTORIZE Vectorize expression.
%   VECTORIZE(S), when S is a string expression, inserts a '.' before
%   any '^', '*' or '/' in S.  The result is a character string.
%
%   VECTORIZE(FUN), when FUN is an INLINE function object, vectorizes the
%   formula for FUN.  The result is the vectorized version of the INLINE
%   function.
%
%   See also INLINE/FORMULA, INLINE.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.11 $  $Date: 2002/04/15 04:22:08 $

v = char(s);
if isempty(v)==1
    v = [];
else
    for k = fliplr(find((v=='^') | (v=='*') | (v=='/')))
        v = [v(1:k-1) '.' v(k:end)];
    end
end
v(findstr(v,'..')) = []; % Remove any possible ..*, ../, etc.
