function allowedIntegerSizes = rtw_prodhw_sizes(model)
% RTW_PRODHW_SIZES - returns the integer sizes allowed for the
% production hardware that a Simulink model will be deployed on.
% 
% For example, if the production target is 16 bit micro with 
% 8 bit chars and 32 bit longs, then the output is
%
%    allowedIntegerSizes = [8, 16, 32];
%
% For example, if the production target has unconstrained integer
% sizes, such as when the design will be implemented on an ASIC
% or FPGA, then the output is all fixed-point sizes supported
% by Simulink.
%
%    allowedIntegerSizes = 1:128;
%
% Example
%   rtw_prodhw_sizes('model_name')

% Copyright 1994-2003 The MathWorks, Inc.
% $Revision: 1.1.6.1 $
  
  cs = getActiveConfigSet(model);
  hardware = cs.getComponent('Hardware Implementation');


  devType = lower(get_param(cs,'ProdHWDeviceType'));
  
  asic     = 'asic';
  fpga     = 'fpga';
  unconstr = 'unconstr';
  
  if strncmp(devType,asic,    length(asic    )) || ...
     strncmp(devType,fpga,    length(fpga    )) || ...
     strncmp(devType,unconstr,length(unconstr))
           
    allowedIntegerSizes = 1:128;
  else
    allowedIntegerSizes = sort(double([
        get_param(cs, 'ProdBitPerChar');
        get_param(cs, 'ProdBitPerShort');
        get_param(cs, 'ProdBitPerInt');
        get_param(cs, 'ProdBitPerLong')].'));

    ii = find( diff(allowedIntegerSizes) == 0 );
    
    allowedIntegerSizes(ii)=[];
  end
