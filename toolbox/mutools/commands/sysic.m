% SYSIC is a M-file used to form interconnections of SYSTEM
%   matrices (it also works for interconnections of VARYING
%   matrices). A number of variables need to be in the workspace
%   to run SYSIC. These are explained in the manual.
%
%   See also: ABV, MADD, DAUG, MMULT, SBS and STARP.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

%   mod 8/17  10:06pm
%   modified to run under MATLAB Version 4.0      GJB   10 Dec 92

if ~exist('systemnames')
  disp(['error_in_SYSIC: need SYSTEMNAMES to be set']);
  return
end
if ~exist('inputvar')
  disp(['error_in_SYSIC: need INPUTVAR to be set']);
  return
end
if ~exist('outputvar')
  disp(['error_in_SYSIC: need OUTPUTVAR to be set']);
  return
end
if ~exist('cleanupsysic')
  cleanupsysic = 'no';
end

[numxinp_ms,xndf_ms,xipnt_ms,xinames_ms,xinlen_ms, ...
     ximaxl_ms,err_ms] = inpstuff(inputvar);
if err_ms == 1
  disp(['error_in_SYSIC: problem in INPUTVAR']);
  return
end

[numsys_ms,names_ms,namelen_ms,maxnamelen_ms] = namstuff(systemnames);

if ximaxl_ms > maxnamelen_ms
  maxxxx_ms = ximaxl_ms;
else
  maxxxx_ms = maxnamelen_ms;
end
para_ms = [];
sysdata_ms= [];
inpoint_ms = zeros(1,numsys_ms+xndf_ms);
outpoint_ms = zeros(1,numsys_ms+xndf_ms);
sysdata_ms = zeros(3,numsys_ms+xndf_ms);
systype_ms = [];
varyflg_ms = 0;
systflg_ms = 0;
for i_ms=1:numsys_ms
  tmp_ms = names_ms(i_ms,1:namelen_ms(i_ms));
  extmp_ms = exist(tmp_ms);
  if extmp_ms ~= 1
    disp(['error_in_SYSIC:']);
    disp(['systemnames variable    "' tmp_ms '"   not found in workspace']);
    return
  end
  eval(['[mtype_ms,mrows_ms,mcols_ms,mnum_ms] = minfo(' tmp_ms ');']);
%****** ADDED TO MAKE WORK FOR VERSION 4 MATLAB *****  11 DEC 29 ***%
  mtype_ms;
  [mrows_ms,mcols_ms,mnum_ms];
%^^^^^^ ADDED TO MAKE WORK FOR VERSION 4 MATLAB *****  11 DEC 29 ***%
  if mtype_ms == 'vary' & systflg_ms == 1
    error('VARYING matrices and SYSTEM matrices not both allowed');
    return
  elseif mtype_ms == 'syst' & varyflg_ms == 1
    error('VARYING matrices and SYSTEM matrices not both allowed');
    return
  elseif mtype_ms == 'syst'
    systflg_ms = 1;
  elseif mtype_ms == 'vary'
    varyflg_ms = 1;
  end
%
% SYSDATA is (3 by NUMSYS+XNDF), it has states (or points),
%                  outputs (rows), and inputs (columns). Note
%                  that it will have data for the XTERNAL INPUTS
% SYSTYPE is (NUMSYS by 4) character string. it DOES NOT have
%                                         the external inputs
%
  sysdata_ms(1,i_ms) = mnum_ms;
  sysdata_ms(2,i_ms) = mrows_ms;
  sysdata_ms(3,i_ms) = mcols_ms;
  systype_ms = [systype_ms ; mtype_ms];
%
% INPOINT(i)+j points to the j'th input of SYSTEM_i.  it does
%      have the external inputs included at the end (numsys+xndf)
% OUTPOINT(i)+k points to the k'th output of SYSTEM_i. it does
%      have the external inputs included at the end (numsys+xndf)
%
  tmp2_ms = ['para_ms = daug(para_ms,' tmp_ms ');'];
  eval(tmp2_ms);
  if i_ms > 1
    inpoint_ms(i_ms) = sysdata_ms(3,i_ms-1) + inpoint_ms(i_ms-1);
    outpoint_ms(i_ms) = sysdata_ms(2,i_ms-1) + outpoint_ms(i_ms-1);
  end
end


