function fcns = slfdatoolinterface
%SLFDATOOLINTERFACE Simulink to FDATool interface function.
%   FCNS = SLFDATOOLINTERFACE returns a structure of function handles 
%   for communication between Simulink and FDATool. These functions
%   provide the mechanism by which Simulink and FDATool exchange
%   information via the block's UserData and FDATool's API functions. 


%   Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.34.4.3 $ $Date: 2004/04/12 23:07:52 $

fcns.slOpenFDATool  = @slOpenFDATool;
fcns.slCloseFDATool = @slCloseFDATool;
fcns.slModelClose   = @slModelClose;
fcns.slNameChange   = @slNameChange;
fcns.slStartFcn     = @slStartFcn;

% ---------------------------------------------------------------
function slOpenFDATool(hBlk)
%SLOPENFDATOOL Launch FDATool from Simulink
%   Open a new copy of FDATool (if one is not already open)
%   for the referenced block.  If one is open, make it visible and
%   make it the active figure window.

hFDA = validatehFDA(hBlk);
if ~isempty(hFDA),
    
    % Disable if called from a locked model.
    disableiflocked(hFDA);
    
    % If hFDA stored in hBlk points to hBlk show hFDA
    set(hFDA,'Visible','On');
    figure(hFDA.FigureHandle);
else
    
    % Find or render a new FDATool.
    findnsetupFDA(hBlk);
end


% ---------------------------------------------------------------
function slCloseFDATool(hBlk)
%SLCLOSEFDATOOL Close FDATool from Simulink
%   SLCLOSEFDATOOL will close FDATool when the model is closed or the
%   block is deleted. 

% If there is an open FDATool session associated with the Block close it
hFDA = validatehFDA(hBlk);
if ~isempty(hFDA),
    
    % Reset the block's FDATool session
    blk_ud = get_param(hBlk, 'UserData');
    blk_ud.hFig = [];
    if ~islockedModel(hBlk),
        set_param(hBlk, 'UserData',blk_ud);
    end
    
    close(hFDA,'force');
end


% ---------------------------------------------------------------
function slNameChange(hBlk)
%SLNAMECHANGE Change the title of FDATool from Simulink.
%   SLNAMECHANGE will change the title of FDATool when the name of the
%   Simulink block is changed.  It will also change the title when the
%   name of the Simulink model is changed.


% Check for an existing FDATool session associated with the block.
hFDA = validatehFDA(hBlk);
if ~isempty(hFDA),
    
    data = getappdata(hFDA,'DSPBlks');
    
    % Store the new full name in AppData
    data.fullname = getfullname(hBlk);
    setappdata(hFDA,'DSPBlks',data);
    
    % Store the new block name in the Title of FDATool
    newname = get_param(hBlk,'Name');
    settitle(hFDA,newname);
end


% ---------------------------------------------------------------
function slStartFcn(hBlk)
%SLSTARTFCN Check to make sure that the block is set properly
% Make sure the sampling frequencies match, but only warn.

w = warning('on');

try,
    
    [fda_Ts, isnormalized] = get_stored_Ts(hBlk);
    
    if ~isnormalized,
        
        blk_Ts = get_blk_Ts(hBlk);
        
        % If the sampling times do not match warn, do not error.
        if difference(blk_Ts,fda_Ts),
            msg = 'sampling frequency does not correspond to input sample time.';
            fullname = getfullname(hBlk);
            
            % Replace new line feeds with spaces
            fullname(find(fullname == char(10))) = ' ';
            msg = [fullname ' ' msg];
            warning(msg);
        end
    end
catch,
    dspblkfdatool('filterInvalid',hBlk);
end

warning(w);


% ---------------------------------------------------------------
function slModelClose(model_name)
%SLMODELCLOSE Close FDATools associated with the Simulink model.
%   SLMODELCLOSE will find all FDATools that are associated with a given
%   Simulink model and close them.

