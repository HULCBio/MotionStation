% Run the fifth stage of the power window demo.

% Copyright 1994-2004 The MathWorks, Inc.

function powerwindow05script

msg = chk_license('SimMechanics');
msg1 = chk_license('Power_System_Blocks');
msg2 = chk_license('Signal_Blocks');
msg3 = chk_license('Fixed-Point_Blocks');
msg4 = chk_license('XPC_Target');
msg5 = '';

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
    
if size(msg3) ~= 0
  if size(msg) == 0
    msg = msg3;
  elseif size(msg4) == 0
    msg = strcat(msg, ' and', msg3);
  else  
    msg = strcat(msg, ',', msg3);
  end
end
    
if size(msg4) ~= 0
  if size(msg) == 0
    msg = msg4;
  elseif size(msg5) == 0
    msg = strcat(msg, ' and', msg4);
  else  
    msg = strcat(msg, ',', msg4);
  end
end

if ~ispc
  msg = 'This demo contains xPC blocks and can only be run on a PC.';
  errordlg(msg, 'Error', 'modal'); 
elseif size(msg) == 0
  powerwindow05
else
  msg = ['You must install' msg, ...
         ' to run this power window demo.', ...
        ];
  errordlg(msg, 'Error', 'modal');
end
