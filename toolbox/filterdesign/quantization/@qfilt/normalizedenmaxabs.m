function Hn = normalizedenmaxabs(Hq)
%NORMALIZEDENMAXABS  Normalize quantized filter coefficients.
%   Hn = NORMALIZEDENMAXABS(Hq) returns the quantized filter Hn, which is the
%   same as quantized filter Hq, except that denominator filter coefficients are
%   normalized and Hn.ScaleValues is modified.
%
%   Denominator filter coefficients are normalized such that they are less than
%   or equal to 1 in magnitude. Scale factors are calculated to compensate for
%   the normalization at each filter section input.  This allows the overall
%   filter gain to remain unchanged.  The calculated scale factors are powers of
%   2 and are stored in Hn.ScaleValues.
%
%   You can apply NORMALIZEDENMAXABS to the following filter structures:
%        df1              Direct form I
%        df1t             Direct form I transposed
%        df2              Direct form II
%        df2t             Direct form II transposed
%
%   Example:
%      % You can use NORMALIZEDENMAXABS to prevent overflow of filter coefficients.
%          warning on
%          [b,a] = ellip(5,2,40,0.4);  % Low pass elliptic filter.
%          Hq = qfilt('df2t',{b,a})    % Direct form II transposed quantized filter.
%                                      % Note: Some coefficients have overflowed.
%          Hn = normalizedenmaxabs(Hq)
%
%   See also QFILT, QFILT/GET, QFILT/SET.

%   Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/03/28 20:23:33 $

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
  case {'df1','df1t','df2','df2t'}
   % Only applies to direct-form IIR structures
    if isnumeric(rcoeff{1})
      [rcoeff{2},scales(1)] = dennormalize(rcoeff{2},rmax,scales(1),tol);
    else
      for k=1:length(rcoeff)
        [rcoeff{k}{2},scales(k)] = dennormalize(rcoeff{k}{2},rmax,scales(k),tol);
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
function [den,scale]=dennormalize(den,rmax,scale,tol)
%DENNORMALIZE  Normalize FIR
%   [DEN,SCALE]=DENNORMALIZE(DEN,DEN) normalizes the denominator vector DEN and
%   returns the scale factor SCALE that will scale the output back to unity
%   gain.  The SCALE is always a power of two.

% Exponent for denominator scaling
denexp = coeffexponent(den,tol);
den = den*2^(-denexp);
% Retain previous scaling e.g., so normalize(normalize(Hq))==normalize(Hq).
scale = scale*2^(-denexp);
if max(den(:))>rmax
  % When scaling the denominator alone, it doesn't have a numerator to make up
  % for the additional scaling by rmax, so the denominator is scaled by 1/2 so
  % the scale value can remain a power of two.
  den = den/2;
  scale = scale/2;
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


