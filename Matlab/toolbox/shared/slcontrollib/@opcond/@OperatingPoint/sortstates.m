function sortstates(this,statecell)
% SORTSTATES Sorts the states of an operating point object given a cell
% array of state names.
%
% SORTSTATES(OP,STATECELL) sorts the states of the operating point OP
% object.

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2004/03/24 21:06:26 $

%% Sort the states first get the states in the operating point
OpStates = cell(length(this.States),1);
for ct2 = 1:length(this.States)
    if isa(this.States(ct2),'opcond.StatePointSimMech')
        OpStates{ct2} = this.States(ct2).SimMechBlock;
    else
        OpStates{ct2} = this.States(ct2).Block;
    end
end

ind = [];
indState = [1:length(statecell)]';

%% Loop over the state objects
for ct2 = 1:length(statecell)
    stateind = find(strcmp(statecell(ct2),OpStates));
    indState(stateind) = 0;
    ind = [ind;stateind];
end

%% Sort the operating point states
this.States = this.States(ind);