function varargout = sfprint(varargin)
%SFPRINT Prints a Stateflow diagram(s).
%   SFPRINT prints the visible portion of the current Stateflow diagram
%
%   SFPRINT(objects, format, outputOption, printEntireChart) prints
%   the charts in any of the passed objects to a file or default printer.
%
%   objects parameter can be a name or id (handle) of Stateflow chart,
%   Simulink model, system or block, or any combination of the above
%   (cell array or a vector of handles )
%
%   Possible formats:
%        'default'
%        'ps'         generates postscript file
%        'psc'        generates color postscript file
%        'eps'        generates encapsulated postscript file
%        'epsc'       generates color encapsulated postscript file
%        'tif'        generates TIFF file
%        'jpg'        generates JPEG file
%        'png'        generates PNG file
%        'meta'       saves Stateflow image to clipboard as a meta file (PC only!)
%        'bitmap'     saves Stateflow image to clipboard as a bitmap    (PC only!)
%
%        if format parameter is absent (sfprint called with 1 argument), format
%        defaults to 'ps', and output is sent to default printer.
%
%   Possible outputOptions:
%        a file name string         specifies the file to write to
%                                   (if more than one chart to be printed, the
%                                   file will be overwritten)
%        'promptForFile' keyword    file name(s) will be asked through a dialog
%        'printer' keyword          output will be sent to default printer.
%                                   (Only use with 'default', 'ps' or 'eps' formats)
%        'file'          keyword    output will be sent to a default file
%                                   <path to object>.<device extension>
%        'clipboard',    keyword    output will be copied to the clipboard
%
%        If outputOption parameter is absent or empty, default file name
%        (chart name) in current directory is used.
%
%   printEntireChart parameter is optional.  There are 2 possible values
%        1 (default)   prints entire charts
%        0             prints current view of charts
%
%   Examples:
%      sfprint(id, 'tif', ...
%                  'myFilename'); % prints the chart/subchart (id) to a tiff file
%
%      sfprint( gcs )              % prints all charts in current system
%
%      sfprint( gcb, 'jpg', ...    % prints current block(if it is a Stateflow
%             'promptForFile')    % block) to file (name specified through
%                                  % dialog)in JPEG format.
%
%      sfprint( gcs, 'tif', ...    % prints all Stateflow charts in current
%             'file', 1);             % system using default file names.  Forces
%                                  % to print entire charts.
%
%   See also STATEFLOW, SFNEW, SFSAVE, SFEXIT, SFHELP.

%   Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.54.4.2 $  $Date: 2004/04/15 01:01:44 $


%
% Expand first argument if necessary and print all associated charts/subcharts
%
switch nargin,
    case 0, print_l;
    otherwise,
        firstArg = varargin{1};

        if nargin==1, args = {}; else args = varargin(2:end); end;

		if is_single_figure_handle_l(firstArg) | (iscell(firstArg) & is_single_figure_handle_l(firstArg{1})),
            print_l(firstArg, args{:});
        else,
           charts = get_charts_of(firstArg);
           if isempty(charts),
              disp('Warning, nothing to print --no Stateflow Charts resolved from input args to sfprint()!');
            end;
            for chart=charts, output = print_l(chart, args{:}); end;
        end;

        if nargout == 1, varargout = {output}; end;
end;


%------------------------------------------------------------------------------------------------
function out = print_l(varargin),
%
% Execute print operation on a single chart/subchart
%
	 out = '';

    %
    % setup parameter defaults
    %
    device      = 'default'; % default device
    output      = 'default'; % default output is device dependent
    currentView = 0;         % object view is the default
    showPreview = 0;         % no previews shown on default

    %
    % Process input args
    %
    switch (nargin),
        case 0,
            chart = currentchart;
            if (chart == 0), disp( 'No current chart to print' ); return; end;

        case 1,
            chart = varargin{1};

        case 2,
            % called with two args, must be chart followed by cmd or device descriptor
            chart = varargin{1};
            cmd   = varargin{2};

            %
            % filter out and execute commands
            %
            switch cmd,
                case 'setup',             print('-dsetup');               return;
                case 'resize',            portal_figure_resize_l(chart);  return; % chart ==> figureH
                case 'printframe_adjust', printframe_adjust(chart);       return;
                otherwise, device = cmd;
            end;

        case 3,
           chart   = varargin{1};
           device  = varargin{2};
           output  = varargin{3};

        case 4,
           chart       = varargin{1};
           device      = varargin{2};
           output      = varargin{3};
           currentView = varargin{4};

        case 5,
           chart       = varargin{1};
           device      = varargin{2};
           output      = varargin{3};
           currentView = varargin{4};
           showPreview = varargin{5};

        otherwise, error('Too many args passed to sfprint!');
    end;

    %
    % Execute print
    %
    out = print_this_chart_l(chart, device, output, currentView, showPreview);

