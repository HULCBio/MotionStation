function S = smnode25x0(X)
% SMNODE25X0  SBS2510/SBS2500 Node definition object
%  OBJ=SMNODE25X0 - Creates a Node object that is used in conjunction
%   with the 'SBS25x0 Init' block to define the operating mode of the xPC
%   Target which contains SBS 25x0 Broadcast memory
%  OBJ=SMNODE25X0(STR) - Same as above, except it accepts a structure STR
%   that defines properties of the resulting OBJ.  
%  
% See also SMPART25X0

%   Copyright 2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2004/01/22 18:34:54 $
default.TargetAbortEnable = 'off';
default.LoopbackEnable = 'off';  
default.Node2Node = 'off';    % On enables point to point (no Hub)
default.RXEnable = 'on';
default.TXEnable = 'on';
default.MemorySize = '256kByte';
default.WITEnable = 'off';
%default.Mode.ERR?
default.IRQ_ErrorEnable = 'off';
default.IRQ_WITEnable= 'off';
default.Partition = [];

default.SlotID = 'any';  % 'any' or 0 to 31  to force a slot check (fails of slot does not match!)
S = class(default,'smnodesbs25x0');
if nargin >= 1  && ~isempty(X),
    S = set(S,X);
end


