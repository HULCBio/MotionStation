function varargout = commblkconvcod(block, varargin)
% COMMBLKCONVCOD Communications Blockset Convolutional Encoder block helper 
%   function.

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.11 $ $Date: 2002/03/24 02:01:10 $

%  Possible calls:
%      The seocnd argument indicates if it is R11 mask (0), or
%      if it is R12 mask (1).
%
% R11 mask
%      commblkconvcod(block, 0, 'init', memlen, gen, fbflag);
%      commblkconvcod(block, 0, 'cbFbFlag');
%      commblkconvcod(block, 0, 'default');
%      commblkconvcod(block, 0, 'showall');
%
% R12 mask
%      commblkconvcod(block, 1, 'init', memlen, gen, fbflag);
%      commblkconvcod(block, 1, 'cbDecType');
  
nvarargin = nargin - 2;
newBlk    = varargin{1};

%
% Code for old mask
%
% --- Field numbers
if ~newBlk,
  
  switch nvarargin
   case 0
    action = '';
   case 1
    action = varargin{2};
    Args   = 0;
   case  2
    action = varargin{2};
    Args   = varargin{3};
   case 4
    action    = varargin{2};
    MemLenArg = varargin{3};
    GenArg    = varargin{4};
    fbTaps    = varargin{5};
    Args      = {MemLenArg,GenArg,fbTaps};
  end;

  % --- Field data
  Vals	= get_param(block, 'maskvalues');
  Vis	= get_param(block, 'maskvisibilities');
  En  	= get_param(block, 'maskenables');
  
  % --- Field numbers
  MemLen   = 1;
  Gen      = 2;
  FbFlag   = 3;
  FbTaps   = 4;
  Reset    = 5;

  %*****************************************************************************
  % Function:    Initialize
  % Description: Set the dialogs up based on the parameter values.
  %	       MaskEnables/MaskVisibilities are not saved in reference blocks.
  % Inputs:      current block
  % Return Values:	none
  %*****************************************************************************
  if(strcmp(action,'init'))
    feval(mfilename, block, 0, 'UpdateFields', Args);
    [varargout{1:3}] = feval(mfilename, block, 0, 'UpdateWs', Args);
  end;
  
  %*****************************************************************************
  % Function:      UpdateFields
  % Description:   Update the dialog fields. Indicate that block updates are 
  %                not required
  % Inputs:        current block
  % Return Values: none
  %*****************************************************************************
  if(strcmp(action,'UpdateFields'))
    feval(mfilename,block, 0 ,'cbFbFlag', 1);
  end;
  
  %*****************************************************************************
  % Function:      UpdateWs
  % Description:   Set the simulink blocks as required
  % Inputs:        current block
  % Return Values: s, x, y
  %*****************************************************************************
  if(strcmp(action,'UpdateWs'))
    % Drawing vectors
    x = 0;
    y = 0;

    MemLenArg = Args{1};
    GenArg    = Args{2};
    fbTaps    = Args{3};
    
    isRst = strcmp(Vals{Reset},'on');
    s     = initWorkSpace(isRst);
    
    if isRst,
      s.reset = 3; % has reset port
    else
      s.reset = 1; % no reset port
    end

    % Setup port label structure:
    try,
    if(strcmp(Vals{FbFlag},'Feedforward')),
      trellis = poly2trellis(MemLenArg, GenArg);
    else
      trellis = poly2trellis(MemLenArg, GenArg, fbTaps);
    end
    
    catch
      s.status = lasterr;
    end

    if isempty(s.status)
      s = updateWorkSpace(s, trellis);
    end
    varargout{1} = s;
    varargout{2} = x;
    varargout{3} = y;
  end;
  
  %****************************************************************************
  % Function Name: 'cbFbFlag'
  % Description:   Deal with the feedforward/feedback mode of operation
  % Inputs:	   current block 
  % Return Values: none
  %****************************************************************************
  if(strcmp(action,'cbFbFlag'))
    oldEn = Vals{FbFlag};
    if(strcmp(Vals{FbFlag},'Feedforward'))
      En{FbTaps}  = 'off';
    else % 'Feedback'
      En{FbTaps}  = 'on';
    end;
    if strcmp(oldEn, En{FbTaps}) == 0
      set_param(block,'MaskEnables',En);    
    end;
  end;
  
  %*****************************************************************************
  % Function Name: 'default'
  % Description:   Set the block defaults (development use only)
  % Inputs:	   current block
  % Return Values: none
  %*****************************************************************************
  if(strcmp(action,'default'))
    
    Cb{MemLen} 	= '';
    Cb{Gen} 		= '';
    Cb{FbFlag}	= [mfilename '(gcb, 0,''cbFbFlag'');'];
    Cb{FbTaps}	= '';
    Cb{Reset}	= '';
    
    En{MemLen}	= 'on';
    En{Gen}		= 'on';
    En{FbFlag}	= 'on';
    En{FbTaps}	= 'off';
    En{Reset}	= 'on';
    
    Vis{MemLen}	= 'on';
    Vis{Gen}		= 'on';
    Vis{FbFlag}	= 'on';
    Vis{FbTaps}	= 'on';
    Vis{Reset}	= 'on';
    
    % -- Get the MaskTunableValues 
    Tunable = get_param(block,'MaskTunableValues');
    Tunable{MemLen}  = 'off';
    Tunable{Gen}     = 'off';
    Tunable{FbFlag}  = 'off';
    Tunable{FbTaps}  = 'off';
    Tunable{Reset}   = 'off';
    
    % -- Set Callbacks, enable status, visibilities and tunable values
    set_param(block,'MaskCallbacks',Cb,'MaskEnables',En,'MaskVisibilities', ...
		    Vis, 'MaskTunableValues', Tunable);
    
    % -- Set the startup values.  Indicates that the default saved will be used
    
    Vals{MemLen}  = '7';
    Vals{Gen}     = '[171 133]';
    Vals{FbFlag}  = 'Feedforward';
    Vals{FbTaps}  = '171';
    Vals{Reset}   = 'off';
    
    MN = get_param(gcb,'MaskNames');
    for n=1:length(Vals)
      if(~isempty(Vals{n}))
	set_param(block,MN{n},Vals{n});
      end;
    end;
    
    % --- Update the Vals field with the actual values
    Vals	= get_param(block, 'maskvalues');
    
    % --- Ensure that the block operates correctly from a library
    set_param(block,'MaskSelfModifiable','on');
    
  end;

  %*****************************************************************************
  % Function Name: show all
  % Description:	 Show all of the widgets
  % Inputs:        current block
  % Return Values: none
  % Notes: This function is for development use only and allows All fields to
  % be displayed
  %*****************************************************************************
  if(strcmp(action,'showall'))
    
    Vis	= get_param(block, 'maskvisibilities');
    En  = get_param(block, 'maskenables');
    
    Cb = {};
    for n=1:length(Vis)
      Vis{n} = 'on';
      En{n} = 'on';
      Cb{n} = '';
    end;
    
    set_param(block,'MaskVisibilities',Vis,'MaskEnables',En,'MaskCallbacks',Cb);
    
  end;
  
