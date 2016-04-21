function op = setxu(this,x,varargin);
%SETXU Set states and inputs in operating points.
%
%   OP_NEW=SETXU(OP_POINT,X,U) sets the states and inputs in the operating 
%   point, OP_POINT, with the values in X and U. A new operating point 
%   containing these values, OP_NEW, is returned. The variable X can be a 
%   vector or a structure with the same format as those returned from a 
%   Simulink simulation. The variable U can be a vector. Both X and U can 
%   be extracted from another operating point object with the getxu function.
% 
%   See also GETXU, OPERPOINT.

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:31:09 $

%% Create a copy of the object being passed into the method
op = this;

%% Extract the states from the operating condition object
if isa(x,'struct')
    %% First make sure that this is a Simulink struct
    try
        xsignals = x.signals;
    catch
        error('slcontrol:setxu_InvalidSimulinkStateStruct',['The Simulink',... 
               'structure is not valid'])
    end
    states = this.States;
    %% Get the state names to match up with in the struct
    statenames = get(states,'Block');
    %% Loop over each element in the structure
    for ct = 1:length(xsignals)
        ind = find(strcmp(xsignals(ct).blockName,statenames));
        if isempty(ind)
            str = ['The state: \n %s \n contained',...
                ' in the input structure was not found in the operating',...
                ' specification/point object.'];
            warning('slcontrol:setxu_InvalidSimulinkState',sprintf(str,xsignals(ct).blockName))
        else
            for ct2 = 1:length(ind)
                if isa(states(ind(ct2)),'opcond.StatePointSimMech') || ...
                                isa(states(ind(ct2)),'opcond.StateSpecSimMech') 
                    %% Find the SimMech state references if needed.  This will be a subset
                    %% of all the states in the SimMechanics machine.
                    ind_xstr = strmatch([states(ind(ct2)).SimMechBlock,':'],...
                                                states(ind(ct2)).SimMechSystemStates);
                    states(ind(ct2)).x = xsignals(ct).values(ind_xstr);                        
                else
                    states(ind(ct2)).x = xsignals(ct).values;
                end
            end
        end
    end
    op.States = states;
else
    %% Get the states of the system
    [sizes, x0, x_str, pp, qq] = feval(this.Model,[],[],[],'sizes');
    states = op.States;
    for ct = 1:length(this.States)
        %% Find the state indicies
        ind = find(strcmp(x_str,states(ct).Block));
        %% Find the SimMech state references if needed.  This will be a subset
        %% of all the states in the SimMechanics machine.
        if isa(states(ct),'opcond.StatePointSimMech') || isa(states(ct),'opcond.StateSpecSimMech') 
            ind = ind(strmatch([states(ct).SimMechBlock,':'],states(ct).SimMechSystemStates));
        end
        state = states(ct);
        %% Set the properties
        state.Nx = length(ind);
        state.x  = x(ind);
        states(ct) = state;
    end
    op.States = states;
end

if nargin == 3
    u = varargin{1};
    %% Extract the input levels
    offset = 0;
    inputs = op.Inputs;
    for ct = 1:length(this.Inputs)
        input = inputs(ct);
        input.u = u(offset+1:offset+this.Inputs(ct).PortWidth);
        inputs(ct) = input;
        offset = offset + this.Inputs(ct).PortWidth;
    end
    op.Inputs = inputs;
end
