function reset(this,Component)
%RESET  Clears dependent data when model changes.

%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:21:03 $

% REVISIT: Use direct assignments into struct when works
ni = nargin;
ResetTime = (ni==1 || strcmpi(Component(1),'t'));
ResetFreq = (ni==1 || strcmpi(Component(1),'f'));
ResetPZ = (ni==1 || strcmpi(Component(1),'p'));

% Response data
T = this.TimeResponse;
F = this.FreqResponse;
ZPK = this.ZPKData;
for ct=1:getsize(this,3)
   % Reset dynamics data
   if ResetTime
      T(ct).SimSampling = [];
      T(ct).DCGain = [];
   end
   % Reset frequency response data
   if ResetFreq
      F(ct).Magnitude = [];
      F(ct).Phase = [];
      F(ct).MarginInfo = [];
   end
   % Reste dynamics
   if ResetPZ
      ZPK(ct).Zero = [];
      ZPK(ct).Pole = [];
   end
end
this.FreqResponse = F;
this.TimeResponse = T;
this.ZPKData = ZPK;