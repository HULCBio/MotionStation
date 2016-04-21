function varargout = sptprefs(varargin)
%SPTPREFS  Preferences dialog box for SPTool.
%  prefs = sptprefs(prefs)

%   Copyright 1988-2004 The MathWorks, Inc.
% $Revision: 1.12.4.2 $

if ~isstr(varargin{1})
    action = 'init';
    prefs = varargin{1};
else
    action = varargin{1};
end

switch action
case 'init'

    SPTfig = gcf;

    if nargin > 1
       panelInd = varargin{2};
    else
       panelInd = 1;
    end
    
    figname = 'Preferences for SPTool';
    okstring = 'OK';
    cancelstring = 'Cancel';
    fus = 5;  % frame / uicontrol spacing
    ffs = 8;
    uh = 24;  % uicontrol height
    listw = 175;  % list box width
    lw = 170; % label width
    bw = 110; % button width
    bw1 = 90; % button width for Cancel and OK
    uw = 250; % uicontrol width
    lfs = 5;  % label / frame spacing
    lbs = 3;  % label / box spacing
    lh = 16;  % label height
    
    fp = get(0,'defaultfigureposition');
    w = 2*ffs + listw + fus + 2*fus + lbs + lw + uw;
    h = 8*(fus+uh) + lh + 2*fus + uh;
    fp = [15 fp(2)+fp(4)-h w h];  % keep top of window fixed

    fig_props = { ...
       'name'                   figname ...
       'resize'                 'off' ...
       'numbertitle'            'off' ...
       'windowstyle'            'modal' ... 
       'createfcn'              ''    ...
       'position'               fp   ...
       'closerequestfcn'        'sbswitch(''sptprefs'',''cancel'')' ...
       'color'                  get(0,'defaultuicontrolbackgroundcolor') ...
       'units'                  'pixels' ...
       'dockcontrols',          'off',...
       'handlevisibility'       'callback'};

    fig = figure(fig_props{:});
    
    cancel_btn = uicontrol('style','pushbutton',...
      'units','pixels',...
      'string',cancelstring,...
      'position',[fp(3)-ffs-bw1 ffs bw1 uh],...
      'tag','cancelButton',...
      'callback','sbswitch(''sptprefs'',''cancel'')');
    ud.ok_btn = uicontrol('style','pushbutton',...
      'units','pixels',...
      'string',okstring,...
      'enable','off',...
      'tag','okButton',...
      'position',[fp(3)-ffs-bw1-fus-bw1 ffs bw1 uh],...
      'callback','applyfilt(''ok'')');
    
    ud.list = uicontrol('style','listbox',...
      'units','pixels',...
      'string',{prefs.panelDescription},...
      'value',panelInd,...
      'tag','listbox',...
      'position',[ffs ffs+fus+uh listw fp(4)-2*ffs-fus-uh],...
      'callback','sbswitch(''sptprefs'',''list'')',...
      'backgroundcolor','w');
      
    ud.helpButton = uicontrol('style','pushbutton',...
      'units','pixels',...
      'tag','helpButton',...
      'string','Help...',...
      'position',[ffs ffs listw uh],...
      'callback','sbswitch(''sptprefs'',''help'')');
    
    ud.prefs = prefs;
    
    ud.factory = uicontrol('style','pushbutton',...
      'units','pixels',...
      'string','Factory Settings',...
      'tag','factoryButton',...
      'position',[ffs+fus+listw ffs bw uh],...
      'callback','sbswitch(''sptprefs'',''factory'')');
    ud.revert = uicontrol('style','pushbutton',...
      'units','pixels',...
      'string','Revert Panel',...
      'tag','revertButton',...
      'position',[ffs+fus+listw+fus+bw ffs bw uh],...
      'callback','sbswitch(''sptprefs'',''revert'')');
          
   
    pf_pos = [ffs+fus+listw 2*fus+uh 2*fus+lbs+lw+uw 8*(uh+fus)+lh/2];
    ud.panelFrame = uicontrol('style','frame',...
      'units','pixels',...
      'tag','panelFrame',...
      'position',pf_pos);
    ud.panelLabel = uicontrol('style','text',...
      'units','pixels',...
      'tag','panelLabel',...
      'position',[pf_pos(1)+10 pf_pos(2)+pf_pos(4)-lh/2 lw lh],...
      'string',ud.prefs(panelInd).panelDescription);
    minwidthLeft(ud.panelLabel)
    
    ud.panelControls = cell(length(prefs),1);
    
    ud.panelControls{panelInd} = createPanel(prefs(panelInd),pf_pos,...
         fus,lbs,lw,lh,uw,uh);
    
    ud.whichControl = [];
    ud.changedFlags = zeros(length(ud.prefs),1);
    ud.flag = '';
    set(fig,'userdata',ud)
    setEnable(panelInd,ud.prefs,ud.panelControls,ud.factory,ud.revert)
    
    done = 0;
    while ~done
        waitfor(fig,'userdata')

        ud = get(fig,'userdata');
       
        switch ud.flag
        case 'list'
            oldPanelInd = panelInd;
            panelInd = get(ud.list,'value');
           
            if panelInd ~= oldPanelInd
               % change label
               set(ud.panelLabel,'string',ud.prefs(panelInd).panelDescription);
               minwidthLeft(ud.panelLabel)

               % hide old uicontrols
               set([ud.panelControls{oldPanelInd}{:}],'visible','off')
               
               % show or create uicontrols for this panel
               if isempty(ud.panelControls{panelInd})
                   ud.panelControls{panelInd} = createPanel(prefs(panelInd),...
                       pf_pos,fus,lbs,lw,lh,uw,uh);
               else
                    set([ud.panelControls{panelInd}{:}],'visible','on')
               end
               setEnable(panelInd,ud.prefs,ud.panelControls,ud.factory,ud.revert)
            end
        case 'change'            
            % if this is a radio button, set values of all visible 
            % radiobuttons with the same tag.
            if strcmp('radiobutton',...
                 get(ud.panelControls{panelInd}{ud.whichControl}(1),'style'))
                radioTag = ud.prefs(panelInd).controls{ud.whichControl,4};
                if ~isempty(radioTag)
                    u = findobj('style','radiobutton','userdata',radioTag,...
                        'visible','on');
                    set(u,'value',0)
                    set(ud.panelControls{panelInd}{ud.whichControl},'value',1)
                end
            end
            
            % check to see if current values are factory or original,
            %  and set enable property of Factory Settings and Revert Panel
            %  buttons appropriately.
            
            setEnable(panelInd,ud.prefs,ud.panelControls,ud.factory,ud.revert)

        case 'revert'
        % revert panel button pushed
            setPanel(ud.panelControls{panelInd},ud.prefs(panelInd).currentValue)
            setEnable(panelInd,ud.prefs,ud.panelControls,ud.factory,ud.revert)
            
        case 'factory'
        % factory button pushed
            setPanel(ud.panelControls{panelInd},ud.prefs(panelInd).controls(:,7))
            setEnable(panelInd,ud.prefs,ud.panelControls,ud.factory,ud.revert)
            
        case 'ok'
            newprefs = ud.prefs;
            err = 0;
            for i=1:length(ud.prefs)
                if ~isempty(ud.panelControls{i})
                    newprefs(i).currentValue = getPanel(ud.panelControls{i});
                end
                
                if ~isequal(newprefs(i).currentValue,ud.prefs(i).currentValue)
                    p = cell2struct(newprefs(i).currentValue,...
                                    ud.prefs(i).controls(:,1));
                    for j=1:length(ud.prefs(i).clientList)
                        errstr = feval(ud.prefs(i).clientList{j},'setprefs',...
                           ud.prefs(i).panelName,p);
                        err = length(errstr)>0;
                        if err
                            break
                        end
                    end
                    if err
                        break
                    end
                    ud.prefs(i).currentValue = newprefs(i).currentValue;
                    sptool('setprefs',ud.prefs(i).panelName,p,SPTfig)
                end
            end
            if err
                done = 0;
                msgbox(errstr,'Error','error','modal')
            else
                done = 1;
            end
        case 'cancel'
            % do nothing and return
            done = 1;
            err = 1;
        case 'help'
            sptprefsHelp
        end
    
        if ~done
            if strcmp(get(ud.revert,'enable'),'on')
                ud.changedFlags(panelInd) = 1;
            else
                ud.changedFlags(panelInd) = 0;
            end
            if any(ud.changedFlags)
                set(ud.ok_btn,'enable','on')
            else
                set(ud.ok_btn,'enable','off')
            end
            ud.flag = [];
            set(fig,'userdata',ud)
        end
    end
    
    delete(fig)
    varargout{1} = ud.prefs;
    varargout{2} = panelInd;

