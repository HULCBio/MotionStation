function hLib = make_iso_tfl

% Copyright 2003 The MathWorks, Inc.

% $Revision $
% $Date: 2004/04/15 00:46:26 $

  hLib = make_ansi_tfl;
  hLib.matFileName = 'iso_tfl_tmw.mat';
  
  updateMathFcn(hLib,'fix'     , 'double', 1, 0, 1, 'trunc',  'double', '<math.h>');
  updateMathFcn(hLib,'rem'     , 'double', 1, 0, 2, 'fmod',   'double', '<math.h>');
  updateMathFcn(hLib,'min'     , 'double', 1, 0, 2, 'fmin',   'double', '<math.h>');
  updateMathFcn(hLib,'max'     , 'double', 1, 0, 2, 'fmax',   'double', '<math.h>');
  updateMathFcn(hLib,'hypot'   , 'double', 1, 0, 2, 'hypot',  'double', '<math.h>');
  %%
  %% --- single datatype
  %%
  updateMathFcn(hLib,'sqrt'    , 'single', 1, 0, 1, 'sqrtf',  'float',  '<math.h>');
  updateMathFcn(hLib,'floor'   , 'single', 1, 0, 1, 'floorf', 'float',  '<math.h>');
  updateMathFcn(hLib,'fmod'     , 'single', 1, 0, 2, 'fmodf',  'float',  '<math.h>');
  updateMathFcn(hLib,'ceil'    , 'single', 1, 0, 1, 'ceilf',  'float',  '<math.h>');  
  updateMathFcn(hLib,'round'   , 'single', 1, 0, 1, 'roundf', 'float',  '<math.h>'); 
  updateMathFcn(hLib,'fix'     , 'single', 1, 0, 1, 'truncf', 'float',  '<math.h>'); 
  updateMathFcn(hLib,'abs'     , 'single', 1, 0, 1, 'fabsf',  'float',  '<math.h>'); 
  updateMathFcn(hLib,'pow'     , 'single', 1, 0, 2, 'powf',   'float',  '<math.h>'); 
  updateMathFcn(hLib,'power'   , 'single', 1, 0, 2, 'powf',   'float',  '<math.h>'); 
  updateMathFcn(hLib,'exp'     , 'single', 1, 0, 1, 'expf',   'float',  '<math.h>'); 
  updateMathFcn(hLib,'ln'      , 'single', 1, 0, 1, 'logf',   'float',  '<math.h>');
  updateMathFcn(hLib,'log'     , 'single', 1, 0, 1, 'logf',   'float',  '<math.h>');
  updateMathFcn(hLib,'log10'   , 'single', 1, 0, 1, 'log10f', 'float',  '<math.h>');
  updateMathFcn(hLib,'rem'     , 'single', 1, 0, 2, 'fmodf',  'float',  '<math.h>');
  updateMathFcn(hLib,'min'     , 'single', 1, 0, 2, 'fminf',  'float',  '<math.h>');
  updateMathFcn(hLib,'max'     , 'single', 1, 0, 2, 'fmaxf',  'float',  '<math.h>');
  updateMathFcn(hLib,'hypot'   , 'single', 1, 0, 2, 'hypotf', 'float',  '<math.h>');
  updateMathFcn(hLib,'sin'     , 'single', 1, 0, 1, 'sinf',   'float',  '<math.h>');
  updateMathFcn(hLib,'cos'     , 'single', 1, 0, 1, 'cosf',   'float',  '<math.h>');
  updateMathFcn(hLib,'tan'     , 'single', 1, 0, 1, 'tanf',   'float',  '<math.h>');
  updateMathFcn(hLib,'asin'    , 'single', 1, 0, 1, 'asinf',  'float',  '<math.h>');
  updateMathFcn(hLib,'acos'    , 'single', 1, 0, 1, 'acosf',  'float',  '<math.h>');
  updateMathFcn(hLib,'atan'    , 'single', 1, 0, 1, 'atanf',  'float',  '<math.h>');
  updateMathFcn(hLib,'atan2'   , 'single', 1, 0, 2, 'atan2f', 'float',  '<math.h>');
  updateMathFcn(hLib,'raw_atan2','single', 1, 0, 2, 'atan2f', 'float',  '<math.h>');
  updateMathFcn(hLib,'sinh'    , 'single', 1, 0, 1, 'sinhf',  'float',  '<math.h>');
  updateMathFcn(hLib,'cosh'    , 'single', 1, 0, 1, 'coshf',  'float',  '<math.h>');
  updateMathFcn(hLib,'tanh'    , 'single', 1, 0, 1, 'tanhf',  'float',  '<math.h>');
  updateMathFcn(hLib,'asinh'   , 'single', 1, 0, 1, 'asinhf', 'float',  '<math.h>');
  updateMathFcn(hLib,'acosh'   , 'single', 1, 0, 1, 'acoshf', 'float',  '<math.h>');
  updateMathFcn(hLib,'atanh'   , 'single', 1, 0, 1, 'atanhf', 'float',  '<math.h>');



function status = updateMathFcn(libH, RTWName, RTWType, nu1, nu2, NumInputs, ImplName, FcnType, HdrFile)

    implH = libH.getFcnImplement(RTWName, RTWType);   
     
    if isempty(implH)
        implH = Simulink.RtwFcnImplementation;
        implH.InDataType = RTWType;
        if  isempty(implH)    
            error('Could not create the implementation');
            return;
        end
        libH.addImplementation(RTWName,implH);        
    end
                         
    implH.ImplementName = ImplName;
    implH.OutDataType = FcnType;
    implH.HeaderFile = HdrFile;
    implH.NumInputs = NumInputs;








