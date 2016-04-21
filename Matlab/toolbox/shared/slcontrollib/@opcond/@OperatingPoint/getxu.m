function [x,u,varargout] = getxu(this);
% GETXU Extract states and inputs from operating points
%
%   X = GETXU(OP_POINT) extracts a vector of state values, X, from the 
%   operating point object, OP_POINT. The ordering of states in X is the 
%   same as that used by Simulink. 
%
%   [X,U] = GETXU(OP_POINT) extracts a vector of state values, X, and a 
%   vector of input values, U, from the operating point object, OP. 
%   The ordering of states in X, and inputs in U, is the same as that used 
%   by Simulink. 
%
%   [X,U,XSTRUCT] = GETXU(OP_POINT) extracts a vector of state values, X, 
%   a vector of input values, U, and a structure of state values, XSTRUCT, 
%   from the operating point object, OP_POINT. The structure of state 
%   values, xstruct, has the same format as that returned from a Simulink 
%   simulation. The ordering of states in X and XSTRUCT, and inputs in U, 
%   is the same as that used by Simulink.
%
%   See also OPERPOINT, OPERSPEC.

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:31:07 $

%% Get the states of the system
[sizes, x0, x_str, ts, xts] = feval(this.Model,[],[],[],'sizes'); 

% Initialize the vectors
x = zeros(size(x_str));
u = [];

%% Extract the states from the operating condition object
for ct = 1:length(this.States)
    ind = find(strcmp(this.States(ct).Block,x_str));    
    
    if isa(this.States(ct),'opcond.StatePointSimMech') || ...
             isa(this.States(ct),'opcond.StateSpecSimMech')
        ind = ind(strmatch(this.States(ct).SimMechBlock,this.States(ct).SimMechSystemStates));
    end
    
    x(ind) = this.States(ct).x;
end

%% Create the simulink structure format if requested
if (nargout == 3)
    %% Find the unique state names
    [uniquestates,uind] = unique(x_str);
    uniquexts = xts(uind);

    %% Create the structure
    for ct = length(uniquestates):-1:1
        ind = find(strcmp(uniquestates(ct),x_str));
        if uniquexts(ct) == 0
            xsignal(ct) = struct('values',x(ind),'dimensions',length(ind),...
                'label','CSTATE','blockName',uniquestates(ct));
        else
            xsignal(ct) = struct('values',x(ind),'dimensions',length(ind),...
                'label','DSTATE','blockName',uniquestates(ct));
        end
    end
    if ~isempty(uniquestates)
        varargout{1} = struct('time',[],'signals',xsignal);
    else
        varargout{1} = struct('time',[],'signals',[]);
    end
end
    
%% Extract the input levels handle multivariable case
offset = 0;
for ct = 1:length(this.Inputs)    
    u = [u;this.Inputs(ct).u(:)];
    offset = offset + this.Inputs(ct).PortWidth;
end
