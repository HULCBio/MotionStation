function dspfwizaddgatewayout(Hq, hTar, coef, convertflag)
%DSPFWIZADDGATEWAYOUT Add a GatewayOut block and a Convert block if
%specified by CONVERTFLAG

% INPUTS: 
%    Hq: qfilt
%    hTar: dspfwiztarget.abstracttarget
%    coef: tune the position of the GatewayOut block (-1<coef<1)
%    convertflag: 'convert' -> add a Convert block begore the GatewayOut

%    Author(s): V. Pellissier
%    Copyright 1999-2002 The MathWorks, Inc.
%    $Revision: 1.3 $  $Date: 2002/03/28 23:00:24 $

error(nargchk(4,4,nargin));

% Skip Convert and gatewayOut blocks if quantizer Mode is 'none'
if strcmpi(get(outputformat(Hq), 'Mode'), 'none'),
    return
end

sys = hTar.system;

% Find Output block
dstblk = find_system(sys, 'BlockType', 'Outport');
dstblk = dstblk{1};
oldpos = get_param(dstblk, 'Position');

% Define orientation 
orient = get_param(dstblk, 'Orientation');

if strcmpi(orient, 'right'),
    % Offset to apply to convert block compared to the position of the Output block
    offset = [-10, -7, -5, 8]; 
    decal = [50 0 50 0]; % Move Output block by decal
else
    % Special case: Lattice All-pass
    
    % Offset to apply to convert block compared to the position of the Output block
    offset = [5, -7, 10, 8];
    decal = [-50 0 -50 0]; % Move Output block by decal
    
    % Move Input
    blk = find_system(sys, 'BlockType', 'Inport');
    set_param(blk{1}, 'Position', get_param(blk{1}, 'Position')+ [-50 0 -50 0]);
end

if strcmpi(convertflag, 'convert'),
    % Add a Convert block: this will move the Output block
    dspfwizaddconvert(Hq, hTar, oldpos + offset, 'Out', ...
        orient, dstblk, 'destination', dstblk, decal, 'out');
end

