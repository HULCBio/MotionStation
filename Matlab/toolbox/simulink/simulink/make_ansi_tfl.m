function hLib = make_ansi_tfl

% Copyright 2003-2004 The MathWorks, Inc.

% Create an instance of the UDD Target specific math library

% $Revision $
% $Date: 2004/04/15 00:46:24 $

hLib = Simulink.RtwFcnLib;
hLib.matFileName = 'ansi_tfl_tmw.mat';

add_impl(hLib, 1,'sqrt', 'double', 'sqrt', 'double', '<math.h>','','');
add_impl(hLib, 1,'floor', 'double', 'floor', 'double', '<math.h>','','');
add_impl(hLib, 2,'fmod', 'double', 'fmod', 'double', '<math.h>','','');
add_impl(hLib, 1,'ceil', 'double', 'ceil', 'double', '<math.h>','','');
add_impl(hLib, 1,'abs', 'double', 'fabs', 'double', '<math.h>','','');
add_impl(hLib, 2,'pow', 'double', 'pow', 'double', '<math.h>','','');
add_impl(hLib, 2,'power', 'double', 'pow', 'double', '<math.h>','','');
add_impl(hLib, 1,'exp', 'double', 'exp', 'double', '<math.h>','','');
add_impl(hLib, 2,'ldexp', 'double', 'ldexp', 'double', '<math.h>','','');
add_impl(hLib, 1,'ln', 'double', 'log', 'double', '<math.h>','','');
add_impl(hLib, 1,'log', 'double', 'log', 'double', '<math.h>','','');
add_impl(hLib, 1,'log10', 'double', 'log10', 'double', '<math.h>','','');
add_impl(hLib, 1,'sin', 'double', 'sin', 'double', '<math.h>','','');
add_impl(hLib, 1,'cos', 'double', 'cos', 'double', '<math.h>','','');
add_impl(hLib, 1,'tan', 'double', 'tan', 'double', '<math.h>','','');
add_impl(hLib, 1,'asin', 'double', 'asin', 'double', '<math.h>','','');
add_impl(hLib, 1,'acos', 'double', 'acos', 'double', '<math.h>','','');
add_impl(hLib, 1,'atan', 'double', 'atan', 'double', '<math.h>','','');
add_impl(hLib, 2,'atan2', 'double', 'rt_atan2', 'double', 'rtlibsrc.h','','');
add_impl(hLib, 2,'raw_atan2', 'double', 'atan2', 'double', '<math.h>','','');
add_impl(hLib, 1,'sinh', 'double', 'sinh', 'double', '<math.h>','','');
add_impl(hLib, 1,'cosh', 'double', 'cosh', 'double', '<math.h>','','');
add_impl(hLib, 1,'tanh', 'double', 'tanh', 'double', '<math.h>','','');
add_impl(hLib, 1,'asinh', 'double', 'asinh', 'double', '<math.h>','','');
add_impl(hLib, 1,'acosh', 'double', 'acosh', 'double', '<math.h>','','');
add_impl(hLib, 1,'atanh', 'double', 'atanh', 'double', '<math.h>','','');
add_impl(hLib, 1,'sign', 'double', 'rt_SGN', 'double', 'rtlibsrc.h','','');
add_impl(hLib, 3,'saturate', 'double', 'rt_SATURATE', 'double', 'rtlibsrc.h','','');
add_impl(hLib, 2,'min', 'double', 'rt_MIN', 'double', 'rtlibsrc.h','','');
add_impl(hLib, 2,'max', 'double', 'rt_MAX', 'double', 'rtlibsrc.h','','');
add_impl(hLib, 2,'hypot', 'double', 'rt_hypot', 'double', 'rtlibsrc.h','','');

