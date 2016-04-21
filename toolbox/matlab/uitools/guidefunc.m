function varargout = guidefunc(type, varargin)
%GUIDEFUNC Support function for Guide

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.85.4.17 $

error(nargchk(1,inf,nargin));

try

    switch type,

    case 'activateFigure'
        varargout = layoutActivate(varargin{:});

    case 'activexControl'
        varargout = getActiveXControlList(varargin{:});

    case 'activexSelect'
        varargout = selectActiveXControl;

    case 'applicationOptions'
        fig = varargin{1};
        guideopts(fig, 'edit');

    case 'changeparent'
        varargout = changeparent(varargin{:});

    case 'copy'
        varargout = copyGobject(varargin{:});

    case 'deleteFigure'
        varargout = deleteFigure(varargin{:});

    case 'deleteGObject'
        varargout = deleteGobject(varargin{:});

    case 'duplicate'
        varargout = duplicateGobject(varargin{:});

    case 'editCallback'
        varargout = editCallback(varargin{:});

    case 'export'
        varargout = layoutExport(varargin{:});

    case 'getProperties'
        varargout = getProperties(varargin{:});

    case 'getPropertyCallback'
        varargout = getPropertyCallback(varargin{:});

    case 'helpCreatingGUIs'
        helpview([docroot '/mapfiles/creating_guis.map'], 'creating_guis')

    case 'helpUsingLayout'
        helpview([docroot '/mapfiles/creating_guis.map'], 'layout_editor')

    case 'move'
        varargout = moveGobject(varargin{:});

    case 'moveToFront'
        moveGobjectOrder(varargin{:},'top');

    case 'moveToBack'
        moveGobjectOrder(varargin{:},'bottom');

    case 'moveForward'
        moveGobjectOrder(varargin{:},'up');

    case 'moveBackward'
        moveGobjectOrder(varargin{:},'down');

    case 'moveNForward'
        varargout = moveGobjectForward(varargin{:});

    case 'moveNBackward'
        varargout = moveGobjectBackward(varargin{:});

    case 'newGObject'
        varargout = createNewGobject(varargin{:});

    case 'newFigure'
        varargout = createNewFigure(varargin{:});

    case 'newLayout'
        varargout = createNewLayout(varargin{:});

    case 'openFigure'
        varargout = openFigure(varargin{:});

    case 'openCallbackEditor'
        varargout = openCallbackEditor(varargin{:});

    case 'prepareProxy'
        varargout = prepareProxy(varargin{:});

    case 'readFigure'
        varargout = readSavedFigure(varargin{:});

    case 'resizeFigure'
        varargout = resizeFigure(varargin{:});

    case 'save'
        varargout = layoutSave(varargin{:});

    case 'saveAs'
        varargout = layoutSaveAs(varargin{:});

    case 'setProperties'
        varargout = setProperties(varargin{:});

    case 'snapshotFigure'
        varargout = snapshotFigure(varargin{:});

    case 'showPropertyPage'
        varargout = showPropertyPage(varargin{:});

    case 'updateChildrenPosition'
        varargout = updateChildrenPosition(varargin{:});

    case 'updateTag'
        varargout = updateTag(varargin{:});

    end
    
catch
    import com.mathworks.ide.layout.LayoutEditor;
    % toggle layout's busy state
    LayoutEditor.toggleBusyState(0,0);
    
    % initialize varargout to something useful
    for i=1:nargout, varargout{i} = []; end

    if ~isempty(lasterr)
        errordlg(sprintf('Unhandled internal error in guidefunc.\n%s',lasterr), ...
            'GUIDE');
    else
        %errordlg('Unexpected CATCH in guidefunc with empty LASTERR');
        lasterr ('unknown');
    end
    error(lasterr);
end


% ****************************************************************************
% create new GObjects with default properties or with given properties,
% If no property is given, it is the first time creation. Otherwise, it if
% creation from undo/redo
% ****************************************************************************
function out = createNewGobject(varargin)

items = length(varargin)/8;
allhandles = [];

for i=1:items
    past = 1+(i-1)*8;
    parent = varargin{past};
    if isstr(parent)
        parent = allhandles(str2num(parent));
    end
    parent = double(parent);
    
    if (strcmp(varargin{past+1},'uicontrol'))
        vin = {parent varargin{past+1:past+7}};
        h = createUicontrol(vin{:});
    elseif (strcmp(varargin{past+1},'axes'))
        vin = {parent varargin{past+1:past+7}};
        h = createAxes(vin{:});
    elseif (strcmp(varargin{past+1},'uipanel'))
        vin = {parent varargin{past+1:past+7}};
        h = createContainer(vin{:});
    else
        vin = {parent varargin{past+1:past+7}};
        control = createExternalControl(vin{:});
        h = get(control,'Peer');
    end

    %add tag property listener
    initLastValidTagProperty(h);

    % local handle list for finding parent in undo/redo
    allhandles(end+1) = h;
    
    % store double handle on Java side
    h = handle(h);
    out{(i-1)*6+1} = h;
    if ~isExternalControl(h)
        out{(i-1)*6+2} = requestJavaAdapter(h);
        out{(i-1)*6+3} = out{(i-1)*6+2};
    else
        out{(i-1)*6+2} = requestJavaAdapter(get(h,'Peer'));
        out{(i-1)*6+3} = requestJavaAdapter(h);end
    [out{(i-1)*6+4} out{(i-1)*6+5}] = getProperty(h);
    out{(i-1)*6+6} = guidemfile('getCallbackProperties', h);
    varargin{past+2}.updateProxy(out{(i-1)*6+3});
end


% ****************************************************************************
% create a new figure for Guide. Return the figure, its UDD adapter, initial
% properties, and initial position.
% ****************************************************************************
function out = createNewFigure(varargin)

layout_ed = varargin{1};
fig = newGuideFig(layout_ed);
set(fig,'tag',nextTag(fig));

out{1} = fig;
out{2} = requestJavaAdapter(fig);
[out{3} out{4}] = getProperty(fig);
out{5} = guidemfile('getCallbackProperties', fig);
out{6} = localGetPixelPos(fig);
[out{7} out{8}] = guideopts(fig);


% ****************************************************************************
% call 'guide' to open the LayoutNewDialog to get the user input to created
% a new layout from template
% ****************************************************************************
function out = createNewLayout(varargin)

out =[];

fig = varargin{1};
layout_ed = getappdata(fig, 'GUIDELayoutEditor');
filename =guidetemplate(layout_ed.getFrame);


if ~isequal(filename, 0)
    guide(filename);
end

% ****************************************************************************
% update parent change
% ****************************************************************************
function out = changeparent(varargin)

out={};

objs = varargin{1};
parents = varargin{2};
for i=1:length(objs)
    set(objs{i},'Parent',parents{i});
end

% ****************************************************************************
% Make a copy of the given object
% ****************************************************************************
function out = copyGobject(varargin)

copyContents = varargin{1};
copyBuffer = varargin{2};
if isempty(copyBuffer)
    copyBuffer = newGuideFig;
else
    delete(get(copyBuffer,'children'));
end

newList = [];
for i=1:length(copyContents)
    keeppos = 0;  % for normalized units
    if strcmpi(get(copyContents{i},'units'), 'normalized')
        keeppos=1;
    end
    if keeppos
        mypos = localGetPixelPos(copyContents{i});
    end
    if isExternalControl(copyContents{i})
        newList(end+1) = copyExternalControl(copyContents{i}, copyBuffer);
    else
        newList(end+1) = copyobj(copyContents{i}, copyBuffer);
    end
    if keeppos
        localSetPixelPos(newList(end),mypos);
    end
end
newList = handle(newList);

out{1} = num2cell(newList);
out{2} = copyBuffer;

% ****************************************************************************
% Delete graphics objects
% ****************************************************************************
function out = deleteGobject(varargin)

items = length(varargin);

for i=1:items
    h= varargin{i};

    [out{i*2-1} out{i*2}] = getProperty(h);

    if isExternalControl(h)
        delete(get(h,'Peer'));
    end
    delete(h);
end


% ****************************************************************************
% Delete figure
% ****************************************************************************
function out = deleteFigure(varargin)

fig = varargin{1};

delete(fig);
out = [];

% ****************************************************************************
% Adjust the offset used in Paste or Duplicate
% ****************************************************************************
function offset = getPasteDuplicateOffset(varargin)

originals = varargin{1};
parents = varargin{2};
offset = [varargin{3}(1) -varargin{3}(2) 0 0];
type = varargin{4};

if strcmpi(type, 'paste')
    % adjust offset so that the new copy will appear from the top-left
    % corner of its parent
    parentpos = localGetPixelPos(parents(1));
    mypos = localGetPixelPos(originals{1});
    leftmost = mypos(1);    
    topmost = mypos(2) + mypos(4);
    for i=2:length(originals)
        mypos = localGetPixelPos(originals{i});
        if (mypos(1) < leftmost)
            leftmost = mypos(1);
        end
        if (mypos(2)+mypos(4) >topmost)
            topmost = mypos(2)+mypos(4);
        end
    end
    offset(1) = offset(1) - leftmost;
    offset(2) = offset(2) + (parentpos(4) - topmost);
else
    oldparent = get(originals{1},'Parent');
    newparent = parents(1);
    if (oldparent ~= newparent)
        oldparentpos = localGetPixelPos(oldparent);
        while (~strcmp(get(oldparent,'type'),'figure'))
            oldparent = get(oldparent,'Parent');
            oldparentpos = oldparentpos + localGetPixelPos(oldparent);
        end    
        newparentpos = localGetPixelPos(newparent);
        while (~strcmp(get(newparent,'type'),'figure'))
            newparent = get(newparent,'Parent');
            newparentpos = newparentpos + localGetPixelPos(newparent);
        end
        offset(1) = offset(1) + (oldparentpos(1) - newparentpos(1));
        offset(2) = offset(2) + (oldparentpos(2) - newparentpos(2));
    end
end


% ****************************************************************************
% Make a copy of the given object and add to the figure
% This function is called by both Paste and Duplicate
% ****************************************************************************
function out = duplicateGobject(varargin)

originals = varargin{1};
parents = varargin{2};
fig = getParentFigure(parents(1));
offset = getPasteDuplicateOffset(varargin{:});

% new uicontrols are created here. For external controls, the duplication
% is not done until the real controls get a change to create in createExternalControl

% dups = copyobj(originals{:}, parents);
origs = [];
dups = [];
tops = [];
filter.includeParent =1;
for i=1:length(originals)
    keeppos = 0;    % for normalized units
    if strcmpi(get(originals{i},'units'), 'normalized')
        keeppos = 1;
    end
    if keeppos
        mypos = localGetPixelPos(originals{i}); 
    end
    if isExternalControl(originals{i})
        origs(end+1) = originals{i};
        tops(end+1) = copyExternalControl(originals{i}, parents);        
        dups(end+1) = tops(end);
    else
        origs = [origs; guidemfile('findAllChildFromHere', originals{i}, filter)];        
        tops(end+1) = copyobj(originals{i}, parents);
        thisdups = guidemfile('findAllChildFromHere',tops(end), filter);
        dups = [dups;thisdups];
        for i=1:length(thisdups)
            set(thisdups(i), 'tag', nextTag(thisdups(i)));
        end
    end
    if keeppos
        localSetPixelPos(tops(end), mypos); 
    end
end
dups = handle(dups);

% update the callback properties of duplicated objects
guidemfile('chooseCopyCallbacks',fig, origs, dups);

