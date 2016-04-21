function dummy = disp_numeric(mm)
% Private. Display numeric-specific properties.
% Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.5.4.1 $  $Date: 2003/11/30 23:09:52 $

fprintf('  Symbol name             : %s\n',mm.name);
fprintf('  Address                 : [ %.0f %1.0f]\n', mm.address(1), mm.address(2) );

if strcmp(class(mm),'ccs.numeric')
fprintf('  Data type               : %s\n', p_getdatatype(mm) );
end

%[EOF] disp_numeric.m