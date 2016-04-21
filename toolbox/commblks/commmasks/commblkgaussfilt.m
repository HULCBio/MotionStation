function [hFilt,icon,msg] = commblkgaussfilt(block,action)
% COMMBLKGAUSSFILT Gaussian filter block helper function.
%   Usage: 
%       [hFilt,icon,msg] = commblkgaussfilt(gcb,'flag');
%       where action corresponds to one of the following callbacks:
%       cbSampMode, cbCheckCoeff, CbCopyFcn or init. 
%
%   Reference:
%   [1] Rappaport T.S., Wireless Communications Principles and Practice,  
%   Prentice Hall, 1996

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2003/05/20 11:43:58 $

%-- Init variables
msg = [];

switch(action)   
    
    case 'cbSampMode'  % Callback for Sampling Mode
        if strcmp(get_param(block,'sampMode'),'Frame-based')
            % Update check parameter block: FB row vector or scalar
            set_param([block '/Check Signal Attributes'],'Frame', ...
                'Frame-based','Dimensions','Column vector (2-D) or scalar');    
            
        else % Sample-based
            % Update check parameter block: 1-D scalar or scalar
            set_param([block '/Check Signal Attributes'],'Frame', ...
                'Sample-based','Dimensions','Scalar (1-D or 2-D)');
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
        
    case 'init'
        
        %-- Init variables
        msg = [];
                
        %-- Init filter variables
        hFilt.coeff = ones(1,40);      
        
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
        
        % BT product: Error if empty, non-numeric, non-integer, vector
        % or less than 0
        if isempty(maskBT) || ~isnumeric(maskBT) || ~isscalar(maskBT) ...
                || maskBT<0
            msg = 'BT product must be a positive real number.';
            return
        end
        
        % N(Input samples per symbol): Error if empty, non-numeric, 
        % non-integer, vector or less than 2.
        if isempty(maskN) || ~isnumeric(maskN) || ~isinteger(maskN) || ...
                ~isscalar(maskN) || maskN<1 
            msg = ['Input samples per symbol (N) must be an integer '...
                    'number greater than 0.'];
            return
        end
        
        % filterGain: Error if empty, non-numeric, vector, complex or
        % less than 0.
        if isempty(maskFilterGain) || ~isnumeric(maskFilterGain) ...
            || ~isscalar(maskFilterGain) || ~isreal(maskFilterGain) ...
            || maskFilterGain <=0
            msg = ['Linear amplitude filter gain must be a real ' ...
                'positive scalar.'];
            return
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
        
        %-- Design filter
        % Get axis t
        t = linspace(-maskD,maskD,2*maskD*maskN+1);
        % Compute filter over t
        alpha = sqrt(log(2))/(sqrt(2)*maskBT);
        hFilt.coeff = (sqrt(pi)/alpha)*exp(-(pi^2/alpha^2)*t.^2);
        
        %-- Normalize filter and apply gain
        switch maskNormMode
            case 1
                hFilt.coeff = maskFilterGain*hFilt.coeff/sum(hFilt.coeff);
            case 2
                hFilt.coeff = maskFilterGain*hFilt.coeff/norm(hFilt.coeff,2);
            case 3
                hFilt.coeff = maskFilterGain*hFilt.coeff/max(hFilt.coeff);
        end       
        
        %-- Assign filter coefficients to workspace (if selected)
        if maskCheckCoeff == 1 
            assignin('base',maskVariableName, hFilt.coeff);
        end
        
        %-- Drawn icon 
        icon.str = 'Gaussian';
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