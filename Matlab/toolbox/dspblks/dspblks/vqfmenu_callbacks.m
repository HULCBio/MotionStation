function cbs =vqfmenu_callbacks(hMainFig)
% CALLBACKS Callbacks for the menus and toolbar buttons of the VQ DESIGN (GLA) GUI.
% Copyright 1988-2003 The MathWorks, Inc.
% $Revision: 1.1.6.1 $  $Date: 2003/04/11 18:17:57 $ 

cbs.new = {@new_cbs, hMainFig};
cbs.open = {@open_cbs, hMainFig};
cbs.save = {@save_cbs, hMainFig};
cbs.saveas = {@saveas_cbs, hMainFig};
cbs.close = {@close_cbs, hMainFig};
cbs.export = {@export_cbs, hMainFig};
cbs.pagesetup = {@pagesetup_cbs,hMainFig};
cbs.printsetup = {@printsetup_cbs,hMainFig};
cbs.printpreview = {@printpreview_cbs,hMainFig};
cbs.print = {@print_cbs,hMainFig};
cbs.printtofigure = {@printofigure_cbs, hMainFig};

%-------------------------------------------------------------------------
function new_cbs(hcbo, eventstruct, hMainFig)

vqdtool;
%-------------------------------------------------------------------------
function open_cbs(hcbo, eventstruct, hMainFig)

vqload(hMainFig);
%-------------------------------------------------------------------------
function save_cbs(hcbo, eventstruct, hMainFig)

vqsave(hMainFig); 
%-------------------------------------------------------------------------
function saveas_cbs(hcbo, eventstruct, hMainFig)

vqsaveas(hMainFig); 
%-------------------------------------------------------------------------
function close_cbs(hcbo, eventstruct, hMainFig)

vqclose(hMainFig); 
%-------------------------------------------------------------------------
function export_cbs(hcbo, eventstruct, hMainFig)
 
vqexport(hMainFig)
%-------------------------------------------------------------------------
function pagesetup_cbs(hcbo, eventstruct,hMainFig)

hFig_printprev = vqcopyaxes(hMainFig);
pagesetupdlg(hFig_printprev);
delete(hFig_printprev);
%-------------------------------------------------------------------------
function printsetup_cbs(hcbo, eventstruct,hMainFig)

hFig_printprev = vqcopyaxes(hMainFig);
printdlg('-setup', hFig_printprev);
delete(hFig_printprev);

%-------------------------------------------------------------------------
function printpreview_cbs(hcbo, eventstruct,hMainFig)

hFig_printprev = vqcopyaxes(hMainFig);

hWin_printprev = printpreview(hFig_printprev);
uiwait(hWin_printprev);
delete(hFig_printprev);

%-------------------------------------------------------------------------
function print_cbs(hcbo, eventstruct,hMainFig)

hFig_printprev = vqcopyaxes(hMainFig);
printdlg(hFig_printprev);
delete(hFig_printprev);

%-------------------------------------------------------------------------
function printofigure_cbs(hcbo, eventstruct, hMainFig)
% Full view analysis

hFig_printprev = vqcopyaxes(hMainFig);
set(hFig_printprev, 'Visible', 'on');

%% [EOF]
