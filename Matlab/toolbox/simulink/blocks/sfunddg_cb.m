function sfunddg_cb(dlgH)
%SFUNDDG_CB S-Function Edit button callback to find source files
%
% [This file is a callback for the S-function block dialog, 
%  it is not intended for direct use from the MATLAB prompt.]
%
% The following places are searched for S-function source files:
%
%     - on the path or in the current directory
%     - in the <matlabroot>/simulink/src directory
%     - in non-RTW .sourcePath directories returned from rtwmakecfg.m
%     - in the <matlabroot>/simulink/ada/examples/* directories for Ada
%
% The following file types can be found:
%
%     .m  .c .cpp  .f  .for  .f77  .f90  .adb  .ads  .ada
%
% You can add to this file's search heuristic by creating an M-function
% named sfunsrcedit_hook.m on your MATLAB path that opens the editor 
% for the source of a given S-function name.  The general template 
% would be:
%
%      function keepLooking = sfunsrcedit_hook(sfun)
%
%          [... some rules to find your source files ...]
%
%          if (fileFound == true),
%             edit(filenameIfound);
%             keepLooking = false;
%          else
%             keepLooking = true;
%          end
%          return;
%

% Copyright 1990-2004 The MathWorks, Inc.
% $Revision: 1.1.6.4 $


% --- Extract the S-Function name from the dialog
sfun       = dlgH.getWidgetValue('FunctionName');
sfun_exist = exist(sfun,'file');

% --- Check that the S-function exists as .m, .p, or MEX
if any( sfun_exist == [2,3,6] ),
  
  % --- If there is a custom file-finding hook file, call it
  if any( exist('sfunsrcedit_hook','file') == [2,6] ),
    keepLooking = sfunsrcedit_hook(sfun);
    if ~keepLooking,
      return;
    end
  end
  
  % --- Look for the S-Function source code in the following places:
  %
  %     - on the path or in the current directory
  %     - in the <matlabroot>/simulink/src directory
  %     - in the <matlabroot>/simulink/ada/examples/* directories
  %
  
  if sfun_exist == 2,
    
    % --- Open M-file S-functions directly
    edit(which(sfun));
    return;
    
  elseif sfun_exist == 6,
    
    % --- S-function is a P-file, look for a corresponding M-file
    %     on the path.  Note that this might be just a help file
    %     and not very useful.
    
    srcCandidate = [ sfun, '.m' ];
    if exist(srcCandidate,'file') == 2,
      edit(which(srcCandidate));
      return;
    end
    
  elseif sfun_exist == 3,
    
    srcFile = sfunddg_fs(sfun);
    if ~isempty(srcFile)
      edit(srcFile);
      return;
    end
  end
end

% At this point, either the S-function was not found or 
% a source file was not found using the above heuristic search.  
%
% As a fallback, bring up a file chooser dialog to allow
% a manual browse session or just launch the editor.

buttonName = questdlg(...
    ['The S-Function source file cannot be found.', sprintf('\n'),...
     'It could be either that the file does not exist, or it''s not on your MATLAB path.'...
     'Do you want to manually browse it, simply open the editor or cancel?'], ...
    'Question', 'Browse...', 'Open editor', 'Cancel', 'Cancel');

switch buttonName
 case 'Browse...'
  [filename, pathname] = uigetfile( ...
      {'*.c;*.cpp;*.F;*.f;*.for;*.for;*.f77;*.f90;*.adb;*.ada;*.ads;*.m','All S-Function Source Files'; ...
       '*.*', 'All Files(*.*)'}, ...
      'S-Function Browser');
  if isequal(filename,0) || isequal(pathname,0)
    % do nothing, user pressed cancel
  else
    edit([pathname filesep filename]);
  end
  return;
 case 'Open editor'
  % If we reach this point then just launch the editor
  if isempty([name ext])
    edit;
  elseif isempty(ext)
    edit([name '.m']);
  else
    extstr = ['.c','.cpp','.f','.ada','.m'];
    if findstr(extstr, ext)
      edit([name ext]);
    else
      edit([name '.m']);
    end
  end
  return;
 otherwise
  % do nothing
  return;
end

