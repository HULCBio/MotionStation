function t = optimizeunitygains(Hq)
%OPTIMIZEUNITYGAINS  OptimizeUnityGains property of QFILT.
%   OPTIMIZEUNITYGAINS(Hq) returns the value of the OptimizeUnityGains
%   property of quantized filter object Hq.  The value of the
%   OptimizeUnityGains property can be one of the two strings:
%
%     on  - Optimize for coefficients whose real or imaginary part is
%           exactly equal to 1.  Even if 1 cannot be represented by the
%           number format specified by the  CoefficientFormat
%           property, skip multiplications by a real or imaginary
%           part of a coefficient that is equal to 1.
%
%     off - Do not optimize for coefficients whose real or imaginary
%           part is exactly equal to 1.  If 1 cannot be represented
%           by the number format specified by the CoefficientFormat
%           property, then quantize real or imaginary parts of
%           coefficients that are equal to 1 to the next lower quantization level.
%
%   If OptimizeUnityGains is ON, then QUANTIZER(Hq,'coefficient') will return a
%   UNITQUANTIZER object.  If OptimizeUnityGains is OFF, then
%   QUANTIZER(Hq,'coefficient') will return a QUANTIZER object.
%
%   Example:
%     Hq = qfilt;
%     optimizeunitygains(Hq)
%   returns the default 'off'.
%
%   See also QFILT, QFILT/GET, QUANTIZER, UNITQUANTIZER.

%   Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/14 15:31:27 $

t = get(Hq,'optimizeunitygains');
