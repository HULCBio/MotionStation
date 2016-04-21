function varargout = guidemfile(varargin)
%GUIDEMFILE Support function for Guide

%   $Revision: 1.48.4.12 $ $Date: 2004/04/10 23:33:44 $
%   Copyright 1984-2004 The MathWorks, Inc.

error(nargchk(1,inf,nargin));

try
    [varargout{1:nargout}] = feval(varargin{:});
catch
    import com.mathworks.ide.layout.LayoutEditor;
    % toggle layout's busy state
    LayoutEditor.toggleBusyState(0,0);

    errordlg(sprintf('Unhandled internal error in guidemfile.\n%s',lasterr), ...
             'GUIDE');
    lasterr('');
end


%
%----------------------------------------------------------------------
%
function contents = getFileContentsNoSave(filename)
% get contents of file on disk; don't save editor's changes
fid = fopen(filename);
if fid == -1
    error(sprintf('%s does not exist.', filename));
else
    contents = fscanf(fid, '%c');
    fclose(fid);
end

%
%----------------------------------------------------------------------
%
function contents = getFileContents(filename, fcontents)
% This is the only place where we READ the file from disk.

if ~isempty(fcontents)
    contents = fcontents;
else
    % If this file is currently open in the MATLAB editor and has
    % unsaved changes, we need to force a save in the editor before
    % loading the file ourselves (to catch any changes).
    % TODO: We should prompt the user the first time, with a "don't
    % ask me again" dialog.
    if isMFileDirty(filename)
        com.mathworks.mlservices.MLEditorServices.saveDocument(java.lang.String(filename));
    end
    contents = getFileContentsNoSave(filename);
end

%
%----------------------------------------------------------------------
%
function writeFileContents(filename, contents)

[filepath, funcname, ext] = fileparts(filename);

fid = fopen(filename, 'w');
if fid == -1
    error(sprintf('%s does not exist or is not writable.',filename));
else
    fprintf(fid, '%s', contents);
    fclose(fid);
end

% Now that we've changed the file, reload it in the editor,
% QUIETLY, if it is already open:
import com.mathworks.mlservices.MLEditorServices;
MLEditorServices.reloadDocument(java.lang.String(filename), 0);

% clear this function out of the parser cache - we might be
% calling it right away if we're about to activate.
clear(funcname);


%
%----------------------------------------------------------------------
%
function opts = getOptions(filename, contents, options)
% if this file was generated in an older version of GUIDE, let the
% code in the m-file be truth for our defaults, otherwise, use options
% as they are passed in.

% seed output with the values passed in
opts = options;

guts = getFileContents(filename, contents);

% update version field
ind = findVersionString(filename,guts);
if ~isempty(ind)
    opts.version = guts(ind(1):ind(2));
end

if options.release < 13
    % update syscolorfig field (1 if special string found; 0 otherwise)
    opts.syscolorfig = 0;
    ind = findSyscolorString(filename,guts);
    if ~isempty(ind)
        opts.syscolorfig = 1;
    end

    % update singleton field only if 'openfig' is found
    % (1 if openfig(..., 'reuse'); 0 otherwise)
    ind = findConstructorString(filename,guts);
    if ~isempty(ind)
        opts.singleton = 0;
        if ~isempty(findstr(guts(ind(1):ind(2)), '''reuse'''))
            opts.singleton = 1;
        end
    end

    % update blocking field (1 if 'uiwait' found)
    ind = findBlockingString(filename,guts,options);
    if ~isempty(ind)
        opts.blocking = 1;
    end
else
    % update singleton field
    ind = findSingletonString(filename,guts);
    if ~isempty(ind)
        % this should be the string 'gui_Singleton = X;'
        % eval it and try to use the gui_Singleton as a variable
        % default to Singleton == 1 if the variable does not get created
        eval(guts(ind(1):ind(2)),'gui_Singleton = 1;');
        if gui_Singleton == 1
            opts.singleton = 1;
        else
            opts.singleton = 0;
        end
    end
end

%
%----------------------------------------------------------------------
%
function [funcnames, linenums_out] = getFunctionNames(file_contents) %%%%%%%%%%%%%%
% should recognize funcs of the form:
% "function funcname"
% "function out = funcname"
% "function funcname(in)"
% "function out = funcname(in)"
% with or without trailing comment characters on the line

% replace CRs with NLs so we don't have to worry about this below
% file_contents(find(file_contents == CR)) = NL;
% add trailing newline (internally only) so we don't have to worry
file_contents(end + 1) = NL;

% find all occurrences of the word 'function' at begin of line:
funcs = findstr(file_contents, [NL 'function']) + 1;
line_ends = find(file_contents == NL);

funcnames = {};

linenums=[];
for i = funcs

    linenums(end+1) = length(find(line_ends < i))+1;

    this_line = file_contents(i:(line_ends(min(find(line_ends>i)))));
    % strip off trailing comment (if any)
    comments = find(this_line == '%');
    if ~isempty(comments)
        this_line = this_line(1:(comments(1)-1));
    end

    % strip away input args (if any):
    paren = find(this_line == '(');
    if ~isempty(paren)
        this_line = this_line(1:(paren(1) - 1));
    end

    % strip away output args (if any), otherwise strip away word 'function':
    equalsign = find(this_line == '=');
    if ~isempty(equalsign)
        this_line = this_line((equalsign(1) + 1):end);
    else
        this_line = this_line(9:end);
    end

    % finally strip away all whitespace:
    this_line = this_line(~isspace(this_line));

    funcnames{end+1} = this_line;
end
if nargout == 2
    linenums_out = linenums;
end


%
%----------------------------------------------------------------------
%
function isDirty = isMFileDirty(filename)
[filepath, funcname, ext] = fileparts(filename);
mname = fullfile(filepath, [funcname,'.m']);
isDirty = com.mathworks.mlservices.MLEditorServices.isDocumentDirty(mname);

%
%----------------------------------------------------------------------
%
function [header, body] = splitHeaderBody(contents)
% look for the first line that doesn't start with a comment,
% and return everything up to that in "header", and the remainder
% in "body".  If the function has no help at the top, and no H1
% line, then only the function declaration will be returned in
% header.  If the function has all help and no code, then body will
% be empty.
lines = find(contents == NL);
non_comments = contents(lines(1:end-1)+1) ~= '%';
headerEnd = min([lines(non_comments) length(contents)]);
header = contents(1:headerEnd);
body = contents((headerEnd+1):end);

%
%----------------------------------------------------------------------
% Replace occurrences of a string with another one
%       contents: the string whose 'source' strings needs to be replaced
%       source: the string to search for in contetns
%       target: the string replacing 'source'
%
%       policy: 'loose' or 'strict'. Default is 'loose'
%               'loose' implies: strfind(lower(contents), lower(source))
%               'strict' implies: strfind(contents, source)
%       scope: 'comment', 'function', 'code', or 'all'. Indicates where to look
%               for source. 'comment' will only replace string in comments,
%               'function' replacing string in function definition, 'code'
%               replacing string in real code. 'all' looks everywhere.
%               Default is 'all'.
function result = stringReplace(contents, source, target, policy, scope)