%--------------------------------------------------------------------------------
function out = print_this_chart_l(chart, device, output, currentView, showPreview),
%
%
%
    portal = acquire_print_portal;

    pStack = sf('get', portal, '.printStack');

    % if we're printing a stack of views (done for Simulink hierarchical print jobs),
    % reset the chart id and pop the stack.
    if (length(pStack) > 0),
        chart = pStack(1);
        pStack(1) = [];
        sf('set', portal, '.printStack', pStack);
    end;

    if currentView, sf('set', portal, '.viewMode', 'CURRENT_VIEW');
    else,           sf('set', portal, '.viewMode', 'OBJECT_VIEW');
    end;

    if ~isequal(output,'silent'),
        sf('set', portal, '.printOptions.showTitle', 1);
        sf('set', portal, '.printOptions.showTimeStamp', 1);
    end;

    sf('set', portal, '.colorMode', 'COLORS');
    sf('set', portal, '.border', 'NO_BORDER');
    sf('set', portal, '.viewObject', chart);
    sf('set' ,portal, '.visible', showPreview);
    sf('set', portal, '.printOptions.promptUserForFileName', 0); % default to no prompt.

    % simulink prints need the figure handle
    if nargout == 1,
       out = sf('get', portal, '.figH');
    end;

    switch device,
      case 'default',        sf('set', portal, '.device', 'DEFAULT_DEV');
      case 'ps',             sf('set', portal, '.device', 'PS_DEV');
      case 'psc', 			 sf('set', portal, '.device', 'PSC_DEV');
      case 'eps', 			 sf('set', portal, '.device', 'EPS_DEV');
      case 'epsc', 			 sf('set', portal, '.device', 'EPSC_DEV');
      case {'tiff', 'tif'},  sf('set', portal, '.device', 'TIFF_DEV');
      case {'jpg', 'jpeg'},  sf('set', portal, '.device', 'JPG_DEV');
      case 'png',            sf('set', portal, '.device', 'PNG_DEV');
      case 'meta',           sf('set', portal, '.device', 'META_DEV');
      case 'bitmap',         sf('set', portal, '.device', 'BITMAP_DEV');
      case 'clipboard',      sf('set', portal, '.device', 'META_DEV');
      case 'hg',             % fallthrough
      otherwise, error(['Invalid device specified: ' device]);
    end;

    stateFig = sf('Private', 'state_print_fig', chart, 1);
    if ~isempty(stateFig)
        out = stateFig;
        return;
    end

    %
    % setup correct default output based on device type
    %
    if isequal(output, 'default'),
        switch device,
          case {'ps','psc', 'eps', 'epsc', 'tiff', 'tif', 'jpeg', 'jpg', 'png'}, output = 'file';
          case {'meta', 'bitmap'},                                output = 'clipboard';
          case 'default',                                         output = 'printer';
          case 'hg',                                              % fallthrough
          otherwise, error(['Invalid device specified: ' device]);
        end;
    end;

    switch output,
        case 'silent',
            % just configure for Model print (actual printing happens elsewhere)
            sf('set', portal, '.printOptions.invertHardcopy', 1);
           	sf('set', portal, '.hideBackground', 1);
            sf('set', portal, '.colorMode', 'BLACK_N_WHITE');
            sf('set', portal, '.portalEvent', 'SILENT_PRINT_PE');
           	return;
        case 'printer',
            sf('set', portal, '.output', 'TO_PRINTER');
            sf('set', portal, '.printOptions.invertHardcopy', 1);
        case 'file',      sf('set', portal, '.output', 'TO_FILE');
        case 'clipboard', sf('set', portal, '.output', 'TO_CLIPBOARD');
        case 'promptForFile',
            sf('set', portal, '.output', 'TO_FILE');
            sf('set', portal, '.printOptions.promptUserForFileName', 1);
         case 'figure',
            out = snapshot_portal_to_figure_l(portal);
            return;
        otherwise, % the output parameter is itself a filename
            sf('set', portal, '.output', 'TO_FILE');
            sf('set', portal, '.printOptions.filename', output);
    end;

    sf('set', portal, '.portalEvent', 'PRINT_PE');
    sf('set', portal, '.visible', 0);



%-----------------------------------------------------------------------------
function x = is_single_figure_handle_l(h),
%
%
%
    x = logical(0);

    if isequal(sum(size(h)), 2),
        switch ml_type(h),
            case 'hg_handle',
                if isequal(get(h,'type'), 'figure'), x = logical(1); end;
            otherwise,
        end;
    end;

%-----------------------------------------------------------------------------
function printframe_adjust(args),
% the function to be call from printframe to adjust stateflow
% beautiful picture to the new size, determined by passed margin
%
    figH = args{1};
    unitName = args{2};
    margin = args{3};

    portal = get(figH, 'UserData');

    ppu = compute_points_per_unit_l(unitName);
    margin = margin * ppu;
    figPos = get(figH, 'position');
    figUnits = get(figH, 'units');
    figPosInches = figPos/ppu;
    paperUnits = get(figH, 'paperUnits');
    set(figH, 'paperUnits', unitName);
    paperSize = get(figH, 'paperSize');
    set(figH, 'paperUnits', paperUnits);

    % convert this into a real margin rect (left, top, right, and bottom margins).
    W = paperSize(1)*ppu;
    H = paperSize(2)*ppu;

    x = margin(1);
    y = margin(2);
    w = margin(3);
    h = margin(4);

    margin(1) = x;
    margin(2) = H - h - y;
    margin(3) = W - w - x;
    margin(4) = y;

    sf('set', portal, '.margin', margin);


%-----------------------------------------------------------------------------
function ppu = compute_points_per_unit_l(unit),
%
%
%
    oldUnits = get(0,'units');
    set(0,'units','points');
    p = get(0,'screenSize');
    h = p(4);
    set(0,'units', unit);
    p = get(0,'screenSize');
    ppu = h/p(4);

    set(0,'units', oldUnits);

%-----------------------------------------------------------------------------
function portal_figure_resize_l(figH),
%
%
%
	portal = get(figH, 'userdata');


%-----------------------------------------------------------------------------
function newFig = snapshot_portal_to_figure_l(portal),
%
%
%
    sf('set', portal, '.output', 'TO_FIGURE');
    sf('set', portal, '.portalEvent', 'SILENT_PRINT_PE');
    newFig = figure;
    portalFig = sf('get', portal, '.figH');
    u = get(portalFig, 'units');
    p = get(portalFig, 'pos');
    set(newFig, 'units', u, 'pos', p);
    portalAxes = sf('get', portal, '.axesH');
    copyobj(portalAxes, newFig);
    drawnow;
