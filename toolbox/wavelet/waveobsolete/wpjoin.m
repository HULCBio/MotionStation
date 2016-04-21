function [Ts,Ds,x] = wpjoin(Ts,Ds,node)
%WPJOIN Recompose wavelet packet.
%   WPJOIN updates the tree and data structures after the
%   recomposition of a node.
%
%   [T,D] = WPJOIN(T,D,N) returns the modified tree
%   structure T and the modified data structure D, (see
%   MAKETREE) corresponding to a recomposition of the node N.
%   [T,D,X] = WPJOIN(T,D,N) also returns the coefficients
%   of the node.
%
%   [T,D] = WPJOIN(T,D) is equivalent to
%   [T,D] = WPJOIN(T,D,0).
%   
%   [T,D,X] = WPJOIN(T,D) is equivalent to
%   [T,D,X] = WPJOIN(T,D,0).
%
%   See also MAKETREE, WPDEC, WPDEC2, WPSPLT.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 04-May-1999.
%   Copyright 1995-2002 The MathWorks, Inc.
% $Revision: 1.11 $

% Check arguments.
if errargn(mfilename,nargin,[2:3],nargout,[1:3]), error('*'); end
if nargin == 2, node = 0; end

order    = wtreemgr('order',Ts);
depth    = wtreemgr('depth',Ts);
node     = depo2ind(order,node);
num_pack = wtreemgr('istnode',Ts,node);

% For a terminal node
%%%%%%%%%%%%%%%%%%%%%
if num_pack ~= 0
    x = wdatamgr('rcfs',Ds,Ts,num_pack);
    return
end

tab       = wtreemgr('table',Ts,0);
[row,col] = find(tab==node);
icol = find(col>2);

rec = tab(row(icol),2:max(col(icol)));
rec = rec(:);
rec = rec(find(rec>node));

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
        i_fils(k,j) = min(r);   % indices
    end
end

i_size = ind2depo(order,rec')+1;

% Recomposition
%%%%%%%%%%%%%%%
filter = wdatamgr('read_wave',Ds);
[Lo_R,Hi_R] = wfilters(filter,'r');
sizes  = wdatamgr('rsizes',Ds);

for k = 1:length(rec)
    left_child = i_fils(k,1);
    if order == 2
        % [a,d,beg,len] = wdatamgr('rmcfs',Ds,Ts,left_child);
        %--------------------------------------------------------
        beg = sum(Ts(2,1:left_child-1))+1;
        len = Ts(2,left_child);
        beg = beg+3;        % shift for dim & type of structure
        a   = Ds(beg:beg+len-1);
        d   = Ds(beg+len:beg+len+len-1);
        sx  = sizes(i_size(k));
        x   = idwt(a,d,Lo_R,Hi_R,sx);
    else
        % [a,h,v,d,beg,len] = wdatamgr('rmcfs',Ds,Ts,left_child);
        %-------------------------------------------------------------
        % attention prod([])=1
        if left_child ~= 1
            beg = sum(prod(Ts(2:3,1:left_child-1)))+1;
        else
            beg = 1;
        end
        len = prod(Ts(2:3,left_child));
        beg = beg+3;        % shift for dim & type of structure
        r   = Ts(2,left_child);
        c   = Ts(3,left_child);
        lim = beg:len:beg+order*len;
        a   = zeros(r,c); a(:) = Ds(lim(1):lim(2)-1);
        h   = zeros(r,c); h(:) = Ds(lim(2):lim(3)-1);
        v   = zeros(r,c); v(:) = Ds(lim(3):lim(4)-1);
        d   = zeros(r,c); d(:) = Ds(lim(4):lim(5)-1);
        sx  = sizes(:,i_size(k));
        x   = idwt2(a,h,v,d,Lo_R,Hi_R,sx);
    end
    % Ds = wdatamgr('replace',Ds,x(:)',beg,beg+order*len-1);
    %-----------------------------------------------------------
    first = beg;
    last  = beg+order*len-1;
    Ds    = [Ds(1:first-1) x(:)' Ds(last+1:length(Ds))];
    Ds(2) = Ds(2)-order*len+prod(sx);

    % insert_st = [rec(k) zeros(1,order-1);sx zeros(order/2,order-1)];
    % Ts = wtreemgr('change',Ts,insert_st,i_fils(k,:));
    %-----------------------------------------------------------------
    Ts(:,i_fils(k,:)) = [rec(k) zeros(1,order-1);sx zeros(order/2,order-1)];
end

%
% Modification of Tree and Data Structures.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Ts = wtreemgr('restore',Ts);
new_depth = wtreemgr('depth',Ts);
if new_depth < depth
    nbs = size(sizes,2)-(depth-new_depth);
    Ds  = wdatamgr('wsizes',Ds,sizes(:,1:nbs));
    nbn = (order^(new_depth+1)-1)/(order-1);
    ent = wdatamgr('read_ent',Ds,[0:nbn-1]');
    Ds  = wdatamgr('write_ent',Ds,ent);
    ent = wdatamgr('read_ento',Ds,[0:nbn-1]');
    Ds  = wdatamgr('write_ento',Ds,ent);
end
