function varargout = slsfnagctlr(varargin)
%SLSFNAGCTLR Simulink/Stateflow Error/Warning/Diagnostic and General Nag Controller.
%
%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.83.4.7 $

% Example use of this module to capture product specific diagnostics:
%
%    %
%    % begin of process that may incur errors, warnings, etc.
%    %
%    slsfnagctlr('Clear', 'yourModel', 'RTW Builder');
%
%    ...your code...
%
%    % an error is detected
%    if (hadAnError),
%        %
%        % compose a NAG (example of a Parse Error)
%        %
%        nag                =  slsfnagctlr('NagTemplate');
%        nag.type           = 'Error';                             % type of NAG (Error, Warning, Log, Diagnostic)
%        nag.msg.type       = 'Parse';                             % the type of message
%        nag.msg.details    = 'parse error in 'gain2' due to ...'; % your detailed message
%        nag.msg.summary    =  nag.msg.details;                    % typically, the same as details (will truncate)
%        nag.sourceFullName = 'yourModel/gain2';                   % complete path to the error source
%        nag.sourceName     = 'gain2';                             % blockName or modelName or stateName, etc.
%        nag.component      = 'RTW';                               % who's reporting this NAG
%
%        slsfnagctlr('Push', nag);
%    end;
%
%    ...your code...
%
%    %
%    % finished process, display pushed NAGs
%    %
%    slsfnagctlr('View');
%
%  prevLastErr = lasterr;

mlock;
try,

    %
    % Resolve input args
    %
    arg1 = [];
    args = {};
    switch nargin,
    case 0, arg1 = 'ViewNaglog';
    case 1, arg1 = varargin{1};
    otherwise,
        arg1 = varargin{1};
        args = varargin(2:end);
    end;

    %
    % Acquire current state structure
    %
    if isequal(arg1, 'Dismiss'),
        ss = get_ss_l('noConstruct');
        if isempty(ss),
            if nargout==1, varargout(1) = {[]}; end;
            return;
        end;
    else
        ss = get_ss_l;
    end;

    %|
    %| Broadcast Event / Process Command (control loop)
    %|
    switch ml_type_l(arg1, ss.sfIsHere),
    case 'string',
        ss.cmdEvent = arg1;
        ss = broadcast_cmd_event_l(ss, args{:});
    otherwise, warning('Invalid input passed to: slsfnagctlr()!');
    end;

    %
    % Store resultant state structure
    %
    set_ss_l(ss);

    %
    % Furnish requested output
    %
    if nargout==1
        varargout(1) = {ss.output};
    end
    
    %
    % Keep HG graphics live
    %
    if ~isfield(ss,'dasDiagViewer')
        drawnow; 
    end

catch,
    disp(sprintf('Error calling slsfnagctlr(''%s'',...)\n%s',arg1,lasterr));
end;
%  lasterr(prevLastError);


%---------------------------------------------------------------------------------
function ss = broadcast_cmd_event_l(ss, varargin)
%
%
%
  switch ss.cmdEvent,
   case 'Open',            ss = open_l(ss);
   case 'Cancel',          ss = dismiss_l(ss, 'hide', varargin{:}); 
   case 'Dismiss',         ss = dismiss_l(ss, 'destroy', varargin{:});
   case 'ObjectSelect',    ss = object_select_l(ss);
   case 'Clear',           ss = broadcast_in_collection_mode(ss,'ClearComponent',varargin);
   case 'ClearSimulation', ss = broadcast_in_collection_mode(ss,'ClearSimulation',varargin);
   case 'RestoreDetails',  ss = show_details_l(ss);
   case 'Rename',          ss = pre_namechange_l(ss, varargin{:});
   case 'Create',          ss = create_l(ss, varargin{:}); ss = broadcast_in_collection_mode(ss,'Create',varargin);
   case 'InfoHyperlink',   ss = info_hyperlink_l(ss);
   case 'Exit',            ss = exit_l(ss);
   case 'ViewNaglog',      ss = broadcast_in_collection_mode(ss,'ViewComponent',varargin); 
   case 'View',            ss = broadcast_in_collection_mode(ss,'ViewComponent',varargin);
   case 'ViewSimulation',  ss = broadcast_in_collection_mode(ss,'ViewSimulation',varargin);
   case 'NagTemplate',     ss = output_nag_template_l(ss);
   case 'Naglog',          ss = naglog_l(ss, varargin{:});
   case 'Push',            ss = naglog_l(ss, 'push', varargin{:});
   case 'PushSimMsg',     ss = push_sim_msg(ss, varargin{:});
   case 'NagToken',        ss = nagtoken_l(ss);
   case 'GetNags',         ss = get_nags_l(ss);
   case 'GetInfoTxt',      ss = get_infotxt_l(ss);
   case 'Resize',          ss = resize_l(ss);
   case 'yank_blanket',    ss = yank_blanket_l(ss);
   otherwise, % nada
    ss.cmdEvent,
    warning('Bad event sent to slsfnagctlr!');
    dbstack
    return;
  end;

ss.cmdEvent = ''; % consume event;


%----------------------------------------------------------------------------------
function ss = create_l(ss, varargin),
%
% Called only by Simulink to construct a Simulation Error Dialog.
% This call requires a stream of block errors to be processed.
%

%
% check for a valid nag controller, create one if necessary
%
if ~nagctlr_ui_exists_l(ss),
    ss = construct_ui_l(ss);
end

ss = dehilite_previously_hilit_blocks_l(ss);
ss.processingNags = logical(0);

%
% Check if the sfIsHere state has changed.
%
ss = stateflow_is_here_l(ss);

switch length(varargin),
case {0, 1},
    ss.model        = bdroot;
    ss.blkErrStream = lasterr;
otherwise,
    ss.model        = varargin{1};
    ss.blkErrStream = varargin{2};
end;

ss.interactionMode = 'Simulation';
ss.modelH          = get_param(ss.model, 'handle');

ss.prevHilitObjs = [];
ss.prevHilitClrs = [];

if ~isempty(ss.modelH) & ishandle(ss.modelH),
    ss.ShowLineWidthsOnError    = get_param(ss.modelH,'ShowLineWidthsOnError');
    ss.ShowPortDataTypesOnError = get_param(ss.modelH,'ShowPortDataTypesOnError');
end;
ss = process_block_error_stream_l(ss);
ss = update_simulation_title_l(ss);


%----------------------------------------------------------------------------------
function ss = exit_l(ss),
%
%
%

dismiss_l(ss, 'destroy');

%----------------------------------------------------------------------------------
function ss = push_sim_msg(ss, varargin),

nagTemplate = compose_a_template_nag_l;

b =  varargin{1};
nag = nagTemplate;
nag.component      = 'Simulink';
nag.sourceHId = b.Handle;
nag.type      = b.Type;
nag.sourceFullName   = strrep(getfullname(b.Handle),sprintf('\n'),' ');
nag.objHandles = b.Handle;
nag.msg.summary    = b.Message;       % Windows will truncate this nicely
nag.msg.details    = b.Message;
nag.sourceName = get_param(b.Handle,'name');
nag.msg.type = 'Block';

ss = naglog_l(ss, 'push', nag);
return;

%----------------------------------------------------------------------------------
function ss = process_stateflow_nags_l(ss),
%
%
%

%
% Fill out missing information (if possible)
%
for i=1:length(ss.nags),
    ss.nags(i) = process_this_stateflow_nag_l(ss.nags(i));
end;

%----------------------------------------------------------------------------------
function nag = process_this_stateflow_nag_l(nag),
%
%
%

%
% Fill out missing information (if possible)
%

switch nag.component,
case 'Stateflow',
    if ~isempty(nag.sourceHId) & (isempty(nag.sourceName) | strcmpi(nag.sourceName, 'unknown')),
        [nag.sourceFullName, nag.sourceName] = get_slsf_fullpath_and_name_l(nag.sourceHId);
    end;
otherwise,
end;



%----------------------------------------------------------------------------------
function ss = naglog_l(ss, varargin),
%
% API to underlying naglog module which controls access to the naglog file.
%
% To be safe, set and then get the ss, since
% if we're in memory mode, the state structure may change.
%
set_ss_l(ss);
output = naglog_cmd_l(ss, varargin{:});
ss = get_ss_l;


ss.output = output;



%----------------------------------------------------------------------------------
function ss = view_naglog_l(ss, title),
%
%
%
if nargin < 2,
    if isempty(ss.title), ss.title = 'Diagnostic Window (Control Design Solutions)'; end;
else, ss.title = title;
end;

ss = process_stateflow_nags_l(ss);
ss = compile_nags_into_listitems_l(ss);
ss = render_l(ss);
% Here insert yor code to show the new Diagnostic Viewer
% You will come in here when you have a SimulinkView mode
ss = show_sf_symbol_wiz(ss);

%------------------------------------------------------------------------------------
function  ss = show_sf_symbol_wiz(ss)

if(ss.sfIsHere & ~isempty(ss.modelH))
    machineId = sf('find','all','machine.simulinkModel',ss.modelH);
    if(~isempty(machineId))
        sf('Private','symbol_wiz','View',machineId);
    end
end

