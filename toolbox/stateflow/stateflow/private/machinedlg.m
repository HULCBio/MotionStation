function varargout = machinedlg(varargin),
%EVENTDLG  Creates and manages the machine dialog box

%   E.Mehran Mestchian
%   Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.18.2.6 $  $Date: 2004/04/15 00:58:44 $

error(nargchk(0,1,nargout));


    objectId = varargin{2};
    dynamic_dialog_l(objectId);


function dynamic_dialog_l(machineid)
  
  h = find(sfroot, 'id', machineid);
  if ~isempty(h)
      d = DAStudio.Dialog(h, 'Machine', 'DLG_STANDALONE');
      sf('SetDynamicDialog',machineid, d);
  end

