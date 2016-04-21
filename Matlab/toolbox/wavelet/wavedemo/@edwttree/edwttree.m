function t = edwttree(x,depth,wname,modeDWT,userdata)
%EDWTTREE Constructor for the class EDWTTREE.
%   T = EDWTTREE(X,DEPTH,WNAME) returns an epsilon_dwt tree T.
%   If X is a vector, the tree is of order 2.
%   If X is a matrix, the tree is of order 4.
%   The DWT extension mode is the current one.
%
%   T = EDWTTREE(X,DEPTH,WNAME,DWTMODE) returns an epsilon_dwt tree T
%   built using DWTMODE as DWT extension mode.
%
%   With T = EDWTTREE(X,DEPTH,WNAME,DWTMODE,USERDATA)
%   you may set a userdata field.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 09-Sep-1999.
%   Last Revision: 14-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.5.4.2 $  $Date: 2004/03/15 22:36:01 $ 

%===============================================
% Class RWVTREE (parent class: DTREE)
% Fields:
%   dtree   - Parent object
%   dwtMode - DWTMODE type
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
  case 3 , userdata = {}; modeDWT  = 'per';
  case 4 , userdata = {};
end

% Tree creation.
%---------------
order = 4;
t = dtree(order,depth,x,'spsch',[1 0 0 1],'spflg',0,'ud',userdata);

% Dwtmode  & Wavelet infos.
%--------------------------
obj.dwtMode = modeDWT;
obj.waveInfo.wavName = wname;
[ obj.waveInfo.Lo_D,obj.waveInfo.Hi_D, ...
  obj.waveInfo.Lo_R,obj.waveInfo.Hi_R ] = wfilters(wname);

% Built object.
%---------------
t = class(obj,'edwttree',t);
t = expand(t);
