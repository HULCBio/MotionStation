function mech_OpenVrWorld(DestSubsys,VrLibModelName,OpenOrNot)
% This function will load the vrworld given the SimMechamics Model name and
% the VR model Lib name. Use this as a callback on one of the subsystems
% that is used to open the VR world. 
% 
% If you pass a 1 to OpenOrNot then the function will open the world as
% well else it will just copy the required subsystem. The default is 1.

%   Copyright 1998-2004 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $  $Date: 2004/01/16 20:07:04 $


if ~exist('vrlib','file')
  errordlg('Virtual Reality Toolbox not installed.','Virtual Reality Toolbox','modal');
  return;
end

if nargin < 3,
    OpenOrNot = 1;
end

Dest_Name = gcb;
VRDestBlkName = 'VRAnimation';
load_system(VrLibModelName);

% Find the VR sink block and extract the VRML file name
h=find_system(VrLibModelName,'FindAll','on','type','block','MaskType','Virtual Reality Sink');
VRSinkName = get_param(h,'Name');

% Copy this subsystem to the main nodel
% Update diagram to force loading the VR World
SubsystemToCopy = get_param(h,'Parent');
BlksInDest = find_system(Dest_Name,'type','block','Name',VRDestBlkName);
if isempty(BlksInDest),
    add_block(SubsystemToCopy,[Dest_Name '/' VRDestBlkName]);
    set_param(bdroot(Dest_Name), 'SimulationCommand', 'update');
end

if OpenOrNot == 1,    
    % Open the world
    open_system([Dest_Name '/' VRDestBlkName '/' VRSinkName]);
end
%-----------------------------------------------------------------------