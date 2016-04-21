function navigate_2_sigbuilder(blockH,tabIdx)

% Copyright 2004 The MathWorks, Inc.

    open_system(blockH);  % Open the GUI if needed
    dialogH = get_param(blockH,'UserData');
    sigbuilder('FigMenu',dialogH,[],'showTab',tabIdx);
