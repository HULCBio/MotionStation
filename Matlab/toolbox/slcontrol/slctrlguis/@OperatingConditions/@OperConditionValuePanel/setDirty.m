function setDirty(this)
% SETDIRTY(this) Set this node's project dirty flag

%   Author(s): John Glass
%   Copyright 1986-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $ $Date: 2004/02/06 00:36:39 $

this.getRoot.up.Dirty = 1;
