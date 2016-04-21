function sl_unified_lookup2d_dialog(currentBlock)
%FIXPTDIALOG is for internal use only by the Fixed Point Blockset

% Fixed Point Blockset Dynamic Dialog Management

% $Revision: 1.2 $
%
% Copyright 1994-2002 The MathWorks, Inc.
%

globalVarAlreadyUsed = any(strcmp('GFIXPTDIALOG',who('global')));

global GFIXPTDIALOG

if globalVarAlreadyUsed
   globalVar_OrigCopy = GFIXPTDIALOG;
end

%
% get object parameters
%
GFIXPTDIALOG.block      = currentBlock;
GFIXPTDIALOG.Names      = get_param(GFIXPTDIALOG.block,'MaskNames');
GFIXPTDIALOG.Enables    = get_param(GFIXPTDIALOG.block,'MaskEnables');
GFIXPTDIALOG.Visibles   = get_param(GFIXPTDIALOG.block,'MaskVisibilities');
GFIXPTDIALOG.Values     = get_param(GFIXPTDIALOG.block,'MaskValues');
GFIXPTDIALOG.MaskStyles = get_param(GFIXPTDIALOG.block,'MaskStyles');

%
% the default is to leave all dialogs visible and enabled
%
for i=1:(length(GFIXPTDIALOG.Enables)-2)
    GFIXPTDIALOG.Enables{i} = 'on';
    GFIXPTDIALOG.Visibles{i} = 'on';
end
% Last two parameters are not used. They are put in the mask for
% shutting off warnings
GFIXPTDIALOG.Enables{length(GFIXPTDIALOG.Enables)-1} = 'off';
GFIXPTDIALOG.Visibles{length(GFIXPTDIALOG.Enables)-1} = 'off';
GFIXPTDIALOG.Enables{length(GFIXPTDIALOG.Enables)} = 'off';
GFIXPTDIALOG.Visibles{length(GFIXPTDIALOG.Enables)} = 'off';

try
    
  lookup2d_pre;
    
  % set block parameters
  lookup2d_updateparams;
  
catch

end    
%
% set new enable and visible mask parameters
%
set_param(GFIXPTDIALOG.block,'MaskEnables',GFIXPTDIALOG.Enables,'MaskVisibilities',GFIXPTDIALOG.Visibles);

if globalVarAlreadyUsed
   GFIXPTDIALOG = globalVar_OrigCopy;
else
   clear global GFIXPTDIALOG;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Begin Sub Function  
%   commonToAllBlocks_pre
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function lookup2d_updateparams
  %
  global GFIXPTDIALOG
  %  
  maskName = GFIXPTDIALOG.block;
  blockName = [maskName, '/Look-Up Table (2-D)'];

  a = get_param(maskName, 'SettingsModeFixpt');
  set_param(blockName, 'SettingsModeFixpt', a);
  
  a = get_param(maskName, 'LookUpMeth');
  set_param(blockName, 'LookUpMeth', a);  

  a = get_param(maskName, 'OutputDataTypeScalingMode');
  set_param(blockName, 'OutputDataTypeScalingMode', a); 

  %a = get_param(maskName, 'OutDataType');
  %set_param(blockName, 'OutDataType', a); 

  %a = get_param(maskName, 'OutScaling');
  %set_param(blockName, 'OutScaling', a); 

  a = get_param(maskName, 'LockScale');
  set_param(blockName, 'LockScale', a); 

  a = get_param(maskName, 'RndMeth');
  set_param(blockName, 'RndMeth', a);

  a = get_param(maskName, 'DoSatur');  
  set_param(blockName, 'DoSatur', a);  
  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Begin Sub Function  