% new external controls are created in localScanChildren
[out{1:5}] = localScanChildren(handle(tops), offset, filter);
out{6}=ismember(cell2mat(out{1}), tops);
markDirty(fig);


% ****************************************************************************
% Add callback stub to the mfile and open it in proper editor: M Editor or
% Inspector
% ****************************************************************************
function out = editCallback(varargin)

out=[];

fig = varargin{1};
hndls = varargin{2};
whichCb = varargin{3};

options = guideopts(fig);
if options.mfile & options.callbacks
    for i=1:length(hndls)
        obj = hndls{i};

        % write out this callback to the MFile, and scroll to it:
        guidemfile('setAutoCallback',obj, whichCb);
    end

    setappdata(fig, 'RefreshCallback', 1);
    [success, istemp] = saveBeforeAction(fig, 'editcallback');
    if isappdata(fig, 'RefreshCallback')
        rmappdata(fig, 'RefreshCallback');
    end

    if success
        guidemfile('scrollToCBSubfunction', fig,obj, whichCb);
    end
else
    % If not in mfile mode, go to this callback in the inspector,
    % and highlight it:
    com.mathworks.ide.inspector.Inspector.activateInspector;
    com.mathworks.ide.inspector.Inspector.getInspector.selectProperty(whichCb);
end


% ****************************************************************************
% utility for searching up the instance hierarchy for the figure ancestor
% ****************************************************************************
function fig = getParentFigure(h)

while ~isempty(h) & ~strcmp(get(h,'type'),'figure')
    h = get(h,'parent');
end
fig = h;

% ****************************************************************************
% check to see whether we need to force a save when one or more of callback
% type properties of figure or its children is %automatic.
% Called by layoutActivate
% ****************************************************************************
function status = needRefreshCallback(fig)

status = 0;

handles = [fig;allchild(fig)];
for i = 1:length(handles)
    callbacks = guidemfile('getCallbackProperties', handles(i));
    for j=1:length(callbacks)
        if (strcmp(guidemfile('AUTOMATIC'), get(handles(i), callbacks(j))))
            status =1;
            break;
        end
    end
    if status
        break;
    end
end


% ****************************************************************************
% get the status of the figure and/or m files related to a layout. Return as a
% structure cover: existence, dirty, writable?
% ****************************************************************************
function status = getGuiStatus(varargin)

fig = varargin{1};
layout_ed = getappdata(fig, 'GUIDELayoutEditor');
options = guideopts(fig);

if nargin>1
    figfilename = varargin{2};
else
    figfilename = get(fig,'filename');
end

% check figure file
figure.file      = true;
figure.saved     = false;
figure.exist     = false;
figure.dirty     = false;
figure.writable  = false;

if layout_ed.getDirty
    figure.dirty =true;
end
if ~isempty(figfilename)
    figure.saved =true;
    if exist(figfilename)
        figure.exist = true;
    end

    figure.writable = iswritable(figfilename);
end

% check m file
mfile.file     = false;
mfile.saved    = false;
mfile.exist    = false;
mfile.dirty    = false;
mfile.writable = false;

if options.mfile
    mfile.file = true;
    if ~isempty(figfilename)
        [p,f,e]= fileparts(figfilename);
        mfilename = fullfile(p,[f,'.m']);
        if  guidemfile('isMFileDirty',figfilename)
            mfile.dirty = true;
        end
        if exist(mfilename)
            mfile.exist = true;
            mfile.saved = true;
        end

        mfile.writable = iswritable(mfilename);
    end
end

status.figure = figure;
status.mfile  = mfile;

% ****************************************************************************
%
% ****************************************************************************
function out = getPropertyCallback(varargin)

handles = varargin{1};
hnumber = varargin{2};
for i=1:hnumber
    if (ishandle(handles{i}))
        [properties{1} properties{2}]  = getProperty(handle(handles{i}));
        out{3*i-2} = properties{1};
        out{3*i-1} = properties{2};
        out{3*i} = guidemfile('getCallbackProperties', handle(handles{i}));
    else
        out{3*i-2} = [];
        out{3*i-1} = [];
        out{3*i} = [];
    end
end



% ****************************************************************************
% get the properties of given graphical objects
% ****************************************************************************
function out = getProperties(varargin)

handles = varargin{1};
hnumber = varargin{2};
for i=1:hnumber
    if (ishandle(handles{i}))
        [out{2*i-1} out{2*i}] = getProperty(handles{i});
    else
        out{2*i-1} = [];
        out{2*i} = [];
    end
end

% ****************************************************************************
% get the properties of a graphical object
% ****************************************************************************
function [name, value] = getProperty(obj)

% For External control, the callback properties are added as instance
% proeprties on its uicontrol peer.

if ~isExternalControl(obj)
    properties = get(obj);
    if isfield(properties,'FileName')
        properties = rmfield(properties,'FileName');
    end
    name = fieldnames(properties);
    value = get(obj,name)';
else
    % get the callback properties on peer
    obj=handle(obj);
    callbacks = guidemfile('getCallbackProperties', obj);
    
    % get the real properties of external control
    % some of the ActiveX controls will produce error when try to get its
    % property list and certain property value. Use Try-Catch temporaryly
    try
        properties = get(obj.Peer);
    catch        
    end
    name = {};
    if (~isempty(properties))
        name = fieldnames(properties);
    end
    value ={};
    for i=1:length(name)
        try
            v = get(obj.Peer,char(name{i}));
        catch
            v = [];
        end
        value{end+1} =v;
    end
    % Tag proeprty is also needed for undo/redo
    name = {name{:} 'Tag'}';
    value ={value{:} get(obj,'Tag')}';
    
    % callback properties are always saved at the end, This order is
    % important in setProperty. 
    if ~isempty(callbacks)
        group1 = get(obj, callbacks)';
        name = {name{:} callbacks{:}}';
        value ={value{:} group1{:}}';
    end
end

% ****************************************************************************
% Check to see whether the correct m file can be found in MATLAB path
% popup PathUpdateDialog if cannot
% ****************************************************************************
function success = handleMfilePath(mfilename, frame)
import com.mathworks.mlwidgets.dialog.PathUpdateDialog;

success = 1;

[pname,fcn,ext] = fileparts(mfilename);

% see what MATLAB find
mfiles = which(fcn, '-all');

message=[];
flag = 0;
where = pwd;

if isempty(mfiles)
    flag =1;
else
    [p,f,e]= fileparts(mfiles{1});

    if ispc
        if ~strcmpi(mfilename, mfiles{1})
            if ~strcmpi(p,where)
                flag = 2;
            else
                flag =3;
            end
        end
    else
        if ~strcmp(mfilename, mfiles{1})
            if ~strcmp(p,where)
                flag = 2;
            else
                flag =3;
            end
        end
    end
end

if (flag>0)
    if flag==1
        message = sprintf('File %s\nis not in current directory or MATLAB path', mfilename);
    elseif flag==2
        message = sprintf('File %s\ncan not be correctly found in MATLAB path', mfilename);
    else
        message = sprintf('Another M File with the same name: %s\nexists in current directory: %s', [fcn, '.m'], where);
    end

    choiceTitle = xlate('To continue activation, select one of the following:');
    dialog = PathUpdateDialog(frame, 'GUIDE', message, choiceTitle);

    if flag == 2
        dialog.enableAddPathBottom(0);
    elseif flag==3
        dialog.enableAddPathBottom(0);
        dialog.enableAddPathTop(0);
    end

    selection= dialog.showDialog;

    if selection == PathUpdateDialog.CHOICE_CANCEL
        success = 0;
        return;
    else
        if selection == PathUpdateDialog.CHOICE_CHANGEPATH
            cd(pname);
        elseif selection == PathUpdateDialog.CHOICE_ADDPATHTOP
            path(pname, path);
        else
            path(path,pname);
        end
    end
end


% ****************************************************************************
% Activate the figure in layout
% ****************************************************************************
function out = layoutActivate(varargin)

out =[];

fig = varargin{1};
oldName = get(fig,'FileName');

% First: save layout if needed before activation
[success, istemp]= saveBeforeAction(fig, 'activate');
if ~success  return; end

% gui options may have been changed in saveBeforeAction for tempalte
% get updated options here
options = guideopts(fig);
layout_ed = getappdata(fig, 'GUIDELayoutEditor');

% May did a save as above thus fig file may have changed
filename = get(fig, 'filename');
[pname, fcn, ext] = fileparts(filename);
mfilename = fullfile(pname, [fcn, '.m']);

% Second: check and change MATLAB path so that correct mfile can be found
% check whether need to add path to find the correct mfile
status = getGuiStatus(fig);
if status.mfile.file
    frame = layout_ed.getFrame;
    if ~handleMfilePath(mfilename,frame);
        return;
    end
end

%Third: ready to activate now. Involved files are saved or do not need to save
options.active_h = unique(options.active_h(ishandle(options.active_h)));
if options.singleton & options.mfile
    % if we're in singleton mode, make sure to delete all
    % other copies so that the MFile actually creates a new
    % copy instead of raising the last one:
    delete(options.active_h);
    options.active_h = [];
end

% if we're in MFile mode, and we've got the MFile, then
% activate by calling the MFile (for highest fidelity)
if options.mfile & ~istemp
    % keep track of the new figure handle
    figs_before = allchild(0);

    try
        feval(fcn);
    catch
        errordlg(sprintf('Error while attempting to activate figure.\n%s',lasterr),...
            'GUIDE');
    end
    % capture the new handle (if any), by comparing the root's
    % list of children before and after calling the MFile.
    % Don't assume the MFile returns the figure handle, because
    % users might change that!
    options.active_h = [options.active_h setdiff(allchild(0), figs_before)];
else    
    % because ActiveX controls are saved in individual files at this time,
    % instead of saving in FIG file, need to change directory.
    current = pwd;
    cd(pname);
    new_fig = hgload(filename);
    cd(current);

    options.active_h(end + 1) = new_fig;
    % If we're in "companion mfile" mode, and we activate
    % before having done a SAVE, many of our callbacks will
    % have strings that error out.  Just clear out those
    % callbacks in the "activated" figure:
    % PS - I don't think we need this anymore, as we now
    % force a save upon the first activate.
    if options.mfile & istemp
        guidemfile('loseAutoCallbacks', new_fig);
    end
end

if istemp
    delete([pname, filesep, fcn, '*.*']);
    set(fig,'filename', oldName);
end

guideopts(fig, options);


% ****************************************************************************
% Save layout as figure/m file
% ****************************************************************************
function out = layoutSave(varargin)
import com.mathworks.mwt.dialog.MWAlert;
import com.mathworks.ide.layout.MfileOverwriteDialog;

out{1} = 0;

fig = varargin{1};
if nargin > 1
    filename = varargin{2};
else
    filename = get(fig, 'filename');
end
if isempty(filename)
    % Do saveAs if has not saved
    out{1} = guidefunc('saveAs',fig);
    return;
