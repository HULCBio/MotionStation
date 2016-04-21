function nntool
%NNTOOL Neural Network Toolbox graphical user interface.
%
%  Syntax
%
%    nntool
%
%  Description
%
%    NNTOOL opens the Network/Data Manager window which allows
%    you to import, create, use, and export neural networks
%    and data.

% Copyright 1992-2003 The MathWorks, Inc.
% $Revision: 1.13.4.2 $  $Date: 2004/04/10 23:46:12 $

% make sure we are on a platform that has the desktop
jc=javachk('mwt','NNTOOL');
if ~isempty(jc)
    if isstruct(jc)
        jc = jc.message;
    end
    disp(jc)
    return
end

% NNTGUI access port
nntgui = com.mathworks.toolbox.nnet.NNTGUI('dummy');

% Open manager
launchNNManager(nntgui);
