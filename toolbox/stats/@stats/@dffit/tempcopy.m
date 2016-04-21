function f2 = tempcopy(f1);
%TEMPCOPY Create a temporary copy of a distfit for saving to a file
%   This is a temporary copy that should not be added to the database.

% $Revision: 1.1.6.2 $  $Date: 2004/01/24 09:32:53 $
% Copyright 2003-2004 The MathWorks, Inc.

% Create a new empty object, not connected to the database
f2 = stats.dffit;
f2 = initdistfit(f2);

% Remove its listeners
f2.listeners = [];

% Copy fields from the original, except the ones listed here
fields = fieldnames(f1);
toskip = {'linehandle'};
for i=1:length(fields)
   if ~ismember(fields{i},toskip)
      set(f2,fields{i},get(f1,fields{i}));
   end
end
