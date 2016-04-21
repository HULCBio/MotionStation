function L = augstate(L,statenames)
%AUGSTATE   LTI property management for AUGSTATE.
%
%   SYS.LTI = AUGSTATE(SYS.LTI,STATENAMES)  sets the 
%   LTI properties of SYS = AUGSTATE(SYS)
%
%   See also SS/AUGSTATE

%	P. Gahinet 5-21-96
%	Copyright 1986-2002 The MathWorks, Inc. 
%	$Revision: 1.15 $  $Date: 2002/04/10 05:52:12 $

if ~strcmp(class(L),'lti')
   error('AUGSTATE is applicable only to state-space models.');
end

ns = length(statenames);

% Append "state" group to output groups
StateGroup = {1:ns , 'states'};
L.OutputGroup = groupcat(L.OutputGroup,StateGroup,...
                              length(L.OutputName)+(1:ns));

% Append state names to output names
L.OutputName = [L.OutputName ; statenames];

% Delete notes and userdata
L.Notes = {};
L.UserData = [];

% Delay time
L.ioDelay = ndops('vcat',L.ioDelay,zeros(ns,size(L.ioDelay,2)));
L.OutputDelay = ndops('vcat',L.OutputDelay,zeros(ns,1));
