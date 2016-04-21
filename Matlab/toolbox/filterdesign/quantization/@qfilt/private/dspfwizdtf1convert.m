function dspfwizdtf1convert(Hq, hTar)
%DSPFWIZDTF1CONVERT Add Convert blocks in each section of a Direct Form I
% (DF-I and DF-ISOS) and Direct Form II Transposed (DF-IIT and DF-IITSOS)

% INPUTS: 
%    Hq: qfilt
%    hTar: dspfwiztarget.abstracttarget

%    Author(s): V. Pellissier
%    Copyright 1999-2002 The MathWorks, Inc.
%    $Revision: 1.9 $  $Date: 2002/11/21 15:51:17 $

sys = hTar.system;

% Add a Convert after Input block if filter not scaled
scalblk = find_system(sys, 'Name', 'ConvertS1'); 
if isempty(scalblk),
    inblk = find_system(sys, 'BlockType', 'Inport');
    oldpos = get_param(inblk{1}, 'Position');
    offset = [0 -7 5 8];
    dspfwizaddconvert(Hq, hTar, oldpos + offset, 'In', 'right', inblk{1}, 'source', inblk{1}, [-50 0 -50 0]);
end

a1blk = find_system(sys, 'Regexp', 'on', 'Name', '^1|');
if ~isempty(a1blk),
    % Convert before scaler 1|a(1,i)
    for i=1:length(a1blk),
        oldpos = get_param(a1blk{i}, 'Position');
        dspfwizaddconvert(Hq, hTar, oldpos + [-10 0 -5 0], ['A' sprintf('%d', i)], ...
            'right', a1blk{i}, 'destination', a1blk{i}, [45 0 45 0]);
        
        % Refresh connections of 1|a(1,i) blocks (cosmetic)
        conn = get_param(a1blk{i}, 'PortConnectivity');
        [dummy, srcblk] = fileparts(a1blk{i});
        dstblocks = conn(end).DstBlock;
        dstblocks = get_param(dstblocks, 'Name');
        if ~iscell(dstblocks), dstblocks = {dstblocks}; end
        for j=1:length(dstblocks), 
            delete_line(sys, [srcblk '/1'], [dstblocks{j} '/' num2str(conn(end).DstPort(j)+1)]);  
            add_line(sys, [srcblk '/1'], [dstblocks{j} '/' num2str(conn(end).DstPort(j)+1)], ... 
                'autorouting', 'on');
        end
    end
end

% Convert in the recursive branchs (feeding the a(i,j) gains)
if ~isfir(Hq),
    delayblk = find_system(sys, 'Name', 'BodyRDelay(2)'); 
    if issos(Hq), delayblk = [delayblk; find_system(sys, 'Regexp', 'on', 'Name', '^BodyRDelay(2,')]; end
    if ~isempty(delayblk),
        % Destination of Convert (DFI)
        for i=1:length(delayblk),
            oldpos = get_param(delayblk{i}, 'Position');
            dspfwizaddconvert(Hq, hTar, oldpos + [0 -50 0 -50], ['R' sprintf('%d', i)], ...
                'down', delayblk{i}, 'destination');
            % Reconnect Goto
            conn = get_param([sys '/ConvertR' sprintf('%d', i)], 'PortConnectivity');
            gotoblock = find_system(sys, 'BlockType', 'Goto');
            gotoblock = [gotoblock; find_system(sys, 'Regexp', 'on', 'Name', '^s(')];
            for j=1:length(gotoblock),
                gotoconn = get_param(gotoblock{j}, 'PortConnectivity');
                if find(gotoconn(1).SrcBlock==conn(1).SrcBlock),
                    [dummy, gotoblock] = fileparts(gotoblock{j});
                    srcblck = get_param(gotoconn(1).SrcBlock, 'Name');
                    delete_line(sys, [srcblck '/1'], [gotoblock '/1']);
                    add_line(sys, ['ConvertR' sprintf('%d', i) '/1'], [gotoblock '/1'], 'autorouting', 'on');
                    break
                end
            end
        end
    else
        % Convert: after 1|a(1,i) blocks (DFIIT)
        srcblock = a1blk; % Source of Convert
        offset = [15 60 20 60];
        if isempty(srcblock),
            % Convert: after HeadSum 
            srcblock = find_system(sys, 'Regexp', 'on', 'Name', '^HeadSum'); % Source of Convert
            offset = [130 60 135 60];
            if isempty(srcblock),
                % Convert: after b(1)
                srcblock = find_system(sys, 'Name', 'b(1)'); % Source of Convert
                if issos(Hq), srcblock = [srcblock find_system(sys, 'Regexp', 'on', 'Name', '^b(1,')]; end
                offset = [205 60 210 60];
            end
        end
        for i=1:length(srcblock),
            pos = get_param(srcblock{i}, 'Position') + offset;
            dspfwizaddconvert(Hq, hTar, pos, ['R' sprintf('%d', i)], 'down', srcblock{i}, 'source');
            if ~isempty(find_system('Name', ['/ConvertR' sprintf('%d', i)])),
                % Reconnect Output branch
                conn = get_param([sys '/ConvertR' sprintf('%d', i)], 'PortConnectivity');
                destblock = find_system(sys, 'BlockType', 'Outport');
                for j=1:length(destblock),
                    if find(get_param(destblock{j}, 'Handle')==conn(end).DstBlock),
                        [dummy, destblock] = fileparts(destblock{j});
                        [dummy, srcblck] = fileparts(srcblock{i});
                        delete_line(sys, ['ConvertR' sprintf('%d', i) '/1'], [destblock '/1']);
                        add_line(sys, [srcblck '/1'], [destblock '/1'], 'autorouting', 'on');
                        break
                    end
                end
            end
        end
    end
end
