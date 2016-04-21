

function varargout = transdlg(varargin),
%TRANSDLG  Creates and manages the transition dialog box

%   E.Mehran Mestchian January 1997
%   Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.19.2.6 $  $Date: 2004/04/15 01:01:13 $

error(nargchk(0,1,nargout));

    objectId = varargin{2};
    dynamic_dialog_l(objectId);

function dynamic_dialog_l(transId)
  
  r = sfroot;
  type = sf('get', transId, '.type');
  
  
  if (type == 0) % SIMPLE wire
      idWithHandle = transId;
  elseif (type == 2) % SUPER wire
      idWithHandle = sf('get', transId, '.firstSubWire');
  else % SUB wire
      idWithHandle = transId;
      nextId = idWithHandle;
      while (nextId ~= 0)
          idWithHandle = nextId;
          nextId = sf('get', idWithHandle, '.subLink.before');
      end
  end
		
  h = r.find('id', idWithHandle);

  if ~isempty(h)		
        d = DAStudio.Dialog(h, 'State', 'DLG_STANDALONE');
        sf('SetDynamicDialog', transId, d);
  end
    
  
