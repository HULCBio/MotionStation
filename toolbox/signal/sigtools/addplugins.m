function varargout = addplugins(hObj, varargin)
%ADDPLUGINS Add plugins to the siggui object
%   ADDPLUGINS(H, FILENAME) Add plug-ins to the object associated with H.
%   Find the plug-in information by searching for FILENAME which must
%   contain the structure STRUCTNAME.  The name of the object H is used to
%   determine which plug-in to install from the plug-in information
%
%   ADDPLUGINS(H, FILENAME, PLUGINNAME) uses the string PLUGINNAME to
%   determine which plug-in to install instead of the name of the object.
%
%   ADDPLUGINS(H) Add plugins to the object associated with H. ADDPLUGINS
%   will search for plugins using 'fdaregister' as the FILENAME.

%   ADDPLUGINS(H, pluginCell) Add the plugins stored in pluginCell to the
%   object associated with H.  pluginCell is a cell of structures that
%   contain the following fields, plugin (a function handle), name (an
%   identifying string) and version (the version number).  It cannot be a
%   vector of structures because the structure might also contain
%   information about which platforms are supported.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.6.4.4 $  $Date: 2004/04/13 00:31:22 $

[pluginCell, classname, msg] = parse_inputs(varargin{:});
error(msg);

% Find the name of the class
if isempty(classname),
    classname = get(hObj.classhandle,'Name');
end

outputs = {};
inputs  = {};
if isempty(hObj),
    inputs = {};
else
    inputs = {hObj};
end

for i = 1:length(pluginCell)

    % Loop over each plugin and get it's structure
    pluginStruct = pluginCell{i};

    % Each plugin can contain multiple plugin functions
    for j = 1:length(pluginStruct.plugin)

        % We need to try/catch in case the license is already checked out.
        try
            % Execute the plugin function
            fcnStruct = feval(pluginStruct.plugin{j});

            % The plugin function returns a structure of function handles
            % See if the classname is one of the fields.
            if isfield(fcnStruct, classname),

                % FEVAL the function which matches the class name
                if nargout
                    outputs{end+1} = feval(fcnStruct.(classname), inputs{:});
                else
                    feval(fcnStruct.(classname), inputs{:});
                end
            end
        catch
            % NO OP.  Can't install the plug-in.
        end
    end
end

if nargout,
    varargout = {outputs};
end

% ------------------------------------------------------------------
function [pluginCell, classname, msg] = parse_inputs(varargin)

msg        = nargchk(0, 3, nargin);
filename   = '';
pluginCell = {};
classname  = '';

if ~isempty(msg), return; end

for i = 1:length(varargin)

    % Loop over the inputs to find the pluginCell
    if iscell(varargin{i}),
        pluginCell = varargin{i};
    elseif ischar(varargin{i})

        % Get the filename and the structure name
        if isempty(filename),
            filename   = varargin{i};
        elseif isempty(classname),
            classname  = varargin{i};
        end
    end
end

% If we do not find a pluginCell, use findplugins
if isempty(pluginCell),
    if isempty(filename),
        filename = 'fdaregister';
    end

    % Search for the plug-ins
    pluginCell = findplugins(filename);
end

% If no plug-in were found error.
% if isempty(pluginCell),
%     msg = ['Plug-ins not found using ''' filename ''' and ''' structname '''.'];
% end

% [EOF]
