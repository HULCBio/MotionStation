% file: ex_f14ic.m
%

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

  ex_f14wt
  systemnames = 'W_in A_S A_R F14_nom antia_filt hqmod_p hqmod_beta ';
  systemnames = [systemnames ' W_act W_n W_p W_beta'];
  inputvar  = '[in_unc{2}; sn_nois{3}; roll_cmd; beta_cmd; delta_dstab; delta_rud]';
  outputvar = '[ W_in; W_p; W_beta; W_act;  roll_cmd; beta_cmd; antia_filt + W_n ]';
	input_to_W_in       = '[ delta_dstab; delta_rud ]';
	input_to_A_S        = '[ delta_dstab + in_unc(1) ]';
	input_to_A_R        = '[ delta_rud + in_unc(2) ]';
	input_to_W_act      = '[ A_S; A_R ]';
	input_to_F14_nom    = '[ A_S(1); A_R(1) ]';
	input_to_antia_filt = '[ F14_nom(4); F14_nom(3); F14_nom(2) ]';
	input_to_hqmod_beta = '[ beta_cmd ]';
	input_to_hqmod_p    = '[ roll_cmd ]';
	input_to_W_beta     = '[ hqmod_beta - F14_nom(1) ]';
	input_to_W_p        = '[ hqmod_p - F14_nom(3) ]';
	input_to_W_n        = '[ sn_nois ]';
  sysoutname = 'F14IC';
  cleanupsysic = 'yes';
  sysic

disp(' The interconnection structure is in F14IC:  ')
disp(' ')
minfo(F14IC)