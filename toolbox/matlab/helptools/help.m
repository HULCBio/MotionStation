function [varargout] = help(varargin)
%  HELP Display help text in Command Window.
%     HELP, by itself, lists all primary help topics. Each primary topic
%     corresponds to a directory name on the MATLABPATH.
%
%     HELP / lists a description of all operators and special characters.
%
%     HELP FUN displays a description of and syntax for the function FUN.
%     When FUN is in multiple directories on the MATLAB path, HELP displays
%     information about the first FUN found on the path and lists
%     PATHNAME/FUN for other (overloaded) FUNs.
%
%     HELP PATHNAME/FUN displays help for the function FUN in the PATHNAME
%     directory. Use this syntax to get help for overloaded functions.
%
%     HELP DIR displays a brief description of each function in the MATLAB
%     directory DIR. DIR can be a relative partial pathname (see HELP
%     PARTIALPATH). When there is also a function called DIR, help for both
%     the directory and the function are provided.
%
%     HELP CLASSNAME.METHODNAME displays help for the method METHODNAME of
%     the fully qualified class CLASSNAME. To determine CLASSNAME for
%     METHODNAME, use CLASS(OBJ), where METHODNAME is of the same class as
%     the object OBJ.
%
%     HELP CLASSNAME displays help for the fully qualified class CLASSNAME.
%
%     T = HELP('TOPIC') returns the help text for TOPIC as a string, with
%     each line separated by /n. TOPIC is any allowable argument for HELP.
%
%     REMARKS:
%     1. Use MORE ON before running HELP to pause HELP output after a
%     screenful of text displays.
%     2. In the help syntax, function names are capitalized to make them
%     stand out. In practice, always type function names in lowercase. For
%     Java functions that are shown with mixed case (for example,
%     javaObject) type the mixed case as shown.
%     3. Use DOC FUN to display help about the function in the Help
%     browser, which might provide additional information, such as graphics
%     and examples.
%     4. Use DOC HELP for information about creating help for your own
%     M-files.
%     5. Use HELPBROWSER to access online documentation in the Help
%     browser. Use the Help browser Index or Search tabs to find more
%     information about TOPIC or other terms.
%
%     EXAMPLES:
%     help close - displays help for the CLOSE function.
%     help database/close - displays help for the CLOSE function in the
%     Database Toolbox.
%     help database - lists all functions in the Database Toolbox and 
%     displays help for the DATABASE function.
%     help general - lists all functions in the directory MATLAB/GENERAL.
%     help embedded.fi - displays help for the EMBEDDED.FI class in the
%     Fixed-Point Toolbox.
%     help embedded.fi.lsb displays help for the LSB method of the
%     EMBEDDED.FI class in the Fixed-Point Toolbox.
%     t = help('close') - gets help for the function CLOSE and stores it as
%     a string in t.
%
%     See also DOC, DOCSEARCH, HELPBROWSER, HELPWIN, LOOKFOR, MATLABPATH,
%     MORE, PARTIALPATH, WHICH, WHOS, CLASS.


%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.11 $  $Date: 2004/04/15 00:01:28 $
%   Built-in function.

if nargin==0
    topic = '';
else
    topic = varargin{1};
end

if nargout == 0
    if ~usejava('jvm')
        helpStr = getHelpText(varargin{:});
        displayHelpText(helpStr);
        % If there is no text, that means there's no help.  We need to call the
        % builtin so it actually prints out the proper message.
        if isempty(helpStr)
            builtin('helpfunc', varargin{:});
        end
    else
        % Get the help text
        helpStr = getHelpText(varargin{:});

        % If there is no text, that means there's no help.  We need to call the
        % builtin so it actually prints out the proper message.
        if isempty(helpStr)
            builtin('helpfunc', varargin{:});

            if usejava('desktop')
                disp(sprintf('Use the Help browser Search tab to <a href="matlab:docsearch %s">search the documentation</a>, or\ntype "<a href="matlab:help help">help help</a>" for help command options, such as help for methods.\n', topic));
            else
                disp(sprintf('Use the Help browser Search tab to search the documentation, or\ntype "help help" for help command options, such as help for methods.\n'));
            end
            return;
        end

        % display the help.  We want hyperlinks if the desktop is on, since
        % the command window knows how to display them.
        displayHelp(helpStr, topic, usejava('desktop'));
    end
