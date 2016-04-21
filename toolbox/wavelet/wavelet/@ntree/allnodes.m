function allN = allnodes(t,flagdp)
%ALLNODES Tree nodes.
%   ALLNODES returns one of two node descriptions:
%   either indices, or depths and positions.
%   The nodes are numbered from left to right and
%   from top to bottom. The root index is 0.
%
%   N = ALLNODES(T) returns in column vector N
%   the indices of all nodes of the tree T.
%
%   N = ALLNODES(T,'deppos') returns in matrix N
%   the depths and positions of all the nodes.
%   N(i,1) is the depth and N(i,2) is the position
%   of node i.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 21-May-2003.
%   Last Revision: 22-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/03/15 22:38:16 $

order = t.order;
depth = t.depth;
allN  = t.tn;
if (depth==0) , return; end
if nargin==1 , flagdp = false; else , flagdp = true; end
allN = ascendants(allN,order,depth,flagdp);
