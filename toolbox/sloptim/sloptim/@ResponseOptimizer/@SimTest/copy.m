function Test = copy(this)
% Deep copy

%   $Revision: 1.1.6.4 $ $Date: 2004/04/11 00:46:25 $
%   Copyright 1986-2003 The MathWorks, Inc.
Test = ResponseOptimizer.SimTest;
Test.Model = this.Model;
Test.Enable = this.Enable;
Test.Optimized = this.Optimized;
Test.Specs = copy(this.Specs);
if ~isempty(this.Runs)
   Test.Runs = copy(this.Runs);
end
if ~isempty(this.SimOptions) % REVISIT: remove this condition when all data files updated
   Test.SimOptions = this.SimOptions;
end
Test.StopTime = this.StopTime;