% ------
%  action == 'ok' or 'cancel' or anything else
otherwise
    fig = gcf;
    ud = get(fig,'userdata');
    ud.flag = action;
    if nargin > 1
        ud.whichControl = varargin{2};
    end
    set(fig,'userdata',ud)
        
end

function minwidthLeft(h,n)
%MINWIDTH Minimize width of left justified text object to be just wide
% enough for extent.
% optional second argument specifies additional pixels on either side
% of text, defaults to 2

if nargin == 1
    n = 2;
end
for i=1:length(h)
    ex = get(h(i),'extent');
    pos = get(h(i),'position');
    style = get(h(i),'style');
    if strcmp(style,'checkbox') | strcmp(style,'radiobutton')
        % add to width to account for radio or check box
        set(h(i),'horizontalalignment','center',...
           'position',[pos(1) pos(2) ex(3)+2*n+30 pos(4)])
   else
       set(h(i),'horizontalalignment','center',...
           'position',[pos(1) pos(2) ex(3)+2*n pos(4)]);
    end
end


function panelControls = createPanel(prefs,pf_pos,fus,lbs,lw,lh,uw,uh);
%createPanel - create uicontrols for Panel
% Inputs:
%    prefs - 1-by-1 struct with fields
%       .panelName, .panelDescription, .controls, .currentValue
%    pf_pos - position in pixels of panel frame
%    fus,lbs,lw,lh,uw,uh - spacing and positioning information
% Outputs:
%    panelControls - cell array of handle vectors, one entry for each row
%       of prefs.controls

