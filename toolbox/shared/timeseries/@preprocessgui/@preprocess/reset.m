function reset(h,dataset)
%RESET
%
% Author(s): James G. Owen
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.5 $ $Date: 2004/04/11 00:32:54 $


% Clear past listeners which may be attached to nodes which have been
% deleted if the SPE has been reopened
% h.resetListeners

h.Datasets = dataset;

% Initialize exclusion properties
h.ManExcludedpts = cell(length(h.Datasets),1);
for k=1:length(h.Datasets)
    h.ManExcludedpts{k} = zeros(size(h.Datasets(k).Data));
end

% The initial position is always 1 - this avoids an old large
% position property being > the length of h.ManExcludedpts
h.Position = 1;

%% Clear rule objects
h.flushrules
