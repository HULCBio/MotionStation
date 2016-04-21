function settype(h,Type)
%SETTYPE  Sets constraint type

%   Authors: P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $ $Date: 2002/04/10 05:09:25 $

% Create constraint of specified type
NewConstr = h.Client.newconstr(Type,h.Constraint);

% Update constraint (will trigger update of param. editor groupbox)
if ~isequal(NewConstr,h.Constraint)
	delete(h.Constraint)
end
h.Constraint = NewConstr;   % always triggers listener
% RE: necessary for @pzdamping since both Damping and Overshoot are the same constraint