end
    layout_ed = getappdata(fig, 'GUIDELayoutEditor');
    frame = layout_ed.getFrame;

    % Get the status of all files involved in saving. Do checking before
    % do save to ensure that saving is necessary and will be successful
    status = getGuiStatus(fig, filename);

    source = get(fig, 'filename');
    target = filename;

    % First, if saving to itself and all files existing and not dirty, return.
    % Otherwise, if file(s) is missing, regenerate if needed. If dirty save.
    % If clean but from adding of callback, still save.
    % If it is from opening template, handle it here.
    needsave = 1;
    isoverwrite = 0;
    if ispc
        isoverwrite = strcmpi(target, source);
    else
        isoverwrite = strcmp(target, source);
    end
    if isoverwrite
        if isappdata(0, 'templateFile')
            savetemplate = getappdata(0,'templateFileSave');
            srcfigfile = getappdata(0,'templateFile');
            [sp, sfile ,se] = fileparts(srcfigfile);
            srcmfile = fullfile(sp, [sfile, '.m']);

            rmappdata(0,'templateFile');
            rmappdata(0,'templateFileSave');

            if savetemplate
                [p, file ,e] = fileparts(target);
                mf = fullfile(p, [file, '.m']);
                guidemfile('renameCallbacks', findall(fig),  sfile, file);
                replaceMfileString(mf, sfile, file, 'loose', 'comment');
                replaceMfileString(mf, sfile, file, 'loose', 'function');
                replaceMfileString(mf, ['@',sfile], ['@',file], 'strict', 'code');
            else
                needsave =0;

                guidemfile('renameCallbacks', findall(fig),  sfile);

                % set flag to indicate template nosave mode. Used by
                % updateFile in guidemfile
                s = guideopts(fig);
                if isfield(s, 'lastSavedFile')
                    s = rmfield(s, 'lastSavedFile');
                end
                s.template = srcfigfile;
                guideopts(fig, s);

                % delete temperary files
                tempfigfile= get(fig,'FileName');
                [tp, tfile ,te] = fileparts(tempfigfile);
                tempmfile = fullfile(tp, [tfile, '.m']);

                % change filename to empty so that it is not added to MRU list
                set(fig,'FileName','');
                set(fig, 'Name', 'Untitled');

                delete(tempfigfile);
                delete(tempmfile);
           end
        elseif ~status.figure.exist | (status.mfile.file & ~status.mfile.exist)
            % regenerate FIG and/or M-file
            if status.mfile.file
                % reset existing callbacks to AUTOMATIC, only those
                % callback properties whose value is generated by GUIDE
                % already will be changed here.
                [p, file ,e] = fileparts(source);
                list = [fig;findall(fig)];
                list =handle(list);
                for i=1:length(list)
                    h= list(i);
                    callbacks = guidemfile('getCallbackProperties', h);
                    if ~isempty(callbacks)
                        head = [file,'(''', get(h,'Tag')];
                        for i=1:length(callbacks)
                            value = get(h, callbacks(i));
                            if strncmp(value, head, length(head))
                                guidemfile('setAutoCallback', h,char(callbacks(i)));
                            end
                        end
                    end
                end
            end
        else
            if isempty(getappdata(fig, 'RefreshCallback')) & ~status.figure.dirty ...
               & (status.mfile.file & ~status.mfile.dirty)
                needsave = 0;
            end
        end
    else
        % if save to different file but target figure file is the figure file
        % of one of the GUIs opened in GUIDE, show dialog and return
        match = com.mathworks.ide.layout.LayoutEditor.isGUIOpen(target);
        if match
            needsave = 0;
            prompt = xlate('File: ');
            message =xlate('is already open in GUIDE. Cannot save to an open GUI.');
            mwa = MWAlert(frame, 'GUIDE', [prompt,10, target, 10, message], MWAlert.BUTTONS_OK, [], MWAlert.ERROR_ICON);
            mwa.setVisible(1);
        end
    end
    if ~needsave
        return;
    end

    % Second, if saving to different file and target exists, ask for
    % confirmation. Only m file is checked at this time because
    % confirmation for overwriting figure file is done in uiputfile
    % presently. These two can be combined here if uiputfile can offer the
    % choice to turn the checking off
    [p, f, e] = fileparts(filename);
    mfilename= fullfile(p,[f, '.m']);
    if ~isoverwrite
        flist = '';
        found=0;
%         if status.figure.exist
%             flist = [flist, filename];
%             found =found+1;
%         end
        if status.mfile.file & status.mfile.exist
            flist = [flist, mfilename, sprintf('\n')];
            found = found+1;
        end
        if found
            if found==1
                prompt = xlate('File:');
                message =xlate('already exists, Do you want to replace it or append to it?');
%             else
%                 prompt = 'Files:';
%                 message = 'already exist, Do you want to replace them?';
            end
            mwa = MfileOverwriteDialog(frame, 'GUIDE', [prompt,sprintf('\n'), flist, message]);
            mwa.setVisible(1);
            wish= mwa.getReply;

            if wish == MfileOverwriteDialog.REPLACE
                % discard the callbacks in the target m file
                if status.mfile.file
                    delete(mfilename);
                end
            elseif wish == MfileOverwriteDialog.CANCEL
                return;
            end
        end
    end

    % Third, check to see whether we have the write permission of all the files
    % If not, give user the chance to save to another file.
    flist = '';
    found = 0;

    fnames=[];
    if ~status.figure.writable
        flist = [flist, filename, sprintf('\n')];
        found = found+1;
        fnames{end+1}= filename;
    end
    if status.mfile.file & ~status.mfile.writable
        flist = [flist, mfilename,sprintf('\n')];
        found = found+1;
        fnames{end+1}= mfilename;
    end
    if found
        if found==1
            prompt = xlate('File:');
            message =xlate('is read only on disk');
        else
            prompt = xlate('Files:');
            message =xlate('are read only on disk');
        end
        mwa = MWAlert(frame, 'GUIDE', [prompt,sprintf('\n'), flist, message], MWAlert.BUTTONS_SAVEASOVERWRITECANCEL);
        wish= mwa.getReply;

        if wish == MWAlert.OK
            out{1}=guidefunc('saveAs',fig);
            return;
        elseif wish == MWAlert.NO
            % pressed overwrite
            fclist = '';
            found =0;
            for i=1:length(fnames)
                fname = fnames{i};
                com.mathworks.util.NativeJava.changeFileAttribute(fname, 'w');
                if ~iswritable(fname)
                    fclist = [fclist, fname,sprintf('\n')];
                    found = found+1;
                end
            end
            if found==1
                prompt = xlate('Error writing file:');
            else
                prompt = xlate('Error writing files:');
            end
            if found
                MWAlert(frame, 'GUIDE',[prompt,sprintf('\n'), fclist, xlate('Check if directory is read only.')], MWAlert.BUTTONS_OK);
                return;
            end
        else
            % pressed cancel
            return;
        end
    end

    %remove from appdata ro prevent it from being saved in figure
    if ~isempty(getappdata(fig, 'RefreshCallback'))
        rmappdata(fig, 'RefreshCallback');
    end

    % Fourth, it is OK to save
    % This is the only place that Guide layout is saved to its figure and mfile
    saveGuideFig(fig, filename);

    % update layout if not saving to temp file from layoutActivate
    if isempty(getappdata(fig, 'ActivateTemp'))
        layout_ed.writeCompleted(java.lang.String(filename));
    end

    out{1} =1;


% ****************************************************************************
% Save layout as figure/m file
% ****************************************************************************
function out = layoutSaveAs(varargin)

out{1} = 0;

fig = varargin{1};

% regenerate FIG and/or M-file if needed
[success, istemp] = saveBeforeAction(fig, 'saveas');

if success
    layout_ed = getappdata(fig, 'GUIDELayoutEditor');
    default_name = get(fig,'filename');
    [oldp, oldf, olde] = fileparts(default_name);
    first=0;
    if isempty(default_name)
        first=1;
        default_name = [char(layout_ed.getRuntimeName) '.fig'];
    end

    % get user input of destination file name
    [figfile, filterindex] = getOutputFilename(fig, default_name,'Save As:', char(layout_ed.getRuntimeName));

    % save layout
    if (~isempty(figfile))
        % change figure Name property to its FileName so that is saved
        oldname = get(fig, 'Name');
        [path, filename, ext] = fileparts(figfile);
        if first | strcmpi(oldname, oldf)
            set(fig, 'Name', filename);
        end

        out{1}= guidefunc('save',fig,figfile);

        % change the Name back if it is not saved
        if ~out{1}
            set(fig, 'Name', oldname);
        end
    end
end

% ****************************************************************************
% Save layout in other format than the latest one. Choices are:
%   1. M only format.
% ****************************************************************************
function out = layoutExport(varargin)
import com.mathworks.mwt.dialog.*;

out{1} = 0;

% save layout if needed
fig = varargin{1};
status = getGuiStatus(fig);

[success, istemp] = saveBeforeAction(fig, 'export');

if success & ~istemp
    filename = get(fig, 'filename');
    options = guideopts(fig);
    [path, infilename, ext] = fileparts(filename);

    addguimain = 1;

    exeindex = -1;
    title = 'Export:';
    filter = {'*.m',  'Single M-file (*.m)'};
%     if exist('mcc','file') == 3
%         filter = [filter; {'*.exe',  'Standalone EXE (*.exe)'}];
%         exeindex = length(filter);
%     end

    % get destination file name
    [exportmfile, filterindex] = getOutputFilename(fig, filter, title, [infilename '_export.m']);

    % user pressed Cancel if file name is empty
    if ~isempty(exportmfile)
        % form temp m file name if user selected exporting to EXE
        if filterindex == exeindex
            exefile = exportmfile;
            [p,f,e]= fileparts(exportmfile);
            exportmfile = fullfile(p, [f '.m']);
        end

        if options.mfile
            % m file and figure file exist
            [p,f,e]= fileparts(filename);
            mfilename = fullfile(p,[f,'.m']);

            % may be used to control whether the exported m file includes
            % gui_main. It is added all the time now.
            addguimain = 1;

            % check to see whether the user selected to export the GUI to the
            % same m file the GUI is using.
            if ispc
                same = strcmpi(mfilename, exportmfile);
            else
                same = strcmp(mfilename, exportmfile);
            end

            % if not same, delete the target m file, make a copy of the m file
            % of this GUI
            if ~same
                if exist(exportmfile)
                    delete(exportmfile);
                end
                [status,msg] = copyfile(mfilename, exportmfile, 'writable');
		        fileattrib(exportmfile, '+w');
                if status == 0
                    error(msg)
                end
            end

            % replace old filename with new filename
            [path, outfilename, ext] = fileparts(exportmfile);
            % first replace infilename in comments
            replaceMfileString(exportmfile, infilename, outfilename, 'loose', 'comment');

            % second replace infilename in function definition
            replaceMfileString(exportmfile, infilename, outfilename, 'strict', 'function');

            % third replace infilename in function handle structure
            replaceMfileString(exportmfile, ['@', infilename], ['@', outfilename], 'strict', 'code');

            % These options only work for FIG/M mode
            if options.release>=13
                choices.createFigureInvisible=1;
            end
            choices.appendToFile=1;
            choices.addHeaderComment=0;
            choices.renameCallbacks=1;
            choices.functionPrefix = getExportHeader(fig, exportmfile);
            choices.functionSuffix = getExportFooter(fig);
        end

        % These options work for both FIG only and FIG/M modes
        choices.absorbGUIDEOptions=1;
        choices.limitForMatFile=256;
        choices.excludedPropertyList = getExclusionPropertyList;
        choices.showMessageForMATFile = 1;
        
        % save exportmfilename in application data that is used to support
        % ActiveX
        myoptions = 'GUIDEOptions';
        myfield = 'lastSavedFile';
        options = getappdata(fig, myoptions);
        needrestore = 0;
        if ~isempty(options)
            if isfield(options, myfield)
                needrestore =1;
                oldvalue = options.(myfield);
                options.(myfield) = exportmfile;
                setappdata(fig, myoptions, options);
            end
        end
        
        % Add layout code
        printdmfile(fig, exportmfile, choices);

        % restore application data
        if needrestore
            options.(myfield) = oldvalue;
            setappdata(fig, myoptions, options);
        end
        
        % update function handle array in the initialization code.
        updateGuiHeader(fig, exportmfile);

        % insert gui_main after replaceMfileString to prevent muiltiple
        % replacement and after printdmfile so that checking for layoutFcn
        % returns true.
        if addguimain
            insertGuiMain(exportmfile);
        end

        if filterindex == 1
            com.mathworks.mlservices.MLEditorServices.reloadDocument(java.lang.String(exportmfile),0);
            com.mathworks.mlservices.MLEditorServices.openDocument(java.lang.String(exportmfile));
        elseif filterindex == exeindex
            % user requested stand alone exe
            [filepath, filename, ext] = fileparts(exportmfile);

            current =pwd;
            % create output directory for generated c and h files
            outdir = fullfile(filepath,[filename '_files']);
            if ~exist(fullfile(filepath,[filename '_files']),'dir')
                [status, msg] = mkdir(filepath,[filename '_files']);
                if status == 0
                    error(msg)
                end
            end

            NL = sprintf('\n');
            checkthis = ['please see the help on MATLAB compiler. You can manually compile this file to find why:', NL, exportmfile];
            try
                % have to change directory, mcc is not working properly
                % under our situation: if export to another directory other
                % than the pwd, three directories are involved.
                cd(filepath);
                % run the compiler
                feval('mcc','-B','sgl','-I',[filepath filesep], '-o',['..' filesep filename], '-d',outdir,filename);
                cd(current);

                % if succeed, the generated EXE may not fully work, if the
                % GUI m code calling some MATLAB function hidden in a string, that
                % function will not be detected and thus compiled by mcc
                msgbox(['File: ', exefile, NL, 'was generated successfully', NL, NL, ...
                        ['If it does not work properly, ', checkthis]], 'GUIDE','help');
            catch
                cd(current);
                errordlg(['File: ', exefile, NL, 'could not be generated successfully.', NL, NL, ...
                         checkthis], 'GUIDE');
            end
        end
    end
