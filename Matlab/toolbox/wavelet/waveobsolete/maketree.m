function [Ts,nbtn] = maketree(order,depth,nbinfo)
%MAKETREE Make tree.
%   [T,NB] = MAKETREE(ORD,D) creates a tree structure
%   of order ORD with depth D. 
%   Output argument NB = ORD^D is the number of 
%   terminal nodes.
%   Output vector T is organized as: [T(1) ... T(NB+1)]
%   where T(i), i = 1 to NB, are the indices of terminal
%   nodes and T(NB+1) = -ORD.
%
%   The nodes are numbered from left to right and
%   from top to bottom. The root index is 0.
%
%   When used with three input arguments,
%   [T,NB] = MAKETREE(ORD,D,NBI) computes T as a 
%   (1+NBI)x(NB+1) matrix with T(1,:) as above
%   and T(2:NBI+1,:) is user free.
%
%   MAKETREE(ORD)   is equivalent to MAKETREE(ORD,0,0).
%   MAKETREE(ORD,D) is equivalent to MAKETREE(ORD,D,0).
%
%   See also PLOTTREE, WTREEMGR.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 04-May-1999.
%   Copyright 1995-2002 The MathWorks, Inc.
% $Revision: 1.11 $

% Check arguments.
if errargn(mfilename,nargin,[1:3],nargout,[0:2]), error('*'); end

if nargin==1
    depth = 0; nbinfo = 0;
elseif nargin==2
    nbinfo = 0;
end
[Ts,nbtn] = wtreemgr('create',[],order,depth,nbinfo);
