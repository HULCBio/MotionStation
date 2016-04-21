function HasMaskDlg=hasmaskdlg(SysHandles)
%HASMASKDLG Check for existence of mask dialog.
%   VALUE=HASMASKDLG(SYS) returns 0 if the block does not have a
%   mask dialog and 1 if the block has a mask dialog.  A block has a mask
%   dialog if a dialog appears when the block is double clicked on.
%
%   SYS may either be the full pathname to the block, the handle of
%   the block, a cell array of full pathnames or a vector of handles.
%
%   See also GET_PARAM, HASMASK, HASMASKICON, LOOKUNDERMASK.

%   Loren Dean
%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.13 $

%
% validate the input data type
%
switch class(SysHandles),
  case 'char',
    SysHandles = { SysHandles }; % makes it easier to vectorize below
    
  case 'double',
  case 'cell',
    % Do Nothing

  otherwise,
    error('Wrong data type for SYS in HASMASK.');

end % switch

%
% initialize the result to zero
%
HasMaskDlg=zeros(size(SysHandles));

%
% find all blocks that have masks off and remove them from the remaining
% set of possibles
%
bIndices=find(strcmp(get_param(SysHandles,'Type'),'block'));
maskIndices=find(strcmp(get_param(SysHandles(bIndices),'Mask'),'off'));
bIndices(maskIndices)=[];

%
% find all the blocks that have non-empty MaskDescription, MaskHelp, and MaskPrompts
% set their hasmask dialog to 1, then remove them from the list
%
maskIndices=find(~strcmp(get_param(SysHandles(bIndices),'MaskDescription'),''));
HasMaskDlg(bIndices(maskIndices)) = 1;
bIndices(maskIndices)=[];
maskIndices=find(~strcmp(get_param(SysHandles(bIndices),'MaskHelp'),''));
HasMaskDlg(bIndices(maskIndices)) = 1;
bIndices(maskIndices)=[];
maskIndices=find(~strcmp(get_param(SysHandles(bIndices),'MaskPromptString'),''));
HasMaskDlg(bIndices(maskIndices)) = 1;
bIndices(maskIndices)=[];

HasMaskDlg=logical(HasMaskDlg);

% end hasmaskdlg
