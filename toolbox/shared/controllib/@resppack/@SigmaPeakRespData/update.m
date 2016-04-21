function update(cd,r)
%UPDATE  Data update method @SigmaPeakRespData class

%  Author(s): John Glass
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:19:27 $


Y = cd.Parent.SingularValues(:,1);

if ~isempty(Y)
	indMax = find(Y == max(Y));
	indMax = indMax(end);
	
	cd.PeakGain = Y(indMax);
	cd.Frequency = cd.Parent.Frequency(indMax);
else
   	cd.PeakGain = NaN;
	cd.Frequency = NaN;
end