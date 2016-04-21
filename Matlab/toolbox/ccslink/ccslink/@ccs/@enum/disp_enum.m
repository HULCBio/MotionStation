function dummy = disp_enum(mm)
% Private. Dispaly enum-specific properties.
% Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.3.4.1 $  $Date: 2003/11/30 23:07:59 $

fprintf('  Labels & values         : ');
for i=1:length(mm.label)-1
fprintf('%s=%d, ',mm.label{i},mm.value(i));
end
if ~isempty(mm.label)
fprintf('%s=%d',mm.label{end},mm.value(end));
end
fprintf('\n');

%[EOF] disp_enum.m