function LimStackBox = editLimStack(this,BoxLabel,BoxPool)
%EDITLIMSTACK  Builds group box for limit stack management.

%   Author(s): A. DiVergilio, P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:16:27 $

% RE: XY is the axis (X or Y), and BoxLabel is the groupbox label
LimStackBox = find(handle(BoxPool),'Tag','Limit Stack');
if isempty(LimStackBox)
   % Create groupbox if not found
   LimStackBox = LocalCreateUI(this);
end
LimStackBox.GroupBox.setLabel(sprintf(BoxLabel))
LimStackBox.Tag = 'Limit Stack';

% Target
LimStackBox.Target = this;


%------------------ Local Functions ------------------------

function LimStackBox = LocalCreateUI(Axes)
%GUI for editing axesgroup limits

%---Get Toolbox Preferences
Prefs = cstprefs.tbxprefs;
import com.mathworks.mwt.*;

%---Top-level panel (MWGroupbox)
Main = MWGroupbox;
Main.setLayout(MWBorderLayout(8,8));
Main.setFont(Prefs.JavaFontB);

%---Create @editbox instance
LimStackBox = cstprefs.editbox;
LimStackBox.GroupBox = Main;

%---Info label along bottom
InfoStr = sprintf('Use the limit stack to store & retrieve axes limits');
s.Status = MWLabel(sprintf('%s',InfoStr),MWLabel.LEFT);
s.Status.setFont(Prefs.JavaFontP);
Main.add(s.Status,MWBorderLayout.SOUTH);

%---West panel for buttons
s.W = MWPanel(java.awt.GridLayout(1,4,10,0));
Main.add(s.W,MWBorderLayout.WEST);

%---Image files for buttons
filebase = matlabroot;
file1 = fullfile(filebase,'toolbox','control','ctrlguis','@ctrluis','@axes','button1.gif');
file2 = fullfile(filebase,'toolbox','control','ctrlguis','@ctrluis','@axes','button2.gif');
file3 = fullfile(filebase,'toolbox','control','ctrlguis','@ctrluis','@axes','button3.gif');
file4 = fullfile(filebase,'toolbox','control','ctrlguis','@ctrluis','@axes','button4.gif');

%---Buttons
MouseEnteredCallback = {@localEnter LimStackBox s.Status};
MouseExitedCallback = {@localExit s.Status};
s.Add = MWButton(MWImageResource(file1)); s.W.add(s.Add);
set(s.Add,'Name','Add','MouseEnteredCallback',MouseEnteredCallback,...
   'MouseExitedCallback',MouseExitedCallback);
s.Prev = MWButton(MWImageResource(file2)); s.W.add(s.Prev);
set(s.Prev,'Name','Prev','MouseEnteredCallback',MouseEnteredCallback,...
   'MouseExitedCallback',MouseExitedCallback);
s.Next = MWButton(MWImageResource(file3)); s.W.add(s.Next);
set(s.Next,'Name','Next','MouseEnteredCallback',MouseEnteredCallback,...
   'MouseExitedCallback',MouseExitedCallback);
s.Remove = MWButton(MWImageResource(file4)); s.W.add(s.Remove);
set(s.Remove,'Name','Remove','MouseEnteredCallback',MouseEnteredCallback,...
   'MouseExitedCallback',MouseExitedCallback);

%---Store java handles
set(Main,'UserData',s);

%---Install GUI callbacks
GUICallback = {@localStackCallbacks LimStackBox};
set(s.Add,   'ActionPerformedCallback',GUICallback);
set(s.Prev,  'ActionPerformedCallback',GUICallback);
set(s.Next,  'ActionPerformedCallback',GUICallback);
set(s.Remove,'ActionPerformedCallback',GUICallback);


%%%%%%%%%%%%%%
% localEnter %
%%%%%%%%%%%%%%
function localEnter(eventSrc,eventData,LimStackBox,Status)
% Mouse entered
Name = get(eventSrc,'Name');
switch Name
case 'Add'
   Str = sprintf('Add current limits to stack');
otherwise
   StackLength = size(LimStackBox.Target.LimitStack.Limits,1);
   if StackLength>0
      switch Name
      case 'Prev'
         Str = sprintf('Retrieve previous stack entry');
      case 'Next'
         Str = sprintf('Retrieve next stack entry');
      case 'Remove'
         Str = sprintf('Remove current limits from stack');
      end
   else
      Str = sprintf('No action (stack is empty)');
   end
end
Status.setText(Str);


%%%%%%%%%%%%%
% localExit %
%%%%%%%%%%%%%
function localExit(eventSrc,eventData,Status)
% Mouse exited
Status.setText(sprintf('Use the limit stack to store & retrieve axes limits'));


%%%%%%%%%%%%%%%%%%%%%%%
% localStackCallbacks %
%%%%%%%%%%%%%%%%%%%%%%%
function localStackCallbacks(eventSrc,eventData,LimStackBox)
% GUI -> Target
s = get(LimStackBox.GroupBox,'UserData');
Axes = LimStackBox.Target;
ax = getaxes(Axes);
% Limit stack data
LimStack = Axes.LimitStack;
StackLength = size(LimStack.Limits,1);
pos = LimStack.Index;

switch get(eventSrc,'Name')
case 'Add'
    new = [get(ax,'Xlim') get(ax,'Ylim')];
    LimStack.Limits = [LimStack.Limits(1:pos,:) ; new ; LimStack.Limits(pos+1:StackLength,:)];
    LimStack.Index = pos+1;
 case 'Prev'
    if StackLength>0
       pos = (pos==1)*StackLength + (pos>1)*(pos-1);
       LocalSetLims(Axes,LimStack.Limits(pos,:));
       LimStack.Index = pos;
    end
 case 'Next'
    if StackLength>0
       pos = (pos==StackLength) + (pos<StackLength)*(pos+1);
       LocalSetLims(Axes,LimStack.Limits(pos,:));
       LimStack.Index = pos;
    end
 case 'Remove'
    if StackLength>0
       lims = [get(ax,'Xlim') get(ax,'Ylim')];
       if isequal(lims,LimStack.Limits(pos,:))
          LimStack.Limits = [LimStack.Limits(1:pos-1,:);LimStack.Limits(pos+1:StackLength,:)];
          newpos = min(pos,StackLength-1);
          localEnter(eventSrc,eventData,LimStackBox,s.Status);
          if newpos>0
             LocalSetLims(Axes,LimStack.Limits(newpos,:));
          else
             Axes.XlimMode = 'auto';
             Axes.YlimMode = 'auto';
          end
          LimStack.Index = newpos;
       end
    end
 end
 Axes.LimitStack = LimStack;



function LocalSetLims(Axes,Limits)
% Updates X and Y limits
setxlim(Axes,Limits([1 2]))
setylim(Axes,Limits([3 4]))
