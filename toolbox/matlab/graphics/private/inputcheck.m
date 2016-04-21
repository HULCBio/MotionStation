function [pj, devices, options] = inputcheck( pj, varargin )
%INPUTCHECK Method to validate input arguments to PRINT.
%   Parses input arguments, updates state of PrintJob object accordingly.
%   Returns PrintJob object and cell-arrays for the lists of devices and
%   options that can legally be passed to PRINT.
%   Will error out if bad arguments are found. 
%
%   Ex:
%      [pj, dev, opt] = INPUTCHECK( pj, ... ); 
%
%   See also PRINT, TABLE, VALIDATE.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.7 $  $Date: 2002/04/10 17:10:36 $

%Get cell arrays of driver specific information
[ options, devices, extensions, classes, colorDevs, destinations ] = printtables;

for i = 1 : length(varargin)
    cur_arg = varargin{i};
    
    if isempty( cur_arg )
        %silly thing to do, ignore it
        
    elseif ~isstr( cur_arg )
        %Non-string argument better be a handle of a Figure or model.
        %To be a non-string we are using the function form of PRINT.
        pj.Handles = [ pj.Handles LocalCheckHandles(cur_arg) ];
        
    elseif (cur_arg(1) ~= '-')
        % Filename, can only have one!
        if isempty( pj.FileName )
            pj.FileName = cur_arg;
        else
            error( [ 'Multiple inputs that look like filenames: ''' ...
                    pj.FileName ''' and ''' cur_arg '''' ] );
        end
        
    else
        switch( cur_arg(2) )
            
        case 'd',

            % Device name
            [ pj, devIndex ] = LocalCheckDevice( pj, cur_arg, devices );
            
            if devIndex == 0
                %Will echo out possible values or error out depending on input to PRINT
                pj.Driver = '-d';
                return 
            end
            pj.DriverExt = extensions{ devIndex };
            pj.DriverClass = classes{ devIndex };
            pj.DriverColor = strcmp( 'C', colorDevs{ devIndex } );
            pj.DriverColorSet = 1;
            pj.DriverExport = strcmp( 'X', destinations{ devIndex } );
            
        case 'f'
            % Handle Graphics figure handle
            pj.Handles = [ pj.Handles {LocalString2Handle(cur_arg)} ];
            
        case 's'
            % Simulink system name
            if ( exist('open_system') ~= 5 )
                error('Simulink is not available in this version of MATLAB.');
            end
            window = LocalSimName2Handle( cur_arg );
            pj.Handles = [ pj.Handles {window} ];
            pj.SimWindowName = get_param( window, 'name' );
            
        case 'P'
	    % Printer name - Windows and Unix
            pj.PrinterName = cur_arg(3:end);

	    % check for empty name
            if(isempty(pj.PrinterName))
                error( [ 'A valid printer name must be supplied with ''-P''.' ] );
            end
            
        otherwise
            %
            % Verify a given option is supported.
            % At this point we now it is a string that starts with -
            %
            opIndex = LocalCheckOption( cur_arg, options );
            
            %Some options are used in HARDCOPY, others used only in M before or after.
            %This switch must be kept up to date with options table and code i HARDCOPY.
            switch options{opIndex}
                
            case 'loose'
                pj.PostScriptTightBBox = 0;
                
            case 'tiff'
                pj.PostScriptPreview = pj.TiffPreview;
                
            case 'append'
                pj.PostScriptAppend = 1;
                
            case 'adobecset'
                pj.PostScriptLatin1 = 0;
                
            case 'cmyk'
                pj.PostScriptCMYK = 1;
                
            case 'r'
                %Need number following -r for resolution
                pj.DPI = round(sscanf( cur_arg, '-r%g' ));
                
            case 'noui'
                pj.PrintUI = 0;
				pj.nouiOption = 1;
                
            case 'painters' 
                pj.Renderer = 'painters';
				pj.rendererOption = 1;
                
            case 'zbuffer'
                if pj.XTerminalMode
                    warning( 'ZBuffer mode can not be used in terminal emulation mode; ignoring option.')
                else
                    pj.Renderer = 'zbuffer';
					pj.rendererOption = 1;
                end
                
	    case 'opengl'
                if pj.XTerminalMode
                    warning( 'OpenGL mode can not be used in terminal emulation mode; ignoring option.')
                else
                    pj.Renderer = 'opengl';
					pj.rendererOption = 1;
				end

            case 'DEBUG'
                pj.DebugMode = 1;
                
            case 'v'
                %This is really just a PC option, but it would have gotten flagged earlier.
                pj.Verbose = 1;
                
            otherwise
                error(['Illegal option ''' cur_arg ''' given.'])
                
            end %switch option
        end %switch cur_arg
    end % if isempty
end %for loop

% if the -noui or renderer weren't on the command line then use
% the defaults from the figure's printtemplate (if exists).



%%%%
%%%% LocalCheckHandles
%%%%
function h = LocalCheckHandles( cur_arg )
%    Checks that input matrix is full of handles to Figures and/or models.

%Expect handles to be cell-array of vectors, each vector on a new page.
%But the easiest form of calling PRINT is just with a scalar.
if ~iscell( cur_arg )
    cur_arg = { cur_arg };
end

for i = 1 : length(cur_arg)
    v = cur_arg{i};
    dims = size( v );
    if length(dims) > 2 | dims(1) ~= 1
        error( 'Handle input must be scalar, vector, or cell-array of vectors.')
    end
    
    if  ~all( ishandle(v) ) 
        error( 'Handle input argument contains non-handle value(s).' )
    else
        for h = v(:)'
            if ishghandle(h)
                if ~isfigure(h) 
                    error( 'Handle Graphics handle must be a Figure.' )
                end
            elseif ~isslhandle(h)
                error( 'Simulink handle must be an open Block Diagram or SubSystem.' )
            end
        end
    end
end
h = cur_arg;
%EOFunction LocalCheckHandles



%%%%
%%%% LocalCheckDevice
%%%%
function [ pj, devIndex ] = LocalCheckDevice( pj, cur_arg, devices )
%LocalCheckDevice Verify device given is supported, and only one is given.
%    device proper starts after '-d', if only '-d'
%    we will later echo out possible choices

if ~isempty( pj.Driver )
    error( [ 'Multiple inputs that look like device names: ''' ...
            pj.Driver ''' and ''' cur_arg ''''] );
end

%We already know first two characters are '-d'
if ( size(cur_arg, 2) > 2 )    
    
    %Is there one unique match?
    devIndex = strmatch( cur_arg(3:end), devices, 'exact' );
    if length(devIndex) == 1
        pj.Driver = cur_arg(3:end);
        
    else
        %Is there one partial match, i.e. -dtiffn[ocompression]
        devIndex = strmatch( cur_arg(3:end), devices );
        if length( devIndex ) == 1
            %Save the full name
            pj.Driver = devices{devIndex};
            
        elseif length( devIndex ) > 1
            error( ['Device option ''' cur_arg '''is not unique'] )
            
        else
            % A special case, -djpegnn, where nn == quality level
            if strncmp( cur_arg, '-djpeg', 6 )
                if isempty( str2num(cur_arg(7:end)) )
                    error( 'JPEG quality level in device name must be numeric.' );
                end
                %We want to keep quality level in device name.
                pj.Driver = cur_arg(3:end); 
                devIndex = strmatch('jpeg',devices);
            else
                error(['Illegal device option, ''' cur_arg ''', specified.']);
            end
        end
    end
else
    devIndex = 0;
end
%EOFunction LocalCheckDevice    


%%%%
%%%% LocalCheckOption
%%%%
function opIndex = LocalCheckOption( op, options )
%LocalCheckOption Verify option given is supported, and only one is given.
%    Option proper starts after '-'. Returns index into options cell array or errors.

%We already know first character is '-'
if ( size(op, 2) > 1 )    
    
    option = op(2:end);
    
    %Is there one unique match?
    opIndex = strmatch( option, options, 'exact' );
    
    if length(opIndex) ~= 1
        
        %Is there one partial match, i.e. -adobe
        opIndex = strmatch( option, options );
        
        if length(opIndex) == 0
            
            %Special case 1
            if strcmp( option, 'epsi' )
                %This was a grandfathered preview format. Tell the user s/he is
                %using something no longer supported and give him/her the new
                %and improved preview, TIFF.
                warning( 'EPSI preview format no longer supported. Using -tiff option.' )
                opIndex = strmatch( 'tiff', options, 'exact' );
                
                %Special case 2
            elseif option(1) == 'r'
                %Resolution switch. As given by user will have a number after it
                %If there is nothing after it, it means to use screen resolution
                %That case is caught in the first strmatch.
                res = sscanf( option, 'r%g' );
                if isempty(res)
                    error( 'Resolution switch expecting numbers after -r.' )
                end
                opIndex = strmatch( 'r', options, 'exact' );
                
            else
                error(['Illegal option ''' op ''' given.'])
            end
            
        elseif length(opIndex) > 1
            error( ['Option ''' op '''is not unique'] )
        end
    end
else
    error( 'Expecting option to follow ''-''.' )
end
%EOFunction LocalCheckOption    


%%%%
%%%% LocalSimName2Handle
%%%%
function h = LocalSimName2Handle( cur_arg )
%LocalGetSlHandle Return handle of (sub)system with given name.
%    Pass full -s<name> argument.

%We already know it starts with at least -s
modelName = cur_arg( 3:end );
if isempty( modelName )
    % Print current system by default, if one is open.
    h = get_param(gcs,'handle');
else 
    %we have a name, but is it a model/subsystem name?
    dberror = disabledberror;
    try
      %Finds root systems and full path named subsystem, it errors if doesn't exist.
      sys = find_system( modelName,'SearchDepth',0, 'open','on' );
    catch
      %Look for system of that name, it doesn't error, just returns empty.
      sys = find_system('name',modelName, 'open','on');
      if isempty( sys )
	error(['Simulink system name ''' modelName ''' does not exist or is not open.'])
      elseif length(sys) ~= 1
	error(['Simulink system name ''' modelName ''' is not unique.'])
      end                
    end
    enabledberror(dberror);
    if isempty( sys )
      error(['Simulink system name ''' modelName ''' is not an open Block Diagram or SubSystem.'])
    end
    
    %Is it a root model, subsystem model, or a block (which can't be print target)?
    if ~isslhandle( get_param( sys{1}, 'handle' ) )
      error(['Simulink system name expected, not block name ''' sys{1} '''.'])
    end
    h = get_param(sys{1},'handle');
end
if isempty( h )
    error('No Simulink system to print with -s option.');
end
%EOFunction LocalSimName2Handle


%%%%
%%%% LocalString2Handle
%%%%
function h = LocalString2Handle( t )
%LocalString2Handle Return handle value for text following -f, or current Figure.
%    Pass -f as well as text after it. Errors out if not a Figure handle or if
%    nothing is after the -f and there is no current Figure to be used.

%We know t is already at least '-f'
if length(t) == 2
    % Get current figure; but don't create one, like gcf would, if none yet.
    h = findobj(get(0,'children'),'flat','type','figure');
    if isempty( h )
        error( 'No Figures to print with -f switch' )
    else
        h = h(1);
    end
else
    %Must be, or at least should be, a figure handle integer.
    [h,c,e] = sscanf( t, '-f%g' );
    if ~isempty(e)
        error( ['Problem reading Figure handle in -f switch: ''' t '''.'])
    elseif isempty(h) | ~ishandle(h) | ~isfigure(h)
        error( 'What follows -f is not a Figure handle.' )
    end
end
%EOFunction LocalString2Handle
