function Test = copy(this)
% Deep copy

%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:45:10 $
%   Copyright 1986-2003 The MathWorks, Inc.
if isscalar(this)
   Test = srogui.SimTestForm;
   Test.Enable = this.Enable;
   Test.Optimized = this.Optimized;
   Test.Specs = copy(this.Specs);
   if ~isempty(this.Runs)
      Test.Runs = copy(this.Runs);
   end
   % Simulink-specific
   Test.Model = this.Model;
   if ~isempty(this.SimOptions) % REVISIT: remove this condition when all data files updated
      Test.SimOptions = copy(this.SimOptions);
   end
else
   for ct=length(this):-1:1
      Test(ct,1) = copy(this(ct));
   end
end