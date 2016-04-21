function dspfwizdtf2convert(Hq, hTar)
%DSPFWIZDTF2CONVERT Add Convert blocks in each section of a Direct Form II
% (DF-II and DF-IISOS), Direct Form I Transposed (DF-IT and DF-ITSOS) and
% Direct Form FIR (DF-FIR and DF-FIRSOS)

% INPUTS: 
%    Hq: qfilt
%    hTar: dspfwiztarget.abstracttarget

%    Author(s): V. Pellissier
%    Copyright 1999-2002 The MathWorks, Inc.
%    $Revision: 1.8 $  $Date: 2002/11/21 15:51:18 $

sys = hTar.system;

isinputscaled = 1;
scalblk = find_system(sys, 'Name', 'ConvertS1'); 
if isempty(scalblk),
    isinputscaled = 0;
end

% Add Convert blocks in each section
if isfir(Hq),
    % FIR
    if isinputscaled,
        % Convert: after scalar s(1)
        srcblk = scalblk;
        offset = [60 0 65 0];
    else
        % Convert: after the GatewayIn
        srcblk = find_system(sys, 'BlockType', 'Inport');
        offset = [60 -7 65 8];
    end
    for i=1:length(srcblk),
        pos = get_param(srcblk{i}, 'Position') + offset;
        dspfwizaddconvert(Hq, hTar, pos , ['A' sprintf('%d',i)], 'right', srcblk{i}, 'source');
    end
else
    % IIR
    a1blk = find_system(sys, 'Regexp', 'on', 'Name', '^1|');
    if ~isempty(a1blk),
        offset = [-30 0 -25 0];
        % Convert: before each 1|a(1,i) block
        for i=1:length(a1blk),
            oldpos = get_param(a1blk{i}, 'Position');
            dspfwizaddconvert(Hq, hTar, oldpos + offset, ['A' sprintf('%d', i)], ...
                'right', a1blk{i}, 'destination', a1blk{i}, [20 0 20 0]);
            
            % Refresh connections of 1/a(1,i) blocks (cosmetic)
            conn = get_param(a1blk{i}, 'PortConnectivity');
            [dummy, srcblk] = fileparts(a1blk{i});
            dstblocks = conn(end).DstBlock;
            dstblocks = get_param(dstblocks, 'Name');
            if ~iscell(dstblocks), dstblocks = {dstblocks}; end
            for j=1:length(dstblocks), 
                delete_line(sys, [srcblk '/1'], [dstblocks{j} '/' num2str(conn(end).DstPort(j)+1)]);  
                add_line(sys, [srcblk '/1'], [dstblocks{j} '/' num2str(conn(end).DstPort(j)+1)], 'autorouting', 'on');
            end
        end
    end
    
    % Convert in the recursive branch
    srcblock = a1blk; % Convert: after gain 1/a(1,i)
    offset = [45 0 50 0];
    if isempty(srcblock),
        srcblock = find_system(sys, 'Regexp', 'on', 'Name', '^HeadSumL'); % Convert: after Head sum
        offset = [80, -1, 85, 1];
        if isempty(srcblock),
            if isinputscaled,
                % Convert: after scalar s(1)
                srcblock = scalblk;
                offset = [130 0 135 0];
            else
                % Convert: after the GatewayIn
                srcblock = find_system(sys, 'BlockType', 'Inport');
                offset = [180 -7 185 8];
            end
        end
    end
    for i=1:length(srcblock),
        pconvert = get_param(srcblock{i}, 'Position') + offset;
        dspfwizaddconvert(Hq, hTar, pconvert, ['R' sprintf('%d',i)], 'right', srcblock{i}, 'source');
    end
end
