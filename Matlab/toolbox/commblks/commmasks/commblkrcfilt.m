function [hFilt,icon,msg] = commblkrcfilt(block,action,varargin)
% COMMBLKRCFILT Raised cosine FIR filter blocks helper function.
%   Usage: 
%       [hFilt,icon,msg] = commblkrcfilt(gcb,'action,'flag');
%       where action corresponds to one of the following callbacks:
%       cbSampMode, cbRateMode cbCheckGain, cbCheckCoeff, CbCopyFcn or init. 
%       and the third parameter can be 'TX', 'RX' or be omitted if not needed.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2003/05/20 11:43:59 $

% Default function: COMMBLKDEF_RCTXFILT, COMMBLKDEF_RCRXFILT

%-- Get type input parameter
if nargin == 3,
    TYPE_TX = strcmp(varargin,'TX');
end

switch(action)   
    
    case 'cbSampMode' % Callback for Sampling Mode
        if strcmp(get_param(block,'sampMode'),'Frame-based')
            % Update check parameter block: FB row vector or scalar
            set_param([block '/Check Signal Attributes'],'Frame',...
                'Frame-based','Dimensions','Column vector (2-D) or scalar');
            % Change settings in filter block
            if TYPE_TX % Tx mode
                set_param([block '/FIR Interpolation'],'framing', ...
                    'Maintain input frame rate');
            else % Rx mode
                set_param([block '/Downsample'],'fmode', ...
                    'Maintain input frame rate');
            end
            
        else % Sample-based
            % Update check parameter block: 1-D scalar or scalar
            set_param([block '/Check Signal Attributes'],'Frame',...
                'Sample-based','Dimensions','Scalar (1-D or 2-D)');
            % Change settings in filter block
            if TYPE_TX % TX mode
                set_param([block '/FIR Interpolation'],'framing', ...
                    'Maintain input frame size');
            else % Rx mode
                set_param([block '/Downsample'],'fmode', ...
                    'Maintain input frame size','smode','Allow multirate');
            end
        end
        
    case 'cbRateMode' % Callback for Rate mode (only in RX mode)
        %-- Get mask visibilities
        vis    = get_param(block,'MaskVisibilities');
        
        %-- Get indexes to mask parameters
        setfieldindexnumbers(block);
        
        %-- Toggle visibility if selected
        if strcmp(get_param(block,'rateMode'),'None') % Downsampling mode
            if strcmp(vis{idxDownFactor},'on')
                [vis{[idxDownFactor idxDownOffset]}] = deal('off');
                set_param(block,'MaskVisibilities',vis);
            end
        else % Filter mode        
            if strcmp(vis{idxDownFactor},'off')
                [vis{[idxDownFactor idxDownOffset]}] = deal('on');
                set_param(block,'MaskVisibilities',vis);    
            end
        end
        
    case 'cbCheckGain' % Callback for checkGain
        %-- Get mask visibilities
        vis = get_param(block,'MaskVisibilities');
        
        %-- Get indexes to mask parameters
        setfieldindexnumbers(block);
        
        %-- Toggle visibility if selected
        if strcmp(get_param(block,'checkGain'),'Normalized') 
            if strcmp(vis{idxFilterGain},'on')
                vis{idxFilterGain} = 'off';
                set_param(block,'MaskVisibilities',vis);    
            end
        else %user-specified option
            if strcmp(vis{idxFilterGain},'off')
                vis{idxFilterGain} = 'on';
                set_param(block,'MaskVisibilities',vis);    
            end
        end      
        
    case 'cbCheckCoeff' % Callback for checkCoeff
        %-- Get mask visibilities
        vis = get_param(block,'MaskVisibilities');
        
        %-- Get indexes to mask parameters
        setfieldindexnumbers(block);
        
        %-- Toggle visibilities
        vis{idxVariableName} = get_param(block,'checkCoeff');
        
        %-- Restore visibilities
        set_param(block,'MaskVisibilities',vis);     
        
    case 'init' % Init callback
        %-- Init variables
        msg = [];
        
        %-- Init filter variables
        hFilt.coeff = ones(1,40);
        hFilt.rateFactor = 1;
        hFilt.downOffset = 0; % Not used in TX mode
        
        %-- Init icon variables
        icon.str = '???';
        icon.x = 0.5;   icon.y=0.25;
        icon.plot = []; icon.xx = 0; 
        
        %-- Get block parameters
        setallfieldvalues(block);
        
        %-- Check parameters
        % D(Group delay): Error if empty, non-numeric, non-integer, vector
        % or less than 1.
        if isempty(maskD) || ~isnumeric(maskD) || ~isinteger(maskD) || ...
                ~isscalar(maskD) || maskD<1 
            msg = 'Group delay must be a positive integer number.';
            return
        end
        
        % R(Rolloff factor): Error if empty, non-numeric, complex, vector or 
        % less than 0 or greater than 1.
        if isempty(maskR) || ~isnumeric(maskR) || ~isscalar(maskR) || ...
                ~isreal(maskR) || maskR<0 || maskR>1 
            msg = 'Rolloff factor must be a real number in the range [0, 1].';
            return
        end
        
        % N(Input samples per symbol): Error if empty, non-numeric, 
        % non-integer, vector or less than 2.
        if isempty(maskN) || ~isnumeric(maskN) || ~isinteger(maskN) || ...
                 ~isscalar(maskN) || maskN<2 
            if TYPE_TX
                msg = ['Upsampling factor (N) must be an integer number '...
                    'greater than 1.'];
            else
                msg = ['Input samples per symbol (N) must be an integer '...
                        'number greater than 1.'];
            end
            return
        end
        
        if not(TYPE_TX) && maskRateMode == 1 % Receive mode    
            % downFactor: Error if empty, non-numeric, non-integer, vector,
            % non-divisor of N, less than 1 or greater than N.
            if isempty(maskDownFactor) || ~isnumeric(maskDownFactor) || ...
                    ~isinteger(maskDownFactor) || ~isscalar(maskDownFactor) ...
                    || mod(maskN,maskDownFactor) || maskDownFactor<1 || ...
                    maskDownFactor>maskN                     
                msg = ['Downsampling factor (L) must be an integer divisor '...
                        'of the Input samples per symbol (N) in the '...
                        'range from 1 to N.'];
                return
            end
            
            % downOffset: Error if empty, non-numeric, non-integer, vector
            % less than 0 or greater than Downsampling factor L-1.
            if isempty(maskDownOffset) || ~isnumeric(maskDownOffset) || ...
                    ~isinteger(maskDownOffset) || ~isscalar(maskDownOffset) ...
                    || maskDownOffset<0 || maskDownOffset>maskDownFactor-1 
                msg = ['Sample offset must be an integer number between 0 ' ...
                        'and L-1, L corresponds to the Downsamplig factor.'];
                return
            end
        end
        
        % filterGain: Error if empty, non-numeric, vector, complex or
        % less than 0.
        if maskCheckGain == 2 % Selected if User-specified option
            if isempty(maskFilterGain) || ~isnumeric(maskFilterGain) ...
                    || ~isscalar(maskFilterGain) || ~isreal(maskFilterGain) ...
                    || maskFilterGain <=0
                msg = ['Linear amplitude filter gain must be a real ' ...
                        'positive scalar.'];
                return
            end
        end
        
        % variableName: Error out if not a MATLAB valid variable name.
        if maskCheckCoeff == 1 % Option selected
            try
                assignin('base',maskVariableName,[]);
            catch
                msg = 'Variable name must be a valid nonempty string.';
                return
            end
        end
        
        %-- Compute filter gain
        gain = 1.0*not(maskCheckGain-1) + maskFilterGain*(maskCheckGain-1);
        
        %-- Design filter using rcosine function from Communications Toolbox
        if(maskFiltType == 1) % Normal Raised Cosine
            hFilt.coeff = rcosine(1, maskN, 'fir/normal', maskR, maskD)*gain;
        else % Square Root Raised Cosine
            hFilt.coeff = rcosine(1, maskN, 'fir/sqrt', maskR, maskD)*gain; 
        end
        
        %-- Assign filter coefficients to workspace (if selected)
        if maskCheckCoeff == 1 
            assignin('base',maskVariableName, hFilt.coeff);
        end
        
        if TYPE_TX % Set upsampling factor
            hFilt.rateFactor = maskN;
        else % Set downsampling factor and phase
            if maskRateMode == 1 
                hFilt.rateFactor = maskDownFactor;
                hFilt.downOffset = maskDownOffset;
            end
        end
        
        %-- Drawn icon 
        icon.str = get_param(block,'filtType');
        icon.plot = hFilt.coeff/max(hFilt.coeff)*0.40+0.50;
        icon.xx = (1:length(hFilt.coeff))/length(hFilt.coeff);        
        
        %-- Cache the updated UserData
        ud = get_param(block,'UserData');
        if isempty(ud)
            % Create new filter
            ud.filter = dfilt.dffir(hFilt.coeff);
        else
            % Update coefficients
            set(ud.filter,'Numerator',hFilt.coeff);
        end
        % Restore values
        set_param(block,'UserData',ud);
        
    case 'cbCopyFcn'
        
        % -- Update variable name if block name ends with scalar index
        if str2num(block(end))+1
            
            %-- Get variable name
            vals = get_param(block,'MaskValues');
            idx = strmatch('variableName',get_param(block,'MaskNames'));
            varName = vals{idx};
            
            %--  Extract digit number from block name
            % double('0') = 48; double('9')=57;
            dBlock = double(block);
            h = and(dBlock>=48,dBlock<=57);     
            hBlock = block(max(find(h==0))+1:end);
            
            %-- Extract digit number from variable name
            dVar = double(varName);
            h = and(dVar>=48,dVar<=57);     
            hVar = varName(1:max(find(h==0)));
            
            %-- Attach index
            vals{idx} = [hVar hBlock];
            
            %Restore mask Values settings
            set_param(block,'MaskValues',vals);
            
        end     
end
%[EOF]