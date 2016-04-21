function FF = formatfactor(CompData,TargetFormat)
%FORMATFACTOR  Computes format factor.
%
%   FF = FORMATFACTOR(MODEL) computes the format factor FF that links
%   the formatted gain to the ZPK model gain:
%        ZPK Gain = FF * (Formatted Gain)
%                 = FF * MODEL.Gain.Magnitude * MODEL.Gain.Sign
%
%   FF = FORMATFACTOR(MODEL,FORMAT) computes the format factor FF for
%   the specified format.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.2 $  $Date: 2002/04/10 04:54:49 $

if nargin==1
   TargetFormat = CompData.Format;
end

switch lower(TargetFormat(1))
case 'z'
   % Zero-pole-gain format
   FF = 1;
case 't'
   % Time constant formats
   % Get pole/zero data
   [Z,P] = getpz(CompData);
   if CompData.Ts, % discrete
      P = P-1;   Z = Z-1;
   end
   FF = real(prod(-P(P~=0,:)) / prod(-Z(Z~=0,:)));
end