function [tn,K] = tnodes(t,flagdp)
%TNODES Determine terminal nodes (obsolete - use LEAVES).
%   N = TNODES(T) returns the indices of terminal nodes 
%   of the tree T. 
%   N is a column vector. 
%
%   The nodes are numbered from left to right and
%   from top to bottom. The root index is 0.
%
%   N = TNODES(T,'deppos') returns a matrix N, which
%   contains the depths and positions of terminal nodes.
%   N(i,1) is the depth of i-th terminal node and
%   N(i,2) is the position of i-th terminal node.
%
%   For [N,K] = TNODES(T) or [N,K] = TNODES(T,'deppos')
%   M = N(K) are the indices reordered as in tree T,
%   from left to right.
%
%   See also LEAVES, NOLEAVES, WTREEMGR.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 21-May-2003.
%   Last Revision: 21-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/03/15 22:38:46 $

if nargin==1 , flagdp = 'sort'; else , flagdp = 'sortdp'; end
[tn,K] = leaves(t,flagdp);
