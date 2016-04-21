function heatex_clbk(action)
% HEATEX_CLBK is a callback function from the Simulink model
% It is called when various tasks are performed in the Simulink model

%   Author(s): N. Hickey
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.4 $  $Date: 2002/04/10 06:40:47 $

LinkData = get_param('heatex_sim/Get Data','UserData');
GUI_Data = get(LinkData.FigHandle,'UserData');

switch action
    
case 'Start'
    feval(LinkData.StartFcn,GUI_Data.Controls.StartBtnHdl,[]);
    
case 'Stop'
    feval(LinkData.StopFcn,GUI_Data.Controls.StopBtnHdl,[]);	
    
case 'Close'
    set_param(GUI_Data.Simulink.Model,'Dirty','off');	
    figHdl = LinkData.FigHandle;
    set(figHdl,'DeleteFcn','');
    close(figHdl);
    
case 'FFSelect'
    FFSwitchPath = GUI_Data.Simulink.FFSwitch;
    FFSwitch = str2num(get_param(FFSwitchPath,'sw'));
    GUI_Data.CtrlStrct(1) = FFSwitch;
    set(LinkData.FigHandle,'Userdata',GUI_Data);
    feval(LinkData.UpDateStrctFcn,GUI_Data.Figure);
    
case 'FBSelect'
    FBSwitchPath = GUI_Data.Simulink.FBSwitch;
    FBSwitch = str2num(get_param(FBSwitchPath,'sw'));
    GUI_Data.CtrlStrct(2) = FBSwitch;
    set(LinkData.FigHandle,'Userdata',GUI_Data);
    feval(LinkData.UpDateStrctFcn,GUI_Data.Figure);
    
otherwise
    % Do nothing	
    
end % of switch action