else
    helpStr = getHelpText(varargin{:});
    moreInfo = '';
    if usejava('jvm') && ~isempty(refPageUrl(topic))
        moreInfo = sprintf('\n    Reference page in Help browser\n    doc %s\n', topic);
    end
    [varargout{1:nargout}] = [helpStr moreInfo];
end

function displayHelp(helpStr, topic, wantHyperlinks)

% Strip off the extension if one exists.
[pathname,topic,ext] = fileparts(topic);
if ~isempty(pathname)
    % only tack on the pathname if it's necessary.
    [unused classname unused] = fileparts(pathname);
    if ~isempty(ismember(methods(classname), topic))
        topic = [pathname '/' topic];
    end
end

if ~isempty(refPageUrl(topic))
    % Show the reference page if it exists.  If the topic contains at least
    % one slash, it means they're looking under a product, and since the
    % doc command only supports one level, we'll use the string before the
    % first slash as the product directory, and the string after the last
    % slash as the topic page.  The rest will be ignored.
    k = [find(topic == '/' | topic == '\')];
    if ~isempty(k)
        topic_dir = topic(1:k-1); % get the topic directory
        topic_page = topic(k(end)+1:end); % get the topic page
        topic = [topic_dir '/' topic_page];
    end
    
    if wantHyperlinks
        moreInfo = sprintf('\n    Reference page in Help browser\n       <a href="matlab:doc %s">doc %s</a>\n', topic, topic);
    else
        moreInfo = sprintf('\n    Reference page in Help browser\n       doc %s\n', topic);
    end
    helpStr = [helpStr moreInfo];
end

if wantHyperlinks
    % Make "see also", "overloaded methods", etc. hyperlinks.
    helpStr = makehelphyper('help', pathname, topic, helpStr);
end

displayHelpText(helpStr);
disp(sprintf('\n'));

function displayHelpText(helpStr)

if isequal(get(0,'More'),'on')
    try
        % Workaround for the fact that more doesn't work well with disp...
        % Get the newlines
        a = regexp(helpStr, '\n');
        if ~isempty(a)
            substart = 1;
            for n=1:length(a)
                subend = a(n)-1;
                if subend<substart
                    % This is a blank line
                    disp(' ');
                else
                    b = helpStr(substart:subend);
                    disp(b);
                end
                substart=subend+2;
            end
            % display the last line (if after the last carriage return)
            b = helpStr(subend+2:length(helpStr));
            if (~isempty(b))
                disp(b);
            end
        else
            disp(helpStr);
        end
    catch
    end
else
    disp(helpStr);
end


function helpText = getHelpText(varargin)

helpText = '';
dotind = [];
if nargin > 0
    topic = varargin{1};
    % Check to see if it's a request for classnames or methods.
    dotind = find(topic == '.');
    if ~isempty(dotind)
        slashind = find(topic == '/');
        packageinfo = what(['@' topic(1:dotind(1)-1)]);
        if ~isempty(packageinfo)
            packagename = packageinfo(1).path;
            atIdx = find(packagename=='@');
            pkh = findpackage(packagename(atIdx(end)+1:end));
            if ~isempty(pkh)
                if strcmp(pkh.Documented, 'on')
                    if length(dotind) > 1
                        classname = topic(dotind(1)+1:dotind(2)-1);
                        classname = localFindDefiningClass(pkh, classname, topic(dotind(2)+1:end));
                        pathname = fullfile(packagename, ['@' classname]);
                        pathname = fullfile(pathname, [topic(dotind(2)+1:end) '.m']);
                    elseif length(slashind) == 1
                        classname = topic(dotind(1)+1:slashind(1)-1);
                        classname = localFindDefiningClass(pkh, classname, topic(slashind(1)+1:end));
                        pathname = fullfile(packagename, ['@' classname]);
                        pathname = fullfile(pathname, [topic(slashind(1)+1:end) '.m']);
                    else
                        classname = topic(dotind(end)+1:end);
                        pathname = fullfile(packagename, ['@' classname], [classname '.m']);
                    end
                    varargin{1} = pathname;
                    helpText = builtin('helpfunc', varargin{:});
                    return;
                end
            else
                % this must be an oops class.  use '/' as the separator so 
                % the builtin help function can find it.
                topic(dotind) = '/';
                varargin{1} = topic;
                helpText = builtin('helpfunc', varargin{:});
                return;
            end
        end
    end
end

if isempty(helpText)
    % Call helpfunc in the caller's workspace.
    helpText = builtin('evalin', 'caller', 'builtin(''helpfunc'', varargin{:})');
end

% Uncomment when this is fast enough...
% if isempty(helpText) && isempty(dotind)
%     % Look for help in methods.
%     helpText = getMethodHelp(varargin{:});
% end


function methodHelp = getMethodHelp(varargin)

methodHelp = '';
if nargin > 0
    topic = varargin{1};
    currentpath=path;
    pathlist=eval(['{''' strrep(currentpath,pathsep,''';''') '''}']);

    allpathinfo = what(pathlist{:});
    overloaded_methods_exist = false;

    for i=1:length(allpathinfo)
        for j=1:length(allpathinfo(i).classes)
            filename = [allpathinfo(i).path filesep '@' allpathinfo(i).classes{j}];
            lsoutput = ls([filename filesep '@*']);
            if ~isempty(lsoutput)
                a = strcat({[filename filesep]}, lsoutput);
                for k=1:length(a)
                    filename = [a{k} filesep topic '.m'];
                    if exist(filename) == 2
                        atind = find(filename == '@');
                        slashind = find(filename == filesep);
                        packagename = filename(atind(1)+1:atind(2)-2);
                        pkh = findpackage(packagename);
                        if ~isempty(pkh) && strcmp(pkh.Documented, 'on')
                            classname = filename(atind(2)+1:slashind(end)-1);
                            methodname = filename(slashind(end)+1:end-2);
                            fullMethodname = sprintf('%s.%s.%s', packagename, classname, methodname);
                            if ~isempty(methodHelp)
                                if ~overloaded_methods_exist
                                    methodHelp = sprintf('%s\n    Overloaded methods (methods with the same name in other classes)\n', methodHelp);
                                end
                                methodHelp = sprintf('%s       help %s\n',methodHelp,fullMethodname);
                                overloaded_methods_exist = true;
                            else
                                helpStr = [methodHelp builtin('helpfunc', filename)];
                                if ~isempty(helpStr)
                                    banner = sprintf('\n --- help for %s ---\n\n', fullMethodname);
                                    methodHelp = [methodHelp banner helpStr];
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end


function url = refPageUrl(topic)

url = '';
if usejava('jvm')
    itemLoc = which(topic);
    if (strcmp(itemLoc,'built-in'))
        itemLoc = which([topic '.m']);
    end
    % Isolate the function name in case a full pathname was passed in
    [unused topic unused unused] = fileparts(topic);
    % Is this topic a function?
    itemIsFunction = length(itemLoc);

    if itemIsFunction
        url = com.mathworks.mlwidgets.help.HelpInfo.getReferencePageUrl([topic '.html']);
    end
end

function classname = localFindDefiningClass(pkh, classname, methodname)
ch = findclass(pkh, classname);
while ~isempty(ch)
    m = ch(1).methods;
    if ~isempty(m) && ~isempty(m.find('Name', methodname))
        classname = ch.Name;
        break;
    end
    ch = ch.Superclasses;
end
