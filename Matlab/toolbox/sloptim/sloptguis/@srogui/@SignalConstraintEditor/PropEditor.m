function hEditor = PropEditor(this)
% Returns singleton instance of Property Editor for signal constraints.

%   Authors: Adam DiVergilio and P. Gahinet
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:44:35 $
persistent hPropEdit
if nargin==1 && isempty(hPropEdit)
   % Create and target prop editor if it does not yet exist
   hPropEdit = cstprefs.propeditor({'Labels','Limits'});
end
hEditor = hPropEdit;
hEditor.setTarget(this)