%% --- single datatype I/O
add_impl(hLib, 1,'sqrt', 'single', 'sqrt', 'double', '<math.h>','','');
add_impl(hLib, 1,'floor', 'single', 'floor', 'double', '<math.h>','','');
add_impl(hLib, 2,'fmod', 'single', 'fmod', 'double', '<math.h>','','');
add_impl(hLib, 1,'ceil', 'single', 'ceil', 'double', '<math.h>','','');
add_impl(hLib, 1,'abs', 'single', 'rt_ABS', 'single', 'rtlibsrc.h','','');
add_impl(hLib, 2,'pow', 'single', 'pow', 'double', '<math.h>','','');
add_impl(hLib, 2,'power', 'single', 'pow', 'double', '<math.h>','','');
add_impl(hLib, 1,'exp', 'single', 'exp', 'double', '<math.h>','','');
add_impl(hLib, 1,'ln', 'single', 'log', 'double', '<math.h>','','');
add_impl(hLib, 1,'log', 'single', 'log', 'double', '<math.h>','','');
add_impl(hLib, 1,'log10', 'single', 'log10', 'double', '<math.h>','','');
add_impl(hLib, 1,'sin', 'single', 'sin', 'double', '<math.h>','','');
add_impl(hLib, 1,'cos', 'single', 'cos', 'double', '<math.h>','','');
add_impl(hLib, 1,'tan', 'single', 'tan', 'double', '<math.h>','','');
add_impl(hLib, 1,'asin', 'single', 'asin', 'double', '<math.h>','','');
add_impl(hLib, 1,'acos', 'single', 'acos', 'double', '<math.h>','','');
add_impl(hLib, 1,'atan', 'single', 'atan', 'double', '<math.h>','','');
add_impl(hLib, 2,'atan2', 'single', 'rt_atan232', 'single', 'rtlibsrc.h','','');
add_impl(hLib, 2,'raw_atan2', 'single', 'atan2', 'double', '<math.h>','','');
add_impl(hLib, 1,'sinh', 'single', 'sinh', 'double', '<math.h>','','');
add_impl(hLib, 1,'cosh', 'single', 'cosh', 'double', '<math.h>','','');
add_impl(hLib, 1,'tanh', 'single', 'tanh', 'double', '<math.h>','','');
add_impl(hLib, 1,'asinh', 'single', 'asinh', 'double', '<math.h>','','');
add_impl(hLib, 1,'acosh', 'single', 'acosh', 'double', '<math.h>','','');
add_impl(hLib, 1,'atanh', 'single', 'atanh', 'double', '<math.h>','','');
add_impl(hLib, 1,'sign', 'single', 'rt_FSGN', 'single', 'rtlibsrc.h','','');
add_impl(hLib, 3,'saturate', 'single', 'rt_SATURATE', 'single', 'rtlibsrc.h','','');
add_impl(hLib, 2,'min', 'single', 'rt_MIN', 'single', 'rtlibsrc.h','','');
add_impl(hLib, 2,'max', 'single', 'rt_MAX', 'single', 'rtlibsrc.h','','');
add_impl(hLib, 2,'hypot', 'single', 'rt_hypot32', 'single', 'rtlibsrc.h','','');

%% --- int32 datatype I/O
add_impl(hLib, 3,'saturate','int32', 'rt_SATURATE', 'int32', 'rtlibsrc.h','','');
add_impl(hLib, 2,'min', 'int32', 'rt_MIN', 'int32', 'rtlibsrc.h','','');
add_impl(hLib, 2,'max', 'int32', 'rt_MAX', 'int32', 'rtlibsrc.h','','');
add_impl(hLib, 1,'abs', 'int32', 'rt_ABS', 'int32', 'rtlibsrc.h','','');
add_impl(hLib, 1,'sign', 'int32', 'rt_SGN', 'int32', 'rtlibsrc.h','','');

%% --- integer datatype I/O
add_impl(hLib, 3,'saturate','integer','rt_SATURATE', 'integer', 'rtlibsrc.h','','');
add_impl(hLib, 2,'min', 'integer', 'rt_MIN', 'integer', 'rtlibsrc.h','','');
add_impl(hLib, 2,'max', 'integer', 'rt_MAX', 'integer', 'rtlibsrc.h','','');
add_impl(hLib, 1,'abs', 'integer', 'rt_ABS', 'integer', 'rtlibsrc.h','','');
add_impl(hLib, 1,'sign', 'integer', 'rt_SGN', 'int32', 'rtlibsrc.h','','');

%% --- int16 datatype I/O
add_impl(hLib, 3,'saturate','int16','rt_SATURATE', 'int16', 'rtlibsrc.h','','');
add_impl(hLib, 2,'min', 'int16', 'rt_MIN', 'int16', 'rtlibsrc.h','','');
add_impl(hLib, 2,'max', 'int16', 'rt_MAX', 'int16', 'rtlibsrc.h','','');
add_impl(hLib, 1,'abs', 'int16', 'rt_ABS', 'int16', 'rtlibsrc.h','','');
add_impl(hLib, 1,'sign', 'int16', 'rt_SGN', 'int16', 'rtlibsrc.h','','');

