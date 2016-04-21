function varargout = datadlg(varargin),
%DATADLG  Creates and manages the data dialog box

%   E.Mehran Mestchian
%   Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.46.4.7 $  $Date: 2004/04/15 00:56:39 $

error(nargchk(0,1,nargout));

    objectId = varargin{2};
    dynamic_dialog_l(objectId);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dynamic_dialog_l(dataId)

  h = find(sfroot, 'id', dataId);
  
  if ~isempty(h)
      d = DAStudio.Dialog(h, 'Data', 'DLG_STANDALONE');
      sf('SetDynamicDialog',dataId, d);
  end	 
