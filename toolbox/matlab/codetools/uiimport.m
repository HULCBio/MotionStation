function varargout = uiimport(varargin)
%UIIMPORT Starts the GUI for importing data (Import Wizard).
%
%   UIIMPORT Starts the Import Wizard in the current directory.  Options to
%   load data from a file or the clipboard are presented.
%
%   UIIMPORT(FILENAME) Starts the Import Wizard, opening the file specified
%   in FILENAME.  The Import Wizard displays a preview of the data in the
%   file.
%
%   UIIMPORT('-file') works as above but the file selection dialog is
%   presented first.
%
%   UIIMPORT('-pastespecial') works as above but the clipboard contents are
%   presented first.
%
%   S = UIIMPORT(...) works as above with resulting variables stored as
%   fields in the struct S.
%
%   For ASCII data, you must verify that the Import Wizard recognized the
%   column delimiter.
%
%   See also LOAD, FILEFORMATS, CLIPBOARD, IMPORTDATA.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.9 $  $Date: 2004/03/02 21:46:34 $

%   N.B.: This function uses undocumented java objects whose behavior will
%       change in future releases.  When using this function as an example,
%       use Java objects from the java.awt or javax.swing packages to
%       ensure forward compatibility.

% Lock the file into memory, since it has persistent variables
% which must last for an entire (non-blocking) invocation.
mlock;

% A handle to an asynchronously-invoked intance (if any), which we can
% bring to the foreground on subsequent calls.
persistent asynchronousInstance;

isSynchronous = (nargout == 1);

% If we already have an asynchronous instance available, either use it or
% error out apprporiately.
if ~isempty(asynchronousInstance)
    if ~isSynchronous
        % Warning: the AWTINVOKE function may not be available in the final
        % release, or its syntax may change without warning.  Do not use the
        % AWTINVOKE function in other contexts.
        awtinvoke(asynchronousInstance, 'setVisible', true);
        asynchronousInstance.toFront;
        return;
    else
        % An asynchronous instance is already us, and the user is trying to
        % start a synchronous instance.  This is going to cause a lot of
        % problems.  We don't want to attach to the existing one, since the
        % synchronous version is most likely being invoked on behalf of
        % some other code.  We don't want to ignore the new request, but we
        % can't honor it intelligently, either.  Error.
        error('MATLAB:uiimport:incompatableInstances', ...
            ['Cannot open an Import Wizard with output arguments while ' ...
            'another Import Wizard is open.']);
    end
end

% ad is the primary piece of data that is shared between the primary
% function and the nested functions of this file.
ad = '';

% If the user didn't specify any input arguments, just initialize the
% Wizard contents normally.  Otherwise, figure out exactly what the user is
% requesting and act accordingly.
if nargin == 0
    iwc = com.mathworks.mde.dataimport.ImportWizardContents;
else
    if strcmp(varargin{1}, '-file')
        fileFromDialog = com.mathworks.mde.dataimport.ImportFileChooser.showImportFileDialog([]);
        if isempty(fileFromDialog)
            if nargout > 0
                varargout{1} = [];
            end
            return;
        end
        fileAbsolutePath = char(fileFromDialog.getAbsolutePath);
    else
        fileAbsolutePath = varargin{1};
    end
    if useAlternateImportTool(fileAbsolutePath)
        if nargout > 0
            varargout{1} = [];
        end
        return;
    end
    % We need to pass a lot of data to the ImportWizardContents object
    % now.  This will allow us to skip the asynchronous initialization
    % which "should" be performed by the panels that we may be skipping.

    % Gather the data, using the same function calls that the callbacks
    % would have used.
    isClip = strcmp(fileAbsolutePath, '-pastespecial');
    if isClip
        fileAbsolutePath = '';
    end
    ctorFile = java.io.File(fileAbsolutePath);
    [ctorPreviewText, ctorHeaderLines, ctorDelim] = ...
        gatherFilePreviewData(fileAbsolutePath);
    [ctorVariables, ctorSizes, ctorBytes, ctorClasses, ctorColHeaders, ctorRowHeaders] = ...
        getVariableListData;

    % Create the Wizard contents, supplying all of that data.
    iwc = com.mathworks.mde.dataimport.ImportWizardContents(isClip, ctorFile,  ...
        ctorDelim, ctorHeaderLines, ctorPreviewText, ...
        ctorVariables, ctorSizes, ctorBytes, ctorClasses, ...
        ctorColHeaders, ctorRowHeaders, getMatlabVariables(isSynchronous));