% Find the handles to all of the open and invisible FDATools
hFigs = findall(0,...
    'tag','FilterDesigner');

for i = 1:length(hFigs)
    hFDA = getfdasessionhandle(hFigs(i));
    
    % Check to see if this is a DSPBlks FDATool
    if isappdata(hFDA,'DSPBlks');
        hBlk = gethblk(hFDA);
        model = getfullname(bdroot(hBlk));
        
        % If the model name stored in FDATool is the same as the current
        % model force it closed.
        if strcmp(model,model_name),
            close(hFDA,'force');
        end
    end
end


% ---------------------------------------------------------------
function filtercheck(hFDA, eventData)

% Force them to convert the filter
blk_ud   = get_param(gethblk(hFDA), 'UserData');
old_filt = blk_ud.current_filt;
new_filt = getfilter(hFDA);

% if isa(new_filt, 'qfilt'),
%     senderror(hFDA, 'QFilts are not supported by the Signal Processing Blockset, converting to DFilt.');
%     new_filt = qfilt2dfilt(new_filt);
%     hFDA.setfilter(new_filt);
% end

if ~issupported(new_filt),
    
    if strcmpi(get(hFDA, 'filterMadeBy'), 'designed'),
        if isa(new_filt, 'qfilt'),
            if isfir(new_filt),
                new_filt = convert(new_filt, 'firt');
            else
                new_filt = sos(convert(new_filt, 'df2t'));
            end
        else
            if isfir(new_filt)
                new_filt = convert(new_filt, 'dffir');
            elseif isa(new_filt, 'dfilt.abstractsos')
                new_filt = convert(new_filt, 'df2tsos');
            else
                new_filt = convert(new_filt, 'df2t');
            end
        end
        hFDA.setfilter(new_filt);
    else
        
        sendwarning(hFDA, cleanerrormsg(lasterr));
        hC = convert(hFDA);
        
        hC.Filter = new_filt;
        set(hC, 'TargetStructure', 'Direct form II transposed');
        
        % Create a listener, but do not store it.  We only want it until
        % the waitfor is complete.
        l  = handle.listener(hC, 'DialogApplied', @convert_listener);
        
        hFig = get(hC, 'FigureHandle');
        
        % Make sure that the window cannot lose focus.
        set(hFig, 'WindowStyle', 'Modal');
        waitfor(hFig, 'Visible', 'Off');
        
        new_filt = getfilter(hFDA);
        
        % If they hit cancel, undo the latest filter.
        if ~issupported(new_filt),
            hFDA.setfilter(old_filt);
        end
        
        % Once we are done, set the dialog back to normal.
        if ishandle(hFig),
            set(hFig, 'WindowStyle', 'Normal');
        end
    end
end

% ---------------------------------------------------------------
function filterlistener(hFDA,eventData)
%FILTERLISTENER Executed by FDATool whenever the filter is changed

w = warning('off');

% If there is no 'DSPBlks' appdata, then FDATool has not been set up yet.
% If parent model is locked, do not attempt to write to the block.
if isappdata(hFDA,'DSPBlks') & ~islockedModel(hFDA),
    
    hBlk = gethblk(hFDA);
    
    storeGUIstate(hBlk,hFDA);
 
    % If the model is running, the update might fail.
    % Catch the errors and display in a nice dialog.
    try,
        updateModelOrBlk(hBlk);
    catch,
        
        error(hFDA);
    end
end

warning(w);


%---------------------------------------------------------------
function hidelistener(hFDA, eventData)
% HIDELISTENER Set the correct analysis in the block and close excessive
%   hidden FDATools.

% Get the visible state from FDATool
visState = get(hFDA, 'Visible');

% If the new state is visible (1) then return
if strcmpi(visState,'on'), return; end

% If parent model is locked, do not attempt to write to the block.
if ~islockedModel(hFDA),
    if isappdata(hFDA,'DSPBlks'),
        
        hBlk = gethblk(hFDA);

        % Save the analysis from FDATool
        storeanalysis(hFDA);
        
        % Restore old settings in FDATool
        restoreGUIstate(hBlk, hFDA);
        
        % Find any excessive hidden FDATools and close them
        closeXtraFDAs;
        
    end
