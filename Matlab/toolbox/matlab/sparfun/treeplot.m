function treeplot(p,c,d)
%TREEPLOT Plot picture of tree.
%   TREEPLOT(p) plots a picture of a tree given a vector of
%   parent pointers, with p(i) == 0 for a root. 
%
%   TREEPLOT(P,nodeSpec,edgeSpec) allows optional parameters nodeSpec
%   and edgeSpec to set the node or edge color, marker, and linestyle.
%   Use '' to omit one or both.
%
%   See also ETREE, TREELAYOUT, ETREEPLOT.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 5.12.4.1 $  $Date: 2004/03/02 21:48:33 $

[x,y,h]=treelayout(p);
f = find(p~=0);
pp = p(f);
X = [x(f); x(pp); repmat(NaN,size(f))];
Y = [y(f); y(pp); repmat(NaN,size(f))];
X = X(:);
Y = Y(:);

if nargin == 1,
    n = length(p);
    if n < 500,
        plot (x, y, 'ro', X, Y, 'r-');
    else
        plot (X, Y, 'r-');
    end;
else
    [ignore, clen] = size(c);
    if nargin < 3, 
        if clen > 1, 
            d = [c(1:clen-1) '-']; 
        else
            d = 'r-';
        end;
    end;
    [ignore, dlen] = size(d);
    if clen>0 && dlen>0
        plot (x, y, c, X, Y, d);
    elseif clen>0,
        plot (x, y, c);
    elseif dlen>0,
        plot (X, Y, d);
    else
    end;
end;
xlabel(['height = ' int2str(h)]);
axis([0 1 0 1]);
