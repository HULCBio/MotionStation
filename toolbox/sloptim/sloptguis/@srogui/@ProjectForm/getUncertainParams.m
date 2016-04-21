function UPars  = getUncertainParams(this)
% Collects names of all uncertain parameters

% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.4.1 $ $Date: 2004/04/11 00:44:15 $
UPars = cell(0,1);
for ct=1:length(this.Tests)
   t = this.Tests(ct);
   if ~isempty(t.Runs)
      UPars = [UPars ; {t.Runs.Parameters.Name}'];
   end
end
