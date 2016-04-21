function surveil_script(action,value)
%SURVEIL_SCRIPT controls demo processing
%    surveil_script(ACTION) performs requested ACTION, which can be
%       'run', 'closewindow', 'halt'
%    surveil_script(ACTION, VALUE) ACTION = 'newthresh'; VALUE is a
%       numeric value defining SAD threshold value

% $Revision: 1.1.6.1 $ $Date: 2004/01/22 18:33:11 $
% Copyright 2001-2003 The MathWorks, Inc.

persistent stopLoop newThresh

switch lower(action)
    case 'run'
        modelName = gcs;
        fprintf('Starting application: %s\n', modelName);

        % Construct full path names for project
        fullModelName = fullfile('.', [modelName '_c6000_rtw'], modelName);
        outModelName  = [fullModelName '.out'];
        pjtModelName  = [fullModelName '.pjt'];

        CCS_Obj = ConnectToCCS(modelName);
        CCS_Obj.visible(1);
        if need2rebuild(modelName),
            % generate code and build target project
            load_system(modelName);
            make_rtw;
            saveModelState(modelName);
        end
        saveState = warning; warning off
        try
            CCS_Obj.open(pjtModelName,'project');
        catch
            % don't error if project does not exist
        end
        warning(saveState);
        CCS_Obj.reset; pause(1);
        CCS_Obj.load(outModelName,100);
        
        % Setup image for drawing:
        load vid_hist;
        sz=size(vG3);
        VidLoopFrames = sz(3);
        hVideo = videoSetup(sz);
        
        % Configure RTDX
        r = CCS_Obj.rtdx;
        r.disable;
        r.open('videoFrames',           'w', ...
               'motionThreshold',     'w', ...
               'motionFrames', 'r', ...
               'motionEst',    'r', ...
               'eventCnt',     'r');
        r.configure(32768,4,'continuous');
        CCS_Obj.run;     % Run application
        r.enable('all');
        r.enable;        % Master RTDX enable

        % Manage threshold
        lastThresh  = 0;
        newThresh   = 1.5e5;
        stopLoop    = 0;
        TestVidLoop = 0; % test video loop counter
        TxCnt       = 0;
        while ~stopLoop,
            try
                % Get next test video frame and send to target
                TestVidLoop = 1+rem(TestVidLoop,VidLoopFrames);
                inFrame = vG3(:,:,TestVidLoop);
                r.writemsg('videoFrames', inFrame);
                TxCnt = TxCnt + 1;

                % See if new threshold should be sent
                if ~isequal(newThresh, lastThresh),
                    lastThresh = newThresh;
                    r.writemsg('motionThreshold', int32(newThresh));
                end
                
                % Process received frames
                while ~stopLoop && (r.msgcount('motionFrames') > 0),
                    outFrame  = r.readmsg('motionFrames', 'uint8',[120 160]);
                    motionEst = r.readmsg('motionEst',    'int32', [2 1]);
                    evCnt     = r.readmsg('eventCnt',     'int32');
                    videoUpdate(inFrame, outFrame, TxCnt, evCnt, motionEst, hVideo);
                end
                
            catch
                stopLoop=1;
                fprintf('Error occurred during update loop\n'); lasterr
            end
        end
        % Here we halt the processor
        fprintf('Halting processor\n');
        CCS_Obj.reset;

    case 'newthresh'
        newThresh = value;
        
    case 'closewindow'
        stopLoop=1;
        fprintf('Figure closed: Ending application\n');
        
    case 'halt',
        stopLoop=1;
        fprintf('Halt pressed: Ending application\n');

        % Act as reset when target is not running
        CCS_Obj = ConnectToCCS(gcs);
        if ~CCS_Obj.isrunning, CCS_Obj.reset; end
end


% -------------------------------------------------------------------------
function CCS_Obj = ConnectToCCS(modelName)
% ConnectToCCS

[boardNum, procNum] = c6000tgtpref('getBoardProcNums',modelName);
CCS_Obj = ccsdsp('boardnum', boardNum, 'procnum', procNum);


% -------------------------------------------------------------------------
function saveModelState(modelName)
% Save version number and 'dirty' state of Simulink model just built.  This
% information is used to determine whether a rebuild is necessary

codegenDir = fullfile(pwd, [modelName '_c6000_rtw']);
versionFile = [fullfile(codegenDir, modelName) '_version.mat'];

modelVersion = get_param(modelName,'ModelVersion');
bDirty = get_param(modelName,'Dirty');

if exist(codegenDir,'dir')
    save(versionFile, 'modelVersion', 'bDirty');
else
    error(['Current directory does not contain RTW-generated directory '...
        'for this model.']);
end


% -------------------------------------------------------------------------
function bRebuild = need2rebuild(modelName)

codegenDir = fullfile(pwd, [modelName '_c6000_rtw']);
fullModelName = fullfile(codegenDir, modelName);
coffFile = [fullModelName '.out'];
versionFile = [fullModelName '_version.mat'];

