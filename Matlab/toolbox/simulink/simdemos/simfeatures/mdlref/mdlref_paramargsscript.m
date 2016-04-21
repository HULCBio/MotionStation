function mdlref_paramargsscript(varargin)

% Copyright 2003-2004 The MathWorks, Inc.

%MDLREF_PARAMARGSSCRIPT Controls the Model Reference  Demo HTML page
%   MDLREF_PARAMARGSSCRIPT(action) executes the hyperlink callback
%   associated with the the strings in varargin
%
%   The complete set of demo files is as follows.
%      1) mdlref_paramargs.mdl
%      2) mdlref_counter_paramargs.mdl
%      3) mdlref_paramargs.html
%      4) mdlref_counter_paramargs_init.mat
%      5) mdlref_paramargsscript.m
%
%   Mehmet Yunt
%

%States to keep track between calls to this
%function

  persistent prevBlock;
  persistent prevModel;

  %Protecting against what may happen
  try

    mFileName     = 'mdlref_paramargsscript';
    modelName     = 'mdlref_paramargs';
    refModelName  = 'mdlref_counter_paramargs';
    htmlName      = 'mdlref_paramargs.html';
    dataFileName  = 'mdlref_counter_paramargs_init.mat';

    fullPath      = which(mFileName);
    dirPath       = fileparts(fullPath);
    fullHTMLPath  = fullfile(dirPath,htmlName);

    %Open the html page if it is not already open
    %Do a once initialization
    if(nargin < 1 )
      try
        web(fullHTMLPath,'-helpbrowser');
      end
    end

    %If no command was given assume open
    if(nargin > 0)
      command = varargin{1};
    else
      command ='open';
    end

    %Switch on what needs to be done
    switch(command)

      %Open the specified or the top model
     case {'open'}
      if(nargin > 1)
        model = varargin{2};
      else
        model = modelName;
      end

      %Open the model if it is not already open
      if(isempty(find_system('Name',model)))
        load_system(model);
      end
      set_param(model,'Open','on');


      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %Hilite specified block in specified model
     case {'hilite'}

      %Remove the previous hiliting if the previous
      %model is open and previous hiliting was done
      if(~isempty(prevBlock) & ~isempty(prevModel))
        if(~isempty(find_system('Name',prevModel)))
          hilite_system(prevBlock,'none');
        end
      end

      if(nargin > 2)
        block = varargin{3};
        model = varargin{2};
        if(isempty(find_system('Name',model)))
          load_system(model);
        end
        hilite_system(block,'find');
        prevBlock = block;
        prevModel = model;
      end

      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %Various building for the demonstration
     case {'build'}

      if(nargin > 2)
        model  = varargin{2};
        target = varargin{3};
        slbuild(model,target);
      end

      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %Sample time hiliting
     case {'sampletimes'}

      if(nargin > 1)
        model   = varargin{2};
        state   = varargin{3};

        %Open the model if it is not already open
        open_system(model);
        set_param(model,'SampleTimeColors',state);
        set_param(model,'SimulationCommand','update')
      end

      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %Simulate top model
     case{'sim'}
      sim(modelName);

      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %Update top model
     case{'update'}
      load_system(modelName);
      set_param(modelName,'SimulationCommand','update')

      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %Close all models
     case {'close'}
      close_system(refModelName,0);
      close_system(modelName,0);

      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %Open file for inspection with the MATLAB editor
     case {'openfile'}
      if(nargin >1)
        edit(varargin{2})
      end

     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     %Obtain Model Workspace
     case {'getWS'}
      if(isempty(find_system('Name',refModelName)))
        load_system(refModelName);
      end
      evalin('base',['mdlWS = get_param(''',refModelName,''',''ModelWorkspace'');']);
      disp(['mdlWS = get_param(''',refModelName,''',''ModelWorkspace'');']);
      
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     %Set the data source type
     case {'setSrcType'}
      if(isempty(find_system('Name',refModelName)))
        load_system(refModelName);
      end
      evalin('base',['mdlWS = get_param(''',refModelName,''',''ModelWorkspace'');']);
      evalin('base','mdlWS.DataSource =''MAT-File'';');
      disp('mdlWS.DataSource =''MAT-File'';');
      
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     %Set the file name
     case {'setSrcFileName'}

      if(isempty(find_system('Name',refModelName)))
        load_system(refModelName);
      end
      evalin('base',['mdlWS = get_param(''',refModelName,''',''ModelWorkspace'');']);
      evalin('base','mdlWS.DataSource =''MAT-File'';');
      evalin('base',['mdlWS.FileName =''', dataFileName,''';']);
      disp(['mdlWS.FileName =''', dataFileName,''';']);
      
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     
     %Upload data
     case {'upload'}
      if(isempty(find_system('Name',refModelName)))
        load_system(refModelName);
      end
      warning off;
      evalin('base',['mdlWS = get_param(''',refModelName,''',''ModelWorkspace'');']);
      evalin('base','mdlWS.DataSource =''MAT-File'';');
      evalin('base',['mdlWS.FileName =''', dataFileName, ''';']);
      evalin('base','mdlWS.reload;');
      disp('mdlWS.reload;');
      warning on;

      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %Set the parameter argument names for
      %the referred model
      case {'setParameterArgNames'}
       if(isempty(find_system('Name',refModelName)))
         load_system(refModelName);
       end
       warning off;
       evalin('base',['mdlWS = get_param(''',refModelName,''',''ModelWorkspace'');']);
       evalin('base','mdlWS.DataSource =''MAT-File'';');
       evalin('base',['mdlWS.FileName =''', dataFileName, ''';']);
       evalin('base','mdlWS.reload');   
       set_param(refModelName,'ParameterArgumentNames','lower_saturation_limit,upper_saturation_limit');
       disp(['set_param(',refModelName,',''ParameterArgumentNames''',',''lower_saturation_limit,upper_saturation_limit'');']);
       
       warning on;

     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     %Set the block values in the model blocks
     %
     case {'setValues'}
      if(isempty(find_system('Name',refModelName)))
        load_system(modelName);
      end
      set_param('mdlref_paramargs/CounterA','ParameterArgumentValues','0,20')
      set_param('mdlref_paramargs/CounterB','ParameterArgumentValues','0,10')
      set_param('mdlref_paramargs/CounterC','ParameterArgumentValues','0,5')

     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     %Save specified model
     %
     case {'save'}
      if(nargin > 1)
        if(~isempty(find_system('Name',varargin{2})))
          save_system(varargin{2});
        end
      end

     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     % Open up the Model Reference Tab in the Simulation
     % Parameters page

     case {'openmdlrefdlg'}
      if(nargin > 1)
        model = varargin{2};
        if(isempty(find_system('Name',model)))
          load_system(model);
        end
         modelH = get_param(model,'Object');
         referenceTab = find(modelH,'-isa','Simulink.ModelReferenceCC');
         daexplr('VIEW',referenceTab);
      end

      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     % Open up the Model Workspace in  Model Explorer

     case {'openwrkspace'}
      if(nargin > 1)
        model = varargin{2};
        if(isempty(find_system('Name',model)))
          open_system(model);
        end
        modelH = get_param(model,'Object');
        hChildren = modelH.getHierarchicalChildren;
        for idx =1:length(hChildren)
          if isa(hChildren(idx),'DAStudio.WorkspaceNode')
            daexplr('VIEW',hChildren(idx));
            break;
          end
        end
      end

      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %Open up block dialog on the Model Reference Block
      %
      %
     case {'openblkdlg'}     
      if(nargin > 2)
        block = varargin{3};
        model = varargin{2};
        if(isempty(find_system('Name',model)))
          load_system(model);
        end
        open_system(block);
      end
         
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %Unnecessary collector
     otherwise
    end

  catch

    warndlg({'There was an error executing the link you selected.';
             'Please, restart the demonstration as additional links ';
             'may be broken due to this problem.';});

  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%