%% --- int8 datatype I/O
add_impl(hLib, 3,'saturate','int8','rt_SATURATE', 'int8', 'rtlibsrc.h','','');
add_impl(hLib, 2,'min', 'int8', 'rt_MIN', 'int8', 'rtlibsrc.h','','');
add_impl(hLib, 2,'max', 'int8', 'rt_MAX', 'int8', 'rtlibsrc.h','','');
add_impl(hLib, 1,'abs', 'int8', 'rt_ABS', 'int8', 'rtlibsrc.h','','');
add_impl(hLib, 1,'sign', 'int8', 'rt_SGN', 'int8', 'rtlibsrc.h','','');

%% --- uint32 datatype I/O
add_impl(hLib, 3,'saturate','uint32','rt_SATURATE', 'uint32', 'rtlibsrc.h','','');
add_impl(hLib, 2,'min', 'uint32', 'rt_MIN', 'uint32', 'rtlibsrc.h','','');
add_impl(hLib, 2,'max', 'uint32', 'rt_MAX', 'uint32', 'rtlibsrc.h','','');
add_impl(hLib, 1,'abs', 'uint32', 'rt_ABS', 'uint32', 'rtlibsrc.h','','');
add_impl(hLib, 1,'sign', 'uint32', 'rt_UNSGN', 'uint32', 'rtlibsrc.h','','');

%% --- uint16 datatype I/O
add_impl(hLib, 3,'saturate','uint16','rt_SATURATE', 'uint16', 'rtlibsrc.h','','');
add_impl(hLib, 2,'min', 'uint16', 'rt_MIN', 'uint16', 'rtlibsrc.h','','');
add_impl(hLib, 2,'max', 'uint16', 'rt_MAX', 'uint16', 'rtlibsrc.h','','');
add_impl(hLib, 1,'abs', 'uint16', 'rt_ABS', 'uint16', 'rtlibsrc.h','','');
add_impl(hLib, 1,'sign', 'uint16', 'rt_UNSGN', 'uint16', 'rtlibsrc.h','','');

%% --- uint8 datatype I/O
add_impl(hLib, 3,'saturate','uint8','rt_SATURATE', 'uint8', 'rtlibsrc.h','','');
add_impl(hLib, 2,'min', 'uint8', 'rt_MIN', 'uint8', 'rtlibsrc.h','','');
add_impl(hLib, 2,'max', 'uint8', 'rt_MAX', 'uint8', 'rtlibsrc.h','','');
add_impl(hLib, 1,'abs', 'uint8', 'rt_ABS', 'uint8', 'rtlibsrc.h','','');
add_impl(hLib, 1,'sign', 'uint8', 'rt_UNSGN', 'uint8', 'rtlibsrc.h','','');

add_impl(hLib, 1,'initnonfinite', 'double', 'rt_InitInfAndNaN',...
         'double', 'rt_nonfinite.h','genrtnonfinite.tlc','rt_nonfinite');
add_impl(hLib, 1,'rtIsInf', 'double', 'rtIsInf','double', 'rt_nonfinite.h','','');
add_impl(hLib, 1,'rtIsInf', 'single', 'rtIsInfF','float', 'rt_nonfinite.h','','');
add_impl(hLib, 1,'rtIsNaN', 'double', 'rtIsNaN','double', 'rt_nonfinite.h','','');
add_impl(hLib, 1,'rtIsNaN', 'single', 'rtIsNaNF','float', 'rt_nonfinite.h','','');

%
% ====== Constants 
%
% --- double constants
add_const_impl(hLib,'RT_PI', 'double', 'RT_PI', 'double', 'rtlibsrc.h','','');
add_const_impl(hLib,'RT_E', 'double', 'RT_E', 'double', 'rtlibsrc.h','','');
add_const_impl(hLib,'RT_LOG10E', 'double', 'RT_LOG10E', 'double', 'rtlibsrc.h','','');
add_const_impl(hLib,'RT_LN_10', 'double', 'RT_LN_10', 'double', 'rtlibsrc.h','','');

