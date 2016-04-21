function [rectPul,msg] = commblkrectpulse(block,action)
% COMMBLKSQPULSE Ideal Rectangualr pulse block helper function.
%   Usage:
%       [rectPul,msg] = commblkrectpulse(gcb,'action');
%       where action corresponds to one of the following callbacks:
%       cbSampMode, cbNormCheck, or init.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2003/12/01 18:59:36 $


switch(action)
    
    case 'cbSampMode'  % Callback for Sampling Mode
        if strcmp(get_param(block,'sampMode'),'Frame-based')
            % Update check parameter block: FB row vector or scalar
            set_param([block '/Check Signal Attributes'],'Frame', ...
            'Frame-based','Dimensions','Column vector (2-D) or scalar');
            
            % Update Repeater block 
            set_param([block '/Repeat'],'Mode','Maintain input frame rate');
            
            
        else % Sample-based
            % Update check parameter block: 1-D scalar or scalar
            set_param([block '/Check Signal Attributes'],'Frame', ...
            'Sample-based','Dimensions','Scalar (1-D or 2-D)');
            
             % Update Repeater block 
            set_param([block '/Repeat'],'Mode','Maintain input frame size');
        end
        
    case 'cbNormCheck' % Callback for checkCoeff
        %-- Get mask visibilities
        vis = get_param(block,'MaskVisibilities');
                
        %-- Get indexes to mask parameters
        setfieldindexnumbers(block);
        
        %-- Toggle visibilities
        vis{idxNormMode} = get_param(block,'normCheck');
        
        %-- Restore visibilities
        set_param(block,'MaskVisibilities',vis);
        
        
    case 'init'

        %-- Init variables
        msg = [];
        rectPul.pulseLen = 1;
        rectPul.pulseDelay = 0;
        rectPul.gain = 1;
        
        %-- Get block parameters
        setallfieldvalues(block);
        
        %-- Check parameters
        % Pulse Length: Error if empty, nonnumeric, noninteger, vector
        % or less than 1.
        if isempty(maskPulseLen) || ~isnumeric(maskPulseLen) || ...
            ~isinteger(maskPulseLen) || ~isscalar(maskPulseLen) || maskPulseLen<1
            msg = 'Pulse length must be a positive integer number.';
            return
        end
        
        % Pulse Delay: Error if empty, nonnumeric, noninteger, vector
        % or less than 1.
        if isempty(maskPulseDelay) || ~isnumeric(maskPulseDelay) || ...
            ~isinteger(maskPulseDelay) || ~isscalar(maskPulseDelay) || maskPulseDelay<0
            msg = 'Pulse delay must be a nonnegative integer number.';
            return
        end
        
        
        % filterGain: Error if empty, nonnumeric, vector, complex or
        % less than 0.
        if isempty(maskFilterGain) || ~isnumeric(maskFilterGain) ...
            || ~isscalar(maskFilterGain) || ~isreal(maskFilterGain) ...
            || maskFilterGain <=0
            msg = ['Linear amplitude filter gain must be a real ' ...
                'positive scalar.'];
            return
        end
        
        %-- Assign Variables
        rectPul.pulseLen = maskPulseLen;
        rectPul.pulseDelay = maskPulseDelay;
        
        %-- Apply filter gain
        if maskNormCheck % Normalize
            switch maskNormMode
                case 1 % sum of coefficients
                    rectPul.gain = maskFilterGain/maskPulseLen;
                case 2 % filter energy
                    rectPul.gain = maskFilterGain/sqrt(maskPulseLen);
            end
        else % Not normalize
            rectPul.gain = maskFilterGain;
        end
end
%[EOF]
