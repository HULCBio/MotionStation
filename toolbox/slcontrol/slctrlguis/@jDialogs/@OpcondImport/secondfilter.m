function tf = secondfilter(this,var)
% SECONDFILTER 
% Checks if given variable should be included in the import browser
% The valid variables are:
%       opcond.OperatingPoint variables that have matching models.
%       vectors that match the number of states in the project.
%       Simulink state structures.

%   Author(s): John Glass
%   Copyright 1986-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $ $Date: 2004/02/06 00:37:16 $

if isa(var,'opcond.OperatingPoint') && strcmp(this.Task.model,var.model)
    tf = true;
elseif isa(var,'double')
    tf = true;
elseif isa(var,'struct') && isfield(var,'time') && isfield(var,'signals') 
    tf = true;
else
    tf = false;
end
