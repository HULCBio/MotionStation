function UpdateFlag = fillresp(this, r, Tfinal)
%FILLRESP  Update data to span the current X-axis range.

%  Author(s): Bora Eryilmaz
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:20:46 $

UpdateFlag = false;
if ~isfield(r.Context,'Type')
   return
else
   RespType = r.Context.Type;   
end

% Check for missing data
for ct = 1:length(r.Data)
   UpdateFlag = (~isempty(r.Data(ct).Amplitude)) && (r.Data(ct).Time(end) < Tfinal);
   if UpdateFlag
      break
   end
end

% Plot-type-specific settings
if UpdateFlag
   switch RespType
   case {'step', 'impulse'}
      x0 = [];
   case 'initial'
      x0 = r.Context.IC;
   end
   
   % Extend data past Tfinal: d.Time(end) > TFinal
   for ct = 1:length(r.Data)
      d = r.Data(ct);
      [d.Amplitude, d.Time] = gentresp(this.Model(:,:,ct), RespType, Tfinal, x0);
   end
end
