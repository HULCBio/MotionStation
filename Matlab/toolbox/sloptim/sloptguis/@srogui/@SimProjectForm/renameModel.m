function renameModel(this,Model)
% Modifies name of associated Simulink model (used, e.g.,
% to cope with model renames).

%   $Revision $ $Date: 2004/04/11 00:45:05 $
%   Copyright 1986-2004 The MathWorks, Inc.
if strcmp(this.Name,this.Model)
   this.Name = Model;
end
this.Model = Model;
for ct=1:length(this.Tests)
   this.Tests(ct).Model = Model;
end
