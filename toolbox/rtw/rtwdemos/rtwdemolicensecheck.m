% Copyright 1994-2004 The MathWorks, Inc.
% $Revision: 1.1.4.1 $  $Date: 2004/04/11 00:15:33 $

function str = rtwdemolicensecheck(product) 

  str = '';
  
  switch product
   case 'sfsfc'
    if ~slproductinstalled('Stateflow') || ~slproductinstalled('Stateflow_Coder')
      str = ['You must install Stateflow and Stateflow Coder to run this demonstration.'];
    end
   case 'sp'
    if ~slproductinstalled('Signal_Blocks')
      str = ['You must install Signal Processing Blockset to view this ',...
             'demonstration.'];
    end
   case 'svv'
    if ~slproductinstalled('SL_Verification_Validation')
      str = ['You must install Simulink Verfication and Validation to view this ',...
             'demonstration.'];
    end
   otherwise
    error(['Unknown case: ',product])
  end
  