%------------------------------------------------------------------------------------
function ss = process_block_error_stream_l(ss),
%
%
%
if ~isempty(ss.blkErrStream)
    %
    % extract the blkerrors and corresponding handles
    %
    blkerrorHandles = { ss.blkErrStream(:).Handle };
    blkerrors       = { ss.blkErrStream(:).Message };
    type            = { ss.blkErrStream(:).Type };

    %
    % convert each error string into the appropriate MATLAB expression to examine
    % the object that issued the error
    %
    ss.processingNags = logical(1);
    ss = set_ss_l(ss);
    [nags, uploadNaglog] = parse_block_errors_l(blkerrors, blkerrorHandles, ss.sfIsHere, type);
    ss.processingNags = logical(0);
    ss = process_stateflow_nags_l(ss);
    % Here call the new Diagnostic Viewer
    if isfield(ss,'dasDiagViewer'),
        ss.dasDiagViewer.convertNagsToUDDObject(nags);
    end
    ss.nags = ss.nags(:);
    nags = nags(:);
    ss.nags = [ss.nags; nags];
end

%----------------------------------------------------------------------------------
function ss = output_nag_template_l(ss),
%
%
%
ss.output = compose_a_template_nag_l;


%----------------------------------------------------------------------------------
function nagTemplate = compose_a_template_nag_l
%
%
%
UK = 'Unknown';

nagTemplate.component                  = UK;  % Simulink, Stateflow, Physical Modeling, etc.
nagTemplate.type                       = '';  % Erorr, Warning, Diagnostic, etc.
nagTemplate.refDir                     = '';  % To be used by the file link resolver.
nagTemplate.msg.type                   = '';  % Parser, Coder, Builder, Block, etc.
nagTemplate.msg.details                = '';  % Formatted details string --will be renderd with fixed width font
nagTemplate.msg.summary                = '';  % description to be displayed in Summary/Description field
nagTemplate.msg.links                  = [];  % the hyperlinks info. This is a structure array.
nagTemplate.msg.preprocessedFileLinks  = 0;   % boolean to indicate nag msgs that have been preprocessed
nagTemplate.sourceFullName             = '';  % full pathname of source object
nagTemplate.sourceName                 = UK;  % name of source object
nagTemplate.sourceHId                  = '';  % handle or id for the source object
nagTemplate.objHandles                 = [];  % associated object handles
nagTemplate.openFcn                    = '';  % function to call when open operation is performed
nagTemplate.userdata                   = [];  % random info storage space
nagTemplate.ids                        = [];  % associated Statflow Objects --Stateflow specific
nagTemplate.parentSystemH              = [];  % Parent of the Stateflow Chart Block for this nag
nagTemplate.time                       = [];  % time stamp indicating exactly when the nag was logged
nagTemplate.blkHandles                 = [];

%------------------------------------------------------------------------------------
function [nags, readNaglog] = parse_block_errors_l(blkerrors, blkerrorHandles, sfIsHere, type),
%
% Parse given block errors into nag structures.
%
% A "nag" is a generalization of an anti-good message.  Various types exist in nature.  Examples
% of classic nags include: errors, warnings, diagnostics, and other generally negative type
% thingies.
%
nagTemplate = compose_a_template_nag_l;
nags = [];
readNaglog = 0;

%
% Snuff out tokenized errors generated by Stateflow's construct_error()
% routine.
% as elements are being stubbed out, we must do it
% in reverse order so that stubbing out one element doesnt
% change the indices of the unprocessed elements.
% this was causing ugly errors before.
for i=length(blkerrors):-1:1,
    err = blkerrors{i};
    err(err==10) = [];
    err = deblank(err);
    s = findstr_l(err, get_nagtoken_l);
    if ~isempty(s) & any(s),
        blkerrors(i) = [];
        blkerrorHandles(i) = [];
        readNaglog = 1;
    end;
end;

if length(blkerrors) > 0,
    clear nags; % so struct assignments don't fail (initializing nags to [] causes it
    % to be of type double which makes the parser fail when we try to assign
    % it to a struct (i.e., nags(i) = <struct>)
end;

%
% lasterr gets clobbered in here by calls to get_param, save
% and restore just to be nice
%
oldLastErr=lasterr;

if(sfIsHere)
    %%% sometimes Stateflow throws a single concatenated error message consisting
    %%% of multiple errors. we need to break them up before proceeding
    [blkerrors,blkerrorHandles] = LocalBreakUpSFErrorsIfNeeded(blkerrors,blkerrorHandles);
end

for i=1:length(blkerrors)
    err = blkerrors{i};
    lowerErr = lower(err);

    %
    % Check if it is a Stateflow error
    % Stateflow will parse the error, set the errorObject properties and
    % update the corresponding blkerrors cell
    %
    isSFError = 0;
    if sfIsHere,
        warningState = warning;
        warning('off', 'REGEXP:multibyteCharacters');

        [isSFError,sfIds,sfBlockPath,errType,strippedMsg,errMsg,openFcn,relevantBlockHandle,parentSystemH] = ...
            sf( 'Private','parse_error_msg', err,blkerrorHandles{i});
	warning(warningState);
        if ~isempty(sfIds),
            [fullSLSFPath, sfName] = get_slsf_fullpath_and_name_l(sfIds(1));
        else,
            if ~isempty(relevantBlockHandle),
                sfName = get_param(relevantBlockHandle, 'Name');
                fullSLSFPath = getfullname(relevantBlockHandle);
            else,
                fullSLSFPath = '';
                sfName = '';
            end;
        end;
    end

    if isSFError,
        % yes! it is a Stateflow error!
        if ~isempty(sfIds), id = sfIds(1);
        else, id = [];
        end;

        % Initialize error structure from template. Unused fields default
        % to empty.
        sfErrorStruct                   = nagTemplate;
        if(sf('Private','is_eml_chart',id))
           compName = 'Embedded MATLAB';
        else
           compName = 'Stateflow';
        end
        sfErrorStruct.component         = compName;
        sfErrorStruct.type              = 'Error'; %%%%%%%%%%%%%%%%% should parse this out later!!
        sfErrorStruct.msg.type          = errType;
        sfErrorStruct.msg.details       = errMsg;
        sfErrorStruct.msg.summary       = strippedMsg;
        sfErrorStruct.sourceFullName    = fullSLSFPath;
        sfErrorStruct.sourceHId         = id;
        sfErrorStruct.sourceName        = sfName;
        sfErrorStruct.objHandles        = relevantBlockHandle;
        sfErrorStruct.openFcn           = openFcn;
        sfErrorStruct.ids               = sfIds;
        sfErrorStruct.parentSystemH = parentSystemH;

        nags(i) = sfErrorStruct;

    else % it is not a stateflow error, so go ahead, do Simulink
        % For now, assume that the error is always in the first
        % object handle that is passed down with the error message
        errName = '';
        blocks  = [];
        try,
            blocks    = blkerrorHandles{i};
            errName   = strrep(getfullname(blocks(1)),sprintf('\n'),' ');
        end;

        if ~isempty(errName),
            %%% if this error is coming from the SFunction block contained
            %%% inside a Stateflow block, we must point to the parent block
            %%% instead of the SFunction block itself since it is not supposed
            %%% to be seen by users.
            parent = get_param(blocks(1),'Parent');
            if ~isempty(parent) &  strcmp(get_param(parent,'Type'),'block') & ...
                    strcmp(get_param(parent,'MaskType'),'Stateflow')
                errName = parent;
            end;
        else, errName = '';
        end;

        % Initialize error structure from template. Unused fields default to empty.
        slErrorStruct = nagTemplate;

        slErrorStruct.component      = 'Simulink';
        slErrorStruct.sourceFullName = errName;
        slErrorStruct.objHandles     = blocks;
        if ~isempty(blocks)
            slErrorStruct.sourceHId = blocks(1);
        else
            slErrorStruct.sourceHId = [];
        end
        slErrorStruct.type           = type{i};
        slErrorStruct.msg.summary    = err;       % Windows will truncate this nicely
        slErrorStruct.msg.details    = err;
        if ~isempty(blocks),  slErrorStruct.sourceName = get_param(blocks(1),'name');
        else,                    slErrorStruct.sourceName = 'Unknown';
        end;

        %
        % If there is no relevant block handle, then its probably a model error
        %
        if isempty(blocks) | strcmp(get_param(blocks(1),'Type'),'block_diagram')
            slErrorStruct.msg.type = 'Model';
        else
            if strcmp(get_param(blocks(1),'Type'),'block') & ...
                    ~strcmp(get_param(blocks(1),'iotype'),'none')
                slErrorStruct.msg.type = 'IO';
            else
                slErrorStruct.msg.type = 'Block';
            end;
        end;

        nags(i) = slErrorStruct;
    end;

end % for

%
% restore lasterr to what it was before we did anything
%
lasterr(oldLastErr);


%---------------------------------------------------------------------------------------------------
function  [newblkerrors,newblkerrorHandles] = LocalBreakUpSFErrorsIfNeeded(blkerrors,blkerrorHandles)
% This function takes the cell array of block errors and checks to see if
% any of the errors is a concatenation of multiple SF errors. If so,
% we break them up and present  extended versions of blkerrors and blkerrorHandles
% Note that we do this ONLY for Stateflow errors. This function wont get called
% if SF doesnt exist.

