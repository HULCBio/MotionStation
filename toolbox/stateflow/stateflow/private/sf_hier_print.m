function varargout = sf_hier_print(varargin),
%SF_HIER_PRINT(CHART)
%   [SYSTEMS] = SF_HIER_PRINT(CHART)
%   Manages Stateflow hierarchical printing and associated Simulink interfaces
%

%   Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.7.2.2 $  $Date: 2004/04/15 00:59:38 $


args = {};
switch nargin,
    case 0, return;
    case 1,  
       	if isequal(varargin{1}, 'getDirectives'),
            chartSys = 0; % not needed.
            cmdEvent = varargin{1};
        else,
        
        	chartSys = varargin{1};
        	cmdEvent = 'launch';
        end;
    case 2, 
        chartSys = varargin{1};
        cmdEvent = varargin{2};
    otherwise, 
        chartSys = varargin{1};
        cmdEvent = varargin{2};     
        args     = varargin(3:nargin);      
end;

out = broadcast_l(chartSys, cmdEvent, args); 
if nargout > 0, varargout{1} = out; end;



%--------------------------------------------------------------------


function  out = broadcast_l(chartSys, cmdEvent, args),
%
%
%
    out = '';
    switch (cmdEvent),
        case 'launch',        launch_system_print_ui_l(chartSys);
        case 'executePrint',  execute_print_job_l(chartSys, args{:}); % args better be a valid directives structure!
        case 'getDirectives', out = get_directives_template_l;
        case 'getSystems',    out = get_systems_l(chartSys, args);
        otherwise,            error('bad args passed to sf_hier_print()');
    end;


%--------------------------------------------------------------------
function launch_system_print_ui_l(chart),
%
%
%
    viewObj = sf('get', chart, '.viewObj');
    portal  = acquire_print_portal;
    sf('set', portal, '.sfBasedPrintJob', 1, '.viewObject', viewObj, '.visible', 0);
    
    block = get_chart_block_path_l(chart);
    sys   = get_param(block, 'parent');

    open_system(sys);
    open_system(block);

    sf('Private', 'simprintdlg', sys); % jedi mind trick
    
    if isunix,
       simPrintDlgH = findall(0, 'type','figure','tag','TMWsimprintdlg');      
       waitfor(simPrintDlgH);       
    end;      
    sf('set', portal, '.sfBasedPrintJob', 0);


%--------------------------------------------------------------------
function systems = get_systems_l(sys, args);
%
%
%   
    portal     = acquire_print_portal;
    chart      = sf('get', portal, '.chart');
    viewObj    = sf('get', chart, '.viewObj');
    chartBlock = get_chart_block_path_l(chart);

    printDirective = args{1};
    switch printDirective,
        case 'This',
            systems = {chartBlock};
            sf('set', portal, '.printStack', viewObj);
        case 'Up',
            %
            % If we're looking at a subchart, add all intermediate
            % views up to the chart itself
            %
            subcharts = [];
            while ~isequal(viewObj, chart), 
                subcharts = [viewObj, subcharts];
                viewObj = sf('get', viewObj, '.subviewer');    
            end;
            
            sf('set', portal, '.printStack', [chart, subcharts]);

            subchartPaths = {chartBlock};
            num = length(subcharts) + 1;
            subchartPaths = subchartPaths(ones(num,1));
            systems = [sys; subchartPaths];

        case 'Down',
			subcharts = non_empty_subcharts_in(viewObj);
            subcharts = [subcharts truth_tables_in(viewObj) eml_fcns_in(viewObj)];
            
            sf('set', portal, '.printStack', [viewObj, subcharts]);
            num = length(subcharts) + 1;
            systems = {chartBlock};
            systems = systems(ones(1, num));
            
        otherwise, error('bad args passed to sf_hier_print()');
    end;

%--------------------------------------------------------------------
function block = get_chart_block_path_l(chart);
%
%
% 
    instance = sf('get', chart, '.instance');
    blockH   = sf('get', instance, '.simulinkBlock');
    block    = getfullname(blockH);


%--------------------------------------------------------------------
function directives = get_directives_template_l
%
%
%
  	directives.loop                         = 'CurrentSystem';
	directives.printStruct.PrintLog         = 'off';
	directives.printStruct.PrintFrame       = 'sldefaultframe.fig';
	directives.printStruct.FileName         = 'printtest.ps';
	directives.printStruct.PrintOptions     = '-dps';
	directives.printStruct.PaperType        = 'usletter';
	directives.printStruct.PaperOrientation = 'portrait';
  	directives.LookUnderMask                = 0;
	directives.ExpandLibLinks               = 0;


%--------------------------------------------------------------------
function block = execute_print_job_l(chart, directives);
%
% Command API for testability (launch a printjob sans dialog)
%

%
% print directives nust have the following structure:
%
%   Field                                     Example
%   --------------------------------------------------------------------
%   directives.loop                         = 'CurrentSystem';
% 	directives.printStruct.PrintLog         = 'off';
% 	directives.printStruct.PrintFrame       = 'sldefaultframe.fig';
% 	directives.printStruct.FileName         = 'printtest.eps';
% 	directives.printStruct.PrintOptions     = '-deps2';
% 	directives.printStruct.PaperType        = 'usletter';
% 	directives.printStruct.PaperOrientation = 'portrait';
%   directives.LookUnderMask                = 0;
% 	directives.ExpandLibLinks               = 0;
%

	viewObj = sf('get', chart, '.viewObj');
    portal  = acquire_print_portal;
    sf('set', portal, '.sfBasedPrintJob', 1, '.viewObject', viewObj, '.visible', 0);
    
    block = get_chart_block_path_l(chart);
    sys   = get_param(block, 'parent');

    open_system(sys);
    open_system(block);

   	% need to go through sf Private for mysterious reason only known by the jedi
    sf('Private', 'simprintdlg', sys, directives.loop, directives.LookUnderMask, directives.ExpandLibLinks, directives.printStruct); 

    sf('set', portal, '.sfBasedPrintJob', 0);
