function Tsim = getSimTime(this)
% Computes simulation horizon and time points to hit exactly.

%   $Revision: 1.1.6.6 $ $Date: 2004/04/11 00:46:30 $
%   Copyright 1986-2004 The MathWorks, Inc.
Ts = this.StartTime;
Tf = this.StopTime;

% Get time points to hit exactly
Th = [];
for ct=1:length(this.Specs)
   Th = [Th;getSimTime(this.Specs(ct))];
end

% Form time vector for SIM
Tsim = [Ts ; unique(Th(Th>Ts & Th<Tf)) ; Tf];