inpoint_ms(numsys_ms+1) = inpoint_ms(numsys_ms) + sysdata_ms(3,numsys_ms);
outpoint_ms(numsys_ms+1) = outpoint_ms(numsys_ms) + sysdata_ms(2,numsys_ms);
sysdata_ms(:,numsys_ms+1) = [0; xipnt_ms(1,2) ; xipnt_ms(1,2)];
for i_ms=2:xndf_ms
  inpoint_ms(numsys_ms+i_ms)=inpoint_ms(numsys_ms+i_ms-1)+xipnt_ms(i_ms-1,2);
  outpoint_ms(numsys_ms+i_ms)=outpoint_ms(numsys_ms+i_ms-1)+xipnt_ms(i_ms-1,2);
  sysdata_ms(:,numsys_ms+i_ms)=[0; xipnt_ms(i_ms,2) ; xipnt_ms(i_ms,2)];
end

nameds_ms = [];
for i_ms=1:numsys_ms
  padd_ms = mtblanks(maxxxx_ms-namelen_ms(i_ms));
  nameds_ms = [nameds_ms ; names_ms(i_ms,1:namelen_ms(i_ms)) padd_ms];
end
for i_ms=1:xndf_ms
  padd_ms = mtblanks(maxxxx_ms-xinlen_ms(i_ms));
  nameds_ms = [nameds_ms ; xinames_ms(i_ms,1:xinlen_ms(i_ms)) padd_ms];
end
names_ms = nameds_ms;

% all names are called NAME_MS with length NAMELEN

namelen_ms = [namelen_ms ; xinlen_ms];

% add the identity at the bottom for the external inputs

para_ms = daug(para_ms,eye(numxinp_ms));
[alltype_ms,allrows_ms,allcols_ms,allnum_ms] = minfo(para_ms);

% DETERMINE NUMBER OF OUTPUTS

numout_ms = 0;
[ard_ms,arl_ms,er_ms] = pass1(outputvar);
if er_ms ~= 0
  disp(['error_in_SYSIC: problem in outputvar']);
  return
