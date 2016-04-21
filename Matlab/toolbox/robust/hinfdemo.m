function hinfdemo
%HINFDEMO H-2 & H-inf Optimal Control Synthesis Demonstration.
%

% R. Y. Chiang & M. G. Safonov 3/88
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.8.4.3 $
% All Rights Reserved.
% ----------------------------------------------------------------
clc
disp('       ')
disp(' ')
disp(' ')
disp('               <<<  H2 & H-inf Optimal Control Synthesis Demo  >>>')
disp('    ')
disp('   ')
disp('                    1). SISO W-Plane H-inf Actuator design example')
disp(' ')
disp('                    2). MIMO H2 & H-inf fighter design example')
disp(' ')
disp('                    3). MIMO H-inf large space structure design example')
disp(' ')
disp('                    4). Go to the main menu')
disp(' ')
disp('                    0). Quit ..')
disp('  ')
Demono = input('       Select one of the above options: ');
% ----------------------------------------------------------------------
if Demono == 0
   clc
   disp(' ')
   disp(' ')
   disp('  ')
   disp('  ')
   disp('                   * * * * * * * * * * * * * * * * *')
   disp('                   *  End of HINFDEMO  ......      *')
   disp('                   *                               *')
   disp('                   * Good luck with your design !! *')
   disp('                   * * * * * * * * * * * * * * * * *')
   return
end
if Demono == 4
   rctdemo1
end
% ---------------------------------------------------------------------
if Demono == 1
   actdemo
   hinfdemo
end
% ----------------------------------------------------------------------
if Demono == 2
   hmatdemo
   hinfdemo
end
% ----------------------------------------------------------------------
if Demono == 3
   josedemo
   hinfdemo
end
%
% --------- End of HINFDEMO.M --- RYC/MGS %