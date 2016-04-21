function retvalue = mem_callback(action)
% MEM_CALLBACK Mask Helper Function for the memory blocks.
%
% $RCSfile: mem_callback.m,v $
% $Revision: 1.1.6.1 $ $Date: 2004/04/01 16:17:41 $
% Copyright 2001-2004 The MathWorks, Inc.

if nargin==0, action = 'dynamic'; end
blk = gcbh;

retvalue = 1;

switch action
case 'dynamic'

    mask_visibility_orig  = get_param(blk,'MaskVisibilities');
    mask_visibility       = mask_visibility_orig;
    useInitValue          = get_param(blk,'useInitValue');
    useTermValue          = get_param(blk,'useTermValue');
    InitValueEditBoxIndex = 4;
    TermValueEditBoxIndex = 6;

    if (strcmp(useInitValue,'on'))
        mask_visibility{InitValueEditBoxIndex} = 'on';
    else
        mask_visibility{InitValueEditBoxIndex} = 'off';
    end

    if (strcmp(useTermValue,'on'))
        mask_visibility{TermValueEditBoxIndex} = 'on';
    else
        mask_visibility{TermValueEditBoxIndex} = 'off';
    end

    if ~isequal(mask_visibility, mask_visibility_orig),
        set_param(blk,'MaskVisibilities',mask_visibility);
    end

otherwise

end

% [EOF]
