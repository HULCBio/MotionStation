function varargout = statedlg(varargin),
%EVENTDLG  Creates and manages the state dialog box

%   E.Mehran Mestchian
%   Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.26.4.7 $  $Date: 2004/04/15 01:00:43 $

error(nargchk(0,1,nargout));

    objectId = varargin{2};
    dynamic_dialog_l(objectId);

function dynamic_dialog_l(stateId)
  
  h = find(sfroot, 'id', stateId);
  if ~isempty(h)
      d = DAStudio.Dialog(h, 'State', 'DLG_STANDALONE');
      sf('SetDynamicDialog',stateId, d);
  end	 


