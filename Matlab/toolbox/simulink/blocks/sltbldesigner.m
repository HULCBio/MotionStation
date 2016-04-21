function sltbldesigner(varargin)
% SLTBLDESIGNER Simulink Lookup Table Designer dialog. This function will
% be called from Lookup Table Editor dialog.
%
% To use this dialog, MATLAB must have Java Swing supported. 
% See general MATLAB Release Notes for details.
%

%  Jun Wu, Mar. 2001
%  Copyright 1990-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $

lutDesigner = varargin{1};

plotFlag   = false;
closeFlag  = false;

if nargin > 1
  closeFlag  = strcmp(varargin{2}, 'Close');
end

if nargin > 2
  plotFlag = strcmp(varargin{3}, 'Plot');
end

if closeFlag
  return;
end

% data from Designer dialog
lutDesignerSetting.DesignerMode = lutDesigner.getDesignerMode;
lutDesignerSetting.NumDimension = lutDesigner.getNumDims;
lutDesignerSetting.FunctionStr  = char(lutDesigner.getApproxRefFcnStr);
lutDesignerSetting.XMinSet      = getColumnDataSet(lutDesigner, lutDesigner.getColumnIndex('minValue'), true);
lutDesignerSetting.XMaxSet      = getColumnDataSet(lutDesigner, lutDesigner.getColumnIndex('maxValue'), true);
lutDesignerSetting.RelErrMax    = str2num(lutDesigner.getMaxRelErr)/100;
lutDesignerSetting.AbsErrMax    = str2num(lutDesigner.getMaxAbsErr);
lutDesignerSetting.NumPtsMax    = getColumnDataSet(lutDesigner, lutDesigner.getColumnIndex('maxNumBP'), true);
lutDesignerSetting.VarName      = getColumnDataSet(lutDesigner, lutDesigner.getColumnIndex('varName'), false);
lutDesignerSetting.Spacing      = getColumnDataSet(lutDesigner, lutDesigner.getColumnIndex('spacing'), false);

% data propagated from the model
blkHdl = lutDesigner.getLUTOwner.getCurrentBlockHandle;

% run the model to get the compiled data type information
dtSet = {};
try 
  cmdStr = [get_param(bdroot(blkHdl), 'Name'), '([],[],[],''compile'');'];
  eval(cmdStr);
  compiledDT = get_param(blkHdl, 'CompiledPortDataTypes');
  cmdStr = [get_param(bdroot(blkHdl), 'Name'), '([],[],[],''term'');'];
catch
  % update diagram failed for some reason
  disp('Model can not be run. Can''t get input port data type for this LUT block');
end
eval(cmdStr);

lutDesignerSetting.RndMethod = 'Floor';

inportFxpProp = get_fxpprop_from_name(compiledDT.Inport{1});
outportFxpProp = get_fxpprop_from_name(compiledDT.Outport{1});

lutDesignerSetting.XDataType = inportFxpProp.dt;
lutDesignerSetting.XScale    = inportFxpProp.scale;
lutDesignerSetting.YDataType = outportFxpProp.dt;
lutDesignerSetting.YScale    = outportFxpProp.scale;

switch lutDesignerSetting.DesignerMode
 case 0
  % re-design existing table based on block dialog mode
  %disp(' re-design existing table based on block dialog mode...');
  designMode = 'Redesign Table';
  
 case 1
  % re-design existing table based on MATLAB workspace variable mode
  %disp(' re-design existing table based on MATLAB workspace variable mode...');
  designMode = 'Redesign Table';

 case 2
  % re-design existing table based on function mode
  %disp(' re-design existing table based on function mode...');
  designMode = 'Redesign Table';
  
 case 3
  % Function approximation mode
  % disp(['Generate lookup table data for this block to approximate function: ' ...
  %      lutDesignerSetting.FunctionStr]);
  designMode = 'Approximate Function';
  Recompute = 1;
  [xdata, ydata, errWorst] = ...
      look1_func_approx(lutDesignerSetting.FunctionStr, ...
                        lutDesignerSetting.XMinSet(1), ...
                        lutDesignerSetting.XMaxSet(1), ...
                        lutDesignerSetting.XDataType, ...
                        lutDesignerSetting.XScale, ...
                        lutDesignerSetting.YDataType, ...
                        lutDesignerSetting.YScale, ...
                        lutDesignerSetting.RndMethod, ...
                        lutDesignerSetting.AbsErrMax, ...
                        lutDesignerSetting.NumPtsMax(1), ...
                        lutDesignerSetting.VarName, ...
                        lutDesignerSetting.Spacing(1,1:4), ...
                        Recompute);
  
  if plotFlag
    errWorst1 = ...
        look1_func_plot(xdata, ...
                        ydata, ...
                        lutDesignerSetting.FunctionStr, ...
                        lutDesignerSetting.XMinSet(1), ...
                        lutDesignerSetting.XMaxSet(1), ...
                        lutDesignerSetting.XDataType, ...
                        lutDesignerSetting.XScale, ...
                        lutDesignerSetting.YDataType, ...
                        lutDesignerSetting.YScale, ...
                        lutDesignerSetting.RndMethod, ...
                        lutDesignerSetting.VarName);
    assignin('base', 'errworst1', errWorst1);

    disp('finished designing a table, stuck bogus variables in base workspace');
  end
      
  % set data back to LUT Editor
  try
    sltbledit('UpdateFromDesigner', xdata, ydata, lutDesigner.getNumDims);

    appdata     = getappdata(0, 'SLLookupTableEditor');
    selectedBlk = appdata.SelectedBlk;
    
  catch
    % update selected block and/or LUT Editor failed, don't save those data back to the block
  end
  
 otherwise
  disp('No support for this design mode. How do you get here? :-)');
end

useExistBP = 'off';
if lutDesigner.getUseExistBP.isSelected
  useExistBP = 'on';
end
paramValPair = {'LUTDesignTableMode', designMode, ...
                'LUTDesignDataSource', lutDesigner.getDataSrcPopup.getSelectedItem, ...
                'LUTDesignFunctionName', lutDesignerSetting.FunctionStr, ... 
                'LUTDesignUseExistingBP', useExistBP,...
                'LUTDesignRelError', num2str(lutDesignerSetting.RelErrMax), ...
                'LUTDesignAbsError', num2str(lutDesignerSetting.AbsErrMax)};
set_param(selectedBlk, paramValPair{:});

% end sltbldesigner


function data = getColumnDataSet(lutDesigner, idx, isNum)
  
data = [];
for i=1:lutDesigner.getInputTable.getRowCount
  if isNum
    if strcmp('Auto', char(lutDesigner.getInputTable.getValueAt(i-1,idx)))
      data = [data char(lutDesigner.getInputTable.getValueAt(i-1,idx))];
    else
      data = [data str2num(lutDesigner.getInputTable.getValueAt(i-1,idx))];
    end
  else
    data = [data char(lutDesigner.getInputTable.getValueAt(i-1,idx))];
  end
end
