function varargout = dataStoreRWddg_cb(blkH, action, varargin)

% Copyright 2003 The MathWorks, Inc.

h = get_param(blkH,'object');

blockHandles = [];
blockNames   = {};
if strcmp(h.BlockType, 'DataStoreMemory')
    if ~isempty(h.DSReadWriteBlocks)
        blockHandles = [h.DSReadWriteBlocks(:).handle];
        blockNames   = {h.DSReadWriteBlocks(:).name};
    end
else
    if ~isempty(h.DSReadOrWriteSource)
        blockHandles = [h.DSReadOrWriteSource(:).handle];
        blockNames   = {h.DSReadOrWriteSource(:).name};
    end
end

switch action
    case 'hilite'
        block = varargin{1};
        found = ~strcmp(get_param(block,'HiliteAncestors'),'find');
        dataStoreRWddg_cb(blkH, 'unhilite', [blockHandles get_param(block,'Handle')]);
        if found
            hilite_system(block, 'find');
        end

    case 'unhilite'
        if nargin > 2   % we want to unhilite specific blocks
            blockHandles = varargin{1};
        end
        hiliting = char(get_param(blockHandles,'HiliteAncestors'));
        ind = strmatch('find',hiliting);
        if ~isempty(ind)
            hilite_system(blockHandles(ind), 'none');
        end

    case 'getDSMemBlkEntries'
        varargout{1} = getDSMemBlkEntries(blkH);        
        
    case 'getRWBlksHTML'
        varargout{1} = getRWBlksHTML(blkH, blockNames);

    case 'findMemBlk'
        dsmSrc = findMatchingDSMemBlock(blkH, get_param(blkH,'DataStoreName'));
        varargout{1} = strrep(dsmSrc, sprintf('\n'), ' ');

    otherwise
        warning('DDG:SLDialogSource',['Unknown action in ' mfilename]);
end


% Utility Functions -------------------------------------------------------
% getRWBlksHTML: return valid HTML representing available data store
% read/write blocks to be displayed in a textbrowser widget
function html = getRWBlksHTML(blkH, RWBlks)
if strcmp(get_param(blkH,'BlockType'), 'DataStoreRead')
    blkType = 'Data Store Write';
else
    blkType = 'Data Store Read';
end
html = [...
    '<html><body padding="0" spacing="0">'...
    '<table width="100%" cellpadding="0" cellspacing="0">'...
    '<tr><td align="left"><b>Corresponding ' blkType ' blocks:</b></td>'...
    '<td align="right"><a href="ddgrefresh:eval('''')">refresh</a></td></tr>'...
    ];
if ~isempty(RWBlks)
    for i = 1:length(RWBlks)
        html = [html '<tr><td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'...
            '<a href="matlab:eval([''f_nz=get_param(''''' RWBlks{i} ''''',''''Handle'''');dataStoreRWddg_cb(f_nz,''''hilite'''',''''' RWBlks{i} ''''');clear(''''f_nz'''')''])">' RWBlks{i} '</a>'...
            '</td><td></td></tr>'];
    end
end
html = [html '</table></body></html>'];

% getDSMemBlkEntries: get combobox entries of all available data store
% memory blocks
function entries = getDSMemBlkEntries(blkH)
entries  = {};
dsBlks = find_system(bdroot(blkH), 'LookUnderMasks', 'on', ...
                     'FollowLinks', 'on', 'BlockType', 'DataStoreMemory');
if isempty(dsBlks)
    entries = {''};
elseif length(dsBlks) == 1
    entries = {get_param(dsBlks, 'DataStoreName')};
else
    entries = get_param(dsBlks,'DataStoreName');
end

% findMatchingDSMemBlock: returns the memory block corresponding to a name
function dsmBlk = findMatchingDSMemBlock(blk, dsName)
dsmBlk = find_system(get_param(blk, 'Parent'), ...
    'SearchDepth',   1, ...
    'BlockType',     'DataStoreMemory', ...
    'DataStoreName', dsName);
if ~isempty(dsmBlk)
    dsmBlk = dsmBlk{1};
else
    blk = get_param(blk, 'Parent');
    if ~strcmp(bdroot(blk), blk)
        dsmBlk = findMatchingDSMemBlock(blk, dsName);
    end
end

