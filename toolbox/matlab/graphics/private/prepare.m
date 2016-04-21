function pj = prepare( pj, h )
%PREPARE Method to modify a Figure or Simulink model for printing.
%   It is not always desirable to have output on paper equal that on screen.
%   The dark backgrounds used on screen would saturate paper with toner. Lines
%   and text colored in light shades would be very hard to see if dithered on 
%   standard gray scale printers. Arguments to PRINT and the state of some 
%   Figure properties dictate what changes are required while rendering the 
%   Figure or model for output.
%
%   Ex:
%      pj = PREPARE( pj, h ); %modifies PrintJob pj and Figure/model h
%
%   See also PRINT, PRINTOPT, RESTORE, PREPAREHG, PREPAREUI.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.5 $  $Date: 2002/04/10 17:10:19 $

error( nargchk(2,2,nargin) )

if ~isequal(size(h), [1 1]) | ~ishandle( h )
    error( 'Need a handle to a Figure or model.' )
end

%Need to see everything when printing
hiddenH = get( 0, 'showhiddenhandles' );
set( 0, 'showhiddenhandles', 'on' )

dberror = disabledberror;
try
    err = 0;
    
    pj.PaperUnits = getget( h, 'paperunits' );
    setset( h, 'paperunits', 'points' )
    
    if isfigure( h ) 
        
        % Create Handle Graphics objects on screen if not already there.
        drawnow
        
        %Make extensive property changes.
        pj = preparehg( pj, h );
        
    else
        
        %Some things just can't do with Simulink output
        if strcmp(pj.Renderer, 'zbuffer' )
            warning( 'Simulink systems only print in Painters mode.' )
            pj.Renderer = '';
        end
        
        if strcmp(pj.Driver, 'mfile')
            error( 'The -dmfile device option can not be used with Simulink systems.' )
        end
        
        if strcmp(pj.DriverClass, 'IM' )
	    error( sprintf('The %s device option is not supported for Simulink systems.', ...
		upper(pj.Driver)))
        end
    end
    
    %Adobe Illustrator format doesn't allow us to set landscape, draw as portrait
    if strcmp(pj.Driver, 'ill') & ~strcmp('portrait', getget(h,'paperorientation') )
        warning('Illustrator only supports Portrait orientation, switching to that mode.')
        pj.Orientation = getget(h,'paperorientation');
        setset( h, 'paperorientation', 'portrait')
    end
    
    
    %If saving a picture, not a printer format, crop the image by moving its
    %lower-left corner to the lower-left of the page. We will use an option
    %with GS to crop it at the width and height of the PaperPosition.
    %This includes the PS generated when we want to use GS to make a TIFF preview.
    if ( strcmp(pj.DriverClass, 'GS') & pj.DriverExport ) ...
            | (pj.DriverExport & pj.PostScriptPreview == pj.TiffPreview)
        pj.GhostImage = 1;
    end
    
catch
    err = 1;
end
enabledberror(dberror);

%Pay no attention to the objects behind the curtain
set( 0, 'showhiddenhandles', hiddenH )

if err
    error( lasterr )
end
