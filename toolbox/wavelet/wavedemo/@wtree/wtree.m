function t = wtree(x,depth,wname,modeDWT,userdata)
%WTREE Constructor for the class WTREE.
%   T = WTREE(X,DEPTH,WNAME) returns a wavelet tree T.
%   If X is a vector, the tree is of order 2.
%   If X is a matrix, the tree is of order 4.
%   The DWT extension mode is the current one.
%
%   T = WTREE(X,DEPTH,WNAME,DWTMODE) returns a wavelet tree T
%   built using DWTMODE as DWT extension mode.
%
%   With T = WTREE(X,DEPTH,WNAME,DWTMODE,USERDATA)
%   you may set a userdata field.
%
%   If ORDER = 2, T is a WTREE object corresponding to a
%   wavelet decomposition of the vector (signal) X,
%   at level DEPTH with a particular wavelet WNAME.
%
%   If ORDER = 4, T is a WTREE object corresponding to a
%   wavelet decomposition of the matrix (image) X,
%   at level DEPTH with a particular wavelet WNAME.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 09-Sep-1999.
%   Last Revision: 14-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.4.4.2 $  $Date: 2004/03/15 22:36:12 $ 

%===============================================
% Class WTREE (parent class: DTREE)
% Fields:
%   dtree   - Parent object
%   dwtMode - DWT extension mode
%   wavInfo - Structure (wavelet infos)
%     wavName : Wavelet Name.
%     Lo_D    : Low Decomposition filter
%     Hi_D    : High Decomposition filter
%     Lo_R    : Low Reconstruction filter
%     Hi_R    : High Reconstruction filter
%===============================================

% Check arguments.
%-----------------
nbIn = nargin;
if nbIn < 3
  error('Not enough input arguments.');
end
switch nbIn
  case 3 , userdata = {}; modeDWT = dwtmode('status','nodisp');
  case 4 , userdata = {};
end

% Tree creation.
%---------------
if min(size(x))>1 , order = 4; else , order = 2; end
t = dtree(order,depth,x,'spsch',[1 ; zeros(order-1,1)],'spflg',0,'ud',userdata);

% Wavelet infos.
%---------------
obj.dwtMode = modeDWT;
obj.waveInfo.wavName = wname;
[ obj.waveInfo.Lo_D,obj.waveInfo.Hi_D, ...
  obj.waveInfo.Lo_R,obj.waveInfo.Hi_R ] = wfilters(wname);

% Built object.
%---------------
t = class(obj,'wtree',t);
t = expand(t);
