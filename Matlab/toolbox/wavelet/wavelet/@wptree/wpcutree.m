function [wpt,n2m] = wpcutree(wpt,level)
%WPCUTREE Cut wavelet packet tree.
%   T = WPCUTREE(T,L) cuts the tree T at level L.
%
%   In addition, [T,RN] = WPCUTREE(T,L) returns 
%   the vector RN which contains the indices
%   of the reconstructed nodes.
%
%   See also WPDEC, WPDEC2.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 23-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.4.4.2 $  $Date: 2004/03/15 22:39:19 $

% Check arguments.
if nargin==1 , level = 0; end
if level<0
    error('Invalid level value.');
end

depth = treedpth(wpt);
if (level>=depth) || (depth==0)
    n2m = [];
    return;
end

order = treeord(wpt);
nottn = noleaves(wpt,'dp');
K     = nottn(:,1)==level;
n2m   = depo2ind(order,nottn(K,:));
wpt   = nodejoin(wpt,n2m);