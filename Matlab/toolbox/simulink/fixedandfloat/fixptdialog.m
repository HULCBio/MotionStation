function fixptdialog(currentBlock)
%FIXPTDIALOG is for internal use only by the Fixed Point Blockset

% Fixed Point Blockset Dynamic Dialog Management

% $Revision: 1.20.2.4 $
%
% Copyright 1994-2004 The MathWorks, Inc.
%

%
% get object parameters
%
G.block      = currentBlock;
G.Names      = get_param(G.block,'MaskNames');
G.Enables    = get_param(G.block,'MaskEnables');
G.Visibles   = get_param(G.block,'MaskVisibilities');
G.Values     = get_param(G.block,'MaskValues');
G.MaskStyles = get_param(G.block,'MaskStyles');

%
% the default is to leave all dialogs visible and enabled
%
for i=1:length(G.Enables)
    G.Enables{i} = 'on';
    G.Visibles{i} = 'on';
end

try
    
  G.maskType = get_param(G.block,'MaskType');
  
  G = commonToAllBlocks_pre(G);
    
  switch G.maskType
  
    case 'Data Type Propagation'
        
        G = handleDataTypePropagationBlock(G);
                
    case 'Sample Time Math'
       
       G = handleSampleTimeMathBlock(G);
       
   case 'Bitwise Operator'

       G = handleBitwiseBlock(G);
         
   otherwise
       
       %handleOtherBlocks;
  end
  
catch
end    
%
% set new enable and visible mask parameters
%
set_param(G.block,'MaskEnables',G.Enables,'MaskVisibilities',G.Visibles);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Begin Sub Function  
%   commonToAllBlocks_pre
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function G = commonToAllBlocks_pre(G_in)    
    %
    G = G_in;
    %
    % case when output data type and scaling are both specified
    % and the output type was able to be evaluated
    %
    [vOutputDataTypeScalingMode,G] = get_param_value(G,'OutputDataTypeScalingMode');
    % 
    if isempty(vOutputDataTypeScalingMode) | isequal(vOutputDataTypeScalingMode,'Specify via dialog')
      %
      [OutDtInfo,G] = get_datatype_class_info(G,'OutDataType');
      %
      if  OutDtInfo.DataTypeDeterminesScaling
        %
        G = param_NOT_visible(G,'LockScale');
        %
        G = param_NOT_visible(G,'ConRadixGroup');
        %
        G = param_NOT_visible(G,'OutScaling');
        %
      elseif OutDtInfo.DataTypeIsFix
        %
        switch G.maskType
          
         case 'Repeating Sequence Stair'
          
          G = handle_best_precision(G, 'ConRadixGroup', 'OutScaling' );
          G = handle_best_precision(G, 'ConRadixGroup', 'LockScale' );
          
        end
      end
      %
      % case when output data type and scaling is inherited
      %   
    else
      %
      G = param_NOT_visible(G,'OutDataType');
      %
      G = param_NOT_visible(G,'ConRadixGroup');
      %
      G = param_NOT_visible(G,'OutScaling');
      %
      G = param_NOT_visible(G,'LockScale');
    end
    %
    [vGainDataTypeScalingMode,G] = get_param_value(G,'GainDataTypeScalingMode');
    
    if isempty(vGainDataTypeScalingMode) | isequal(vGainDataTypeScalingMode,'Specify via dialog')
      %
      [GainDtInfo,G] = get_datatype_class_info(G,'GainDataType');
      %
      if  GainDtInfo.DataTypeDeterminesScaling
        %
        G = param_NOT_visible(G,'VecRadixGroup');
        %
        G = param_NOT_visible(G,'MatRadixGroup');
        %
        G = param_NOT_visible(G,'GainScaling');
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
        switch G.maskType
          
         case 'Weighted Moving Average'
          
          G = handle_best_precision(G, 'MatRadixGroup', 'GainScaling' );
        end
      end
      %
      % case when output data type and scaling is inherited
      %
    else
      %
      G = param_NOT_visible(G,'GainDataType');
      %
      G = param_NOT_visible(G,'VecRadixGroup');
      %
      G = param_NOT_visible(G,'MatRadixGroup');
      %
      G = param_NOT_visible(G,'GainScaling');
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End Sub Function
%   commonToAllBlocks_pre
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Begin Sub Function  
%   handleBitwiseBlock
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function G = handleBitwiseBlock(G_in)
    %
    G = G_in;
    %
    [logicOpIsNOT,G] = get_param_value(G,'logicop','NOT');
    %
    if logicOpIsNOT
       %
       G = param_NOT_enabled(G,'NumInputPorts','1');
       %
       G = param_NOT_enabled(G,'UseBitMask');
       %
       G = param_NOT_visible(G,'BitMask');
       %
       G = param_NOT_visible(G,'BitMaskRealWorld');
    else        
       [UseBitMask,G] = get_param_value(G,'UseBitMask','on');
       %
       if UseBitMask
           %
           G = param_NOT_enabled(G,'NumInputPorts','1');
       else
           %
           G = param_NOT_visible(G,'BitMask');
           %
           G = param_NOT_visible(G,'BitMaskRealWorld');
       end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End Sub Function
