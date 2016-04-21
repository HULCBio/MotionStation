function update(cd,r)
%UPDATE  Data update method @StepPeakRespData class

%  Author(s): John Glass
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:19:43 $

% RE: Assumes response data is valid (shorted otherwise)
X = cd.Parent.Time;
Y = cd.Parent.Amplitude;
nrows = length(r.RowIndex);
ncols = length(r.ColumnIndex);

% Compute Peak Response
Time = zeros(nrows, ncols);
PeakData = zeros(nrows, ncols);
OverShoot = repmat(NaN,nrows,ncols);
for ct=1:nrows*ncols
   Yabs = abs(Y(:,ct));
   indMax = find(Yabs==max(Yabs));
   indMax = indMax(end);   % to correctly compute Time for first-order-like systems
   Time(ct) = X(indMax);
   PeakData(ct) = Y(indMax,ct);              
   
   %% Compute the overshoot
   if ~isempty(r.DataSrc) 
      %% Compute DC gain
      DC = dcgain(r.DataSrc,find(r.Data==cd.Parent),r.Context);
      if isinf(DC(ct))
         OverShoot(ct) = NaN;
      elseif DC(ct)==0
         OverShoot(ct) = Inf;
      elseif abs(DC(ct)) > abs(PeakData(ct))
         OverShoot(ct) = 0;
      else
         OverShoot(ct) = 100*(PeakData(ct) - DC(ct))./DC(ct);
      end   
   end    
end

% Update data object
cd.Time = Time;
cd.PeakResponse = PeakData;
cd.OverShoot = OverShoot;    
