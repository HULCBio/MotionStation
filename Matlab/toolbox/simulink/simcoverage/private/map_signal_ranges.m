function map_signal_ranges(modelH,covdata,informerObj)

% Copyright 2003 The MathWorks, Inc.

    % Function to put signal range information on all lines
    lineHandles = find_system(modelH,'findall','on','LookUnderMasks','all','FollowLinks','on','type','line','SegmentType','trunk');
    srcBlockH = get_param(lineHandles ,'SrcBlockHandle');
    srcPortH = get_param(lineHandles ,'SrcPortHandle');
    srcPortIdx = get_param([srcPortH{:}]', 'PortNumber');
    isVirtual = strcmp(get_param([srcBlockH{:}]','Virtual'),'on');
    
    % Convert properties to cell arrays
    lineCnt = length(lineHandles);
    %srcBlockH = num2cell(srcBlockH);
    %srcPortIdx = num2cell(srcPortIdx);
%    firstIdx = cell(lineCnt);
%    lastIdx = cell(lineCnt);
    
    % Remap virtual blocks to their non-virtual sources.
    virtualIdx = find(isVirtual);
    for lineIdx = virtualIdx(:)'
        srcPorts = get_param(lineHandles(lineIdx),'NonVirtualSrcPorts');
        portCnt = length(srcPorts);
        thisSrcBlock = zeros(portCnt);
        thisSrcPortIdx = zeros(portCnt);
        
        for i = 1:portCnt
            porti = srcPorts(i);
            linei = get_param(porti,'Line');
            thisSrcBlock(i) = get_param(linei ,'SrcBlockHandle');
            thisSrcPortIdx(i) = get_param(porti,'PortNumber');
        end
        
        srcBlockH{lineIdx} = thisSrcBlock;
        srcPortIdx{lineIdx} = thisSrcPortIdx;
    end

    for i=1:lineCnt
        map_single_signal_ranges(informerObj, lineHandles(i), srcBlockH{i}, srcPortIdx{i}, covdata);
    end

function str = formatted_block_name(blockH)
    maxStrLength = 40;
    
    str = getfullname(blockH);
    str = strrep(str,'\n',' ');
    if length(str) > maxStrLength
        str = [str(1:(maxStrLength-3)) '...'];
    end

function map_single_signal_ranges(informerObj, lineHandle, blocks, ports, covdata)

    % XXX - Temporarily make the assumption that all of the
    % elements from an outport appear in the line.  This may
    % not be true for lines that have virtual blocks as the 
    % graphical source.
    
    % WISH - We need to implement an efficient way to prune the
    % display for large vectorized or bus signals.

    lineUdi = get_param(lineHandle,'LineOwner');
    
    allNames = {};
    allMins = [];
    allMaxs = [];
    
    try,
        for i = 1:length(blocks)
            name = {formatted_block_name(blocks(i))};
            [mins,maxs] = sigrangeinfo(covdata,blocks(i),ports(i));
            allNames = [allNames  name(ones(1,length(mins)))];     
            allMins = [allMins mins];
            allMaxs = [allMaxs maxs];
        end
    
        tableData.allNames = allNames;
        tableData.allMins = allMins;
        tableData.allMaxs = allMaxs;
        totalWidth = length(allMins);
        dispRows = min([totalWidth 20]);
    
        template = {'$<B>Idx</B>', '$<B>Source Block</B>','$<B>Min</B>', '$<B>Max</B>', '\n', ...
                      {'ForN', dispRows, ...
                        '@1', {'#allNames','@1'}, {'#allMins','@1'}, {'#allMaxs','@1'}, '\n'} ...
                   };
    
        systableInfo.cols(1).align = 'LEFT';
        systableInfo.cols(2).align = 'LEFT';
        systableInfo.cols(3).align = 'CENTER';
        systableInfo.table = '  CELLPADDING="2" CELLSPACING="1"';
        systableInfo.textSize = 4;
    
        tableStr = cv('Private','html_table',tableData,template,systableInfo);
        if ~isempty(informerObj)
            informerObj.mapData(lineUdi,['<big> <BR> ' tableStr '</big>']);
        end
    catch
    end
    
    
    