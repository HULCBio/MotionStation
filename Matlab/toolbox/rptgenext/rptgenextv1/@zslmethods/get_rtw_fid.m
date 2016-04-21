function fid=get_rtw_fid(z,mdlName)
%GET_RTW_FID returns a file ID to a model's RTW file
%   get_rtw_fid returns -1 if the file could not be loaded
%   It is the responsibility of the user to close the FID after using it.

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:22:31 $


z=zslmethods;

fid=-1;
if ~strcmp(get_param(0,'RtwLicensed'),'on')
    return;
end

compiledModels = subsref(z,substruct('.','RtwCompiledModels'));
if ~any(strcmp(compiledModels,mdlName))
    try
        rtwbuild(mdlName);
        ok = 1;
    catch
        ok = 0;
    end

    %Even if the rtwgen does not happen properly, we add the name to the
    %list to prevent repeated rtwgens.
    compiledModels{end+1}=mdlName;
    subsasgn(z,substruct('.','RtwCompiledModels'),compiledModels);
    
    if ~ok
        return;
    end
end

fid = fopen([mdlName '.rtw']);
