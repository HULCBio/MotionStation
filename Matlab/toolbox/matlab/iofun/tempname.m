function tmp_name = tempname
%TEMPNAME Get temporary file.
%   TEMPNAME returns a unique name suitable for use as a temporary file.
%
%   Note: The filename that tempname generates is not guaranteed to be 
%   unique; however, it is likely to be so.
%
%   See also TEMPDIR.

%   Marc Ullman  2-8-93
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 5.12 $  $Date: 2002/06/17 13:26:43 $

t0 = clock;

while(1)
    % loop in place until the time changes, so we can get a unique
    % filename (won't take very long)
    t = clock;
    if (fix(t0(6)*100) ~= fix(t(6)*100))
        break;
    end
end

tmp_name = fullfile(tempdir,sprintf('tp%02.0f%04.0f', t(5), fix(t(6)*100)));

