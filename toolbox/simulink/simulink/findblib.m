function varargout = findblib
%FINDBLIB Searches the MATLAB path for products with Simulink blocks.

%   Optionally returns: 
%            0 for failure (an error occured).
%            1 for success. 
%            2 when the window is already open. 
%            3 when no slblocks files are found.

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.34.4.4 $

errmsg = '';
errAlreadyOpen = 2;
errNoFilesFound = 3;

% Determine if the library is already loaded up.  If it is, exit early.
found = find_system(0,...
                    'SearchDepth', 0,...
                    'Name','Blocksets_and_Toolboxes');
if ~isempty(found),
  open_system(found);
  if nargout > 0, varargout{1} = errAlreadyOpen; end
  return
end

% Put up message box.
mhdl = helpdlg('Scanning the MATLAB path for Simulink blocks...','Please wait');
drawnow;

% Find all slblocks.m
libs = which('slblocks.m', '-all');
if ~isempty(libs)
  libs = cellstr(unique(char(libs),'rows'));  % Remove any duplicates.
end

% If no slblocks.m files were found place a message in the subsystem
% and get out.
if isempty(libs)
  delete(mhdl);
  mhdl = msgbox('No Blocksets or Toolboxes with Simulink Blocks are installed.',...
      'Simulink','help');
  if nargout > 0, varargout{1} = errNoFilesFound; end
  return
end

% Create the new system as an unlocked library.
sys = ['Blocksets_and_Toolboxes'];
new_system(sys,'Library');
set_param(sys,'Location',[28 247 518 357],'Lock','off');

% disable the toolbar and statusbar
set_param(sys, 'ToolBar', 'off', 'StatusBar', 'off');

open_system(sys);

% Counters
row = 1;
col = 0;

% Define the position of the new blocks.
ys = 15; xs = 20; width = 50; xgap = 30; ygap = 40;
pos(1, :) = [xs    ys    xs+width    ys+width];
pos(2, :) = pos(1, :) + [width+xgap  0  width+xgap  0];
pos(3, :) = pos(2, :) + [width+xgap  0  width+xgap  0];
pos(4, :) = pos(3, :) + [width+xgap  0  width+xgap  0];
pos(5, :) = pos(4, :) + [width+xgap  0  width+xgap  0];
pos(6, :) = pos(5, :) + [width+xgap  0  width+xgap  0];

% Loop through the occurances of 'slblocks.m' in the MATLAB path.
nBS = size(libs,1);
for i=1:nBS
  col = col + 1;
  if col > 6
    col = 1;
    row = row + 1;
    set_param(sys,'Location',[28 247 518 (247 + 110*row)]);
  end
  
  % Use fopen to avoid checking out the toolbox license keys
  % This code is not robust to changes in the variable name "blkStruct"
  fcnStr = '';
  fid = fopen(libs{i},'r');
  
  % Skip down to function definition.
  while 1
    fcnLine = fgetl(fid);
    if findstr(lower(fcnLine),'function'), break, end
  end
  
  % Start reading the file.
  while 1
    fcnLine = fgetl(fid);           % Read next line in file.
    if ~ischar(fcnLine), break, end  % Breaks out at end of file.
    dotsIndex = findstr(fcnLine,'...');
    if isempty(dotsIndex),
      fcnStr=[fcnStr fcnLine sprintf('\n')];
    else
      % We're removing the "..." and literally concatenating the
      % two affected lines to make one line
      % Note: this will remove the "..."s inside any quoted strings
      fcnLine(dotsIndex:dotsIndex+2) = [];
      fcnStr=[fcnStr fcnLine];
    end
  end
  fclose(fid);
  
  % Execute the function slblocks.
  if ~isempty(fcnStr),
    blkStruct = '';
    eval(fcnStr,'errmsg = LocalErrHandler(libs{i}, nargout);');
    out = blkStruct;
  else
    errmsg = LocalErrHandler(libs{i}, nargout);
  end
  
  % If there was no error above (struct returned),
  % continue processing this file.
  if isstruct(out)
    %
    % Determine if the block already exists.  This can happen when the
    %  MATLABPATH contains multiple directories that contain similar
    % slblocks.m files.
    %
    if isempty(find_system(sys,'Name',out.Name)),

      % Create the block and set the required parameters, Name and OpenFcn.
      name = [sys '/' out.Name];
    
      add_block('built-in/Subsystem',name, ...
                'Position',(pos(col,:) + (row-1).*[0 90 0 90]));
      
      %
      % Set other block params (Name and OpenFcn required) the user desires.
      % Any other parameters the user provides are 'set' in the block.
      % Note that the Browser and IsFlat parameters are removed from the set
      % as they are used by the Simulink browser.
      %
      if isfield(out,'Browser'),
        out = rmfield(out,'Browser');
      end
      if isfield(out,'IsFlat'),
        out = rmfield(out,'IsFlat');
      end
      if isfield(out,'Viewer'),
        out = rmfield(out,'Viewer');
      end
      if isfield(out,'Generator'),
        out = rmfield(out,'Generator');
      end
      params = fieldnames(out);
      for ind = 1:length(params),
        value = eval(['out.' params{ind}]);
        try
          set_param(name,params{ind},value)
        catch
          errmsg = LocalErrHandler(libs{i}, nargout);
        end
      end
      
      % Flush the graphics so that blocks appear as they are added.
      drawnow;
    end
  end
end

% Turn off dirty flag, clean up figures and return to original directory.
set_param(sys,'Dirty','off','Lock','on');
if ishandle(mhdl), delete(mhdl); end
if (nargout > 0)
  varargout{1} = double(isempty(errmsg)); 
  warning(errmsg);
end

%------------------ LocalErrHandler ----------------------------
function str = LocalErrHandler(fname, showdialog)
% Used to trap and process errors in user slblocks.m files.
% The second input is to determine if we should display the error
% dialog or not.  This value is based on nargout of the main function.

str = sprintf('Error in file : %s\n%s',fname,lasterr);
if (showdialog == 0)
  % Raise error dialog
  errordlg(str, 'Error in slblocks.m file');
end


