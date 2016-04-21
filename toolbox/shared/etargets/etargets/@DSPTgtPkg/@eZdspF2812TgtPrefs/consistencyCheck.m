function errormsg = consistencyCheck (h)

% $RCSfile: consistencyCheck.m,v $
% $Revision: 1.1.6.2 $ 
% $Date: 2004/04/08 21:07:25 $
% Copyright 2003-2004 The MathWorks, Inc.



% make sure that "DSPChipLabel" matches this target
if ( ~strcmp (lower(h.DSPBoard.DSPChip.DSPchipLabel),'ti tms320c2812'))
    error ('Target Preference block property ''DSPChipLabel'' has illegal value. Restore the original value ''TI TMS320C2812''.');
end

% EOF consistencyCheck.m
