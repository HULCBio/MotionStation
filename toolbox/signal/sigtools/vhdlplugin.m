function plugins = vhdlplugin
%VHDLPLUGIN   Plug-in file for the VHDL Filter product.

%   Author(s): J. Schickler
%   Copyright 2003-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2004/04/20 23:21:23 $

plugins.fdatool = @vhdldlg_plugin;

% -------------------------------------------------------------------------
function vhdldlg_plugin(hFDA)

% Add the VHDL menu item.
addtargetmenu(hFDA,'Generate HDL ...',{@vhdldlg_cb,hFDA},'generatehdl');

% -------------------------------------------------------------------------
function vhdldlg_cb(hcbo, eventStruct, hFDA)

Hd = getfilter(hFDA);
hDlg = getcomponent(hFDA, '-class', 'hdlgui.vhdldlg');

if isempty(hDlg),
  [cando, msg] = ishdlable(Hd);
  if cando
    hDlg = hdlgui.vhdldlg(Hd);
    
    addcomponent(hFDA, hDlg);

  else
    senderror(hFDA, msg);
    return;
  end
end

% Make sure that the dialog is rendered.
if ~isrendered(hDlg),
    render(hDlg);
    % Set the filter for the first time
    hDlg.Filter = Hd;
    if ishdlable(Hd)
      hDlg.Enable = 'on';
    else
      hDlg.Enable = 'off';
    end
    % Create a listener on FDATool's Filter.
    l = handle.listener(hFDA, 'FilterUpdated', {@lclfilter_listener, hDlg});
    setappdata(hDlg.FigureHAndle, 'fdatool_listener', l);
    hDlg.centerdlgonfig(hFDA);
end

% Make sure that the dialog is visible
set(hDlg, 'Visible', 'On');
figure(hDlg.FigureHandle);

% -------------------------------------------------------------------------
function lclfilter_listener(hFDA, eventData, hDlg)

Hd = getfilter(hFDA);
hDlg.Filter = Hd;
if ishdlable(Hd),
    enab = 'on';
else
    enab = 'off';
end

hDlg.Enable = enab;

% [EOF]
