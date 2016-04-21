function helpview(path, varargin)
%HELPVIEW Displays an HTML file or collection in a platform-dependent
%help viewer.
%
%SYNTAX:
%
%  helpview (coll_path)
%  helpview (coll_path, win_type)
%  helpview (topic_path)
%  helpview (topic_path, win_type)
%  helpview (topic_path, win_type, parent)
%  helpview (map_path, topic_id)
%  helpview (map_path, topic_id, win_type)
%  helpview (map_path, topic_id, win_type, parent)
%
%
%ARGUMENTS:
%
%  coll_path
%    Path of a collection of html files. The last
%    name in the path is the name of the collection.
%
%  topic_path
%    Path of an html file. The path must end in .htm(l) or
%    .htm(l) and an HTML anchor reference, for example,
%
%       /v5/help/helpview.html#topicpath
%       d:/v5/help/helpview.html#topicpath
%
%  map_path
%    Path of a map file (see below) that maps
%    topic ids to the paths of topic files. The path must
%    end in the extension .map, for example,
%
%      d:/v5/help/ml_graph.map
%
%  topic_id
%    An arbitrary string that identifies a topic. HELPVIEW uses
%    the map file specified by path to map topic_id to
%    the path of the HTML file that documents the topic.
%
%  win_type
%    Type of window in which to display the help content.
%    Specify "CSHelpWindow" to use the context-sensitive help viewer.
%    Otherwise, the main "Help" window is used.
%
%  parent
%    Handle to a figure window.  Used by the "CSHelpWindow" win_type
%    to determine the parent of the help dialog.  This argument is ignored
%    if the win_type is not CSHelpWindow.
%
%TOPIC MAP FILE
%
%  The map file is an ascii text file that is
%  essentially a two-column list.  Each line is
%  of the form:
%
%    TOPIC_ID PATHNAME
%
%  The TOPIC_ID is an arbitrary string identifying
%  a "chunk" of online help contained in an HTML
%  file.  Typically, the technical writer and the
%  developer will agree what these identifiers should be,
%  and the developer will use them in calls to helpview.
%
%  PATHNAME is a coll_path or topic_path relative to
%  the directory containing the map file.
%
%  For example, suppose the following map file
%
%    % ml_graph.map
%    COLORPICKDLG  ml_graph/ch02aa31.html
%    PRINTDLG      ml_graph/ch02aa35.html
%    LINESTYLEDLG  ml_graph/ch02aa31.html#ModLines
%
%  is in the directory DOCROOT\techdoc, where DOCROOT
%  is the root directory of the MATLAB help system. Then,
%  the following call
%
%    helpview([docroot '/techdoc/ml_graph.map'], 'PRINTDLG');
%
%  is equivalent to
%
%    helpview([docroot '/techdoc/ml_graph/ch02aa35.html']);

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.12 $

wintype = '';
topic_id = '';
parent = '';

if nargin < 1
    error('MATLAB:helpview:NotEnoughInputArgs', 'Not enough input arguments.  For MATLAB help, type ''help'' or ''helpbrowser''.');
end

if ~ ischar(path) || strcmp(path, '')
    error('MATLAB:helpview:InvalidFirstArg', 'First argument must be a non-null path');
end

% Ensure that path uses correct separator
% for platform.
help_path = normalize_path(path);


% Does path specify a topic map file?
e = length(help_path);
b = e - 3;
if (b > 0) && strcmp(help_path(b:e), '.map')
    % First arg is path of a collection or a topic.
    % Get the id of the topic to be mapped.
    if (length(varargin) < 1)
        error('MATLAB:helpview:TopicIdRequired', 'Topic id required to find topic path from map file.');
    else
        topic_id = varargin{1};
    end
    
    % If help_path starts with /mapfiles and docroot is empty, assume doc is
    % missing and show the standard error page in the help browser.
    if ((usejava('mwt') == 1) && ((strncmp(help_path, [filesep 'mapfiles'], 9)) || (strncmp(help_path, 'mapfiles', 8))) && (isempty(docroot)))
        html_file = fullfile(matlabroot, 'toolbox', 'local', 'helperr.html');
        web(html_file, '-helpbrowser');
        return;
    end
    
    % Make sure the mapfile exists.
    if ~ (exist(help_path) == 2 || exist(help_path) == 7)
        error('MATLAB:helpview:TopicPathDoesNotExist', 'Specified path for topic collection does not exist:\n%s',help_path)
    end

    % Look up topic or collection path in the map file.
    help_path = map_topic(help_path, topic_id);
    
    % Get windows type argument, if specified.
    if (length(varargin) >= 2)
        wintype = varargin{2};
        if ~ ischar(wintype)
            error('MATLAB:helpview:InvalidThirdParameter', 'Third parameter must specify a window type.');
        end
    end
    
    % Get parent argument, if specified.
    if (length(varargin) == 3)
        parent = varargin{3};
    end

