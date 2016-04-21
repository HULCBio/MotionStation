function S = parseSlInfo_TItarget(S)
% Accept raw Simulink/RTW info stored from TLC hooks, and
% add computed information into S for later use.
% $Revision: 1.1.6.3 $ $Date: 2004/04/08 21:08:11 $
% Copyright 2002-2004 The MathWorks, Inc.

numSys = length(S.sys);

S.modelName = gcs;
if findstr(S.modelName,'/')
    S.modelName = strtok(S.modelName,'/');
end
configSet = getActiveConfigSet(gcs);
S.BoardType = getTargetType_DSPtarget(S.modelName);
S.OrigBoardType = get_param(configSet,'BoardType');
S.solverMode = get_param(configSet,'SolverMode');

% Form STS object names
S.stsObjNames = {};
for k = 1:numSys
    idx = S.sys(k).SystemIdx;
    if S.sys(k).OutputUpdateCombined, 
        S.sys(k).stsObj(1).name = ['stsSys' num2str(idx) '_OutputUpdate'];
        S.stsObjNames{end+1} = ['stsSys' num2str(idx) '_OutputUpdate'];
    else  % separate
        S.sys(k).stsObj(1).name = ['stsSys' num2str(idx) '_Output'];
        S.sys(k).stsObj(2).name = ['stsSys' num2str(idx) '_Update'];
        S.stsObjNames{end+1} = ['stsSys' num2str(idx) '_Output'];
        S.stsObjNames{end+1} = ['stsSys' num2str(idx) '_Update'];
    end
end

% Parse subsystem names 
for k = 1:numSys
    S.sys(k).simName = strrep(getfullname(S.sys(k).name),sprintf('\n'),' ');
end


% EOF  parseSlInfo_TItarget.m
