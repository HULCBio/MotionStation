% file: ex_f14s1.m
%

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

  systemnames = 'W_in A_S A_R F14_nom antia_filt hqmod_p hqmod_beta ';
  inputvar  = '[in_unc{2}; roll_cmd; beta_cmd; delta_dstab; delta_rud]';
  outputvar = '[W_in; hqmod_p; F14_nom(2); hqmod_beta; F14_nom(1);  ';
  outputvar = [outputvar ' roll_cmd; beta_cmd; antia_filt ]'];
	input_to_W_in       = '[ delta_dstab; delta_rud ]';
	input_to_A_S        = '[ delta_dstab + in_unc(1) ]';
	input_to_A_R        = '[ delta_rud + in_unc(2) ]';
	input_to_F14_nom    = '[ A_S(1); A_R(1) ]';
	input_to_antia_filt = '[ F14_nom(4); F14_nom(3); F14_nom(2) ]';
	input_to_hqmod_beta = '[ beta_cmd ]';
	input_to_hqmod_p    = '[ roll_cmd ]';
  sysoutname = 'F14SIM';
  cleanupsysic = 'yes';
  sysic

disp(' The interconnection structure is in F14SIM:  ')
disp(' ')
minfo(F14SIM)