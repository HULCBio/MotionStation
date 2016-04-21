function y = fdatool_help
%FDATOOL_HELP Help system functions for FDATool GUI.

%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.46.4.2 $  $Date: 2004/04/13 00:31:43 $

% Return structure of public function handles:
y.install_CSH      = @install_CSH;
y.toolhelp_cb      = @toolhelp_cb;
y.producthelp_cb   = @producthelp_cb;
y.HelpWhatsThis_cb = @HelpWhatsThis_cb;
y.importhelp_cb    = @importhelp_cb;
y.exporthelp_cb    = @exporthelp_cb;
y.saveopensessionshelp_cb = @saveopensessionshelp_cb;
y.demos_cb         = @demos_cb;
y.about_cb         = @about_cb;
y.HelpGeneral      = @HelpGeneral;
y.tag_mapping      = @tag_mapping;

% General Context Sensitive Help (CSH) system rules:
%  - context menus that launch the "What's This?" item have their
%    tag set to 'WT?...', where the '...' is the "keyword" for the
%    help lookup system.


% --------------------------------------------------------------
function toolhelp_cb(hco,eventStruct)
% toolhelp_cb Overview of the tool (reference-page help).

hFig = gcbf;
hFDA = getfdasessionhandle(hFig);
calledbydspblks = getflags(hFDA,'calledby','dspblks');
if calledbydspblks,
    map = 'dspblks';
    tag = 'dspblksfdatool_overview';
else
    map = 'signal';
    tag = 'fdatool_overview';
end

helpview(fullfile(docroot, ['toolbox',filesep,map,filesep], [map '.map']), tag);

% --------------------------------------------------------------
function producthelp_cb(hco,eventStruct)
% producthelp_cb Opens the Help window with the online doc Roadmap
%                page (a.k.a. "product page") displayed.

doc signal/

% --------------------------------------------------------------
function HelpWhatsThis_cb(hco, eventStruct)
% HelpWhatsThis_cb Get "What's This?" help
%   This mimics the context-menu help selection, but allows
%   cursor-selection of the help topic

% Invoke the generic utility function
cshelpgeneral_cb(hco, eventStruct, 'FDATool');

% --------------------------------------------------------------
function importhelp_cb(hco,eventStruct)
% importhelp_cb Help on Importing into the tool.

helpview ([docroot '/toolbox/signal/signal.map'],...
	'fdatool_importfilterdesign');

% --------------------------------------------------------------
function exporthelp_cb(hco,eventStruct)
% exporthelp_cb Help on Exporting from the tool.

helpview ([docroot '/toolbox/signal/signal.map'],...
	'fdatool_exportfilterdesign');

% --------------------------------------------------------------
function saveopensessionshelp_cb(hco,eventStruct)
% saveopensessionshelp_cb Help on Exporting from the tool.

helpview ([docroot '/toolbox/signal/signal.map'],...
	'fdatool_saveopensessions');

% --------------------------------------------------------------
function demos_cb(hco,eventStruct)
% demos_cb Starts Demo window, with the appropriate product's
%                demo highlighted in the Demo window contents pane.

demo toolbox signal

% --------------------------------------------------------------
function about_cb(hco,eventStruct)
% about_cb Displays version number of product, and copyright.

aboutsignaltbx;

% --------------------------------------------------------------
function HelpGeneral(hco,eventStruct,tag)
% HelpGeneral Bring up the help corresponding to the tag string.

tag=get(hco,'tag');
% Invoke the context sensitive help engine
cshelpengine(hco,eventStruct,'FDATool',tag);

% --------------------------------------------------------------
function tag = tag_mapping(hFig,tag);
% Intercept general tags to differentiate as appropriate, if 
% necessary, otherwise, return the input tag string.

switch tag
case 'fdatool_other_filtertypes_button',% Other filter types button.
    tag = otherfiltertypes_tags(hFig);
    
case 'fdatool_ALL_analysis_plots',      % Analysis plots.
    tag = analysisplots_tags(hFig);
    
