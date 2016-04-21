function out = report_fix_html(in)

% Copyright 2003 The MathWorks, Inc.

    out = strrep(in,'&','&amp;');
    out = strrep(out,'<','&lt;');
    out = strrep(out,'>','&gt;');