newblkerrors = {};
newblkerrorHandles = {};
for i=1:length(blkerrors)
    thisBlkError = blkerrors{i};
    thisBlkHandle = blkerrorHandles{i};
    [startIndices,endIndices] = findstr_l(thisBlkError,'\-\->Stateflow',1);
    if(isempty(startIndices))
        newblkerrors{end+1} = thisBlkError;
        newblkerrorHandles{end+1} = thisBlkHandle;
    else
        for j = 1:length(startIndices)
            errorStartIndex = startIndices(j)+3;
            if(j<length(startIndices))
                errorEndIndex = startIndices(j+1)-1;
            else
                errorEndIndex = length(thisBlkError);
            end
            newblkerrors{end+1} = thisBlkError(errorStartIndex:errorEndIndex);
            newblkerrorHandles{end+1} = thisBlkHandle;
        end
    end
end


%----------------------------------------------------------------------------------
function uiExists = nagctlr_ui_exists_l(ss)
%
%
%
uiExists = 1;
switch ss.renderMode,
case 'WINDOWS',
    ud = [];
    evalc('ud = nagctlr(''GetUserData'');','ud = [];');
    if isempty(ud),
        uiExists = 0;
    end

case 'HG',
    if isempty(ss.figH) | ~ishandle(ss.figH),
        uiExists = 0;
    end

case 'JAVA',%nada
end;


%----------------------------------------------------------------------------------
function ss = construct_l(ss, renderS),
%
%
%
switch nargin,
case 0, ss = default_ss_l;
case 1,
case 2, ss = extract_parameters_l(ss, renderS);
otherwise, error('bad number of args passed to constructor');
end;

switch ss.renderMode,
case 'WINDOWS',
    ss = compile_nags_into_listitems_l(ss);
case 'HG',
case 'JAVA',
end;

%
% check for a valid nag controller, create one if necessary
%
if ~nagctlr_ui_exists_l(ss),  ss = construct_ui_l(ss);  end

ss.prevHilitObjs = [];
ss.prevHilitClrs = [];


%-----------------------------------------------------------------------------------------
function ss = extract_parameters_l(ss, renderS),
%
%
%
switch ml_type_l(renderS, ss.sfIsHere),
case 'struct',
    if isfield(renderS, 'title')      ss.title  = renderS.title;    else, ss.title   = 'Output Window';  end;
    if isfield(renderS, 'nags')       ss.nags      = renderS.nags;     else, ss.nags    = [];               end;
    if isfield(renderS, 'infoTxt')    ss.infoTxt = renderS.infoTxt;  else, ss.infoTxt = [];               end;

    if ~isempty(ss.nags),
        if ~isstruct(ss.nags), arg_warn_l; return; end;

        for i=1:length(ss.nags),
            if ~nag_is_good_l(ss.nags(i)), arg_warn_l; return; end;
        end;
    end;
otherwise, arg_warn_l;
end;


%----------------------------------------------------------------------------------------
function ss = construct_ui_l(ss),
%
%
%

switch ss.renderMode,
case 'WINDOWS',
    nagctlr('BroadcastFcn', 'slsfnagctlr');
case 'HG',

    %
    % Most of the following was generated by Guide
    %
    backGroundColor = get(0,'defaultuicontrolbackgroundcolor');

    %
    % Calculate initial screen position
    %
    posWidth = 720 * ss.pointsPerPixel;
    posWidth = min(posWidth, ss.screenWidthInPoints * 0.9);

    posHeight = 450 * ss.pointsPerPixel;
    posHeight = min(posHeight, ss.screenHeightInPoints * 0.9);

    pos = [((ss.screenWidthInPoints - posWidth) / 2) ((ss.screenHeightInPoints - posHeight) / 2) posWidth posHeight];

    ss.figH = figure('Color',backGroundColor, ...
        'Units', 'Points',...
        'Position', pos,...
        'NumberTitle','off',...
        'MenuBar','none',...
        'IntegerHandle','off',...
        'HandleVisibility','off',...
        'Name',ss.title,...
        'Tag',tag_l,...
        'Resize','on',...
        'Vis','off',...
        'DeleteFcn', 'slsfnagctlr Exit',...
        'ResizeFcn', 'slsfnagctlr Resize',...
        'CloseRequestFcn','slsfnagctlr Dismiss');

    %top frame
    ss.hg.topFrameH = uicontrol('Parent',ss.figH, ...
        'Units','Points', ...
        'BackgroundColor',backGroundColor,...
        'Style','frame');

    %list box
    ss.hg.listBoxH = uicontrol('Parent',ss.figH, ...
        'Units','Points',...
        'Max',1,...
        'Style','listbox', ...
        'BackgroundColor',[1 1 1],...
        'Callback','slsfnagctlr ObjectSelect');

    %bottom frame
    ss.hg.bottomFrameH = uicontrol('Parent',ss.figH,...
        'style', 'frame',...
        'Units', 'Points', ...
        'backgroundcolor', backGroundColor);

    %labels
    ss.hg.sourceLabelH = uicontrol('Parent',ss.figH, ...
        'Units','Points', ...
        'HorizontalAlignment','left', ...
        'BackgroundColor',backGroundColor,...
        'String','Source(s) ', ...
        'Style','text');

    ss.hg.diagnosticLabelH = uicontrol('Parent',ss.figH, ...
        'Units','Points', ...
        'HorizontalAlignment','left', ...
        'BackgroundColor',backGroundColor,...
        'String','Diagnostic message ', ...
        'Style','text');

    % Edit text field
    ss.hg.editFieldH = uicontrol('Parent',ss.figH, ...
        'Units','Points', ...
        'BackgroundColor',[1 1 1], ...
        'Style','edit', ...
        'Enable','on',...
        'Max',2,...
        'Callback','slsfnagctlr RestoreDetails',...
        'HorizontalAlignment','Left',...
        'Tag','OpenText1');

    % Edit button
    ss.btns.openH = uicontrol('Parent',ss.figH, ...
        'Units','Points', ...
        'BackgroundColor',backGroundColor,...
        'String','Open',...
        'Callback','slsfnagctlr Open');

    % Cancel button
    ss.btns.cancelH = uicontrol('Parent',ss.figH, ...
        'Units','Points', ...
        'BackgroundColor',backGroundColor,...
        'String',xlate('Cancel'),...
        'Callback','slsfnagctlr Cancel');

    % ---Blanket----------------------------------------------------------------------------------------------

    ss.hg.blanket = uicontrol(          'Style',                'pushbutton',...
        'Parent',               ss.figH,...
        'Visible',              'off',...
        'FontWeight',           'bold',...
        'Units',                'Points',...
        'String',               sprintf('The window is too small'));
    ss.hg.minWidth = 154;
    ss.hg.minHeight = 290;

    ss = resize_l(ss);
case 'JAVA',
end;


%----------------------------------------------------------------------------------------
function ss = resize_l(ss),
%
%
%
if strcmp(ss.renderMode, 'HG')
    figureSize = get(ss.figH, 'Position');
    width = figureSize(3);
    height = figureSize(4);
    buffer = 7;
    listBoxHeight = 150;
    buttonHeight = 20;
    buttonWidth = 60;
    buttonSlough = (width - buttonHeight) / 2 - buffer - buttonWidth;

    % enforce minumum dimentions
    if (width < ss.hg.minWidth) | (height < ss.hg.minHeight)
        set(ss.hg.blanket, 'Position', [0 0 width height], 'Visible', 'on');
        set(ss.figH, 'WindowButtonMotionFcn', 'slsfnagctlr yank_blanket');
        return;
    else
        set(ss.hg.blanket, 'Visible', 'off');
        set(ss.figH, 'WindowButtonMotionFcn',  '');
    end

    %top frame
    set(ss.hg.topFrameH, 'Position', [(1 * buffer) (height - 4 * buffer - listBoxHeight) (width - 2 * buffer) (listBoxHeight + 2 * buffer)]);
    sourceLabelExtent = get(ss.hg.sourceLabelH, 'Extent');
    set(ss.hg.sourceLabelH, 'Position', [(2 * buffer) (height - 2 * buffer - sourceLabelExtent(4) / 2) sourceLabelExtent(3)  sourceLabelExtent(4)]);

    %list box
    set(ss.hg.listBoxH, 'Position',  [(2 * buffer) (height - 3 * buffer - listBoxHeight) (width - 4 * buffer) (listBoxHeight + 0 * buffer)]);

    %bottom frame
    set(ss.hg.bottomFrameH, 'Position', [(1 * buffer) (buttonHeight + 2 * buffer) (width - 2 * buffer) (height - listBoxHeight - buttonHeight - 8 * buffer)]);
    diagnosticLabelExtent = get(ss.hg.diagnosticLabelH, 'Extent');
    set(ss.hg.diagnosticLabelH, 'Position', [(2 * buffer) (height - listBoxHeight - 6 * buffer - diagnosticLabelExtent(4) / 2)  diagnosticLabelExtent(3) diagnosticLabelExtent(4)]);

    % Edit text field
    set(ss.hg.editFieldH, 'Position', [(2 * buffer) (buttonHeight + 3 * buffer) (width - 4 * buffer) (height - listBoxHeight - buttonHeight - 10 * buffer)]);

    % Edit button
    set(ss.btns.openH, 'Position', [(buffer + buttonSlough) buffer buttonWidth buttonHeight]);

    % Cancel button
    set(ss.btns.cancelH, 'Position', [(buffer + buttonSlough + buttonWidth + buttonHeight) buffer buttonWidth buttonHeight]);
