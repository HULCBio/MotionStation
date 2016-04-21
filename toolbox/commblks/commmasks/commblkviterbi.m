function varargout = commblkviterbi(block,varargin)
% COMMBLKCONVCOD Communications Blockset Viterbi Decoder block helper function.

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.13 $ $Date: 2002/03/24 02:02:16 $

%  Possible calls:
%      The seocnd argument indicates if it is R11 mask (0), or
%      if it is R12 mask (1).
%
% R11 mask
%      commblkviterbi(block, 0, 'init', memlen, gen, fbflag);
%      commblkviterbi(block, 0, 'cbFbFlag');
%      commblkviterbi(block, 0, 'cbDecType');
%      commblkviterbi(block, 0, 'default');
%      commblkviterbi(block, 0, 'showall');
%
% R12 mask
%      commblkviterbi(block, 1, 'init', trellis);
%      commblkviterbi(block, 1, 'cbDecType');
%      commblkviterbi(block, 1, 'cbOpMode');
%      commblkviterbi(block, 1, 'showall');

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
    Args = 0;
   case 4
    action    = varargin{2};
    MemLenArg = varargin{3};
    GenArg    = varargin{4};
    FbTapsArg = varargin{5};
    Args      = {MemLenArg,GenArg,FbTapsArg};
   otherwise
    action = varargin{2};
    Args = varargin{3:end};
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
  DecType  = 5;
  NsDecB   = 6;
  TbDepth  = 7;
  OpMode   = 8;
  Reset    = 9;

  %*********************************************************************
  % Function:	initialize
  %
  % Description:Set the dialogs up based on the parameter values.
  %		MaskEnables/MaskVisibilities are not saved in reference 
  %		blocks.
  %
  % Inputs:	current block
  %
  % Return Values:	none
  %
  %********************************************************************

  if(strcmp(action,'init'))
      
    cbFbFlags(block,FbFlag,FbTaps);
    cbDecType(block,DecType,NsDecB);
    cbOpMode(block,OpMode,Reset);
      
    s = initWorkSpace(Vals{Reset},En{Reset});
    try,
      if(strcmp(Vals{FbFlag},'Feedforward')),
	trellis = poly2trellis(MemLenArg, GenArg);
      else
	trellis = poly2trellis(MemLenArg, GenArg, FbTapsArg);
      end
      
    catch
      s.status = lasterr;
    end

    if isempty(s.status)
      s = updateWorkSpace(s, trellis);
    end
    varargout{1} = s;
  end;


  %----------------------------------------------------------------------
  %
  %	Dynamic dialog specific field functions
  %
  %----------------------------------------------------------------------

  if(strcmp(action,'cbFbFlag'))
      cbFbFlags(block,FbFlag,FbTaps);      
  end;

  if(strcmp(action,'cbDecType'))
      cbDecType(block,DecType,NsDecB);
  end
  
  if(strcmp(action,'cbOpMode'))
      cbOpMode(block,OpMode,Reset);
  end
  
  %----------------------------------------------------------------------
  %
  %	Setup/Utility functions
  %
  %----------------------------------------------------------------------

  %*********************************************************************
  % Function Name: 'default'
  % Description:   Set the block defaults (development use only)
  % Inputs:	   current block
  % Return Values: none
  %********************************************************************

  if(strcmp(action,'default'))
    
    Cb{MemLen} 	= '';
    Cb{Gen} 	= '';
    Cb{FbFlag}	= [mfilename '(gcb,0,''cbFbFlag'');'];
    Cb{FbTaps}	= '';
    Cb{DecType}	= [mfilename '(gcb,0,''cbDecType'');'];;
    Cb{NsDecB}	= '';
    Cb{TbDepth}	= '';
    Cb{OpMode}  = [mfilename '(gcb,0,''cbOpMode'');'];;
    Cb{Reset}	= '';
    
    En{MemLen}	= 'on';
    En{Gen}	    = 'on';
    En{FbFlag}	= 'on';
    En{FbTaps}	= 'off';
    En{DecType}	= 'on';
    En{NsDecB}	= 'off';
    En{TbDepth}	= 'on';
    En{OpMode}  = 'on';
    En{Reset}	= 'on';
    
    Vis{MemLen}	= 'on';
    Vis{Gen}	= 'on';
    Vis{FbFlag}	= 'on';
    Vis{FbTaps}	= 'on';
    Vis{DecType}= 'on';
    Vis{NsDecB}	= 'on';
    Vis{TbDepth}= 'on';
    Vis{OpMode} = 'on';
    Vis{Reset}	= 'on';
    
    % --- Get the MaskTunableValues 
    Tunable = get_param(block,'MaskTunableValues');
    Tunable{MemLen}  = 'off';
    Tunable{Gen}     = 'off';
    Tunable{FbFlag}  = 'off';
    Tunable{FbTaps}  = 'off';
    Tunable{DecType} = 'off';
    Tunable{NsDecB}  = 'off';
    Tunable{TbDepth} = 'off';
    Tunable{OpMode}  = 'on';
    Tunable{Reset}   = 'off';
    
    % --- Set Callbacks, enable status, visibilities and tunable values
    set_param(block,'MaskCallbacks',     Cb, ...
                    'MaskEnables',       En, ...
                    'MaskVisibilities',  Vis, ...
                    'MaskTunableValues', Tunable);
    
    % --- Set the startup values.''Indicates that the default saved will be used
    Vals{MemLen}  = '7';
    Vals{Gen}     = '[171 133]';
    Vals{FbFlag}  = 'Feedforward';
    Vals{FbTaps}  = '171';
    Vals{DecType} = 'Unquantized';
    Vals{NsDecB}  = '4';
    Vals{TbDepth} = '34';
    Vals{OpMode}  = 'Continuous'
    Vals{Reset}   = 'off';
    
    MN = get_param(gcb,'MaskNames');
    for n=1:length(Vals)
      if(~isempty(Vals{n}))
	set_param(block,MN{n},Vals{n});
      end;
    end;
    
    % --- Update the Vals field with the actual values
    Vals = get_param(block, 'maskvalues');
    
    % --- Ensure that the block operates correctly from a library
    set_param(block,'MaskSelfModifiable','on');
    
  end;
  
  %*********************************************************************
  % Function Name: show all
  % Description:   Show all of the widgets
  % Inputs:	   current block
  % Return Values: none
  % Notes:	   This function is for development use only and allows
  %		   All fields to be displayed
  %
  %********************************************************************
  if(strcmp(action,'showall'))
    ShowAll;
  end;
  
