function hObj = stf2target(name)
% STF2TARGET: Read from the system target file and generate appropriate target component

% Copyright 2002-2003 The MathWorks, Inc.
% $Revision: 1.1.6.4 $
  
  hObj = [];
  
  if isempty(name)
    error(['Empty system target file name.']);
    return;
  end

  % check that rtw is installed
  if ~(exist('rtwprivate')==2 | exist('rtwprivate')==6)
    error(['Unable to create target component from ', ...
          'system target file. The required Real-Time Workshop ', ...
          'components are not available.']);
    return;
  end

  [fullSTFName, fid, prevfpos] = rtwprivate('getstf', [], name);
  if (fid == -1)
    error(['System target file "' name '" cannot be found.']);
    return;
  end
  
  % get the class name for target component from stf if any
  className = rtwprivate('tfile_classname', fid);
  
  closestf(fid, prevfpos);
  
  if ~isempty(className)
    try
      hObj = eval(className);
    end
    
    % a target object must be of Simulink.TargetCC
    if ~isa(hObj, 'Simulink.TargetCC')
      hObj = [];
    end
    
    return;
  end
  
  % we cannot get a class name from stf; then generate a generic target object
  % and fill it with rtwoptions in stf
  hObj = Simulink.STFCustomTargetCC(name);
  