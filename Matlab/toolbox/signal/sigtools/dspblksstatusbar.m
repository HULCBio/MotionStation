function dspblksstatusbar(hFig)
%DSPBLKSSTATUSBAR Update FDATool's status bar when called by the Signal Processing Blockset.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.5.4.3 $  $Date: 2004/04/13 00:31:33 $

hFDA = getfdasessionhandle(hFig);
calledbydspblks = getflags(hFDA,'calledby','dspblks');

if calledbydspblks,
    hFDA = getfdasessionhandle(hFig);
    data = getappdata(hFDA,'DSPBlks');
    hBlk = data.hBlk;
    name = get_param(hBlk,'Name');
    % Remove the carriage return (if it exists) from the block name
    name(find(name == char(10))) = ' ';

    msg = ['Filter coefficients have been sent to ' name ' block.'];
    status(hFDA,msg);
end

% [EOF]
