function maskdisplay = mxpccreateenable( showEnable )
  
  maskdisplay = 'disp(''Create\nEnable\nSignal'');';
  maskdisplay = [maskdisplay, 'port_label(''output'',1,''E'');'];
  maskdisplay = [maskdisplay, 'port_label(''input'',1,''S'');' ];
  if showEnable == 1
    maskdisplay = [ maskdisplay, 'port_label(''input'', 2, ''L'');' ];
  end


%   Copyright 2001-2002 The MathWorks, Inc.
%   $Revision: 1.2.2.1 $  $Date: 2004/04/08 21:03:13 $
