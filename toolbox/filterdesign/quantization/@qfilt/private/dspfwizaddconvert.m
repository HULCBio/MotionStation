function dspfwizaddconvert(Hq, hTar, pos, no, orient, blk, blkdescription, movedblk, pdecal, outflag)
%DSPFWIZADDCONVERT Add a Convert block.

% INPUTS: 
%    Hq: qfilt
%    hTar: dspfwiztarget.abstracttarget
%    pos: position of the block
%    no: number of the scaler (string) -> name of the block 's(no)'
%    orient: orientation of the block
%    blk: block source or destination of the new gain block
%    blkdescription: 'source' or 'destination'
%    movedblk: block to move (optional)
%    pdecal: offset to apply to the block moved (optional)
%    outflag: 'out' -> use outputformat quantizer instead of multiplicand
%    quantizer to  map fixed-point attributes (optional)

%    Author(s): V. Pellissier
%    Copyright 1999-2002 The MathWorks, Inc.
%    $Revision: 1.4 $  $Date: 2002/06/17 11:44:51 $

error(nargchk(7,10,nargin));

sys = hTar.system;

% Skip Convert block if quantizer Mode is 'none'
if nargin==10,
    if strcmpi(get(outputformat(Hq), 'Mode'), 'none'),
        return
    end
else
    if strcmpi(get(multiplicandformat(Hq), 'Mode'), 'none'),
        return
    end
end

if nargin>8,
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
    for j=1:length(dstblocks),
        delete_line(sys, [srcblk '/1'], [dstblocks{j} '/' num2str(conn(end).DstPort(j)+1)]); 
    end
    
    % Add Convert block 
    blk = ['Convert' no]; 
    if nargin<10, 
        hTar.convert(blk, Hq); 
    else 
        hTar.convert(blk, Hq, outflag); 
    end
    set_param([sys '/' blk], 'Position', pos, ... 
        'Orientation', orient, 'ShowName', 'off'); 
    
    % New connections: 
    add_line(sys, [srcblk '/1'], [blk '/1'],'autorouting','on');  % Connect Source to Convert 
    if ~iscell(dstblocks), dstblocks = {dstblocks}; end 
    for j=1:length(dstblocks), 
        % Connect Convert to old destinations of the Source 
        add_line(sys, [blk '/1'], [dstblocks{j} '/' num2str(conn(end).DstPort(j)+1)],'autorouting','on');  
    end
    
elseif strcmpi(blkdescription, 'destination'),
    dstblocks = blk;
    % Disconnect destination block
    conn = get_param(dstblocks, 'PortConnectivity');
    [dummy, dstblocks] = fileparts(dstblocks);
    srcblk = conn(1).SrcBlock;
    srcblk = get_param(srcblk, 'Name');
    delete_line(sys, [srcblk '/1'], [dstblocks '/1']); 
    
    % Add Convert block
    blk = ['Convert' no];
    if nargin<10,
        hTar.convert(blk, Hq);
    else
        hTar.convert(blk, Hq, outflag);
    end
    set_param([sys '/' blk], 'Position', pos, ...
        'Orientation', orient, 'ShowName', 'off');
    
    % New connections:
    add_line(sys, [srcblk '/1'], [blk '/1'],'autorouting','on');  % Connect Source to Convert
    if ~iscell(dstblocks), dstblocks = {dstblocks}; end
    % Connect Convert to old destinations of the Source
    for j=1:length(dstblocks),
        add_line(sys, [blk '/1'], [dstblocks{j} '/' num2str(conn(1).SrcPort(j)+1)],'autorouting','on');
    end
    
else 
    error(lasterr);
end

