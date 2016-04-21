function t = wfustree(x,depth,varargin)
%WFUSTREE Creation of a wavelet decomposition TREE.
%   T = WFUSTREE(X,DEPTH,WNAME) returns a wavelet decomposition 
%   tree T (WDECTREE Object) of order 4 corresponding to 
%   a wavelet decomposition of the matrix (image) X, at level 
%   DEPTH with a particular wavelet WNAME.
%   The DWT extension mode used is the current one.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi  12-Feb-2003.
%   Last Revision: 15-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/13 00:40:11 $

%   ==== Under Development ====
%   T = WFUSTREE(X,WT_Settings)

% Check arguments.
%-----------------
% Check arguments.
nbIn = nargin;
if nbIn < 3
  error('Not enough input arguments.');
elseif nbIn > 4
  error('Too many input arguments.');
end
if nargin<4 , userdata = {}; end
order = 4;
if ischar(varargin{1})
    dwtATTR = dwtmode('get');
    WT_Settings = struct(...
        'typeWT','dwt','wname',varargin{1},...
        'extMode',dwtATTR.extMode,'shift',dwtATTR.shift2D);
else
   % ==== Under Development ====
end

% Tree creation.
%---------------
t = wdectree(x,order,depth,WT_Settings,userdata);
