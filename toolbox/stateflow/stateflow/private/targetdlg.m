function varargout = targetdlg(varargin),
%TARGETDLG  Creates and manages the main target dialog box
%           There are two other dialog boxes associated with
%           target manager. They are defined in dlg_coder_flags.m
%           and dlg_custom_target.m functions.

%   E.Mehran Mestchian
%   Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.68.2.8 $  $Date: 2004/04/15 01:01:04 $
nargchk(0,1,nargout);
  
    objectId = varargin{2};
    deleteOnCancel = 0;
    if(nargin > 2)
        deleteOnCancel = varargin{3};
    end
    dynamic_dialog_l(objectId, deleteOnCancel);

%--------------------------------------------------------------------------
%  ddg constructor
%--------------------------------------------------------------------------
function dynamic_dialog_l(targetId, deleteOnCancel)
  h = find(sfroot, 'id', targetId);
  if ~isempty(h)
      if(deleteOnCancel)
        h.Tag = ['_DDG_INTERMEDIATE_' sf_scalar2str(targetId)];
      end
	  d = DAStudio.Dialog(h, 'Target', 'DLG_STANDALONE');
      sf('SetDynamicDialog', targetId, d);
  end	
