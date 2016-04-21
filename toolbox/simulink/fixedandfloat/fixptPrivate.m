function res = fixptPrivate( action, varargin );
% fixptPrivate This is function for private use by Simulink-Fixed-Point
%              

% Copyright 1994-2003 The MathWorks, Inc.
% $Revision: 1.1.6.1 $  
% $Date: 2003/12/31 19:48:14 $

if strcmp(action,'fhpBestPrecisionQuantizeParts')
  
  value    = varargin{1};
  mantBits = varargin{2};
  isSigned = varargin{3};
  
  Slope  = 0;
  FixExp = 0;
  
  if value ~= 0
    
    fe = fixptbestexp( value, mantBits, isSigned );
    
    value = num2fixpt( value, fixdt(isSigned,mantBits), 2^fe, 'Nearest', 'on' );
    
    if value ~= 0
      
      [Slope,FixExp] = log2(value);
      
      Slope = 2 * Slope;
      
      FixExp = FixExp - 1;
      
    end
  end
  
  res = [Slope FixExp];
  
else
  error('Unknown action');
end
  
