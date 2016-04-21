function varargout = eq_initmask(block, action, varargin)
% EQ_INITMASK Sets up workspace variables for the Equalizer demo.
%
% This function calls the following functions:
%  - eq_checkparams: to check mask parameters.
%  - eq_getopt: to compute optimim equalizer coefficients.
%  - eq_computecostfcn: to graphically choose initial conditions for equalizer.
%  - eq_mmseconverg: to compute MSE and MMSE for a given equalizer coefficients.
%  - eq_costfcnconverg: to display the equalizer trajectory over the cost func.

% Copyright 1996-2004 The MathWorks, Inc.
% $Revision: 1.1.4.3 $  $Date: 2004/03/24 20:33:07 $

% --- Initialize output parameters, exit code and error message definitions
eStr.emsg  = '';
eStr.emsg_w = '';
varargout{1} = eStr;

% Return if the simulation is running (non-tunable parameters)
if ~any(strcmp(get_param(bdroot(block),'simulationstatus'), ...
        {'stopped','initializing','terminating'}))
    return;
end

%**************************************************************************
% --- Action switch -- Determines which of the callback functions is called
%**************************************************************************
switch(action)
    
    case 'cbEqAlg'
        % Get variables from mask
        En   = get_param(block, 'MaskEnables');
        Vis  = get_param(block, 'MaskVisibilities');
        Vals = get_param(block, 'MaskValues');

        % Set Index to Mask parameters
        setfieldindexnumbers(block);

        % Determine parameter's visibility depending on the selected algorithm
        idxLMS = [idxNumTaps idxStepSize idxLeakage idxSymConst];
        idxNLMS = [idxLMS idxNormalBias];
        idxSLMS = [idxNumTaps idxLeakage idxStepSize idxSymConst];
        idxVSLMS = [idxNumTaps idxLeakage idxMuParIni idxMuParStep ...
            idxMuParMax idxMuParMin idxSymConst];
        idxRLS = [idxNumTaps idxIcCorr idxLambdaPar idxSymConst];
        idxCMA = [idxNumTaps idxStepSize idxLeakage idxSymConstCMA];
        
        % -- Set Visibilities
        switch get_param(block, 'eqAlg') 
            case {'LMS - Least-Mean-Square'}
                [En{[idxNLMS idxSLMS idxVSLMS idxRLS idxCMA]},...
                    Vis{[idxNLMS idxSLMS idxVSLMS idxRLS idxCMA]}] = deal('off');
                [En{idxLMS}, Vis{idxLMS}] = deal('on');

            case {'Sign LMS'}
                [En{[idxNLMS idxVSLMS idxRLS idxCMA]},...
                    Vis{[idxNLMS idxVSLMS idxRLS idxCMA]}] = deal('off');
                [En{idxSLMS}, Vis{idxSLMS}]  = deal('on');

            case {'NLMS - Normalized LMS'}
                [En{[idxSLMS idxVSLMS idxRLS idxCMA]},...
                    Vis{[idxSLMS idxVSLMS idxRLS idxCMA]}] = deal('off');
                [En{idxNLMS}, Vis{idxNLMS}]  = deal('on');

            case {'VSLMS - Variable Step-size LMS'}
                [En{[idxLMS idxSLMS idxNLMS idxRLS idxCMA]},...
                    Vis{[idxLMS idxSLMS idxNLMS idxRLS idxCMA]}]  = deal('off');
                [En{idxVSLMS}, Vis{idxVSLMS}]  = deal('on');

            case {'RLS - Recursive Least-Squares'}
                [En{[idxLMS idxNLMS idxSLMS idxVSLMS idxCMA]}, ...
                    Vis{[idxLMS idxNLMS idxSLMS idxVSLMS idxCMA]}]  = deal('off');
                [En{idxRLS}, Vis{idxRLS}]  = deal('on');

            case {'CMA - Constant Modulus Algorithm'}
                [En{[idxLMS idxNLMS idxSLMS idxVSLMS idxRLS]},...
                    Vis{[idxLMS idxNLMS idxSLMS idxVSLMS idxRLS]}] = deal('off');
                [En{idxCMA}, Vis{idxCMA}]  = deal('on');
        end
        
        %-- Set Symbol constellation parameter: choose between SymConstCMA and
        % SymConst
        if strcmp(Vals{idxEqAlg},'CMA - Constant Modulus Algorithm')
            idx = idxSymConstCMA;
        else
            idx = idxSymConst;
        end
        
        switch(Vals{idx})
            case {'BPSK','QPSK'}
                Vis{idxMconst}  = deal('off');
            otherwise
                Vis{idxMconst}  = deal('on');
        end
                
        %-- Update parameters
        set_param(block,'MaskVisibilities',Vis, 'MaskEnables', En);
        
    case {'cbSymConst','cbSymConstCMA'} % Symbol constellation parameter

        %-- Get variables from mask
        En   = get_param(block, 'MaskEnables');
        Vals = get_param(block, 'MaskValues');
        Vis  = get_param(block, 'MaskVisibilities');

        %-- Set Index to Mask parameters
        setfieldindexnumbers(block);

        %-- Set Symbol constellation parameter: choose between SymConstCMA and
        % SymConst
        if strcmp(Vals{idxEqAlg},'CMA - Constant Modulus Algorithm')
            idx = idxSymConstCMA;
        else
            idx = idxSymConst;
        end
        
        switch(Vals{idx})
            case {'BPSK','QPSK'}
                Vis{idxMconst}  = deal('off');
            otherwise
                Vis{idxMconst}  = deal('on');
        end
        
        %-- Update parameters
        set_param(block, 'MaskEnables', En, 'MaskVisibilities', Vis); 
        
    case 'init' % Initial Settings' Initialization callback
        
        %-- Get Mask values
        setallfieldvalues(block);
        
        %-- Check parameters
        [eStr.emsg, eStr.emsg_w] = eq_checkparams(block);
        varargout{1} = eStr;
        if ~isempty(eStr.emsg)
            return;
        end  
        
        %-- Crop or Extend Initial Conditions
        s = size(maskIcCoeff);
        ic = reshape(maskIcCoeff,max(s),min(s));
        if length(ic)<maskNumTaps % Padd with zeros
            ic = [ic; zeros(maskNumTaps-length(ic),1)];
        else % Crop
            ic = ic(1:maskNumTaps);
        end
                                
        %-- If CMA Equalizer, change switch to decision directed mode
        if maskEqAlg == 6 % 'CMA - Constant Modulus Algorithm'
            str = 'Manual Switch';
            if(~isempty(find_system(bdroot,'Regexp','on','Name',str)))
                set_param([bdroot '/' str],'sw','1');
            end
        end
        
        %-- Compute Optimum values that minimize the MSE
        sigma2S = 1;
        [w_opt, mmse, delta_opt, mu_max] = eq_getopt(maskChCoeff, ...
            maskNumTaps, sigma2S, 10^(-maskSnrdB/10));

        %-- Display results
        if maskDisplayChk == 1 % Check on
            % Display results
            clc
            disp(' ');
            disp(['The optimum equalizer taps that minimize'...
                'the Mean Square Error (MSE) are: ']);
            w_opt
            disp('The minimum Mean Square error is: ');
            mmse
            disp(['The maximum value of the step-size parameter (StepSize)'...
                'that ensures the convergency of the algorithm is: ']);
            mu_max
            disp(' ');
            disp('These variables are stored in the Workspace in eq_opt structure.');
           
            % Assign result variables to base workspace
            eq_opt = struct('taps',w_opt,'mmse',mmse,'mu_max',mu_max); 
            assignin('base','eq_opt',eq_opt);
            
        end
        
        %-- Assign variables into the base Workspace
        %eq = [];
        
        eq.alg = get_param(block,'eqAlg');
        eq.chCoeff = maskChCoeff.';
        eq.snrdB = maskSnrdB;
        eq.numTaps = maskNumTaps;
        eq.ic = ic;
        
        %-- Create constellation
        if maskEqAlg == 6 % CMA case
            symConst = maskSymConstCMA;
        else
            symConst = maskSymConst;
        end
        switch symConst
            case 1 % BPSK
                const = qammod(0:1,2);
            case 2 % QPSK
                const = qammod(0:3,4);
            case 3 % M-PSK
                const = pskmod(0:maskMconst-1,maskMconst);                
            case 4 % M-QAM
                const = qammod(0:maskMconst-1,maskMconst);
        end
        % Normalize and store constellation
        eq.const = const * modnorm(const,'AVPOW',1);
        
        %-- Store parameters depending on the selected equalizer
        switch maskEqAlg
            case {1,2,6} % LMS, sign LMS
                eq.stepSize = maskStepSize; % Initial conditions
                eq.leakage = maskLeakage; % Leakage Factor
            case 3 % N-LMS
                eq.stepSize = maskStepSize; % Initial conditions
                eq.norm = maskNormalBias; % Normalization Factor
                eq.leakage = maskLeakage; % Leakage Factor
            case 4 % VSLMS
                eq.stepSize = maskStepSize; % Initial conditions
                eq.muParIni = maskMuParIni; % muParIni
                eq.muParStep = maskMuParStep; % muParStep
                eq.muParMax = maskMuParMax; % muParMax
                eq.muParMin = maskMuParMin; % muParMin
                eq.leakage = maskLeakage; % Leakage Factor
            case 5 %RLS
                eq.lambda = maskLambdaPar; % Initial conditions
                eq.icCorr = maskIcCorr*eye(maskNumTaps); % IcCorr
        end
        
        % Store result variables
        eq.delta_opt = delta_opt; % Initial conditions
        
        %-- Change Equalizer in Configurable Equalizer block
        str = 'Configurable Subsystem';
        eqNames = {'LMS Linear  Equalizer','Sign LMS Linear  Equalizer', ...
            'Normalized LMS  Linear Equalizer', ...
            'Variable Step LMS  Linear Equalizer', ...
            'RLS Linear  Equalizer','CMA Equalizer'};
        if(~isempty(find_system(bdroot,'Regexp','on','Name',str)))
            set_param([bdroot '/' str],'BlockChoice',eqNames{maskEqAlg});
        end
                            
        %-- Compute Number of points in constellation for Integer Source
        if maskEqAlg == 6 % CMA case
            symConst = maskSymConstCMA;
        else % otherwise
            symConst = maskSymConst;
        end
        switch symConst
            case 1 % BPSK
                eq.MConst = 2; % Constellation order
            case 2 % QPSK
                eq.MConst = 4; % Constellation order
            otherwise
                eq.MConst = maskMconst; % Constellation order
        end
        
        %-- Store struct in base Workspace
        assignin('base','eq',eq);
        
    case 'plotCostFcn' % Open Function callback for "Plot Cost Function" block
        
        %-- Get Mask values
        setallfieldvalues(block);
        Vals = get_param(block, 'MaskValues');
        
        if maskSymConst<2 && maskNumTaps<3
            %-- Plot Cost Function to choose initial conditions
            ic = eq_computecostfcn(maskChCoeff, maskNumTaps, 1, ...
                10^(-maskSnrdB/10), 50, 0.5, Vals{idxEqAlg});
            Vals{idxIcCoeff} = ['[' num2str(ic.') ']'];

            %-- Update parameters
            set_param(block, 'MaskValues', Vals);

        else
            errordlg(['In the Initial Settings dialog box, set the Number of ' ...
                'equalizer coefficients equal to 2 and the Symbol constellation '...
                'to BPSK.']);
        end
            
    case 'plotCostTrajectory' % Model's Stop Function
        
        %-- Get funciton call parameters
        taps = varargin{1};
        tapsRef = varargin{2};
        eq = varargin{3};
        
        %-- Plot MSE Trajectory
        eq_costfcnconverg(taps, tapsRef,1,10^(-eq.snrdB/10),50,25,eq);
               
    case 'CloseFcn' % Model's Close Function
        
        %-- Delete all variables left in the workspace
        evalin('base', 'clear eq taps tapsRef eq_opt');     
        
        %-- Close trajectory window if it is still open
        if findobj(0, 'type', 'figure', 'Name', 'MSE trajectory plot')
            close('MSE trajectory plot');
        end
end    
% [End of eq_initmask.m]
