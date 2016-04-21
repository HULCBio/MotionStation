function Proj = copy(this)
% Deep copy

%   $Revision: 1.1.6.4 $ $Date: 2004/04/11 00:46:08 $
%   Copyright 1986-2003 The MathWorks, Inc.
Proj = ResponseOptimizer.SimProject;
Proj.Name = this.Name;
Proj.Model = this.Model;
if ~isempty(this.Parameters)
   Proj.Parameters = copy(this.Parameters);
end
Proj.Tests = copy(this.Tests);
Proj.OptimOptions = copy(this.OptimOptions);