labelPos = [pf_pos(1)+fus pf_pos(2)+pf_pos(4)-lh/2+fus lw uh];
controlPos = [pf_pos(1)+fus+lbs+lw ...
       pf_pos(2)+pf_pos(4)-lh/2+fus uw uh];

N = size(prefs.controls,1);
% prefs.controls is a table containing the following columns:
%  Name  Description  type  radiogroup  number_of_lines popup_string ...
%      factory_value  help_string

panelControls = cell(1,N);
for i=1:N
    if i == 1
        labelPos = labelPos - [0 uh+fus 0 0];
    else
        labelPos = labelPos - [0 prefs.controls{i-1,5}*uh+fus 0 0];
    end
    controlPos = controlPos - [0 prefs.controls{i,5}*uh+fus 0 0];
    controlPos(4) = prefs.controls{i,5}*uh;
    switch prefs.controls{i,3}
    case 'edit'
        panelControls{i} = uicontrol('style','text',...
            'units','pixels',...
            'tag',['control' num2str(i)],...
            'position',labelPos,...
            'string',prefs.controls{i,2},...
            'horizontalalignment','right');
        panelControls{i} = [ panelControls{i}  uicontrol('style','edit',...
            'units','pixels',...
            'tag',['control' num2str(i)],...
            'backgroundcolor','w','string',prefs.currentValue{i},...
            'callback',['sbswitch(''sptprefs'',''change'',' num2str(i) ')'],...
            'userdata',prefs.controls{i,4},...
            'position',controlPos,...
            'horizontalalignment','left',...
            'max',prefs.controls{i,5})   ];    
    case 'popupmenu'
        panelControls{i} = uicontrol('style','text',...
            'units','pixels',...
            'tag',['control' num2str(i)],...
            'position',labelPos,...
            'string',prefs.controls{i,2},...
            'horizontalalignment','right');
        panelControls{i} = [ panelControls{i}  uicontrol('style','popupmenu',...
            'backgroundcolor','white',...
            'units','pixels',...
            'tag',['control' num2str(i)],...
            'string',prefs.controls{i,6},...
            'value',prefs.currentValue{i},...
            'callback',['sbswitch(''sptprefs'',''change'',' num2str(i) ')'],...
            'userdata',prefs.controls{i,4},...
            'position',controlPos)   ];    
    case 'radiobutton'
        panelControls{i} = uicontrol('style','radiobutton',...
            'units','pixels',...
            'tag',['control' num2str(i)],...
            'position',labelPos,...
            'string',prefs.controls{i,2},...
            'value',prefs.currentValue{i},...
            'callback',['sbswitch(''sptprefs'',''change'',' num2str(i) ')'],...
            'userdata',prefs.controls{i,4});
        minwidthLeft(panelControls{i})

    case 'checkbox'
        panelControls{i} = uicontrol('style','checkbox',...
            'units','pixels',...
            'tag',['control' num2str(i)],...
            'position',labelPos,...
            'string',prefs.controls{i,2},...
            'value',prefs.currentValue{i},...
            'callback',['sbswitch(''sptprefs'',''change'',' num2str(i) ')'],...
            'userdata',prefs.controls{i,4});
        minwidthLeft(panelControls{i})
    end