%   handleBitwiseBlock
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Begin Sub Function  
%   handleDataTypePropagationBlock
%
% MaskVariables		  
%
%   PropDataTypeMode=@1;
%
%     PropDataType=@2;
%
%     IfRefDouble=@3;
%     IfRefSingle=@4;
%     IsSigned=@5;
%     NumBitsBase=@6;
%     NumBitsMult=@7;
%     NumBitsAdd=@8;
%     NumBitsAllowFinal=@9;
%
%   PropScalingMode=@10;
%
%     PropScaling=@11;
%
%     ValuesUsedBestPrec=@12;
%
%     SlopeBase=@13;
%     SlopeMult=@14;
%     SlopeAdd=@15;
%     BiasBase=@16;
%     BiasMult=@17;
%     BiasAdd=@18;"
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function G = handleDataTypePropagationBlock(G_in)
    %
    G = G_in;
    %
    % find inheritance settings
    %
    [specifyDataType,G] = get_param_value(G,'PropDataTypeMode','Specify via dialog');
    %
    dataTypeGivesScalingToo = 0;
    %
    if specifyDataType
        %
        G = param_NOT_visible(G,'IfRefDouble');
        G = param_NOT_visible(G,'IfRefSingle');
        G = param_NOT_visible(G,'IsSigned');
        G = param_NOT_visible(G,'NumBitsBase');
        G = param_NOT_visible(G,'NumBitsMult');
        G = param_NOT_visible(G,'NumBitsAdd');
        G = param_NOT_visible(G,'NumBitsAllowFinal');
        %
        [PropDtInfo,G] = get_datatype_class_info(G,'PropDataType');
        %
        dataTypeGivesScalingToo = PropDtInfo.DataTypeDeterminesScaling;
    else
        G = param_NOT_visible(G,'PropDataType');
    end
    %%   
    if dataTypeGivesScalingToo
      %
