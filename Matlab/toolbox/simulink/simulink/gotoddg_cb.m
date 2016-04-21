function varargout = gotoddg_cb(src, action, varargin)

% Copyright 2003 The MathWorks, Inc.

if isnumeric(src) & ishandle(src)
    h = get_param(src,'Object');
    blkH = src;
else
    h = src.getBlock;
    blkH = h.Handle;
end

if strcmp(h.BlockType, 'Goto')  % dealing with GOTO block
    if length(h.FromBlocks)>0
        blockHandles = [h.FromBlocks(:).handle];
    else
        blockHandles = [];
    end
    isGoto = true;
else                            % dealing with FROM block
    blockHandles = h.GotoBlock.handle;
    isGoto = false;
end

switch action
    case 'hilite'
        block = varargin{1};
        found = ~strcmp(get_param(block,'HiliteAncestors'),'find');
        gotoddg_cb(blkH, 'unhilite');
        if found
            hilite_system(block, 'find');
        end

    case 'unhilite'
        hiliting = char(get_param(blockHandles,'HiliteAncestors'));
        ind = strmatch('find',hiliting);
        if ~isempty(ind)
            hilite_system(blockHandles(ind), 'none');
        end

    case 'refresh'
        if ~isGoto
            refreshFrom(get_param(h.GotoBlock.handle,'Object'));
        end

    case 'getFromHTML'
        fromBlks = get_param(blkH,'FromBlocks');
        if ~isempty(fromBlks)
            varargout{1} = getFromHTML(blkH, {fromBlks(:).name});
        else
            varargout{1} = getFromHTML(blkH, {});
        end
        
    case 'getGotoTagEntries'
        varargout{1} = getGotoTagEntries(blkH);
        
    case 'getGotoURL'
        goto = get_param(blkH, 'GotoBlock');
        varargout{1} = goto.name;
        
    case 'handleGotoTag'
        dlg  = varargin{1};
        type = varargin{2};
        tag  = varargin{3};
        
    case 'doPreApply'
        dlg = varargin{1};
        [varargout{2} varargout{1}] = src.preApplyCallback(dlg); %[str bool]
        dlg.refresh;

    otherwise
        warning('DDG:SLDialogSource',['Unknown action in ' mfilename]);
end


% Utility Functions -------------------------------------------------------
function html = getFromHTML(blkH, fromBlks)
html = [...
    '<html><body padding="0" spacing="0">'...
    '<table width="100%" cellpadding="0" cellspacing="0">'...
    '<tr><td align="left"><b>Corresponding From blocks:</b></td>'...
    '<td align="right"><a href="ddgrefresh:eval('''')">refresh</a></td></tr>'...
    ];
if ~isempty(fromBlks)
    for i = 1:length(fromBlks)
        html = [html '<tr><td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'...
               '<a href="matlab:eval([''f_nz=get_param(''''' fromBlks{i} ''''',''''GotoBlock'''');gotoddg_cb(f_nz.handle,''''hilite'''',''''' fromBlks{i} ''''');clear(''''f_nz'''')''])">' fromBlks{i} '</a>'...
               '</td><td></td></tr>'];
    end
end    
html = [html '</table></body></html>'];

function refreshFrom(h)
r    = DAStudio.ToolRoot;
dlgs = r.getOpenDialogs;
for i = 1:length(dlgs)
    if isa(dlgs(i).getDialogSource,'Simulink.DDGSource')
        if strcmp(dlgs(i).getDialogSource.getBlock.BlockType,'Goto')
            dlgs(i).refresh;
        end
    end
end

function entries = getGotoTagEntries(blkH)
entries  = {};
gotoBlks = find_system(bdroot(blkH), 'LookUnderMasks', 'on', ...
                         'FollowLinks', 'on', 'BlockType', 'Goto');
if isempty(gotoBlks)
    entries = {''};
elseif length(gotoBlks) == 1
    entries = {get_param(gotoBlks, 'GotoTag')};
else
    entries = get_param(gotoBlks,'GotoTag');
end