function mRoot = addContextMenu(this,menuType,varargin)
%ADDCONTEXTMENU  Install generic response plot menus.

%  Author(s): James Owen
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:27:09 $

%Create or identify (if one already exists) a context menu for a @respplot object
%of type menuType. Return an array of handles m, where m(1) identifies the parent
%context menu of type menuType, and m(2:end) are handles to the children of m(1).
AxGrid = this.AxesGrid;
mRoot = AxGrid.findMenu(menuType);  % search for specified menu (HOLD support)
if ~isempty(mRoot)
   return
end

% Create menu if it does not already exist
switch menuType
   
case 'characteristics'
   % Characteristics root menu
   mRoot = uimenu('Parent', AxGrid.UIcontextMenu,...
      'Label', xlate('Characteristics'), 'Tag', menuType);
   
case 'fullview'
   % Full View (zoom out)
   mRoot = uimenu('Parent', AxGrid.UIcontextMenu,...
      'Label', xlate('Full View'), 'Tag', menuType,...
      'Callback',{@LocalToggleFullView AxGrid});
   % Listener for menu state (check)
   p = [AxGrid.findprop('XlimMode');AxGrid.findprop('YlimMode')];
   L = handle.listener(AxGrid,p,'PropertyPostSet',{@localSyncFullView AxGrid mRoot});
   set(mRoot,'UserData',L)
   % Initialize state
   localSyncFullView([],[],AxGrid,mRoot);
   
case 'normalize'
   % Normalized Y range
   mRoot = uimenu('Parent', AxGrid.UIcontextMenu,...
      'Label', xlate('Normalize'), 'Tag', menuType,...
      'Callback',{@localToggleNormalize AxGrid});
   % Listener for menu state (check)
   L = handle.listener(AxGrid,AxGrid.findprop('YNormalization'),...
      'PropertyPostSet',{@localSyncNormalize AxGrid mRoot});
   set(mRoot,'UserData',L)
   % Initialize state
   localSyncNormalize([],[],AxGrid,mRoot);
   
case 'properties' 
   % Property editor menu
   mRoot = uimenu('Parent', AxGrid.UIcontextMenu,'Label',xlate('Properties...'),...
      'Callback',{@LocalEditProp this},'Tag', menuType);
   
case 'waveforms'
   % Menu for managing WAVEFORM visibility
   WFProp = varargin{1};  % Handle of property holding waveforms
   mRoot = uimenu('Parent',AxGrid.UIcontextMenu, 'Tag', menuType);
   L = handle.listener(this, WFProp,...
      'PropertyPreSet',{@localSyncWaveForms this WFProp mRoot});
   set(mRoot,'Userdata',{L []}); 
   % Initialize menu
   localSyncWaveForms([],[],this,WFProp,mRoot);
end

%-------------------- Local Functions ---------------------------

function localToggleNormalize(eventSrc, eventData,AxGrid)
% Toggles visibility of particular response
if strcmp(AxGrid.YNormalization,'off')
   AxGrid.YNormalization='on';
else
   AxGrid.YNormalization='off';
end


function localSyncNormalize(eventSrc,eventData,AxGrid,mRoot)
% Updates check status of Full View
set(mRoot,'Checked',AxGrid.YNormalization)


function LocalToggleFullView(eventSrc,eventData,AxGrid)
% Zooms out
AxGrid.XlimMode = 'auto';
AxGrid.YlimMode = 'auto';


function localSyncFullView(eventSrc,eventData,AxGrid,mRoot)
% Updates check status of Full View
if all(strcmp(AxGrid.XlimMode,'auto')) & all(strcmp(AxGrid.YlimMode,'auto'))
   set(mRoot,'Checked','on')
else
   set(mRoot,'Checked','off')
end


function LocalEditProp(eventSrc,eventData,this) 
% Open property editor 
PropEdit = PropEditor(this);
PropEdit.setTarget(this);


function localSyncWaveForms(eventSrc,eventData,Plot,WFProp,mRoot)
% PreSet listener to the property holding the set of waveforms shown on the plot.
% Enssures that the number of submenus matches the number of waveforms and installs
% appropriate listeners to the name, visibility, and legend properties of the tracked
% waveforms
if isempty(eventData)
   % Init
   OldWFs = [];
   NewWFs = Plot.(WFProp.Name);
else
   % PreSet listener
   OldWFs = Plot.(WFProp.Name);
   NewWFs = eventData.NewValue;
end
mSub = get(mRoot,'Children');
% Sort in order of appearance
p = get(mSub,{'Position'});
mSub([p{:}]) = mSub;

% First look for deleted waveform's
iDelResp = find(~ismember(OldWFs,NewWFs));
delete(mSub(iDelResp));
mSub(iDelResp) = [];

% Next look for added waveform's
for k=length(mSub)+1:length(NewWFs)
   uimenu('Parent',mRoot,'Callback',{@localToggleWaveFormVisibility NewWFs(k)});
end

% Update listeners to waveform properties
L = get(mRoot,'Userdata');
if ~isempty(NewWFs)
   delete(L{2});
   Props = [NewWFs(1).findprop('Visible'),...
         NewWFs(1).findprop('Name'),...
         NewWFs(1).findprop('Style')];
   Styles = get(NewWFs,{'Style'});
   Callback = {@localUpdateWaveFormMenuLabels mRoot NewWFs};
   L{2} = [handle.listener(NewWFs,Props,'PropertyPostSet',Callback);...
         handle.listener([Styles{:}],'StyleChanged',Callback)];
else
   L{2} = [];
end
set(mRoot,'Userdata',L)

% Initialize menu labels
localUpdateWaveFormMenuLabels([],[],mRoot,NewWFs)



function localToggleWaveFormVisibility(eventSrc, eventData,wf)
% Toggles visibility of particular response
if strcmp(wf.Visible,'off')
   wf.Visible='on';
else
   wf.Visible='off';
end



function localUpdateWaveFormMenuLabels(eventSrc,eventData,mRoot,WaveForms)
% Callback which sets the response menu checked status equal to the visiblity
% properties of the associated responses. 
mSub = get(mRoot,'Children');
for Menu=mSub(:)'
   wf = WaveForms(get(Menu,'Position'));  % associated waveform
   Legend = wf.Style.Legend;
   if isempty(Legend)
      set(Menu,'Label',wf.Name,'Checked',wf.Visible)
   else
      set(Menu,'Label',sprintf('%s (%s)',wf.Name,Legend),'Checked',wf.Visible)
   end
end