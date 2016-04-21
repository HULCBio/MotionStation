function pj = start( pj )
%START Method to start a print job.
%   Shows platform/device independent dialog to user if PrintJob is in
%   verbose mode. If possible it interagates current window system printer 
%   to find out what options it supports in preperation for rendering. After
%   user finishes with dialog box the PrintJob's state will reflect options
%   chosen.
%
%   Ex:
%      pj = START( pj );
%
%   See also PRINT, PRINTOPT, PREPARE.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.4 $  $Date: 2002/04/10 17:10:13 $

pj.Active = 1;

%Get internal drivers wound up
if feature('NewPrintAPI')
	pj.Error = hardcopy( pj, 'start' );
end
