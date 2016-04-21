function hEditor = PropEditor(plot,CurrentFlag)
%PROPEDITOR  Returns instance of Property Editor for response plots.
%
%   HEDITOR = PROPEDITOR(PLOT) returns the (unique) instance of  
%   Property Editor for w/r plots, and creates it if necessary.
%
%   HEDITOR = PROPEDITOR(PLOT,'current') returns [] if no Property 
%   Editor exists.

%   Authors: Adam DiVergilio and P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:27:07 $
persistent hPropEdit
if nargin==1 & isempty(hPropEdit) & usejava('MWT')
   % Create and target prop editor if it does not yet exist
   hPropEdit = cstprefs.propeditor({'Labels','Limits','Units','Style','Characteristics'});
end
hEditor = hPropEdit;