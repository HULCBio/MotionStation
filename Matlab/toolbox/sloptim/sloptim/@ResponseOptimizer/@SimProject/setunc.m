function setunc(this,uset)
% Sets parameter uncertainty.

%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:46:21 $
%   Copyright 1986-2003 The MathWorks, Inc.
if isequal(uset,[])
   this.Tests = this.Tests(1);
else
   uTest = copy(this.Tests(1));
   uTest.Runs = uset;
   % REVISIT: Temporary measure to ensure edits on the nominal test's
   % constraints are reflected in the uncertainty test.  Ultimately these 
   % could be dissociated (may want different constraints on nominal/uncertain)
   uTest.Specs = this.Tests(1).Specs;
   % Add new test
   this.Tests = [this.Tests(1) ; uTest];
end