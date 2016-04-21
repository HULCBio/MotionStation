function Hn = normalizedenleading(Hq)
%NORMALIZEDENLEADING  Normalize quantized filter coefficients.
%   Hn = NORMALIZEDENLEADING(Hq) returns the quantized filter Hn, which is the
%   same as quantized filter Hq, except that denominator filter coefficients are
%   normalized and Hn.ScaleValues is modified.
%
%   Denominator filter coefficients are normalized such that the leading
%   denominator coefficient is 1. Scale factors are calculated to compensate for
%   the normalization at each filter section input.  This allows the overall
%   filter gain to remain unchanged.  The calculated scale factors are stored
%   in Hn.ScaleValues.
%
%   You can apply NORMALIZEDENLEADING to the following filter structures:
%        df1              Direct form I
%        df1t             Direct form I transposed
%        df2              Direct form II
%        df2t             Direct form II transposed
%
%   Example:
%          w = warning('on');
%          [b,a] = ellip(5,2,40,0.4);  % Low pass elliptic filter.
%          Hq = qfilt('df2t',{b,a})    % Direct form II transposed quantized filter.
%                                      % Note: Some coefficients have overflowed.
%          Hn = normalizedenleading(Hq)
%          warning(w);
%
%   See also QFILT, QFILT/GET, QFILT/SET.

%   Thomas A. Bryan
%   Copyright 1999-2003 The MathWorks, Inc.
%   $Revision: 1.1.4.2 $  $Date: 2004/04/12 23:25:14 $

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
%   [DEN,SCALE]=DENNORMALIZE(DEN,DEN) normalizes the denominator vector DEN such
%   that DEN(1)=1 and returns the scale factor SCALE that will scale the output
%   back to unity gain.  The SCALE is always a power of two.

scale = 1/den(1);
den = den/den(1);