else % new mask
  
  switch nvarargin
   case 0
    action = '';
   case 1
    action  = varargin{2};
    Args    = 0;
   case 2
    action  = varargin{2};
    trellis = varargin{3};
    Args    = 0;
   otherwise
    action = varargin{2};
    Args = varargin{3:end};
  end;
  
  % --- Field data
  Vals	= get_param(block, 'maskvalues');
  Vis	= get_param(block, 'maskvisibilities');
  En  	= get_param(block, 'maskenables');
  
  % --- Field numbers
  Trellis  = 1;
  DecType  = 2;
  NsDecB   = 3;
  TbDepth  = 4;
  OpMode   = 5;
  Reset    = 6;
  
  %*********************************************************************
  % Function:	  initialize
  % Description:  Set the dialogs up based on the parameter values.
  % Inputs:	  current block
  % Return Values: A MATLAB structure
  %
  %********************************************************************
  if(strcmp(action,'init'))
      cbDecType(block,DecType,NsDecB);
      cbOpMode(block,OpMode,Reset);
      s = initWorkSpace(Vals{Reset},En{Reset});
      
      % Do not evaluate/check the parameters if the simulation status is 'stopped'.
      % This is the case when loading a model with the block in it. 
      simStat = get_param(bdroot(gcb),'SimulationStatus');
      if(strcmpi(simStat,'stopped'))
          varargout{1} = s;
          return;
      end;
      
      % --- Check trellis
      s = updateWorkSpace(s, trellis);    
      varargout{1} = s;  
  end;
  
  
  if(strcmp(action,'cbDecType'))
      cbDecType(block,DecType,NsDecB);
  end
  
  if(strcmp(action,'cbOpMode'))
      cbOpMode(block,OpMode,Reset);
  end


  %*********************************************************************
  % Function Name: show all
  % Description:   Show all of the widgets
  % Inputs:	   current block
  % Return Values: none
  % Notes:	   This function is for development use only and allows
  %		   All fields to be displayed
  %
  %********************************************************************
  if(strcmp(action,'showall'))
    ShowAll;
  end;