end

% Create the Wizard proper.  Store a handle to it if it was launched
% asynchronously, position it nicely, etc.
wiz = com.mathworks.widgets.wizard.WizardFrame(iwc);
if ~isSynchronous
    asynchronousInstance = wiz;
end
wiz.setName('ImportWizard');
wiz.setSize(702, 435);
wiz.setLocation(200, 200);
wiz.setVisible(1);
wizardCallbackProxy = iwc.getImportProxy;
remainPaused = true;

% Register function handles as callbacks to various events in the GUI.
set(wizardCallbackProxy, 'filePreviewEventCallback', @filePreview);
set(wizardCallbackProxy, 'multimediaEventCallback', @multimediaDisplay);
set(wizardCallbackProxy, 'variableListEventCallback', @variableList);
set(wizardCallbackProxy, 'variableListDelimiterEventCallback', @variableListDelimiter);
set(wizardCallbackProxy, 'variablePreviewEventCallback', @variablePreview);
set(wizardCallbackProxy, 'finishEventCallback', @finish);
set(wizardCallbackProxy, 'cancelEventCallback', @cancel);
set(wiz, 'windowClosingCallback', @cancel);

% Notify the proxy that all registrations have been completed, so that
% it can fire any queued events.
wizardCallbackProxy.registrationCompleted;

% If the Wizard was launched asynchronously, wait for notification that it
% has been either completed or dismissed.  Once that happens, return the
% appropriate values.
newData = [];
if isSynchronous
    while getRemainPaused
        drawnow;
        pause(0.1);
    end
    varargout{1} = newData;
