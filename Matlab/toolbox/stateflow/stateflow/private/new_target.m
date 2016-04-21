function newTarget = new_target(parentId,newTargetName),
%NEW_TARGET(parentId)

%   Jay R. Torgerson
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.18.2.4 $  $Date: 2004/04/15 00:58:52 $

allTargets = sf('TargetsOf', parentId);
if(nargin<2)
   TARGET = sf('get','default','target.isa');
   newTargetName = unique_name_for_list(allTargets, TARGET);
end
newTarget = sf('new','target'...
   ,'.name',newTargetName...
   ,'.linkNode.parent',parentId...
   );
if(strcmp(newTargetName,'rtw'))
% dboissy says:
% Do not populate the RTW target based on the sfun target.  During model load
% we copy the RTW target settings to the configset.  If we keep setting the RTW
% target settings, we will append to the configset multiple times.
%
%    %tis an RTW target. Copy useful stuff from it.
%   sfunTarget = sf('find',allTargets,'target.name','sfun');
%   sf('set',newTarget...
%           ,'target.customCode',sf('get',sfunTarget,'target.customCode')...
%           ,'target.reservedNames',sf('get',sfunTarget,'target.reservedNames')...
%           ,'target.customInitializer',sf('get',sfunTarget,'target.customInitializer')...
%           ,'target.customTerminator',sf('get',sfunTarget,'target.customTerminator')...
%           ,'target.userSources',sf('get',sfunTarget,'target.userSources')...
%           ,'target.userIncludeDirs',sf('get',sfunTarget,'target.userIncludeDirs')...
%           );
else
    targetFile = find_target_files(newTargetName);
    if ~isempty(targetFile)
        sf('set',newTarget,'target.targetFunction',targetFile.fcn);
    end
end

target_methods('initialize',newTarget);
