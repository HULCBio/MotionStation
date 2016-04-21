function [Ts,Ds,out3,out4,out5,out6] = wpsplt(Ts,Ds,node)
%WPSPLT Split (decompose) wavelet packet.
%   WPSPLT updates the tree and data structures after the
%   decomposition of a node.
%
%   [T,D] = WPSPLT(T,D,N) returns the modified tree
%   structure T and the modified data structure D (see
%   MAKETREE), corresponding to the decomposition of the
%   node N.
%
%   For a 1-D decomposition: [T,D,CA,CD] = WPSPLT(T,D,N)
%   with CA = approximation and CD = detail of node N.
%
%   For a 2-D decomposition: [T,D,CA,CH,CV,CD] = WPSPLT(T,D,N)
%   with CA = approximation and CH, CV, CD = (Horiz., Vert. and
%   Diag.) details of node N.
%
%   See also MAKETREE, WAVEDEC, WAVEDEC2, WPDEC, WPDEC2, WPJOIN.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 04-May-1999.
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.11 $

% Check arguments.
if errargn(mfilename,nargin,[3],nargout,[2:6]), error('*'); end

pack_exist = wtreemgr('istnode',Ts,node);
if pack_exist==0
    errargt(mfilename,'Invalid node value','msg');
    return
end

filter      = wdatamgr('read_wave',Ds);
[Lo_D,Hi_D] = wfilters(filter,'d');
[type_ent,parameter] = wdatamgr('read_tp_ent',Ds);
[x,beg_p,len_p] = wdatamgr('rcfs',Ds,Ts,pack_exist);
order  = wtreemgr('order',Ts);
node   = depo2ind(order,node);
indord = node*order;

%
% Decomposition of the node
%%%%%%%%%%%%%%%%%%%%%%%%%%%
if order==2
    % out3 = a; out4 = d;
    [out3,out4] = dwt(x,Lo_D,Hi_D);
    ent = [wentropy(out3,type_ent,parameter)...
           wentropy(out4,type_ent,parameter)];
    insert_ts = [indord+1:indord+order ;length(out3) length(out4)];
    insert_ds = [out3 out4];
    a_len = length(out3);

elseif order==4
    % out3 = a; out4 = h; out5 = v; out6 = d;
    [out3,out4,out5,out6] = dwt2(x,Lo_D,Hi_D);
    ent = [wentropy(out3,type_ent,parameter) ...
           wentropy(out4,type_ent,parameter) ...
           wentropy(out5,type_ent,parameter) ...
           wentropy(out6,type_ent,parameter)];
    insert_ts = [indord+1:indord+order ;
                 size(out3)' size(out4)' size(out5)' size(out6)'];
    insert_ds = [out3(:)' out4(:)' out5(:)' out6(:)'];
    a_len = size(out3)';
end

%
% Modification of Tree and Data Structures.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
depth = wtreemgr('depth',Ts);
Ts  = wtreemgr('replace',Ts,insert_ts,pack_exist,pack_exist);
Ds  = wdatamgr('replace',Ds,insert_ds,beg_p,beg_p+len_p-1);

if treedpth(Ts) > depth
    sizes   = wdatamgr('rsizes',Ds);
    Ds    = wdatamgr('wsizes',Ds,[sizes a_len]);

    ent_old = wdatamgr('read_ent',Ds);
    len_ent = length(ent_old);
    tmp     = NaN;
    ent_new = tmp(ones(1,order*len_ent+1));
    ent_new(1:len_ent) = ent_old;
    Ds    = wdatamgr('write_ent',Ds,ent_new);

    ent_old = wdatamgr('read_ento',Ds);
    ent_new(1:len_ent) = ent_old;
    Ds    = wdatamgr('write_ento',Ds,ent_new);
end

Ds = wdatamgr('write_ent',Ds,ent(1:order),insert_ts(1,1:order));