end;


%---------------------------------------------------------------------------------------
% Hides the blanket and resizes the figure to it's minimum size.
%---------------------------------------------------------------------------------------
function ss = yank_blanket_l(ss)
%
position = get(ss.figH, 'Position');

position(3) = max(position(3), ss.hg.minWidth + 1);
if position(4) < ss.hg.minHeight
    position(2) = position(2) + position(4) - (ss.hg.minHeight + 1);
    position(4) = ss.hg.minHeight + 1;
end

set(ss.hg.blanket, 'Visible', 'off');
set(ss.figH, 'WindowButtonMotionFcn',  '', 'Position', position);


%---------------------------------------------------------------------------------------
function ss = default_ss_l
%
%

%
% Do some translations:
%
messageLabel = xlate('Message');
sourceLabel = xlate('Source');
fullpathLabel = xlate('Fullpath');
reportedLabel = xlate('Reported By');
summaryLabel = xlate('Summary');

ss.title                    = 'Uninitialized Diagnostic Window';
ss.componentName            = '';
ss.viewMode                 = 'ListInfo';
ss.splitMode                = 'TopBottom';
ss.interactionMode          = 'Idle'; % can be 'Idle', 'Simulation'
ss.nags                     = [];
ss.figH                     = [];
ss.model                    = [];
ss.modelH                   = [];
ss.ShowLineWidthsOnError    = [];
ss.ShowPortDataTypesOnError = [];
ss.prevHilitObjs            = [];
ss.prevHilitClrs            = [];
ss.listHeadings             = {messageLabel, sourceLabel,fullpathLabel, reportedLabel, summaryLabel}; % standard Design Automation Nag List Headings
ss.listItems                = {};
ss.infoTxt                  = ''; % text displayed
ss.links                    = [];
ss.output                   = [];
ss.collectionMode               = 'Idle'; %can be Idle or Component or Simulation
%Being in Component or Simulation means we are
%collecting messages for either simulation or a component
% ss.naglog.file              = init_naglog_l;
ss.processingNags           = logical(0);

ss.visible                  = 0;

units = get(0, 'Units');
set(0, 'Units', 'Pixels');
screenSize = get(0, 'ScreenSize');
pixelHeight = screenSize(4);
set(0, 'Units', 'Points');
screenSize = get(0, 'ScreenSize');
ss.screenWidthInPoints = screenSize(3);
ss.screenHeightInPoints = screenSize(4);
pointHeight = screenSize(4);
set(0, 'Units', units);
if pixelHeight == 0
    ss.pointsPerPixel = 1;
else
    ss.pointsPerPixel = pointHeight / pixelHeight;
end;

%
% setup default fonts
%
ss.defaultFontName          = get(0,'defaultuicontrolfontname');
ss.defaultFontSize          = max(10, get(0,'defaultuicontrolfontsize'));
ss.defaultFixedWidthName    = get(0,'fixedwidthfontname');
ss.defaultFixedWidthSize    = 10;

%
% Determine whether or not Stateflow is loaded/present
%
ss.sfIsHere = 0;
ss = stateflow_is_here_l(ss);

%
% Resolve render mode based on platform
%
% Add das diagnosticViewer
if isjava_l & ~isfield(ss,'dasDiagViewer'),
    ss.dasDiagViewer = DAStudio.DiagnosticViewer('DAS');
end;

if isjava_l,
    ss.renderMode = 'JAVA';
elseif ispc_l,
    ss.renderMode = 'WINDOWS';
    evalc('nagctlr(''Loaded'');', 'ss.renderMode = ''HG'';');
    if strcmp(ss.renderMode,'WINDOWS'),
        nagctlr('BroadcastFcn', 'slsfnagctlr');
    end
else,
    ss.renderMode = 'HG';
end;


%---------------------------------------------------------------------------------------
function ind = find_first_error_index_l(ss),
%
%
%
ind = -1;
for i=1:length(ss.nags),
    nag = ss.nags(i);
    if strcmpi(nag.type, 'Error'),
        ind = i;
        break;
    end;
end;


%---------------------------------------------------------------------------------------
function ss = render_l(ss),
%
%
%
set_ss_l(ss);
firstErrorInd = find_first_error_index_l(ss);
firstErrorInd = max(firstErrorInd, 1);
if ~isempty(ss.nags),
    nag = ss.nags(firstErrorInd);
    switch lower(nag.component),
    case 'stateflow',
        if strcmpi(nag.type,'error') & ~isempty(nag.sourceHId), sf('Open', nag.sourceHId); end;    % open the object for stateflow.
    otherwise,
    end;
end;
switch ss.renderMode,
case 'WINDOWS',
    nagctlr(ss);
    if ~isempty(ss.nags) & ~isequal(firstErrorInd, nagctlr('SelectedInd')),
        nagctlr('SelectItem', firstErrorInd); % zero based indexing in MEX-File.
    end;
    ss = get_ss_l;
case 'HG',
    %
    % replace any unknown objects with '<<Simulation Error>>'
    % this could happen for various reasons, for instance, an object type that
    % that reports an error isn't handled in the error parsing function
    %
    objectNames{1} = '<<unknown>>';
    for i=1:length(ss.nags),
        nag = ss.nags(i);
        objectNames{i} = [nag.sourceFullName, '   <<',nag.msg.type,' ',nag.type,'>>'];
    end;
    unknowns              = find( strcmp( objectNames, '' ) );
    objectNames(unknowns) = { '<<Simulation Error>>' };

    set(ss.hg.listBoxH, 'String',objectNames, 'Value', firstErrorInd);
    set(ss.figH, 'name', ss.title);

    ss = show_details_l(ss);
    ss = yank_blanket_l(ss);
    figure(ss.figH);
case 'JAVA',
    if (isfield(ss,'dasDiagViewer'))
        javahere = ss.dasDiagViewer.javaEngaged;
        if (~javahere)
            ss.dasDiagViewer.javaEngaged = 1;
        end
        % chack for visiblity of the diganostic viewer
        visib = ss.dasDiagViewer.isVisible;
	drawnow;
        if (~visib)
            ss.dasDiagViewer.Visible = 1;
        else
            ss.dasDiagViewer.synchronizeJavaViewer;
        end;
	% Set the model of the diagnostic viewer
	ss.dasDiagViewer.modelH = [ss.modelH];
	% Set the title of the diagnostic Viewer
        ss.dasDiagViewer.setTitle(ss.title);
    end
end;

ss.visible = 1;

