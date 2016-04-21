function S = regSysInfo_TItarget(S,systemInfo);
% $Revision: 1.1.6.2 $ $Date: 2004/04/08 21:08:13 $
% Copyright 2002-2003 The MathWorks, Inc.

if isempty(S) | ~isfield(S,'sys')
    S.sys = [];
end

% Get system name
name = '';
k = 1;
while k <= length(systemInfo)-1
    prop = systemInfo{k};
    val = systemInfo{k+1};
    if strcmp(prop,'Name'),
        name = val;
        break;
    end
    k = k+2;
end
if isempty(name),
    disp('Error:  System name not specified for regSysInfo_TItarget.m')
end

% Find this system in the list we registered thus far
idx = -1;
for i = 1:length(S.sys),
    if strcmp(S.sys(i).name, name)
        idx = i;
    end
end
if idx==-1,
    idx = length(S.sys)+1;
end

% Write properties into structure
k = 1;
while k <= length(systemInfo)-1
    prop = systemInfo{k};
    val = systemInfo{k+1};
    switch prop
        case 'Name'
            S.sys(idx).name = val;
        case 'Idx'
            S.sys(idx).SystemIdx = str2num(val);
        case 'OutputUpdateCombined'
            S.sys(idx).OutputUpdateCombined = str2num(val);
        case 'FundamentalStepSize'
            S.FundamentalStepSize = str2num(val);
        case 'IsSingleRate'
            S.isSingleRate = strcmp(val,'yes');
        case 'IsMultiTasking'
            S.isMultiTasking = strcmp(val,'1');
        case 'NumSampleTimes'
            S.NumSampleTimes = str2num(val);
    end
    k = k+2;
end  % while


% EOF  regSysInfo_TItarget.m