end
% If instead the Wizard was launched asynchronously, finish execution of
% the primary function and allow control to return to the caller.  The
% @finish callback will take care of assigning the variables corectly in
% the caller's workspace.

    function filePreview(unused, b)
        fileObject = b.getFile;
        fileAbsolutePath = '';
        if ~isempty(fileObject)
            fileAbsolutePath = char(fileObject.getAbsolutePath);
        end
        [description, headerLines, textDelimiter, handledElsewhere] = ...
            gatherFilePreviewData(fileAbsolutePath);
        if ~handledElsewhere
            reportFilePreview(getSource(b), description, headerLines, textDelimiter);
        else
            pause(0.1);
            cancel;
            wiz.dispose;
            drawnow;
        end
    end

    function [description, headerLines, textDelimiter, handledElsewhere] = gatherFilePreviewData(fileAbsolutePath)
        type = '';
        loadcmd = '';
        handledElsewhere = false;

        if isempty(fileAbsolutePath)
            description = clipboard('paste');
        else
            handledElsewhere = ~isempty (fileAbsolutePath) && hdfh('ishdf', fileAbsolutePath);
            if handledElsewhere
                description = '';
                headerLines = '';
                textDelimiter = '';
                hdftool(fileAbsolutePath);
                return;
            end
            [type, unused, loadcmd, description] = ...
                finfo(fileAbsolutePath);
        end

        description = convertToString(description);
        limit = 1000000;
        limitString = 'one million';
        if (length(description) > limit)
            description = [description(1:limit) 10 10 ...
                'Preview truncated at ' limitString ...
                ' characters.'];
        end

        % Stash the type away for use in the previewType function, so that
        % we don't have to call finfo again.  finfo is a little too
        % expensive to call repeatedly for no good reason.
        ad.type = type;
        ad.absolutePath = fileAbsolutePath;
        ad.loadcmd = loadcmd;

        [datastruct, textDelimiter, headerLines]= runImportdata(fileAbsolutePath, type);
        ad.datastruct = datastruct;
    end

    function [datastruct, OTextDelimiter, OHeaderLines] = runImportdata(fileAbsolutePath, type, delim, hLines)
        datastruct = [];
        OTextDelimiter = ',';
        OHeaderLines = -1;
        ismat = 0;
        if isempty(fileAbsolutePath)
            fileAbsolutePath = '-pastespecial';
        end
        if strcmp(type, 'mat')
            try
                % check if this is a binary mat file
                datastruct = load('-mat', fileAbsolutePath);
                ismat = 1;
                if isempty(fieldnames(datastruct))
                    datastruct = [];
                end
            catch
                % not a binary mat file - try using -ascii, this will
                % nearly allways work cuz importdata should be called
                % use try catch just in case
                try
                    datastruct = load('-ascii', fileAbsolutePath);
                    %ad.FilePreview = fileread(FileName);
                catch
                    %if ad.ShowWarnings
                    %	warning(lasterr)
                    %        end
                    datastruct = [];
                end
            end
        end
        if ~ismat && isempty(datastruct)
            try
                if nargin == 2
                    % try importdata and get text delimiter if there
                    [datastruct, OTextDelimiter, OHeaderLines] = ...
                        importdata(fileAbsolutePath);
                elseif nargin == 3
                    [datastruct, OTextDelimiter, OHeaderLines] = ...
                        importdata(fileAbsolutePath, delim);
                elseif nargin == 4
                    [datastruct, OTextDelimiter, OHeaderLines] = ...
                        importdata(fileAbsolutePath, delim, hLines);
                end
            catch
                % unrecognized file format
                %if ad.ShowWarnings
                %    warning(lasterr)
                %end
                datastruct = [];
            end
        end

        % Error handling code below will be rewritten at a future date.
        if ismat && isempty(datastruct)
            % empty mat file
            % Set preview to
            % 'Nothing to load. MAT-file is empty.'
        elseif isempty(datastruct)
            % can't load file
            if isempty(ad.loadcmd)
                % set preview to
                % 'Don''t know how to import this file.\n\n\tSee HELP
                % FILEFORMATS.'  and a diagnostic describing the actual
                % error.
            else
                % set preview to
                % 'File contains:' and a description of the problem.
            end
        else
            if ~isstruct(datastruct) || length(datastruct) > 1
                [unused,name] = fileparts(fileAbsolutePath);
                s = struct(legalname(name), 1);
                s.(legalname(name)) = datastruct;
                datastruct = s;
            end
        end

        if isnan(OTextDelimiter)
            % If OTextdelimiter is NaN, then we've resorted to IMPORTDATA,
            % but have found that we're NOT trying to import raw text.
            % Therefore, re-initialize the variables so that the rest of 
            % the Wizard knows to act properly.
            OTextDelimiter = '';
            OHeaderLines = -1;
        end
        % If this is from XLSREAD, patch up all of the data to act as if
        % there is only one sheet.
        if length(fileAbsolutePath) > 4 && ...
                strcmpi(fileAbsolutePath(end-3:end), '.xls')
            if isfield(datastruct, 'data') && ...
                  isstruct(datastruct.data)
                fields = fieldnames(datastruct.data);
                datastruct.data = datastruct.data.(fields{1});
            end
            if isfield(datastruct, 'textdata') && ...
                    isstruct(datastruct.textdata)
                fields = fieldnames(datastruct.textdata);
                datastruct.textdata = datastruct.textdata.(fields{1});
            end
            if isfield(datastruct, 'colheaders') && ...
                    isstruct(datastruct.colheaders)
                fields = fieldnames(datastruct.colheaders);
                datastruct.colheaders = datastruct.colheaders.(fields{1});
            end
            if isfield(datastruct, 'rowheaders') && ...
                    isstruct(datastruct.rowheaders)
                fields = fieldnames(datastruct.rowheaders);
                datastruct.rowheaders = datastruct.rowheaders.(fields{1});
            end
        end
    end

    function [variables, sizes, byteses, classes, colHeaders, rowHeaders] = ...
            getVariableListData

        variables = [];
        if isstruct(ad.datastruct)
            variables = fields(ad.datastruct);
        end

        sizes = [];
        if length(variables) > 0
            sizes = cell(size(variables));
            for i = 1:length(variables)
                sizes{i} = getSizeString(ad.datastruct.(variables{i}));
            end
        end

        classes = [];
        if length(variables) > 0
            classes = cell(size(variables));
            for i = 1:length(variables)
                classes{i} = class(ad.datastruct.(variables{i}));
            end
        end

        byteses = [];
        if length(variables) > 0
            for i = 1:length(variables)
                myTemp = ad.datastruct.(variables{i});
                whosData = whos('myTemp');
                byteses = [byteses whosData.bytes];
            end
        end

        colHeaders = [];
        if isfield(ad.datastruct, 'colheaders')
            colHeaders = ad.datastruct.colheaders;
        end

        rowHeaders = [];
        if isfield(ad.datastruct, 'rowheaders')
            rowHeaders = ad.datastruct.rowheaders;
        end
    end

    function variableList(unused, b)
        [variables, sizes, byteses, classes, colHeaders, rowHeaders] = ...
            getVariableListData;
        reportVariableList(getSource(b), previewType, variables, ...
            sizes, byteses, classes, colHeaders, rowHeaders, ...
            getMatlabVariables(isSynchronous));
    end

    function variableListDelimiter(unused, b)
        ad.datastruct = runImportdata(ad.absolutePath, ad.type, ...
            char(getDelimiter(b)), getHeaderLines(b));
        [vars, sizes, byteses, classes, colHeaders, rowHeaders] = ...
            getVariableListData;
        reportVariableListDelimiter(getSource(b), vars, sizes, ...
            byteses, classes, colHeaders, rowHeaders, ...
            getMatlabVariables(isSynchronous));
    end

    function variablePreview(unused, b)
        javaVariableName = getVariableName(b);

        varName = char(javaVariableName);
        fullRefName = '';
        value = [];
        if (strcmp(varName, 'colheaders') || ...
                strcmp(varName, 'rowheaders') || ...
                strcmp(varName, 'data') || ...
                strcmp(varName, 'textdata'))
            fullRefName = ['ad.datastruct.' varName];
            value = ad.datastruct.(varName);
        end
        if isempty(fullRefName)
            ds = ad.datastruct;
            fields = fieldnames(ds);
            index = find(strcmp(varName, fields));
            if ~isempty(index)
                fullRefName = ['ad.datastruct.' varName ];
                value = ad.datastruct.(varName);
            end
        end
        realValue = '';
        if isnumeric(value) && isempty(value)
            realValue = '[ ]';
        end
        imagValue = '';
        if isempty(realValue)
            if numel(size(value)) == 2 && isnumeric(value)
                realValue = real(value);
                if ~isreal(value)
                    imagValue = imag(value);
                else
                    imagValue = [];
                end
            else
                realValue = evalc(['disp(' fullRefName ')']);
                limit = 1000000;
                limitString = 'one million';
                if (length(realValue) > limit)
                    realValue = [realValue(1:limit) 10 10 ...
                        'Preview truncated at ' limitString ...
                        ' characters.'];
                end
            end
        end
        if (isa(realValue, 'char'))
            imagValue = '';
        end
        reportVariablePreview(getSource(b), getOwner(b), javaVariableName, ...
            realValue, imagValue);
    end

    function out = getRemainPaused
        out = remainPaused;
    end

    function setRemainPaused(in)
        remainPaused = in;
    end

    function finish(unused, b)
        origVars = getOriginalNames(b);
        newVars = getNewNames(b);
        newData = [];
        switch(getStyle(b))
            case 2
                for i = 1:length(newVars)
                    newData.(genvarname(char(newVars(i)))) = ad.datastruct.data(:, i);
                end
            case 1
                for i = 1:length(newVars)
                    newData.(genvarname(char(newVars(i)))) = ad.datastruct.data(i, :);
                end
            otherwise
                for i = 1:length(newVars)
                    newData.(genvarname(char(newVars(i)))) = ad.datastruct.(char(origVars(i)));
                end
        end

        if isSynchronous
            setRemainPaused(false);
        else
            asynchronousInstance = [];
            newVariableNames = fields(newData);
            for j = 1:length(newVariableNames)
                assignin('caller', newVariableNames{j}, newData.(newVariableNames{j}));
            end
            if length(newVariableNames) > 0
                dt = javaMethod('getInstance', 'com.mathworks.mde.desk.MLDesktop');
                message = 'Import Wizard created variables in the current workspace.';
                if dt.hasMainFrame
                    dt.setStatusText(message);
                else
                    disp(message);
                end
            end
        end
    end

    function cancel(unused, unused1)
        setRemainPaused(false);
        if ~isSynchronous
            asynchronousInstance = [];
        end
    end

    function type = previewType
        type = 0;
        if ~isempty(ad.type)
            switch getFileTypeFromExt(ad.type)
                case 'movie'
                    % if this is an avi, show a panel for preview
                    type = 1;
                case 'image'
                    % if this is an image, show a panel for preview
                    type = 2;
                case 'sound'
                    % if this is a sound, show a panel for preview
                    type = 3;
            end
        end
    end
