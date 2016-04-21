function UpdateFlag = fillstep(this, r, Tfinal)
%  FILLSTEP  Update data to span the current X-axis range.

%  Author(s): Bora Eryilmaz
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:20:47 $

for ct = 1:length(r.Data)
   UpdateFlag = (r.Data(ct).Time(end) < Tfinal);
   if UpdateFlag
      break;
   end
end

if UpdateFlag
   % Extend step data to Tfinal (REVISIT)
   % RE: Do not call ltisource/step here (alters the focus)
   for ct=1:length(r.Data)
      d = r.Data(ct);
      % Extended time vector
      tvec = d.Time(1):d.Time(2)-d.Time(1):1.5*Tfinal;
      [d.Amplitude,d.Time] = gentresp(this.Model(:,:,ct),'step',tvec);
   end
end
