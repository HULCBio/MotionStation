function setHardwareDevice(hObj, mode, device)

% Copyright 2003 The MathWorks, Inc.
% $Revision: 1.1.6.4 $
  
  if ~isa(hObj, 'Simulink.HardwareCC')
    error('Unknown object');
    return;
  end
  
  deviceInfo = getHardwareConfigs('Type', device);
  if isempty(deviceInfo) | length(deviceInfo) > 1
    error('Incorrect device');
    return;
  end
  
  if strcmp(mode, 'Production')
    set(hObj, 'ProdHWDeviceType', deviceInfo.Type);

    set(hObj, 'ProdBitPerChar', (deviceInfo.Char.Value));
    set(hObj, 'ProdBitPerShort', (deviceInfo.Short.Value));
    set(hObj, 'ProdBitPerInt', (deviceInfo.Int.Value));
    set(hObj, 'ProdBitPerLong', (deviceInfo.Long.Value));
    set(hObj, 'ProdWordSize', (deviceInfo.NatWdSize.Value));
    set(hObj, 'ProdShiftRightIntArith', deviceInfo.SftRht.Value);
    set(hObj, 'ProdIntDivRoundTo', deviceInfo.IntDiv.Value);
    set(hObj, 'ProdEndianess', deviceInfo.Endian.Value);

  elseif strcmp(mode, 'Target')
    set(hObj, 'TargetUnknown', 'off');
    set(hObj, 'ProdEqTarget', 'off');
    set(hObj, 'TargetHWDeviceType', deviceInfo.Type);
    
    set(hObj, 'TargetBitPerChar', (deviceInfo.Char.Value));
    set(hObj, 'TargetBitPerShort', (deviceInfo.Short.Value));
    set(hObj, 'TargetBitPerInt', (deviceInfo.Int.Value));
    set(hObj, 'TargetBitPerLong', (deviceInfo.Long.Value));
    set(hObj, 'TargetWordSize', (deviceInfo.NatWdSize.Value));
    set(hObj, 'TargetShiftRightIntArith', deviceInfo.SftRht.Value);
    set(hObj, 'TargetIntDivRoundTo', deviceInfo.IntDiv.Value);
    set(hObj, 'TargetEndianess', deviceInfo.Endian.Value);
    
  else
    error('Unknow mode');
  end