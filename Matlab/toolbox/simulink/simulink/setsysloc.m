function setsysloc(System)
%SETSYSLOC Set system location.
%   SETSYSLOC(System) sets the location of System to be in the upper left hand
%   corner of the screen.  It also sets the location of all subsystems that
%   exist on System to be just underneath the bottom of System and aligned to
%   the left side of their subsystem block.
%
%   This function is primarily meant to be used by block libraries to help
%   align them correctly across all platforms.  To use in this manner, set
%   the PostLoadFcn of your block library to call this function with the
%   block library name:
%
%     set_param(blockLib, 'PostLoadFcn', 'setsysloc blockLib')
%
%   See also SET_PARAM.

%   Loren Dean
%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.8 $ 
  
Handle=get_param(System,'Handle');
RootSys=bdroot(Handle);
Lock=get_param(RootSys,'Lock');
Dirty=get_param(RootSys,'Dirty');
set_param(RootSys,'Lock','off');

%%%%%%%%%%%%%%%%%%%%%%%%%%
% System
%%%%%%%%%%%%%%%%%%%%%%%%%%
Units=get(0,'Units');
set(0,'Units','points');
ScreenSize=get(0,'ScreenSize');
set(0,'Units',Units);
    
SimLoc=get_param(Handle,'Location');
Width=SimLoc(3)-SimLoc(1);
Height=SimLoc(4)-SimLoc(2);
X1=25;
Y1=100;
set_param(Handle,'Location',[X1 Y1 X1+Width Y1+Height]);

%%%%%%%%%%%%%%%%%%%%%%%
% System Children
%%%%%%%%%%%%%%%%%%%%%%%
SystemChildren=find_system(Handle,'SearchDepth',1,'LoadFullyIfNeeded','off',...
			   'BlockType','SubSystem');
for SysLp=1:length(SystemChildren),        
  if ~strcmp(get_param(SystemChildren(SysLp),'Open'),'on'),  
    Parent=get_param(SystemChildren(SysLp),'Parent');
    PLoc=get_param(Parent,'Location');
    BLoc=get_param(SystemChildren(SysLp),'Location');
    BPos=get_param(SystemChildren(SysLp),'Position');
    
    Width=BLoc(3)-BLoc(1);
    Height=BLoc(4)-BLoc(2);  
    X1=PLoc(1)+BPos(1);
    Y1=PLoc(4)+30;
    X2=X1+Width;
    Y2=Y1+Height;
    NewBLoc=[X1 Y1 X2 Y2];
    set_param(SystemChildren(SysLp),'Location',NewBLoc);
  end % if
end % for    

set_param(RootSys,'Lock',Lock,'Dirty',Dirty);
