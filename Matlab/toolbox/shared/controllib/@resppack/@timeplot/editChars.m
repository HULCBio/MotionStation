function TextBox = editChars(this,BoxLabel,BoxPool)
%EDITCHARS  Builds group box for editing Characteristics.

%   Author (s): Kamesh Subbarao
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:24:04 $

% Look for a group box with matching Tag in the pool of group boxes

TextBox = find(handle(BoxPool),'Tag',BoxLabel);

if isempty(TextBox)
   % Create group box if not found
   TextBox = LocalCreateUI(this);
end
TextBox.GroupBox.setLabel(sprintf('Characteristics'));

%%%%%%%%%%%%% Targeting CallBacks.... (Write the Plot Properties into the GUI) %%%%%%%%%%%
TextBox.Target = this;
TextBox.TargetListeners = ...
    [handle.listener(this,findprop(this,'Preferences'),'PropertyPostSet',{@localReadProp TextBox,this});...
     handle.listener(this.PropEditor,'PropEditBeingClosed',{@localWriteProp,TextBox})];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
s = get(TextBox.GroupBox,'UserData');
% Initialization.....................
% Settling Time
stval = this.Preferences.SettlingTimeThreshold;
set(s.SettlingTimeThreshold,'Text',num2str(stval*100));
if strcmpi(this.Tag,'step')
    % Rise Time Limits
    rtval = this.Preferences.RiseTimeLimits;
    s.RiseTimeLimits1.setText(num2str(rtval(1)*100));
    s.RiseTimeLimits2.setText(num2str(rtval(2)*100));
end

%------------------ Local Functions ------------------------
function OptionsBox = LocalCreateUI(h)

% Toolbox Preferences
Prefs = cstprefs.tbxprefs;
%---Create @editbox instance
OptionsBox = cstprefs.editbox;

%---Definitions
WEST   = com.mathworks.mwt.MWBorderLayout.WEST;
CENTER = com.mathworks.mwt.MWBorderLayout.CENTER;
FL_L50 = java.awt.FlowLayout(java.awt.FlowLayout.LEFT,5,0);

%---Top-level panel (MWGroupbox)
Main = com.mathworks.mwt.MWGroupbox(sprintf('Response Characteristics'));
Main.setLayout(com.mathworks.mwt.MWBorderLayout(0,0));
Main.setFont(Prefs.JavaFontB);

%---Response Characteristics panel
switch h.Tag
case 'step'
   s.RC = com.mathworks.mwt.MWPanel(java.awt.GridLayout(2,1,0,4));
case 'impulse'
   s.RC = com.mathworks.mwt.MWPanel(java.awt.GridLayout(1,1,0,4));
end
Main.add(s.RC,com.mathworks.mwt.MWBorderLayout.WEST);

%--- GUI CallBacks.... (Write the GUI Values into the Plot Properties)
GUICallback = {@localWriteProp,OptionsBox};
%---SettlingTime
s.R2 = com.mathworks.mwt.MWPanel(com.mathworks.mwt.MWBorderLayout(0,0)); s.RC.add(s.R2);
s.SettlingTime = com.mathworks.mwt.MWLabel(sprintf('Show settling time within')); s.R2.add(s.SettlingTime,WEST);
s.SettlingTime.setFont(Prefs.JavaFontP);
%---SettlingTimeThreshold
s.R2E = com.mathworks.mwt.MWPanel(FL_L50); s.R2.add(s.R2E,CENTER);
s.SettlingTimeThreshold = com.mathworks.mwt.MWTextField(3); s.R2E.add(s.SettlingTimeThreshold);
s.SettlingTimeThreshold.setFont(Prefs.JavaFontP);
s.R2EL1 = com.mathworks.mwt.MWLabel(sprintf('%%')); s.R2E.add(s.R2EL1);
s.R2EL1.setFont(Prefs.JavaFontP);
%---SettlingTimeThreshold
set(s.SettlingTimeThreshold,'Name','SettlingTimeThreshold',...
    'ActionPerformedCallback',GUICallback);

