function GainData = convertgain(CompData,CurFormat,TargetFormat,NormalizedFlag)
%CONVERTGAIN  Updates gain factors to conform with given format.
%
%   GAINDATA = CONVERTGAIN(MODEL,FORMAT1,FORMAT2) returns the gain 
%   sign and magnitude in the target format FORMAT2.  FORMAT1 specifies 
%   the current format (typically MODEL.Format).
%
%   GAINDATA = CONVERTGAIN(MODEL,FORMAT1,FORMAT2,'norm') returns the
%   gain data in the target format FORMAT2 after normalizing MODEL, 
%   i.e., setting MODEL.Gain.Magnitude=1 in the current format FORMAT1.

%   Author(s): P. Gahinet
%   Copyright 1986-2001 The MathWorks, Inc. 
%   $Revision: 1.12 $  $Date: 2001/09/28 21:31:11 $

% RE: CurFormat is the current format, TargetFormat the target format

GainData = CompData.Gain;
if isempty(GainData)
    return
end

% Handle normalized case
if nargin>3
    GainData.Magnitude = 1;  
end

% z for ZeroPoleGain, t for TimeConstant1 and 2.
if ~strcmpi(CurFormat(1), TargetFormat(1))
  % Different formats: perform the transformation
  % Get pole/zero data
  [Z,P] = getpz(CompData);
  if CompData.Ts, % discrete
    P = P-1;   Z = Z-1;
  end
  Gain = GainData.Sign * GainData.Magnitude;
  
  % Convert
  switch lower(TargetFormat(1))
   case 't'
    % zero/pole/gain -> time constant
    Gain = Gain * real(prod(-Z(Z~=0,:)) / prod(-P(P~=0,:)));
   case 'z'
    % time constant -> zero/pole/gain
    Gain = Gain * real(prod(-P(P~=0,:)) / prod(-Z(Z~=0,:)));
  end
  
  % Update values
  GainData.Magnitude = abs(Gain);
  GainData.Sign = sign(Gain) + (~Gain);
end
