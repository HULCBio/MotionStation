function sys = ss(ModelData)
%SS   Get SS representation of model.
%

%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.2 $  $Date: 2002/04/04 15:20:38 $
sys = ModelData.StateSpace;
if isempty(sys)
   sys = ss(ModelData.Model);
   ModelData.StateSpace = sys;
end
