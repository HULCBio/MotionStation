function xpcinit(arg)

% XPCINIT - xPC Target Environment Helper Function

% Copyright 1996-2004 The MathWorks, Inc.
% $Revision: 1.15.6.3 $ $Date: 2004/04/08 21:04:22 $

if nargin==0
toolboxversion=ver('xpc');
setup_version=toolboxversion.Version;

% check if environment mat file exists
if exist(xpcenvdata,'file')

  % load environment file
  load(xpcenvdata);
  % check if the environment information is for the current version
  if strcmp(actpropval{1},setup_version)
    actpropval=check_embedded(actpropval);
    save(xpcenvdata,'propname','actpropval','newpropval');
    return;   % nothing to do
  end

end

% build default environment
[propname,actpropval]=create_default;
actpropval{1}=setup_version;
actpropval{2}=xpcroot;
newpropval=cell(1,length(actpropval));
actpropval=check_embedded(actpropval);
save(xpcenvdata,'propname','actpropval','newpropval');

return;

end

if ~strcmp(arg,'reinit')
  error('invalid argument passed to xpcinit');
end

if ~exist(xpcenvdata,'file')
  xpcinit;
end

load(xpcenvdata);

clear mex;

delete(xpcenvdata);
xpcinit;
updatexpcenv;


function actpropval=check_embedded(actpropval)

if exist([xpcroot,'\target\kernel\embedded\xpcboot.com'],'file')
  actpropval{22}='Enabled';
else
  actpropval{22}='Disabled';
end

function [propname,propval]=create_default;

i=1;
propname{i}='Version';i=i+1;                                    % 1
propname{i}='Path';i=i+1;                                       % 2
propname{i}='CCompiler';i=i+1;                                  % 3
propname{i}='CompilerPath';i=i+1;                               % 4
propname{i}='VCCompilerPath1';i=i+1;                            % 5
propname{i}='VCCompilerPath2';i=i+1;                            % 6
propname{i}='TargetRAMSizeMB';i=i+1;                            % 7
propname{i}='MaxModelSize';i=i+1;                               % 8
propname{i}='SystemFontSize';i=i+1;                             % 9
propname{i}='CANLibrary';i=i+1;                                 % 10
propname{i}='HostTargetComm';i=i+1;                             % 11
propname{i}='RS232HostPort';i=i+1;                              % 12
propname{i}='RS232Baudrate';i=i+1;                              % 13
propname{i}='TcpIpTargetAddress';i=i+1;                         % 14
propname{i}='TcpIpTargetPort';i=i+1;                            % 15
propname{i}='TcpIpSubNetMask';i=i+1;                            % 16
propname{i}='TcpIpGateway';i=i+1;                               % 17
propname{i}='TcpIpTargetDriver';i=i+1;                          % 18
propname{i}='TcpIpTargetBusType';i=i+1;                         % 19
propname{i}='TcpIpTargetISAMemPort';i=i+1;                      % 20
propname{i}='TcpIpTargetISAIRQ';i=i+1;                          % 21
propname{i}='EmbeddedOption';i=i+1;                             % 22
propname{i}='TargetScope';i=i+1;                                % 23
propname{i}='TargetMouse';i=i+1;                                % 24
propname{i}='TargetBoot';i=i+1;                                 % 25

i=1;
propval{i}='';i=i+1;
propval{i}='';i=i+1;
propval{i}='VisualC';i=i+1;
propval{i}='C:\Microsoft Visual Studio';i=i+1;
propval{i}='c:\devstudio';i=i+1;
propval{i}='c:\msvc';i=i+1;
propval{i}='Auto';i=i+1;
propval{i}='1MB';i=i+1;
propval{i}='Small';i=i+1;
propval{i}='None';i=i+1;
propval{i}='RS232';i=i+1;
propval{i}='COM1';i=i+1;
propval{i}='115200';i=i+1;
propval{i}='255.255.255.255';i=i+1;
propval{i}='22222';i=i+1;
propval{i}='255.255.255.255';i=i+1;
propval{i}='255.255.255.255';i=i+1;
propval{i}='NE2000';i=i+1;
propval{i}='PCI';i=i+1;
propval{i}='0x300';i=i+1;
propval{i}='5';i=i+1;
propval{i}='Disabled';i=i+1;
propval{i}='Enabled';i=i+1;
propval{i}='None';i=i+1;
propval{i}='BootFloppy';i=i+1;