end;

  %*********************************************************************
  % Function Name:	'cbFbFlag'
  %
  % Description: Deal with the feedforward/feedback mode of operation
  %
  % Inputs: current block
  % Update mode: Args = 0, block update required
  %	         Args = 1, no block update required
  %
  % Return Values:	none
  %
  %********************************************************************
  function cbFbFlags (block,Nfbflag,Nfbtaps)
    Vals  = get_param(block, 'maskvalues');
    En    = get_param(block, 'maskenables');
    oldEn = En{Nfbtaps};
    if(strcmp(Vals{Nfbflag},'Feedforward'))
      En{Nfbtaps}  = 'off';
    else % 'Feedback'
      En{Nfbtaps}  = 'on';
    end;
    if strcmp(oldEn, En{Nfbtaps}) == 0
      set_param(block,'MaskEnables',En);
    end


  %*********************************************************************
  % Function Name: 'cbDecType'
  % Description     Deal with Decision Type field
  % Inputs:	    current block
  % Return Values:  none
  %********************************************************************
  function cbDecType (block,Ndectype,Nnsdec)  
    Vals  = get_param(block, 'maskvalues');
    En    = get_param(block, 'maskenables');
    oldEn = En{Nnsdec};
    if(strcmp(Vals{Ndectype},'Soft Decision'))
      En{Nnsdec}  = 'on';
    else % Unquantized or Hard Decision
      En{Nnsdec}  = 'off';
    end
    if strcmp(oldEn, En{Nnsdec}) == 0
      set_param(block,'maskenables', En);
    end

  
  %*********************************************************************
  % Function Name: 'cbOpMode'
  % Description     Deal with Operation Mode field
  % Inputs:	    current block
  % Return Values:  none
  %********************************************************************
  function cbOpMode (block,Nopmode,Nreset)
    Vals  = get_param(block, 'maskvalues');
    En    = get_param(block, 'maskenables'); 
    OldEn =En{Nreset};
    if(strcmp(Vals{Nopmode},'Continuous'))
        En{Nreset}   = 'on';
    else
        En{Nreset}   = 'off';
    end
    if strcmp(OldEn,En{Nreset}) == 0
        set_param(block,'maskenables', En);
    end
  
%- Helper functions-----------------------------------------------------------
% Create and initialize a workspace structure
function s = initWorkSpace(rst,rstEn)
    s                  = [];
    s.k                = [];
    s.n                = [];
    s.numStates        = [];
    s.nextStates       = [];
    s.outputs          = [];
    s.draw.x           = [];
    s.draw.y           = [];
    s.draw.p           = [];
    s.status           = '';
    
    % --- Drawing vectors
    x = [10 30 10 30 10 NaN 10 30 10 30 10 NaN 30 50 30 50 30 NaN 30 50 30, ...
	 50 30 NaN 50 70 50 70 50 NaN 50 70 50 70 50 NaN 70 90 70 90 70 NaN, ...
	 70 90 70 90 70 NaN];
    y = [95 95 80 65 95 NaN 50 50 65 80 50 NaN 95 95 80 65 95 NaN 50 50 65, ...
	 80 50 NaN 95 95 80 65 95 NaN 50 50 65 80 50 NaN 95 95 80 65 95 NaN, ...
	 50 50 65 80 50 NaN];
    
    % --- Setup port label structure:
    isRst = strcmp(rst,'on') & strcmp(rstEn,'on');
    if isRst,
      p.i1 = 1; p.i1s = 'In'; 
      p.i2 = 2; p.i2s = 'Rst';
    else
      p.i1 = 1; p.i1s = ''; 
      p.i2 = 1; p.i2s = '';
    end
    p.o1 = 1; p.o1s = '';
    
    s.draw.x = x;
    s.draw.y = y;
    s.draw.p = p;
    

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


% Show all fields
function ShowAll()
  Vis = get_param(block, 'maskvisibilities');
  En  = get_param(block, 'maskenables');
  
  Cb = {};
  for n=1:length(Vis)
    Vis{n} = 'on';
    En{n}  = 'on';
    Cb{n}  = '';
  end;
  set_param(block,'MaskVisibilities',Vis, ...
		   'MaskEnables',En,'MaskCallbacks',Cb);