end

% ****************************************************************************
% Only insert @mfilename_LayoutFcn at this time
% ****************************************************************************
function updated = updateGuiHeader(fighandle, mfilename)

updated = 0;

[fpath, fname, fext]= fileparts(mfilename);
contents = fileread(mfilename);

% set correct gui_LayoutFcn
NL = sprintf('\n');
signature = '''gui_LayoutFcn''';
head = strfind(contents, signature);
tail = [];
if ~isempty(head)
    % search for the line end
    for i=(head(1)+length(signature)):length(contents)
        if contents(i) == NL
            tail = i;
            break;
        end
    end
end

if ~isempty(head) & ~isempty(tail)
    new_contents = [contents(1:head(1)-1), ...
            '''gui_LayoutFcn'',  @', fname,'_LayoutFcn, ...', ...
            contents(tail:end)];
    % don't use 'wt', it puts too many CR's in.
    fid=fopen(mfilename, 'w');
    if fid > 0
        fprintf(fid, '%s', new_contents);
        fclose(fid);
        updated =1;
    end
end



% ****************************************************************************
% Insert gui_main.m script file into the given M file if that file uses it
% ****************************************************************************
function inserted = insertGuiMain(mfilename)

inserted = 0;

% insert gui_mainfcn so we have a single file
main = 'gui_mainfcn';
[fpath, fname, fext]= fileparts(mfilename);
contents = fileread(mfilename);

% insert guimainfcn at the end of the mfilename if it is called
where = strfind(contents, main);

% if we found the gui_main call, replace it
if ~isempty(where)
    NL = sprintf('\n');

    % read gui_main from file
    guimain = fileread(which(main));

    % remove comments from guimain
    guimain = removeComments(guimain);

    % rename 'UNTILED' in guimainfcn to the export file name
    guimain = guidemfile('stringReplace', guimain, 'UNTITLED', upper(fname), 'strict', 'comment');

    % add together
    new_contents = [contents, NL, NL, ...
            '% --- Handles default GUIDE GUI creation and callback dispatch', NL, ...
            guimain, NL];

    % don't use 'wt', it puts too many CR's in.
    fid=fopen(mfilename, 'w');
    if fid > 0
        fprintf(fid, '%s', new_contents);
        fclose(fid);
        insertes =1;
    end
end


% ****************************************************************************
% replace all the occurences of the given string in m file with a new string
% and open and/or bring it to front in m file editor
%       filename: the m file whose contents will be changed
%       sourcestring: the string to search for in m file
%       targetstring: the string replacing sourcestring
%
%       policy: 'strict' or 'loose'. Used to do string-match. Default is 'loose'.
%
%       scope: 'comment', 'function', 'code', or 'all'. Indicates where to look
%               for sourcestring. 'comment' will only replace string in comments,
%               'function' replacing string in function definition, 'code'
%               replacing string in real code. 'all' looks everywhere.
%               Default is 'all'.
% ****************************************************************************
function replaceMfileString(filename, sourcestring, targetstring, policy, scope)

if nargin < 4
    policy ='loose';
end

if nargin < 5
    scope ='all';
end

if exist(filename)
    [path, file,ext] = fileparts(filename);
    if strcmp(ext,'.m')
        mcode = fileread(filename);

        % replace old filename with new name
        mcode = guidemfile('stringReplace', mcode, sourcestring, targetstring, policy, scope);

        % update version string
        mcode = guidemfile('updateVersionString', targetstring, mcode);

        fid = fopen(filename,'w');
        fprintf(fid,'%s',mcode);
        fclose(fid);
    end
end


% ****************************************************************************
% returns that part of the input string after removing the first comment
% block. The first comment block starts from the first '%' to the first
% character that is not in the comments or empty line after the first '%'
% ****************************************************************************
function body = removeComments(contents)

body ='';

% search for the first '%'
found = 0;
for i=1:length(contents)
    if contents(i) == '%'
        found = i;
        break;
    end
end

if found
    body = contents(1:found-1);
    contents = contents(found:end);

    NL = sprintf('\n');
    if ~isempty(contents)
        tails = find(contents==NL);
        if ~isempty(tails)
            head = 1;
            for i=1:length(tails)
                thisline = strjust(contents(head: tails(i)), 'left');
                if ~isempty(thisline) & thisline(1) ~='%' & thisline(1) ~= NL
                    body = [body, NL, contents(head: end)];
                    break;
                else
                    head = tails(i)+1;
                end
            end
        end
    end
else
    body = contents;
end


% ****************************************************************************
% returns a cell array of the properties that should be excluded from the
% exported layout code of a GUI for certain types
% ****************************************************************************
function list = getExclusionPropertyList()

% for figure type
figurelist.type = 'figure';
figurelist.properties{1} = 'FileName';
list{1} = figurelist;

buttongrouplist.type = 'uitools.uibuttongroup';
buttongrouplist.properties{1}='Listeners';
list{2} = buttongrouplist;


% ****************************************************************************
% returns the commands that should be added before the exporting layout
% code of a GUI
% ****************************************************************************
function header = getExportHeader(figure, filename)

options = guideopts(figure);

[path, name, ext] = fileparts(filename);

returnname ='h1';
NL = sprintf('\n');
functionline = ''; 
if options.release < 13 
    functionline =['function ', returnname, ' = openfig(filename, policy, varargin)', NL, ... 
                   returnname, ' = ', name, '_LayoutFcn(policy);', NL, NL, ... 
                  ]; 
end 

functionline =[functionline, ... 
               'function ', returnname, ' = ', name, '_LayoutFcn(policy)']; 

% if options.release < 13
%     functionline =['function ', returnname, ' = openfig(filename, policy)'];
% else
%     functionline =['function ', returnname, ' = ', name, '_LayoutFcn(policy)'];
% end

header =[...
    NL, NL, ...
    '% --- Creates and returns a handle to the GUI figure. ', NL, ...
    functionline, NL, ...
    '% policy - create a new figure or use a singleton. ''new'' or ''reuse''.' NL, NL, ...
    'persistent hsingleton;',NL,...
    'if strcmpi(policy, ''reuse'') & ishandle(hsingleton)',NL,...
    '    h1 = hsingleton;',NL,...
    '    return;',NL,...
    'end',NL];


% ****************************************************************************
% returns the commands that should be added after the exporting layout
% code of a GUI
% ****************************************************************************
function footer = getExportFooter(figure)

NL = sprintf('\n');

footer=[...
        NL,'hsingleton = h1;',NL];

% ****************************************************************************
% Convert the object type from string to integer ID
% ****************************************************************************
function typeID = localGetTypeID(obj)

typeID = -1;
typeStr = get(obj,'type');
if isa(handle(obj),'uitools.uibuttongroup')
    typeID = 13;
elseif isa(handle(obj),'uipanel')
    typeID = 12;
elseif isa(handle(obj),'uicontainer')
    typeID = 11;
elseif strcmp(typeStr, 'axes') ~= 0
    typeID = 10;
elseif strcmp(typeStr,'uicontrol') ~= 0
    styleStr = get(obj,'style');
    if strcmp(styleStr,'pushbutton') ~= 0
        typeID = 0;
    elseif strcmp(styleStr,'slider') ~= 0
        typeID = 1;
    elseif strcmp(styleStr,'radiobutton') ~= 0
        typeID = 2;
    elseif strcmp(styleStr,'checkbox') ~= 0
        typeID = 3;
    elseif strcmp(styleStr,'edit') ~= 0
        typeID = 4;
    elseif strcmp(styleStr,'text') ~= 0
        typeID = 5;
    elseif strcmp(styleStr,'frame') ~= 0
        typeID = 6;
    elseif strcmp(styleStr,'popupmenu') ~= 0
        typeID = 7;
    elseif strcmp(styleStr,'listbox') ~= 0
        typeID = 8;
    elseif strcmp(styleStr,'togglebutton') ~= 0
        typeID = 9;
    end
end

% ****************************************************************************
% Return the position value in pixel unit of the given object
% ****************************************************************************
function pixelPos = localGetPixelPos(obj)
saveUnits = get(obj, 'units');
set(obj, 'units', 'pixels');
pixelPos = get(obj, 'position');
set(obj, 'units', saveUnits);


% ****************************************************************************
% Set the position value of the given object in pixel unit
% ****************************************************************************
function localSetPixelPos(objs, pos)

for i=1:length(objs)
    if iscell(objs)
        obj = objs{i};
    else
        obj = objs(i);
    end
    where= pos(1,((i-1)*4+1):(i*4));
    saveUnits = get(obj, 'units');
    set(obj, 'units', 'pixels');
    size = get(obj,'pos');
    set(obj, 'position', where);
    set(obj, 'units', saveUnits);
    
    if isExternalControl(obj)
        moveExternalControl(obj, where);
    end

    updateChildrenWhenResize(obj, [where(3)-size(3) where(4)-size(4)]);
end

% ****************************************************************************
% Change children position when container position changed
% ****************************************************************************
function out = updateChildrenPosition(objs, oldposs)
out = {0};
for i=1:length(objs)
    obj = objs{i};
    oldpos = oldposs{i};
    if iscontainer(obj)
        pos = localGetPixelPos(obj);
        if (pos(4) ~= oldpos(4))
            out = {1};
            updateChildrenWhenResize(obj, [pos(3)-oldpos(3), pos(4)- oldpos(4)]);
        end
    end
end

% ****************************************************************************
% 
% *************************************************************************
function out = iscontainer(obj)

out =0;
if isa(handle(obj),'uicontainer')
    out =1;
elseif isa(handle(obj),'uipanel')
    out =1;
elseif strcmp(get(obj,'type'), 'figure')
    out =1;    
end

% ****************************************************************************
% Return the value of the string property of given object
% ****************************************************************************
function str = localGetString(obj)
str = '';
type = get(obj,'Type');

if strcmpi(type, 'uicontrol')
    str = get(obj, 'string');
elseif isa(handle(obj),'uitools.uibuttongroup')
    str = get(obj, 'title');    
elseif isa(handle(obj),'uipanel')
    str = get(obj, 'title');    
end

if ~iscell(str) & min(size(str)) > 1
    str = cellstr(str);
end

% ****************************************************************************
% Find all the children of given OBJECTS. Return a cell array of child, Adapter,
% and MObjectProxy in the order for each cild.
% This function is called by:
%       duplicateGobject
%       readSavedFigure
%       snapshotFigure
% ****************************************************************************
function [hndl,adpt,prox, peer, parent] = localScanChildren(objects, offset, filter)

kids =[];
for i=1:length(objects)
    kids = [kids; guidemfile('findAllChildFromHere',objects(i), filter)];
end

limit = length(kids);
hndl = cell(limit,1);
adpt = cell(limit,1);
prox = cell(limit,1);
peer = cell(limit,1);
parent  = cell(limit,1);

for i = 1:limit
    obj = kids(i);
    myparent = get(obj, 'Parent');
    position = localGetPixelPos(myparent);
    parentHeight = position(4);
    
    %create external controls if it has not been created
    if isExternalControl(obj)
        info = getExternalControlInfo(obj);
        if info.Runtime
            control = createExternalControl(myparent, info.Type, obj);
        else
            control = info.Instance;
        end
    end

    % update position if needed for the top level objects
    if ~isempty(find(objects == obj))
        pos = localGetPixelPos(obj);
        if ~isempty(offset)
            pos = pos + offset;
            localSetPixelPos(obj, pos);
        end
    end

    parent{i} = requestJavaAdapter(myparent);    
    if isExternalControl(obj)
        info = getExternalControlInfo(obj);
        hndl{i} = obj;
        adpt{i} = requestJavaAdapter(control);
        peer{i} = requestJavaAdapter(obj);
        str=[];
        str{1} = info.ProgID;
        str{2} = info.Name;
        prox{i} = com.mathworks.ide.layout.AControlProxy(0,str,peer{i},parentHeight);
    else
        type = get(obj,'Type');
        typeID = localGetTypeID(obj);
        str = localGetString(obj);

        % do not delete axes children
        %if strcmpi(type, 'axes')
            % contents = get(obj,'children');
            % if ~isempty(contents)
            % this is where I delete axes children
            %    delete(contents);
            % end
        %end
        hndl{i} = obj;
        adpt{i} = requestJavaAdapter(hndl{i});
        peer{i} = adpt{i};
        prox{i} = com.mathworks.ide.layout.GObjectProxy(typeID,str,adpt{i},parentHeight);
    end

    %add tag property change listener
    initLastValidTagProperty(obj);
end


% ****************************************************************************
% Move graphics objects
% ****************************************************************************
function out = moveGobject(varargin)

localSetPixelPos(varargin{1}, varargin{4});
for i=1:length(varargin{1})
    [out{2*i-1} out{2*i}] = getProperty(varargin{1}{i});
end

% *************************************************************************
% ***
% Mark the layout corresponding to the given figure as dirty
% ****************************************************************************
function markDirty(fig)

layout_ed = getappdata(fig, 'GUIDELayoutEditor');
layout_ed.setDirty(1);

% ****************************************************************************
% Move graphics objects backward in the stack order for rendering
% ****************************************************************************
function out = moveGobjectOrder(varargin)

out=[];

obj = varargin{1};
direction = varargin{2};
uistack(double(obj), direction);

% ****************************************************************************
% Move graphics objects backward in the stack order for rendering
% ****************************************************************************
function out = moveGobjectBackward(varargin)

out=[];

items = length(varargin)/2;
for i=1:items
    obj = varargin{i*2-1};
    step = varargin{i*2};
    uistack(double(obj),'down',step);
end


% ****************************************************************************
% Move graphics objects forward in the stack order for rendering
% ****************************************************************************
function out = moveGobjectForward(varargin)

out=[];

items = length(varargin)/2;
for i=1:items
    obj = varargin{i*2-1};
    step = varargin{i*2};
    uistack(double(obj),'up',step);
end

% ****************************************************************************
% Loads or creates a figure, initializing it for internal use by GUIDE. If a
% filename is specified, it loads the figure from that file, otherwise it
% creates a new figure.
% ****************************************************************************
function fig = newGuideFig(layout_ed, filename)
 
if nargin == 2 & ~isempty(filename)
    %Load figure using hgload. For template in nonsaving mode, the file(s)
    %is in the system TEMP directory. Currently, we have to change
    %directory to where the GUI file(s) is before calling hgload because
    %any set creatFcn will be called by hgload and the GUI file(s) may not
    %be on MATLAB path. The figure is set to invisible.
    [p,f,e] = fileparts(filename);
    if isempty(e)
        e = '.fig';
    end
    filename = fullfile(p, [f, e]);

    targetpath = p;
    istemplate =0;
    istemplatesave =0;
    current =pwd;
    if isappdata(0, 'templateFile')
        istemplate =1;
        istemplatesave = getappdata(0, 'templateFileSave');
        [templatedir, f, e] = fileparts(getappdata(0, 'templateFile'));
        targetpath = templatedir;
    end

    cd(targetpath);
    overrides.Visible = 'off';
    overrides.IntegerHandle = 'off';
    [fig, old_vals] = hgload(filename, overrides);
    cd(current);

    % set the created figure property correctly to indicate that it is a
    % GUIDE layout figure.
    if isfield(old_vals{1}, 'Visible')
        vis = old_vals{1}.Visible;
    else
        vis = 'on';
    end
    if isfield(old_vals{1}, 'IntegerHandle')
        intHandle = old_vals{1}.IntegerHandle;
    else
        intHandle = 'on';
    end

    setappdata(fig, 'GUIDELayoutEditor', layout_ed);
    p = schema.prop(fig, '__GUIDEFigure', 'double');
    set(fig, 'visible', vis);
    set(fig, 'integerhandle', intHandle);

    % If it is from template, M-files and callback properties of figure and
    % uicontrols need to be updated to point to the correct M-file if it is
    % opened in saving mode, or change to AUTOMATIC if it is opened in
    % nonsaving mode. This is done by calling 'Save'. In template nonsaving
    % mode, the file(s) under system TEMP directory are deleted.
    if istemplate
        guidefunc('save', fig, filename);
        if ~istemplatesave
            layout_ed.setLayoutUntitled;
        end
    end

    % Set the GUIDE internal flags properly to refelct the following two
    % things:
    %       1. GUI is in FIG only or FIG/M-file format
    %       2. The last M-file that this GUI saved to
    options = guideopts(fig);
    % Set active_h to [] if it is not since this is loaded from Fig file 
    % and we do not have an activated GUI yet. There may already be an open 
    % figure for this GUI by running the GUI M-file directly, it will be 
    % picked up when activating. 
    options.active_h =[]; 

    if istemplate & ~istemplatesave
        figFile = options.template;
        [p,f,e]= fileparts(figFile);
        mFile = fullfile(p, [f,'.m']);
    else
        figFile = get(fig,'filename');
        [path,name,ext]=fileparts(figFile);
        mFile = fullfile(path, [name '.m']);
    end

    if ~exist(mFile)
        options.mfile = 0;
        if isfield(options, 'lastSavedFile')
            options = rmfield(options, 'lastSavedFile');
        end
    end
    if options.mfile & ~istemplatesave
        % update the lastSavedFile saved in figure file in case the GUI
        % files were moved/copied to another location after creation
        options.lastSavedFile = mFile;
    end
    guideopts(fig, options);

else % create blank figure, don't load from FIG-file
    intHandle = 'off';
    vis = 'on';

    fig = figure('visible','off',...
        'menubar','none',...
        'numbertitle','off',...
        'handlevisibility','callback',...
        'integerhandle', 'off',...
        'name','Untitled',...
        'units','character',...
        'resize','off');

    % store this release number if one is not there already
    options = guideopts(fig);
    options.release = getGuiReleaseNumber; 
    guideopts(fig, options);

    if nargin > 0
        setappdata(fig, 'GUIDELayoutEditor', layout_ed);
    end
    p = schema.prop(fig, '__GUIDEFigure', 'double');
    set(fig, 'visible', vis);
    set(fig, 'integerhandle', intHandle);
end

% get system color if it is set
options = guideopts(fig);
if options.syscolorfig
    set(fig,...
        'color', get(0, 'defaultuicontrolbackgroundcolor'));
end

if isequal(getappdata(0, 'MathWorks_GUIDE_testmode'),1)
    options.mfile = 0;
    guideopts(fig, options);
end

%add tag property listener
initLastValidTagProperty(fig);


% ****************************************************************************
% utility for returning the next unique tag for any object
% ****************************************************************************
function tag = nextTag(obj)

fig = getParentFigure(obj);
if isempty(fig)
    tag = '';
else
    options = guideopts(fig);
    if isExternalControl(obj)
        control = getExternalControlInfo(obj);
        objType = control.Type;
    else
        objType = get(obj,'type');
        if(strcmp(objType,'uicontrol'))
            objType = get(obj,'style');
        end
    end
    if ~isfield(options.taginfo,objType)
        options.taginfo.(objType) = 1;
    end
    num = options.taginfo.(objType);
    tag = [objType, num2str(num)];
    options.taginfo.(objType) = num+1;
    guideopts(fig,options);
end


% ****************************************************************************
% Display a confrimation dialog for overwriting existing file, path
% indicates from where this function is called. It can be:
%       save
%       activate: from GUIDE Avtivation
%       export: from GUIDE exporting
% The default is 'save' and it does nothing but return 1
% ****************************************************************************
function answer = okToSave(fig, path)

if isequal(getappdata(0, 'MathWorks_GUIDE_testmode'),2) 
    answer = 1; 
    return; 
end 

import com.mathworks.mwt.dialog.MWAlert;

if nargin<2  path ='save'; end

answer = 1;
prefstring = [];
prompt = [];
checkstring =xlate('Do not show this dialog again.');
dialogtitle = 'GUIDE';

if strcmpi(path, 'activate')
    prefstring = 'LayoutActivate';
    prompt = sprintf('Activating will save changes to your figure and M-file.\nDo you wish to continue?');
elseif strcmpi(path, 'export')
    prefstring = 'LayoutExport';
    prompt = sprintf('Exporting will save changes to your figure and M-file.\nDo you wish to continue?');
end

if ~isempty(prefstring) & ~isempty(prompt)
    pref = com.mathworks.services.Prefs.getBooleanPref(prefstring);

    if pref
        layout_ed = getappdata(fig, 'GUIDELayoutEditor');
        frame = layout_ed.getFrame;

        check = com.mathworks.mwt.MWCheckbox(checkstring,0);
        manager = java.awt.FlowLayout(java.awt.FlowLayout.LEFT);
        panel = com.mathworks.mwt.MWPanel(manager);
        panel.add(check);

        mwa =MWAlert(frame, dialogtitle, prompt,MWAlert.BUTTONS_YESNO,...
            [], MWAlert.QUESTION_ICON,panel);
        mwa.setVisible(1);
        wish= mwa.getReply;

        if wish == MWAlert.NO
            answer = 0;
        end

        % change pref if user check the checkbox
        if check.getState
            com.mathworks.services.Prefs.setBooleanPref(prefstring,0);
        end
    end
end


% ****************************************************************************
% path indicates from where this function is called. It can be:
%       save:
%       saveas:
%       activate: from GUIDE Avtivation
%       export: from GUIDE exporting
%       openeditor: from GUIDE open M-file Editor
%       editcallback: from GUIDE view callback
% Aee aslo: okToSave
% ****************************************************************************
function [success, istemp] = saveBeforeAction(fig, path)

% Get current status of all involved files.
status = getGuiStatus(fig);

% Do save or save as if needed before activation
success = 1;
istemp = 0;

needsave =0;
issaveas =0;
targetname=[];
if status.figure.saved
    if ~status.figure.exist | (status.mfile.file & ~status.mfile.exist)
        % user may have deleted fig and/or m file, regenerate
        needsave = 1;
        targetname = get(fig,'FileName');
    elseif  status.figure.dirty | (status.mfile.file & status.mfile.dirty)
        if  strcmpi(path, 'saveas')
            if status.figure.writable & (status.mfile.file & status.mfile.writable)
                needsave = 1;
            end        
        elseif  ~strcmpi(path, 'openeditor')
            needsave = 1;
        elseif status.figure.dirty
            needsave =1;
        end
    else
        if strcmpi(path, 'editcallback')
            needsave = 1;
        end
    end
else
    if ~strcmpi(path, 'saveas')
        if status.mfile.file
            needsave = 1;
            issaveas = 1;
        else
            % figure only mode, have not saved. need to save to tempary figure file
            % so that tests for layout can be run automatically.
            istemp =1;
            figfile = [tempname,'.fig'];
            oldName = get(fig,'filename');
            setappdata(fig, 'ActivateTemp', 1);
            success = guidefunc('save', fig, figfile);
            rmappdata(fig, 'ActivateTemp');
        end
    end
end

if needsave
    if ~okToSave(fig, path)
        success = 0;
    else
        if issaveas
            success = guidefunc('saveAs', fig);
        else
            if ~isempty(targetname)
                success = guidefunc('save', fig, targetname);
            else
                success = guidefunc('save', fig);
            end
        end
    end
end

% ****************************************************************************
% Open the m file associated to this GUI in Callback Editor if the GUI is in
% figure/m mode. If the GUI has not been saved, save it first
% ****************************************************************************
function out = openCallbackEditor(varargin)

out=[];
fig = varargin{1};

if ishandle(fig)
    options = guideopts(fig);
    if options.mfile
        [success, istemp] = saveBeforeAction(fig, 'openeditor');

        if success & ~istemp
            figfile = get(fig,'FileName');
            [path, file, ext] = fileparts(figfile);
            mfile = fullfile(path, [file, '.m']);

            com.mathworks.mlservices.MLEditorServices.openDocument(mfile);
        end
    end
end

% ****************************************************************************
% Open figure in Guide
% ****************************************************************************
function out = openFigure(varargin)

out =[];

[filename, pathname] = uigetfile( ...
    {'*.fig', 'FIG-files (*.fig)'; ...
        '*.m', 'M-files (*.m)';...
        '*.*',   'All Files (*.*)'}, ...
    'Pick a file');

if isequal(filename, 0) | isequal(pathname, 0) %CANCEL
    return;
end

[p, f, e] = fileparts([pathname filename]);
if strcmp(e, '.fig')
    guide([pathname filename]);
else
    uiopen([pathname filename], 'direct');
end

%uiwait(msgbox('please add code for opening here', 'modal'));


% ****************************************************************************
% Create a figure from saved file. Return figure, its UDD adapter, initial
% properties, initial position, and child list.
% ****************************************************************************
function out = readSavedFigure(varargin)

layout_ed = varargin{1};
filename = varargin{2};
fig = newGuideFig(layout_ed, filename);

out{1} = fig;
out{2} = requestJavaAdapter(fig);
[out{3} out{4}] = getProperty(fig);
out{5} = guidemfile('getCallbackProperties', fig);
out{6} = localGetPixelPos(fig);
[out{7} out{8}] = guideopts(fig);
[out{9:13}] = localScanChildren(fig, [],[]);
[out{14} out{15}]= getGuiMenus(fig);

% ****************************************************************************
% Change the layout(figure) size in GUIDE
% ****************************************************************************
function out = resizeFigure(varargin)

fig = varargin{1};
size = varargin{2};
saveUnits = get(fig, 'units');
set(fig, 'units', 'pixels');
pos = get(fig, 'position');
y = pos(2) + pos(4) - size(2);
set(fig, 'position', [pos(1) y size]);
set(fig, 'units', saveUnits);

updateChildrenWhenResize(fig, [size(1)-pos(3) size(2)-pos(4)]);
% force a completion call
[out{1} out{2}] = getProperty(fig);

% ****************************************************************************
% update the position of all uicontrols and axes so that they appear to
% follow top-left coordinates instead of the default HG's bottom-left 
% ****************************************************************************
function updateChildrenWhenResize(parent, displacement)
if ~isempty(find(displacement)>0)
    filter.recursiveSearch = 0;
    children = guidemfile('findAllChildFromHere',parent, filter);

    for i=1:length(children)
        if ~strcmpi(get(children(i),'Units'), 'normalized')
            oldunit = get(children(i),'Units');
            set(children(i),'Units', 'Pixels');
            pos = get(children(i),'Position');
            pos(2) = pos(2)+ displacement(2);
            set(children(i),'Position',pos); 
            set(children(i),'Units', oldunit);
        end
    end
end


% ****************************************************************************
% Saves an internal GUIDE figure to a fig file
% ****************************************************************************
function saveGuideFig(fig, filename)

% remove this from appdata for two reasons:
% 1) we don't want it saved/reloaded with the figure
% 2) there's a bug in saving with java objects...
layout_ed = getappdata(fig, 'GUIDELayoutEditor');
options = guideopts(fig);
if isappdata(fig, 'GUIDELayoutEditor')
    rmappdata(fig, 'GUIDELayoutEditor');
end
p = findprop(handle(fig), '__GUIDEFigure');
delete(p);
[pname, funcname, ext] = fileparts(filename);
if options.mfile
    guidemfile('updateFile', fig, filename);
end

%uiwait(msgbox(['saving figure to file: ' filename]))

% update external controls before saving the figure so that updated
% information will be saved in the FIG-file later.
saveExternalControl(fig, filename);

hgsave(fig, filename);
set(fig, 'filename', filename)
p = schema.prop(fig, '__GUIDEFigure', 'double');
if ~isempty(layout_ed)
    setappdata(fig, 'GUIDELayoutEditor', layout_ed)
end
if isempty(getappdata(fig, 'ActivateTemp'))
    layout_ed.setDirty(0);
end



% ****************************************************************************
% change the properties of given graphical objects
% ****************************************************************************
function out = setProperties(varargin)

handles = varargin{1};
hnumber = length(handles);
for k=1:hnumber
    fields = varargin{k*2}';
    values = varargin{k*2+1};
    if ~isExternalControl(handles{k})        
        setProperty(double(handles{k}), fields,values);
    else
        setProperty(handle(handles{k}), fields,values);
    end
end

out{1} = 0;

% ****************************************************************************
% change the properties in FIELDS of the object given in HANDLE to those given
% in VALUES
% ****************************************************************************
function setProperty(h, fields, values)

if isExternalControl(h)
    peerfields = guidemfile('getCallbackProperties', h);
    if length(peerfields)>0
        peerfields = {'Tag', peerfields{:}}';
    else
        peerfields ={'Tag'};
    end
    count = length(peerfields);
    
    % Need to use decreasing index. Callback properties are added at the
    % end of uicontrol peer. It is possible that callback properties added
    % are overlaping with other properties of external control. For
    % example, there may be two 'Click' cells in fields. 
    matched =0;
    for j=length(fields):-1:1
        obj = h.Peer;
        if matched <count 
            if ismember(fields{j}, peerfields)
                obj = h;
                matched= matched+1;
            end
        end 
        try, set(obj, fields{j}, values{j}), end, 
    end
else
    % get the current position of figure first
    if iscontainer(h)
        oldunit = get(h,'Units');
        set(h,'Units','pixels');
        posnow = get(h,'Position');
        set(h,'Units',oldunit);
    end
    % must change 'units' and 'font units' first if they exist
    for i=1:length(fields)
        if (strcmp(fields{i},'Units') | strcmp(fields{i}, 'FontUnits'))
            set(h, fields{i},values{i});
        end
    end
    % second chance to set 'units' and 'font units' first
    % must use decreasing index
    for i=length(fields):-1:1, try, set(h, fields{i}, values{i}), end, end
    % get the position of figure after setting property
    if iscontainer(h)
        oldunit = get(h,'Units');
        set(h,'Units','pixels');
        poslater = get(h,'Position');
        set(h,'Units',oldunit);

        % update children position if figure size changed
        updateChildrenWhenResize(h, [poslater(3)-posnow(3), poslater(4)-posnow(4)]);
    end    
end


% ****************************************************************************
% takes an existing figure and 'snapshots' it into a GUIDE internal figure
% ****************************************************************************
function out = snapshotFigure(varargin)

layout_ed = varargin{1};
fig = varargin{2};

filename = [tempname '.fig'];
hgsave(fig, filename);
newFig = newGuideFig(layout_ed, filename);

% If we are editing an existing open figure, forget which file it
% may have come from - we don't want to automatically overwrite
% that file when we do Save.  This will make the figure do a
% SaveAs the first time it is saved, and will protect the
% original fig file.
set(newFig, 'filename', '');
options = guideopts(fig);
delete(filename);

out{1} = newFig;
out{2} = requestJavaAdapter(newFig);
[out{3} out{4}] = getProperty(newFig);
out{5} = guidemfile('getCallbackProperties', newFig);
out{6} = localGetPixelPos(newFig);
[out{7} out{8}] = guideopts(newFig);
[out{9:13}] = localScanChildren(newFig, [],[]);
[out{14} out{15}]= getGuiMenus(fig);


% ****************************************************************************
% use uiputfile to return a valid filename. filename will be checked to make
% sure it is a valid Matlab name. If the return name if empty, the use had
% pressed CANCEL
% ****************************************************************************
function [outputname, filterindex] = getOutputFilename(figure, filterspec, title, defaultname)
import com.mathworks.mwt.dialog.*;

outputname = [];
filterindex = [];

layout_ed = getappdata(figure, 'GUIDELayoutEditor');
frame = layout_ed.getFrame;

if isequal(getappdata(0, 'MathWorks_GUIDE_testmode'),2) 
    if (iscell(filterspec)) 
        % export 
        name = defaultname; 
    else 
        % save 
        name = filterspec; 
    end 
         
    outputname = fullfile(pwd,name); 
    return; 
end 

% Put up an Export dialog box, and check the return result.
% If the user picks a bad name, put up an error message and then redisplay
% the Export dialog, until the user gets it right, or Cancels.
needreentry = 1;
while needreentry
    [filename, pathname, filterindex] = uiputfile(filterspec, title, defaultname);

    if isequal(filename, 0) | isequal(pathname, 0)
        %user pressed CANCEL
        return;
    end

    [p, f, e] = fileparts([pathname filename]);
    ErrMsg = '';

    % check to see whether a valid Matlab name
    if isempty(f)
        ErrMsg = sprintf('File: %s\nis not a valid GUIDE file name. It must have at least one character.', [pathname filename]);
    elseif ~isvarname(f)
        ErrMsg = sprintf (['Please choose a valid MATLAB function name.\n\n', ...
                'A valid function name is a character string of letters, digits and ', ...
                'underscores, with length <= ' num2str(namelengthmax) ' and the first character a letter.']);
    end

    % add file ext if not there, check to see whether file extension is OK
    if (iscell(filterspec))
        ext = filterspec{filterindex};
        ext = ext(find(ext=='.'):end);
    else
        [pe, fe, ext] = fileparts(filterspec);
    end
    if (~isempty(ext))
        if (isempty(e))
            e = ext;
        end

        if ~strcmp(e, ext) % Don't allow any other extension
            ErrMsg = sprintf('Selected file: %s\nFile name must end with %s', filename, ext);
        end
    end

    % If error, show it and the user entered an illegal file name, show the error and popup the dislog again.
    if ~isempty(ErrMsg)
        mwa = MWAlert.errorAlert(frame, 'GUIDE', ErrMsg, MWAlert.BUTTONS_OK);
        needreentry =1;
    else
        % now we have a legal figure file name, do save
        outputname = fullfile(p, [f e]);
        needreentry = 0;
    end
end % end while needreentry


% ****************************************************************************
% Returns the number of objects in the figure (h or its parent figure) whose
% Tag property is 'tag
% ****************************************************************************
function result = getTagCount(h, tag)

result = 0;

if ~strcmpi(get(h,'Type'),'Figure')
    fig = get(h,'Parent');
else
    fig =h;
end

list = findall(fig);

for i=1:length(list)
    if ispc
        match = strcmpi(tag, get(list(i),'Tag'));
    else
        match = strcmp(tag, get(list(i),'Tag'));
    end

    if match
        result = result +1;
    end
end

% ****************************************************************************
% Function test whether a given file can be opened for writing
% ****************************************************************************
function out = iswritable(filename)
out = false;

wasthere = (exist(filename,'file') > 0);
fid=fopen(filename,'a');
if fid > 0
    out = true;
    fclose(fid);
    if ~wasthere
        delete(filename);
    end
end


function out = generateTrailerCode
NL = sprintf('\n');
out = [
NL, ...
'function out = which(varargin)',NL,...
'% always return something for which - this turns off some error checking but',NL,...
'% assures us that the compiled code runs.',NL,...
'out = varargin{1};',NL,...
'',NL,...
'function out = version(varargin)',NL,...
'% always return the current version, this assures us that the compiled code',NL,...
'% runs.',NL,...
sprintf('out = ''%s''\n',version('-release')), ...
'',NL,...
'function out = openfig(varargin)',NL,...
'% fake the compiler into thinking we don''t depend on open fig - in fact we',NL,...
'% don''t.',NL,...
'out = [];',NL,...
'',NL,...
'function out = exist(varargin)',NL,...
'% always return true for exist, this keeps the complier happy but disables',NL,...
'% some error checking.',NL,...
'out = 1;',NL,...
];


function filewrite(filename, contents)
% don't use 'wt', it puts too many CR's in.
errMsg = sprintf('Error creating file - is disk full?');

fid=fopen(filename,'w');
if fid > 0
    outLen = fprintf(fid, '%s',contents);
    fclose(fid);
else
    error(errMsg);
end

if outLen ~= length(contents)
    error(errMsg);
end

% ****************************************************************************
% initialize last valid tag property of uicontrol
% ****************************************************************************
function initLastValidTagProperty(h)

if isvarname(get(h,'Tag'))
    setappdata(h,tagPropertyLastValid, get(h,'Tag'));
else
    setappdata(h,tagPropertyLastValid, '');
end

% ****************************************************************************
% string used by Tag property change listener
% ****************************************************************************
function string = tagPropertyLastValid
string = 'lastValidTag';

% ****************************************************************************
% Handles update M-file nad callbacks when Tag property cahnges
% ****************************************************************************
function out = updateTag(varargin)

handles = varargin{1};
types = varargin{2};
styles = varargin{3};
hnumber = length(handles);
refresh = 0;
for i=1:hnumber
    switch types{i}
        case {'figure', 'uicontrol', 'axes'}
            out = updateTagProperty(handles{i}, hnumber);
            if out & (refresh ==0)
                refresh = 1;
            end

        case ACTIVEX
    end
end

if refresh
    com.mathworks.ide.inspector.Inspector.refreshIfOpen;
end

out = [];


% ****************************************************************************
% Helper function for update Tag property
% ****************************************************************************
function out = updateTagProperty(h, numselected)

out = 0;

oldTag = getappdata(h, tagPropertyLastValid);
newTag = get(h,'Tag');

% Tag value validation should be moved to Inspector
if ~isvarname(newTag)
    set(h, 'Tag', oldTag);
    out = 1 ;
else
    if ~isvarname(oldTag)
        % update last valid tag
        setappdata(h, tagPropertyLastValid, newTag);
        return;
    elseif strcmp(newTag, oldTag)
        return;
    end

    if ~strcmpi(get(h,'Type'),'Figure')
        fig = getParentFigure(h);
    else
        fig = h;
    end


    % update m file when tag changed only when GUIDE is saved and GUIDE is in
    % fig/mfile mode
    status = getGuiStatus(fig);
    if status.figure.exist & status.mfile.file & status.mfile.exist
        [path, file, ext] = fileparts(get(fig,'Filename'));
        mfile = fullfile(path,[file, '.m']);

        % reset existing callbacks to AUTOMATIC, only those
        % callback properties whose value is generated by GUIDE
        % already will be changed here.
        callbacks = guidemfile('getCallbackProperties', h);
        if ~isempty(callbacks)
            for i=1:length(callbacks)
                head = [file,'(''', oldTag];
                if strncmp(get(h,callbacks(i)), head, length(head))
                    set(h,char(callbacks(i)), guidemfile('AUTOMATIC'));
                end
            end
        end

        if getTagCount(h, newTag)>1
            line1 = sprintf('is assigned to more than one component in your GUI. ');
            line2 = sprintf('Their callbacks may point to the same functions in the GUI M-file.');
            warndlg(sprintf('The Tag, ''%s'', %s %s', newTag, line1,line2), 'GUIDE','modal');

            % update last valid tag
            setappdata(h, tagPropertyLastValid, newTag);

            return;
        end

        % replace the occurrence of the old tag in m file with new
        % tag only if it is the single selection and the tag is unique
        if numselected == 1 & (getTagCount(h, oldTag)==0)
            % save mfile if it is dirty
            if guidemfile('isMFileDirty', mfile)
                com.mathworks.mlservices.MLEditorServices.saveDocument(java.lang.String(mfile));
            end

            % first replace oldTag in comments with newTag
            replaceMfileString(mfile, oldTag, newTag, 'loose', 'comment');

            % second replace oldTag_ in code with newTag_
            replaceMfileString(mfile, oldTag, newTag, 'strict', 'function');

            % third replace handles.oldTag in code with handles.newTag
            replaceMfileString(mfile, ['handles.', oldTag], ['handles.', newTag], 'strict','code');
        end

        % update m file. Callbacks will be checked and may be added
        % for those set to AUTOMATIC above
         markDirty(fig);
         guidefunc('save', fig);

        % refresh m file
        com.mathworks.mlservices.MLEditorServices.reloadDocument(java.lang.String(mfile),0);
    end
    % update last valid tag
     setappdata(h, tagPropertyLastValid, newTag);
