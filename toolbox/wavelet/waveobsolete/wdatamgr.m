function [out1,out2,out3,out4,out5,out6] = ...
                        wdatamgr(opt,in2,in3,in4,in5,in6,in7,in8,in9,in10)
%WDATAMGR Manager for data structure.
%   WDATAMGR is a type of data manager for the wavelet packet
%   tree structure.
%   [OUT1,OUT2] = WDATAMGR(O,D,IN3,IN4,IN5) where D is the
%   Data Structure and O is a string option.
%   The possible options are:
%   'write_cfs': writes coefficients for a terminal node,
%     data  = wdatamgr('write_cfs',data,tree,node,coefs)
%   'read_cfs'   : reads coefficients for a terminal node,
%     coefs = wdatamgr('read_cfs',data,tree,node);
%   'read_ent'   : reads the entropy vector,
%     ent   = wdatamgr('read_ent',data,nodes)        
%   'read_ento'  : reads the optimal entropy vector,
%     ento  = wdatamgr('read_ento',data,nodes)
%   'read_tp_ent': reads the type and the parameter for entropy,
%     [type_ent,param] = wdatamgr('read_tp_ent',data)
%   'read_wave'  : reads the name of wavelet,
%     wave = wdatamgr('read_wave',data)
%   'write_wave': writes the name of wavelet,
%     data  = wdatamgr('write_wave',data,wname)
%
%   See also WPDEC, WPDEC2, WTREEMGR.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 15-Jul-1999.
%   Copyright 1995-2002 The MathWorks, Inc.
% $Revision: 1.11 $


%   INTERNAL OPTIONS :
%-------------------------
% 'beglen'      : begin and length of coefficient vector.
% 'order'       : tree order.
%
% 'write'       : writes initial Data Structure.
% 'wcfs'        : writes coefs. for a ter. node
%                   (index in tree structure)
% 'wsizes'      : writes the lengths vector.
% 'write_ent'   : writes the entropy vector.
%     data  = wdatamgr('write_ent',data,ent,nodes) or
% 'write_ento'  : writes the optimal entropy vector.
%     data  = wdatamgr('write_ento',data,ento,nodes)
%
% 'replace'     : replaces part of coefficients.
%                   (first and last indexes in tree structure)
% 'change'      : replaces part of coefficients.
%                   (indexes in tree structure)
%
% 'rcfs'        : reads coefs. for a ter. node (index in tree structure)
% 'rmcfs'       : reads coefs. for terminal "brothers" nodes
%                   (index of left one in tree structure)
% 'rallcfs'     : reads all coefficients.
% 'rsizes'      : reads the size of packets at at all depths.
%
% 'write_tp_ent': writes the type and the parameter for entropy.
%     data   = wdatamgr('write_tp_ent',data,type_ent,param)

% Check arguments.
if errargn(mfilename,nargin,[2:10],nargout,[0:6]), error('*'); end

if strcmp(opt,'beglen')
    % in2 = order
    % in3 = tree structure --  in4 = k (index in tree structure)
    if in2 == 2
        out1 = sum(in3(2,1:in4-1));
        out2 = in3(2,in4);
    elseif in2 == 4
        % attention prod([])=1
        if in4 ~= 1
            out1 = sum(prod(in3(2:3,1:in4-1)));
        else
            out1 = 0;
        end
        out2 = prod(in3(2:3,in4));
    end
    out1 = out1+1;
    return;
end

if strcmp(opt,'write')
    % Data Structure
    %--------------------------
    % data = [ 
    %       cfs(:)'         in2
    %       sizes           in3
    %       x_shape         in4
    %       ent             in5
    %       ent_opt         in6
    %       parameter       in7
    %       type_ent        in8
    %       filter          in9 
    %       order           in10
    %       ]
    %--------------------------
    if strcmp(lower(in8),'user')
        in8 = ['user' '&' in7];
        in7 = 0;
    end
    out1 = [];
    out1 = wmemutil('add',out1,in3);
    out1 = wmemutil('add',out1,in4);
    out1 = wmemutil('add',out1,in5);
    out1 = wmemutil('add',out1,in6);
    out1 = wmemutil('add',out1,in7);
    out1 = wmemutil('add',out1,in8);
    out1 = wmemutil('add',out1,in9);
    out1 = wmemutil('add',out1,in10);
    out1 = wmemutil('add',out1,in2,1);
    return;
end

ind_cfs       = 1;
ind_sizes     = 2;
ind_x_shape   = 3;
ind_ent       = 4;
ind_ento      = 5;
ind_parameter = 6;
ind_type_ent  = 7;
ind_filter    = 8;
ind_order     = 9;

% in2 = Data Structure for all remaining options
%------------------------------------------------

order = wmemutil('get',in2,ind_order);

