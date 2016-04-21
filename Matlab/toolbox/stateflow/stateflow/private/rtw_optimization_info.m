function result = rtw_optimization_info(machineName,chartFileNumber,optimProp)

%   Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.7.2.5 $  $Date: 2004/04/15 00:59:11 $
result = [];

try,
	infoStruct = sf('Private','infomatman','load','binary',machineName,'rtw');

	chartNumber = find(infoStruct.chartFileNumbers==chartFileNumber);

	switch(optimProp)
	case 'chart_inlinable'
        result = strcmp(infoStruct.chartInfo(chartNumber).Inline,'Yes');
	case 'instance_optimized_out'
        result = strcmp(infoStruct.chartInfo(chartNumber).InstanceOptimizedOut,'Yes');
	case 'chart_multi_instanced'
        result = strcmp(infoStruct.chartInfo(chartNumber).IsMultiInstanced,'Yes');
	case 'reusable_outputs'
        result = infoStruct.chartInfo(chartNumber).ReusableOutputs;
	case 'expressionable_inputs'
        result = infoStruct.chartInfo(chartNumber).ExpressionableInputs;
	case 'chart_instance_typedef'
        result = infoStruct.chartInfo(chartNumber).InstanceTypedef;
    case 'sfSymbols'
        result = infoStruct.chartInfo(chartNumber).sfSymbols;
	end
catch,
    disp(lasterr);
end
return;

