function HasMaskIcon=hasmaskicon(SysHandles)
%HASMASKICON Check for existence of mask icon.
%   VALUE=HASMASKICON(SYS) returns 0 if the block does not have a
%   mask icon and 1 if the block has a mask icon. 
%  
%   Sys may either be the full pathname to the block, the handle of 
%   the block, a cell array of full pathnames or a vector of handles.
%
%   See also GET_PARAM, HASMASK, HASMASKDLG, LOOKUNDERMASK.

%   Loren Dean
%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.12 $

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
HasMaskIcon=zeros(size(SysHandles));

%
% find all blocks that have masks off and remove them from the remaining
% set of possibles
%
bIndices=find(strcmp(get_param(SysHandles,'Type'),'block'));
maskIndices=find(strcmp(get_param(SysHandles(bIndices),'Mask'),'off'));
bIndices(maskIndices)=[];

%
% find all the blocks that have empty MaskDisplay and remove them from the
% list
%
maskIndices=find(strcmp(get_param(SysHandles(bIndices),'MaskDisplay'),''));
bIndices(maskIndices)=[];

%
% what remains has a mask icon, mark them with a 1
%
HasMaskIcon(bIndices) = 1;

HasMaskIcon=logical(HasMaskIcon);

% end hasmaskicon