if nargin < 5
    scope = 'all';
end

if nargin < 4
    policy = 'loose';
end

match =[];
if strcmpi(scope, 'all')
    match = getStringLocation(contents, source, policy);
else
    incomment  = strcmpi(scope,'comment');
    infunction = strcmpi(scope,'function');
    incode  = strcmpi(scope,'code');
    subfunctions = getFunctionNames(contents);

    NL = 10;
    lineends = strfind(contents, NL);

    head = 1;
    for i=1:length(lineends)
        tail = lineends(i);
        line = contents(head:tail);

        shortline = line;
        spaces = (shortline==' ');
        shortline(spaces)=[];

        if ~isempty(shortline)
            index = strfind(shortline, 'function');
            if (~isempty(index) & index(1) ==1)
                isfunction = 1;
            else
                isfunction = 0;
            end
            iscomment = (shortline(1) == '%');
            iscode = (~iscomment & ~isfunction);
            if (incomment == 1 & iscomment == incomment) ...
               | (infunction ==1 & isfunction == infunction) ...
               | (incode==1 & iscode == incode)
                searchfor = source;

                found = getStringLocation(line, searchfor, policy);

                if ~isempty(found)
                    % do not do string replace if the target function is
                    % already exists in the m file
                    if (infunction ==1 & isfunction == infunction)
                        rest = line(found(1):end);
                        nameend = strfind(rest, '(');
                        if isempty(nameend)
                            nameend = strfind(rest, ' ');
                        end
                        if isempty(nameend)
                            nameend = strfind(rest, NL);
                        end
                        if ~isempty(nameend)
                            subname = rest(1:(nameend(1)-1));
                            targetname = [target, subname((length(searchfor)+1):end)];
                            spaces = (targetname==' ');
                            targetname(spaces)=[];
                            alreadyexist = 0;
                            % do not use i. It is used in the out loop
                            for k=1:length(subfunctions)
                                if strcmp(targetname, char(subfunctions(k)))
                                    alreadyexist =1 ;
                                    break;
                                end
                            end
                            if ~alreadyexist
                                match=[match, found+head-1];
                            end
                        end
                    else
                        match=[match, found+head-1];
                    end
                end
            end
        end
        head = lineends(i) +1;
    end
end

if ~isempty(match)
    head = 1;
    result ='';
    for i=1:length(match)
        thisend = (match(i) + length(source)-1);
        this  = contents(match(i):thisend);

        if strcmp(this, source)
            result = [result,contents(head:(match(i)-1)), target];
        elseif strcmp(this, upper(source))
            result = [result,contents(head:(match(i)-1)), upper(target)];
        elseif strcmp(this, lower(source))
            result = [result,contents(head:(match(i)-1)), lower(target)];
        else
            result = [result,contents(head:(match(i)-1)), this];
        end
        head = match(i) + length(source);
    end
    result = [result, contents(head: end)];
else
    result = contents;
end

%
%----------------------------------------------------------------------
% Helper function for stringReplace
% Returns index of searchfor in source. Does whole word match
function found = getStringLocation(source, searchfor, policy)
%
if nargin < 3
    policy = 'loose';
end

if strcmp(lower(policy), 'strict')
    found = strfind(source, searchfor);
else
    % default
    found = strfind(lower(source), lower(searchfor));
end

% implement whole-word match
filtered =[];
% do not use i. It is used in the out loop
for j=1:length(found)
    index = found(j);
    OK =1;
    if (index -1)>0
        previous = source(index-1);
        if isletter(previous) | ('0' <= previous & previous <= '9')
            OK = 0;
        end
    end
    if (index + length(searchfor))<=length(source)
        next = source(index + length(searchfor));
        if isletter(next) | ('0' <= next & next <= '9')
            OK = 0;
        end
    end

    if OK
        filtered = [filtered, index];
    end
end
found = filtered;



%----------------------------------------------------------------------
%
function updateFile(fig, filename)
% takes a .fig file name, and generates or updates the
% corresponding mfile.  If the mfile doesn't exist yet, create the
% main function.  If the mfile does exist, update the main function
% as necessary.  Then, append any new callback subfunctions.
% Called whenever we choose "save" or "activate" or "edit Callback"
% in the layout editor.  Also called if we modify any mfile options
% in the application options, and hit OK.
% This is the only place where we ever WRITE the file to disk.

[filepath, funcname, ext] = fileparts(filename);
mname = fullfile(filepath, [funcname,'.m']);

new_options = guideopts(fig);
oldfilename = get(fig, 'filename');

% if (ispc)
%     mname=lower(mname);
%     oldfilename=lower(oldfilename);
% end

if isfield(new_options, 'template')
    oldfilename = new_options.template;
end

if ~isempty(oldfilename)
    [oldfilepath, oldfuncname, oldext] = fileparts(oldfilename);
    oldmfile = fullfile(oldfilepath, [oldfuncname,'.m']);
    if exist(oldmfile)
        new_options.lastSavedFile = oldmfile;
        guideopts(fig, new_options);
    end
end


% Take care of saveAs issues before doing the regular save stuff
isSaveAs = 0;
if isfield(new_options, 'template')
    isSaveAs = 1;
    [p, f, e] = fileparts(new_options.template);
    fname = fullfile(p, [f,'.m']);
    new_options = rmfield(new_options, 'template');
elseif isfield(new_options, 'lastSavedFile')
    fname = new_options.lastSavedFile;
    if ispc
        if ~strcmpi(mname, fname)
            isSaveAs = 1;
        end
    else
        if ~strcmp(mname, fname)
            isSaveAs = 1;
        end
    end
end

if  isSaveAs
    % get a copy of the latest SAVED changes, before we get a copy of
    % the latest unsaved changes (which forces a save as a
    % side-effect).  We want to make the new file based on the latest
    % changes in the editor, but we don't want the old file to
    % contain those changes - so after we force the save and get the
    % latest contents for the save as, we put back the previous
    % version.
    if guidemfile('isMFileDirty', fname)
        old_contents = getFileContentsNoSave(fname);
        contents =  getFileContents(fname,[]);
        % restore the old file to its last saved state, getting rid of
        % unsaved changes in the editor that were saved as a side-effect
        % of our reading it:
        writeFileContents(fname, old_contents);
    else
        contents =  getFileContentsNoSave(fname);
    end

    % convert all occurrences of the old function name with new
    % function name, preserving case:
    % old -> new (all lowercase)
    % OLD -> NEW (all uppercase)
    [header, body] = splitHeaderBody(contents);
    header = guidemfile('stringReplace', header, oldfuncname, funcname);
    body = guidemfile('stringReplace', body, oldfuncname, funcname);
    contents = [header, body];

    % convert all callbacks containing calls to old fcn with calls to
    % new fcn:
    renameCallbacks(handle(findall(fig)), oldfuncname, funcname);

    % now write out the modified version of the old mfile to the new name:
    writeFileContents(mname, contents);
end

bringEditorForward = 0;

