function mpc_block_resize(blk,MDenabled,mpcobjname)
% MPC_BLOCK_RESIZE Modify the I/O structure depending on whether MDs are
% present

%   Authors: A. Bemporad, J. Owen
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2004/04/19 01:16:36 $

if nargin<1,
    % MPC_BLOCK_RESIZE is called as a LoadFnc
    blk = gcb;  % Use this when LoadFcn is part of the MPC block
    MDenabled = strcmp(get_param(blk,'md_inport'),'on');
elseif nargin==1 % Called from mask initialization 
    % are any masks already open?
    oldsh = get(0,'ShowHiddenHandles');
    set(0,'ShowHiddenHandles','on');
    fig = findobj('Type','figure', 'Tag', 'MPC_mask');
    set(0,'ShowHiddenHandles',oldsh');
    thismask = findobj(fig, 'flat', 'UserData', get_param(blk,'Handle'));
    thisCheckBox = findobj(thismask, 'Tag', 'checkbox1');
    if ~isempty(thisCheckBox)
        MDenabled = get(thisCheckBox,'Value');
    else
        MDenabled = strcmp(get_param(blk,'md_inport'),'on');
    end
end
    
nomdinobj=~MDenabled;
if nargin<3,
    mpcobjname=strtrim(get_param(blk,'mpcobj'));
end

muxblkcell = find_system(blk,'FollowLinks','on','LookUnderMasks','all','blocktype','Mux');
muxblk = muxblkcell{1};
inports = get_param(muxblk,'PortConnectivity');
numinputs = str2num(get_param(muxblk,'Inputs'));
maskdisplay=get_param(blk,'MaskDisplay');

s=warning;
warning off;

% Convert from 3 ports to 2 ports
if nomdinobj>0,
    % Resize block with no measured disturbances
    aux='port_label(''input'', 3';
    pos=findstr(maskdisplay,aux);
    if pos>0,
        maskdisplay=maskdisplay(1:pos-2);
    end
    set_param(blk,'MaskDisplay',maskdisplay);
    try
        delete_line(blk,'In3/1','Mux/3');
    end
    set_param(muxblk,'Inputs','2');
    try
        delete_block(inports(3).SrcBlock);
    end
    set_param(blk,'md_inport','off')
end

% Convert from 2 ports to 3 ports
if nomdinobj==0,
    % Resize block with measured disturbances
    maskdisplay=[maskdisplay char(10) 'port_label(''input'', 3, ''md'')'];
    set_param(blk,'MaskDisplay',maskdisplay);
    try
        add_block([blk '/In1'],[blk '/In3']);
    end
    set_param(muxblk,'Inputs','3');
    try
        add_line(blk,'In3/1','Mux/3');
    end
    set_param([blk '/In3'],'position',[240    88   270   102]);
    set_param([blk '/In3'],'orientation','left');
    set_param(blk,'md_inport','on')
end
warning(s);
