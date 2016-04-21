function etreeplot(A,c,d)
%ETREEPLOT Plot elimination tree.
%   ETREEPLOT(A) plots the elimination tree of A (or A+A', if
%   non-symmetric). 
%
%   ETREEPLOT(A,nodeSpec,edgespec) allows optional parameters nodeSpec
%   and edgeSpec to set the node or edge color, marker, and linestyle.
%   Use '' to omit one or both.
%
%   See also TREEPLOT, ETREE, TREELAYOUT.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.9 $  $Date: 2002/04/15 04:13:34 $

B = spones(A);
if nargin == 1,
    treeplot(etree(B+B'));
elseif nargin == 2,
    treeplot(etree(B+B'),c);
else
    treeplot(etree(B+B'),c,d);
end
