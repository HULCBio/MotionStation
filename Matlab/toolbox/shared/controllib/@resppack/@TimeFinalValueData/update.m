function update(cd,r)
%UPDATE  Data update method for @TimeFinalValueData class.

%  Author(s): John Glass
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:20:05 $

% Compute final value responses for each of the data objects in the response
if isempty(r.DataSrc)
   % If there is no source do not give a valid DC gain result.
   cd.FinalValue = repmat(NaN,length(r.RowIndex),length(r.ColumnIndex));
else
   % If the response contains a source object compute the DC gain
   cd.FinalValue = dcgain(r.DataSrc,find(r.Data==cd.Parent),r.Context);
end    
