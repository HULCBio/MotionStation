function update(cd,r)
%UPDATE  Data update method @StepRiseTimeData class

%   Author(s): John Glass
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:19:49 $

% RE: Assumes response data is valid (shorted otherwise)
X = cd.Parent.Time;
Y = cd.Parent.Amplitude;
nrows = length(r.RowIndex);
ncols = length(r.ColumnIndex);

% Initialize arrays
THigh = zeros(nrows, ncols);
TLow = zeros(nrows, ncols);
Amplitude = zeros(nrows, ncols);

% DC gain
if ~isempty(r.DataSrc)
   % If the response contains a source object compute the DC gain
   DC = dcgain(r.DataSrc,find(r.Data==cd.Parent),r.Context);
else
   % If there is no source do not give a valid DC gain result.
   DC = repmat(NaN,nrows,ncols);
end  

% Compute Rise Time
RiseTimeLims = cd.RiseTimeLimits;
for ct=1:nrows*ncols
   if isinf(DC(ct)) | isnan(DC(ct))
      TLow(ct) = Inf;            
      THigh(ct) = Inf;
      Amplitude(ct) = NaN;
   else
      Y0 = Y(1,ct);  % initial value
      Y1 = Y0 + RiseTimeLims(1)*(DC(ct)-Y0);  % lower threshold line
      Y2 = Y0 + RiseTimeLims(2)*(DC(ct)-Y0);  % upper threshold line
      % Find first crossing for each threshold line
      Npts = length(Y(:,ct));
      IndStart = find((Y(1:Npts-1,ct)-Y1).*(Y(2:Npts,ct)-Y1)<=0);
      IndEnd = find((Y(1:Npts-1,ct)-Y2).*(Y(2:Npts,ct)-Y2)<=0);
      % Get time of first crossing
      if isempty(IndStart),
         % Has not yet reached RiseTimeLims(1) level
         X1 = NaN;
      else
         idx = IndStart(1);
         if Y(idx,ct)==Y(idx+1,ct),
            X1 = X(idx);
         elseif cd.Parent.Ts~=0
            X1 = X(idx+1);
         else 
            X1 = X(idx) + (X(idx+1)-X(idx))/(Y(idx+1,ct)-Y(idx,ct)) * (Y1-Y(idx,ct));
         end
      end
      % Get time of second crossing
      if isempty(IndEnd),
         % Has not yet reached RiseTimeLims(2) level
         X2 = NaN;
      else
         idx = IndEnd(1);
         if Y(idx,ct)==Y(idx+1,ct),
            X2 = X(idx);
         elseif cd.Parent.Ts~=0
            X2 = X(idx+1);
         else
            X2 = X(idx) + (X(idx+1)-X(idx))/(Y(idx+1,ct)-Y(idx,ct)) * (Y2-Y(idx,ct));
         end
      end
      TLow(ct) = X1;
      THigh(ct) = X2;
      Amplitude(ct) = Y2;
   end
end
cd.THigh = THigh;
cd.Amplitude = Amplitude;
cd.TLow = TLow;
