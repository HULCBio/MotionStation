function sfun_bitopcbk()
%SFUN_BITOPCBK Support function for Bitwise Operator block.
%   Displays or hides the bitwise operator block's second parameter
%   based on which operator has been selected.  Used as the 
%   'MaskCallbacks' function for the first parameter in 
%   the mask for S-function sfun_bitop.

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.6 $

mv = get_param( gcbh, 'MaskValues' );
if ( strcmp( mv{1}, 'NOT' ) )
   set_param( gcbh, 'MaskVisibilities', {'on','off'}, ...
		    'MaskEnables', {'on','off'} );
else
   set_param( gcbh, 'MaskVisibilities', {'on','on'}, ...
		    'MaskEnables', {'on','on'} );
end   