end

% *************************************************************************
% get the release number for GUIDE GUI 
% *************************************************************************
% We need a more reliable way to get this information. There was a problem
% in R13.0.1
function rnumber = getGuiReleaseNumber 
rnumber = str2double(version('-release')); 

% *************************************************************************
% 
% *************************************************************************
function [adapters, parents] = getGuiMenus(fig)

show = get(0, 'showhiddenhandles');
set(0, 'showhiddenhandles', 'on');
menus=getMenuHandles(fig);
set(0, 'showhiddenhandles', show);

adapters={};
parents={};
if ~isempty(menus)
    for i=1:length(menus)
        adapters = [adapters; requestJavaAdapter(menus(i))];
        parents = [parents; requestJavaAdapter(get(menus(i),'parent'))];        
    end
end


function menus = getMenuHandles(menuparent)

if strcmpi(get(menuparent,'Type'),'figure')
    menus = findobj(allchild(menuparent), 'flat', 'type', 'uimenu', 'serializable', 'on');
    menus = [menus; findobj(allchild(menuparent), 'flat', 'type', 'uicontextmenu')];
else
    menus = get(menuparent,'Children');
end

menus = flipud(menus);

children = [];
if ~isempty(menus)
    for i=1:length(menus)
        children = [children; getMenuHandles(menus(i))];
    end
    menus = [menus; children];
