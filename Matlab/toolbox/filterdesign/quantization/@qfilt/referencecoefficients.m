function rcoeff = referencecoefficients(Hq)
%REFERENCECOEFFICIENTS  Reference coefficients of a quantized filter.
%   REFERENCECOEFFICIENTS(Hq) returns the value of the REFERENCECOEFFICIENTS
%   property of quantized filter object Hq.  
%
%   The reference coefficients are the unquantized coefficients of the
%   filter.  The quantized coefficients are derived from them.  The
%   coefficients are contained in cell arrays, one cell per section of the
%   filter.  The meaning of the coefficients is dependant on the filter
%   structure:
%
%    Filter structure,  Reference coefficients  
%                       Single Section | Multiple sections
%                'df1', {num,den}      | {{num1,den1},{num2,den2},...}
%               'df1t', {num,den}      | {{num1,den1},{num2,den2},...}
%                'df2', {num,den}      | {{num1,den1},{num2,den2},...}
%               'df2t', {num,den}      | {{num1,den1},{num2,den2},...}
%                'fir', {num}          | {{num1},{num2},...}
%               'firt', {num}          | {{num1},{num2},...}
%       'symmetricfir', {num}          | {{num1},{num2},...}
%   'antisymmetricfir', {num}          | {{num1},{num2},...}
%          'latticear', {k}            | {{k1},{k2},...}
%     'latticeallpass', {k}            | {{k1},{k2},...}
%          'latticema', {k}            | {{k1},{k2},...}
%    'latticemaxphase', {k}            | {{k1},{k2},...}
%          'latticeca', {k1,k2,beta}   | {{k11,k21,beta1},{k12,k22,beta},...}
%        'latticecapc', {k1,k2,beta}   | {{k11,k21,beta1},{k12,k22,beta},...}
%         'statespace', {A,B,C,D}      | {{A1,B1,C1,D1},{A2,B2,C2,D2},...}
%     
%   The default is 'df2t',{1,1}.
%
%   Example:
%     [A,B,C,D] = butter(2,.5);
%     Hq = qfilt('statespace',{A,B,C,D});
%     rcoeff = referencecoefficients(Hq)
%     celldisp(rcoeff)
%
%   See also QFILT, QFILT/GET, QFILT/SET, QFILT/FILTERSTRUCTURE,
%   QFILT/QUANTIZEDCOEFFICIENTS, QFILTCONSTRUCTION.

%   Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.9 $  $Date: 2002/04/14 15:32:11 $

rcoeff = get(Hq,'referencecoefficients');
