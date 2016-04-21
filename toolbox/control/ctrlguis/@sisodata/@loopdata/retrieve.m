function retrieve(LoopData,DesignIndex,InputList)
%RETRIEVE  Retrieves given compensator design.
%
%   See also SISOTOOL.

%   Author(s): P. Gahinet
%   Revised  : Kamesh Subbarao 11-07-2001
%   Copyright 1986-2002 The MathWorks, Inc.
%   $Revision: 1.12 $  $Date: 2002/04/10 04:53:12 $

Design = LoopData.SavedDesigns(DesignIndex);
% Update data
LoopData.Configuration = Design.Configuration;
LoopData.FeedbackSign = Design.FeedbackSign;
ModelList = {'Plant', 'Sensor', 'Filter', 'Compensator'};
ImportList = cell(1,4);
for ct = InputList,
   ImportList{ct} = Design.(ModelList{ct});
end
LoopData.importdata(ImportList{:});