%   commonToAllBlocks_pre
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function lookup2d_pre    
    %
    global GFIXPTDIALOG
    %
    % show/hide implementation details
    %
    if get_param_value('SettingsModeFixpt', 'off')
        %
        param_NOT_visible('LookUpMeth');
        %
        param_NOT_visible('OutputDataTypeScalingMode');
        %
        param_NOT_visible('OutDataType');
        %
        param_NOT_visible('OutScaling');
        %
        param_NOT_visible('LockScale');
        %
        param_NOT_visible('RndMeth');
        %
        param_NOT_visible('DoSatur');
        %
        param_NOT_visible('SaturateOnIntegerOverflow');
    else
        %
        % case when output data type and scaling are both specified
        % and the output type was able to be evaluated
        %
        vOutputDataTypeScalingMode = get_param_value('OutputDataTypeScalingMode');
    
        if isempty(vOutputDataTypeScalingMode) | isequal(vOutputDataTypeScalingMode,'Specify via dialog')
            %
            OutDtInfo = get_datatype_class_info('OutDataType');
            %
            if  OutDtInfo.DataTypeDeterminesScaling
                %
                param_NOT_visible('LockScale');
                %
                param_NOT_visible('ConRadixGroup');
                %
                param_NOT_visible('OutScaling');
                %
                %
                if OutDtInfo.DataTypeIsFloat
                    %
                    param_NOT_visible('DoSatur');
                    %
                    param_NOT_visible('RndMeth');
                end
                %
            end
        %
        % case when output data type and scaling is inherited
        %   
        else
            %
            param_NOT_visible('OutDataType');
            %
            param_NOT_visible('ConRadixGroup');
            %
            param_NOT_visible('OutScaling');
            %
            param_NOT_visible('LockScale');
        end
        %
        % case when output data type and scaling are both specified
        % and the output type was able to be evaluated
        %
        vGainDataTypeScalingMode = get_param_value('GainDataTypeScalingMode');
        
        if isempty(vGainDataTypeScalingMode) | isequal(vGainDataTypeScalingMode,'Specify via dialog')
            %
            GainDtInfo = get_datatype_class_info('GainDataType');
            %
            if  GainDtInfo.DataTypeDeterminesScaling
                %
                param_NOT_visible('VecRadixGroup');
                %
                param_NOT_visible('MatRadixGroup');
                %
                param_NOT_visible('GainScaling');
                %
            elseif GainDtInfo.DataTypeIsFix
                %
                % goal in this section is to manage "gain" scaling for
                % gain, mgain, and FIR.
                % If one of the best precision modes is on, then
                % our goal is to determine that scaling and to display it,
                % but disabled.  If the same scaling does not apply to
                % all elements of the "gain", then the scaling will
                % be made invisible.
                %  
                switch GFIXPTDIALOG.maskType
    
                  case 'Fixed-Point Gain'
                    
                    handle_best_precision( 'VecRadixGroup', GainDtInfo, 'GainScaling', {'gainval'} );
                        
                  case { 'Fixed-Point Matrix Gain', 'Fixed-Point FIR' }
                  
                    handle_best_precision( 'MatRadixGroup', GainDtInfo, 'GainScaling', {'mgainval'} );
                end
            end
        %
        % case when output data type and scaling is inherited
        %
        else
            %
            param_NOT_visible('GainDataType');
            %
            param_NOT_visible('VecRadixGroup');
            %
            param_NOT_visible('MatRadixGroup');
            %
            param_NOT_visible('GainScaling');
        end
    end
    %
    logicOpIsNOT = get_param_value('logicop','NOT');
    %
    if logicOpIsNOT
       %
       param_NOT_enabled('NumInputPorts','1');
       %
       param_NOT_enabled('UseBitMask','off');
       %
       param_NOT_visible('BitMask');
       %
       param_NOT_visible('BitMaskRealWorld');
    else        
       UseBitMask = get_param_value('UseBitMask','on');
       %
       if UseBitMask
           %
           param_NOT_enabled('NumInputPorts','1');
       else
           %
           param_NOT_visible('BitMask');
           %
           param_NOT_visible('BitMaskRealWorld');
       end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End Sub Function
%   commonToAllBlocks_pre
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Begin Sub Function  
%   param_NOT_visible
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function param_NOT_visible(paramName,paramValue)    
     %
     global GFIXPTDIALOG
     %
     i=find(strcmp(GFIXPTDIALOG.Names,paramName));
     if length(i)
         if nargin > 1
            set_param(GFIXPTDIALOG.block,paramName,paramValue);       
         end
         GFIXPTDIALOG.Visibles{i} = 'off';
     end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End Sub Function
%   param_NOT_visible
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Begin Sub Function  
%   param_NOT_enable
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function param_NOT_enabled(paramName,paramValue)    
     %
     global GFIXPTDIALOG
     %
     i=find(strcmp(GFIXPTDIALOG.Names,paramName));
     if length(i)
         if nargin > 1
            set_param(GFIXPTDIALOG.block,paramName,paramValue);       
         end
         GFIXPTDIALOG.Enables{i} = 'off';
     end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End Sub Function
%   param_NOT_enable
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Begin Sub Function  
%   get_param_value
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function paramValue = get_param_value(paramName,paramValueToMatch)    
     %
     global GFIXPTDIALOG
     %
     paramValue = [];
     %
     i=find(strcmp(GFIXPTDIALOG.Names,paramName));
     %
     if length(i)
         % 
         % Get parameter string from dialog
         % (NOTE: Parameter must be visible)
         %
         maskVisibles = get_param(GFIXPTDIALOG.block,'MaskVisibilities');
         if (strcmp(maskVisibles{i}, 'off')) 
            maskVisibles{i} = 'on';
            set_param(GFIXPTDIALOG.block,'MaskVisibilities',maskVisibles);
         end
         paramString = get_param(GFIXPTDIALOG.block,paramName);       
         %
         % if edit field then param needs to be evaled
         %
         if strcmp('edit',GFIXPTDIALOG.MaskStyles{i})
            %
            % try to eval directly assuming it contains, no
            % references to variables from other workspaces
            %
            paramValue = eval(paramString,'[]');
            %
            if isempty(paramValue)
                %
                % if is empty, then assume direct eval failed
                % because of dependence on variable from some workspace above
                %
                maskAbove = 0;
                %
                bdr = get_param(bdroot(GFIXPTDIALOG.block),'name');
                %
                curParent = get_param(GFIXPTDIALOG.block,'parent');
                %
                while ~strcmp(curParent,bdr)
                   %
                   if hasmask(curParent) == 2
                      %
                      maskAbove = 1;
                      break;
                   end
                   %
                   curParent = get_param(curParent,'parent');
                end
                %
                if ~maskAbove
                    %
                    % no mask above so variables should come from the base 
                    % workspace.
                    %    Cases where variable comes from a workspace above
                    % are too much work to deal with correctly, so the
                    % value will just be treated as empty set, which will
                    % partially disable dynamic dialogs.  The design goal
                    % in these situations is to leave the affected parameters
                    % visible and enabled.
                    %
                    paramValue = evalin('base',paramString,'[]');
                end
            end
         else
            % non edit fields are returned verbatim
            paramValue = paramString;
         end
     end
     %
     if nargin > 1
        %
        paramValue = isequal(paramValue,paramValueToMatch);
     end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End Sub Function
