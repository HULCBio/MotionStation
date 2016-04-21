function varargout = wtreemgr(opt,Ts,varargin)
%WTREEMGR Manager for tree structure.
%   VARARGOUT = WTREEMGR(OPT,TREE,VARARGIN)
%   Allowed values for OPT and associated uses are 
%   described in the functions listed in the See Also section:
%
%   'allnodes'  : All nodes.
%   'isnode'    : Is node.
%   'istnode'   : Lop "is terminal node".
%   'create'    : Create a tree.
%   'nodeasc'   : Node ascendants.
%   'nodedesc'  : Node descendants.
%   'nodepar'   : Node parent.
%   'ntnode'    : Number of terminal nodes.
%   'tnodes'    : Terminal nodes.
%   'leaves'    : Terminal nodes.
%   'noleaves'  : Not Terminal nodes.
%   'order'     : Order of tree.
%   'depth'     : Depth of tree.
%
%   For tree structure implementation see MAKETREE.
%
%   See also ALLNODES, ISNODE, ISTNODE, LEAVES, MAKETREE, 
%   NODEASC, NODEDESC, NODEPAR, NOLEAVES, NTNODE, TNODES,
%   TREEDPTH, TREEORD.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 10-May-1999.
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.12 $

%Internal Options
%----------------
%   'replace'   : Replace.
%   'change'    : Change.
%   'restore'   : Restore.
%   'rinfo'     : Read Info.
%   'winfo'     : Write Info.
%   'table'     : table of nodes fathers.
%   'readall'   :
%   out1 = Terminal Nodes (left ---> right)
%   out2 = sizes of Terminal Nodes
%   out3 = order
%   out4 = depth

% Check arguments.
if errargn(mfilename,nargin,[2:5],nargout,[0:4]), error('*'); end

if strcmp(opt,'create')
    % [in3 in4 in5] = [order depth nbinfo]
    % [out1 out2] = [Ts ntnode]
    order = varargin{1};
    nbtn  = order^varargin{2};
    r     = varargin{3}+1;
    c     = nbtn+1;
    Ts    = zeros(r,c);
    Ts(1,1:nbtn) = (nbtn-1)/(order-1):(order*nbtn-order)/(order-1);
    Ts(1,c)      = -order;
    varargout{1}   = Ts; varargout{2} = nbtn;
    return
end

[rows,cols] = size(Ts);
ntnode      = cols-1;
if ntnode<1
    errargt(mfilename,'Invalid tree structure!','msg');
    error('*');
end

switch opt
    case 'ntnode'
        varargout{1} = ntnode;
        return

    case 'replace'
        % in3 = insert in4,in5 = indices of replaced first, last
        if nargin==3
            varargout{1} = varargin{1};
        else
            varargout{1} = [Ts(:,1:varargin{2}-1) varargin{1} ...
                        Ts(:,varargin{3}+1:cols)];
        end
        return

    case 'change'
        % in3 = new values in4 = indices of changed
        if nargin==3
            varargout{1} = varargin{1};
        else
            varargout{1} = Ts;
            varargout{1}(:,varargin{2}) = varargin{1};
        end
        return

    case 'restore'
        % on trouve sur les tailles (ligne 2) 
        % et pas sur les indices de noeuds (ligne 1)
        %
        preserve = [find(Ts(2,:)) cols];
        varargout{1} = Ts(:,preserve);
        return

    case 'rinfo'
        if rows>1
            varargout{1} = Ts(2:rows,1:ntnode);
        else
            varargout{1} = [];
        end
        return

        case 'winfo'
            varargout{1}  = Ts;
        if rows>1
            varargout{1}(2:rows,1:ntnode) = varargin{1};
        end
        return
end

order = abs(Ts(1,cols));
depth = floor(log(max(Ts(1,:))*(order-1)+1)/log(order));

