function [discrules, type]=rules
%  RULES gets discretization rules.
%  For private use only.
% [DISCRULES, TYPE] = RULES
% DISCRULES - the rules
% TYPE - 0: basic rules + control rules + dsp rules
%        1: basic rules + control rules
%        2: basic rules + dsp rules
%        3: basic rules
%

% $Revision: 1.6.4.2 $ $Date: 2004/04/06 01:10:55 $
% Copyright 1990-2003 The MathWorks, Inc.

% Memory block is discrete now. 
%  {{'BlockType', 'strcmpi', 'Memory'},  'DiscretizeMemory'},...

basicdiscrules = ...
{{{'BlockType', 'strcmpi', 'Integrator'},  'DiscretizeIntegrator'},...
 {{'BlockType', 'strcmpi', 'Sin'},{'SampleTime','<=','0'}, 'DiscretizeSource'},...
 {{'BlockType', 'strcmpi', 'Step'}, 'DiscretizeSource'},...
 {{'BlockType', 'strcmpi', 'RandomNumber'}, 'DiscretizeSource'},...
 {{'BlockType', 'strcmpi', 'UniformRandomNumber'}, 'DiscretizeSource'},...
 {{'BlockType', 'strcmpi', 'FromWorkspace'}, 'DiscretizeSource'},...
 {{'BlockType', 'strcmpi', 'FromFile'}, 'DiscretizeSource'},...
 {{'BlockType', 'strcmpi', 'Clock'} , 'DiscretizeClock'},...
 {{'BlockType', 'strcmpi', 'SignalGenerator'} , 'DiscretizeSignalGenerator'},...
 {{'BlockType', 'strcmpi', 'DiscretePulseGenerator'}, {'PulseType','strcmpi','Time based'}, 'DiscretizePulseGenerator'},...
 {{'MaskType' , 'strcmpi', 'Repeating table'}, 'DiscretizeRepeatingSequence'  },...
 {{'MaskType' , 'strcmpi', 'chirp'}, 'DiscretizeChirp'},...
 {{'MaskType' , 'strcmpi', 'Ramp'}, 'DiscretizeRamp'}...
 {{'BlockType', 'strcmpi', 'TransportDelay'},  'DiscretizeTransportDelay'}
};

controldiscrules = ...
{{{'BlockType', 'strcmpi', 'Derivative'},  'DiscretizeDerivative'},...
 {{'BlockType', 'strcmpi', 'StateSpace'},  'DiscretizeStateSpace'},...
 {{'BlockType', 'strcmpi', 'TransferFcn'},  'DiscretizeTransferFcn'},...
 {{'MaskType',  'strcmpi', 'Transfer Function with Initial States'},  'DiscretizedTransferFcnWithIC'},...
 {{'BlockType', 'strcmpi', 'ZeroPole'}, 'DiscretizeZeroPole'},...
 {{'MaskType',  'strcmpi', 'LTI Block'}, {'MaskWSVariables', 'checkWSVariables','Ts'}, 'DiscretizeLTISystem'},... 
 {{'Mask','strcmpi','on'}, {'MaskType','haselement','Discretized'},{'MaskNames','haselement','method'},{'MaskNames','haselement','SampleTime'},{'MaskNames','haselement','Wc'},'DiscretizeParamMask'}...
};

% dspdiscrules = ...
% {{{'BlockType', 'strcmpi', 'VariableTransportDelay'},  'DiscretizeVarTransportDelay'},...
%  {{'BlockType', 'strcmpi', 'TransportDelay'},  'DiscretizeTransportDelay'}...
% };

dspdiscrules = ...
{{{'BlockType', 'strcmpi', 'VariableTransportDelay'},  'DiscretizeVarTransportDelay'}
};

if(hasControlToolbox)
    if(hasDspBlks)
        discrules = [basicdiscrules controldiscrules dspdiscrules];
        if(nargout == 2)
            type = 0;
        end
    else
        discrules = [basicdiscrules controldiscrules];
        if(nargout == 2)
            type = 1;
        end        
    end
elseif(hasDspBlks)
    discrules = [basicdiscrules dspdiscrules];
    if(nargout == 2)
        type = 2;
    end    
else    
    discrules = basicdiscrules;
    if(nargout == 2)
        type = 3;
    end    
end
    

%end rules

%===============================================================================
% hasControlToolbox
% Check if Control Toolbox is available
%===============================================================================
%
function ret = hasControlToolbox

try
    tf([1], [1 1]);
    ret = 1;
catch
    ret = 0;
end

%end function hasControlToolbox

%===============================================================================
% hasDspBlks
% Check if Dsp Blockset is available
%===============================================================================
%
function ret = hasDspBlks

try
    load_system('dspsigops');
    ret = 1;
catch
    ret = 0;
end
%end function hasDspBlks

%[EOF] rules.m