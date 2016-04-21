function hprintbtns = render_sptprintbtns(htoolbar)
%RENDER_SPTPRINTBTNS Render the "Print" and "Print Preview" toolbar buttons.
%   HPRINTBTNS = RENDER_SPTPRNITBTNS(HTOOLBAR) creates the print portion of a toolbar 
%   (Print, Print Preview) on a toolbar parented by HTOOLBAR and return the handles 
%   to the buttons.

%   Author(s): V.Pellissier
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/11/21 15:36:05 $ 

% Load new, open, save print and print preview icons.
icons = load('sptviewicons');

pushbtns = {icons.printdoc,...
        icons.printprevdoc};

tooltips = {xlate('Print'),...
        xlate('Print Preview')};

tags = {'printresp',...
        'printprev'};

btncbs = {'printdlg(gcbf);',...
        'printpreview(gcbf);'};

% Render the PushButtons
for i = 1:length(pushbtns),
   hprintbtns(i) = uipushtool('Cdata',pushbtns{i},...
        'Parent', htoolbar,...
        'ClickedCallback',btncbs{i},...
        'Tag',            tags{i},...
        'Tooltipstring',  tooltips{i});
end

% [EOF]
