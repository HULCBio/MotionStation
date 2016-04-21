function init_html_renderer
% Initialize html printer. Due to a bug, the components in renderer
% are not ready at the first print. See "private/print_html_str" for
% detail;

% Copyright 2003 The MathWorks, Inc.

persistent initialized;

if isempty(initialized)
    print_html_str;
    initialized = 1;
    mlock;
end
