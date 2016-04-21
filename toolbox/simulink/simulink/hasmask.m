function HasMask=hasmask(SysHandles)
%HASMASK Check for existence of mask.
%   VALUE=HASMASK(SYS) returns 0 if the block is not masked,
%   1 if the block has a graphical mask, or 2 if the block has a functional
%   mask. A graphical mask means that no additional workspace exists inside
%   the mask.  It usually indicates that the block or system has only an
%   icon on it.  A functional mask means that a separate workspace
%   exists under the mask.  It usually indicates that a dialog will
%   appear when the mask is double clicked on.
%
%   SYS may either be the full pathname to the block, the handle of
%   the block, a cell array of full pathnames or a vector of handles.
%
%   See also GET_PARAM, HASMASKDLG, HASMASKICON, LOOKUNDERMASK.

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
HasMask=zeros(size(SysHandles));

%
% find all blocks that have masks and set their hasmask result to 1
%
bIndices=find(strcmp(get_param(SysHandles,'Type'),'block'));
maskIndices=find(strcmp(get_param(SysHandles(bIndices),'Mask'),'off'));
bIndices(maskIndices)=[];

HasMask(bIndices) = 1;


%
% find all the blocks that have nonempty MaskVariables and nonempty
% MaskInitializations and set their hasmask to 2
%
maskIndices=find(~strcmp(get_param(SysHandles(bIndices),'MaskVariables'),''));
HasMask(bIndices(maskIndices))=2;
bIndices(maskIndices)=[];
maskIndices=find(~strcmp(get_param(SysHandles(bIndices),'MaskInitialization'),''));
HasMask(bIndices(maskIndices))=2;

% end hasmask
