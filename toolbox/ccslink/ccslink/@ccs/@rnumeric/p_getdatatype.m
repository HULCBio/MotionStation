function dtype = p_getdatatype(mm)
% P_GETDATATYPE (Private)

% Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.4.6.2 $  $Date: 2003/11/30 23:11:39 $

if strcmp(mm.procsubfamily,'C6x')
    dtype = p_c6xx_nativetypes(mm);
elseif strcmp(mm.procsubfamily,'C54x')
    dtype = p_c54x_nativetypes(mm);
elseif strcmp(mm.procsubfamily,'C55x')
    dtype = p_c55x_nativetypes(mm);
elseif strcmp(mm.procsubfamily,'C28x')
    dtype = p_c28x_nativetypes(mm);
elseif any(strcmp(mm.procsubfamily,{'R1x','R2x'}))
    dtype = p_Rxx_nativetypes(mm);
end

% [EOF] p_getdatatype.m