end

function setPanel(panelControls,value)
%setPanel - set values of uicontrols
% Inputs:
%    panelControls - cell array of handle vectors for the current panel
%    value - cell array of values for each entry of panelControls

N = length(panelControls);
for i=1:N
    if length(panelControls{i}) == 1
        style = get(panelControls{i}(1),'style');
    else
        style = get(panelControls{i}(2),'style');
    end
    switch style
    case 'edit'
        set(panelControls{i}(2),'string',value{i})
    case 'popupmenu'
        set(panelControls{i}(2),'value',value{i})
    case {'radiobutton', 'checkbox'}
        set(panelControls{i}(1),'value',value{i})
    end
end

function values = getPanel(panelControls)
%getPanel - get values from uicontrols
% Inputs:
%    panelControls - cell array of handle vectors for the current panel
% Outputs:
%    value - cell array (column) of values for each entry of panelControls
   values = {};
   for i = 1:length(panelControls)
       if length(panelControls{i}) == 1
           style = get(panelControls{i}(1),'style');
       else
           style = get(panelControls{i}(2),'style');
       end
       switch style
       case 'edit'
           values = {values{:} ...
                get(panelControls{i}(2),'string')};
       case 'popupmenu'
           values = {values{:} ...
                get(panelControls{i}(2),'value')};
       case {'radiobutton','checkbox'}
           values = {values{:} ...
                get(panelControls{i}(1),'value')};
       end
   end
   values = values(:);

function setEnable(panelInd,prefs,panelControls,factory,revert)
% setEnable - sets enable property of factory and revert uicontrols

   values = getPanel(panelControls{panelInd});
   if isequal(values,prefs(panelInd).currentValue)
       set(revert,'enable','off')
   else
       set(revert,'enable','on')
   end
   if isequal(values,prefs(panelInd).controls(:,7))
       set(factory,'enable','off')
   else
       set(factory,'enable','on')
   end
   
