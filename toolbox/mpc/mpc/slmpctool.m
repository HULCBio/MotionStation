function [hJava, hUDD, M, h, project] = slmpctool(varargin)
% SLMPCTOOL

% Author(s): James G. Owen
% Revised: 
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.10.10 $ $Date: 2004/04/16 22:09:27 $

% varargin empty: initialize and returns;
% varagin{1} is action: {'initialize',...
% varargin{2} is the Simulink model name
% varargin{3} is an existing project handle (optional)
% varargin{4} is the label for the mpc task node (optional)
% varargin{5} is the mpc block path/name (optional)
% varargin{6} is a cell array of MPC objects and names (optional)
% varargin{7} is a handle to the java progress dialog (optional)

% Known calling syntaxes
% mpctool
% -------
% 
% [Frame, MPC_WSh, MPC_MANh, h] = slmpctool('initialize',[],[],ProjectName,'', ...
%     MPCobjects);
% 
% mpc_mask
% --------
% 
% [hRoot, hWS, hTree,hGUI,hProj] = slmpctool('initialize', blksystem, [], task_name, ...
%                                  blk,{mpcobj,mpcobjname});
% 
% mpc_openscm
% ------------
% 
% [FRAME,WSHANDLE,MANAGER,hGUI, hProj] = slmpctool('initialize',model, [], ...
%     get_param(mpcblock,'Name'),mpcblock, [],progress);
% 
% @Project/AddNewProject
% ----------------------
% 
% slmpctool('initialize', model);


wb=[];
project = [];
numargin = nargin;

%% Get the simulink model name if any
if numargin<2 || isempty(varargin{2}) % Opened from MATLAB
   model = '';
elseif ~isempty(varargin{2}) 
   if isa(varargin{2}, 'char')
      model = varargin{2};
    else
       try
         model = get_param(varargin{2}, 'Name');
       catch
         error('slmpctool:nodiag','Invalid Simulink model handle.');
       end
    end
elseif (numargin >= 3) && isa(varargin{3}, 'explorer.projectnode')
    model = varargin{3}.Model;
end

% Get the block name/path
fullblockname = '';
if numargin>=5 && ~isempty(varargin{5})
   fullblockname = varargin{5};
elseif ~isempty(model)
   fullblockname = mpc_getblockpath(model);
end 
   
%% Get the tree manager handle
[hJava,hUDD,M] = slctrlexplorer('initialize');
h = [];

% If necessary ask for the # of mvs
if ~localInit(fullblockname) 
     return % Block not initialized - cancel pressed
end

%% Get the handle to the project and the frame
if (numargin >= 3) && isa(varargin{3}, 'explorer.projectnode')
   project = varargin{3};
   FRAME   = hJava;
   if ~isempty(model) % Add op cond task
       addoptask(model,project);
   end
elseif ~isempty(model) 
   % Select the root for getvalidproject to work
   drawnow
   M.ExplorerPanel.setSelected(hUDD.getTreeNodeInterface)
   [project, FRAME] = getvalidproject(model,true);
else
    project = hUDD; % Opened from MATLAB
    FRAME   = hJava;
end    
if isempty(project)
    return
end

% Set the correct initial size. If the GUI is being initialized the 
% FRAME must be invisible
if ~FRAME.isVisible
    WindowSize = java.awt.Dimension(880,770);
    FRAME.setSize(WindowSize);
    %FRAME.setMinimumSize(WindowSize.width,WindowSize.height);
    M.ExplorerPanel.getVerticalSplit.setDividerLocation(int32(550));
end

%% Return if there are no input args
if numargin==0
    return
end

      
%% Switchyard for GUI interaction with Simulink
switch varargin{1}
case 'initialize'
%% Simulink - new task required
  if ~isempty(model) && (numargin<5 || ...
      isempty(project.find('-class','mpcnodes.MPCGUI','Block',fullblockname)))
    
      %% Manage wait/status bar      
      if numargin<=6 || ~isjava(varargin{7})
          wb = waitbar(0, 'MPC Tool', 'Name', 'MPC Tool');
      else % A progressDialog has been specified and should be used as the 
           % desitination for waitbar messages
           wb = varargin{7};
      end
      localWaitbar(0.2, wb, 'Loading MPC Tool...');
      pause(0.5)
      localWaitbar(0.5, wb, 'Creating the GUIs...')
      pause(0.5)     
      localWaitbar(0.6, wb, 'Creating an MPC task...')

      %% Create MPC task 
      n = max(findstr('/',fullblockname));
      if ~isempty(n)
          thisblock = fullblockname(n+1:end);
      else
          thisblock = fullblockname;
      end
      h = mpcnodes.MPCGUI(thisblock);
      
      % Assign the deletefcn callback to remove the task if the
      % MPC block is deleted
      set_param(fullblockname,'deleteFcn',['mpc_deletetask(''' ...
             fullblockname ''')']);
              
                  
      %% Update the new MPCGUI with the treemanager handle
      h.getDialogInterface(M);

      %% Put the block name in the MPCGUI node
      if numargin>=5 && ischar(varargin{5})
          h.Block = varargin{5};
      else
          h.Block = [model '/' h.Label];
      end

      %% Add listeners to the Operating condition node to update the
      %% linearization dialog operating condition combo 
      tasks = project.getChildren;
      opCondNode = [];
      for k=1:length(tasks)
          if isa(tasks(k),'OperatingConditions.OperatingConditionTask')
              opCondNode = tasks(k);
              break
          end
      end
      if ~isempty(opCondNode)
          L = [handle.listener(opCondNode,'ObjectChildAdded', ...
              {@localOpCondAdded h opCondNode});
               handle.listener(opCondNode,'ObjectChildRemoved', ...
               {@localOpCondAdded h opCondNode})];
          h.addListeners(L);
      end

%% Add it to the project node
      localWaitbar(0.7, wb, 'Attach the project to the GUI...');
      project.addNode(h);
      addLinearizationDialog(h,M)  

%% Wait bar update 
      localWaitbar(1.0, wb, 'MPC Tool is ready.');
      if isa(handle(wb),'figure')
         close(wb);
      end
      
      % Reset project save flag
      h.Dirty = false;
      
  %% Command line - new task required    
  elseif isempty(model)
      %% Manage wait/status bar      
      if numargin<=6 || ~isjava(varargin{7})
          wb = waitbar(0, 'MPC Tool', 'Name', 'MPC Tool');
      else % A progressDialog has been specified and should be used as the 
           % desitination for waitbar messages
          wb = varargin{7};
      end     
      localWaitbar(0.2, wb, 'Loading MPC Tool...');
      pause(0.5)
      localWaitbar(0.5, wb, 'Creating the GUI...')
      pause(0.5)     
      localWaitbar(0.6, wb, 'Attach the project to the GUI...')
          
      % Define a new project if necessary
      if numargin>=4 && ~isempty(varargin{4})
          h = newMPCproject(varargin{4});
      else
          h = newMPCproject;
      end
      localWaitbar(1.0, wb, 'MPC Tool is ready.');
      
  % Simulink - task already exists somewhere under the project node so find
  % it
  elseif ~isempty(model) && numargin>=5 && ...
     ~isempty(project.up.find('-class','mpcnodes.MPCGUI','Block',fullblockname))
      h = project.up.find('-class','mpcnodes.MPCGUI','Block',fullblockname);
  else
      error('slmpctool:syntax','Syntax error')
  end

  %% Set the Settings node to be the current selected
  FRAME.setSelected(h.getTreeNodeInterface);
  h.Frame = FRAME;
  

  %% If an MPC block has been defined check to see if it contains an MPC
  %% object
  if ~isempty(fullblockname) && ~isempty(get_param(fullblockname,'mpcobj')) && ...
          (numargin<6 || isempty(varargin{6}))
      try 
          thisobjname = get_param(fullblockname,'mpcobj');
          varargin{6} = {evalin('base',thisobjname), thisobjname}; 
          numargin = 6;
      end
  end
  
  %% If there is/are is a new MPC object create a controller node
  if numargin>=6  && ~isempty(varargin{6}) && ~isempty(varargin{6}{2})
      MPCobjectArray = varargin{6};
      existMPC = h.getMPCControllers.find('-class','mpcnodes.MPCController',...
          'Label',varargin{6}{2});
      if isempty(existMPC)
          h.MPCObject = varargin{6};
          h.loadMPCobjects;
      end
  end

   %% Get focus on the GUI
  drawnow
  awtinvoke(FRAME,'setVisible',true);
  awtinvoke(FRAME,'toFront');
  if isa(handle(wb),'figure')
      close(wb)
  end
end  


function localOpCondAdded(es,ed,mpcnode,opCondNode)

%% Callback to operating condition node childadded/childremoved listener
%% which updates the combo box in the linearization dialog
mpcnode.opCondAdded(opCondNode)

function localWaitbar(val,wb,txt)

if isjava(wb)
    wb.setStatus(txt)
elseif ishandle(wb)
    waitbar(val,wb,txt);
end
    

function localOK(es,ed,f,mvedit)

set(f,'Userdata','OK')
uiresume(f)

function localCancel(es,ed,f)

set(f,'Userdata','Cancel')
uiresume(f)

function status = localInit(mpcblock)

% Queries the user for the number of MVs
status = true;
if ~isempty(mpcblock) && isempty(get_param(mpcblock,'mpcobj'))
    prompt= {'Specify number of Manipulated Variables (MVs)'};
    n_mv = str2num(get_param(mpcblock,'n_mv'));
    if isempty(n_mv)
        answer = inputdlg(prompt,'Build MPC Controller by linearizing Simulink model', ...
           1,{'0'});
    else
        answer = inputdlg(prompt,'Build MPC Controller by linearizing Simulink model', ...
           1,{sprintf('%d',n_mv)});
    end   
    if isempty(answer)
        status = false;
        return
    else
        try
            nu = str2num(answer{1});
        catch
            errordlg('Invalid entry','Model Predictive Control Toolbox', ...
                'modal')
            return
        end
        if ~isscalar(nu) || nu<1
            errordlg('Invalid entry','Model Predictive Control Toolbox',...
                'modal')
            status = false;
            return 
        end
    end
    set_param(mpcblock,'n_mv',sprintf('%d',nu));
end
 
