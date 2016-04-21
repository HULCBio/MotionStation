function getmatfilevars(this)
% getmatfilevars Generates the variable list from .mat file 
% 

%   Author(s): Craig Buhr, John Glass
%   Copyright 1986-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $ $Date: 2004/03/24 20:51:43 $

awtinvoke(this.Handles.FileEdit,'setEnabled',true);
awtinvoke(this.Handles.BrowseButton,'setEnabled',true);

PathName = this.LastPath;
FileName = this.FileName;

if ~isempty(FileName)
    try
        Vars = feval('whos','-file',fullfile(PathName, FileName));
        [VarNames, DataModels] = getmodels(this,Vars,'file');
       
    catch
        errordlg(lasterr,'Import Error','modal')
        VarNames = {};
        DataModels = {};
    end
else
    VarNames = {};
    DataModels = {};
end

this.updatetable(VarNames,DataModels);
