function Ts = nodejoin(Ts,node)
%NODEJOIN Recompose node.
%   T = NODEJOIN(T,N) returns the modified tree structure T
%   corresponding to a recomposition of the node N.
%
%   The nodes are numbered from left to right and
%   from top to bottom. The root index is 0.
%
%   T = NODEJOIN(T) is equivalent to T = NODEJOIN(T,0).
%
%   See also MAKETREE, NODESPLT, WTREEMGR.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 05-May-1999.
%   Copyright 1995-2002 The MathWorks, Inc.
% $Revision: 1.11 $

% Check arguments.
if errargn(mfilename,nargin,[1 2],nargout,[0 1]), error('*'); end
if nargin == 1, node = 0; end

if wtreemgr('istnode',Ts,node) , return; end

order     = wtreemgr('order',Ts);
depth     = wtreemgr('depth',Ts);
node      = depo2ind(order,node);
tab       = wtreemgr('table',Ts,0);
[row,col] = find(tab==node);
icol      = find(col>2);
rec       = tab(row(icol),2:max(col(icol)));
rec       = rec(:);
rec       = rec(rec>node);

if length(rec>1);
    rec = sort(rec);
    K   = [1;find(diff(rec)~=0)+1];
    rec = rec(K);
end

rec    = wrev([node;rec])';
lrec   = length(rec);
ord    = [1:order];
i_fils = order*(rec(ones(1,order),:))'+ ord(ones(1,lrec),:);

for k = 1:lrec
    for j = 1:order
        [r,c] = find(tab==i_fils(k,j));
        i_fils(k,j) = min(r);           % indices
    end
end

nbinfo = size(Ts,1)-1;
for k = 1:lrec
    insert_st = [rec(k) NaN*ones(1,order-1) ; zeros(nbinfo,order)];
    Ts(:,i_fils(k,:)) = insert_st;
end

Ts = Ts(:,~isnan(Ts(1,:)));
