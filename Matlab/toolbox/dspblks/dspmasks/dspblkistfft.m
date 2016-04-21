function varargout = dspblkistfft(varargin)
% DSPBLKDLY Mask dynamic dialog function for inverse STFFT block

% Copyright 1995-2003 The MathWorks, Inc.
% $Date: 2004/04/12 23:06:45 $ $Revision: 1.1.6.2 $

firstArg = varargin{1}; 

if isstr(firstArg)
    action = varargin{1};
else
    action = 'errorfcn';
end
   
switch action
    case 'init'
        % Mask initialization code
        doAssert = varargin{2};
        ovLap    = varargin{3};
        W        = varargin{4};
        cSymm    = varargin{5};
        
        ifftBlk  = [gcb, '/IFFT'];
        
        if doAssert
            isTerminatorPresent = exist_block(gcb, 'Terminator');
            if isTerminatorPresent
            aBlkName = [gcb, '/Terminator'];
            bBlkName = [gcb, '/Window Assert'];
            aBlk     = get_param(aBlkName, 'Handle');
            pos      = get_param(aBlk,'Position');
            if strcmp(get_param(aBlk,'BlockType'), 'Terminator')
                delete_block(aBlk);
                add_block('dspmisc/Window Assert', ...
                    bBlkName, 'Position', pos, 'winsize', 'W', ...
                    'decimat','L','tol','Tol');
            end
            end
        else
            isTerminatorPresent = exist_block(gcb, 'Terminator');
            if ~isTerminatorPresent
            aBlkName = [gcb, '/Window Assert'];
            bBlkName = [gcb, '/Terminator'];
            aBlk     = get_param(aBlkName, 'Handle');
            pos      = get_param(aBlk,'Position');
            if strcmp(get_param(aBlk,'BlockType'), 'SubSystem')
                delete_block(aBlk);
                add_block('built-in/Terminator', ...
                    bBlkName, 'Position', pos);
            end
            end
        end
        
        if cSymm
            set_param(ifftBlk, 'cs_in', 'on');
        else
            set_param(ifftBlk, 'cs_in', 'off');
        end 
        
        varargout = {W-ovLap};
	case 'dynamic'
      % Execute dynamic dialogs 
      doAssert    = get_param(gcb,'DoAssert');
      mask_vis    = get_param(gcb,'maskvisibilities');
      mask_vis{5} = doAssert;
      mask_vis{6} = doAssert;
      set_param(gcb,'maskvisibilities',mask_vis);
  case 'errorfcn'
      disp('In error function');
      err = sllasterror;
      if strcmp(err(1).MessageID, 'SL_AssertionAssert')
          varargout = {'Assertion: Reconstruction error exceeds tolerance'};
      else
          varargout = {err.Message};
      end
          
  otherwise
     error('unhandled case');
end

% -----------------------------------------------
function present = exist_block(sys, name)
try
    present = ~isempty(get_param([sys '/' name], 'BlockType'));
catch
    present = false;
    sllastdiagnostic([]); %reset the last error
end

% end of dspblkistfft.m