end

    

% *************************************************************************
% The code below is for supporting external controls in GUIDE. Following is
% a list of functions in this file:
%       ACTIVEX
%
%       isExternalControl(obj)
%       getExternalControlInfo(obj)
%       setExternalControlInfo(obj, info)
%       createExternalControlInfo(varargin)
%
%       createExternalControl(varargin)
%       createExternalControlInstance(fig, position, info)
%       createExternalControlPeer(fig, position, info)
%       connectExternalControlPeer(control, peer)
%       getExternalControlCreator(obj)
%
%       copyExternalControl(original, parent)
%       saveExternalControl(fig, filename)
%       moveExternalControl(obj, pos)
%       selectActiveXControl(varargin)
%       showPropertyPage(varargin)
%
% Some code also added to guidemfile, functions that were added or affected
% by supporting external control in guidemfile are:
%       isExternalControl
%       getCallbackProperties
%       getCallbackProperty
%       setCallbackProperty
%       setAutoCallback
%       chooseCopyCallbacks
%       makeFunctionPostComment
% *************************************************************************

% *************************************************************************
% return the Type string of ActiveX controls
% *************************************************************************
function string = ACTIVEX

string = 'activex';


% *************************************************************************
% test whether a HG object is really used as a wrapper for an external
% control, such as ActiveX
% *************************************************************************
function result = isExternalControl(obj)

