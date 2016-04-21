function evec = getexcluded(ds,outlier)
%GETEXCLUDED Get an exclusion vector for this dataset/oulier combination

%   $Revision: 1.2.2.1 $  $Date: 2004/02/01 21:38:13 $
%   Copyright 2001-2004 The MathWorks, Inc.

if ~isequal(outlier,'(none)') & ~isempty(outlier)
   % For convenience, accept either an outlier name or a handle
   if ischar(outlier)
      outlier = find(getoutlierdb,'name',outlier);
   end
   evec = cfswitchyard('cfcreateexcludevector',ds,outlier);
else
   evec = logical(zeros(length(ds.x),1));
end