case 'fdatool_ALL_import_structures',   % Import filter structures.
    tag = importstructures_tags(hFig);
    
case 'fdatool_ALL_freq_specs_frame',    % Frequency specifications frame.
    tag = designspecs_tags(hFig,'freq');
    
case 'fdatool_ALL_mag_specs_frame',     % Magnitude specifications frame.
    tag = designspecs_tags(hFig,'mag');
    
case 'fdatool_ALL_freqmag_specs_frame', % Freq. & Mag. specifications frame.
    tag = freqmagspecs_tags(hFig);
end

% --------------------------------------------------------------
function install_CSH(hFig)
%install_CSH Install Context-Sensitive Help

% ==================================================================
%
% Here is where all the handle-to-help relationships are constructed
%
% ==================================================================

% Each relationship is set up as follows:
%
%  fdaddcontextmenu(hFig, [vector_of_UI_handles], tagString);
%
% where tagStr corresponds to the link used in the doc map file. 

% Overview; figure.
fdaddcontextmenu(hFig,hFig, 'fdatool_overview');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Functions that intercept general tags and maps them to a specific tag. %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --------------------------------------------------------------
function tag = otherfiltertypes_tags(hFig)
% "Other" filter types button in the 
% Filter Type frame.

hd = finddesignpanel(hFig);

% Intercept general tags to differentiate as appropriate:
filterType = lower(mapfiltertype(hd));

% Removed spaces from the filter type string.
filterType(isspace(filterType)) = '';
tag = ['fdatool_',filterType,'_othertype'];

% --------------------------------------------------------------
function tag = analysisplots_tags(hFig)
% Analysis plots tags.

hFDA = getfdasessionhandle(hFig);
hfvt = find(hFDA, '-class', 'siggui.fvtool');
analysisPlot = get(hfvt, 'currentanalysis');
tag = ['fdatool_',analysisPlot,'_plot'];

% --------------------------------------------------------------
function tag = importstructures_tags(hFig)
% Structures in the Import tab.

hFDA  = getfdasessionhandle(hFig);
hIT   = find(hFDA, '-class', 'siggui.import');
state = getstate(hIT);

switch lower(state.coeffspecifier.SelectedStructure),
case {'direct-form i','direct-form ii','direct-form i transposed',...
        'direct-form ii transposed'},
    tag = 'fdatool_transferfunction_specs';
    
case 'direct-form ii (second-order sections)',
    tag = 'fdatool_sos_specs';
    
case 'state-space',
    tag = 'fdatool_statespace_specs';
    
case 'lattice allpass'
    %tag = 'fdatool_latticeallpass_specs';
    tag = 'fdatool_lattice_specs';
    
case {'lattice moving-average minimum phase','lattice moving-average maximum phase'},
    %tag = 'fdatool_latticema_specs';
    tag = 'fdatool_lattice_specs';
    
case 'lattice autoregressive moving-average (arma)',
    tag = 'fdatool_lattice_specs';
    
case 'quantized filter (qfilt object)',
    tag = 'fdatool_quantizedfilter_specs';
end

% --------------------------------------------------------------
function tag = designspecs_tags(hFig,frame)
% Tags for the filter design specifications frames (mag and freq).

% Intercept general tags to differentiate as appropriate:
hd = finddesignpanel(hFig);

[filtdes, method] = strtok(get(hd, 'designmethod'), '.');
method(1) = [];
filterType = get(hd, 'SubType');

tag = ['fdatool_',filterType,'_',frame,'_specs_',method];

% --------------------------------------------------------------
function tag = freqmagspecs_tags(hFig)
% Tags for the filter design freqmag specifications frames.

% Intercept general tags to differentiate as appropriate:
hd = finddesignpanel(hFig);
filterType = get(hd, 'SubType');
tag = ['fdatool_',filterType,'_','freqmag_specs'];

% --------------------------------------------------------------
function hd = finddesignpanel(hFig)

h  = getfdasessionhandle(hFig);
hd = find(h, '-class', 'siggui.designpanel');

% [EOF] fdatool_help.m
