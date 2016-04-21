function setDirty(this)
% SETDIRTY(this) Set this node's project dirty flag

%   Author(s): John Glass
%   Copyright 1986-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $ $Date: 2004/04/04 03:40:45 $

project = this.getRoot.up;

if ~isempty(project)
    project.Dirty = 1;
end