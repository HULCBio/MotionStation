function out = fixpt_mask_disp_prep(in);
% FIXPT_MASK_DISP_DATA is a helper function used by the Fixed Point Blocks.

% Copyright 1994-2002 The MathWorks, Inc.
% $Revision: 1.6 $  
% $Date: 2002/04/10 18:58:57 $

maxdim = 4;

if ~isempty(in)
    if isnumeric(in)
        [nrow,ncol]=size(in);
        if nrow > maxdim | ncol > maxdim
            out = sprintf('[%dx%d]',nrow,ncol);
        else
            out = double(in);
        end
    else
        out = in;
    end
else
    out = '';
end