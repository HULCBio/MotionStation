function x = vrinstall(action, component, bxtype)
%VRINSTALL(ACTION, COMPONENT) Install or check components of
%   the Virtual Reality Toolbox.
%
%   ACTION can be one of the following:
%
%     '-interactive'  Installs components interactively.
%     '-selftest'     Tests the integrity of the Virtual Reality Toolbox itself.
%     '-check'        Checks what is installed.
%     '-install'      Installs an optional component.
%     '-uninstall'    Uninstalls an optional component.
%
%   When ACTION is '-interactive', the components are checked and if some
%   are not yet installed, the user is presented with a choice to install them.
%
%   When ACTION is '-check', the COMPONENT parameter specifies which component
%   should be queried. If an output arguments is given, VRINSTALL returns 1 if
%   the component is installed, and 0 if it isn't.
%
%   When ACTION is '-install' or '-uninstall',  the COMPONENT parameter specifies
%   which component should be installed.
%
%   Valid components are:
%
%     'viewer'      Default VRML viewer (currently Blaxxun Contact 4.4.1.0)
%     'editor'      Default VRML editor (currently V-Realm Builder 2.0)
%
%   Not all components can be uninstalled from MATLAB. In some cases,
%   the component is a standalone application and must be uninstalled
%   using the standard procedure of the operating system.
%   Currently this applies to the VRML viewer.

%   Copyright 1998-2004 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.8.4.1 $ $Date: 2004/03/02 03:08:25 $ $Author: batserve $


% do interactive test if no parameters given
if nargin == 0
  if nargout == 0
    action = '-interactive';
  else
    action = '-check';
  end
end

% this paranoia self test is done always
vrroot = fullfile(matlabroot, 'toolbox', 'vr');
if ~exist(fullfile(matlabroot, 'java', 'jar', 'toolbox', 'vr.jar'), 'file')
  error('VR:badinstallation', 'Virtual Reality Toolbox is not correctly installed (Java classes not found).');
elseif ~exist(vrroot, 'dir')
  error('VR:badinstallation', 'Virtual Reality Toolbox is not correctly installed (toolbox directory not found).');
elseif ~exist(fullfile(vrroot, 'vrdemos'), 'dir')
  error('VR:badinstallation', 'Virtual Reality Toolbox is not correctly installed (demos not found).');
elseif ispc && ~exist(fullfile(vrroot, 'blaxxun'), 'dir')
  error('VR:badinstallation', 'Virtual Reality Toolbox is not correctly installed (VRML viewer installer not found).');
elseif ispc && ~exist(fullfile(vrroot, 'vrealm'), 'dir')
  error('VR:badinstallation', 'Virtual Reality Toolbox is not correctly installed (VRML editor not found).');
end

