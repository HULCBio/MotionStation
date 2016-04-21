function dummy = disp_bitfield(mm)
% Private. Dispaly bitfield-specific properties.
% Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.3.4.1 $  $Date: 2003/11/30 23:06:29 $

fprintf('  Length (bits)           : %d\n',mm.length);
fprintf('  Offset (bits)           : %d\n',mm.offset);

%[EOF] disp_bitfield.m