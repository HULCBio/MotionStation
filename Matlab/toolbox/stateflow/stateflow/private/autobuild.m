function status = autobuild(machineId,targetName,buildType,rebuildAllFlag,showNags,chartId)
% TEMPORARY BRIDGE: call autobuild_driver instead
% STATUS = AUTOBUILD( MACHINENAMEORID,
%                     TARGETNAME,
%                     BUILDTYPE={'parse','code','make','build'},
%                     REBUILDALLFLAG={'yes','no'}, %% relevant only if BUILDTYPE is 'code' or 'build'
%                     SHOWNAGS={'yes','no'})
%                     CHARTID (relevant only if buildtype is parse and you want to parse single chart)
%
%

%   Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.73.4.11 $  $Date: 2004/04/15 00:55:59 $




status = 0;

[machineId,machineName] = unpack_machine_id(machineId);

if (nargin<3),   buildType 	    = 'build'; end;
if (nargin<4),   rebuildAllFlag = 0;       end;
if (nargin<5),   showNags       = 'yes';   end;
if (nargin<6),   chartId        = [];   end;

if(ischar(rebuildAllFlag))
    rebuildAllFlag = strcmp(rebuildAllFlag,'yes');
end

switch(buildType)
    case 'parse'
        autobuild_driver('build',machineId,targetName,showNags);
    case {'code','build'}
        if(~rebuildAllFlag)
            autobuild_driver('build',machineId,targetName,showNags);
        else
            autobuild_driver('rebuildall',machineId,targetName,showNags);
        end
    case 'make'
        autobuild_driver('make',machineId,targetName,showNags);
end

        