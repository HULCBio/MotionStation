function F = freqresp(this,idx,grade,w)
%FREQRESP   Updates frequency response data.

%  Author(s): P. Gahinet
%  Copyright 1986-2002 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/08 21:05:39 $

F = this.FreqResponse(idx);

% Recompute frequency response if cleared or of insufficient grade
if isempty(F.Magnitude) | F.Grade>grade
   % Initialization
   sys = this.Model(:,:,idx);  % single MIMO LTI model
   
   % Regenerate frequency response data
   if isempty(w) | iscell(w)
      % Grab pole/zero data (zpk model)
      p = getpole(this,idx);
      [z,k] = getzero(this,idx);
      % Generate grid & data
      [mag,phase,w,FocusInfo] = genfresp(sys,grade,w,z,p,k);
   else
      % User-defined grid
      h = permute(freqresp(sys,w),[3 1 2]);
      mag = abs(h);
      phase = unwrap(angle(h));
      focus = [w(1),w(end)];   
      FocusInfo = struct('Range',focus(ones(4,1),:),'Soft',false);
   end
   
   % Store updated data
   F.Frequency = w;
   F.Magnitude = mag; % abs
   F.Phase = phase;   % radians, unwrapped
   F.Grade = grade;
   F.FocusInfo = FocusInfo;
   % REVISIT: 3 -> 1
   FreqResp = this.FreqResponse;
   FreqResp(idx) = F;
   this.FreqResponse = FreqResp;
end

