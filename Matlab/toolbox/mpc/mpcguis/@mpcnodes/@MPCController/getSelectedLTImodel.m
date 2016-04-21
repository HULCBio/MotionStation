function LTImodel = getSelectedLTImodel(this)

% Returns the LTI model selected in the MPCController model combo
% box.

%	Copyright 1986-2003 The MathWorks, Inc. 
%	$Revision: 1.1.8.2 $  $Date: 2003/10/15 18:48:11 $
%   Author:  Larry Ricker

ModelName = this.ModelName;
if isempty(ModelName)
    errordlg(sprintf(['Unexpected problem:  no model name', ...
            ' stored in controller "%s".'],this.Label));
    LTImodel = [];
    return
end
LTImodel = this.getMPCModels.getLTImodel(ModelName);