else %%%% New block

  switch nvarargin
   case 3, % Currently used for init      
    action     = varargin{2};
    ArgTrellis = varargin{3};
    ArgReset   = varargin{4};
   otherwise
    % User will not see this error message.
    error('Invalid number of parameters');
  end;
  
  %****************************************************************************
  % Function:     Initialize
  % Description:  Set the dialogs up based on the parameter values.
  %	         MaskEnables/MaskVisibilities are not saved in reference blocks
  % Inputs:       current block
  % Return Values:none
  %****************************************************************************
  if(strcmp(action,'init'))
    hasReset = ArgReset == 3;
    s = initWorkSpace(hasReset);
    s.reset = ArgReset;
	
	% Do not evaluate/check the parameters if the simulation status is 'stopped'.
	% This is the case when loading a model with the block in it. 
    simStat = get_param(bdroot(gcb),'SimulationStatus');
    if(strcmpi(simStat,'stopped'))
        varargout{1} = s;
        return;
    end;
	
	s = updateWorkSpace(s, ArgTrellis);
    varargout{1} = s;
  end  
end


%- Helper functions-----------------------------------------------------------
% Create a workspace structure
function s = initWorkSpace(hasResetPort)
  s            = [];
  s.k          = [];
  s.n          = [];
  s.numStates  = [];
  s.outputs    = [];
  s.nextStates = [];
  s.reset      = 0 ;
  s.status     = '';

  if hasResetPort,
    s.i1 = 1; s.i1s = 'In';
    s.i2=  2; s.i2s = 'Rst';
  else
    s.i1 = 1; s.i1s = '';
    s.i2 = 1; s.i2s = '';
  end
  s.o1 = 1; s.o1s = '';
  
  
% Update workspace
function s = updateWorkSpace(s, trellis)
  %set block parameters
  [isOk, msg] = istrellis(trellis);
  if ~isOk, 
    s.status = ['Invalid trellis structure.' msg]; 
    return;
  end;
  s.k          = log2(trellis.numInputSymbols);
  s.n          = log2(trellis.numOutputSymbols);
  s.numStates  = trellis.numStates;
  s.outputs    = oct2dec(trellis.outputs);
  s.nextStates = trellis.nextStates;
