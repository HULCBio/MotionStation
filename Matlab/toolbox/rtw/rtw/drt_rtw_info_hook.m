function varargout = drt_rtw_info_hook(varargin)
% DRT_RTW_INFO_HOOK - Target specific hook file for
% providing RTW the necessary information regarding this
% target.

% Copyright 1994-2002 The MathWorks, Inc.
% $Revision: 1.1 $ $Date: 2002/03/17 02:15:43 $

Action    = varargin{1};
modelName = varargin{2};

switch Action
 case 'wordlengths'
  
  varargout{1} = rtwhostwordlengths(modelName);
  
 case 'cImplementation'
  
  varargout{1} = rtw_host_implementation_props(modelName);
  
 otherwise
  % Properly accommodate future releases of Real-Time Workshop
  varargout = [];
  
end


