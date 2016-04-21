function L = utAugState(L,statenames)
% Metadata management for augstate.

%	P. Gahinet 5-21-96
%	Copyright 1986-2003 The MathWorks, Inc.
%	$Revision: 1.1.6.2 $  $Date: 2004/04/10 23:12:53 $
ns = length(statenames);

% Append "state" group to output groups
CellFlag = isa(L.OutputGroup,'cell');
oGroup = getgroup(L.OutputGroup);
if isfield(oGroup,'states')
   sGroup = struct('states',1:ns);
   oGroup = groupcat(oGroup,sGroup,length(L.OutputName)+(1:ns));
else
   oGroup.states = length(L.OutputName)+(1:ns);
end
L.OutputGroup = setgroup(oGroup,CellFlag);

% Append state names to output names
L.OutputName = [L.OutputName ; statenames];

% Delete notes and userdata
L.Notes = {};
L.UserData = [];