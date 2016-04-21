function List = getMPCprojectList

% List = getMPCprojectList
%
% Utility function returns a cell array of strings.  Each entry is the
% name of a project currently loaded in the MPC GUI.

%	Author:  Larry Ricker
%	Copyright 1986-2003 The MathWorks, Inc. 
%	$Revision: 1.1.6.1 $  $Date: 2003/12/04 01:35:53 $

% Workspace and tree manager handles.  Should have been created previously.
global MPC_WSh MPC_MANh

List = {};
if ~isempty(MPC_WSh)
    Projects = MPC_WSh.getChildren;
    N = length(Projects);
    List = cell(N, 1); 
    for i = 1:N
        List{i} = Projects(i).Label;
    end
end