function Frame = configframe(sisodb)
%CONFIGFRAME  Create feedback structure frame.
%
%   See also SISOTOOL.

%   Author(s): Karen D. Gondoly and P. Gahinet  
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.21.4.2 $  $Date: 2004/04/10 23:14:25 $

% Main figure
SISOfig = sisodb.Figure;
StdUnit = get(SISOfig,'Unit');

% Dimensions parameters
FigPos = get(SISOfig,'Position');
fHeight = 3.8;
fWidth = 25;
xBorder = 2.5;
X0 = FigPos(3)-(xBorder+fWidth);
Y0 = FigPos(4)-1-fHeight;

ConfigAxes = axes('Parent',SISOfig, ...
   'Units',StdUnit, ...
   'Box','on', ...
   'Color',[1 1 1], ...
   'Position',[X0 Y0 fWidth fHeight], ...
   'Tag','ConfigurationAxes', ...
   'XColor',[0 0 0], ...
   'XTickMode','manual', ...
   'YColor',[0 0 0], ...
   'YTickMode','manual', ...
   'ZColor',[0 0 0],...
   'Ylim',[0 1],...
   'Xlim',[0 .9],...
   'HelpTopicKey','feedbackstructure');

% Sign button
ChangeSign = uicontrol('Parent',SISOfig, ...
    'Units',StdUnit, ...
    'Position',[X0 Y0 4 1.2], ...
    'String','+/-', ...
    'TooltipString','Toggle feedback sign',...
    'Callback',{@LocalChangeSign sisodb},...
    'HelpTopicKey','feedbacksign');

% Configuration selector
bWidth = 4.5;
ChangeConfig = uicontrol('Parent',SISOfig, ...
    'Units',StdUnit, ...
    'Position',[X0+fWidth-bWidth Y0 bWidth 1.2], ...
    'String','FS', ...
    'TooltipString','Alter feedback structure',...
    'HelpTopicKey','feedbackstructure',...
    'Callback',{@LocalChangeConfig sisodb}',...
    'UserData',[1;2;3;4]);

% Install listener to (re)draw loop config
setappdata(ConfigAxes,'Listener',...
    handle.listener(sisodb.LoopData,findprop(sisodb.LoopData,'Configuration'),...
    'PropertyPostSet',{@ChangedConfigCB ConfigAxes sisodb}));

% Return frame
Frame = struct(...
    'ConfigAxes',ConfigAxes,...
    'ChangeSign',ChangeSign,...
    'ChangeConfig',ChangeConfig);


%---------------- Callback functions ---------------------

%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalChangeSign %%%
%%%%%%%%%%%%%%%%%%%%%%%
function LocalChangeSign(hSrc,event,sisodb)
% Callback for "change feedback sign" event

LoopData = sisodb.LoopData;
EventMgr = sisodb.EventManager;

% Start transaction
T = ctrluis.transaction(LoopData,'Name','Change Sign',...
    'OperationStore','on','InverseOperationStore','on');

% Update sign
LoopData.FeedbackSign = -LoopData.FeedbackSign;

% Register transaction and trigger update
EventMgr.record(T);
LoopData.dataevent('all');

% Update status bar and history
if LoopData.FeedbackSign>0
    Text = 'positive';
else
    Text = 'negative';
end
Status = sprintf('Now using %s feedback.',sprintf(Text));
EventMgr.newstatus(Status);
EventMgr.recordtxt('history',Status);

%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalChangeConfig %%%
%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalChangeConfig(hSrc,event,sisodb)
% Callback for "change feedback structure" event

LoopData = sisodb.LoopData;
EventMgr = sisodb.EventManager;

% List of available configurations
AvailConfigs = get(hSrc,'UserData');

% Next configuration
NewConfig = 1+rem(LoopData.Configuration,length(AvailConfigs));

% Start transaction
T = ctrluis.transaction(LoopData,'Name','Change Configuration',...
    'OperationStore','on','InverseOperationStore','on');

