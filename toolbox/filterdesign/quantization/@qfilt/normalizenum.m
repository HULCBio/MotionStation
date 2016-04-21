function Hn = normalizenum(Hq)
%NORMALIZENUM  Normalize numerator such that maximum absolute value is 1.
%   Hn = NORMALIZE(Hq) returns the quantized filter Hn, which is the same as
%   the quantized filter Hq, except that all numerator coefficients are
%   normalized such that the maximum absolute value is 1, and
%   Hn.ScaleValues is modified.  The scale values are calculated to
%   compensate for the normalization at each filter section input.  This
%   allows the overall filter gain to remain unchanged.  The calculated scale
%   factors are powers of 2 and are stored in Hn.ScaleValues.
%
%   You can apply NORMALIZENUM to the following filter structures:
%        df1              Direct form I
%        df1t             Direct form I transposed
%        df2              Direct form II
%        df2t             Direct form II transposed
%        fir              Finite impulse response (FIR)
%        firt             Transposed FIR
%        symmetricfir     Symmetric FIR
%        antisymmetricfir Antisymmetric FIR

%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/03/28 20:23:35 $

fstruc = filterstructure(Hq);
rcoeff = referencecoefficients(Hq);
nsections = numberofsections(Hq);
scales = scalevalues(Hq);
q = coefficientformat(Hq); % Quantizer for coefficients
tol = eps(q);
% Max value for quantizer.  Allow rmax==1 for unitquantizer.
rmax = max(realmax(q),isa(q,'quantum.unitquantizer')); 

% If there are too few scalevalues, fill them in with ones.
scales(length(scales)+1:nsections+1) = ones(1,nsections+1-length(scales));

% If there are too many scale values, trim to the max I'll need.
scales = scales(1:nsections+1);

switch fstruc
 case {'df1','df1t','df2','df2t',...
       'fir','firt','symmetricfir','antisymmetricfir'}
  % Normalize the numerator, which is the same for FIR and IIR.
  if isnumeric(rcoeff{1})
    [rcoeff{1},scales(1)] = firnormalize(rcoeff{1},rmax,scales(1),tol);
  else
    for k=1:length(rcoeff)
      [rcoeff{k}{1},scales(k)] = firnormalize(rcoeff{k}{1},rmax,scales(k),tol);
    end
  end
 otherwise
  % Copying the object may trigger an extraneous warning.
  wrn = warning('off');
  Hn = copyobj(Hq);
  warning(wrn);
  warning(sprintf('Unable to normalize a ''%s'' filter structure.',fstruc));
  return    % Early return
end

% Remove trailing scale values that are all ones because missing scale values
% are skipped rather than multiplied through.
% For example, [2 4 1 1 1] would be clipped to [2 4], and
% [1 1 1 1] would be clipped to [].
temp = dezero(scales-1);
if isempty(temp)
  scales = [];
else
  scales = scales(1:length(temp));
end
set(Hq,'ReferenceCoefficients',rcoeff,'ScaleValues',scales);
Hn = Hq;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [num,scale]=firnormalize(num,rmax,scale,tol)
%FIRNORMALIZE  Normalize FIR
%   [NUM,SCALE]=FIRNORMALIZE(NUM,DEN) normalizes the numerator vector NUM and
%   returns the scale factor SCALE that will scale the output back to unity
%   gain.  The SCALE is always a power of two.

% Exponent for numerator scaling
numexp = coeffexponent(num,tol);
num = num*2^(-numexp);
% Retain previous scaling e.g., so normalize(normalize(Hq))==normalize(Hq).
scale = scale*2^(numexp);
if max(num(:))>rmax
  % FIR filters don't have a denominator to make up for the additional
  % scaling by rmax, so the numerator is scaled by 1/2 so the scale value can
  % remain a power of two.
  num = num/2;
  scale = scale*2;
end

function exponent = coeffexponent(coeff,tol)
% Subtract tol because roundoff in the factorization may cause
% ceil to overdo the scaling if the maximum coefficient is close to
% an exact power of 2.
maxcoeff = max(abs(coeff));
if maxcoeff >= 1 & maxcoeff > tol
  maxcoeff = maxcoeff - tol;
end
exponent = ceil(log2( maxcoeff ));