result = 0;

% ActiveX does not support application data
if ishandle(obj)
    try
        result = isappdata(obj, 'Control');
    catch
        result = 0;
    end
end

% *************************************************************************
% obtain the external control information saved on its HG wrapper
% *************************************************************************
function info = getExternalControlInfo(obj)

info =[];

if isExternalControl(obj)
    info = getappdata(obj, 'Control');
end


% *************************************************************************
%o set the external control information on its HG wrapper
% *************************************************************************
function setExternalControlInfo(obj, info)

if ishandle(obj)
    setappdata(obj, 'Control', info);
end

% *************************************************************************
% return the string that will be used as the CreateFcn callback  of the
% HG wrapper for creating the external control
% *************************************************************************
function creator = getExternalControlCreator(obj)

creator ='';
if isExternalControl(obj)
    control = getExternalControlInfo(obj);
    switch control.Type
        case ACTIVEX
            creator = 'actxproxy(gcbo);';
    end
end


% *************************************************************************
% make a copy an external control
% *************************************************************************
function duplicate = copyExternalControl(original, parent)

duplicate =[];
if isExternalControl(original)
    info = getExternalControlInfo(original);

    % make copy of its uicontrol peer. Empty its createFcn temporarily so
    % that external control is not created as in running mode
    fig = parent;
    createFcn = get(original, 'createFcn');
    set(original,'createFcn', '');
    duplicate = handle(copyobj(original, fig));
    set(original,'createFcn', createFcn);

    % make copy of external control with the same properties
    control = info.Instance;
    type = info.Type;
    [properties{1} properties{2}] = getProperty(control);

    switch type
        case ACTIVEX
            info.Instance = [];
            info.Serialize = '';
            info.Runtime =0;
            setExternalControlInfo(duplicate, info);

            h = createExternalControl(fig, type, duplicate, properties);
    end