end
for i_ms=1:length(arl_ms)
  [od_ms,odl_ms,fsys_ms,gains_ms,er_ms] = ...
       pass2(i_ms,ard_ms,arl_ms,names_ms,namelen_ms,sysdata_ms);
  if er_ms ~= 0
    disp(['error_in_SYSIC: problem in outputvar']);
    return
  end
  sz_ms = 0;
  for j_ms = 1:length(odl_ms)
    [out_ms,er_ms] = pass3(j_ms,od_ms,odl_ms);
    if er_ms ~= 0
      disp(['error_in_SYSIC: problem with commas or colons in outputvar']);
      return
    end
    if sz_ms == 0
      sz_ms = length(out_ms);
    else
      if sz_ms ~= length(out_ms)
        disp(['error_in_SYSIC: inconsistent number of signals,']);
        disp(['CHECK: outputvar portion  ' '''' ...
            ard_ms(i_ms,1:arl_ms(i_ms)) '''']);
        return
      end
    end
  end
  numout_ms = numout_ms + length(out_ms);
end

% Feedback interconnection matrix starts as EMPTY
myk_ms = [];

% MAIN LOOP TO DETERMINE INTERCONNECTING FEEDBACK

for k_ms=1:numsys_ms+1
  location_ms = 0;  %  location in feedback matrix for input_to_sysi
  if k_ms <= numsys_ms
    tmp_ms = names_ms(k_ms,1:namelen_ms(k_ms));
    invar_ms = ['input_to_' tmp_ms ' = '];
    eval(['ex_ms = exist(''input_to_' tmp_ms ''');']);
%****** ADDED TO MAKE WORK FOR VERSION 4 MATLAB *****  11 DEC 29 ***%
    ex_ms;
%^^^^^^ ADDED TO MAKE WORK FOR VERSION 4 MATLAB *****  11 DEC 29 ***%
    if ex_ms ~= 1
      disp(['warning_in_SYSIC: INPUTS TO ' tmp_ms ' NOT BEING USED']);
    else
      eval(['var_ms = input_to_' tmp_ms ';']);
    end
    ff_ms = zeros(sysdata_ms(3,k_ms),allrows_ms); % feedback for input_to_sysi
  else
    invar_ms = ['outputvar = '];
    var_ms = outputvar;
    ff_ms = zeros(numout_ms,allrows_ms); % feedback for outputvar
  end

% length(arl) tell how many GROUPS of inputs (semicolons)

  [ard_ms,arl_ms,er_ms] = pass1(var_ms);
  if er_ms == 1
    disp(['error_in_SYSIC: expression lacks square brackets[],']);
    disp(['   CHECK: ' invar_ms '''' var_ms '''']);
    return
  elseif er_ms == 2
    disp(['error_in_SYSIC: inconsistent number of parenthesis,']);
    disp(['   CHECK: ' invar_ms '''' var_ms '''']);
    return
  elseif er_ms == 3 | er_ms == 4
    disp(['error_in_SYSIC: right paren before left paren,']);
    disp(['   CHECK: ' invar_ms '''' var_ms '''']);
    return
  elseif er_ms == 5
    disp(['error_in_SYSIC: square brackets inside parenthesis,']);
    disp(['   CHECK: ' invar_ms '''' var_ms '''']);
    return
  else
    szin_ms = 0;
    for i_ms=1:length(arl_ms)

%      for each group, pass2 splits ARD into the summation
%      of its parts - each part has the same number of signals,
%      just from different components (also have constant
%      scaling factors)

      [od_ms,odl_ms,fsys_ms,gains_ms,er_ms] = ...
           pass2(i_ms,ard_ms,arl_ms,names_ms,namelen_ms,sysdata_ms);
      if er_ms == 1
        disp('error_in_SYSIC: too many scalar multiplies')
        disp(['   CHECK: ' invar_ms '''' var_ms '''']);
        return
      elseif er_ms == 2
        disp('error_in_SYSIC: poorly placed parenthesis')
        disp(['   CHECK: ' invar_ms '''' var_ms '''']);
        return
      elseif er_ms == 3
        disp('error_in_SYSIC: wrong number of parenthesis')
        disp(['   CHECK: ' invar_ms '''' var_ms '''']);
        return
      elseif er_ms == 4
        disp('error_in_SYSIC: scalar mult positioned incorrectly')
        disp(['   CHECK: ' invar_ms '''' var_ms '''']);
        return
      elseif er_ms == 5
        disp('error_in_SYSIC: unknown system specified')
        disp(['   CHECK: ' invar_ms '''' var_ms '''']);
        return
      else
        szout_ms = 0;
        for j_ms=1:length(odl_ms)
          [out_ms,er_ms] = pass3(j_ms,od_ms,odl_ms);
          if szout_ms == 0
            szout_ms = length(out_ms);
          elseif szout_ms ~= length(out_ms)
            disp('error_in_SYSIC: inconsistent combination of signals:')
            disp(['   CHECK: ' invar_ms '''' var_ms '''']);
            return
          end
          if er_ms == 1
            disp('error_in_SYSIC: two or more commas in a row')
            disp(['   CHECK: ' invar_ms '''' var_ms '''']);
            return
          elseif er_ms == 2
            disp('error_in_SYSIC: too many colons between commas')
            disp(['   CHECK: ' invar_ms '''' var_ms '''']);
            return
          else
            sysloc_ms = outpoint_ms(fsys_ms(j_ms));
            ff_ms = gaino(out_ms,gains_ms(j_ms),ff_ms,location_ms,sysloc_ms);
          end
        end
        szin_ms = szin_ms + szout_ms;
        location_ms = location_ms + length(out_ms);
      end
    end
    if k_ms <= numsys_ms
      if sysdata_ms(3,k_ms) ~= szin_ms
        disp('error_in_SYSIC: wrong number of inputs to a system')
        disp(['   CHECK: ' invar_ms '''' var_ms '''']);
        return
      end
    end
    myk_ms = [myk_ms ; ff_ms];
  end
 end
% END OF MAIN LOOP

% WRAP IT UP
 topd_ms = allcols_ms - numxinp_ms;
 topid_ms = eye(topd_ms);
 paraout_ms = mmult(myk_ms,para_ms);
 if exist('sysoutname')
   eval([sysoutname ' = starp(topid_ms,paraout_ms,topd_ms,topd_ms);']);
 else
   ic_ms = starp(topid_ms,paraout_ms,topd_ms,topd_ms);
 end

% Cleanup

if strcmp(cleanupsysic,'yes')
  if exist('sysoutname')
    clear sysoutname
  end
  clear outputvar inputvar systemnames
  for i_ms=1:numsys_ms
    var_ms = ['clear input_to_' names_ms(i_ms,1:namelen_ms(i_ms)) ';'];
    eval(var_ms);
  end
end

clear para_ms sysdata_ms inpoint_ms outpoint_ms
clear maxnamelen_ms sysdata_ms systype_ms varyflg_ms systflg_ms
clear topd_ms topid_ms mtype_ms mrows_ms mcols_ms mnum_ms
clear extmp_ms ard_ms arl_ms names_ms
clear allcols_ms allnum_ms allrows_ms alltype_ms
clear myk_ms paraout_ms location_ms out_ms gains_ms ff_ms i_ms
clear od_ms odl_ms fsys_ms er_ms k_ms j_ms tmp_ms padd_ms
clear ex_ms feed_ms namelen_ms sysloc_ms var_ms argu_ms
clear invar_ms sz_ms szin_ms szout_ms ximaxl_ms xinames_ms
clear numxinp_ms numout_ms tmp2_ms numsys_ms
clear err_ms maxxxx_ms szout_ms xinlen_ms xipnt_ms xndf_ms
clear cleanupsysic nameds_ms