else
    set(hFDA,'Enable','On');
end

%---------------------------------------------------------------
%                       Utility Functions
%---------------------------------------------------------------

%---------------------------------------------------------------
function storeanalysis(hFDA)
% Get the latest analysis_mode from FDATool and save it in the block.

hBlk = gethblk(hFDA);

% Get the analysis mode from the FDATool session.
state = getstate(hFDA);
analysis = state.fvtool.currentAnalysis;

% Set the analysis mode in the block.
blk_ud = get_param(hBlk,'UserData');
blk_ud.fvtool.currentAnalysis = analysis;
set_param(hBlk,'UserData',blk_ud);


%---------------------------------------------------------------
function closeXtraFDAs
% Find and delete any excessive open & hidden FDATools

% Maximum hidden FDATools
maxFDAs = 5;

% Find all hidden (invisible) FDATools
hFigs = findall(0,'tag','FilterDesigner','visible','off');
index = 1;
hFDA_DSPBlks = {}; % Handles to hidden FDATools hosted by DSPBlks

% Find every hidden FDATool associated with the DSPBlks
for i = 1:length(hFigs)
    hFDA = getfdasessionhandle(hFigs(i));
    if isappdata(hFDA,'DSPBlks'),
        hFDA_DSPBlks{index} = hFDA;
        index = index + 1;
    end
end

% Determine how many FDATools need to be deleted and delete them.
if length(hFDA_DSPBlks) > maxFDAs,
    close(hFDA_DSPBlks{i},'force');
end


%---------------------------------------------------------------
function findnsetupFDA(hBlk)
% Look for hidden FDATools.  If one is found use it, otherwise setup
% a new FDATool.

hFDA = findFDA;

if isempty(hFDA),
    
    opts.visstate = 'off';
    opts.title    = sprintf('Block Parameters: %s', get_param(hBlk, 'Name'));
    
    % Render a new FDATool as a client of DSP Blks
    hFDA = fdatool(opts);
        
    % Register the Signal Processing Blockset as the host of FDATool 
    sethost(hFDA,@fdaregisterhost);
    
    % Add listeners to FDATool
    addlistener(hFDA,'Filter',@filtercheck, hFDA);
    addlistener(hFDA,'FilterUpdated',@filterlistener, hFDA);
    addlistener(hFDA,'Visible',@hidelistener, hFDA);
    
    setupFDATool(hFDA,hBlk);
else
    
    % Setup FDATool with the new blocks settings
    setupFDATool(hFDA,hBlk);
end


%---------------------------------------------------------------
function setupFDATool(hFDA,hBlk)
% Configures the session of FDATool associated with hFDA for use with
% DSPBlks.

sendstatus(hFDA, 'Loading block information.');

% Change FDATool's title to the block name
name = get_param(hBlk,'Name');
settitle(hFDA,name, 'Block Parameters:');

% Store the Blocks full name in FDATool's application data.
if isappdata(hFDA, 'DSPBlks'),
    data      = getappdata(hFDA,'DSPBlks');
end

data.fullname = getfullname(hBlk);
data.hBlk     = hBlk;

setappdata(hFDA,'DSPBlks',data);

% Update the FDATool GUI with the session stored in the block.
%
% Send the block UserData to the FDATool session now associated with it.
blk_ud = get_param(hBlk,'UserData');

try,
    % Add blk_ud to FDATool's 'ud' if it is a valid "state" structure
    setstate(hFDA,blk_ud);
    
catch,
    % NO OP
end

% Get the state of FDATool.  This will give us the latest version of the 
% session (state) of FDATool.
blk_ud = getstate(hFDA);

