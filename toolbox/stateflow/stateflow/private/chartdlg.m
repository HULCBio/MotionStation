function varargout = chartdlg(varargin),
%EVENTDLG  Creates and manages the chart dialog box

%   E.Mehran Mestchian
%   Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.26.2.6 $  $Date: 2004/04/15 00:56:11 $

error(nargchk(0,1,nargout));

    objectId = varargin{2};
    dynamic_dialog_l(objectId);

%---------------------------------------------------------------------------------
function dynamic_dialog_l(chartId)
%
%  
%  
   h = find(sfroot, 'id', chartId);
  
  if ~isempty(h)
      d = DAStudio.Dialog(h, 'Chart', 'DLG_STANDALONE');
      sf('SetDynamicDialog',chartId, d);
  end	 

