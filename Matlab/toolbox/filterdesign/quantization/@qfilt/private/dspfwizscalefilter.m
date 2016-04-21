function dspfwizscalefilter(Hq,hTar)
%DSPFWIZSCALEFILTER Add a Gain and a Convert block at the input and output of the filter.

% INPUTS:
%    Hq: qfilt
%    hTar: dspfwiztarget.abstracttarget

%    Author(s): V. Pellissier
%    Copyright 1999-2002 The MathWorks, Inc.
%    $Revision: 1.3 $  $Date: 2002/11/21 15:51:15 $

error(nargchk(2,2,nargin));

sys = hTar.system;
s = scalevalues(Hq);

isinputscaled = 0;
isoutputscaled = 0;
if ~isempty(s),
    % Scale Input
    isinputscaled = 1;
    srcblk = find_system(sys, 'BlockType', 'Inport');
    oldpos = get_param(srcblk{1}, 'Position');
    addscalar(Hq, hTar, oldpos + [10 -7 10 8], '1', 'right', srcblk{1}, 'source', ...
        num2str( s(1)), srcblk{1}, [-100 0 -100 0]);
    
    % Convert: before the scalar
    dstblk = [sys '/s(1)'];
    dspfwizaddconvert(Hq, hTar, oldpos + [-40 -7 -35 8], 'S1', 'right', dstblk, 'destination');

    if length(s)==2,
       isoutputscaled = 1;
       % Scale Output 
       dstblk = find_system(sys, 'BlockType', 'Outport');
       oldpos = get_param(dstblk{1}, 'Position');
       orient = get_param(dstblk{1}, 'Orientation');
       if strcmpi(orient, 'right'),
           scalar_offset = [40 -7 40 8];
           direct = 1;
           convert_offset = [-10 -7 -5 8];
       else
           % Special case: Lattice AR All-Pass
           scalar_offset = [-40 -7 -40 8];
           direct = -1;
           convert_offset = [5 -7 10 8];
       end
       addscalar(Hq, hTar, oldpos + scalar_offset, '2', orient, dstblk{1}, 'destination', ...
           num2str( s(2)), dstblk{1}, direct*[100 0 100 0]);
       
       % Convert: before the scalar
       dstblk = [sys '/s(2)'];
       dspfwizaddconvert(Hq, hTar, oldpos + convert_offset, 'S', orient, dstblk, 'destination');

    end
end


% --------------------------------------------------------------
function addscalar(Hq, hTar, pos, no, orient, blk, blkdescription, scaleval, movedblk, pdecal)
%ADDSCALAR Add a gain block

% INPUTS: 
%    Hq: qfilt
%    hTar: dspfwiztarget.abstracttarget
%    pos: position of the block
%    no: number of the scaler (string) -> name of the block 's(no)'
%    orient: orientation of the block
%    blk: block source or destination of the new gain block
%    blkdescription: 'source' or 'destination'
%    scaleval: value of the gain (string)
%    movedblk: block to move (optional)
%    pdecal: offset to apply to the block moved (optional)

error(nargchk(8,10,nargin));

sys = hTar.system;

if nargin>9,
    % Move Block
    oldpos = get_param(movedblk, 'Position');
    set_param(movedblk, 'Position',oldpos + pdecal);
end

if strcmpi(blkdescription, 'source'),
    srcblk = blk;
    % Disconnect source block
    conn = get_param(srcblk, 'PortConnectivity');
    [dummy, srcblk] = fileparts(srcblk);
    dstblocks = conn(end).DstBlock;
    dstblocks = get_param(dstblocks, 'Name');
    if ~iscell(dstblocks), dstblocks = {dstblocks}; end
    for i=1:length(dstblocks),
        delete_line(sys, [srcblk '/1'], [dstblocks{i} '/1']); 
    end
elseif strcmpi(blkdescription, 'destination'),
    dstblocks = blk;
    % Disconnect destination block
    conn = get_param(dstblocks, 'PortConnectivity');
    [dummy, dstblocks] = fileparts(dstblocks);
    srcblk = conn(1).SrcBlock;
    srcblk = get_param(srcblk, 'Name');
    delete_line(sys, [srcblk '/1'], [dstblocks '/1']); 
else 
    error(lasterr);
end

% Add Scalar
blk = ['s(' no ')'];
hTar.gain(blk, scaleval, Hq);
set_param([sys '/' blk], 'Position', pos, ...
    'Orientation', orient, 'ShowName', 'on');

% New connections:
add_line(sys, [srcblk '/1'], [blk '/1'],'autorouting','on');  % Connect Source to Convert
if ~iscell(dstblocks), dstblocks = {dstblocks}; end
for i=1:length(dstblocks),
    % Connect Convert to old destinations of the Source
    add_line(sys, [blk '/1'], [dstblocks{i} '/1'],'autorouting','on'); 
end