add_const_impl(hLib,'PI', 'double', 'RT_PI', 'double', 'rtlibsrc.h','','');
add_const_impl(hLib,'E', 'double', 'RT_E', 'double', 'rtlibsrc.h','','');
add_const_impl(hLib,'LOG10E', 'double', 'RT_LOG10E', 'double', 'rtlibsrc.h','','');
add_const_impl(hLib,'LN_10', 'double', 'RT_LN_10', 'double', 'rtlibsrc.h','','');
add_const_impl(hLib,'EPS', 'double', 'DBL_EPSILON', 'double', '<float.h>','','');
add_const_impl(hLib,'EPSILON', 'double', 'DBL_EPSILON', 'double', '<float.h>','','');
add_const_impl(hLib,'MAX_VAL', 'double', 'DBL_MAX', 'double', '<float.h>','','');
add_const_impl(hLib,'MIN_VAL', 'double', 'DBL_MIN', 'double', '<float.h>','','');

%% -const_-- single constants
add_const_impl(hLib,'RT_PI', 'single', 'RT_PI', 'double', 'rtlibsrc.h','','');
add_const_impl(hLib,'RT_E', 'single', 'RT_E', 'double', 'rtlibsrc.h','','');
add_const_impl(hLib,'RT_LOG10E', 'single', 'RT_LOG10E', 'double', 'rtlibsrc.h','','');
add_const_impl(hLib,'RT_LN_10', 'single', 'RT_LN_10', 'double', 'rtlibsrc.h','','');

add_const_impl(hLib,'PI', 'single', 'RT_PI', 'double', 'rtlibsrc.h','','');
add_const_impl(hLib,'E', 'single', 'RT_E', 'double', 'rtlibsrc.h','','');
add_const_impl(hLib,'LOG10E', 'single', 'RT_LOG10E', 'double', 'rtlibsrc.h','','');
add_const_impl(hLib,'LN_10', 'single', 'RT_LN_10', 'double', 'rtlibsrc.h','','');
add_const_impl(hLib,'EPS', 'single', 'FLT_EPSILON', 'single', '<float.h>','','');
add_const_impl(hLib,'EPSILON', 'single', 'FLT_EPSILON', 'single', '<float.h>','','');
add_const_impl(hLib,'MAX_VAL', 'single', 'FLT_MAX', 'single', '<float.h>','','');
add_const_impl(hLib,'MIN_VAL', 'single', 'FLT_MIN', 'single', '<float.h>','','');

% Nonfinite constant support.
add_const_impl(hLib,'rtInf', 'double', 'rtInf','double', 'rt_nonfinite.h','','');
add_const_impl(hLib,'rtInf', 'single', 'rtInfF','single', 'rt_nonfinite.h','','');
add_const_impl(hLib,'rtMinusInf', 'double', 'rtMinusInf','double', 'rt_nonfinite.h','','');
add_const_impl(hLib,'rtMinusInf', 'single', 'rtMinusInfF','single', 'rt_nonfinite.h','','');
add_const_impl(hLib,'rtNaN', 'double', 'rtNaN','double', 'rt_nonfinite.h','','');
add_const_impl(hLib,'rtNaN', 'single', 'rtNaNF','single', 'rt_nonfinite.h','','');



function add_impl(hLib,numInpts,name,inDT,implStr,outDT,header,callback,filename)

    impH = Simulink.RtwFcnImplementation;
    impH.InDataType = inDT;
    impH.OutDataType = outDT;
    impH.HeaderFile = header;
    impH.ImplementName = implStr;
    impH.NumInputs = numInpts;
    impH.Type = 'FCN_IMPL_FUNCT';
    impH.genCallback = callback;
    impH.genFileName = filename;
    
    hLib.addImplementation(name,impH);
    
    
function add_const_impl(hLib,name,inDT,implStr,outDT,header,callback,filename)

    impH = Simulink.RtwFcnImplementation;
    impH.InDataType = inDT;
    impH.OutDataType = outDT;
    impH.HeaderFile = header;
    impH.ImplementName = implStr;
    impH.NumInputs = 0;
    impH.Type = 'FCN_IMPL_CONST';
    impH.genCallback = callback;
    impH.genFileName = filename;
    
    hLib.addImplementation(name,impH);
    
    