% xxx when design panel is an object it will take care of this
if isempty(blk_ud.fvtool.currentAnalysis),
    send(hFDA, 'NewAnalysis', ...
        sigdatatypes.sigeventdata(hFDA, 'NewAnalysis', 'Filter Specifications'));
end

% Disable the tool if it was called from the Simulink Library Browser
%
% Stop executing to avoid errors at call to SET_PARAM
if ~disableiflocked(hFDA),
    
    storeGUIstate(hBlk, hFDA);
    
    hFig = get(hFDA,'FigureHandle');
    status(hFDA,'Ready');
end

set(hFDA,'Visible','On');


%---------------------------------------------------------------
function boolflag = disableiflocked(hFDA)
% DISABLEIFBROWSER disables the UIControls of FDATool if it was launched
% from the Simulink browser.


% If parent model is locked, disable all of FDATool's UIControls.
if islockedModel(hFDA),
    boolflag = 1;

    hd = find(hFDA, '-class', 'siggui.designpanel'); % xxx Revisit in R14.
    set(hd, 'StaticResponse', 'On');

    set(hFDA,'Enable','Off');
else
    boolflag = 0;
end


%---------------------------------------------------------------
function storeGUIstate(hBlk, hFDA)
% Send the new filter to the Simulink Block

state_ud      = getstate(hFDA);
state_ud.hFig = get(hFDA, 'FigureHandle');
set_param(hBlk,'UserData',state_ud);

fwfs = getfilter(hFDA, 'wfs');
if ~isprop(fwfs, 'fs_listener'),
    l = handle.listener(fwfs, fwfs.findprop('Fs'), 'PropertyPostSet', {@fs_listener, hBlk});
    set(l, 'callbacktarget', hFDA)
    p = schema.prop(fwfs, 'fs_listener', 'handle.listener');
    set(fwfs, 'fs_listener', l);
    set(p, 'AccessFlags.PublicSet', 'Off', 'AccessFlags.PublicGet', 'Off');
end

%---------------------------------------------------------------
function fs_listener(hFDA, eventData, hBlk)

storeGUIstate(hBlk, hFDA);

%---------------------------------------------------------------
function restoreGUIstate(hBlk, hFDA)
% Send the new filter to the Simulink Block

state_ud = get_param(hBlk,'UserData');
setstate(hFDA, state_ud);

%---------------------------------------------------------------
function updateModelOrBlk(hBlk)
% Update the model if the simulation is running or the block if it is not.
%
% This function is waiting on Geck # 98491

hModel = bdroot(hBlk);

% If the model is running we need to update the entire model.
if strcmpi(get_param(hModel,'SimulationStatus'),'running'),
    set_param(hModel,'SimulationCommand','Update');
else
    % If the simulation is not running we can just update the block.
    update_block(hBlk);
end


%---------------------------------------------------------------
function boolflag = islockedModel(hBlk)
%ISLOCKEDMODEL returns 1 for a locked model and 0 for an unlocked model
% Input can be either hBlk or hFDA.

% If the input is an sigtools.fdatool object convert it to a block handle.
if isa(hBlk,'sigtools.fdatool'),
    hFDA = hBlk;
    hBlk = gethblk(hFDA);
end

% Get the handle to the model and get its locked status.
hModel = bdroot(hBlk);
status = get_param(hModel,'lock');

% Convert the locked status to a boolean.
if strcmpi(status,'on'), boolflag = 1;
else,                    boolflag = 0; end


%---------------------------------------------------------------
function hFDA = findFDA
% FINDFDA searches for a hidden FDATool that is the client of DSPBlks.

% Find all hidden (invisible) FDATools
hFigs = findall(0,'tag','FilterDesigner','visible','off');

% Find the first hidden FDATool associated with the DSPBlks and return
for i = 1:length(hFigs)
    hFDA = getfdasessionhandle(hFigs(i));
    if isappdata(hFDA,'DSPBlks'),
        return;
    end
end

hFDA = [];