if exist(mname)
    prev_contents = getFileContents(mname,[]);

    if new_options.release < 13
        % if the MFile already exists, treat any options in it as the
        % TRUTH, overriding what is contained in the options struct (which
        % may be stale).  BUT: if the 'override' flag exists in the
        % options struct, that means we've just come from the App Options
        % dialog, and we want to change what's in the Mfile.
        mfile_options = getOptions(mname,[],new_options);

        % allow figure's current color to override the MFile's system
        % color setting:
        if ~isequal(get(fig, 'color'),...
                    get(0,'defaultuicontrolbackgroundcolor'))
            mfile_options.syscolorfig = 0;
        end

        % If the new_options struct has the override field set, honor the
        % settings in it without checking what's in the MFile (remember
        % to clear that flag so next time we honor the mfile).
        if new_options.override
            new_options.override = 0;
        else
            % allow changes to the mfile to override fields in the stored
            % mfile_options structure:
            fields = {'singleton','syscolorfig','blocking'};
            for i=1:length(fields)
                if isfield(mfile_options, fields{i})
                    new_options.(fields{i}) = mfile_options.(fields{i});
                end
            end
        end
    end
    contents = updateFileContents(mname, prev_contents, new_options, fig);
else
    prev_contents = '';
    contents = makeFileContents(filename, new_options);
    bringEditorForward = 1;
end

if new_options.callbacks
    contents = appendCallbacks(contents, fig, funcname, new_options);
end

guideopts(fig, new_options);

needToSave = ~contentsEqual(mname, prev_contents, contents);

if needToSave | isSaveAs

    import com.mathworks.mlservices.MLEditorServices;

    if needToSave
        writeFileContents(mname, contents);
    end

    % Bring the editor forward.
    if bringEditorForward | isSaveAs
        MLEditorServices.openDocument(java.lang.String(mname));
        if isSaveAs
            % close the previous filename in editor:
            MLEditorServices.closeDocument(java.lang.String(new_options.lastSavedFile));
        end
    end

    new_options.lastSavedFile = mname;
    guideopts(fig, new_options);

end

%
%----------------------------------------------------------------------
%
function answer = onPath(filepath)
% determine whether the function is on the path (if not, someone
% else will want to add it to the path)

mlpath = lower([path pathsep]);
filepath = lower(filepath);
if isempty(findstr([filepath, pathsep],mlpath)) &...
        ~strcmp(pwd, filepath)
    answer = 0;
else
    answer = 1;
end


%
%----------------------------------------------------------------------
%
function answer = contentsEqual(filename, contents1, contents2)
% compare two functions IGNORING the version strings:

ind = findVersionString(filename,contents1);
if ~isempty(ind)
    contents1(ind(1):ind(2)) = '';
end
ind = findVersionString(filename,contents2);
if ~isempty(ind)
    contents2(ind(1):ind(2)) = '';
end
answer = isequal(contents1, contents2);

%
%----------------------------------------------------------------------
%
function contents = updateFileContents(filename, contents, options, fig)
% Given the current contents of a file, and the selected options,
% modify the main function so that it matches the options.
% Includes singleton mode, system-color mode, and blocking mode.
% also generate a newer version string.  The new options are passed
% in, and we compare them to the previous options

prev_options = getOptions(filename,contents,options);

% replace the version string
contents = updateVersionString(filename, contents);

if options.release < 13
    % change constructor (if necessary and if possible)
    if(isfield(prev_options,'singleton') &...
       prev_options.singleton ~= options.singleton)
        ind = findConstructorString(filename,contents);
        if ~isempty(ind)
            contents = [contents(1:(ind(1)-1)),...
                        makeConstructorString(options.singleton), ...
                        contents((ind(2)+1):end)];
        end
    end

    % insert/remove syscolor block
    if options.syscolorfig ~= prev_options.syscolorfig
        if prev_options.syscolorfig
            % remove it
            ind = findSyscolorString(filename,contents);
            if ~isempty(ind)
                contents = [contents(1:(ind(1)-1)),contents((ind(2)+1):end)];
            end
        else
            % insert it after openfig
            ind = findSignatureHead(filename,contents, 'openfig', 1);
            if ~isempty(ind)
                ind = findNextOccurenceOfCharacter(contents, ind, NL);
                contents = [contents(1:(ind+1)), ...
                            makeSyscolorString(1), NL, ...
                            NL, ...
                            contents((ind+2):end)];
            end
        end
    end

    % insert/remove blocking block
    if options.blocking ~= prev_options.blocking
        if prev_options.blocking
            % remove it
            ind = findBlockingString(filename,contents,options);
            if ~isempty(ind)
                contents = [contents(1:(ind(1)-1)),contents((ind(2)+1):end)];
            end
        else
            % put it just before: the
            %   the 'varargout{', or
            %   the first 'else/end', or
            %   'if nargout',
            % whichever comes first:
            ind = min([findstr(contents, 'varargout{'),...
                       findstr(contents, [NL 'else']),...
                       findstr(contents, ['if nargout']),...
                       findstr(contents, [NL 'end'])]);
            ind = findPreviousOccurenceOfCharacter(contents, ind, NL);
            contents = [contents(1:ind), NL, ...
                        makeBlockingString(1,options), NL, ...
                        NL, ...
                        contents((ind+1):end)];
        end
    end
else
    % change the Singleton line
    if(prev_options.singleton ~= options.singleton)
        ind = findSingletonString(filename,contents);
        if ~isempty(ind)
            contents = [contents(1:(ind(1)-1)), NL, ...
                        makeSingletonString(options.singleton), NL, ...
                        contents((ind(2)+1):end)];
        end
    end
end

%
%----------------------------------------------------------------------
%
function str = AUTOMATIC
str = '%automatic';


%
%----------------------------------------------------------------------
%
function setAutoCallback(h, cb)
set(h, cb, AUTOMATIC);
com.mathworks.ide.inspector.Inspector.refreshIfOpen;


%
%----------------------------------------------------------------------
%
function chooseCopyCallbacks(fig, hOriginalVec, hDupVec)

 options = guideopts(fig);
% for j=1:length(hDupVec)
%     % For external controls, always set the callbacks of the newly copied
%     % objects to AUTOMATIC because those properties will not be saved when
%     % save the GUI (instance properties). For HG objects, this is done only
%     % in FIG/M-file format so that the AUTOMATIC string will not be saved
%     % in the FIG file.
%     h = hOriginalVec{j};
%     if isExternalControl(h) | (options.mfile & options.callbacks)
%         callbacks = getCallbackProperties(h);
%         for i=1:length(callbacks)
%             if ~isempty(get(h, callbacks{i}))
%                 setAutoCallback(hDupVec(j), callbacks{i});
%             end
%         end
%     end
% end

% choose default AUTOMATIC callbacks. If users delete the default callback,
% here is another change to add it.
if options.mfile & options.callbacks
    guidemfile('chooseAutoCallbacks',hDupVec);
end

