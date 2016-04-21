function success = focus_explorer_on_model_configuration(model)
%  Given a model, points Explorer to model's active config set

% Copyright 2003 The MathWorks, Inc.

success = true;

% First, find the explorer.  If one is open, we will use
% that one.  If more than one is open, we will use the first
% one that was opened.  If none is opened, we will open a
% new one.  This is how web browsers are used when clicking
% links in mail (in most cases)

explr = daexplr;
explr.show;
cfgset = model.getActiveConfigSet;
solver = cfgset.getComponent('Solver');
explr.view(solver);
    
    
