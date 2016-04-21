function dlgStruct = gotoddg(source, h)

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
gotoTag.Name            = 'Tag:';
gotoTag.Type            = 'edit';
gotoTag.RowSpan         = [1 1];
gotoTag.ColSpan         = [1 1];
gotoTag.ObjectProperty  = 'GotoTag';
gotoTag.Tag             = gotoTag.ObjectProperty;
% required for synchronization --------
gotoTag.MatlabMethod    = 'slDialogUtil';
gotoTag.MatlabArgs      = {source,'sync','%dialog','edit','%tag'};

gotoVis.Name            = 'Tag Visibility:';
gotoVis.Type            = 'combobox';
gotoVis.Entries         = h.getPropAllowedValues('TagVisibility')';
gotoVis.RowSpan         = [1 1];
gotoVis.ColSpan         = [2 2];
gotoVis.ObjectProperty  = 'TagVisibility';
gotoVis.Tag             = gotoVis.ObjectProperty;
% required for synchronization --------
gotoVis.MatlabMethod    = 'slDialogUtil';
gotoVis.MatlabArgs      = {source,'sync','%dialog','combobox','%tag'};

gotoFrom.Name           = 'Corresponding From blocks:';
gotoFrom.Type           = 'textbrowser';
gotoFrom.Text           = gotoddg_cb(source, 'getFromHTML');
gotoFrom.RowSpan        = [2 2];
gotoFrom.ColSpan        = [1 2];
gotoFrom.Tag            = 'gotoFrom';

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

paramGrp.Name           = 'Parameters';
paramGrp.Type           = 'group';
paramGrp.Items          = {gotoTag, gotoVis, gotoFrom, gotoIcon};
paramGrp.LayoutGrid     = [3 2];
paramGrp.RowStretch     = [0 1 0];
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
dlgStruct.PreApplyMethod = 'preApplyCallback';
dlgStruct.PreApplyArgs   = {'%dialog'};
dlgStruct.PreApplyArgsDT = {'handle'};
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
