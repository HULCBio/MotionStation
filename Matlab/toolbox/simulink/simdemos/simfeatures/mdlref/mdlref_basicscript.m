function mdlref_basicscript(varargin)

% Copyright 2003-2004 The MathWorks, Inc.

%MDLREF_BASICSCRIPT Controls the Model Reference  Demo HTML page
%   MDLREF_BASICSCRIPT(action) executes the hyperlink callback 
%   associated with the the strings in varargin
%  
%   The complete set of demo files is as follows.
%      1) mdlref_basic.mdl
%      2) mdlref_counter.mdl 
%      3) mdlref_basic.html 

%   Mehmet Yunt 
%     

%States to keep track between calls to this 
%function   
  
  persistent prevBlock;  
  persistent prevModel;
    
  %Protecting against what may happen
  try   
  
    mFileName     = 'mdlref_basicscript';
    modelName     = 'mdlref_basic';
    refModelName  = 'mdlref_counter';
    htmlName      = 'mdlref_basic.html';  
    fullPath      = which(mFileName); 
    dirPath       = fileparts(fullPath);
    fullHTMLPath  = fullfile(dirPath,htmlName);
    
    %Open the html page if it is not already open
    %The HTML page is only opened 
    if(nargin < 1)
      try
        [stat,browser,url] = web(fullHTMLPath,'-helpbrowser');      
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
        open_system(model);
      else 
        set_param(model,'Open','on');  
      end   
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
          open_system(model);  
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
      open_system(modelName);
      set_param(modelName,'SimulationCommand','update')
      
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %Close all models
     case {'close'} 
      close_system(refModelName,0);
      close_system(modelName,0);
      
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
      %Open the mdlref tab
     case {'openmdlrefdlg'}
      if(nargin > 1)
        model = varargin{2};
        if(isempty(find_system('Name',model)))
          open_system(model);
        end  
      end
      modelH = get_param(model,'Object');
      referenceTab = find(modelH,'-isa','Simulink.ModelReferenceCC'); 
      daexplr('VIEW',referenceTab');    
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     %Unnecessary collector
     otherwise
    end
    
  catch
    
    warndlg({'There was an error executing the link you selected.';
             'Please, restart the demonstration as additional links ';
             'may be broken due to this problem.';});
             
  end
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  