switch opt
    case 'order'
        varargout{1} = order;

    case 'depth'
        varargout{1} = depth;

    case 'readall'
        varargout{1} = Ts(1,1:ntnode)';
        varargout{2} = Ts(2:rows,1:ntnode)';
        varargout{3} = order;
        varargout{4} = depth;      

    case 'leaves'
        tn = Ts(1,1:ntnode)';
        K  = [1:length(tn)]';
        if nargin>2
            flagdps = varargin{1};
            switch flagdps
                case {'s','sort'}
                    [tn,K] = sort(tn); [nul,K] = sort(K);

                case {'sdp','dps','sortdp','dpsort'}
                    [tn,K] = sort(tn); [nul,K] = sort(K);
                    [tn(:,1),tn(:,2)] = ind2depo(order,tn);

                case {'dp'}
                    [tn(:,1),tn(:,2)] = ind2depo(order,tn);
            end
        end
        varargout{1} = tn; varargout{2} = K;

    case 'tnodes'
        [tn,K] = sort(Ts(1,1:ntnode)');
        [nul,K]  = sort(K);
        if nargin==3
            [tn(:,1),tn(:,2)] = ind2depo(order,tn);
        end
        varargout{1} = tn; varargout{2} = K;
    
    case 'noleaves'
         tmp = Ts(1,1:ntnode)';
         if length(tmp)<=1, varargout{1} = []; return; end
         nottn  = floor((tmp-1)/order);
         for k = 1:depth
             tmp  = floor((tmp-1)/order);
             nottn = [nottn;tmp];
         end
         nottn = sort(nottn(find(nottn>=0)));
         K    = [1;find(diff(nottn)~=0)+1];
         nottn = nottn(K);
         if nargin==3
             [nottn(:,1),nottn(:,2)] = ind2depo(order,nottn);
         end
         varargout{1} = nottn;

    case 'allnodes'
        allN  = wtreemgr('tnodes',Ts);
        if length(allN)<=1, varargout{1} = allN; return; end
        tmp   = allN;
        for k = 1:depth
            tmp  = floor((tmp-1)/order);
            allN = [allN;tmp];
        end
        allN = sort(allN(find(allN>=0)));
        K    = [1;find(diff(allN)~=0)+1];
        allN = allN(K);
        if nargin==3
            [allN(:,1),allN(:,2)] = ind2depo(order,allN);
        end
        varargout{1} = allN;

    case 'isnode'
        node  = depo2ind(order,varargin{1});
        all   = wtreemgr('allnodes',Ts);
        if prod(size(node))<=1
            if find(all==node)
                varargout{1} = 1;
            else
                varargout{1} = 0;
            end
        else
            varargout{1} = ismember(node,all);
        end

    case 'istnode'
        node  = depo2ind(order,varargin{1});
        tn    = Ts(1,1:ntnode)';
        varargout{1}  = zeros(size(node));
        for k = 1:length(node)
            in = find(node(k)==tn);
            if ~isempty(in), varargout{1}(k) = in; end
        end

    case 'nodepar'
        varargout{1}  = floor((depo2ind(order,varargin{1})-1)/order);
        if nargin==4
            [varargout{1}(:,1),varargout{1}(:,2)] = ind2depo(order,varargout{1});
        end

    case 'nodeasc'
        asc   = depo2ind(order,varargin{1});
        [d,p] = ind2depo(order,asc);
        tmp   = asc;
        for k = 1:d
            tmp  = floor((tmp-1)/order);
            asc = [asc;tmp];
        end
        if nargin==4
            [asc(:,1),asc(:,2)] = ind2depo(order,asc);
        end
        varargout{1} = asc;

    case 'nodedesc'
        A     = wtreemgr('table',Ts);
        node  = depo2ind(order,varargin{1});
        [i,j] = find(A==node);
        desc  = A(i,:);
        desc  = desc(:);
        desc  = sort(desc(find(desc>=node)));
        if length(desc)>1
            K = [1;find(diff(desc)~=0)+1];
        else
            K = 1;
        end
        desc = desc(K);
        if nargin==4
            [desc(:,1),desc(:,2)] = ind2depo(order,desc);
        end
        varargout{1} = desc;

    case 'table'
        [tn,K] = wtreemgr('tnodes',Ts);
        if nargin==3, tn = tn(K); end
        tab = zeros(length(tn),depth+1);
        tab(:,1) = tn;
        for j = 1:depth
            tab(:,j+1) = floor((tab(:,j)-1)/order);
        end
        varargout{1} = tab;

    otherwise
        errargt(mfilename,'unknown option','msg'); error('*');
end