%---------------------------------------------------------------
function validhFDA = validatehFDA(hBlk)
% Test if the FDATool pointed to by hBlk is valid.
% FDATool is valid if it also points to hBlk.

validhFDA = [];
blk_ud = get_param(hBlk,'UserData');

if isfield(blk_ud, 'hFig') & isa(handle(blk_ud.hFig), 'hg.figure'),
    hFDA = getfdasessionhandle(blk_ud.hFig);
else,
    hFDA = [];
end

% Check if the stored hFDA still exists
if isa(hFDA,'sigtools.fdatool'), 
    
    thBlk = gethblk(hFDA);
    
    % Check if hFDA is still associated with the block
    if thBlk == hBlk
        validhFDA = hFDA;
    end
    
    % If the model is locked search all FDATools for the valid FDATool.
elseif islockedModel(hBlk),
    
    % Find all FDATools
    hFigs = findall(0,'tag','FilterDesigner');
    
    % Find an FDATool associated with the DSPBlks and hBlk
    for i = 1:length(hFigs)
        hFDA = getfdasessionhandle(hFigs(i));
        if isappdata(hFDA,'DSPBlks'),
            thBlk = gethblk(hFDA);
    
            % Check if hFDA is associated with the block
            if thBlk == hBlk
                validhFDA = hFDA;
            end
        end
    end
end


%---------------------------------------------------------------
function modelname = getmodelname(hBlk)
% Returns the model name that contains hBlk

hModel    = bdroot(hBlk);
modelname = get_param(hModel,'name');


%---------------------------------------------------------------
function update_block(hBlk)
%UPDATE_BLOCK Changes the position slightly to force an update of the
% block. Updating the S-function with SET_PARAM does not do this.

pos = get_param(hBlk,'position');
pos(1) = pos(1)+2;
set_param(hBlk,'position',pos);
pos(1) = pos(1)-2;
set_param(hBlk,'position',pos);


%---------------------------------------------------------------
function [Ts, isnormalized] = get_stored_Ts(hBlk)

blk_ud = get_param(hBlk,'UserData');

% Get Fs from the block's UserData.
Fs    = blk_ud.currentFs;
if isstruct(Fs),
    Fs    = blk_ud.currentFs.value;
    units = lower(blk_ud.currentFs.units);
    
    isnormalized = 0;
    % Convert Fs units to Hz.
    switch units
    case 'hz',
        % NO OP
    case 'khz'
        units = 'hz';
        Fs    = Fs * 1000;
    case 'mhz'
        units = 'hz';
        Fs = Fs * 1000000;
    otherwise % normalized case
        isnormalized = 1;
    end
else
    if isempty(Fs), isnormalized = 1;
    else,           isnormalized = 0; end
end
if ~isnormalized,
    Ts = 1/Fs;
else
    Ts = 0;
end


%---------------------------------------------------------------
function boolflag = difference(ts1,ts2)
% Check the difference between the two inputs sample times to see
% if they are within a predefined tolerance.

% Test to see if it should warn, because the difference is too great
boolflag = (abs(ts1-ts2) > sqrt(eps));


%---------------------------------------------------------------
function blk_Ts = get_blk_Ts(hBlk)
% Get Model Sampling Time

blk_Ts      = get_param(hBlk,'CompiledSampleTime');
port_dims   = get_param(hBlk,'CompiledPortdimensions');
frame_width = port_dims.Inport(2);

blk_Ts      = blk_Ts(1)/frame_width;


%---------------------------------------------------------------
function hBlk = gethblk(hFDA)

data = getappdata(hFDA,'DSPBlks');
hBlk = data.hBlk;

%---------------------------------------------------------------
function boolflag = issupported(Hd)

try,
    [lib, b] = blockparams(Hd, 'off');
    boolflag = strcmpi(b, 'digital filter');
catch
    boolflag = false;
end

%---------------------------------------------------------------
function convert_listener(hC, eventData)

% If the dialog is applied, we can just close it.
set(hC, 'Visible', 'Off');

% [EOF]
