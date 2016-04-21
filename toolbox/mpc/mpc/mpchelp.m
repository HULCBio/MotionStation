function varargout = mpchelp(varargin)
%MPCHELP Display Model Predictive Control Toolbox help.
%
%    MPCHELP provides a complete listing of Model Predictive Control Toolbox
%    functions with a brief description of each function.
%
%    MPCHELP NAME provides on-line help for the function or property,
%    NAME.   
%
%    OUT = MPCHELP('NAME') returns the help text in string, OUT.
%
%    MPCHELP(OBJ) displays a complete listing of functions and properties
%    for the MPC object, OBJ, along with the on-line help
%    for the object's constructor.
%
%    MPCHELP(OBJ, 'NAME') displays the help for function or property, NAME,
%    for the MPC object, OBJ.
%
%    OUT = MPCHELP(OBJ, 'NAME') returns the help text in string, OUT.
%
%    When displaying property help, the names in the See also section which
%    contain all upper case letters are function names.  The names which
%    contain a mixture of upper and lower case letters are property names.
%
%    When displaying function help, the see also section contains only 
%    function names.
%
%    Examples:
%       mpchelp('getoutdist')
%       mpchelp getoutdist
%       mpc1 = mpc(tf(1,[1 0]),0.1);
%       mpchelp(mpc1)
% 
%    See also MPCPROPS.
%

%    Author: A. Bemporad (based on DAQHELP.M)
%    Copyright 1998-2004 The MathWorks, Inc.
%    $Revision: 1.1.6.3 $  $Date: 2004/04/16 22:09:24 $

ArgChkMsg = nargchk(0,2,nargin);
if ~isempty(ArgChkMsg)
    error('mpc:mpchelp:argcheck', ArgChkMsg);
end
if nargout > 1,
   error('mpc:mpchelp:argcheck', 'Too many output arguments.')
end

% Find the directory where the toolbox is installed.
mpcroot = which('mpcprops.m', '-all');
mpcroot = fileparts(mpcroot{1});

switch nargin
case 0
    % No input parameters, just give general help from Contents.m
    if nargout==1,
        varargout{1} = help(mpcroot);
    else
        help(mpcroot);
    end
   return;
case 1
   % 1 input parameter.  Could be an MPC object, could be a name
   % Initialize variables.
   str = varargin{1};
   fullpath = {''};
   isdir = [];
   parent = '';
   device=[];
   
   % Check first argument to see if it is an MPC object. 
   if ~ischar(str)
      if isa(str, 'mpc')
         path = '';
         name = class(str);
         ext = '';
         % Yes -- it's an MPC object.  It corresponds to the Contents.m
         % in a subdirectory
         isdir = 1;
      else
         error('mpc:mpchelp:argcheck', 'The first input argument must be a string or an MPC object.');
      end
   else
      % Determine if user specified an extension and/or a path.
      [path,name,ext] = fileparts(str);
   end
   
   % Determine if the name specified is a directory.
   if isempty(isdir)
      isdir = localIsDir(lower(name),mpcroot);
      % isdir will be nonzero if it is a directory
   end
   
   % If the name is a directory, fullpath contains the full path to the
   % contents help and constructor help (if it is not mpc).
   % Ex. "mpchelp mpc"
   if isdir && isempty(ext)
      if strcmp(lower(name), 'mpc')
         fullpath = {mpcroot};
      elseif strcmp(name(1), '@')
         fullpath = {[mpcroot filesep name]};
      else
         fullpath = {[mpcroot filesep name]};
         % !!! Do we do this because there might be two different
         % possibilities?  One with the @, and one without?
         fullpath = {fullpath{:}, [mpcroot filesep '@' name filesep name '.m']};
      end
   end
   
   % Determine the full path, if one was not provided.
   if isempty(fullpath{1})
      % Get all the locations of the file.
      temppath = which(name, '-all');
      % Determine the parent directory - path:mpc.
      if ~isempty(path)
         parent = localFindParent(path);
      end
      % Loop through temppath and find the requested path.
      for i = 1:length(temppath)
