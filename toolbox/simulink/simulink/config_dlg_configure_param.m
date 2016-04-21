function config_dlg_configure_param(action, hDlg, hSrc)
%

% Copyright 2003-2004 The MathWorks, Inc.
% $Revision: 1.1.6.6 $
  if ~isa(hSrc, 'Simulink.BaseConfig')
    error('This function must be associated with a configuration set object');
  end

  model = hSrc.getModel;
  
  if isempty(model)
    return;
  end
  
  data = getUserData(hDlg, 'Tag_ConfigSet_Optimization_Configure');

  if usejava('MWT')
    dlgID = [];
  else
    dlgID = -1;
  end
  
  if ~isempty(data) && isfield(data, 'hConfigDlg')
    dlgID = data.hConfigDlg;
  end
    
  errmsg = [];
  
  switch action
    case 'Show'
     if usejava('MWT')
       if isempty(dlgID) || ~ishandle(dlgID)
         eval(['dlgID = slwsprmattrib(''Create'',model,' ...
               'hDlg);'], ...
              'errmsg = lasterr;');
         eval(['dlgID = slwsprmattrib(''reshow'',model,' ...
               'hDlg, dlgID);'], ...
              'errmsg = lasterr;');
       else
         eval(['dlgID = slwsprmattrib(''reshow'',model,' ...
               'hDlg, dlgID);'], ...
              'errmsg = lasterr;');
       end
     else
       if dlgID == -1
         eval(['dlgID = tunable_param_dlg(''Create'',model,' ...
               'hDlg, dlgID, hDlg);'], ...
              'errmsg = lasterr;');
       else
         eval(['dlgID = tunable_param_dlg(''reshow'',model,' ...
               'hDlg, dlgID);'], ...
              'errmsg = lasterr;');
       end
       
     end

     data.hConfigDlg = dlgID;
     setUserData(hDlg, 'Tag_ConfigSet_Optimization_Configure', data);

   case 'ParentClose'
    
    if usejava('MWT')
      if ~isempty(dlgID)
        hd = findobj(allchild(0), 'Title', ...
                     get(dlgID,'Title'));
        dlgID.dispose;
        if ishandle(hd)
          delete(hd);
        end
      end
    else
      if dlgID ~= -1
        delete(dlgID);
      end
    end
  end
  
  % EOF
    