if strcmpi(h.Tag,'step')
    %---RiseTime
    s.R3 = com.mathworks.mwt.MWPanel(com.mathworks.mwt.MWBorderLayout(0,0)); s.RC.add(s.R3);
    s.RiseTime = com.mathworks.mwt.MWLabel(sprintf('Show rise time from')); s.R3.add(s.RiseTime,WEST);
    s.RiseTime.setFont(Prefs.JavaFontP);
    %---RiseTimeLimits
    s.R3E = com.mathworks.mwt.MWPanel(FL_L50); s.R3.add(s.R3E,CENTER);
    s.RiseTimeLimits1 = com.mathworks.mwt.MWTextField(3); s.R3E.add(s.RiseTimeLimits1);
    s.RiseTimeLimits1.setFont(Prefs.JavaFontP);
    s.R3EL1 = com.mathworks.mwt.MWLabel(sprintf('to')); s.R3E.add(s.R3EL1);
    s.R3EL1.setFont(Prefs.JavaFontP);
    s.RiseTimeLimits2 = com.mathworks.mwt.MWTextField(3); s.R3E.add(s.RiseTimeLimits2);
    s.RiseTimeLimits2.setFont(Prefs.JavaFontP);
    s.R3EL2 = com.mathworks.mwt.MWLabel(sprintf('%%')); s.R3E.add(s.R3EL2);
    s.R3EL2.setFont(Prefs.JavaFontP);
    %---RiseTimeLimits
    set(s.RiseTimeLimits1,'Name','RiseTimeLimits1',...
        'ActionPerformedCallback',GUICallback);
    set(s.RiseTimeLimits2,'Name','RiseTimeLimits2',...
        'ActionPerformedCallback',GUICallback);
end

%---Store java handles
set(Main,'UserData',s);
OptionsBox.GroupBox = Main;
OptionsBox.Tag = sprintf('%s',h.tag,'Characteristics');

%%%%%%%%%%%%%%%%%
% localReadProp %
%%%%%%%%%%%%%%%%%
function localReadProp(eventSrc,eventData,TextBox,h)
% Update GUI when property changes
s = get(TextBox.GroupBox,'UserData');
NewValue = eventData.NewValue;
%---Set GUI state/text
s.SettlingTimeThreshold.setText(num2str(NewValue.SettlingTimeThreshold*100));
if strcmpi(h.Tag,'step')
   s.RiseTimeLimits1.setText(num2str(NewValue.RiseTimeLimits(1)*100));
   s.RiseTimeLimits2.setText(num2str(NewValue.RiseTimeLimits(2)*100));
end

%%%%%%%%%%%%%%%%%%
% localWriteProp %
%%%%%%%%%%%%%%%%%%
function localWriteProp(eventSrc,eventData,TextBox)
% Update property when GUI changes

h = TextBox.Target;
s = get(TextBox.GroupBox,'UserData');
Prefs = h.Preferences;
isChanged = false; 

% Settling Time
STOldVal = h.Preferences.SettlingTimeThreshold;
STCurrentVal = evalnum(char(s.SettlingTimeThreshold.getText))/100;

if ~isequal(STOldVal,STCurrentVal) && ~isempty(STCurrentVal)
    isChanged = true;
    STCurrentVal = max(min(STCurrentVal,1),0);
    Prefs.SettlingTimeThreshold = STCurrentVal;
    s.SettlingTimeThreshold.setText(num2str(STCurrentVal*100));
else
    % revert back to old value
    s.SettlingTimeThreshold.setText(num2str(STOldVal*100));
end

if strcmpi(h.Tag,'step')
    % Rise Time
    RTOldVec = h.Preferences.RiseTimeLimits;
    RTCurrentVal1 =  evalnum(char(s.RiseTimeLimits1.getText))/100;
    RTCurrentVal2 =  evalnum(char(s.RiseTimeLimits2.getText))/100;
    RTCurrentVec = [RTCurrentVal1,RTCurrentVal2];
    
    if ~isequal(RTOldVec,RTCurrentVec)
        isChanged = true;
        
        %---Revert to old values for empty ones
        if isempty(RTCurrentVal1)
            RTCurrentVal1 = RTOldVec(1);
        end
        if isempty(RTCurrentVal2)
            RTCurrentVal2 = RTOldVec(2);
        end
        RTCurrentVec = [RTCurrentVal1,RTCurrentVal2];
        
        %---Limit entries to (0,1)
        RTCurrentVec = max(min(RTCurrentVec,1),0);
        
        %---Reset upper or lower bounds if incompatible 
        if diff(RTCurrentVec)<0 
            if isequal(RTCurrentVec(1),RTOldVec(1)) 
                RTCurrentVec(1) = 0;
            elseif isequal(RTCurrentVec(2),RTOldVec(2))
                RTCurrentVec(2) = 1;
            else
                RTCurrentVec = RTOldVec;
            end
        end
        Prefs.RiseTimeLimits = RTCurrentVec;
        s.RiseTimeLimits1.setText(num2str(RTCurrentVec(1)*100));
        s.RiseTimeLimits2.setText(num2str(RTCurrentVec(2)*100));
    end
end

if isChanged
    h.Preferences = Prefs;
end

%%%%%%%%%%%
% evalnum %
%%%%%%%%%%%
function val = evalnum(val)
% Evaluate string val, returning valid real scalar only, empty otherwise
if ~isempty(val)
   val = evalin('base',val,'[]');
   if ~isnumeric(val) | ~(isreal(val) & isfinite(val) & isequal(size(val),[1 1]))
      val = [];
   end
end
