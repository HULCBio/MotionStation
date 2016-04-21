function hEditor = PropEditor(this,CurrentFlag)
%PROPEDITOR  Returns instance of Property Editor for response plots.
%
%   PropEdit = PROPEDITOR(GraphEditor) returns the (unique) instance of  
%   Property Editor for the SISO Tool's graphical editors, and creates 
%   it if necessary.
%
%   PropEdit = PROPEDITOR(GraphEditor,'current') returns [] if no Property 
%   Editor exists.

%   Authors: Adam DiVergilio and P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.2 $  $Date: 2002/04/10 05:02:33 $
persistent hPropEdit
if nargin==1 & isempty(hPropEdit) & usejava('MWT')
   % Create and target prop editor if it does not yet exist
   hPropEdit = cstprefs.propeditor({'Labels','Limits','Options'});
end
hEditor = hPropEdit;