function r = isnode(t,n)
%ISNODE True for existing node.
%   R = ISNODE(T,N) returns 1's for nodes N which
%   exist in the tree T, and 0's for others.
%
%   N can be a column vector containing the indices of nodes
%   or a matrix, which contains the depths and positions of nodes.
%   In the last case, N(i,1) is the depth of i-th node 
%   and N(i,2) is the position of i-th node.
%
%   The nodes are numbered from left to right and
%   from top to bottom. The root index is 0.
%
%   See also ISTNODE, WTREEMGR.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 13-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
% $Revision: 1.10.4.2 $

r = wtreemgr('isnode',t,n);