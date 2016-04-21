function this = TestPoint(vars,links)
%TESTPOINT  Constructs instance of @TestPoint class.
%
%   T = HDS.TESTPOINT(VARS) constructs a new testpoint dataset  
%   with variables VARS.  VARS is either a cell array of variable 
%   names, or a vectors of @variable handles.

%   Author(s): P. Gahinet
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:28:51 $

% Create instance
this = hds.TestPoint;
this.Grid_ = struct('Length',1,'Variable',[]);

% Convert variables to @variable instances
if isa(vars,'char')
   V = hds.variable(vars);
elseif isa(vars,'cell')
   V = handle(zeros(size(vars)));
   for ct=1:length(vars)
      V(ct) = hds.variable(vars{ct});
   end
else
   V = vars;
end
for ct=1:length(V)
   this.addvar(V(ct));
end