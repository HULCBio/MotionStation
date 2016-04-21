% Run the third stage of the power window demo.

% Copyright 1994-2004 The MathWorks, Inc.

function powerwindow03script

msg  = chk_license('SimMechanics');
msg1 = chk_license('Power_System_Blocks');
msg2 = chk_license('Virtual_Reality_Toolbox');
msg3 = '';

if size(msg1) ~= 0
  if size(msg) == 0
    msg = msg1;
  elseif size(msg2) == 0
    msg = strcat(msg, ' and', msg1);
  else  
    msg = strcat(msg, ',', msg1);
  end
end
    
if size(msg2) ~= 0
  if size(msg) == 0
    msg = msg2;
  elseif size(msg3) == 0
    msg = strcat(msg, ' and', msg2);
  else  
    msg = strcat(msg, ',', msg2);
  end
end
    
if size(msg) == 0
  powerwindow03
else
  msg = ['You must install' msg, ...
         ' to run this power window demo.', ...
        ];
  errordlg(msg, 'Error', 'modal');
end
