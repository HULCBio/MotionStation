function dlgStruct = fromddg(source, h)

% Copyright 2003-2004 The MathWorks, Inc.

% Top group is the block description
descTxt.Name            = h.BlockDescription;
descTxt.Type            = 'text';
descTxt.WordWrap        = true;

descGrp.Name            = h.BlockType;
descGrp.Type            = 'group';
descGrp.Items           = {descTxt};
descGrp.RowSpan         = [1 1];
descGrp.ColSpan         = [1 1];

% Bottom group is the block parameters
gotoTag.Name            = 'Goto Tag:';
gotoTag.Type            = 'combobox';
gotoTag.Entries         = gotoddg_cb(source, 'getGotoTagEntries')';
gotoTag.Editable        = 1;
gotoTag.RowSpan         = [1 1];
gotoTag.ColSpan         = [1 2];
gotoTag.ObjectProperty  = 'GotoTag';
gotoTag.Tag             = gotoTag.ObjectProperty;
% required for synchronization --------
gotoTag.MatlabMethod    = 'slDialogUtil';
gotoTag.MatlabArgs      = {source,'sync','%dialog','edit','%tag'};

gotoBlockLbl.Name       = 'Goto Source:';
gotoBlockLbl.Type       = 'text';
gotoBlockLbl.RowSpan    = [2 2];
gotoBlockLbl.ColSpan    = [1 1];
if isempty(h.GotoBlock.name)
    gotoBlock.Name      = 'none';
    gotoBlock.Type      = 'text';
    gotoBlock.Italic    = 1;
else
    url = gotoddg_cb(source, 'getGotoURL');
    gotoBlock.Name      = url;
    gotoBlock.Type      = 'hyperlink';
    gotoBlock.MatlabMethod = 'gotoddg_cb';
    gotoBlock.MatlabArgs   = {source, 'hilite', url};
end
gotoBlock.RowSpan       = [2 2];
gotoBlock.ColSpan       = [2 2];

gotoIcon.Name           = 'Icon Display:';
gotoIcon.Type           = 'combobox';
gotoIcon.Entries        = h.getPropAllowedValues('IconDisplay')';
gotoIcon.RowSpan        = [3 3];
gotoIcon.ColSpan        = [1 2];
gotoIcon.ObjectProperty = 'IconDisplay';
gotoIcon.Tag            = gotoIcon.ObjectProperty;
% required for synchronization --------
gotoIcon.MatlabMethod   = 'slDialogUtil';
gotoIcon.MatlabArgs     = {source,'sync','%dialog','combobox','%tag'};

spacer.Name             = '';
spacer.Type             = 'text';
spacer.RowSpan          = [4 4];
spacer.ColSpan          = [1 2];

paramGrp.Name           = 'Parameters';
paramGrp.Type           = 'group';
paramGrp.Items          = {gotoTag, gotoBlockLbl, gotoBlock, gotoIcon, spacer};
paramGrp.LayoutGrid     = [4 2];
paramGrp.RowStretch     = [0 0 0 1];
paramGrp.ColStretch     = [0 1];
paramGrp.RowSpan        = [2 2];
paramGrp.ColSpan        = [1 1];
paramGrp.Source         = h;

%-----------------------------------------------------------------------
% Assemble main dialog struct
%-----------------------------------------------------------------------
dlgStruct.DialogTitle   = ['Block Parameters: ' strrep(h.Name, sprintf('\n'), ' ')];
dlgStruct.Items         = {descGrp, paramGrp};
dlgStruct.LayoutGrid    = [2 1];
dlgStruct.RowStretch    = [0 1];
dlgStruct.CloseCallback = 'gotoddg_cb';
dlgStruct.CloseArgs     = {source, 'unhilite'};
dlgStruct.HelpMethod    = 'slhelp';
dlgStruct.HelpArgs      = {h.Handle};
% Required for simulink/block sync ----
dlgStruct.PreApplyCallback = 'gotoddg_cb';
dlgStruct.PreApplyArgs  = {source, 'doPreApply', '%dialog'};
% Required for deregistration ---------
dlgStruct.CloseMethod       = 'closeCallback';
dlgStruct.CloseMethodArgs   = {'%dialog'};
dlgStruct.CloseMethodArgsDT = {'handle'};

[isLib, isLocked] = source.isLibraryBlock(h);
if isLocked || source.isHierarchySimulating
  dlgStruct.DisableDialog = 1;
else
  dlgStruct.DisableDialog = 0;
end