%          % Ex. mpchelp analoginput/getsample.
%          if ~isempty(path) && any(findstr([mpcroot '\@mpc\' path], temppath{i}))
%             fullpath = temppath(i);
%             break;
%          elseif any(findstr([mpcroot '\@mpc\' name], temppath{i}))
%             fullpath = temppath(i);
%             break;
%          end
         
         % Ex. mpchelp mpc/set
         if ~isempty(parent) && any(findstr([mpcroot '/@mpc\' parent], temppath{i}))
            fullpath = temppath(i);
            break;
         elseif any(findstr([mpcroot '\@mpc\' name], temppath{i}))
            fullpath = temppath(i);
            break;
         end
      end         
   end %isempty(fullpath{1})
case 2
   % Error if the first input is not a mpcdevice or mpcchild object.
   if ~isa(varargin{1}, 'mpc')
      % If the input is not a string, error with the class name.
      if ~ischar(varargin{1})
         varargin{1} = class(varargin{1});
      end
      if ~ischar(varargin{2})
         varargin{2} = class(varargin{2});
      end
      error('mpc:mpchelp:invalidproperty', 'Invalid MPC function or property: ''%s'' ''%s''.', varargin{1}, varargin{2} );
   end
   
   if ~ischar(varargin{2})
      error('mpc:mpchelp:argcheck', 'The second input argument must be a string.');
   end

   
   % Initialize variables.
   name = varargin{2};
   path = class(varargin{1});  
   device = varargin{1};
   driver = path;
       
   % Find the fullpath.  First assume the name is not inherited.  If that
   % fails, assume the name is inherited.
   % Ex. "mpchelp(mpc1, 'getoutdist')"
   fullpath = {which([path '\' name])};
   if isempty(fullpath{1})
      parent = localFindParent(path);
      fullpath = {which([parent '\' name])};
   end
   
   % Determine if function is in the mpc directory.
   % Ex. "mpchelp(mpc1, 'getindist')"
   if isempty(fullpath{1})
      fullpath = {which([mpcroot filesep name])};
   end
end

% If path is empty either NAME is a property or NAME is invalid.
if isempty(fullpath{1}) && (nargin == 2 || (nargin == 1 && isempty(path)))
    % Ex. "mpchelp set", "mpchelp(mpc1, 'set')"
    if isempty(path)
         error('mpc:mpchelp:invalidproperty', 'Invalid MPC function or property: ''%s''.', name);
    end
    if nargout == 0
        fprintf('\n');
        fprintf(out);
        fprintf('\n');
    else
        varargout{1} = out;
    end
    return;
elseif isempty(fullpath{1}) && nargin == 1
    % Ex. "mpchelp set"
   error('mpc:mpchelp:invalidproperty', 'Invalid MPC function or property: ''%s''.',  varargin{1});
else
   % By this point, we've either got a path to the directory that we're going
   % to use the content.m of, or the .m file that we're going to use.

   % If the name is mpcmex, the fullpath may be to the .dll.  Therefore
   % need to replace the .dll with a .m so the correct help is called.
%    if strcmp(name, 'mpcmex')
%       fullpath = strrep(fullpath, '.dll', '.m');
%    end
   % Call help on each fullpath string.
   outTemp = [];
   for i = 1:length(fullpath)
      if nargout == 0
         out = evalc('help(fullpath{i})');
         fprintf('\n');
         fprintf(out);
         fprintf('\n');
      else
         out = help(fullpath{i});
         outTemp = [outTemp out];
      end
   end
   if nargout == 1
      varargout{1} = outTemp;
   end
end

% ********************************************************************
% Determine if the name specified is a directory.
function out = localIsDir(name,mpcroot)

% If the name is mpc return 1.
if strcmp(name, 'mpc')
   out = 1;
   return;
end

% Add the @ to the name if it isn't included.
if ~strcmp(name(1), '@')
   name = ['@' name];
end

% Get all the directory names in the Data Acquisition toolbox.
d = dir(mpcroot);
names = {d.name};
dirnames = {names{find([d.isdir])}};

% Determine if name is one of the directories in the toolbox.
out = find(strcmp(name, dirnames));
if isempty(out)
   out = 0;
end;

% ********************************************************************
% Determine the parent of the pathname specified.
function out = localFindParent(name)

% Initialize variables.
out = '';

% If the name is mpc return 1.
if strcmp(name, 'mpc') || isempty(name)
   out = '';
   return;
end

% Add the @ to the name if it isn't included.
if strcmp(name(1), '@')
   name = name(2:end);
end

% if any(strcmp(lower(name), {'analoginput', 'analogoutput', 'digitalio'}))
%    out = 'mpcdevice';
%    return;
% elseif any(strcmp(lower(name), {'aichannel', 'aochannel', 'dioline'}))
%    out = 'mpcchild';
% end
