function mdlref_conversionscript(varargin)

%MDLREF_CONVERSIONSCRIPT Controls the Model Reference  Demo HTML page
%   MDLREF_CONVERSIONSCRIPT(action) executes the hyperlink callback 
%   associated with the the strings in varargin
%  
%   The complete set of demo files is as follows.
%      1) mdlref_conversion.mdl
%      2) mdlref_conversion.html 
%
%   Arwen Warlock
%     

% Copyright 2004 The MathWorks, Inc.
%$Revision: 1.1.6.2 $
%States to keep track between calls to this 
%function   
  
  persistent prevBlock;  
  persistent prevModel;
    
  %Protecting against what may happen
  try   
  
    mFileName     = 'mdlref_conversionscript';
    modelName     = 'mdlref_conversion';
    convModelName = 'mdlref_conversion_converted';
    convRefModelName = 'Bus_Counter';
    htmlName      = 'mdlref_conversion.html';  
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
      
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
      %Hilite specified block in specified model 
      % and open it
     case {'hiliteAndOpen'}
      
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
        open_system(block);
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
        
        if strcmp(model,'Bus_Counter')
          save_system(model);
        end
      end
      if(nargin > 3) 
        subsys = varargin{4};
        %Open the subsystem if it is not already open
        open_system(subsys);
      end
      
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %Simulate top model
     case{'sim'} 
      if(nargin > 1) 
        model   = varargin{2};
      else 
        model = modelName;
      end
      sim(model);
      
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %Update top model
     case{'update'}  
      open_system(modelName);
      set_param(modelName,'SimulationCommand','update')
      
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %Close all models
     case {'close'} 
      close_system(modelName,0);
      try
        close_system(convModelName,0);
        close_system(convRefModelName,0);
      catch
      end
      
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

      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %Convert the model
     case{'convert'}
      if(nargin > 1)
        model   = varargin{2};
        mdlref_conversionscript('close');
        mdlref_conversionscript('cleanup','files');
        mdlref_conversionscript('cleanup','vars');
        open_system(model);
        mkdir('mdlref_conv_demo');
        [success,newMdlName] = sl_convert_to_model_reference(model,...
                               ['.',filesep,'mdlref_conv_demo']);
        open_system(model);
        open_system(newMdlName);
      end

      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %Cleanup created files
     case{'cleanup'}
      if(nargin > 1) 
        mode   = varargin{2};
        
        if strcmp(mode,'files')
          try
            rmdir('mdlref_conv_demo','s');
          catch
          end
          delete Bus_Counter_msf.*
          delete mdlref_conversion_converted_msf.*
          % should we try to remove slprj if we can detect it was 
          % not there when demo started?
        else      
          if evalin('base','exist(''bus0'',''var'')')
            evalin('base','clear bus0 bus1 bus2 bus3 bus4');
          end
        end
      end
      
     otherwise
    end
    
  catch
    
    warndlg({'There was an error executing the link you selected.';
             'Please, restart the demonstration as additional links ';
             'may be broken due to this problem.';});
             
  end
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  