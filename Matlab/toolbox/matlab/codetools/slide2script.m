function slide2script(slide);
% SLIDE2SCRIPT converts playshow-format demos to script-format.
%    SLIDE2SCRIPT(SLIDE) creates in the current directory a script that has the
%    same content as SLIDE, a function on the path that returns a playshow
%    structure.

% Matthew J. Simoneau
% $Revision: 1.1.6.2 $  $Date: 2003/12/24 19:12:05 $
% Copyright 1984-2003 The MathWorks, Inc.

slide = regexprep(slide,'\.m$','');
newName = fullfile(pwd,[slide '_new.m']);
f = fopen(newName,'w');
if (f == -1)
    error('MATLAB:slide2script:CannotCreate', ...
        'Cannot open "%s" for writing.', ...
        newName);
end
fprintf(f,'%c',mxdom2m(slide2mxdom(slide))');
fclose(f);
disp(['Created "' newName '".'])
