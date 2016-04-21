function [y,cens,freq] = getincludeddata(ds,outlier)
%GETINCLUDEDDATA Get data vectors after applying an exclusion rule

%   $Revision: 1.1.6.3 $  $Date: 2004/01/24 09:32:33 $
%   Copyright 2003-2004 The MathWorks, Inc.

% Get all data
y = ds.y;
freq = ds.frequency;
cens = ds.censored;

% Treat NaN as missing and exclude them
evec = isnan(y);
if ~isempty(freq)
   evec = evec | isnan(freq);
end
if ~isempty(cens)
   evec = evec | isnan(cens);
end

% Remove anything excluded by exclusion rule
if ~isequal(outlier,'(none)') && ~isempty(outlier)
   evec = evec | getexcluded(ds,outlier);
end

if any(evec)
   y(evec) = [];
   if ~isempty(freq)
      freq(evec) = [];
   end
   if ~isempty(cens)
      cens(evec) = [];
   end
end
