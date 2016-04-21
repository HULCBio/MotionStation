function [p,q] = etree(A,f)
%ETREE  Elimination tree.
%   p = ETREE(A) returns an elimination tree for the square symmetric
%   matrix whose upper triangle is that of A.  p(j) is the parent of
%   column j in the tree, or 0 if j is a root.
%
%   p = ETREE(A,'col') returns the elimination tree of A'*A.
%   p = ETREE(A,'sym') is the same as p = ETREE(A).
%
%   [p,q] = ETREE(...) also returns a postorder permutation q on the tree.
%
%   See also TREELAYOUT, TREEPLOT, ETREEPLOT.

%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 5.9.4.1 $  $Date: 2003/05/01 20:43:02 $

if nargin <= 1,
    [p,q] = sparsfun('symetree',A);
elseif f(1) == 's' || f(1) == 'S',
    [p,q] = sparsfun('symetree',A);
elseif f(1) == 'c' || f(1) == 'C',
    [p,q] = sparsfun('coletree',A);
else 
    error('MATLAB:etree:InvalidInput2',...
          'Second input argument must be ''sym'' or ''col''.');
end