%----------------------------------------------------------
function ss = broadcast_in_collection_mode(ss, event, vargin),

  mode = ss.collectionMode;

  switch mode,
   case 'Idle',
    switch event,
     case 'ViewComponent',
      % view things
      ss = view_naglog_l(ss,vargin{:});
     case 'ClearSimulation',
      ss.collectionMode = 'Simulation';
      %set title
      ss = clear_l(ss,vargin{:});
     case 'ClearComponent',
      ss.collectionMode = 'Component';
      % set Title
      % clear things
      ss = clear_l(ss,vargin{:});
     case 'Create',
      % view things if you have an error
      hasError = logical(0);
      for i = 1:length(ss.nags),
	nag = ss.nags(i);
	if ( isequal(lower(nag.type), 'error') |...
	  isequal(lower(nag.type), 'warning'))
	  hasError = logical(1);
	  break;
	end
      end
      if hasError,
	ss = view_naglog_l(ss, ss.title);
      end
     otherwise
      if slfeature('RTWTesting')
        fprintf(['\nslsfnagctlr: Event ''', event, ...
                 ''' is not handled when in mode ''', mode, '''\n']);
        dbstack
        %error(sprintf('\n\n'));
      end
    end;
   case 'Component',
    switch event,
     case 'ClearSimulation',
      ss.collectionMode = 'Simulation';
      %set title
      %clear the list
      ss = clear_l(ss,vargin{:});
     case 'ViewComponent',
      ss.collectionMode = 'Idle';
      % view things
      ss = view_naglog_l(ss,vargin{:});
     case 'ClearComponent'
      ss = clear_l(ss,vargin{:});
     otherwise
      if slfeature('RTWTesting')
        fprintf(['\nslsfnagctlr: Event ''', event, ...
                 ''' is not handled when in mode ''', mode, '''\n']);
        dbstack
        %error(sprintf('\n\n'));
      end
    end;
   case 'Simulation',
    switch event,
     case 'ClearSimulation',
      %set title
      %clear the list
      ss = clear_l(ss,vargin{:});
     case 'ViewSimulation',
      ss.collectionMode = 'Idle';
      % view things if you have an error
      hasError = logical(0);
      for i = 1:length(ss.nags),
	nag = ss.nags(i);
	if (isequal(lower(nag.type), 'error') |...
	  isequal(lower(nag.type), 'warning'))
	  hasError = logical(1);
	  break;
	end
      end
      if hasError,
	ss = view_naglog_l(ss,vargin{:});
      end
     otherwise
      %% xxx This code path is triggered when
      %%     slDisplaySimulationErrorsIfNecessary is called
      %%     inside Simulink code base
      %if slfeature('RTWTesting')
      %  fprintf(['\nslsfnagctlr: Event ''', event, ...
      %           ''' is not handled when in mode ''', mode, '''\n']);
      %  dbstack
      %  error(sprintf('\n\n'));
      %end
    end;
   otherwise
    fprintf(['\nFatal Error in slsfnagctlr: Illegal mode ''', mode, '''\n']);
    dbstack
    error(sprintf('\n\n'));
  end;

  set_ss_l(ss);

%----------------------------------------------------------
function ss = clear_component_l(ss, varargin),
%
ss = set_collect_msg_mode(ss, 'ClearComponent');

if (ss.collectMsg ~= 'Component')
    return;
end
ss = clear_l(ss, varargin);

%----------------------------------------------------------
function ss = clear_simulink_l(ss, varargin),
%
ss = set_collect_msg_mode(ss, 'ClearSimulink');

if (ss.collectMsg ~= 'Simulation')
    return;
end
ss = clear_l(ss, varargin);


%------------------------------------------------------------------------------------
function ss = clear_l(ss, varargin),
%
% Here you need to clean all the msgs from the new
% DiagnosticViewer

ss.processingNags = logical(0);
if (isfield(ss,'dasDiagViewer') == 1)
    ss.dasDiagViewer.flushMsgs;
end
oldLastErr = lasterr;

%
% Check if the sfIsHere state has changed.
%
ss = stateflow_is_here_l(ss);

%
% Dehilite blocks
%
ss = dehilite_blocks_l(ss);


%
% resolve new name
%
switch nargin,
case 1,
    ss.model  = '';
    ss.modelH = [];
case 2,
    prevLastErr = lasterr;
    try,
        ss.model  = varargin{1};
        ss.modelH = get_param(ss.model, 'handle');
        ss        = update_simulation_title_l(ss);
    catch,
        lasterr(prevLastErr);
        ss.model = '';
        ss.modelH =[];
    end;
case 3,
    %
    % must be a call with a title
    %
    prevLastErr = lasterr;
    try,
        ss.model  = varargin{1};
        ss.modelH = get_param(ss.model, 'handle');
        ss.title  = [varargin{2}, ': ', ss.model];
        ss.componentName = varargin{2};
    catch,
        lasterr(prevLastErr);
        ss.model = '';
        ss.modelH =[];
    end;
otherwise, error('bad num args passed to slsfnagctlr(''Cleaer'',...)');
end;


%
% Reset lasterr in case an error occured during try
%
lasterr(oldLastErr);

ss.nags               = [];
ss.listItems          = [];
ss.infoTxt            = '';
switch ss.renderMode,
case 'WINDOWS',
    nagctlr('CLEAR', ss.title);
    nagctlr('DisableOpen');
case 'HG'
    if isfield(ss,'hg'),
        set(ss.hg.listBoxH, 'String', {}, 'Value', 1);
        set(ss.hg.editFieldH, 'String', '');
        set(ss.btns.openH,'Enable','off');
        set(ss.figH, 'name', ss.title);
    end
case 'JAVA',
end;

ss.nags = [];

%-----------------------------------------------------------------------------------
function ss = object_select_l(ss),
%
%
%
ss = show_details_l(ss);
switch ss.renderMode,
case 'HG',
    switch lower(get(ss.figH, 'selectiontype')),
    case 'open',
        ss.cmdEvent = 'Open';
        ss = broadcast_cmd_event_l(ss);
    end;
case 'WINDOWS', % nada
case 'JAVA', %nada
end;


%-----------------------------------------------------------------------------------
function ss = show_details_l(ss),
%
%
%
OpenEnable = 'off';

wrappingOn = 0;

selectInd  = get_selected_ind(ss);
if ~isempty(selectInd),
    nag = ss.nags(selectInd);
    ss.infoTxt = nag.msg.details;

    switch nag.msg.type,
    case {'Lex', 'Coder', 'Make'}, wrappingOn = 0;
    otherwise, wrappingOn = 1;
    end;

    try,
        switch nag.component,
        case 'Stateflow',
            if ~isempty(nag.openFcn ) | ~isempty(nag.parentSystemH), OpenEnable = 'on'; end;
        case {'Simulink','RTW'},
            OpenEnable = 'on';
        otherwise,
            if ~isempty(nag.openFcn ),  OpenEnable = 'on'; end;
        end;
    end;

    switch ss.renderMode,
    case 'WINDOWS',
        if (~nag.msg.preprocessedFileLinks)
            nag = preprocess_file_links_l(nag);
        end
        ss.nags(selectInd) = nag;
        ss.infoTxt = nag.msg.details;
        nagctlr('InfoTxt', ss.infoTxt, wrappingOn);
        switch nag.msg.type,
        case {'Lex', 'Parse', 'Coder', 'Make', 'Build'},
            nagctlr('InfoFont', ss.defaultFixedWidthName, ss.defaultFixedWidthSize);
        otherwise,
            nagctlr('InfoFont', ss.defaultFontName, ss.defaultFontSize);
        end;
        switch OpenEnable,
        case 'on',  nagctlr('EnableOpen');
        case 'off', nagctlr('DisableOpen');
        end;

        switch nag.msg.type,
        case {'Lex', 'Parse'}, findFiles = 0;
        otherwise,             findFiles = 1;
        end;

        [s, e, types] = find_links_l(nag.msg.details, ss.sfIsHere, findFiles, nag);

        if ~isempty(s),
            ss.links.mbOffset = cumsum(nag.msg.details > 255);
            ss.links.mbOffset = ss.links.mbOffset(:); % force to a column so dimensions match with s & e
            ss.links.s     = s + ss.links.mbOffset(s);
            ss.links.e     = e + ss.links.mbOffset(e);
            ss.links.uniS  = s;
            ss.links.uniE  = e;
            ss.links.types = types;

            set_ss_l(ss); % need to set here so that nagctlr's user data is up to date.
            % This should change Mehran
            nagctlr('UpdateHyperLinks');
        else,
            ss.links.s     = [];
            ss.links.e     = [];
            ss.links.uniS  = [];
            ss.links.uniE  = [];
            ss.links.types = [];
        end;
    case 'HG',
        renderTxt = ss.infoTxt;
        set(ss.hg.editFieldH, 'String', renderTxt);
        set(ss.btns.openH,'Enable', OpenEnable);
    end;

    if isfield(nag, 'objHandles')
        ss = hilite_blocks_l(ss, nag.objHandles);
    end;

else,
    %
    % No nags selected, so just render infoTxt
    %
    switch ss.renderMode,
    case 'WINDOWS',
        nagctlr('InfoTxt', '', wrappingOn);
        switch OpenEnable,
        case 'on',  nagctlr('EnableOpen');
        case 'off', nagctlr('DisableOpen');
        end;
        [s, e, types] = find_links_l(ss.infoTxt, ss.sfIsHere, 1);
        if ~isempty(s),
            ss.links.mbOffset = cumsum(ss.infoTxt > 255);
            ss.links.mbOffset = ss.links.mbOffset(:); % force to a column so dimensions match with s & e
            ss.links.s     = s + ss.links.mbOffset(s);
            ss.links.e     = e + ss.links.mbOffset(e);
            ss.links.uniS  = s;
            ss.links.uniE  = e;
            ss.links.types = types;
            set_ss_l(ss);
            for i=1:length(s),
                nagctlr('SetExtentToLink', [s(i) e(i)]);
            end;
        else,
            ss.links.s     = [];
            ss.links.e     = [];
            ss.links.uniS  = [];
            ss.links.uniE  = [];
            ss.links.types = [];
        end;
    case 'HG',
        %
        % This is not allowed, but lets try to be nice
        %
        warning('Trying to use slsfnagctlr() InfoView in HG render mode...this is not supported!');
        set(ss.hg.editFieldH, 'String', ss.infoTxt);
        set(ss.btns.openH,'Enable', OpenEnable);
    end;
end;


%----------------------------------------------------------------------------------
function ss = open_l(ss),
%
%
%
selectInd  = get_selected_ind(ss);
if isempty(selectInd), return; end;

nag = ss.nags(selectInd);

blockH = [];

if ~isempty(nag.openFcn)
    try,
        eval(nag.openFcn);
    catch,
        disp('Error calling custom callback');
    end;
else,

    if ~isempty(nag.objHandles),
        blockH = nag.objHandles(1);
        hilite_blocks_l(ss, nag.objHandles);
    else,
        if ~isempty(nag.sourceHId),
            switch ml_type_l(nag.sourceHId, ss.sfIsHere),
            case 'sl_handle', open_system(nag.sourceHId, 'force');
            case 'sf_handle', sf('Open', nag.sourceHId);
            otherwise,
            end;
        else,
            if ~isempty(nag.sourceFullName),
                try, open_system(nag.sourceFullName); end;
            end;
        end;
    end;

    %
    % Open the selected Object
    %
    switch nag.component,
    case 'Simulink',
        if ~isempty(blockH),
            try, open_block_and_parent_l(blockH); end; % try
        end;
    case 'Stateflow',
        if ~isempty(blockH) open_system(blockH); end;
        if ~isempty(nag.sourceHId), sf('Open', nag.sourceHId); end;
    end;

end;


%-----------------------------------------------------------------------------------
function open_block_and_parent_l(blockH),
%
% Open block and parent
%
switch get_param(blockH, 'Type'),
case 'block',
    parentH = get_param(blockH,'Parent');
    % Check if block still exists (not in undo stack only)
    checkBlks = find_system(parentH, 'SearchDepth', 1, ...
        'FollowLinks', 'on', ...
        'LookUnderMasks', 'on', ...
        'Handle', blockH);
    if ~isempty(checkBlks)
        deselect_all_blocks_in_l(parentH);
        hilite_system(blockH)
    end
case 'block_diagram', open_system(blockH);
otherwise,
end;


%-----------------------------------------------------------------------------------
function ss = hilite_blocks_l(ss, blockHandles),
%
% Dehilits the previously hilit blockhandle and hilits the new one.
%
%
% if the last block hilit was you, just return;
%
hiliteH = blockHandles;
ss      = dehilite_previously_hilit_blocks_l(ss);

oldLastErr = lasterr;  % cache lasterr

for bidx = 1:length(hiliteH)
    blockH = hiliteH(bidx);

    isABlock = strcmp(get_param(blockH, 'Type'),'block');

    % Set the hiliting of new error ON
    try,
        if isABlock
            ss.prevHilitObjs(end+1) = blockH;
            ss.prevHilitClrs{end+1} = get_param(blockH,'HiliteAncestors');
            hilite_system(blockH,'error');
        end;
    end;
end

% Restore lasterr
lasterr(oldLastErr);

%-----------------------------------------------------------------------------------------
function deselect_all_blocks_in_l(sysH),
%
%
%
selectedBlocks = find_system(sysH, 'SearchDepth', 1, 'Selected', 'on');
for i = 1:length(selectedBlocks), set_param(selectedBlocks{i},'Selected','off'); end;


%----------------------------------------------------------------------------------------
function ss = dismiss_l(ss, hideOrDestroy, model),
%
%
%
oldLastErr = lasterr;

if nargin > 1,
    try,
        modelH = get_param(model, 'handle');
        if ~isequal(modelH, ss.modelH),
            return;
        end;
    end;
end;

switch ss.renderMode,
case 'JAVA',
    if isfield(ss,'dasDiagViewer')
        ss.dasDiagViewer.Visible = 0;
    end;
case 'WINDOWS',
    nagctlr('CLOSE');

case 'HG',
    try,
        switch hideOrDestroy,
        case 'hide'
            set(ss.figH, 'vis','off');
        case 'destroy'
            delete(ss.figH);
        end
    end;
    ss.figH = [];
end;

try,

    switch ss.interactionMode,
    case 'Simulation',
        modelH = ss.modelH;

        %
        % Restore the state of linewidths and port data types
        % display t o how it was before the error occured.
        %
        if strcmp(ss.ShowLineWidthsOnError,'on')
            % We have to toggle this parameter to reset an internal flag
            % to show line widths in the case of an error
            set_param(modelH,'ShowLineWidthsOnError','off');
            set_param(modelH,'ShowLineWidthsOnError','on');
        end;
        if strcmp(ss.ShowPortDataTypesOnError,'on')
            % We have to toggle this parameter to reset an internal flag
            % to show line widths in the case of an error
            set_param(modelH,'ShowPortDataTypesOnError','off');
            set_param(modelH,'ShowPortDataTypesOnError','on');
        end;
    case 'Idle',
    end;
    ss = dehilite_blocks_l(ss);
end;
ss.visible = 0;

% Reset lasterr in case an error occured during try
lasterr(oldLastErr);


%-------------------------------------------------------------------------------------
function ss = dehilite_previously_hilit_blocks_l(ss),
%
%
%
for bidx = 1:length(ss.prevHilitObjs)
    blockH   = ss.prevHilitObjs(bidx);
    blockClr = ss.prevHilitClrs{bidx};
    if ishandle(blockH),
        try, set_param(blockH,'HiliteAncestors',blockClr); end;
    end;
end
ss.prevHilitObjs = [];
ss.prevHilitClrs = [];

%--------------------------------------------------------------------------------------
function ss = dehilite_blocks_l(ss),
%
%
%
ss = dehilite_previously_hilit_blocks_l(ss);
sysH = ss.modelH;

if ~ishandle(sysH), return; end;

set_param(sysH, 'HiliteAncestors', 'off');

%------------------------------------------------------------------------------------
function ss = set_ss_l_non_java(ss),
%
% Store state structure
%
switch ss.renderMode,
case 'WINDOWS', nagctlr('SetUserData', ss);
case 'HG', if ishandle(ss.figH), set(ss.figH, 'userdata', ss); else ss.figH = []; end;
end;

%-------------------------------------------------------------------------------------
function ss = get_ss_l_non_java(constructFlag),
%
% Get state structure
%
ss = [];

%
% On the PC, look for the nagctlr module
%
if ispc_l,
    try,
        failed = 0;
        evalc('ss = nagctlr(''GetUserData'');','failed = 1;');
        if ~failed,
            if ~isempty(ss),
                return;
            else,
                if nargin==0, ss = construct_l; end
            end;
            return;
        end;
    end;
end;

%
% nagctlr isn't here, look for HG figure
%
fig = findall(0, 'type','figure', 'tag', tag_l);
switch length(fig),
case 0,
case 1, ss = get(fig,'userdata'); 
      if (isempty(ss)),
         set(fig,'closerequestfcn','','deletefcn','','tag','');
         %delete(fig);
         ss = construct_l;
      end;  
      return;
otherwise,
    warning('Multiple nag controllers found!');
    delete(fig);
end;

% No state structure found ==> construct a default
if nargin==0, ss = construct_l; end;


%-----------------------------------------------------------------------------------------------------------------------------
function ss2 = ss_l(arg),
persistent ss;

% Decide what mode you are in
% you can be in get, set and no-construct get
if (nargin == 0 | ischar(arg)),
    operation = 'GET';
else,
    operation = 'SET';
end;

% Switch based on the type of operation
switch operation,
case 'GET',
    ss2 = ss;
    % For a situation where are trying to get the ss simply return
    % the one that we have ot get it from the ddl
    if (isempty(ss))
        if (nargin == 0)
            ss2 = construct_l;
            ss = ss2;
        end;
        return
    end;

case 'SET', % This is the case for setting the ss structure

    % always set the persistent structure to be the same as
    % the one passed in
    ss = arg;
end
%-------------------------------------------------------------------------------------
function ss = set_ss_l(ss),
%
% Store state structure
% by calling the ss_l function

if (isjava_l)
    ss_l(ss);
else
    set_ss_l_non_java(ss);
end;
%-------------------------------------------------------------------------------------
function ss = get_ss_l(constructFlag),
%
% Get state structure by calling the ss_l function
%
switch (isjava_l)
case 1,
    if nargin == 0,
        ss = ss_l;
    else,
        ss = ss_l(constructFlag);
    end;
case 0,
    if (nargin == 0)
        ss =  get_ss_l_non_java;
    else
        ss = get_ss_l_non_java(constructFlag);
    end;

end
%-------------------------------------------------------------------------------------
function tag = tag_l
%
%
%
tag = '_SLSFNAGCTLR_';


%-------------------------------------------------------------------------------------
function [theType, conflict] = ml_type_l(obj, sfIsHere),
%ml_type_l  Extracts the type of the given input wrt standard MATLAB types,
%         HG, Simulink, and Stateflow handles.  Handle conflicts between
%         Stateflow and Simulink or Stateflow and HG are detected if requested.
if nargin < 2, sfIsHere = stateflow_is_here_l; end;

theType = 'unknown';
conflict = logical(0);
if iscell(obj),       theType = 'cell';               return; end;
if isobject(obj),
    theType = 'object';
    switch(class(obj)),
    case 'activex', theType = 'activex';
    end;
    return;
end;

if ischar(obj),          theType = 'string';  return; end;
if islogical(obj), theType = 'bool';  return; end;
if isstruct(obj),  theType = 'struct';        return; end;

%
% Resolve handle (Stateflow handles take precedence if it is present).
%
if isnumeric(obj),
    if ~isempty(obj),
        if (sfIsHere & obj==fix(obj) & sf('ishandle', obj)),
            theType = 'sf_handle';
            if (nargout < 2), return; end;
        end;
        if ishandle(obj),
            if ~is_simulink_handle(obj),
                if nargout > 1 & strcmp(theType, 'sf_handle'), conflict = logical(1);
                else, theType = 'hg_handle';
                end
                return;
            else,
                if nargout > 1 & strcmp(theType, 'sf_handle'), conflict = logical(1);
                else, theType = 'sl_handle';
                end;
                return;
            end;
        end;
    end;

    theType = 'numeric';
end;


%-------------------------------------------------------------------------------------
function selectInd = get_selected_ind(ss),
%
%
%
switch ss.renderMode,
case 'HG', selectInd = get(ss.hg.listBoxH, 'value');
case 'WINDOWS',
    selectInd = [];
    if length(ss.listItems) > 0,
        selectInd = nagctlr('SelectedInd');
        if selectInd <1, selectInd = []; end;
    end;
case 'JAVA',
end;


%-------------------------------------------------------------------------------------
function ss = pre_namechange_l(ss, varargin),
%
% This event only comes from Simulink when the model's name is about to change from
% varargin{1} to varargin{2}.
%
ss.model = varargin{2};

% Set the default visibility to be zero
visib = 0;

ss = update_simulation_title_l(ss);
switch ss.renderMode,
 case 'JAVA',
  if isfield(ss,'dasDiagViewer')
    visib = ss.dasDiagViewer.Visible;
  end;
 otherwise,
  visib = ss.visible;
end

% Only if the nag controller is visible. show it
if (visib == 1)
    ss = render_l(ss);
end

%-------------------------------------------------------------------------------------
function ss = update_simulation_title_l(ss),
%
%
%
ss.title = [xlate('Simulation Diagnostics: '), ss.model];

%-------------------------------------------------------------------------------------
function ss = stateflow_is_here_l(ss),
%
% Determines if Stateflow is present at runtime.
%
newsfIsHere = 0;
if ss.sfIsHere,
    [mf, mexf] = inmem;
    newsfIsHere = any(strcmp(mexf,'sf'));
else,
    if exist(['sf.', mexext],'file'),
        [mf, mexf] = inmem;
        newsfIsHere = any(strcmp(mexf,'sf'));
    end;
end;

if ~isequal(ss.sfIsHere, newsfIsHere), ss.sfIsHere = newsfIsHere; end;


%-------------------------------------------------------------------------------------
function ss = compile_nags_into_listitems_l(ss),
%
%
%
ss.listItems = {};

for i=1:length(ss.nags),
    nag = ss.nags(i);

    if ~nag_is_good_l(nag), arg_warn_l; return; end;

    nag.msg.details = [nag.msg.details, ' ']; % append space to ALL details so that indicies calculation don't fail
    ss.nags(i) = nag;

    switch lower(nag.type),
    case 'error',                       icon = 1; % red
    case 'warning',                     icon = 2; % gray
    case {'log', 'info', 'diagnostic'}, icon = 3; % blue
    case 'internal',                    icon = 4; % black
    otherwise,                          icon = 0; % queston mark
    end;

    ss.listItems{i} = { icon, [nag.msg.type,32,nag.type], nag.sourceName, nag.sourceFullName, nag.component, nag.msg.summary};
end;


%-------------------------------------------------------------------------------------
function isGood = nag_is_good_l(nag),
%
%
%
isGood = 0;

if ~isstruct(nag) return; end;

if ~isfield(nag, 'type') | ...
        ~isfield(nag, 'msg') | ...
        ~isfield(nag, 'component') | ...
        ~isfield(nag, 'sourceFullName'),
    return;
end;

if ~isstruct(nag.msg) | ...
        ~isfield(nag.msg, 'type') | ...
        ~isfield(nag.msg, 'summary') | ...
        ~isfield(nag.msg, 'details'),
    return;
end;

isGood = 1;


%-----------------------------------------------------------------------
function arg_warn_l
%
%
%
warning ('Incorrect or poorly formed arguments passed to slsfnagctlr()!');



%--------------------------------------------------------------------------------------------
function [fullSLSFPath, sfName] = get_slsf_fullpath_and_name_l(id),
%
%
%
fullSLSFPath     = '';
sfName           = '';

switch ml_type_l(id, 1), case 'sf_handle', otherwise, return; end;

MACHINE     = sf('get', 'default', 'machine.isa');
CHART       = sf('get', 'default', 'chart.isa');
STATE       = sf('get', 'default', 'state.isa');
JUNCTION    = sf('get', 'default', 'junction.isa');
TRANSITION  = sf('get', 'default', 'transition.isa');
EVENT       = sf('get', 'default', 'event.isa');
DATA        = sf('get', 'default', 'data.isa');
TARGET      = sf('get', 'default', 'target.isa');

switch sf('get', id, '.isa'),
case {MACHINE, CHART, STATE, EVENT, DATA, TARGET},
    sfName       = sf('get', id, '.name');
    fullSLSFPath = sf('FullNameOf', id, '.');
case JUNCTION,
    sfName       = ['Junct(#',int2str(id),')'];
    parent       = sf('get', id, '.linkNode.parent');
    fullSLSFPath = [sf('FullNameOf', parent, '.'), '.', sfName];
case TRANSITION,
    sfName       = ['Trans(#',int2str(id),')'];
    parent       = sf('get', id, '.linkNode.parent');
    fullSLSFPath = [sf('FullNameOf', parent, '.'), '.', sfName];
otherwise, error('bad type passed to get_slsf_fullpath_and_name_l().');
end;



%--------------------------------------------------------------------------
function [s, e] = findstr_l(stream,pattern,multiple),
%
%
%
if nargin<3, multiple=0; end
if length(stream)<length(pattern)
    if multiple
        s=[]; e=[];
    else
        s=0; e=0;
    end
    return;
end
s = findstr(stream,pattern);
e = s;
if ~isempty(s)
    e = s+length(pattern)-1;
end
if (multiple==0)
    if isempty(s)
        s=0; e=0;
    else
        s=s(1); e=e(1);
    end
end

%----------------------------------------------------------------------------
function goto_sf_object(id),
%
%
%
try,
    switch ml_type_l(id), case 'sf_handle', sf('Open',id); end;
end;


%------------------------------------------------------------------------------------
function ss = info_hyperlink_l(ss),
%
%
%

if isempty(ss.links) | ~isfield(ss.links, 's'), return; end;

hitInd = nagctlr('GetInfoLinkInd');

if isempty(hitInd) | hitInd < 1 | hitInd > length(ss.links.s), return; end;

startInd = ss.links.uniS(hitInd) + 1;
endInd   = ss.links.uniE(hitInd);

listSelectInd = nagctlr('SelectedInd');

nagHasPreprocessedLinks = 0;

if isempty(listSelectInd),
    if isempty(ss.infoTxt), return; end;
    txt = ss.infoTxt(startInd:endInd);
else,
    nag = ss.nags(listSelectInd);
    txt = nag.msg.details(startInd:endInd);
    nagHasPreprocessedLinks = nag.msg.preprocessedFileLinks;
end;

switch ss.links.types{hitInd},
case 'id',
    txt(1) = [];        % remove beginning #
    id = str2num(txt);
    sf('Open', id);
case 'txt',
    txt([1 end]) = [];  % remove quotes

    %
    % if this is a reference to dir, open a shell there,
    % otherwise, just edit the file.
    %
    switch(exist(txt)),
    case 7,
        if ispc_l,
            curDir = pwd;
            prevLastErr = lasterr;
            try,
                cd (txt);
                if sf('RunningWin95'), cmd = ['command.com &'];
                else,                  cmd = ['cmd /c start',10];
                end;
                dos(cmd);
                cd(curDir);
            catch,
                lasterr(prevLastErr);
                cd(curDir);
            end;
        end;
    otherwise,
        if nagHasPreprocessedLinks
            for i=1:length(nag.msg.links)
                if (startInd>=nag.msg.links(i).si-1 & endInd<=nag.msg.links(i).ei+1)
                    edit(nag.msg.links(i).file);
                    break;
                end
            end
        else
            edit(txt);
        end
    end;
case 'dir', % WISH to use this when dir types are implemented in nagctlr.dll
    txt([1 end]) = [];  % remove quotes
    dos(['start /D', txt]);
case 'mdl',
    txt([1 end]) = [];  % remove quotes
    try,
        blockH = get_param(txt, 'handle');
        open_block_and_parent_l(blockH);
    end;
end;


%--------------------------------------------------------------------------
function [S, E, linkTypes] = find_links_l(stream, sfIsHere, findFiles, nag)
%
%
%
S = [];
E = [];
linkTypes = {};
numFound = 0;

if ~ischar(stream), error('bad input'); end;
if nargin < 4, nag=[]; end;

prevLastErr = lasterr;
try,
    %
    % match standard Stateflow Ids
    %
    pattern = '\#\d+';
    [sv,ev] = regexp(stream, pattern);
    for i=1:length(sv),
        s = sv(i);
        e = ev(i);
        if s>0 & s<e,
            S = [S;s];
            E = [E;e];
            linkTypes{numFound+1} = 'id';
            numFound = numFound + 1;
        end;
    end;

    if findFiles & ~isempty(nag) & nag.msg.preprocessedFileLinks & ~isempty(nag.msg.links)
        % all the file links should be preprocessed so we should do it
        % again! Instead just return the preprocessed links
        s = [nag.msg.links(:).si]';
        S = [S;s-1];

        e = [nag.msg.links(:).ei]';
        E = [E;e+1];
        linkTypes = {linkTypes{:},nag.msg.links(:).type};
    elseif findFiles
        %
        % match file/system paths in double or single quotes
        %
        [sv,ev] = find_quoted_patterns_l( stream );
        for i=1:length(sv),
            s = sv(i);
            e = ev(i);
            if s>0 & s<e,
                si = s+1;
                ei = e-1;
                if si<ei,
                    txt = stream(si:ei);
                    [isFile, fileType] = is_a_file_l(txt);
                    if isFile,
                        S = [S; s];
                        E = [E; e];
                        linkTypes{numFound+1} = fileType;
                        numFound = numFound + 1;
                    end;
                end;
            end;
        end;
    end;
catch
    lasterr(prevLastErr);
    %%%% Error in hyperlink detection %%%% do not display thiss
end;

if ~isempty(S),
    S = S - 1;
    if any(S < 0) error('bad'); end;
end;


%--------------------------------------------------------------------------
function goodExt = file_has_good_extension(file),
%
%
%
goodExt = 1;

if length(file) > 4,
    if strcmp(file(end-3),'.'),
        ext = file((end-2):end);
        switch ext,
        case {'exe', 'dll', 'obj', 'lib', 'ilk', 'mat', 'fig', 'exp', 'res', 'zip'}, % add to exclude
            goodExt = 0;
        end;
    end;
end;


%--------------------------------------------------------------------------
function [isFile, fileType] = is_a_file_l(file),
%
%
%
isFile = 0;
fileType = '';
oldWarn=warning;
warning('off');
switch exist(file,'file'),
case 0, % does not exist
    isFile = (exist(file, 'file') ~= 0 & file_has_good_extension(file));

    if isFile,
        fileType = 'txt';
    else,
        prevLastErr = lasterr;
        try,
            get_param(file, 'handle');
            isFile = 1;
            fileType = 'mdl';
        catch,
            lasterr(prevLastErr);
        end;
    end;
case 2, % is a file
    if file_has_good_extension(file),
        isFile = 1;
        fileType = 'txt';
    end;
case 4, % is a MDL file on the path
    isFile = 1;
    fileType = 'mdl';
case 7, % is a directory
    isFile = 1;
    fileType = 'txt'; % WISH: change this to dir
    % hack to use txt for now to get hilights
    % (DLL needs to be updated to look for fileType dir).
end;
warning(oldWarn);


%----------------------------------------------------------------------------------------
function varargout = naglog_cmd_l(sNagFile, command, varargin),
%   E.Mehran Mestchian
%
%
switch nargout,
case 0,
case 1, varargout{1} = [];
end;

%
% if we get a struct, we know we're running in memory mode due to a failure to
% access naglog file.
%
if isstruct(sNagFile),
    ss = sNagFile;
    try,
        switch (command),
        case 'clear',
            ss.nags = [];
            set_ss_l(ss);
        case 'push',
            nag = varargin{1};
            nag = process_this_stateflow_nag_l(nag);
            % Put your nag object stuff here - Mehran Kamran
            
            if isfield(ss,'dasDiagViewer') & ~ss.processingNags,
                ss.dasDiagViewer.convertNagsToUDDObject(nag);
            end;
            ss.nags = ss.nags(:);
            ss.nags = [ss.nags; nag];
            set_ss_l(ss);
        case 'pop',                                         % pop the last nag recorded
        case 'count',   varargout{1} = length(ss.nags);
        case 'isempty', varargout{1} = length(ss.nags) == 0;
        case 'get',     varargout{1} = ss.nags;
        case 'text',                                        % all the nag records returned in a text string
        case 'file',    varargout{1} = '';                  % fullpath of the nag file
        case 'copy',
        otherwise,      error(sprintf('bad command: %s',command));
        end;
    end;
else,
    try,
        switch (command),
        case 'clear',   clear_naglog_l(sNagFile);
        case 'push',    push_naglog_l(sNagFile, varargin{1});
        case 'pop',                                         % pop the last nag recorded
        case 'count',   varargout{1} = count_naglog_l(sNagFile);
        case 'isempty', varargout{1} = naglog_cmd_l(sNagFile, 'count')==0;
        case 'get',     varargout{1} = get_naglog_l(sNagFile, varargin{:});
        case 'text',                                        % all the nag records returned in a text string
        case 'file',    varargout{1} = sNagFile;            % fullpath of the nag file
        case 'copy',    copyfile(sNagFile,varargin{1});     % copy nag file to another file
        otherwise,      error(sprintf('bad command: %s',command));
        end
    catch,
        disp(sprintf('Error calling naglog(''%s'',...)\n%s',command,lasterr));
    end;
end;



%------------------------------------------------------------------------------------
function count = count_naglog_l(nagFile, varargin)
%
%
%
load(nagFile,'nagCount','-mat');
if exist('nagCount','var'),  count = nagCount;
else,                        error('Invalid NAGLOG file');
end;

%------------------------------------------------------------------------------------
function push_naglog_l(nagFile, nag),
%
%
%
nagCount = count_naglog_l(nagFile) + 1;
newNagVar = sprintf('nag%d',nagCount);

eval([newNagVar,'=nag;']);
save(nagFile,'nagCount',newNagVar,'-mat','-append');

%----------------------------------------------------------------------------------
function nags = get_naglog_l(nagFile, varargin)
%
%
%
load(nagFile,'nagCount','-mat');

if isempty(nagCount) | nagCount < 1,
    nags = [];
    return;
end;

for i=1:nagCount,
    nagVar = sprintf('nag%d',i);
    load(nagFile,nagVar,'-mat');
    nags(i) = eval(nagVar);
end


%---------------------------------------------------------------------------------
function nagFile = clear_naglog_l(nagFile)
%
%
%
nagCount = 0;
nagTime = now;
try,
    save(nagFile,'nagCount','nagTime','-mat');
end;

if ~isequal(exist(nagFile, 'file'),2),
    nagFile = '';
end;


%----------------------------------------------------------------------------------
function nagFile = delete_naglog_l(nagFile),
%
%
%
if isempty(nagFile), return; end;
if isequal(exist(nagFile,'file'),2), delete(nagFile); end;
nagFile = '';


%---------------------------------------------------------------------------------
function nagFile = init_naglog_l(nagFile),
%
%
%
if nargin<1 | isempty(nagFile) | ~isequal(exist(nagFile,'file'),2),
    nagFile = [tempname,'.log'];
end;
nagFile = clear_naglog_l(nagFile);


%---------------------------------------------------------------------------------
function nagFile = check_naglog_l(nagFile),
%
%
%
if ~isempty(nagFile) & isequal(exist(nagFile,'file'),2), return; end;
nagFile = init_naglog_l(nagFile);


%----------------------------------------------------------------------------------
function ss = nagtoken_l(ss)
%
% Errors that result in nags should set the lasterr to this token.
%
ss.output = get_nagtoken_l;


%----------------------------------------------------------------------------------
function token = get_nagtoken_l
%
%
%
token = '(SLSF Diagnostic)';


%----------------------------------------------------------------------------------
function s = merge_structs_l(s1, s2),
%
%
%
if ~isstruct(s2), error('bad input to merge_structs_l()'); end;
if ~isstruct(s1), s = s2; return; end;

s = s1;
f2 = fieldnames(s2);
len2 = length(f2);

for i=1:len2;
    aField = f2{i};
    if ~isfield(s, aField), eval(['s.',aField,'=s2.',aField,';']); end;
end;

f = fieldnames(s);
if (length(f) ~= len2), error('bad nag fields'); end;


%----------------------------------------------------------------------------------
function ss = get_nags_l(ss),
%
%
%
ss.output = ss.nags;


%----------------------------------------------------------------------------------
function ss = get_infotxt_l(ss),
%
%
%
ss.output = ss.infoTxt;


%----------------------------------------------------------------------------------
function result = ispc_l
%
%
%
c = computer;
result = strcmpi(c(1:2),'PC');

function result = isjava_l
result = usejava('mwt') & usejava('swing') & slfeature('CreateDiagnosticViewer');

function isAbsPath = is_absolute_path_l(fileName)
isAbsPath = 0;
if(ispc_l)
    if(length(fileName)>=2)
        if(fileName(2)==':' | (fileName(1)=='\' & fileName(2)=='\'))
            isAbsPath = 1;
        end
    end
else
    if( length(fileName)>=1 & fileName(1)=='/' )
        isAbsPath = 1;
    end
end


function [si,ei] = find_quoted_patterns_l( stream )
%Find all quoted strings with their start and end indices.
%These constitute potential file links.
si=[]; ei=[];
if (isempty(stream))
    return
end;
delim = find(stream<' ');
s2 = find(stream=='"');
s1 = find(stream=='''');
if isempty(s1) & isempty(s2)
    return;
end
us = [s2,delim,s1];
ubs = [ones(size(s2)),zeros(size(delim)),-ones(size(s1))];
[s,indx] = sort(us);
bs = ubs(indx);
good = find((bs(1:end-1)==bs(2:end)) & (bs(1:end-1)~=0));
si = s(good);
ei = s(good+1);


function nag = preprocess_file_links_l( nag )
if ~isequal(nag.component,'Stateflow'), return; end
stream = nag.msg.details;
links = [];
[sv,ev] = find_quoted_patterns_l( stream );
% check each candidate file link and create link info as appropriate.
for i=1:length(sv)
    s = sv(i);
    e = ev(i);
    if s>0 & s<e,
        si = s+1;
        ei = e-1;
        if si<ei,
            txt = stream(si:ei);
            if is_absolute_path_l(txt)
                [isFile, fileType] = is_a_file_l(txt);
                if isFile,
                    links(end+1).type = fileType;
                    links(end).file = txt;
                    links(end).si = si;
                    links(end).ei = ei;
                    [links(end).path, links(end).name, links(end).ext] = fileparts(txt);
                end;
            else
                fullFileName = fullfile(nag.refDir,txt);
                [isFile, fileType] = is_a_file_l(fullFileName);
                if (~isFile)
                    fullFileName = '';
                    [isFile, fileType] = is_a_file_l(txt);
                end
                if isFile,
                    links(end+1).type = fileType;
                    links(end).file = fullFileName;
                    links(end).si = si;
                    links(end).ei = ei;
                    [links(end).path, links(end).name, links(end).ext] = fileparts(fullFileName);
                end;
            end;
        end;
    end;
end;
nag.msg.links = links;
nag.msg.preprocessedFileLinks = 1;



