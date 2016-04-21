function pj = restore( pj, h )
%RESTORE Reset a Figure or Simulink model after printing.
%   When printing a model or Figure, some properties have to be changed
%   to create the desired output. RESTORE resets the properties back to 
%   their original values.
%
%   Ex:
%      pj = RESTORE( pj, h ); %modifies PrintJob pj and Figure/model h
%
%   See also PRINT, PRINTOPT, PREPARE, RESTOREHG, RESTOREUI.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.4 $  $Date: 2002/04/10 17:10:22 $

error( nargchk(2,2,nargin) )

if ~isequal(size(h), [1 1]) | ~ishandle( h )
    error( 'Need a handle to a Figure or model.' )
end

%Need to see everything when printing
hiddenH = get( 0, 'showhiddenhandles' );
set( 0, 'showhiddenhandles', 'on' )

try
    err = 0;
    
    if isfigure(h)
        pj = restorehg( pj, h );
    end
        
    setset( h, 'paperunits', pj.PaperUnits );
    pj.PaperUnits = ''; %not needed anymore
    
    %May have changed orientation because of device
    if ~isempty( pj.Orientation )
        setset(h,'paperorientation', pj.Orientation)
        pj.Orientation = '';
    end
    

catch
    err = 1;
end

%Pay no attention to the objects behind the curtain
set( 0, 'showhiddenhandles', hiddenH )

if err
    error( lasterr )
end
