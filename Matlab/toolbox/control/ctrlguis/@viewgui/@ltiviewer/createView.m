function View = createView(this,PlotType,varargin)
%CREATEVIEW  Creates one of the built-in LTI plots.

%   Authors: Kamesh Subbarao, Pascal Gahinet
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.36.4.5 $  $Date: 2004/04/10 23:14:37 $

% Create seed axes
Ax = axes('Parent',this.Figure,'Visible','off');

% Create @respplot instance
if strcmp(PlotType,'bodemag')
    PlotType = 'bode';
    Options = {'Tag','bodemag','PhaseVisible','off'};
else
    Options = {};
end
View = ltiplot(Ax,PlotType,this.InputNames,this.OutputNames,...
this.Preferences,'StyleManager',this.StyleManager,Options{:});
View.AxesGrid.EventManager = this.EventManager;
View.AxesGrid.LayoutManager = 'off';
View.DataExceptionWarning = 'off';

% Initialize plot's focus
LocalInitializeFocus(View,this.Preferences);

% Add one response per system
% RE: Define Viewer-specific DataFcn to derive data from lti sources
this.createResponse(View,this.Systems,this.Styles,varargin{:});
% Plot-specific additions
if strcmp(PlotType,'lsim')
    % Need to assign channnel names to existing system channels and map
    % inputs
    View.setInputWidth(length(this.InputNames)); % size the input response wrt viewer
    View.Input.ChannelName = this.InputNames;
    View.localizeInputs;
    set(View.Input,'Visible','on');
    [t,x0,u] = deal(varargin{1:3});
    setinput(View,t,u);
    if length(varargin)==4
        % Store the interpolation in the viewer input waveform
        View.Input.Context.Interpolation = varargin{4};
    end
    % Assign initial condition
    for k=1:length(View.Responses)
        if ~isempty(View.Responses(k).DataSrc)
            View.Responses(k).Context.IC = x0;
        end
    end  
elseif strcmp(PlotType,'initial')
    for k=1:length(View.Responses)
        if ~isempty(View.Responses(k).DataSrc)
            View.Responses(k).Context.IC = varargin{2};
        end
    end
end

% Add right-click menus
LocalAddPlotTypeMenu(this,View);
Menus = ltiplotmenu(View,PlotType);
lticharmenu(View,Menus.Characteristics,PlotType);

% Add listeners tracking imports and changes in System pool
L = [handle.listener(this,'SystemChanged',{@LocalSystemChanged View varargin{:}});...
    handle.listener(this,'ModelImport',{@LocalCheckException View})];
View.addlisteners(L)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     LISTENER CALLBACKS                             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%
% LocalSystemChanged
%%%%%%%%%%%%%%%%%%%%%%
function LocalSystemChanged(eventsrc,eventdata,View,varargin)
% Callback for 'SystemChanged' event.
this = eventdata.source;
Info = eventdata.data;
outNames  = Info.OutNames;
inNames   = Info.InNames;

% Delete responses associated with deleted sources
if ~isempty(Info.DelSys)
    r = find(View.Responses,'-not','DataSrc',[]);
    src = get(r,{'DataSrc'});
    [junk,ia,ib] = intersect(Info.DelSys,cat(1,src{:}));
    View.AxesGrid.LimitManager = 'off';
    for rr=r(ib)',
        View.rmresponse(rr);
    end
    View.AxesGrid.LimitManager = 'on';
end

% Adjust new I/O size to include user-added responses
NewSize = [length(outNames),length(inNames)];
LocalSize = NewSize;
for r=View.Responses'
    rSize = [length(r.RowIndex),length(r.ColumnIndex)];
    if any(rSize>NewSize)
        LocalSize = max(LocalSize,rSize);
        % Move to upper left corner
        r.RowIndex = 1:rSize(1);
        r.ColumnIndex = 1:rSize(2);
    end
end
if any(LocalSize>NewSize)
    % Increase I/O size computed from Systems list
    outNames(end+1:LocalSize(1)) = {''};
    inNames(end+1:LocalSize(2)) = {''};
end

% Resize plot
View.resize(outNames,inNames);

% Create responses for added systems
this.createResponse(View,Info.AddSys,Info.AddSysStyle,varargin{:});

% Special processing
if strcmp(View.Tag,'lsim')
    % Determine which subset of the input channels drives each response
    View.Input.ChannelName = this.InputNames; %Update channel names
    localizeInputs(View)
