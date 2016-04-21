function mdlStruct=loopmodel(c,mdlStruct)
%LOOPMODEL loop over models
%   MDLSTRUCT=LOOPMODEL(C,MDLSTRUCT)
%   MDLSTRUCT is a structure with the following fields
%    .isActive
%    .MdlName
%    .MdlCurrSys
%    .SysLoopType
%    .isMask
%    .isLibrary
% 

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:22:41 $

trgm='temp_rptgen_model';

i=1;
while i<=length(mdlStruct)
    switch mdlStruct(i).MdlName
    case '$current'
        newName=bdroot(gcs);
        if isempty(newName)
            mdlStruct=mdlStruct([1:i-1,i+1:end]);
        elseif strcmp(newName,trgm) | LocIsLibrary(newName)
            newName=LocAllModels({trgm});
            if ~isempty(newName)
                mdlStruct(i).MdlName=newName{1};
                i=i+1;
            else
                mdlStruct=mdlStruct([1:i-1,i+1:end]);
            end
        else
            mdlStruct(i).MdlName=newName;
            i=i+1;
        end      
    case '$all'
        newName=LocAllModels({trgm});
        if isempty(newName)
            mdlStruct=mdlStruct([1:i-1,i+1:end]);
        else
            newEntry=struct('isActive',{mdlStruct(i).isActive},...
                'MdlName',newName,...
                'MdlCurrSys',{mdlStruct(i).MdlCurrSys},...
                'SysLoopType',{mdlStruct(i).SysLoopType},...
                'isMask',{mdlStruct(i).isMask},...
                'isLibrary',{mdlStruct(i).isLibrary} ); 
            mdlStruct=[mdlStruct(1:i-1),...
                    newEntry,...
                    mdlStruct(i+1:end)];
            i=i+length(newEntry);
        end
    otherwise
        %a custom model name - check for %<varname> notation
        if (strncmp(mdlStruct(i).MdlName,'%<',2) & mdlStruct(i).MdlName(end)=='>')
            try
                mdlStruct(i).MdlName=evalin('base',mdlStruct(i).MdlName(3:end-1));
            catch
                mdlStruct(i).MdlName=mdlStruct(i).MdlName(3:end-1);
            end
        end
        
        %try
        %   open_system(mdlStruct(i).MdlName);
        %   ok=logical(1);
        %catch
        %   ok=logical(0);
        %end
        %if ok
        i=i+1;
        %else
        %   mdlStruct=mdlStruct([1:i-1,i+1:end]);         
        %end
    end   
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tf=LocIsLibrary(newName)

tf=logical(0);

try
    tf=strcmp(get_param(newName,'blockdiagramtype'),'library');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function allGoodModels=LocAllModels(badList);

allModels=find_system('SearchDepth',0,...
    'type','block_diagram',...
    'blockdiagramtype','model');
allGoodModels=setdiff(allModels,badList);
