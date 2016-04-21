function isc=iscontinuous(sys,discRules)
%ISCONTINUOUS decides if a system or block is discretizable
%      ISC = ISCONTINUOUS(SYS,DISCRULES) returns a logical value.
%      SYS - full path name of model or block. It has to be opened first.
%

% $Revision: 1.4 $ $Date: 2002/04/10 18:56:55 $
% Copyright 1990-2002 The MathWorks, Inc.

member = find_system(sys);
k = 1;
if isempty(findstr(member{1},'/'))
    k = 2;
end
isc=0;

model = bdroot(sys);
disc_configurable_lib = 'none';
try
    disc_configurable_lib = get_param(model,'disc_configurable_lib');
catch
    disc_configurable_lib = 'none';
end

for j = k:length(member),            
    [isDiscretizable, discfcn] = chkrules(member{j},discRules);
    isconf = isconfigurable(disc_configurable_lib,member{j});
    if isconf | isDiscretizable
        isc = 1;
        break;
    end
end  
%end function IsContinuous

%[EOF] IsContinuous.m