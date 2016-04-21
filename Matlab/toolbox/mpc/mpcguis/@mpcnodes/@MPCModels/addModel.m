function Boolean = addModel(this, Name, LTImodel, Replace)

%     Boolean = addModel(this, Name, LTImodel, Replace)
%
% Adds the model to the list of MPCModel objects.  
% Name is a string model name.  Name must
% be unique.  If it isn't, and Replace is false (or not specified),
% addModel returns Boolean = 0.  If the model is added, addModel
% returns Boolean = 1.
% LTImodel is an LTI object.
% Set Replace ~= 0 to replace the LTImodel if Name matches an existing model.
%
% "this" is the MPCModels node object.

%  Author:  Larry Ricker
%  Copyright 1986-2003 The MathWorks, Inc. 
%  $Revision: 1.1.8.4 $ $Date: 2003/12/04 01:34:56 $

if nargin < 4 || isempty(Replace)
    Replace = 0;
end    

% Check the list of existing models

for i = 1:length(this.Models)
    if strcmp(this.Models(i).Name,Name)
        if Replace
            this.Models(i).Model = LTImodel;
            this.Models(i).Imported = datestr(now);
            Boolean = 1;
            return
        else
            Boolean = 0;
            return
        end
    end
end

% If we get here, Name is unique, so add the model to the end of
% the list.

Model = mpcnodes.MPCModel(Name,LTImodel);
this.Models = [this.Models; Model];
%this.addNode(Model); % jgo
Model.Imported = datestr(now);
Boolean = 1;
