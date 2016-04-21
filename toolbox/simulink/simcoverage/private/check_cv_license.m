function status = check_cv_license
%CHECK_CV_LICENSE Check if the coverage tool is licensed

% Bill Aldrich
% Copyright 1990-2004 The MathWorks, Inc.
% $Revision: 1.5.2.2 $  $Date: 2004/04/15 00:37:14 $

[wState] = warning;
warning('off');
try,
    status = cv('License','basic');
catch
    status = 0;
end
warning(wState);



