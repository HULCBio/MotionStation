function ltrdemo
%LTRDEMO Demo of LQG/LTR optimal control synthesis.
%

% R. Y. Chiang & M. G. Safonov 3/88
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.8.4.3 $
% All Rights Reserved.
% ---------------------------------------------------------------
clc
disp('       ')
disp(' ')
disp(' ')
disp('                <<<  LQG/LTR Optimal Control Synthesis Demo  >>>')
disp('    ')
disp('   ')
disp('                     1). SISO fighter design example')
disp(' ')
disp('                     2). MIMO fighter design example')
disp(' ')
disp('                     0). Quit ...')
disp('  ')
Demono = input('       Select one of the above options: ');
format short e
% ----------------------------------------------------------------------
if isequal(Demono,0)
   clc
   disp(' ')
   disp(' ')
   disp('  ')
   disp('  ')
   disp('                   * * * * * * * * * * * * * * * * *')
   disp('                   *  End of LQG/LTRDEMO  ......   *')
   disp('                   *                               *')
   disp('                   * Good luck with your design !! *')
   disp('                   * * * * * * * * * * * * * * * * *')
end
if isequal(Demono,0)
   return
elseif isequal(Demono,1)
   sltrdemo
elseif isequal(Demono,2)
   mltrdemo
end
ltrdemo
%
% --------- End of LTRDEMO.M --- RYC/MGS %