else % First argument is a fully qualified path.
    % Is there also a wintype argument?
    if (length(varargin) >= 1)
        wintype = varargin{1};
        if ~ ischar(wintype)
            error('MATLAB:helpview:InvalidSecondParameter', 'Second parameter must specify a window type.');
        end
    end

    % Get parent argument, if specified.
    if (length(varargin) == 2)
        parent = varargin{2};
    end
end

% Strip off HTML anchor if present.
[help_path anchor] = parse_anchored_path(help_path);

% Now we have a normalized path and an optional wintype argument.
% The path points to a collection, a file in a collection, or
% a file. The collection is a directory of files.

% Parse the path.
[coll_dir topic_file ext unused] = fileparts(help_path);

% Does help_path point to a topic file?
if ext
    if ~ findstr(ext, 'htm')
        error('MATLAB:helpview:InvalidTopicFilename', 'Name of topic file must end in .htm or html.')
    end
    topic_file = [topic_file ext];
    title_file = '';
else % Points to a directory, i.e., a collection.
    coll_dir = help_path;
    title_file = [topic_file '.html'];
    topic_file = '';
    % Does collection's title topic exist?
    if (exist([coll_dir filesep title_file]) ~= 2)
        error('MATLAB:helpview:NoTopicFound', 'Cannot find title topic in collection directory.');
    end
end

% Display the file
%
if isempty(topic_file)
    topic_file = title_file;
end
html_file = [coll_dir filesep topic_file anchor];


% Call the help viewer, unless Desktop is not enabled.
%
if (usejava('mwt') == 1)
    % The ICE browser fails to correctly interpret relative links using ".."
    % in certain URLs that mix slashes and backslashes.  As a workaround,
    % replace backslashes with slashes (following the "help" node).
    helpnodeidx = findstr(html_file, '\help\');
    if (~isempty(helpnodeidx))
        for i = (helpnodeidx(1)+1) : length(html_file)
            if (html_file(i) == '\')
                html_file(i) = '/';
            end
        end
    end
    % Use the appropriate viewer, based on window type.
    if strcmp(wintype,'CSHelpWindow')
        drawnow
        if isempty(parent)
            if strcmp(topic_id,'')
                com.mathworks.mlservices.MLHelpServices.cshDisplayFile(normalize_path(path));
            else
                com.mathworks.mlservices.MLHelpServices.cshDisplayTopic(normalize_path(path), topic_id);
            end
        else
            if isa(handle(parent), 'figure')
                % We actually want the parent of the figure...
                figpeer = get(parent,'javaframe');
            else
                figpeer = parent;
            end
            
            if strcmp(topic_id,'')
                com.mathworks.mlservices.MLHelpServices.cshDisplayFile(figpeer, normalize_path(path));
            else
                com.mathworks.mlservices.MLHelpServices.cshDisplayTopic(figpeer, normalize_path(path), topic_id);
            end
        end            
    else
        % Otherwise, use the main Help window.
        web(html_file, '-helpbrowser');
    end
else
    % use web browser to display the file
    display_file([coll_dir filesep topic_file anchor]);
end


function display_file(html_file)
% Display html_file in the default browser for
% the user's system.

% Load the correct HTML file into the browser.
stat = web(html_file);
if (stat==2)
    error(sprintf(['Could not launch Web browser. Please make sure that\n' ...
        'you have enough free memory to launch the browser.']));
elseif (stat)
     error(sprintf(['Could not load HTML file into Web browser. Please make sure that\n' ...
        'you have a Web browser properly installed on your system.']));
end


function topic_path = map_topic(map_path, topic_id)
% Look up the path of a topic in a topic map file.

rel_path = [];

if (exist(map_path) ~= 2)
    error('MATLAB:helpview:TopicMapInvalid', 'Specified path for topic map is invalid.\n%s',map_path)
end

[tid, tpath] = textread(map_path, '%s %s','commentstyle','matlab');

n = length(tid);
for i = 1:n
    if (strcmp(tid(i), topic_id))
        rel_path = tpath{i};
        break;
    end
end

map_path = fileparts(map_path);
topic_path = normalize_path([map_path filesep rel_path]);



function normal_path = normalize_path(path)
% Ensures that path uses the correct separator
% for the current platform.
%
if strcmp(computer, 'PCWIN')
    normal_path = strrep(path, '/', '\');
else
    normal_path = strrep(path, '\', '/');
end



function [path, anchor] = parse_anchored_path(apath)
% Parses a path that references an HTML anchor.
n = findstr(apath, '#');
if n > 3
    path = apath(1:(n-1));
    anchor = apath(n:length(apath));
else
    path = apath;
    anchor = '';
end



% End of helpview.m







