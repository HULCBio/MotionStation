function hmenu = ltiplotmenu(hplot,plotType) 
%LTIPLOTMENU  Constructs right-click menus for LTI response plots. 

%  Author(s): James Owen 
%  Revised:   Kamesh Subbarao
%  Copyright 1986-2003 The MathWorks, Inc.
%  $Revision: 1.23.4.5 $ $Date: 2004/04/10 23:14:47 $ 

%Create a group of context menu items appropriate for the plotType. 
%Note hplot is a @respplot object. Return a structure with fields set  
%to the appropriate meu handles for each item 
     
AxGrid = hplot.AxesGrid;
Size = AxGrid.Size; 
hmenu = struct(... 
   'Systems',[],... 
   'Characteristics',[]); 
       
% Group #1: Data contents (waves & characteristics) 
hmenu.Systems = hplot.addMenu('responses','Label',xlate('Systems')); 

if ~strcmp(plotType,{'pzmap','rlocus','margin','iopzmap'}) 
   % Create a Characteristics menu 
   hmenu.Characteristics = hplot.addMenu('characteristics'); 
end 

% Install listener to track responses added or deleted to update
% characteristics.
set(hmenu.Characteristics,'UserData',handle.listener(hplot,hplot.findprop('Responses'),...
     'PropertyPostSet',{@LocalCharCallback  hmenu.Characteristics,hplot}));

switch plotType 
case 'bode' 
   % Show mag/phase 
   hplot.addBodeMenu('show'); 
case 'nyquist' 
   % Show negative frequency 
   hplot.addNyquistMenu('show'); 
case 'lsim' 
   % Show input signal 
   hplot.addSimMenu('show'); 
end 

% Group #2: Axes configuration, I/O and model selectors
grp2 = [...
      hplot.addMenu('iogrouping'); ...
      hplot.addMenu('ioselector'); ...
      hplot.addMenu('arrayselector')];
set(grp2(1),'Separator','on')
LocalUpdateVis([],[],AxGrid,grp2)  % initialize menu visibility
% Install listener to track plot size and update menu visibility
set(grp2(2),'UserData',handle.listener(AxGrid,...
   AxGrid.findprop('Size'),'PropertyPostSet',{@LocalUpdateVis AxGrid grp2}))

% Group #3: Annotation and Focus 
AxGrid.addMenu('grid','Separator','on');

% Zoom and full view 
switch plotType 
case 'nyquist' 
   % Show mag/phase 
   hplot.addNyquistMenu('zoomcritical'); 
case {'step','impulse','lsim','initial'} 
   hplot.addMenu('normalize'); 
end    
hplot.addMenu('fullview'); 

% Add properties menu
if usejava('MWT')
    hplot.addMenu('properties','Separator','on');
end


%------------------ Local Functions -----------------------------

function LocalUpdateVis(eventsrc,eventdata,AxGrid,MenuHandles)
% Initializes and updates visibility of "MIMO" menus
if prod(AxGrid.Size([1 2]))==1
   set(MenuHandles(1:2),'Visible','off')
   set(MenuHandles(3),'Separator','on')
else
   set(MenuHandles(1:2),'Visible','on')
   set(MenuHandles(3),'Separator','off')
end
% I/O grouping options
subMenus = get(MenuHandles(1),'Children');
if all(AxGrid.Size([1 2])>1)
   set(subMenus([1 2]),'Visible','on')
else
   set(subMenus([1 2]),'Visible','off')
end
   
% 
 function LocalCharCallback(eventsrc,eventdata,CharMenuHandle,hplot)
%  Listener Callback applies characteristics for systems imported through
%  the LTIVIEWER of in the hold mode.

subMenus=get(CharMenuHandle,'Children');
ch = subMenus(find(strcmp('on',get(subMenus,'checked'))));
if ~isempty(eventdata.NewValue)
   wf = find(eventdata.NewValue,'Characteristics',[]);
   for ct = 1:length(ch)
      for  ctwf = 1:length(wf)
         args = get(ch(ct),'UserData');
         try
            % RE: Creation may fail due to size incompatibility, cf. stability
            %     margins on plot with mix of SISO and MIMO systems
            wfChar = wf(ctwf).addchar(args{:});   
            syncprefs(wfChar.Data,hplot.Preferences); % initialize parameters
         end
      end
   end
end