% do the individual actions
switch lower(action)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% SELFTEST
  case '-selftest'
    if nargout>0
      x = true;    % do nothing, selftest is already done
    else
      fprintf('Virtual Reality Toolbox installation self-test has passed.\n');
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% INTERACTIVE
  case  '-interactive'
  if nargout>0
    error('VR:invalidoutarg', 'Too many output arguments.');
  end
  if ~vrinstall('-check', 'viewer')
    inp = input('VRML viewer is not installed. Install it? (y/n) ', 's');
    if strcmpi(inp, 'y')
      vrinstall('-install', 'viewer');
    end
  else
    vrinstall('-check', 'viewer');
  end
  vrinstall('-check', 'editor');

  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% CHECK
  case '-check'

  % Unix
  if ~ispc
    if nargout>0
      x = true;    % always OK on Unix
    else
      fprintf('Nothing to check on this platform.\n');
    end

  % all components
  elseif nargin < 2
    if nargout>0
      x = vrinstall(action,'viewer') && vrinstall('-check','editor');
    else
      vrinstall(action,'viewer');
      vrinstall(action,'editor');
    end

  % viewer
  elseif strcmp(component, 'viewer')
    [wrlinst wrlviewer wrlver] = wrlcheck;     % test viewer type and version
    x = wrlinst && strcmp(wrlviewer, 'blaxxun Contact');
    if nargout==0           % print text info if no output required
      if x
        if strcmp(wrlver, '4.4.1.0')
          fprintf('\tVRML viewer:\tinstalled\n');
        else
          fprintf('\tVRML viewer:\tcompatible (%s %s)\n', wrlviewer, wrlver);
        end
      elseif wrlinst
        fprintf('\tVRML viewer:\tunsupported (%s %s)\n', wrlviewer, wrlver);
      else
        fprintf('\tVRML viewer:\tnot installed\n');
      end
      clear x;
    end

  % editor
  elseif strcmp(component, 'editor')
    x = exist(fullfile(getenv('windir'), 'vrbuild2.ini'), 'file');     % test editor INI file
    if nargout==0          % print text info if no output required
      if x
        fprintf('\tVRML editor:\tinstalled\n');
      else
        fprintf('\tVRML editor:\tnot installed (will be installed on first edit)\n');
      end
      clear x;
    end

  else
    error('VR:invalidinarg', 'Invalid component name');
  end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% INSTALL
  case '-install'
  if nargout>0
    error('VR:invalidoutarg', 'Too many output arguments.');
  end

  % Unix
  if ~ispc
    fprintf('Nothing to install on this platform.\n');
    return;        % nothing to do on Unix

  % all components
  elseif nargin < 2
    vrinstall(action,'viewer');
    vrinstall(action,'editor');

  % viewer
  elseif strcmp(component, 'viewer')
    if nargin>2 && strcmpi(bxtype, 'OpenGL')
      inp = 'o';
    elseif nargin>2 && strcmpi(bxtype, 'Direct3D')
      inp = 'd';
    else
      inp = ' ';
    end

    fprintf('Installing blaxxun Contact viewer ...\n');
    while ((inp~='o') && (inp~='d'))
      inp = lower(input('Do you want to use OpenGL or Direct3D acceleration? (o/d) ', 's'));
    end
    if inp=='o'
      bxinst = 'blaxxunContact44OGL.exe';
    else
      bxinst = 'blaxxunContact44.exe';
    end

    disp('Starting viewer installation ...');
    system(fullfile(matlabroot, 'toolbox', 'vr', 'blaxxun', bxinst));
    disp('Done.');

  % editor
  elseif strcmp(component, 'editor')
    disp('Starting editor installation ...');
    f = fopen(fullfile(matlabroot, 'toolbox', 'vr', 'resource', 'vrbuild2.ini'), 'r');
    ini = fread(f, '*char')';
    ini = strrep(ini, '$matlabroot', matlabroot);
    fclose(f);
    f = fopen(fullfile(getenv('windir'), 'vrbuild2.ini'), 'w+');
    fwrite(f, ini);
    fclose(f);
    disp('Done.');

  else
    error('VR:invalidinarg', 'Invalid component name');
  end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% UNINSTALL
  case '-uninstall'
  if nargout>0
    error('VR:invalidoutarg', 'Too many output arguments.');
  end

  % Unix
  if ~ispc
    fprintf('Nothing to uninstall on this platform.\n');
    return;        % nothing to do on Unix

  % all components
  elseif nargin < 2
    vrinstall(action,'viewer');
    vrinstall(action,'editor');

  % viewer
  elseif strcmp(component, 'viewer')
    warning('VR:cantuninstall', 'VRML viewer can''t be uninstalled from MATLAB. Please uninstall the viewer from the Control Panel.');

  % editor
  elseif strcmp(component, 'editor')
    if vrinstall('-check', 'editor')
      fprintf('Starting editor uninstallation ...\n');
      delete(fullfile(getenv('windir'), 'vrbuild2.ini'));
      fprintf('Done.');
    else
      fprintf('Editor not installed.\n');
    end

  else
    error('VR:invalidinarg', 'Invalid component name');
  end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% everything else
  otherwise
  error('VR:invalidinarg', 'Invalid action name');

end
