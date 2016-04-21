function update(cd,r)
%UPDATE  Data update method @StepSettleTimeData class

%  Author(s): John Glass
%  Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:19:57 $

% RE: Assumes response data is valid (shorted otherwise)
X = cd.Parent.Time;
Y = cd.Parent.Amplitude;
nrows = length(r.RowIndex);
ncols = length(r.ColumnIndex);

SetTimeLims = cd.SettlingTimeThreshold;
Time = zeros(nrows, ncols);
YSettle = zeros(nrows, ncols);

% Get DC gain value
if ~isempty(r.DataSrc)
   % If the response contains a source object compute the DC gain
   DC = dcgain(r.DataSrc,find(r.Data==cd.Parent),r.Context);
else
   % If there is no source do not give a valid DC gain result.
   DC = repmat(NaN,nrows,ncols);
end  

% Compute Settle Time
for ct=1:nrows*ncols
   if isinf(DC(ct))
      Time(ct) = Inf;
      YSettle(ct) = NaN;
   elseif isnan(DC(ct))
      Time(ct) = NaN;
      YSettle(ct) = NaN;
   else
      MaxError = max(abs(Y(:,ct)-DC(ct)));
      NotSettled = find(abs(Y(:,ct)-DC(ct))>SetTimeLims*MaxError);
      if isempty(NotSettled),
         % Direct feedthrough
         Time(ct) = 0;
         YSettle(ct) = Y(1,ct);
      elseif NotSettled(end)==length(Y(:,ct))
         % Not Settled yet
         Time(ct) = NaN;
         YSettle(ct) = DC(ct);
      else   
         idx = NotSettled(end);
         if Y(idx,ct)<DC(ct),
            YSettle(ct) = DC(ct)-SetTimeLims*MaxError;
         else
            YSettle(ct) = DC(ct)+SetTimeLims*MaxError;
         end
         
         if cd.Parent.Ts~=0,
            Time(ct) = X(idx+1);
         else
            Time(ct) = X(idx) + (X(idx+1)-X(idx))/(Y(idx+1,ct)-Y(idx,ct)) ...
               * (YSettle(ct)-Y(idx,ct));
         end    
      end 
   end
end
cd.Time = Time;
cd.YSettle = YSettle;
cd.DCGain = DC;

