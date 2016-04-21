function y = cleanerrormsg(x)
%CLEANERRORMSG Make error message appropriate for a dialog box.

%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/04/14 23:52:25 $ 

y = deblank(removeErrorTraceback(x));

%-------------------------------------------------------------------
function y = removeErrorTraceback(x)
% REMOVEERRORTRACEBACK Removes the error message's back trace.
%
% Input:
%   x - error message
% Output:
%   y - error message without backtrace

iErr = findstr(x,sprintf('Error using ==>'));
if ~isempty(iErr),
    % Traceback present in message
    iCR = findstr(x,char(10));        % Find carriage-return chars
    iFirstCR = find(iCR > iErr(end)); % Find first CR char beyond the last iErr index:
    iBegin = iCR(iFirstCR(1))+1;      % Starting point of "clipped" warning message
    y = x(iBegin:end);                % Construct clipped warning message
else
    % No traceback present in message
    y = x;
end


% EOF
