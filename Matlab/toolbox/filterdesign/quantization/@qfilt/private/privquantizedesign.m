function Hq = privquantizedesign(Hq)
%PRIVQUANTIZEDESIGN  Quantize ReferenceCoefficients into QuantizedCoefficients.
%   Hq = PRIVQUANTIZEDESIGN(Hq) where Hq is a quantized filter object computes
%   QuantizedCoefficients from ReferenceCoefficients.  This function also
%   defines the contents of the coefficients logging object field which contains
%   a log of max, mins, overflows and underflows.  This logging information is
%   used by FILTER.
%
%   The real and imaginary parts of complex coefficients are quantized
%   separately.
%
%   PRIVQUANTIZEDESIGN is a private function called by SET whenever the
%   quantizer or coefficient properties are modified.

%   Author: Chris Portal
%   Modified: Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.18 $  $Date: 2002/04/14 15:27:46 $


[qcoefficient,qinput,qoutput,qmultiplicand,qproduct,qsum] = quantizer(Hq,...
    'coefficient','input','output','multiplicand','product','sum');
reset(qcoefficient,qinput,qoutput,qmultiplicand,qproduct,qsum);
coeffs = get(Hq,'referencecoefficients');
bracesadded = 0;
if isnumeric(coeffs{1})
  coeffs = {coeffs};
  bracesadded = 1;
end
nsections = get(Hq,'numberofsections');

% Initialize hqreport
Hq.report = qreportinit(nsections);

warnmode = warning;
warning off
totalnover = 0;
for k=1:nsections
  reset(qcoefficient);
  coeffs{k} = quantize(qcoefficient,coeffs{k});
  Hq.report.coefficient(k) = qreportupdate(Hq.report.coefficient(k),qcoefficient);
  totalnover = totalnover + get(qcoefficient,'nover');
end    
warning(warnmode)

if bracesadded
  coeffs = coeffs{1};
end
Hq.quantizedcoefficients = coeffs;
Hq.overflowmessage='';
if totalnover>0
  if totalnover==1
    Hq.overflowmessage=[num2str(totalnover),...
          ' overflow in coefficients.'];
  else
    Hq.overflowmessage=[num2str(totalnover),...
          ' overflows in coefficients.'];
  end
  warning(Hq.overflowmessage);
end
  
% Check for symmetric coefficients if we modified the FilterStructure to 'symmetricfir'
% or if we modified a property that would change the coefficients while using
% a 'symmetricfir' structure.
% We will warn that coefficients were modified to be symmetric.
% Check all sections.
warnstr='';
struct = Hq.filterstructure;
switch struct
  case {'symmetricfir','antisymmetricfir'}
    rcoeffs = Hq.referencecoefficients;
    qcoeffs = Hq.quantizedcoefficients;
    if isnumeric(rcoeffs{1})
      rcoeffs={rcoeffs}; 
      qcoeffs={qcoeffs};
    end
    for k=1:length(rcoeffs)
      br = rcoeffs{k}{1};
      bq = qcoeffs{k}{1};
      n=length(br);
      % Make symmetric
      br = br([1:ceil(n/2),floor(n/2):-1:1]);
      bq = bq([1:ceil(n/2),floor(n/2):-1:1]);
      s = 'symmetric';
      if strcmpi(struct,'antisymmetricfir')
        % Make antisymmetric
        s = 'antisymmetric';
        br(ceil(n/2+1):end) = -br(ceil(n/2+1):end);
        bq(ceil(n/2+1):end) = -bq(ceil(n/2+1):end);
        if fix(n/2)~=n/2
          % The middle coefficient for odd-length antisymmetric must be 0.
          br(ceil(n/2)) = 0;
          bq(ceil(n/2)) = 0;
        end
      end 
      if ~isequal(br,rcoeffs{k}{1})
        warnstr=['Coefficients have been modified to be ',s,'.'];
      end
      rcoeffs{k}{1} = br;
      qcoeffs{k}{1} = bq;
    end
    if length(rcoeffs)==1 & iscell(rcoeffs{1})
      rcoeffs = rcoeffs{1};
      qcoeffs = qcoeffs{1};
    end
    Hq.referencecoefficients = rcoeffs;
    Hq.quantizedcoefficients = qcoeffs;
end
warning(warnstr)

