function modelddg_readOnly_cb(h, dlgH)

% Copyright 2003 The MathWorks, Inc.

readOnly = dlgH.getWidgetValue('readOnly_tag');
if readOnly
    h.EditVersionInfo = 'ViewCurrentValues';
else
    h.EditVersionInfo = 'EditFormatStrings';
end