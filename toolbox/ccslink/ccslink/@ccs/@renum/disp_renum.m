function dummy = disp_renum(mm)
% Private. Dispaly enum-specific properties.
% Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.3.2.1 $  $Date: 2003/11/30 23:10:59 $

fprintf('  Labels & values          : ');
for i=1:length(mm.label)-1
fprintf('%s=%d, ',mm.label{i},mm.value(i));
end
fprintf('%s=%d',mm.label{end},mm.value(end));
fprintf('\n');

%[EOF] disp_renum.m