end

%
% utility functions
%
function out = convertToString(in)
out = ['Unknown result of class ' class(in) ' encountered.'];
if ischar(in);
    out = in;
else
    if iscell(in)
        out = '';
        for i = 1:length(in)
            out = [out in{i} char(10)];
        end
    end
end
out = strrep(out, char([13 10]), char(10));
out = strrep(out, char(13), char(10));
end

function legalout = legalname(legalin)
if iscell(legalin)
    legalout = cell(size(legalin));
    s = size(legalin);
    for i = 1:s(1)
        for j = 1:s(2)
            legalout{i, j} = legalname(legalin{i, j});
        end
    end
else
    % leading char must be alpha (constraint for structs)
    if ~isalpha(legalin(1))
        legalin = ['A' legalin];
    end
    legalout = legalin;
    if length(legalin) < 2
        return;
    end
    % subsequent chars must be alphanumeric or _
    for i = 2:length(legalout)
        if ~isalpha(legalin(i)) && ~strcmp(legalin(i), '_') && ~isdigit(legalin(i))
            legalout(i) = '_';
        end
    end
end
end

function out = isalpha(in)
out = (all(abs(in) >= abs('a')) & all(abs(in) <= abs('z'))) | ...
    (all(abs(in) >= abs('A')) & all(abs(in) <= abs('Z')));
