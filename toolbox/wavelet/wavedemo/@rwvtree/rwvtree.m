function t = rwvtree(varargin)
%RWVTREE Constructor for the class RWVTREE.
%   T = RWVTREE(X,DEPTH,WNAME) returns a wavelet tree T.
%   If X is a vector, the tree is of order 2.
%   If X is a matrix, the tree is of order 4.
%   The DWT extension mode is the current one.
%
%   T = RWVTREE(X,DEPTH,WNAME,DWTMODE) returns a wavelet tree T
%   built using DWTMODE as DWT extension mode.
%
%   With T = RWVTREE(X,DEPTH,WNAME,DWTMODE,USERDATA)
%   you may set a userdata field.
%
%   If ORDER = 2, T is a RWVTREE object corresponding to a
%   wavelet decomposition of the vector (signal) X,
%   at level DEPTH with a particular wavelet WNAME.
%
%   If ORDER = 4, T is a RWVTREE object corresponding to a
%   wavelet decomposition of the matrix (image) X,
%   at level DEPTH with a particular wavelet WNAME.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 09-Oct-1998.
%   Last Revision: 21-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.4.4.2 $  $Date: 2004/03/15 22:36:08 $ 

%===============================================
% Class RWVTREE (parent class: WTREE)
% Fields:
%   dummy - Not Used
%   wtree - Parent object
%===============================================

% Check arguments.
%-----------------
nbIn = nargin;
if nbIn < 3
  error('Not enough input arguments.');
end

% Tree creation.
%---------------
depth = varargin{2};
varargin{2} = 0;

% Tree creation.
%---------------
O.dummy = 'right';
t = wtree(varargin{:});
order = treeord(t);
t = set(t,'spsch',[zeros(order-1,1) ; 1]);

% Built object.
%---------------
t  = class(O,'rwvtree',t);
tn = 0;
for d = 1:depth
    t = nodesplt(t,tn);
    tn = order*(tn+1);
end
