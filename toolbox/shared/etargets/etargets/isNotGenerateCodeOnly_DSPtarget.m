function bool = isNotGenerateCodeOnly_DSPtarget(args),

% $RCSfile: isNotGenerateCodeOnly_DSPtarget.m,v $
% $Revision: 1.1.6.2 $ $Date: 2004/04/08 21:08:06 $
% Copyright 2001-2003 The MathWorks, Inc.

bool = isempty(findstr(args,'BUILD_ACTION="Generate_code_only"'));

% [EOF] isNotGenerateCodeOnly_DSPtarget.m