%
%----------------------------------------------------------------------
%
function chooseAutoCallbacks(hVec)
for h = hVec(:)'
    if strcmp(get(h,'Type'),'uicontrol')
        style = get(h,'Style');
        if strcmp(style, 'frame') | strcmp(style,'text')
            % frames and text objects have callbacks but they never execute
            continue;
        end
        if strcmp(style, 'popupmenu') | strcmp(style, 'listbox') | strcmp(style, 'edit') | strcmp(style,'slider')
            % automatically put in the create fcn for white bg handling
            setAutoCallback(h,'CreateFcn');
        end

        if (~((strcmp(style,'radiobutton') || strcmp(style,'togglebutton')) && isa(handle(get(h,'parent')), 'uitools.uibuttongroup')))
            setAutoCallback(h,'Callback');
        end
    end
end

%
%----------------------------------------------------------------------
% If newFunc name is not given, all auto generated callbacks will be
% renamed to AUTOMATIC
function renameCallbacks(hVec, oldFunc, newFunc)
if nargin < 3
    isAutomatic = 1;
else
    isAutomatic = 0;
end
oldLen = length(oldFunc);
for h = hVec(:)'
    callbacks = getCallbackProperties(h);
    for cb = callbacks(:)'
        val = get(h, cb{:});
        if strncmp(val, oldFunc, oldLen) & ...
                (...
                    length(val) == oldLen |...
                    val(oldLen+1) == ' '   |...
                    val(oldLen+1) == '('    ...
                    )
            if isAutomatic
                newVal = AUTOMATIC;
            else
                newVal = [newFunc, val((oldLen + 1):end)];
            end
            set(h, cb{:}, newVal);
        end
    end
end
com.mathworks.ide.inspector.Inspector.getInspector.refreshIfOpen;


%
%----------------------------------------------------------------------
%
function loseAutoCallbacks(hVec)
for h = hVec(:)'
    callbacks = getCallbackProperties(h);
    for cb = callbacks(:)'
        if isequal(get(h, cb{:}), AUTOMATIC)
            set(h, cb{:}, '');
        end
    end
end
com.mathworks.ide.inspector.Inspector.getInspector.refreshIfOpen;


%
%----------------------------------------------------------------------
%
function external = isExternalControl(h)

external = 0;

% ActiveX does not support application data
if ishandle(h)
    try
        external = isappdata(h, 'Control');
    catch
        external = 0;
    end
end

%
%----------------------------------------------------------------------
%
function info = getExternalControlInfo(obj)

info =[];

if isExternalControl(obj)
    info = getappdata(obj, 'Control');
end

%
%----------------------------------------------------------------------
%
function callbacks = getCallbackProperties(h)
% h can be a valid HG handle or a handle structure for HG object. The later
% is used by printdmfile.

callbacks = [];
uitype = '';
uistyle = '';

if ishandle(h)
    if isExternalControl(h)
        info = getExternalControlInfo(h);
        uitype = info.Type;
        uistyle = info.Style;
    else
        uitype = class(handle(h));
        if strcmpi(uitype,'uicontrol')
            uistyle = get(h,'Style');
        end
    end    
elseif isstruct(h)
    if isfield(h,'type')
        uitype = h.type;
    end
    try
        info = h.properties.ApplicationData.Control;
        uitype = info.Type;
        uistyle = info.Style;
    catch
    end
end

if ~isempty(uitype)
    common = {'CreateFcn'; 'DeleteFcn'; 'ButtonDownFcn'};
    switch uitype
        case 'activex'
            if ishandle(h)
                info = getExternalControlInfo(h);
                control = info.Instance;
                eventlist = events(control);
                if ~isempty(eventlist)
                    callbacks = fieldnames(eventlist);
                end
            end
        case 'figure'
            callbacks = [common,
                {'WindowButtonDownFcn',
                'WindowButtonMotionFcn',
                'WindowButtonUpFcn',
                'KeyPressFcn',
                'ResizeFcn',
                'CloseRequestFcn'}];
        case {'uimenu','uicontextmenu'}
            callbacks = [{'Callback'}; common];
        case 'axes'
            callbacks = common;
        case 'uicontrol'
            if strcmpi(uistyle, 'frame') | strcmpi(uistyle, 'text')
                callbacks = [common];
            else
                callbacks = [{'Callback'};common;{'KeyPressFcn'};];
            end
        case 'uipanel'
            callbacks = [common,
                {'ResizeFcn'}];
        case 'uitools.uibuttongroup'
            callbacks = [common,
                {'ResizeFcn',
                 'SelectionChangeFcn'}];
        case 'uicontainer'
            callbacks = [common];
    end
end