%      G = param_NOT_visible(G,'PropScalingMode');
      G = param_NOT_visible(G,'PropScaling');
      G = param_NOT_visible(G,'ValuesUsedBestPrec');
      G = param_NOT_visible(G,'SlopeBase');
      G = param_NOT_visible(G,'SlopeMult');
      G = param_NOT_visible(G,'SlopeAdd');
      G = param_NOT_visible(G,'BiasBase');
      G = param_NOT_visible(G,'BiasMult');
      G = param_NOT_visible(G,'BiasAdd');
      %
    else
      [specifyPropScalingMode,G]  = get_param_value(G,'PropScalingMode','Specify via dialog');
      %
      [bestprecPropScalingMode,G] = get_param_value(G,'PropScalingMode','Obtain via best precision');
      %
      inheritPropScalingMode = ~( specifyPropScalingMode | bestprecPropScalingMode );
      %
      if inheritPropScalingMode
        %
        G = param_NOT_visible(G,'PropScaling');
        G = param_NOT_visible(G,'ValuesUsedBestPrec');
      else
        %
        G = param_NOT_visible(G,'SlopeBase');
        G = param_NOT_visible(G,'SlopeMult');
        G = param_NOT_visible(G,'SlopeAdd');
        G = param_NOT_visible(G,'BiasBase');
        G = param_NOT_visible(G,'BiasMult');
        G = param_NOT_visible(G,'BiasAdd');
        %    
        if specifyPropScalingMode
            %
            G = param_NOT_visible(G,'ValuesUsedBestPrec');
        else
            G = param_NOT_visible(G,'PropScaling');
        end
      end
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End Sub Function
%   handleDataTypePropagationBlock
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Begin Sub Function  
%   handleSampleTimeMathBlock
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function G = handleSampleTimeMathBlock(G_in)
     %
     G = G_in;
     %
     [mathop,G] = get_param_value(G,'TsampMathOp');
     %
     if strcmp(mathop,'*') | strcmp(mathop,'/')
        %
        [curValue,G] = get_param_value(G,'TsampMathImp','Offline Scaling Adjustment');
        
        if curValue
          %  
          G = param_NOT_enabled(G,'OutputDataTypeScalingMode','Inherit via internal rule');
          %
          G = param_NOT_visible(G,'DoSatur','off');
          %
          G = param_NOT_visible(G,'RndMeth','Floor');
        end
     else
       G = param_NOT_visible(G,'TsampMathImp','Online Calculations');
       %
       if strcmp(mathop,'Ts Only') | strcmp(mathop,'1/Ts Only')
          %
          G = param_NOT_visible(G,'DoSatur','off');
          %
          G = param_NOT_visible(G,'RndMeth','Floor');
       end
     end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End Sub Function
%   handleSampleTimeMathBlock
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Begin Sub Function  
%   param_NOT_visible
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function G = param_NOT_visible(G_in,paramName,paramValue)    
     %
     G = G_in;
     %
     i=find(strcmp(G.Names,paramName));
     if length(i)
         if nargin > 2
            set_param(G.block,paramName,paramValue);       
         end
         G.Visibles{i} = 'off';
     end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End Sub Function
%   param_NOT_visible
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Begin Sub Function  
%   param_NOT_enable
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function G = param_NOT_enabled(G_in,paramName,paramValue)    
     %
     G = G_in;
     %
     i=find(strcmp(G.Names,paramName));
     if length(i)
         if nargin > 2
            set_param(G.block,paramName,paramValue);       
         end
         G.Enables{i} = 'off';
     end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End Sub Function
%   param_NOT_enable
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Begin Sub Function  
%   get_param_value
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [paramValue,G] = get_param_value(G_in,paramName,paramValueToMatch)    
     %
     G = G_in;
     %
     paramValue = [];
     %
     i=find(strcmp(G.Names,paramName));
     %
     if length(i)
         % 
         % Get parameter string from dialog
         % (NOTE: Parameter must be visible)
         %
         maskVisibles = get_param(G.block,'MaskVisibilities');
         if (strcmp(maskVisibles{i}, 'off')) 
            maskVisibles{i} = 'on';
            set_param(G.block,'MaskVisibilities',maskVisibles);
         end
         paramString = get_param(G.block,paramName);       
         %
         % if edit field then param needs to be evaled
         %
         if strcmp('edit',G.MaskStyles{i})
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
                bdr = get_param(bdroot(G.block),'name');
                %
                curParent = get_param(G.block,'parent');
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
     if nargin > 2
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
function [dtInfo,G] = get_datatype_class_info(G_in,paramName)    
     %
     G = G_in;
     %
     dtInfo.DataType                  = [];
     dtInfo.DataTypeDeterminesScaling = 0;
     dtInfo.DataTypeIsFloat           = 0;
     dtInfo.DataTypeIsFix             = 0;
     dtInfo.ImpliedScalingString      = [];
     %
     [dtInfo.DataType,G] = get_param_value(G,paramName);
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
function G = handle_best_precision(G_in,radixGroupParamName,scalingParamName)    
    %
    G = G_in;
    %
    [curValue,G] = get_param_value(G,radixGroupParamName,'Use Specified Scaling');
    %    
    if curValue
      %
      % don't do anything for specified case
      %
      return;
    else
      %
      % hide scaling rather than show invalid scaling
      %
      G = param_NOT_visible(G,scalingParamName);
      return;
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End Sub Function
%  handle_best_precision
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
