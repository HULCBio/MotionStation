function tr=cliptr(tr,epochs)
%CLIPTR Clip training record to the final number of epochs.
%
%  Syntax
%
%    tr = cliptr(tr,epochs)
%
%  Warning!!
%
%    This function may be altered or removed in future
%    releases of the Neural Network Toolbox. We recommend
%    you do not write code which calls this function.

% Mark Beale, 11-31-97
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.7 $

indices = 1:(epochs+1);
names = fieldnames(tr);
for i=1:length(names)
  name = names{i};
  eval(['tr.' name ' = tr.' name '(:,indices);']);
end
