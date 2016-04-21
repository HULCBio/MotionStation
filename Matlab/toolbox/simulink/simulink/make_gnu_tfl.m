function hLib = make_gnu_tfl

% Copyright 2003 The MathWorks, Inc.

% $Revision $
% $Date: 2004/04/15 00:46:25 $

  hLib = make_iso_tfl;
  hLib.matFileName = 'gnu_tfl_tmw.mat';
  
  updateMathFcn(hLib,'ten_u', 'double', 1, 0, 1, 'exp10',  'double',  '<math.h>');
  updateMathFcn(hLib,'ten_u', 'single', 1, 0, 1, 'exp10f', 'float',   '<math.h>');

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








