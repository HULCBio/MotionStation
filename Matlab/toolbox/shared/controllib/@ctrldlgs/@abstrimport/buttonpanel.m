function Btnpanel = buttonpanel(this)
% BUTTONPANEL Create the standard button panel for the import dialog.

%   Author(s): Craig Buhr, John Glass
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:16:16 $

import java.awt.*;
import javax.swing.*;
import com.mathworks.mwswing.*;
import com.mathworks.page.utils.VertFlowLayout;
import javax.swing.table.*;
import javax.swing.border.*;

Btnpanel = MJPanel(FlowLayout(FlowLayout.RIGHT));

Btn1 = MJButton(sprintf('Import'));
Btn1.setName('Import')
h = handle( Btn1, 'callbackproperties');
h.ActionPerformedCallback = {@LocalImport this};

Btn2 = MJButton(sprintf('Close'));
Btn2.setName('Close');
h = handle( Btn2, 'callbackproperties');
h.ActionPerformedCallback = {@LocalClose this};

Btn3 = MJButton(sprintf('Help'));
Btn3.setName('Help')
h = handle( Btn3, 'callbackproperties');
h.ActionPerformedCallback = {@LocalHelp, this};

Btnpanel.add(Btn1);
Btnpanel.add(Btn2);
Btnpanel.add(Btn3);

% ------------------------------------------------------------------------%
% Function: LocalClose
% Purpose:  Destroy dialog Frame
% ------------------------------------------------------------------------%
function LocalClose(hSrc, event, this)

this.Frame.hide;
this.Frame.dispose;

% ------------------------------------------------------------------------%
% Function: LocalImport
% Purpose:  Import selected model
% ------------------------------------------------------------------------%
function LocalImport(hSrc, event, this)

this.import

% ------------------------------------------------------------------------%
% Function: LocalHelp
% Purpose:  Open Help
% ------------------------------------------------------------------------%
function LocalHelp(hSrc, event, this)

this.help
