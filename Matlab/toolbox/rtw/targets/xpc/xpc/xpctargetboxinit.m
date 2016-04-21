function xpctargetboxinit

% XPCTARGETBOXINIT - Prepare xPC Target Environment for xPC TargetBox
%
%    XPCTARGETBOXINIT updates the xPC Target environment with settings
%    specific to xPC TargetBox and enables the DOSLoader and StandAlone
%    target boot modes for xPC TargetBox.
%

% Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2004/04/08 21:05:16 $

setxpcenv('CANLibrary','PC104','TcpIpTargetDriver','I82559','TcpIpTargetBusType','PCI');
updatexpcenv('silent');

if ~exist([xpcroot,'\target\kernel\embedded\contents.m'],'file')
    if ~exist([xpcroot,'\target\kernel\embedded\xpcboot.com'],'file')
        copyfile([xpcroot,'\target\kernel\xpcbootb.com'],[xpcroot,'\target\kernel\embedded\xpcboot.com']);
    end
end

