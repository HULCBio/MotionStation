% Run the second stage of the power window demo.

% Copyright 1994-2004 The MathWorks, Inc.

function powerwindow02script

msg  = chk_license('SimMechanics');
msg1 = chk_license('Power_System_Blocks');
msg2 = '';

if size(msg) == 0
  msg = msg1;
elseif size(msg2) == 0
  msg = strcat(msg, ' and', msg1);
else  
  msg = strcat(msg, ',', msg1);
end

if size(msg) == 0
  powerwindow02
else
  msg = ['You must install' msg, ...
         ' to run this power window demo.', ...
        ];
  errordlg(msg, 'Error', 'modal');
end