%   get_param_value
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Begin Sub Function  
%   get_datatype_class_info
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dtInfo = get_datatype_class_info(paramName)    
     %
     global GFIXPTDIALOG
     %
     dtInfo.DataType                  = [];
     dtInfo.DataTypeDeterminesScaling = 0;
     dtInfo.DataTypeIsFloat           = 0;
     dtInfo.DataTypeIsFix             = 0;
     dtInfo.ImpliedScalingString      = [];
     %
     dtInfo.DataType = get_param_value(paramName);
     %
     if length(dtInfo.DataType)
        %
        if  any(strcmp(dtInfo.DataType.Class, { 'SINGLE', 'DOUBLE', 'FLOAT', 'INT', 'FRAC' } ))
            %
            dtInfo.DataTypeDeterminesScaling = 1;
            %
            if  any(strcmp(dtInfo.DataType.Class, { 'FRAC' } ))
                %
                dtInfo.ImpliedScalingString = sprintf('2^%d',dtInfo.DataType.GuardBits+dtInfo.DataType.IsSigned-dtInfo.DataType.MantBits);
            else
                dtInfo.ImpliedScalingString = '1';
            end
            %
            if  any(strcmp(dtInfo.DataType.Class, { 'SINGLE', 'DOUBLE', 'FLOAT' } ))
               %
               dtInfo.DataTypeIsFloat = 1;
            end
        else
            if  any(strcmp(dtInfo.DataType.Class, { 'FIX' } ))
               %
               dtInfo.DataTypeIsFix = 1;
            end        
        end
     end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End Sub Function
%   get_datatype_class_info
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Begin Sub Function  
%   handle_best_precision
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function handle_best_precision(radixGroupParamName, dtInfo,scalingParamName,valueParamNameCell)    
    %
    global GFIXPTDIALOG
    %
    if get_param_value(radixGroupParamName,'Use Specified Scaling')
        %
        % don't do anything for specified case
        %
        return;
    end
    %
    maxInitialized = 0;
    %
    for i=1:length(valueParamNameCell)
        %
        curVal = get_param_value(valueParamNameCell{i});
        %
        if isempty(curVal)
            %
            % can't get values so hide scaling rather than show invalid scaling
            %
            param_NOT_visible(scalingParamName);
            return;
        else
            if any(curVal)
                %
                bestFixExpMat = fixptbestexp( curVal, dtInfo.DataType );
                %
                curBestFixExp = max(max(bestFixExpMat));
                %
                if get_param_value(radixGroupParamName,'Best Precision: Element-wise')
                    %
                    curMinFixExp = min(min(bestFixExpMat));
                    %
                elseif get_param_value(radixGroupParamName,'Best Precision: Row-wise')
                    %
                    [nrow,ncol]=size(bestFixExpMat);
                    %
                    if ncol > 1
                       curMinFixExp = min(max(bestFixExpMat.'));
                    else
                       curMinFixExp = min(bestFixExpMat);
                    end
                    %                
                elseif get_param_value(radixGroupParamName,'Best Precision: Column-wise')
                    %
                    [nrow,ncol]=size(bestFixExpMat);
                    %
                    if nrow > 1
                       curMinFixExp = min(max(bestFixExpMat));
                    else
                       curMinFixExp = min(bestFixExpMat);
                    end
                    %                
                else
                    curMinFixExp = curBestFixExp;
                end 
                %
                if maxInitialized == 0
                    %
                    maxInitialized = 1;
                    %
                    bestFixExp = curBestFixExp;
                    %
                    minFixExp  = curMinFixExp;
                else
                    bestFixExp = max(bestFixExp,curBestFixExp);
                    %
                    minFixExp  = max(minFixExp,curMinFixExp);                    
                end
            end 
        end
    end      
    %              
    if maxInitialized == 0
        %
        bestFixExp = -1000;
        %
        minFixExp = bestFixExp;
    end
    %
    scaleStr = sprintf('2^%d',bestFixExp);
    %
    if minFixExp == bestFixExp
        %
        param_NOT_enabled(scalingParamName,scaleStr)
    else
        %
        param_NOT_visible(scalingParamName,scaleStr)
    end    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End Sub Function
%   get_datatype_class_info
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

