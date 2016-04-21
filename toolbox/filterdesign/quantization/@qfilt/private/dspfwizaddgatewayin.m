function dspfwizaddgatewayin(Hq, hTar)
%DSPFWIZADDGATEWAYIN Add a GatewayIn block.

% INPUTS: 
%    Hq: qfilt
%    hTar: dspfwiztarget.abstracttarget

%    Author(s): V. Pellissier
%    Copyright 1999-2002 The MathWorks, Inc.
%    $Revision: 1.2 $  $Date: 2002/03/20 17:08:32 $

sys = hTar.system;

% Skip GatewayIn block if quantizer Mode is 'none'
if strcmpi(get(inputformat(Hq), 'Mode'), 'none'),
    return
end

% Move Input block to the left
inblk = find_system(sys, 'BlockType', 'Inport');
inblk = inblk{1};
oldpos = get_param(inblk, 'Position');
set_param(inblk, 'Position',oldpos + [-50 0 -50 0]);

% Disconnect Input block
conn = get_param(inblk, 'PortConnectivity');
[dummy, inblk] = fileparts(inblk);
dstblocks = conn(1).DstBlock;
for i=1:length(dstblocks),
    delete_line(sys, [inblk '/1'], [get_param(dstblocks(i), 'Name') '/1']); 
end

% Add GatewayIn block
%XXX Test if really needed
blk = 'GatewayIn';
hTar.gatewayin(blk, Hq);
ypos = (oldpos(2)+oldpos(4))/2;
newpos = oldpos;
newpos(2) = ypos-15;
newpos(4) = ypos+15;
set_param([sys '/' blk], 'Position', newpos, 'ShowName', 'off');

% New connections:
add_line(sys, [inblk '/1'], [blk '/1'],'autorouting','on');  % connect Input to GatewayIn
for i=1:length(dstblocks),
    % Connect GatewayIn to the blocks that were connected to the Input
    % block
    add_line(sys, [blk '/1'], [get_param(dstblocks(i), 'Name') '/1'],'autorouting','on'); 
end