end

function out = isdigit(in)
out = (all(abs(in) >= abs('0')) & all(abs(in) <= abs('9')));
end

function result = getFileTypeFromExt(inext)
if strcmp(inext, 'avi')
    result = 'movie';
    % finfo returns 'im' for files which are known image types (regardles of file ext)
elseif strcmp(inext, 'im')
    result = 'image';
elseif (strcmp(inext, 'wav') || ...
        strcmp(inext, 'au') || ...
        strcmp(inext, 'snd'))
    result = 'sound';
else
    result = '';
end
end

function out = getSizeString(in)
s = builtin('size', in);
switch(length(s))
    case 1
        out = num2str(s(1));
    case 2
        out = [num2str(s(1)) 'x' num2str(s(2))];
    case 3
        out = [num2str(s(1)) 'x' num2str(s(2)) 'x' num2str(s(3))];
    otherwise
        out = [num2str(length(s)) '-D'];
end
end

function rerouted = useAlternateImportTool(fn)
rerouted = false;
if ~isempty (fn) && hdfh('ishdf', fn)
    rerouted = true;
    hdftool(fn);
end
end

function existingVarNames = getMatlabVariables(synchronous)
if (~synchronous)
    existingVarNames = evalin('base', 'who');
else
    existingVarNames = {};
end
if (isempty(existingVarNames))
    existingVarNames = {''};
end
end

function multimediaDisplay(unused, in)
import com.mathworks.mde.dataimport.MultimediaEvent;
file = char(getAbsolutePath(getFile(in)));
medium = getMedium(in);
switch (medium)
    case MultimediaEvent.MEDIUM_IMAGE
        imageview(file);
    case MultimediaEvent.MEDIUM_MOVIE
        movieview(file);
    case MultimediaEvent.MEDIUM_SOUND
        soundview(file);
end
end