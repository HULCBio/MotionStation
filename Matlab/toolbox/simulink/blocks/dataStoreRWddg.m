function dlgStruct = dataStoreRWddg(source, h)

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
dsName.Name             = 'Data store name:';
dsName.Type             = 'combobox';
dsName.Entries          = dataStoreRWddg_cb(h.Handle, 'getDSMemBlkEntries')';
dsName.Editable         = 1;
dsName.RowSpan          = [1 1];
dsName.ColSpan          = [1 2];
dsName.ObjectProperty   = 'DataStoreName';
dsName.Tag              = dsName.ObjectProperty;
% required for synchronization --------
dsName.MatlabMethod    = 'slDialogUtil';
dsName.MatlabArgs      = {source,'sync','%dialog','edit','%tag'};

dsBlockLbl.Name        = 'Data store memory block:';
dsBlockLbl.Type        = 'text';
dsBlockLbl.RowSpan     = [2 2];
dsBlockLbl.ColSpan     = [1 1];
dsmSrc = dataStoreRWddg_cb(h.Handle, 'findMemBlk');
if ~isempty(dsmSrc)
    dsBlock.Name      = dsmSrc;
    dsBlock.Type      = 'hyperlink';
    dsBlock.MatlabMethod = 'dataStoreRWddg_cb';
    dsBlock.MatlabArgs   = {h.Handle, 'hilite', dsBlock.Name};
else
    dsBlock.Name      = 'none';
    dsBlock.Type      = 'text';
    dsBlock.Italic    = 1;
end
dsBlock.RowSpan       = [2 2];
dsBlock.ColSpan       = [2 2];

dsRWBlks.Type           = 'textbrowser';
dsRWBlks.Text           = dataStoreRWddg_cb(h.Handle, 'getRWBlksHTML');
dsRWBlks.RowSpan        = [3 3];
dsRWBlks.ColSpan        = [1 2];
dsRWBlks.Tag            = 'dsRWBlks';

dsTS.Name               = 'Sample time:';
dsTS.Type               = 'edit';
dsTS.RowSpan            = [4 4];
dsTS.ColSpan            = [1 2];
dsTS.ObjectProperty     = 'SampleTime';
dsTS.Tag                = dsTS.ObjectProperty;
% required for synchronization --------
dsTS.MatlabMethod    = 'slDialogUtil';
dsTS.MatlabArgs      = {source,'sync','%dialog','edit','%tag'};

paramGrp.Name           = 'Parameters';
paramGrp.Type           = 'group';
paramGrp.Items          = {dsName, dsBlockLbl, dsBlock, dsRWBlks, dsTS};
paramGrp.LayoutGrid     = [4 2];
paramGrp.RowStretch     = [0 0 1 0];
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
dlgStruct.CloseCallback = 'dataStoreRWddg_cb';
dlgStruct.CloseArgs     = {h.Handle, 'unhilite'};
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