function status = slproductinstalled(productName)
% slproductinstalled - check whether the license is available for current
% user for the product specified. If it is available, the license is
% checked out
% 
% Some license codes to pass:
%     Simulink_Accelerator
%     Real-Time_Workshop
%     RTW_Embedded_Coder
%
% Return 1 if installed, otherwise return 0.


% Copyright 1994-2003 The MathWorks, Inc.
%
% $Revision: 1.1.6.3 $

try                                                                        
  MpcObj = slprivate('slchecklicense',productName,'quiet');
end                                                                        
if MpcObj == 1                                                             
    status=0;
else
    status=1;
end