bRebuild = logical(1);
% does the RTW-generated directory exist?
if exist(codegenDir,'dir'),
    % do the COFF file and the saved model version file exist?
    if (exist(coffFile)) && (exist(versionFile)),
        load(versionFile);
        if sameModelVersion(modelName,modelVersion),
            % can skip rebuild only if the model versions are alike, and the
            % current model is not dirty, and the previous model was not dirty
            
            if (~isDirty(modelName)) && strcmp(bDirty,'off'),
                bRebuild = logical(0);
            elseif (isDirty(modelName)),
                % if the versions are the same, but the current model is
                % dirty and the previous model not dirty, then it is
                % ambiguous -> must ask user
                ansStr = questdlg(sprintf(['You have unsaved changes in the model.  ' ...
                        'What would you like to do?']), ...
                    'Rebuild Action','Rebuild','Reload','Rebuild');
                
                switch ansStr,
                    case 'Rebuild', 
                        % bRebuild = logical(1);
                    case 'Reload',
                        bRebuild = logical(0);
                end % switch
                
            end
        end
    end
end


% -------------------------------------------------------------------------
function bFlag = sameModelVersion(fullModelName,modelVersion)
bFlag = strcmp(get_param(fullModelName,'ModelVersion'),modelVersion);


% -------------------------------------------------------------------------
function bFlag = isDirty(fullModelName)
bFlag = strcmp(get_param(fullModelName,'Dirty'),'on');


% -------------------------------------------------------------------------
function h = videoSetup(sz)
% VideoSetup  Setup display for Video Surveillance compression

nrows=sz(1);
ncols=sz(2);

% Determine if GUI is already open
% Tear it down
hfig = findobj('type','figure', ...
    'tag', 'RTDX Video Surveillance Demo');
if ~isempty(hfig),
    set(hfig,'deletefcn','');  % clear callback
    close(hfig);
end

% Setup image for drawing:
h.hfig = figure('numbertitle','off', ...
    'name','RTDX Video Monitor', ...
    'backingstore','off', ...
    'doublebuffer','off', ...
    'tag', 'RTDX Video Surveillance Demo', ...
    'renderer','painters', ...
    'DeleteFcn', 'surveil_script(''closeWindow'')', ...
    'colormap',gray(256));
%     'CloseRequestFcn','surveil_script(''halt'')', ...

h.h1 = createImage(0,h.hfig,nrows,ncols); % Render image 1
h.h2 = createImage(1,h.hfig,nrows,ncols); % Render image 2
h.h3 = createPlot(h.hfig);                % Render plot axis

% -----------------------------------------------------------------
function h = createPlot(hfig)

h.ax = axes('parent', hfig, ...
    'pos', [.05 .7 .9 .2], ...
    'drawmode','fast', ...
    'buttondown',@plot_bdfcn, ...
    'xlim', [1 64], ...
    'ylim', [0 4e5]);
hold on;
h.line1 = line('parent', h.ax, ...
    'erase','xor', ...
    'color','c', ...
    'xdata', 1:64, ...
    'ydata', zeros(1,64));
h.line2 = line('parent', h.ax, ...
    'erase','xor', ...
    'color','m', ...
    'xdata', 1:64, ...
    'ydata', zeros(1,64));
title('Inter-Frame Motion (click to adjust threshold)');
legend('Estimate','Threshold',2)
    

% -----------------------------------------------------------------
function h = createImage(k,hfig,nrows,ncols)
% k=0 or 1 to horiz offset of axis

uibg = get(hfig,'color');
dummy = uint8(ones(nrows,ncols));

% Render image 1
h.ax = axes('parent',hfig, ...
    'pos', [.01+k*.5 0 .48 .48], ...
    'drawmode','fast', ...
    'xlim',[1 ncols], ...
    'ylim',[1 nrows], ...
    'ydir','rev', ...
    'dataaspectratio',[1 1 1], ...
    'xlimmode','manual',...
    'ylimmode','manual',...
    'zlimmode','manual',...
    'climmode','manual',...
    'alimmode','manual',...
    'layer','bottom',...
    'nextplot','add', ...
    'vis','off');
hold on;
h.image = image(h.ax,'erase','none','cdata',dummy);
pos = [0.01+k*.5 .5 .48 .075];
h.text = uicontrol('parent',hfig, ...
    'units','norm', ...
    'style','text', ...
    'pos', pos,...
    'horiz','left', ...
    'backgr',uibg, ...
    'string','Loading...');
ex=get(h.text,'extent');
pos(4)=ex(4);  % vertical extent
set(h.text,'pos',pos);

% ------------------------------------------------------
function plot_bdfcn(hco,eventStruct)
% Button down function in threshold plot axis

cp=get(hco,'currentpoint');
y = min(max(0, cp(1,2)), 4e5);  % lower limit of zero, upper limit of 4e5
surveil_script('newThresh',y);    % send new threshold to application


% -------------------------------------------------------------------------
function videoUpdate(inV,outV,inCnt,outCnt,Thresh,h)
% VideoUpdate

if ~ishandle(h.hfig),
    return
end

set(h.h1.image,'cdata',inV);
str = sprintf('Source: %d', inCnt);
set(h.h1.text, 'string', str);

set(h.h2.image,'cdata',outV);
str = sprintf('Capture: %d', double(outCnt));
set(h.h2.text, 'string', str);

y = get(h.h3.line1,'ydata');
y=[y(2:end) Thresh(1)];
set(h.h3.line1,'ydata',y);

y = get(h.h3.line2,'ydata');
y=[y(2:end) Thresh(2)];
set(h.h3.line2,'ydata',y);

drawnow;


% [EOF] surveil_script.m
