%HELPLINF Help file for L-inf design using LINF program.
%

% R. Y. Chiang & M. G. Safonov 3/86
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.8.4.3 $
% All Rights Reserved.
% ------------------------------------------------------------------
clc
disp('  ')
disp('  ')
disp('  ')
disp('  ')
disp('                << L-inf OPTIMAL CONTROL SYNTHESIS >>')
disp('  ')
disp('                   R. Y. Chiang & M. G. Safonov')
disp('  ')
disp('             Dept. of Electrical Engineering - Systems')
disp('                 University of Southern California')
disp('                   Los Angeles, CA. 90089-0781')
disp('  ')
disp('                           October, 1987')
disp('  ')
disp('                  (ver. 2.0, all rights reserved)')
disp('  ')
disp('   ')
disp('  ')
disp('  ')
disp('                     (strike a key to continue ...)')
pause
clc
disp('  ')
disp('        THE LINF COMPUTER PROGRAM IS DIVIDED INTO 3 PHASES:')
disp('  ---------------------------------------------------------------------')
disp('    Phase I:   Plant Augmentation')
disp('               (see M-files: AUGTF.M AUGSS.M)')
disp('  ')
disp('    Phase II:  Youla Parametrization (see script file YOULA.M)')
disp('  ')
disp('    Phase III: Interpolation Problem (see script file HKL1,2,3,4.M)')
disp('  ---------------------------------------------------------------------')
disp('    Remark 1: Inaccurate results may occur if the model reduction')
disp('              routines are not used properly. The following methods')
disp('              can improve the situation drastically:')
disp('              1). reset "tol" for a smaller reduced order model')
disp('                  (default: "tol" = 0.01), or')
disp('              2). set "MRtype = 3" to have a closer look of Hankel SV.')
disp('    Remark 2: The final controller can be reduced to (n-1) states')
disp('              using Moore balanced realization, which will confirm')
disp('              with Limebeer theoretical results.')
disp('   --------------------------------------------------------------------')
disp('               GOOD LUCK WITH YOUR L-INF DESIGN !!')
%
% -------- End of HELPLINF.M --- RYC/MGS 3/86 %
