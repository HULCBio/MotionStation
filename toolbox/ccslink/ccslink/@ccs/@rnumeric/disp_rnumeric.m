function dummy = disp_rnumeric(mm)
% Private. Display rnumeric-specific properties.
% Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.7.4.1 $  $Date: 2003/11/30 23:11:30 $

fprintf('  Symbol name              : %s\n',mm.name);

fprintf('  Register                 : %s', mm.regname{1});
if mm.wordsize>mm.bitsperstorageunit 
fprintf(', %s\n', mm.regname{2});
else
fprintf('\n');
end

if strcmp(class(mm),'ccs.rnumeric')
fprintf('  Data type                : %s\n', p_getdatatype(mm) );
end

%[EOF] disp_rnumeric.m