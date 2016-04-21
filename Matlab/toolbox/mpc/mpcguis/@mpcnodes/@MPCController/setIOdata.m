function setIOdata(this, Root)

%  SETIODATA  Saves input/output properties needed to construct the MPC
%  object.  This makes the MPCControllers node independent of the root
%  MPCGUI node.

%  Author:   Larry Ricker
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/10 23:35:53 $

if isa(Root, 'mpcnodes.MPCGUI')
    this.IOdata = struct('InData', {Root.InData}, ...
        'OutData', {Root.OutData}, ...
        'iMV', {Root.iMV}, 'iMD', {Root.iMD}, 'iUD', {Root.iUD}, ...
        'iMO', {Root.iMO}, 'iUO', {Root.iUO});
    this.Frame = Root.Frame;
end
