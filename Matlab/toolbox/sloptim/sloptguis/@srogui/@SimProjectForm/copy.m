function Proj = copy(this)
% Deep copy

%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:44:56 $
%   Copyright 1986-2003 The MathWorks, Inc.
Proj = srogui.SimProjectForm;
Proj.Name = this.Name;
if ~isempty(this.Parameters)
   Proj.Parameters = copy(this.Parameters);
end
Proj.OptimOptions = copy(this.OptimOptions);
Proj.Tests = copy(this.Tests);
Proj.Model = this.Model;