function sptprefsHelp
% local function to go into help mode
    fig = gcf;
    ud = get(fig,'userdata');
    set(ud.helpButton,'String','Click for Help...')
    setptr(fig,'help')

    panelInd = get(ud.list,'value');
    
    uilist = findobj(fig,'type','uicontrol');
    saveenable = get(uilist,'enable');
    set(uilist,'enable','inactive',...
       'buttondownfcn',...
         'set(findobj(gcf,''tag'',''helpButton''),''userdata'',get(gcbo,''tag''))')

    set(ud.helpButton,'userdata',0)
    waitfor(ud.helpButton,'userdata')
    tag = get(ud.helpButton,'userdata');
    switch tag
    case 'helpButton'
        s = {
        'PREFERENCES DIALOG BOX'
        ' '
        'This window allows you to change certain settings of the SPTool'
        'and its clients that will be remembered between MATLAB sessions.'
        'The preferences are saved on disk in the MAT-file "sigprefs.mat".'
        ' '
        'To get help on any preference or on how to use the buttons, '
        'click "Help..." once, and then click on the item you would like'
        'more help on.'
        };
    case 'revertButton'
        s = {
        'REVERT PANEL BUTTON'
        ' '
        'Press this button to revert the preferences in the current '
        'panel to what they were when you opened the preferences window.'
        ' '
        'This button is enabled only if you have made a change to the'
        'preferences in the current panel.' 
        };
    case 'factoryButton'
        s = {
        'FACTORY SETTINGS BUTTON'
        ' '
        'Press this button to restore the preferences in the current panel'
        'to their "factory settings", that is, the settings at the time'
        'the software was first installed.'
        ' '
        'This button is enabled only when the preferences in the current'
        'panel are not the same as the factory settings.' 
        };
    case 'okButton'
        s = {
        'OK BUTTON'
        ' '
        'Press this button to apply your changes to the preferences and'
        'close the preferences window.'
        ' '
        'This button is only enabled when you have made some change to'
        'a preference.'
        ' '
        'If the file "sigprefs.mat" is not found, a dialog box will appear,'
        'asking you to find a place to save this file.  If this process '
        'happens repeatedly, then either you are saving the file somewhere'
        'not on your MATLAB path or current directory, or perhaps you are out of'
        'disk space or the directory is write-protected.'
        };
    case 'cancelButton'
        s = {
        'CANCEL BUTTON'
        ' '
        'Press this button to close the preferences window, ignoring any'
        'changes made while it was open.'
        };
    case 'listbox'
        s = {
        'PREFERENCE CATEGORY LIST'
        ' '
        'This is a list of all the categories of preferences that you'
        'can change for the SPTool.'
        ' '
        'By clicking on a category, the panel on the right changes to'
        'reflect the preferences for that category.'
        ' '
        'To get help on a category, change to that category first, and then'
        'click on "Help..." and click the question mark cursor on the'
        'category name at the top of the panel on the right.'
        };
    case {'panelLabel','panelFrame'}
        s = {
        ['Preferences for "' ud.prefs(panelInd).panelDescription '"'] ...
        ' ' ...
        ud.prefs(panelInd).panelHelp{:} ...
        };
    otherwise
        ind = findstr('control',tag);
        if ~isempty(ind)
            tag(1:7)=[];
            i = str2double(tag);
            s = {['You have clicked on preference "' ...
                     ud.prefs(panelInd).controls{i,2} '"'] ... 
                     ['in the category "' ...
                  ud.prefs(panelInd).panelDescription '".'] ...
                 ' ' ...
                 ud.prefs(panelInd).controls{i,8}{:} ...
                 };
        else
            s = {['this object has tag ' tag]};
        end
    end
    
    set(uilist,{'enable'},saveenable,'buttondownfcn','')
    set(ud.helpButton,'String','Help...')
    setptr(fig,'arrow')
    
    fp = get(fig,'position');
    sz = sptsizes;
    helpButtonPos = get(ud.helpButton,'position');
    sz.uh = helpButtonPos(4);

    saveVis = get(uilist,'visible');
    if strcmp(computer,'PCWIN')
        set(uilist,'visible','off')
    end

    f = uicontrol('style','frame',...
           'position',[sz.fus sz.fus fp(3)-2*sz.fus fp(4)-sz.fus-1],...
           'tag','prefhelp');
    tp = [2*sz.fus 4*sz.fus+sz.uh fp(3)-4*sz.fus fp(4)-(6*sz.fus+sz.uh)];
       % text position
    [fontname,fontsize]=fixedfont;
    t = uicontrol('style','listbox','position',tp,'string',s,'max',2,...
         'tag','prefhelp','horizontalalignment','left',...
         'backgroundcolor','w','fontname',fontname,'fontsize',fontsize);
    bp = [fp(3)/2-sz.bw/2 2*sz.fus sz.bw sz.uh];
    okCbStr = 'delete(findobj(gcf,''tag'',''prefhelp''))';
    b = uicontrol('style','pushbutton','position',bp,...
         'tag','prefhelp','string','OK',...
         'callback',okCbStr);
      
    % Temporarily set the CloseRequestFcn property of fig to be the same
    % as the callback string of the OK button.  This will allow the user
    % to close the figure by clicking on the close box ('X') of the fig.
    closeReqFcn = get(fig,'CloseRequestFcn');
    set(fig,'CloseRequestFcn',okCbStr);
    waitfor(b)
    set(fig,'CloseRequestFcn',closeReqFcn);
    
    if all(ishandle(uilist))
        if strcmp(computer,'PCWIN')
            set(uilist,{'visible'},saveVis)
        end
    end

