function qcoeff = quantizedcoefficients(Hq)
%QUANTIZEDCOEFFICIENTS  Quantized coefficients of a quantized filter.
%   QUANTIZEDCOEFFICIENTS(Hq) returns the value of the QUANTIZEDCOEFFICIENTS
%   property of quantized filter object Hq.  
%
%   The quantized coefficients are the quantized version of the
%   reference coefficients.  They are quantized by the COEFFICIENTFORMAT
%   quantizer.  See the help for REFERENCECOEFFICIENTS for the
%   interpretation of the cell array of coefficients.
%
%   Example:
%     [A,B,C,D] = butter(2,.5);
%     Hq = qfilt('statespace',{A,B,C,D});
%     qcoeff = quantizedcoefficients(Hq)
%     celldisp(qcoeff)
%
%   See also QFILT, QFILT/GET, QFILT/SET, QFILT/FILTERSTRUCTURE,
%   QFILT/REFERENCECOEFFICIENTS, QFILT/COEFFICIENTFORMAT,
%   QFILTCONSTRUCTION. 

%   Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.8 $  $Date: 2002/04/14 15:30:16 $

qcoeff = get(Hq,'quantizedcoefficients');
