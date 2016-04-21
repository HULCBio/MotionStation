function eStr = commblkerrpatgen(block, action)
%COMMBLKERRPATGEN Mask dynamic dialog function for Error pattern generator block.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/02/14 20:51:26 $

% --- Exit code and error message definitions
eStr.ecode1 = 0;
eStr.ecode2 = 0;
eStr.emsg1  = '';
eStr.emsg2  = '';

% --- Set Field index numbers and mask variable data
setallfieldvalues(block);

if isempty(maskProb) || ismatrix(maskProb) || any(find(maskProb<0)) || any(find(maskProb>1))
   eStr.ecode1 = 1;
   eStr.emsg1  = 'The probabilities parameter must be a scalar or vector of values in the range [0 1].';
   return
end

vLen = [maskN length(maskProb) length(maskSeed)];

%*********************************************************************
% Function:			initialize
% Description:		Set the dialogs up based on the parameter values.
%					MaskEnables/MaskVisibles are not save in reference 
%					blocks.
% Inputs:			current block
% Return Values:	none
%********************************************************************
if(strcmp(action,'init'))

   % --- If the simulation status is 'stopped', then the function is being called
   %     because of an OK or apply and so the parameters do not need to be valid
   %     and hence, need not be evaluated
   simStatus = lower(get_param(bdroot(gcb),'SimulationStatus'));
   if(strcmp(simStatus,'stopped'))
      eStr.ecode = 3;  % Quiet exit
      return;
   end;  
   
   % Check for consistency among vector parameter lengths
   if vLen(2) > vLen(1)
      eStr.ecode2 = 1;
      eStr.emsg2  = 'The length of probabilities parameter must be smaller or equal to the block length parameter.';
      return;
   end

   if sum(maskProb) > 1
      eStr.ecode2 = 1;
      eStr.emsg2  = 'The sum of the probabilities parameter must be less than or equal to 1.';
      return;
   end
   
   cbFrameBased(block);
   cbOrient(block);
end;

if(strcmp(action,'cbFrameBased'))
   cbFrameBased(block);
end

if(strcmp(action,'cbOrient'))
   cbOrient(block);
end

%----------------------------------------------------------------------
%	Dynamic dialog specific field functions
%----------------------------------------------------------------------
%*********************************************************************
% Function Name:	'cbFrameBased'
%  - Callback function for 'frameBased' parameter
%********************************************************************
function cbFrameBased(block)

Vals  = get_param(block, 'maskvalues');
En    = get_param(block, 'maskenables');
oldEnSamp   = En{6};
oldEnOrient = En{7};

if(strcmp(Vals{5},'off'))
    En{6}  = 'off';
    En{7}  = 'on';
else % 'Frame-based'
    En{6}  = 'on';
    En{7}  = 'off';
end;

if strcmp(oldEnSamp, En{6}) == 0 || strcmp(oldEnOrient, En{7}) == 0
    set_param(block,'MaskEnables',En);
end

%*********************************************************************
% Function Name:	'cbOrient'
%  - Callback function for 'orient' parameter
%********************************************************************
function cbOrient(block)

Vals  = get_param(block, 'maskvalues');
En    = get_param(block, 'maskenables');
oldEnFrame = En{5};

if(strcmp(Vals{7},'on'))  % Interpret as 1-D
    En{5}  = 'off';
else
    En{5}  = 'on';
end;

if strcmp(oldEnFrame, En{5}) == 0
    set_param(block,'MaskEnables',En);
end

% [EOF]