% Update configuration
LoopData.Configuration = AvailConfigs(NewConfig);

% Register transaction 
EventMgr.record(T);

% Trigger update
LoopData.dataevent('all');

% Update status bar and history
Status = 'The control structure has been changed.';
EventMgr.newstatus(Status);
EventMgr.recordtxt('history',Status);


%%%%%%%%%%%%%%%%%%%%%%%
%%% ChangedConfigCB %%%
%%%%%%%%%%%%%%%%%%%%%%%
function ChangedConfigCB(hSrcProp,event,ConfigAxes,sisodb)
% Redraws feedback configuration.

CurrentConfig = get(ConfigAxes,'UserData');
NewConfig = event.NewValue;

% Redraw configuration if it does not match currently drawn
if ~isequal(NewConfig,CurrentConfig)
    % Draw loop configuration
    Configuration = loopstruct(NewConfig,ConfigAxes);
    
    % Draw feedback sign and attach listener to LoopData.FeedbackSign
    LoopData = sisodb.LoopData;
    if LoopData.Configuration == 4
       hSignText = text(.15,.6,LocalGetSign(LoopData.FeedbackSign),...
          'Parent',ConfigAxes,'FontWeight','bold');
       text(.43,.66,'+','Parent',ConfigAxes,'FontSize',7,'Color',[0 0 0]);
    else
       hSignText = text(0.24,0.4,LocalGetSign(LoopData.FeedbackSign),...
          'Parent',ConfigAxes,'FontWeight','bold');
    end     
    set(hSignText,'UserData',...
       handle.listener(LoopData,findprop(LoopData,'FeedbackSign'),...
       'PropertyPostSet',{@ChangedSignCB hSignText}),...
       'HelpTopicKey','feedbacksign')
    
    % Set ButtonDownFcn's of the configuration
    set([Configuration.Plant;Configuration.Sensor],'ButtonDownFcn',{@LocalShowData sisodb});
    set(Configuration.Filter,'ButtonDownFcn',{@LocalEditComp sisodb 'F'});
    set(Configuration.Compensator,'ButtonDownFcn',{@LocalEditComp sisodb 'C'});
    
    % Set help topic key
    c = struct2cell(Configuration);
    set(cat(1,c{:}),'HelpTopicKey','feedbackstructure')
    
    % Store handles of configuration plot
    set(ConfigAxes,'UserData',NewConfig)  % store config # in axis UserData
end


%%%%%%%%%%%%%%%%%%%%%
%%% ChangedSignCB %%%
%%%%%%%%%%%%%%%%%%%%%
function ChangedSignCB(hSrcProp,event,hSignText)
% Update HG rendering of feedback sign
set(hSignText,'String',LocalGetSign(event.NewValue));


%%%%%%%%%%%%%%%%%%%%%
%%% LocalShowData %%%
%%%%%%%%%%%%%%%%%%%%%
function LocalShowData(hSrc,event,sisodb)
% Launch System Data view
sisodb.send('ShowData');


%%%%%%%%%%%%%%%%%%%%%
%%% LocalEditComp %%%
%%%%%%%%%%%%%%%%%%%%%
function LocalEditComp(hSrc,event,sisodb,ComponentID)
% Brings up Edit Compensator window
if ~(strcmp(get(sisodb.Figure,'Selectiontype'),'open'))
    PZEditor = sisodb.TextEditors(1);
    switch ComponentID
        case 'C'
            PZEditor.show(sisodb.LoopData.Compensator);
        case 'F'
            PZEditor.show(sisodb.LoopData.Filter);
    end
end

%-------------------------Helper Functions-------------------------

%%%%%%%%%%%%%%%%%%%%
%%% LocalGetSign %%%
%%%%%%%%%%%%%%%%%%%%
function SignText = LocalGetSign(Sign)

if Sign>0,
   SignText='+';
else
   SignText='-';
end
