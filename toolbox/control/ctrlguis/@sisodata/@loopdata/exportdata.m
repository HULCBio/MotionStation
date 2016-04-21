function ExportData = exportdata(LoopData,ModelList)
%EXPORTDATA   Export SISO Tool models back to workspace.
%
%   See also SISOTOOL.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.13 $  $Date: 2002/04/10 04:52:55 $

% Grab models
ExportData = looptransfers(LoopData,ModelList);

% Convert SISO models to ZPK
for ct=1:length(ModelList)
    if ~isa(ExportData{ct},'zpk') & issiso(ExportData{ct})
        ExportData{ct} = zpk(ExportData{ct});
    end
end
