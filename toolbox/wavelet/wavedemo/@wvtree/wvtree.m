function t = wvtree(varargin)
%WVTREE Constructor for the class WVTREE.
%   T = WVTREE(X,DEPTH,WNAME) returns a wavelet tree T.
%   If X is a vector, the tree is of order 2.
%   If X is a matrix, the tree is of order 4.
%   The DWT extension mode is the current one.
%
%   T = WVTREE(X,DEPTH,WNAME,DWTMODE) returns a wavelet tree T
%   built using DWTMODE as DWT extension mode.
%
%   With T = WVTREE(X,DEPTH,WNAME,DWTMODE,USERDATA)
%   you may set a userdata field.
%
%   If ORDER = 2, T is a WVTREE object corresponding to a
%   wavelet decomposition of the vector (signal) X,
%   at level DEPTH with a particular wavelet WNAME.
%
%   If ORDER = 4, T is a WVTREE object corresponding to a
%   wavelet decomposition of the matrix (image) X,
%   at level DEPTH with a particular wavelet WNAME.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 09-Oct-1998.
%   Last Revision: 14-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.5.4.2 $  $Date: 2004/03/15 22:36:16 $ 

%===============================================
% Class WVTREE (parent class: WTREE)
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
O.dummy = 'left';
t = wtree(varargin{:});

% Built object.
%--------------
t = class(O,'wvtree',t);