end



% *************************************************************************
% save an external control
% *************************************************************************
function saveExternalControl(fig, filename)

kids= handle(allchild(fig));
limit = length(kids);
[pname, funcname, ext] = fileparts(filename);

for i=1:limit
    if isExternalControl(kids(i))
        control = getExternalControlInfo(kids(i));
        switch control.Type
            case ACTIVEX
                 % serialize of Activex control
                 try
                     afname = [funcname, '_', get(kids(i), 'Tag')];
                     controlfile = fullfile(pname, afname);
                     save(control.Instance, controlfile);
                     control.Serialize = afname;
                 catch
                 end

                 % save callback info for registering events handlers in
                 % running mode
                 callbacks = control.Callbacks;
                 eventlist = guidemfile('getCallbackProperties', kids(i));
                 for j=1:length(eventlist)
                     if ~isempty(get(kids(i), char(eventlist{j})))
                         if isempty(find(ismember(callbacks, eventlist{j})))
                             callbacks{end+1} = eventlist{j};
                         end
                     end
                 end
                 control.Callbacks = callbacks;

                 setExternalControlInfo(kids(i), control);
         end
    end
end

% *************************************************************************
% change the position of an external control 
% *************************************************************************
function moveExternalControl(obj, pos)

if isExternalControl(obj)
    info = getExternalControlInfo(obj);
    type = info.Type;
    control = info.Instance;
    switch type
        case ACTIVEX
            if ishandle(control)
                control.move(pos);
            end
    end

end


% *************************************************************************
% create HG uicontrol
% *************************************************************************
function h = createUicontrol(varargin)

parent = varargin{1};

% for creating new UIcontrol
if (~isempty(varargin{7}) & ~isempty(varargin{8}))
    % from RedoAdd or UndoDeletef
    h = uicontrol('parent', parent, ...
        'style', varargin{5});
    fields = varargin{7}';
    values = varargin{8};
    setProperty(h, fields, values);
else
    % from create new object. The position passed from Java is in
    % pixel.
    h = uicontrol('parent', parent, ...
        'units', 'pixel', ...
        'position', varargin{4}, ...
        'style', varargin{5}, ...
        'strin', varargin{6});
    % XXX Hack until we get the right defaults from the Java side
    if strcmpi(get(h,'style'),'edit')
        % XXX design review this
        % reset string to '' for edit controls
        % set(h,'string','');

        % reset bg color to white
        set(h,'backgroundcolor','white');
    end
    set(h,'units','character','tag',nextTag(h));
    options = guideopts(parent);
    if strcmp(options.resize, 'simple')
        set(h, 'units', 'normalized')
    end
    if options.mfile & options.callbacks
        guidemfile('chooseAutoCallbacks',h);
    end
end

% *************************************************************************
% create HG axes
% *************************************************************************
function h = createAxes(varargin)

parent = varargin{1};

% for creating new Axes
if (~isempty(varargin{7}) & ~isempty(varargin{8}))
    % from RedoAdd or UndoDelete
    h = axes('parent', parent);
    fields = varargin{7}';
    values = varargin{8};
    setProperty(h, fields, values);
else
    h = axes('parent', parent, ...
        'units', 'pixels', ...
        'position', varargin{4});
    set(h, 'units','character','tag',nextTag(h));
    options = guideopts(parent);
    if strcmp(options.resize, 'simple')
        set(h, 'units', 'normalized')
    end
end

% *************************************************************************
% create HG containers
% *************************************************************************
function h = createContainer(varargin)

parent = varargin{1};
type = varargin{2};
position = varargin{4};
style = varargin{5};            
title = varargin{6};   
properties{1} = varargin{7}';
properties{2} = varargin{8};

switch style
    case 'panel'
        h = uipanel('parent', parent,'units', 'pixel','position', position,'title', title);        
    case 'buttongroup'
        h = uibuttongroup('parent', parent,'units', 'pixel','position', position,'title', title);        
    otherwise
        h = uicontainer('parent', parent,'units', 'pixel','position', position);        
end

if ~isempty(properties{1})
    setProperty(h, properties{1}, properties{2});
else
    set(h,'units','character','tag',nextTag(h));
    options = guideopts(parent);
    if strcmp(options.resize, 'simple')
        set(h, 'units', 'normalized')
    end
end

% *************************************************************************
% create an external control for GUIDE
% *************************************************************************
function h = createExternalControl(varargin)

fig =varargin{1};
type = varargin{2};

peer = [];              %the uicontrol peer for external control
position = [];          %the location where the external control should be
properties{1} =[];      %properties is P/V pairs for undo/redo and copy
properties{2} =[];
undoredo = 0;           %flag to indicate whether from undo/redo

% First, create or get external control info structure.
if length(varargin)>4   % first time creation or from redo/undo
    info = createExternalControlInfo(varargin{:});
    
    properties{1} = varargin{7}';
    properties{2} = varargin{8};
    position = varargin{4};
    if ~isempty(properties{1});
        undoredo =1;
    end
else
    peer = varargin{3};
    info = getExternalControlInfo(peer);
    position = get(peer, 'Position');

    if length(varargin) == 4    % copy/paste or duplicate
        properties{1} = varargin{4}{1};
        properties{2} = varargin{4}{2};
    end
end

% Second, create external control and possibly its peer
runtime = info.Runtime;
if ~runtime
    % first time/undoredo/copy/paste/duplicate
    info.Instance = createExternalControlInstance(fig, position, info);
    
    % create the uicontrol peer: first time/undoredo
    if isempty(peer)
        peer = createExternalControlPeer(fig, position, info);
    end
end
info.Runtime = 0;
h = info.Instance;
% store updated external control info
setExternalControlInfo(peer, info);

% Third, add instance properties for all the external events for
% automatically generating callbacks in M-file.
eventlist = guidemfile('getCallbackProperties', peer);
for i=1:length(eventlist)
    if ~isprop(peer, eventlist{i})
        % we do not need to serialize these instance properties
        p= schema.prop(peer, eventlist{i}, 'string');        
        p.AccessFlags.Serialize = 'off';
        if ismember(eventlist{i}, info.Callbacks)
            guidemfile('setAutoCallback', peer,  eventlist{i});
        end
    end 
end

% Fourth, connect external control and its uicontrol peer by instance
% proeperty: 
set(peer,'HandleVisibility', 'off');
set(peer,'Visible', 'off');
connectExternalControlPeer(h, peer)

% Fifth, apply P/V paires if given for undoredo/copy
if ~isempty(properties{1});
    fields = properties{1};
    values = properties{2};
    setProperty(peer, fields, values);
    h.Peer = peer;
    peer.Peer = h;
end

% Last, correct Tag and CreateFcn properties if needed
if ~runtime & ~undoredo
    set(peer, 'Tag', nextTag(peer));
end
set(peer, 'CreateFcn', getExternalControlCreator(peer));



% *************************************************************************
% create a real external control in MATLAB
% *************************************************************************
function instance = createExternalControlInstance(fig, position, info)

instance=[];
switch info.Type
    case ACTIVEX
        instance = actxcontrol(info.ProgID, position, double(fig));
end

% *************************************************************************
% create the HG wrapper for an external control
% *************************************************************************
function peer = createExternalControlPeer(fig, position, info)

peer = handle(uicontrol('parent', fig, 'position', position, 'style', 'text'));

% *************************************************************************
% set an external control and its HG wrapper so that they can find each
% other 
% *************************************************************************
function connectExternalControlPeer(control, peer)

peer =handle(peer);
if ~isprop(peer, 'Peer')
    % we do not need to serialize this instance properties
    p = schema.prop(peer, 'Peer', 'handle');
    p.AccessFlags.Serialize = 'off';
end
if ~isprop(control, 'Peer')
    control.addproperty('Peer');
end
control.Peer = peer;
peer.Peer = control;


% *************************************************************************
% return the information about an external control that needs to be saved
% on its HG wrapper
% *************************************************************************
function info = createExternalControlInfo(varargin)

% Create fields common to all external controls
info.Type = varargin{2};        % external control type
info.Style = varargin{5};       % external control style
info.Instance = [];             % store the handle to the created external control in MATLAB
info.Runtime = 0;               % indicates whether it is called from bringing in a running figure
info.Callbacks = {};            % cell array for storing those callbacks that have stubs in M-file

% Create fields specific to external controls
switch info.Type
    case ACTIVEX
        info.ProgID = char(varargin{6}{1}); % ProgID of ActiveX, needed by actxcontrol
        info.Name = char(varargin{6}{2});   % Name of ActiveX
        info.Serialize = '';                % the disk file where Activex is serialized
end



% *************************************************************************
% This is where to get necessary information about a control that is being
% created in GUIDE layout before it is shown.
% *************************************************************************
function out = prepareProxy(varargin)
out = {};

type = varargin{1};
switch type
    case ACTIVEX
        out = selectActiveXControl;
end


% *************************************************************************
% show the actxcontrolselect dialog for user to select an ActiveX 
% *************************************************************************
function out = selectActiveXControl(varargin)
out = [];
if isappdata(0, 'MathWorks_GUIDE_testmode')
    % Do not show dialog to select ActiveX control in test mode. Use one
    % control comes along with MATLAB instead
    list = getActiveXControlList;
    index = find(ismember(list{1}, 'MWSAMP.MwsampCtrl.1'));
    if isempty(index)
        eval(['!regsvr32 /s ', fullfile([matlabroot,'\bin\win32'], 'mwsamp.ocx')])
        list = getActiveXControlList;
        index =find(ismember(list{1}, 'MWSAMP.MwsampCtrl.1'));
    end
    info ={char(list{2}(index)), char(list{1}(index))};
else
    [h, info]= actxcontrolselect('User','GUIDE');
end

if ~isempty(info)
    out{1} = {info{2}, info{1}};
else
    out{1} ={};
end

% ****************************************************************************
% return the list of all ActiveX controls on a computer system
% ****************************************************************************
function out = getActiveXControlList

out=[];

controls = actxcontrollist;
out{1} = controls(:,2);
out{2} = controls(:,1);

% *************************************************************************
% use Propeedit to change the properties of an object. For ActiveX, this
% will show its built-in property pages.
% *************************************************************************
function out =  showPropertyPage(varargin)

out =[];

handle = varargin{1};
fig = getParentFigure(handle);
if isExternalControl(handle)    
    handle = handle.Peer;
    propedit(handle);

    % we only need to run the following code when there are changes to the
    % Activex properties. This is impossible to get at this time. 
    markDirty(fig);
    com.mathworks.ide.inspector.Inspector.refreshIfOpen;
else
    propedit(handle,'v6');
end