end

% Redraw view
draw(View)


%%%%%%%%%%%%%%%%%%%%%%
% LocalCheckException
%%%%%%%%%%%%%%%%%%%%%%
function LocalCheckException(eventsrc,eventdata,View,varargin)
% Creates warning when some imported systems cannot be plotted
if isempty(View.Responses)
    return
end
this = eventdata.source;
ImportedSystems = eventdata.data;  % new or modified data sources
% Find responses with these data sources
r = find(View.Responses,'-not','DataSrc',[]);
src = get(r,{'DataSrc'});
[junk,ia,ib] = intersect(cat(1,src{:}),ImportedSystems);
% Issue warning if some of these responses have exceptions
Exception = false;
for ct=1:length(ia)
    if ~isempty(find(r(ia(ct)).Data,'Exception',true))
        Exception = true;  break
    end
end
if Exception
   WarnHeader = {sprintf('At least one imported system cannot be shown in the plot');...
         sprintf('with title "%s"',View.AxesGrid.Title);''};
   WarnDetails = [];
   switch View.Tag
      case {'step','impulse'}
         WarnDetails = {...
               sprintf('Systems that cannot be shown in this plot include');...
               sprintf('FRD models and models with more zeros than poles.')};
      case 'initial'
         WarnDetails = {...
            sprintf('Only state-space models with the same number of states');...
            sprintf('as the initial condition X0 can be shown in this plot.')};
      case 'lsim'
         WarnDetails = {...
            sprintf('Systems that cannot be shown in this plot include');...
            sprintf('FRD models, models with more zeros than poles, and');...
            sprintf('models whose number of inputs or states is incompatible');...
            sprintf('with the specified input data U or initial condition X0.')};
      case {'pzmap','iopzmap'}
         WarnDetails = {sprintf('FRD models cannot be shown in pole/zero plots.')};
   end
   warndlg([WarnHeader;WarnDetails],'LTI Viewer Warning','modal');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     UTILITIES                             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%
% LOCALADDPLOTTYPEMENU
%%%%%%%%%%%%%%%%%%%%%%
function  LocalAddPlotTypeMenu(this,View)
% LOCALADDPLOTTYPEMENU adds the list of plot types
% to the right click menus of all the plots.

mRoot = uimenu('Parent', View.AxesGrid.UIcontextMenu,...
   'Label',xlate('Plot Types'),'Tag','PlotType');
% Available plot types
Names = ltiplottypes('Name');
Aliases = ltiplottypes('Alias');
% RE: initial may not be available
[junk,ia,ib] = intersect(Aliases,{this.AvailableViews.Alias});
ia = sort(ia);
Names = Names(ia);
Aliases = Aliases(ia);
% Create menus
for ct=1:length(Aliases)
   mSub(ct,1) = uimenu('Parent',mRoot,'Label',Names{ct},...
      'Tag',Aliases{ct},'Callback',{@LocalChecked this View});
end
set(mSub(strcmp(View.Tag,Aliases)),'Checked','on');

%%%%%%%%%%%%%%%%
% LOCALCHECKED %
%%%%%%%%%%%%%%%%
function LocalChecked(eventsrc,eventdata,this,View)
% Reacts to change in selected plot in Plot Types menu
% Switch view
NewView = this.switchView(View,get(eventsrc,'Tag'));
NewView.Visible = 'on';
% Update list of views
% REVISIT: 3->1
Views = this.Views;
Views(this.Views==View) = NewView;
this.Views = Views;
% Update status and notify clients
this.EventManager.newstatus('Plot type changed.');
this.send('ConfigurationChanged');

%%%%%%%%%%%%%%%%%%%%%%
% LocalInitializeFocus %
%%%%%%%%%%%%%%%%%%%%%%
function LocalInitializeFocus(View,Prefs)
% Applies the Focus to the View from the preferences.

t = Prefs.TimeVector;
if length(t)==1
   t = [0 t];
elseif length(t)>1
   t = [t(1) t(end)];
end
% RE: Use 'Time' flag to ensure time focus only applied to time plots
View.setfocus(t,'sec','Time');

f  = Prefs.FrequencyVector;
if iscell(f)
   f = [f{1} f{2}];
elseif length(f)>1
   f = [f(1) f(end)];
end
View.setfocus(f,Prefs.FrequencyUnits,'Frequency');