switch opt
    case 'order'
        out1 = order;

    case 'rcfs'
        % in3  = tree structure  -- in4 = index in tree structure
        % out1 = x    out2 = beg    out3 = len
        if in4>wtreemgr('ntnode',in3)
            errargt(mfilename,'invalid packet number','msg');
            return;
        end
        tmp = wmemutil('get',in2,ind_cfs);
        [out2,out3] = wdatamgr('beglen',order,in3,in4);
        if order==4
            out1    = zeros(in3(2,in4),in3(3,in4));
            out1(:) = tmp(out2:out2+out3-1);
        else
            out1 = tmp(out2:out2+out3-1);
        end

    case 'rmcfs'
        % in3  = tree structure  -- in4 = first-child (index in tree structure)
        % if order = 2 : 
        % out1 = a ; out2 = d ; out3 = beg ; out4 = len;
        % if order = 4 : 
        % out1 = a ; out2 = h ; out3 = v ; out4 = d ; out5 = beg ; out6 = len;
        cfs = wmemutil('get',in2,ind_cfs);
        if order == 2
            [out3,out4] = wdatamgr('beglen',order,in3,in4);
            out1 = cfs(out3:out3+out4-1);
            out2 = cfs(out3+out4:out3+out4+out4-1);
        elseif order == 4
            r = in3(2,in4); c = in3(3,in4);
            [out5,out6] = wdatamgr('beglen',order,in3,in4);
            lim  = out5:out6:out5+order*out6;
            out1 = zeros(r,c); out1(:) = cfs(lim(1):lim(2)-1);
            out2 = zeros(r,c); out2(:) = cfs(lim(2):lim(3)-1);
            out3 = zeros(r,c); out3(:) = cfs(lim(3):lim(4)-1);
            out4 = zeros(r,c); out4(:) = cfs(lim(4):lim(5)-1);
        end

    case 'rallcfs'
        out1 = wmemutil('get',in2,ind_cfs);

    case 'read_cfs'
        % in3 = tree structure
        % in4 = terminal node (index num or depth/pos num)
        % out1 = coefs
        pack_exist = wtreemgr('istnode',in3,in4);
        if pack_exist ~= 0
            out1 = wdatamgr('rcfs',in2,in3,pack_exist);
        else
            errargt(mfilename,'invalid node value','msg');
            error('*');
        end

    case 'read_ent'
        out1 = wmemutil('get',in2,ind_ent);
        if nargin==3
            in3 = 1+depo2ind(order,in3);
            out1 = out1(in3);
        end

    case 'read_ento'
        out1 = wmemutil('get',in2,ind_ento);
        if nargin==3
            in3 = 1+depo2ind(order,in3);
            out1 = out1(in3);
        end

    case 'read_tp_ent'
        out1 = wmemutil('get',in2,ind_type_ent);
        k = find(out1=='&');
        if k>0
            out2 = out1(k+1:length(out1));
            out1 = out1(1:k-1);
            if ~strcmp(out1,'user')
                errargt(mfilename,'invalid type of entropy','msg');
                error('*');  
            end
        else
            out2 = wmemutil('get',in2,ind_parameter);
        end

    case 'read_wave'
        out1 = wmemutil('get',in2,ind_filter);

    case 'rsizes'
        out1    = wmemutil('get',in2,ind_sizes);
        x_shape = wmemutil('get',in2,ind_x_shape);
        if strcmp(x_shape,'m')
            out1 = reshape(out1,2,prod(size(out1))/2);
        end

    case 'write_cfs'
        % in3 = tree structure
        % in4 = terminal node (index num or depth/pos num)
        % in5 = coefs
        pack_exist = wtreemgr('istnode',in3,in4);
        if pack_exist ~= 0
            pack_exist = depo2ind(order,pack_exist);
            [beg,len] = wdatamgr('beglen',order,in3,pack_exist);
            if order == 4
                r = in3(2,pack_exist); c = in3(3,pack_exist);
            else 
                r = 1;
                c = in3(2,pack_exist);
            end
            if find([r c]~=size(in5))
                errargt(mfilename,'invalid size for coefs','msg');
                error('*');
            else
                out1 = wdatamgr('replace',in2,in5(:)',beg,beg+len-1);
            end
        else
            errargt(mfilename,'invalid node value','msg');
            error('*');
        end

    case 'wcfs'
        % in3  = tree structure  -- in4 = index in tree structure -- in5 = cfs
        % out1 = new data
        [beg,len] = wdatamgr('beglen',order,in3,in4);
        out1 = wdatamgr('replace',in2,in5,beg,beg+len-1);

    case 'write_ent'
        if nargin==3
            out1 = wmemutil('set',in2,ind_ent,in3);
        elseif nargin==4
            old  = wmemutil('get',in2,ind_ent);
            old(in4+1) = in3;
            out1 = wmemutil('set',in2,ind_ent,old);
        end

    case 'write_ento'
        if nargin==3
            out1 = wmemutil('set',in2,ind_ento,in3);
        elseif nargin==4
            old  = wmemutil('get',in2,ind_ento);
            old(in4+1) = in3;
            out1 = wmemutil('set',in2,ind_ento,old);
        end

    case 'write_wave'
        out1 = wmemutil('set',in2,ind_filter,in3);

    case 'wsizes'
        in3  = in3(:)';
        out1 = wmemutil('set',in2,ind_sizes,in3);

    case 'replace'
        % in3 = insert        in4,in5 = indices of replaced first,last
        if nargin==3
            out1 = wmemutil('set',in2,ind_cfs,in3);
        else
            cfs  = wmemutil('get',in2,ind_cfs);
            cfs  = [cfs(1:in4-1) in3 cfs(in5+1:length(cfs))];
            out1 = wmemutil('set',in2,ind_cfs,cfs);
        end

    case 'change'
        % in3 = new values        in4 = indices of replaced
        if nargin==3
            out1 = in3;
        else
            out1 = in2;
            out1(in4) = in3;
        end

    case 'write_tp_ent'
        if nargin==3 , in4 = 0; end
        if strcmp(lower(in3),'user')
            in3 = ['user' '&' in4];
            in4 = 0;
        end
        out1 = wmemutil('set',in2,ind_type_ent,in3);
        out1 = wmemutil('set',out1,ind_parameter,in4);

    otherwise
        errargt(mfilename,'unknown option','msg'); error('*');
end
