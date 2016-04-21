function varargout = junctdlg(varargin),
%JUNCTDLG  Creates and manages the junction dialog box

%   E.Mehran Mestchian
%   Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.16.2.6 $  $Date: 2004/04/15 00:58:36 $

  error(nargchk(0,1,nargout));
  
    objectId = varargin{2};
    dynamic_dialog_l(objectId);


function dynamic_dialog_l(junctId)
  h = find(sfroot, 'id', junctId);
  if ~isempty(h)
      d = DAStudio.Dialog(h, 'Junction', 'DLG_STANDALONE');
      sf('SetDynamicDialog', junctId, d);
  end	 
  

