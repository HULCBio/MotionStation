function update(cd,r)
%UPDATE  Data update method @FreqPeakGainData class

%  Author(s): John Glass
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:25:22 $

% Get data of parent response
X = cd.Parent.Frequency;  
Mag = cd.Parent.Magnitude;
Ph = cd.Parent.Phase;
nrows = length(r.RowIndex);
ncols = length(r.ColumnIndex);

% Compute Peak Response
Frequency = zeros(nrows, ncols);
PeakGain = zeros(nrows, ncols);
PeakPhase = repmat(NaN,nrows,ncols);
for ct=1:nrows*ncols
   Yabs = Mag(:,ct);
   indMax = find(Yabs==max(Yabs));
   indMax = indMax(end);
   Frequency(ct) = X(indMax);
   PeakGain(ct) = Yabs(indMax);      
   if ~isempty(Ph)
      PeakPhase(ct) = Ph(indMax,ct);
   end
end
cd.Frequency = Frequency;
cd.PeakGain = PeakGain;
cd.PeakPhase = PeakPhase;