%
%----------------------------------------------------------------------
%
function contents = appendCallbacks(contents, fig, funcname, options)
% traverse the tree of objects, looking for any callback containing
% '%automatic'.  Replace that callback property with the "magic
% incantation" to get into the subfunction, and append that
% subfunction (if it doesnt' already exist).

subfcncallback = 'function %s(hObject, eventdata, handles)';

% arrange handles in desired order: uicontrol Callbacks + menu Callbacks
top = flipud(findall(fig));
menu = [findobj(top,'Type','uimenu');findobj(top,'Type','uicontextmenu')];
all_h = fig;
all_menu = [];
for i=1:length(top)
    if (isempty(find(menu==top(i))))
        all_h=[all_h;top(i)];
    else
        all_menu= [all_menu;sort(findall(top(i)))];
    end
end
all_h=[all_h;all_menu];

all_h = handle(all_h);
for i = 1:length(all_h)

    callbacks = getCallbackProperties(all_h(i));
    this_tag = get(all_h(i),'tag');
    objtype = get(all_h(i),'type');

    for cb = 1:length(callbacks)
        if strcmp(get(handle(all_h(i)),callbacks{cb}), AUTOMATIC)
            this_cb = callbacks{cb};
            % find out what the callback was before this.  If it was
            % already a call into this function, just put it back, else,
            % construct a subfunction for it:
            PREVIOUS_CALLBACK = ['preserve',lower(this_cb)];
            body = getappdata(all_h(i), PREVIOUS_CALLBACK);

            [p,n,e]=fileparts(getCBMfileName(fig,body));
            if strcmp(n, funcname)
                % put it back if it was already a call into this file:
                set(all_h(i),this_cb,body);
            else
                % Check if the object's tag is a valid variable name - if
                % not, then skip this callback, and issue a warning to the
                % user prompting them to change the tag if they want a
                % callback.  When OK is pressed on the warning dialog, jump
                % to that object's tag property in the inspector:
                if ~isvarname(this_tag)
                    warnstr = sprintf(['Tag must be a legal variable name for GUIDE to append a callback function prototype to the application M-file. ',...
                                       'The %s for the %s with Tag: ''%s'' ',...
                                       'can not be appended until a legal tag is chosen'], this_cb,get(all_h(i),'type'),this_tag);
                    warnfig = warndlg(warnstr, 'GUIDE');
                    setappdata(warnfig, 'GUIDEInspectMe',all_h(i));
                    set(warnfig,'deletefcn','guidemfile(''delayedInspectTag'')');
                    continue
                end

                % construct a callback property value for the object to
                % call into this file:
                subfcn = [this_tag '_' this_cb];
                % replace %automatic with callback of form
                % mfilename('subfcn',gcbo,[],guidata(gcbo))
                if strcmp(objtype,'figure') & strcmp(callbacks{cb},'CloseRequestFcn')
                    % using gcbo here will make close(h) from the command line fail
                    callback = [funcname, '(''', subfcn, ''',gcbf,[],guidata(gcbf))'];
                else
                    callback = [funcname, '(''', subfcn, ''',gcbo,[],guidata(gcbo))'];
                end
                set(all_h(i),callbacks{cb},callback);

                % Now add the subfuction to this file (if it doesn't
                % already exist):
                existingSubfuncs = getFunctionNames(contents);
                if isempty(strmatch(subfcn, existingSubfuncs, 'exact'))
                    fcndeclaration = sprintf(subfcncallback, subfcn);

                    if isempty(body)
                        body = sprintf('\n');
                    end
                    if strcmp(objtype,'uicontrol')
                        style = get(all_h(i),'style');
                    else
                        style = objtype;
                    end
                    % trim trailing new lines
                    ind = 0;
                    while ind < length(contents)
                        if contents(end) == NL
                            contents = contents(1:end-1);
                        else
                            break;
                        end
                        ind = ind + 1;
                    end
                    contents = [
                        contents, NL, ...
                        NL, ...
                        NL, ...
                        makeFunctionPreComment(all_h(i), callbacks{cb},objtype,style,this_tag),  NL, ...
                        fcndeclaration, NL, ...
                        makeFunctionPostComment(all_h(i), callbacks{cb},objtype,style,this_tag),  NL, ...
                        body
                               ];
                end % end if callback subfunction needs to be appended
            end % end if callback was already calling into this file

            if isappdata(all_h(i), PREVIOUS_CALLBACK)
                rmappdata(all_h(i), PREVIOUS_CALLBACK);
            end

        end % end converting %automatic callback
    end % end WHILE loop over all callbacks on this object
end % end loop over all objects
com.mathworks.ide.inspector.Inspector.getInspector.refreshIfOpen;

%
%----------------------------------------------------------------------
%
function delayedInspectTag
warnfig = gcbo;
inspectMe = getappdata(gcbo,'GUIDEInspectMe');
inspect(inspectMe);
com.mathworks.ide.inspector.Inspector.activateInspector
com.mathworks.ide.inspector.Inspector.getInspector.selectProperty(java.lang.String('Tag'));

%
%----------------------------------------------------------------------
%
function n = NL
n = 10; % ascii newline character

%
%----------------------------------------------------------------------
%
function c = CR
c = 13; % ascii carriage-return character

%
%----------------------------------------------------------------------
%
function contents = makeFileContents(filename, options)
% Generate the main function the first time through:

[path, filename, ext] = fileparts(filename);
FILENAME = upper(filename);
contents =[ 'function varargout = ' filename '(varargin)',NL,...
    '%' FILENAME ' M-file for ' filename '.fig',NL,...
    '%      ' FILENAME ', by itself, creates a new ' FILENAME ' or raises the existing',NL,...
    '%      singleton*.',NL,...
    '%',NL,...
    '%      H = ' FILENAME ' returns the handle to a new ' FILENAME ' or the handle to',NL,...
    '%      the existing singleton*.',NL,...
    '%',NL,...
    '%      ' FILENAME '(''Property'',''Value'',...) creates a new ' FILENAME ' using the',NL,...
    '%      given property value pairs. Unrecognized properties are passed via',NL,...
    '%      varargin to ' filename '_OpeningFcn.  This calling syntax produces a',NL,...
    '%      warning when there is an existing singleton*.',NL,...
    '%',NL,...
    '%      ' FILENAME '(''CALLBACK'') and ' FILENAME '(''CALLBACK'',hObject,...) call the',NL,...
    '%      local function named CALLBACK in ' FILENAME '.M with the given input',NL,...
    '%      arguments.',NL,...
    '%',NL,...
    '%      *See GUI Options on GUIDE''s Tools menu.  Choose "GUI allows only one',NL,...
    '%      instance to run (singleton)".',NL,...
    '%',NL,...
    '% See also: GUIDE, GUIDATA, GUIHANDLES',NL,...
    '',NL,...
    '% Edit the above text to modify the response to help ' filename '',NL,...
    '',NL,...
    '% ', makeVersionString,NL,...
    '',NL,...
    makeGuiInitializationCode(filename, options) ...
    makeOpeningFcn(filename), ...
    makeOutputFcn(filename)];



%
%----------------------------------------------------------------------
%
function guiMainCode = makeGuiInitializationCode(filename, options)

guiMainCode=[...
    '% Begin initialization code - DO NOT EDIT',NL,...
    'gui_Singleton = ', num2str(options.singleton),';',NL,...
    'gui_State = struct(''gui_Name'',       mfilename, ...',NL,...
    '                   ''gui_Singleton'',  gui_Singleton, ...',NL,...
    '                   ''gui_OpeningFcn'', @', filename,'_OpeningFcn, ...',NL,...
    '                   ''gui_OutputFcn'',  @', filename,'_OutputFcn, ...',NL,...
    '                   ''gui_LayoutFcn'',  [], ...',NL,...
    '                   ''gui_Callback'',   []);',NL,...
    'if nargin && ischar(varargin{1})',NL,...
    '   gui_State.gui_Callback = str2func(varargin{1});',NL,...
    'end',NL,...
    '',NL,...
    'if nargout',NL,...
    '    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});',NL,...
    'else',NL,...
    '    gui_mainfcn(gui_State, varargin{:});',NL,...
    'end',NL,...
    '% End initialization code - DO NOT EDIT',NL,...
    '',NL,...
    '',NL];

%    'gui_Name  = mfilename;',NL,...
%    'gui_main;',NL,...

%
%----------------------------------------------------------------------
%
function openingFcn = makeOpeningFcn(filename)

openingFcn=[...
    '% --- Executes just before ' filename ' is made visible.',NL,...
    'function ' filename '_OpeningFcn(hObject, eventdata, handles, varargin)',NL,...
    '% This function has no output args, see OutputFcn.',NL,...
    '% hObject    handle to figure',NL,...
    '% eventdata  reserved - to be defined in a future version of MATLAB',NL,...
    '% handles    structure with handles and user data (see GUIDATA)',NL,...
    '% varargin   unrecognized PropertyName/PropertyValue pairs from the',NL,...
    '%            command line (see VARARGIN)',NL,...
    '',NL,...
    '% Choose default command line output for ' filename,NL,...
    'handles.output = hObject;',NL,...
    '',NL,...
    '% Update handles structure',NL,...
    'guidata(hObject, handles);',NL,...
    '',NL,...
    '% UIWAIT makes ' filename ' wait for user response (see UIRESUME)',NL,...
    '% uiwait(handles.figure1);',NL];

%
%----------------------------------------------------------------------
%
function outputFcn = makeOutputFcn(filename)

outputFcn=[...
    '',NL,...
    '',NL,...
    '% --- Outputs from this function are returned to the command line.',NL,...
    'function varargout = ' filename '_OutputFcn(hObject, eventdata, handles)',NL,...
    '% varargout  cell array for returning output args (see VARARGOUT);',NL,...
    '% hObject    handle to figure',NL,...
    '% eventdata  reserved - to be defined in a future version of MATLAB',NL,...
    '% handles    structure with handles and user data (see GUIDATA)',NL,...
    '',NL,...
    '% Get default command line output from handles structure',NL,...
    'varargout{1} = handles.output;',NL];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                 VERSION handling                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = makeVersionString
prefix = getVersionPrefix;
verStr = '2.5';
dateStr = date;
timeVec = clock;
timeStr = sprintf('%02d:%02d:%02d',fix(timeVec(4:6)));
str = sprintf('%s%s %s %s',prefix,verStr,dateStr,timeStr);


%
%----------------------------------------------------------------------
%
function result = updateVersionString(filename, contents)

result = contents;
ind = findVersionString(filename,contents);
if ~isempty(ind)
    result = [contents(1:(ind(1)-1)),...
                makeVersionString,NL,...
                contents((ind(2)+1):end)];
end


%
%----------------------------------------------------------------------
%
function ind = findVersionString(filename,contents)
% return start and end index of version string (or [] if not found)
% consider the whole line from the beginning of the string to the
% \n to be the version string.
ind = [];
prefix = getVersionPrefix;
len = length(prefix);
ver_begin = findSignatureHead(filename,contents, prefix, 0);
if ~isempty(ver_begin)
    ver_end = ver_begin + len;
    line_end = findNextOccurenceOfCharacter(contents, ver_end, NL);
    ind = [ver_begin, line_end];
end

function str = makeSingletonString(is_singleton)
if is_singleton
    str = 'gui_Singleton = 1;';
else
    str = 'gui_Singleton = 0;';
end

%
%----------------------------------------------------------------------
%
function str = getVersionPrefix
str = 'Last Modified by GUIDE v';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                CONSTRUCTOR handling                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = makeConstructorString(is_singleton)
if is_singleton
    arg = 'reuse';
else
    arg = 'new';
end
str = sprintf('openfig(mfilename,''%s'',varargin{:});',arg);

%
%----------------------------------------------------------------------
%
function ind = findConstructorString(filename,contents)

ind = [];
const_start = findSignatureHead(filename,contents, 'openfig',1);
if ~isempty(const_start)
    const_end = const_start + 6;
    if contents(const_end + 1) == '('
        closeparen = findNextOccurenceOfCharacter(contents, const_start,')');
        const_end = closeparen;
        if contents(const_end + 1) == ';'
            const_end = const_end + 1;
        end
    end
    ind = [const_start const_end];
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                SYSCOLOR handling                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = makeSyscolorString(is_syscolorfig)

if is_syscolorfig
    str = sprintf('%s\n%s', getSyscolorComment,getSyscolorCode);
else
    str = '';
end

%
%----------------------------------------------------------------------
%
function str = getSyscolorComment %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
str = '% Use system color scheme for figure:';

%
%----------------------------------------------------------------------
%
function str = getSyscolorCode %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
str = 'set(fig,''Color'',get(0,''DefaultUicontrolBackgroundColor''));';

%
%----------------------------------------------------------------------
%
function ind = findSyscolorString(filename,contents) %%%%%%%%%%%%%%%%%%%%%
comment = findLineExtent(contents, findSignatureHead(filename,contents, getSyscolorComment, 0));
code = findLineExtent(contents, findSignatureHead(filename,lower(contents), lower(getSyscolorCode),1));
if isempty(code)
    code = findLineExtent(contents, findStrWithSpacing(lower(contents), lower(getSyscolorCode)));
end

ind = [min([comment code]) max([comment code])];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                BLOCKING handling                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = getBlockingComment
str = '% Wait for callbacks to run and window to be dismissed:';
function str = getBlockingCode(options)
str = 'uiwait(fig);';

%
%----------------------------------------------------------------------
%
function str = makeBlockingString(is_blocking,options)
if is_blocking
    str = sprintf('%s\n%s',getBlockingComment, getBlockingCode(options));
else
    str = '';
end

%
%----------------------------------------------------------------------
%
function ind = findBlockingString(filename,contents,options)
lines = [findLineExtent(contents, findSignatureHead(filename,contents,getBlockingComment, 0)),...
	 findLineExtent(contents, findSignatureHead(filename,contents,getBlockingCode(options), 0))];
ind = [min(lines), max(lines)];

%
%----------------------------------------------------------------------
%
function ind = findSingletonString(filename,contents)
lines = findLineExtent(contents, findSignatureHead(filename,contents,'gui_Singleton =',0));
ind = [min(lines), max(lines)];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             STRING SEARCHING UTILITIES                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ind = findLineExtent(contents, pos) %%%%%%%%%%%%%%%%%%%%%%
if isempty(pos)
    ind = [];
else
    ind = [findPreviousOccurenceOfCharacter(contents, pos, NL),...
           findNextOccurenceOfCharacter(contents, pos, NL)];
end

%
%----------------------------------------------------------------------
%
function ind = findNextOccurenceOfCharacter(contents, pos, character)
occurrences = find(contents == character);
% only care about the first one
ind = occurrences(min(find(occurrences>pos(1))));

%
%----------------------------------------------------------------------
%
function ind = findPreviousOccurenceOfCharacter(contents, pos, character)
occurrences = find(contents == character);
% only care about the first one
ind = occurrences(max(find(occurrences<pos(1))));

%
%----------------------------------------------------------------------
%
function index = findSignatureHead(filename,contents, signature, inCommand)
persistent warnedFlags;

index = [];

% get the positions of occurrence of signature
occurrences = findstr(contents, signature);
counter = 0;

% process each occurrence
candidates = [];

% if inCommand ==1, ignore occurrences of signature in comments
if (inCommand)
    thisLine =[];
    numOccurrences = length(occurrences);
    while ( ~isempty(contents) & counter < numOccurrences)
        [thisLine,contents] = strtok(contents, NL);

        % search each line
        newPos = findstr(thisLine, signature);

        % add to candidates if signature string is not in comments
        for i=1:length(newPos)
            if (isempty(findstr(thisLine(1:newPos(i)),'%')))
                candidates = [candidates; occurrences(counter+1)];
            end
        end

        % index into the accurate positions of the signature in occurrences
        counter = counter + length(newPos);
    end
else
    % search everywhere, including comments
    candidates = occurrences;
end

% show warning dialog if first time detection of multiple copies of signature
if (~isempty(candidates))
    index = candidates(1);

    % form signature field name
    field = signature;
    field(find(~isletter(field))) =[];
    % structure field name length must less than 31
    % should chose longer enough to form unique field names
    if length(field) > 30
        field = field(1:30);
    end

    name = fliplr(filename);
    name(find(~isletter(name))) =[];
    if length(name) > 30
        name = name(1:30);
    end

    if (length(candidates) > 1)
        % maintain warning structure
        % warning flags is per m file
        if (isempty(warnedFlags))
            warnedFlags = struct(name,struct('Function', name));
        elseif  ~isfield(warnedFlags, name)
            warnedFlags.(name) =  struct('Function', name);
        end

        % show warning dialog if first time detection
        if (length(field) > 0 & ~isfield(eval(['warnedFlags.',name]), field))
            myFlags = eval(['warnedFlags.',name]);
            myFlags.(field) = 1;
            warnedFlags.(name) = myFlags;
            message=sprintf('In file %s, there are multiple copies of system string: \n\n %s\n\nYour program may not run properly. Please remove extra copies.', filename, signature);
            warndlg(message);
        end
    else
        % remove the corresponding field so that changes later can still cause warning dialog
        if (~isempty(warnedFlags) & isfield(warnedFlags, name) & isfield(eval(['warnedFlags.',name]), field))
            myFlags = eval(['warnedFlags.',name]);
            myFlags = rmfield(myFlags,field);
            warnedFlags.(name) = myFlags;
        end
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                    OTHER UTILITIES                        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function mname = getCBMfileName(fig, cb)
% parse callback of the form: FUNCTION('SUBFUNCTION',...)
% returning the full path to the Mfile named FUNCTION
mname = '';
if ~isempty(cb)
    funcname_end = min([find(cb==' '),find(cb == '('),length(cb)+1]);
    mcommand = cb(1:(funcname_end-1));

    figfile = get(fig,'filename');
    if isempty(figfile)
    	mname = which(mcommand);
    else
        [p,f,e] = fileparts(figfile);
        mname = fullfile(p,[f, '.m']);
    end
end

%
%----------------------------------------------------------------------
%
function cbname = getCBSubfunctionName(cb)
cbname = '';
quotes = find(cb=='''');
if length(quotes) >= 2
    cbname = cb((quotes(1)+1):(quotes(2)-1));
end

%
%----------------------------------------------------------------------
%
function lineno = getSubfunctionLineNumber(mname, cbname)
contents = getFileContents(mname,[]);
[names, linenos] = getFunctionNames(contents);
ind = strmatch(cbname, names, 'exact');
if length(ind) == 1
    %  lineno = length(find(find(contents==NL) < ind)) + 1;
    lineno = linenos(ind);
else
    lineno = 1;
end

%
%----------------------------------------------------------------------
%
function scrollToCBSubfunction(fig, obj, whichCb)
currentCb = get(handle(obj),whichCb);
if ~strcmp(currentCb, AUTOMATIC)
    mfunc = getCBMfileName(fig, currentCb);
    subfunc = getCBSubfunctionName(currentCb);
    lineno = getSubfunctionLineNumber(mfunc,subfunc);
    com.mathworks.mlservices.MLEditorServices.openDocumentToLine(...
        mfunc, lineno, 1, 1);
end


%
%----------------------------------------------------------------------
%
function preComment = makeFunctionPreComment(hObject, callbackName, objType, objStyle, objTag)
lineLength = 70;
preComment = ['% ' ones(1,lineLength-2)*abs('-')];
switch callbackName
 case 'Callback'
  switch objStyle
   case {'pushbutton','togglebutton','radiobutton','checkbox'}
    preComment = sprintf('%% --- Executes on button press in %s.', objTag);
   case 'edit'
    preComment = sprintf([
        '% --- Executes when user selects %s and presses enter.  Also executes\n', ...
        '% --- if user changes contents and clicks outside %s.'], objTag, objTag);
   case 'text'
    % use default, text objects do not fire callbacks
   case 'slider'
    preComment = sprintf('%% --- Executes on slider movement.');
    % use default, frame objects do not fire callbacks
   case {'listbox', 'popupmenu'}
    preComment = sprintf('%% --- Executes on selection change in %s.', objTag);
   otherwise
    % use default, unknown object type
  end
 case 'CreateFcn'
  preComment = sprintf('%% --- Executes during object creation, after setting all properties.');
 case 'DeleteFcn'
  preComment = sprintf('%% --- Executes during object deletion, before destroying properties.');
 case 'ButtonDownFcn'
  switch objType
   case 'uicontrol'
    preComment = sprintf([
        '%% --- If Enable == ''on'', executes on mouse press in 5 pixel border.\n', ...
        '%% --- Otherwise, executes on mouse press in 5 pixel border or over %s.'], objTag);
   case 'figure'
    preComment = sprintf('%% --- Executes on mouse press over figure background.');
   case 'axes'
    preComment = sprintf('%% --- Executes on mouse press over axes background.');
   otherwise
    % use default, unknown object type
  end
 case {'WindowButtonDownFcn', 'WindowButtonUpFcn'}
  preComment = sprintf([
      '%% --- Executes on mouse press over figure background, over a disabled or\n', ...
      '%% --- inactive control, or over an axes background.']);
 case 'WindowButtonMotionFcn'
  preComment = sprintf('%% --- Executes on mouse motion over figure - except title and menu.');
 case 'KeyPressFcn'
  preComment = sprintf('%% --- Executes on key press over %s with no controls selected.', objTag);
 case 'ResizeFcn'
  preComment = sprintf('%% --- Executes when %s is resized.', objTag);
 case 'CloseRequestFcn'
  preComment = sprintf('%% --- Executes when user attempts to close %s.', objTag);
 otherwise
  % use default, unknown callback type
end

%
%----------------------------------------------------------------------
%
function postComment = makeFunctionPostComment(hObject, callbackName, objType, objStyle, objTag)
if isExternalControl(hObject)
    eventdata = sprintf('%% eventdata  structure with parameters passed to COM event listerner\n');
else
    eventdata = sprintf('%% eventdata  reserved - to be defined in a future version of MATLAB\n');
end
postComment = sprintf([
    '%% hObject    handle to %s (see GCBO)\n%s', ...
    '%% handles    structure with handles and user data (see GUIDATA)\n'], ...
                      objTag, eventdata);
switch callbackName
 case 'Callback'
  switch objStyle
   case 'pushbutton'
    % use default
   case {'togglebutton','radiobutton','checkbox'}
    postComment = sprintf( [
        '%s\n', ...
        '%% Hint: get(hObject,''Value'') returns toggle state of %s\n', ...
     ], postComment, objTag);
   case 'edit'
    postComment = sprintf( [
        '%s\n', ...
        '%% Hints: get(hObject,''String'') returns contents of %s as text\n', ...
        '%%        str2double(get(hObject,''String'')) returns contents of %s as a double\n', ...
     ], postComment, objTag, objTag);
   case 'text'
    % use default, text objects do not fire callbacks
   case 'slider'
    postComment = sprintf( [
        '%s\n', ...
        '%% Hints: get(hObject,''Value'') returns position of %s\n', ...
        '%%        get(hObject,''Min'') and get(hObject,''Max'') to determine range of %s\n', ...
     ], postComment, objStyle, objStyle);
   case 'frame'
    % use default, frame objects do not fire callbacks
   case {'listbox','popupmenu'}
    postComment = sprintf( [
        '%s\n', ...
        '%% Hints: contents = get(hObject,''String'') returns %s contents as cell array\n', ...
        '%%        contents{get(hObject,''Value'')} returns selected item from %s\n', ...
     ], postComment, objTag, objTag);
   otherwise
    % use default, unknown object type
  end
 case 'CreateFcn'
  postComment = sprintf([
      '%% hObject    handle to %s (see GCBO)\n', ...
      '%% eventdata  reserved - to be defined in a future version of MATLAB\n', ...
      '%% handles    empty - handles not created until after all CreateFcns called\n'], ...
                        objTag);
  switch objStyle
   case 'axes'
      postComment = sprintf( [
          '%s\n', ...
          '%% Hint: place code in OpeningFcn to populate %s\n', ...
                   ], postComment, objTag);
   case {'listbox', 'popupmenu', 'edit'}
    postComment = sprintf( [
        '%s\n', ...
        '%% Hint: %s controls usually have a white background on Windows.\n', ...
        '%%       See ISPC and COMPUTER.\n', ...
        'if ispc\n', ...
        '    set(hObject,''BackgroundColor'',''white'');\n', ...
        'else\n', ...
        '    set(hObject,''BackgroundColor'',get(0,''defaultUicontrolBackgroundColor''));\n', ...
        'end\n', ...
                   ], postComment, objStyle);
   case 'slider'
    postComment = sprintf( [
        '%s\n', ...
        '%% Hint: %s controls usually have a light gray background, change\n', ...
        '%%       ''usewhitebg'' to 0 to use default.  See ISPC and COMPUTER.\n', ...
        'usewhitebg = 1;\n', ...
        'if usewhitebg\n', ...
        '    set(hObject,''BackgroundColor'',[.9 .9 .9]);\n', ...
        'else\n', ...
        '    set(hObject,''BackgroundColor'',get(0,''defaultUicontrolBackgroundColor''));\n', ...
        'end\n', ...
                   ], postComment, objStyle);

  end
 case 'DeleteFcn'
  % use default
 case 'ButtonDownFcn'
  switch objType
   case 'uicontrol'
    % use default
   case 'figure'
    % use default
   case 'axes'
    % use default
   otherwise
    % use default, unknown object type
  end
 case 'WindowButtonDownFcn'
  % use default
 case 'WindowButtonMotionFcn'
  % use default
 case 'WindowButtonUpFcn'
  % use default
 case 'KeyPressFcn'
  % use default
 case 'ResizeFcn'
  % use default
 case 'CloseRequestFcn'
  postComment = sprintf( [
      '%s\n', ...
      '%% Hint: delete(hObject) closes the figure\n', ...
      'delete(hObject);\n', ...
                   ], postComment);
 otherwise
  % use default, unknown callback type
end

%
%----------------------------------------------------------------------
%
% ***************************************************************
% Try to find System Color string - in case user inserted spaces.
% contents - contents of M-file.
% str      - string that is being searched for.
function codeIndex = findStrWithSpacing(contents, str)

% Initialize variables.
codeIndex = [];

% Determine if defaultUicontrolBackgroundColor is in contents.
% If not codeIndex = [] and return.
codeIndex = findstr('defaultuicontrolbackgroundcolor', contents);
if isempty(codeIndex)
    return
end

% Determine if the remaining contents of the DefaultUicontrolBackgroundColor
% line is str.

% Remove spaces.
str((str == ' ')) = '';

% Extract the line.
for i = 1:length(codeIndex)
    index = findLineExtent(contents, codeIndex(i));
    contentsLine = contents(index(1)+1:index(2)-1);

    % Remove spaces.
    contentsLine((contentsLine == ' ')) = '';

    % Compare - Return index if the same otherwise return [] (initialized value).
    if strcmp(str, contentsLine)
        codeIndex = index(1)+1;
        return;
    end
end

% If defaultUicontrolBackgroundColor is found but it is not part
% of the entire string need to reset codeIndex to empty.
codeIndex = [];


% *************************************************************************
% find all children of a given HG object with the designated filter(s)
% *************************************************************************
function children = findAllChildFromHere(parent, filter)

parent =double(parent);
children = [];

if nargin <=1
    filter = [];    
end
if ~isfield(filter, 'includeParent')
    filter.includeParent = 0;
end
if ~isfield(filter, 'recursiveSearch')
    filter.recursiveSearch = 1;
end
if ~isfield(filter, 'childrenInReverseOrder')
    filter.childrenInReverseOrder = 1;
end
if ~isfield(filter, 'uiobjectOnly')
    filter.uiobjectOnly = 1;
end
if ~isfield(filter, 'uicontainerOnly')
    filter.uicontainerOnly = 0;
end
if ~isfield(filter, 'includeHiddenHandles')
    filter.includeHiddenHandles = 1;
end

%do not search for axes child
if strcmpi(get(parent,'type'),'axes')
    if filter.includeParent ==1
        children = parent;
    else
        children =[];
    end
    return;
end

if filter.recursiveSearch == 1
    % need to search for children layer by layer and the order
    % of all children in each layer should be reversed
    if filter.includeParent ==1
        childlist(1) =double(parent);
    else
        childlist =[];
    end
    if filter.childrenInReverseOrder
        mychildren = flipud(allchild(parent));
    else
        mychildren = allchild(parent);
    end
    while (~isempty(mychildren))
        childlist = [childlist;mychildren];
        % do not include axes children
        index = find(ismember(get(mychildren,'Type'),{'axes'}));
        mychildren(index) = [];
        if filter.childrenInReverseOrder
            temp = flipud(mychildren);
        else
            temp = mychildren;
        end
        mychildren = [];
        for i=1:length(temp)
            if filter.childrenInReverseOrder
                mychildren = [mychildren; flipud(allchild(temp(i)))];
            else
                mychildren = [mychildren; allchild(temp(i))];
            end
        end
    end
else
    childlist = flipud(allchild(parent));
end

if ~isempty(childlist) & filter.includeHiddenHandles ~= 1
    notin = find(ismember(get(childlist,'HandleVisibility'),{'off'}));
    childlist(notin)=[];
end

if ~isempty(childlist) & filter.uiobjectOnly ==1
    notin = find(ismember(get(childlist,'Type'),{'uimenu'}));
    notin = [notin ; find(ismember(get(childlist,'Type'),{'uicontextmenu'}))];
    notin = [notin ; find(ismember(get(childlist,'Type'),{'uitoolbar'}))];        
    notin = [notin ; find(ismember(get(childlist,'Type'),{'uitoggletool'}))];
    notin = [notin ; find(ismember(get(childlist,'Type'),{'uipushtool'}))];        
    childlist(notin)=[];
end

if ~isempty(childlist) & filter.uicontainerOnly ==1
    notin = find(ismember(get(childlist,'Type'),{'uicontrol'}));
    notin = [notin; find(ismember(get(childlist,'Type'),{'axes'}))];
    childlist(notin)=[];
end

% filter out all uicontrols used as panel title
titles=[];
if ~isempty(childlist)
    for i=1:length(childlist)
        h= handle(childlist(i));
        if isa(h,'uipanel') | isa(h,'uitools.uibuttongroup')
            titles(end+1) = i;
        end        
    end
    if ~isempty(titles)
        warning off MATLAB:Uipanel:HiddenImplementation;
        thandles= get(childlist(titles),'TitleHandle');
        if ~isempty(thandles)
            if iscell(thandles)
                thandles = cell2mat(thandles);
            end
            index=find(ismember(childlist, thandles));
            childlist(index) = [];
        end
    end
end

children = double(childlist);

