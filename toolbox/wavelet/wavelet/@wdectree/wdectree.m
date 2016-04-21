function t = wdectree(x,order,depth,varargin)
%WDECTREE Constructor for the class WDECTREE.
%   T = WDECTREE(X,ORDER,DEPTH,WNAME) returns a wavelet tree T.
%   If X is a vector, the tree is of order 2.
%   If X is a matrix, the tree is of order 4.
%   The DWT extension mode is the current one.
%
%   T = WDECTREE(X,ORDER,DEPTH,WNAME,DWTMODE) returns a wavelet tree T
%   built using DWTMODE as DWT extension mode.
%
%   With T = WDECTREE(X,DEPTH,WNAME,DWTMODE,USERDATA)
%   you may set a userdata field.
%
%   T is a WDECTREE object corresponding to a
%   wavelet decomposition of the matrix (image) X,
%   at level DEPTH with a particular wavelet WNAME.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi  12-Feb-2003.
%   Last Revision: 14-Jul-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/03/15 22:38:58 $ 

%===============================================
% Class WDECTREE (parent class: DTREE)
% Fields:
%   dtree - Parent object
%   WT_Settings - Structure
%     typeWT  : 'dwt' or 'wp'
%     wname   : Wavelet Name.
%     extMode : DWT extension mode.
%     shift   : DWT shift value.
%     Filters : Structure of filters
%        Lo_D : Low Decomposition filter
%        Hi_D : High Decomposition filter
%        Lo_R : Low Reconstruction filter
%        Hi_R : High Reconstruction filter
%===============================================

% Check arguments.
%-----------------
msg = nargoutchk(0,1,nargout); error(msg);
userdata = {};
switch nargin
    case 0 % Dummy. Only for loading object!
        x = 0; order = 2 ; depth = 0;
        WT_Settings = struct(...
            'typeWT','dwt','wname','db1',...
            'extMode','sym','shift',0);
        
    otherwise
        msg = nargchk(3,5,nargin); error(msg);
        if isstruct(varargin{1})
            msg = nargchk(3,5,nargin); error(msg);
            WT_Settings = varargin{1};
            if nargin==5 , userdata = varargin{2}; end
        else
            %   #### Under Development ####
        end
end

% Tree creation.
%---------------
switch WT_Settings.typeWT
    case {'dwt','lwt'}  , spsch = [1 ; zeros(order-1,1)];
    case {'wpt','lwpt'} , spsch = ones(order,1);        
end
d = dtree(order,depth,x,'spsch',spsch,'spflg',0,'ud',userdata);

% Compute Filters.
%-----------------
switch WT_Settings.typeWT
    case {'dwt','wpt'}
        [Lo_D,Hi_D,Lo_R,Hi_R] = wfilters(WT_Settings.wname);
        WT_Settings.Filters = struct('Lo_D',Lo_D,'Hi_D',Hi_D,'Lo_R',Lo_R,'Hi_R',Hi_R);
        
    case {'lwt','lwpt'}
        WT_Settings.LS = liftwave(WT_Settings.wname);
end
t.WT_Settings = WT_Settings;

% Built object.
%---------------
t = class(t,'wdectree',d);
t = expand(t);