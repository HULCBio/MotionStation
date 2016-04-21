function display(se)
%DISPLAY Display method for structuring element objects.
%   DISPLAY(SE) prints the input variable name associated with SE (if
%   any) to the command window and then calls DISP(SE).  DISPLAY(SE) also
%   prints additional blank lines if the FormatSpacing property is
%   'loose'.
%
%   See also STREL, STREL/DISP.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.5.4.1 $  $Date: 2003/01/26 05:57:26 $

if isequal(get(0,'FormatSpacing'),'compact')
    disp([inputname(1) ' =']);
    disp(se)
else
    disp(' ')
    disp([inputname(1) ' =']);
    disp(' ');
    disp(se)
    disp(' ');
end