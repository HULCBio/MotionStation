% DKIT
%
% This file implements mu-synthesis iteration by D-K iteration.
% A number of variables associated with the particular problem
% need to be specified by the user.  See Manual.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.10.2.3 $

echo off

% VARIABLE NAMES USED IN THE DKIT PROGRAM
%   (All of these variables names are used)
%
% mtype_dk  mrows_dk   mcols_dk  mnum_dk  dl_dk       dispdata_dk
% x_dk_g    again_dk   gf_dk     g_dk     bnds_dk     tmpdl_dk
% tmpdr_dk  tmpdl_dkg  tmpdr_dkg sens_dk  iter_num_dk ag_dk
% first_dk  K_DK       BNDS_DK   DSC_DK   RE_DK       k_dk
% prevd_dk  apstr_dk   GF_DK     tmpdl_dk max_iter_dk chflg_dk
% dr_dk     x_dk       ag_dk     oldgm_dk
% ddd_dk    ddcols_dk  ddd_dkn   dder_dk  ddindv_dk   ddrows_dk
% hinf_go   oldgm_dk   fiti_dk   ddrp_dk  SKIP_DK     apstr_dk_old
% DR_DK     DL_DK      DSENSE_DK rego_dk mbnds_dk
% tmp_omega_dk


% DK_DEF_NAME is a string defined by the user containing the
% filename which, when run, creates the user-defined variables
% needed by DKIT
if exist('DK_DEF_NAME')
    if isstr(DK_DEF_NAME)
        if exist('OMEGA_DK')
            tmp_omega_dk = OMEGA_DK;
            eval(DK_DEF_NAME)
        else
            eval(DK_DEF_NAME)
        end
    else
        dk_defin  % Generic file with DKIT variables defined
    end
else
    dk_defin % Generic file with DKIT variables defined
end

if ~exist('RICMTHD_DK')
    RICMTHD_DK = [];
end
if isempty(RICMTHD_DK)
    RICMTHD_DK = 2;
end
if ~exist('EPP_DK')
    EPP_DK = [];
end
if isempty(EPP_DK)
    EPP_DK = 1e-6;
end
if ~exist('EPR_DK')
    EPR_DK = [];
end
if isempty(EPR_DK)
    EPR_DK = 1e-8;
end
if ~exist('GMAX_DK')
    GMAX_DK = [];
end
if isempty(GMAX_DK)
    GMAX_DK = 100;
end
if ~exist('GMIN_DK')
    GMIN_DK = [];
end
if isempty(GMIN_DK)
    GMIN_DK = 0;
end
if ~exist('GMAX_DK_PLAN')
    GMAX_DK_PLAN = [];
end
if isempty(GMAX_DK_PLAN)
    GMAX_DK_PLAN = 2;
end
if ~exist('NAME_DK')
    NAME_DK = [];
end
if isempty(NAME_DK)
    NAME_DK = '';
end
if ~exist('GTOL_DK')
    GTOL_DK = [];
end
if isempty(GTOL_DK)
    GTOL_DK = 0.01*(GMAX_DK-GMIN_DK);
end
if ~exist('AUTOINFO_DK')
    AUTOINFO_DK = [];
    auto_dk = 0;
    auto_visual_dk = 1;
elseif isempty(AUTOINFO_DK)
    auto_dk = 0;
    auto_visual_dk = 1;
else
    auto_dk = 1;
end
if ~exist('DISCRETE_DK')
    DISCRETE_DK = [];
end
if isempty(DISCRETE_DK)
    DISCRETE_DK = 0;
end

if ~exist('NOMINAL_DK')
    error('Open-Loop Interconnection (NOMINAL_DK) cannot be found');
    return
end
if ~exist('BLK_DK')
    error('Block structure (BLK_DK) cannot be found');
    return
end
if ~exist('OMEGA_DK')
    error('Frequency Response variable (OMEGA_DK) cannot be found');
    return
end
if ~exist('NCONT_DK')
    error('# of Control Actuators (NCONT_DK) cannot be found');
    return
end
if ~exist('NMEAS_DK')
    error('# of Feedback Measurements (NMEAS_DK) cannot be found');
    return
end


tmp_dk = [NCONT_DK NMEAS_DK];
for tmpi_dk=1:size(BLK_DK,1)
        if BLK_DK(tmpi_dk,2)==0
                tmp_dk = tmp_dk + abs(BLK_DK(tmpi_dk,1))*[1 1];
        else
                tmp_dk = tmp_dk + abs(BLK_DK(tmpi_dk,:));
        end
end
if unum(NOMINAL_DK)~=tmp_dk(1) | ynum(NOMINAL_DK)~=tmp_dk(2)
    clear tmp_dk tmpi_dk
    error('Incompatible Dimensions: NOMINAL_DK, BLK_DK, NMEAS_DK, NCONT_DK');
    return
end
clear tmp_dk tmpi_dk

again_dk = 1;
while again_dk
    if auto_dk == 0
        iter_num_dk = input(' Starting mu iteration #: ');
        iter_stop_dk = inf;
    else
        if length(AUTOINFO_DK)<2
            error('Invalid AUTOINFO_DK');
            return
        elseif length(AUTOINFO_DK)==2
            iter_num_dk = AUTOINFO_DK(1);
            iter_stop_dk = AUTOINFO_DK(2);
            auto_visual_dk = 0;
            autoord_dk = 5;
        elseif length(AUTOINFO_DK)==3
            iter_num_dk = AUTOINFO_DK(1);
            iter_stop_dk = AUTOINFO_DK(2);
            auto_visual_dk = AUTOINFO_DK(3);
            autoord_dk = 5;
        elseif length(AUTOINFO_DK)>3
            iter_num_dk = AUTOINFO_DK(1);
            iter_stop_dk = AUTOINFO_DK(2);
            auto_visual_dk = AUTOINFO_DK(3);
            if length(AUTOINFO_DK)==(3+size(BLK_DK,1))
                autoord_dk = floor(abs(AUTOINFO_DK(4:length(AUTOINFO_DK))));
            else
                autoord_dk = 5;
            end
        end
        if iter_num_dk>iter_stop_dk
            error('Stopping iteration should be greater than Starting iteration');
            return
        end
    end
    if iter_num_dk > 0 & ceil(iter_num_dk) == floor(iter_num_dk)
        again_dk = 0;
    else
        if auto_dk == 0
            disp('Starting iteration should be a Positive Integer');
        else
            error('Automatic Iteration Matrix is Incorrect');
            return
        end
    end
end

if iter_num_dk > 1
    if length(OMEGA_DK) ~= length(tmp_omega_dk)
        disp(['<<<<Existing OMEGA_DK and ' ...
            DK_DEF_NAME ' OMEGA_DK clash>>>>'])
        rego_dk = 1;
        while rego_dk
            x_dk = input('    Use existing OMEGA_DK? (y/n) ','s');
            if strcmp(x_dk,'y') | strcmp(x_dk,'''y''')
                OMEGA_DK = tmp_omega_dk;
                rego_dk = 0;
            elseif strcmp(x_dk,'n') | strcmp(x_dk,'''n''')
                rego_dk = 0;
            else
                disp('Please use y or n')
            end
        end
    elseif any(OMEGA_DK ~= tmp_omega_dk)
        disp(['<<<< Existing OMEGA_DK and ' ...
        DK_DEF_NAME ' OMEGA_DK clash>>>>'])
        rego_dk = 1;
        while rego_dk
            x_dk = input('    Use existing OMEGA_DK? (y/n) ','s');
            if strcmp(x_dk,'y') | strcmp(x_dk,'''y''')
                OMEGA_DK = tmp_omega_dk;
                rego_dk = 0;
            elseif strcmp(x_dk,'n') | strcmp(x_dk,'''n''')
                rego_dk = 0;
            else
                disp('Please use y or n')
            end
        end
    end
end
clear tmp_omega_dk rego_dk x_dk

axisvar_dk = 'liv,m';
if abs(max(diff(OMEGA_DK)) - min(diff(OMEGA_DK))) < 1e-5
    axisvar_dk = 'iv,m';
end

%-------dk_defin or the file defined by the variable DK_DEF_NAME -----
%-------------must set the following variables-----------
%
% NOMINAL_DK        % nominal Interconnection structure
% NMEAS_DK          % number of measurements
% NCONT_DK          % number of controls
% BLK_DK            % block structure for mu
% OMEGA_DK          % frequency response range
%
% others are optional
%
% AUTOINFO_DK       % information for automatic iterations
% DISCRETE_DK       % flag for discrete-time interpretation
% GMIN_DK           % gamma min for first iteration
% GMAX_DK           % gamma max for first iteration
% GTOL_DK           % gamma tolerance for H-inf iterations
% RICMTHD_DK        % Riccati solution method
% EPR_DK            % Riccati Real eigenvalue test
% EPP_DK            % Riccati Positive Definite test
% NAME_DK           % this string is appended to all variables
%
%
% VARIABLES SAVED AFTER EACH ITERATION
%
%  gf_dk(i)     - H-infinity norm of i'th iteration
%  k_dk(i)      - i'th iteration controller
%  dl_dk(i)     - left D scale associated with i'th iteration
%  dr_dk(i)     - right D scale associated with i'th iteration
%  Dscale_dk(i) - D-scaling data from the i'th iteration
%  bnds_dk(i)   - mu across frequency for the i'th iteration
%  sens_dk(i)  - sensitivity data from the i'th iteration
%
if exist('NAME_DK')
    if ~isempty(NAME_DK)
        if ~isstr(NAME_DK)
            error('NAME_DK should be a string');
            return
        else
            [mrows_dk,mcols_dk] = size(NAME_DK);
            if mrows_dk ~= 1
                error('NAME_DK should be a string');
                return
            end
        end
    end
else
    NAME_DK = [];
end
apstr_dk = [int2str(iter_num_dk) NAME_DK];
if iter_num_dk > 1
    apstr_dk_old = [int2str(iter_num_dk-1) NAME_DK];
end

if iter_num_dk == 1
    dl_dk = eye(ynum(NOMINAL_DK));
    dr_dk = eye(unum(NOMINAL_DK));
    prevd_dk = 0;
    fiti_dk = 0;
    dispdata_dk = [];
else
%   Rename variables for use inside the iteration
    if exist(['Dscale_dk',apstr_dk_old]) & ...
            exist(['sens_dk',apstr_dk_old])   & ...
            exist(['bnds_dk',apstr_dk_old])   & ...
            exist(['k_dk',apstr_dk_old])
        eval(['Dscale_dk =  Dscale_dk',apstr_dk_old,';']);
        minfo(Dscale_dk)
        dispdata_dk
        eval(['sens_dk =  sens_dk',apstr_dk_old,';']);
        eval(['bnds_dk =  bnds_dk',apstr_dk_old,';']);
        eval(['k_dk =  k_dk',apstr_dk_old,';']);
        if ~exist('dispdata_dk')
            dispdata_dk = [];
        elseif ~isempty(dispdata_dk)
            dispdata_dk = dispdata_dk(:,1:iter_num_dk-1);
        end
    else
        error('Starting iteration is invalid -- data does not exist')
        return
    end
    if iter_num_dk == 2     % haven't fit D's yet
        dl_dk = [];
        dr_dk = [];
        g_dk_g = frsp(starp(NOMINAL_DK,k_dk),Dscale_dk,DISCRETE_DK); % use Dscale_dk IVs, so it
                                                         % matches mu IVs
        clpic_dk = starp(NOMINAL_DK,k_dk);
        clpic_dk_g = frsp(clpic_dk,Dscale_dk,DISCRETE_DK);
    else    %(>2)
        eval(['dl_dk =  dl_dk',apstr_dk_old,';']);
        eval(['dr_dk =  dr_dk',apstr_dk_old,';']);
        IC_DK = mmult(dl_dk,NOMINAL_DK,minv(dr_dk));   % D's absorbed
        clpic_dk = starp(NOMINAL_DK,k_dk);
        clpic_dk_g = frsp(clpic_dk,Dscale_dk,DISCRETE_DK);
    end
    [mtype_dk,mrows_dk,mcols_dk,tmpdl_dk] = minfo(dl_dk);
    [mtype_dk,mrows_dk,mcols_dk,tmpdr_dk] = minfo(dr_dk);
    prevd_dk = tmpdl_dk + tmpdr_dk;  % order of D's
end

again_dk = 1;

if iter_num_dk > 1
    if indvcmp(Dscale_dk,vpck(zeros(length(OMEGA_DK),1),OMEGA_DK)) ~= 1 & ...
         (auto_dk == 0 | auto_visual_dk == 1)
        disp(' ')
        disp('**** New OMEGA_DK frequency data will be incorporated ****')
        disp('****       after next H-infinity control design       ****')
    end
end
if ~isempty(get(0,'children'))
    [mw,sw,notours] = findmuw;
    if ~isempty(notours) & auto_visual_dk==1
        figure(notours(1))
        clf
    end
end

while again_dk == 1 & iter_num_dk<=iter_stop_dk
    apstr_dk = [int2str(iter_num_dk) NAME_DK];
    if iter_num_dk > 1
        if pkvnorm(sens_dk)==0
            sens_dk=madd(sens_dk,ones(1,unum(sens_dk)));
        end
        if auto_dk == 0
            [dlnewj_dk,drnewj_dk] =  ...
                 msf(clpic_dk_g,bnds_dk,Dscale_dk,sens_dk,abs(BLK_DK),[],DISCRETE_DK);
        else
            [dlnewj_dk,drnewj_dk] =  ...
                 msfbatch(clpic_dk_g,bnds_dk,Dscale_dk,sens_dk,abs(BLK_DK),...
                    autoord_dk,auto_visual_dk,DISCRETE_DK);
        end
        tmpdl_dkg = frsp(dlnewj_dk,clpic_dk_g,DISCRETE_DK);
        tmpdr_dkg = frsp(drnewj_dk,clpic_dk_g,DISCRETE_DK);
        x_dk_g = mmult(tmpdl_dkg,clpic_dk_g,minv(tmpdr_dkg));
        mnum_dk = vnorm(x_dk_g);
        if auto_dk==0 | auto_visual_dk == 1
            clf
            vplot(axisvar_dk,bnds_dk,'-',mnum_dk,'--');
            title(['MU bnds (solid) and ||D*M*D^-1|| (dashed): ITERATION  ',int2str(iter_num_dk)])
            drawnow;
        end
        dl_dk = daug(dlnewj_dk,eye(NMEAS_DK));
        dr_dk = daug(drnewj_dk,eye(NCONT_DK));
        DL_DK = ['dl_dk',apstr_dk];
        eval([DL_DK,' = dl_dk;']);
        DR_DK = ['dr_dk',apstr_dk];
        eval([DR_DK,' = dr_dk;']);
        IC_DK = mmult(dl_dk,NOMINAL_DK,minv(dr_dk));
        oldgm_dk = GMAX_DK;
        if GMAX_DK_PLAN == 1
            GMAX_DK = 1.2*pkvnorm(mnum_dk);
        elseif GMAX_DK_PLAN == 2
            x_dk = starp(NOMINAL_DK,k_dk,NMEAS_DK,NCONT_DK);
            if DISCRETE_DK==0
                GMAX_DK = 1.02*hinfnorm(mmult(dlnewj_dk,x_dk,minv(drnewj_dk)));
            else
                GMAX_DK = 1.02*dhfnorm(mmult(dlnewj_dk,x_dk,minv(drnewj_dk)));
            end
            GMAX_DK = GMAX_DK(1);
        end
        clear tmpdr_dk tmpdl_dk tmpdl_dkg tmpdr_dkg x_dk_g mtype_dk
        clear mrows_dk mcols_dk x_dk dlnewj_dk drnewj_dk
        if auto_dk==0
            disp(' ')
            disp('Altering the HINFSYN settings for next synthesis...')
            disp(' ')
            [GMAX_DK,GMIN_DK,GTOL_DK,EPP_DK,EPR_DK] =  ...
                mhhparms(oldgm_dk,GMIN_DK,GTOL_DK,EPP_DK,EPR_DK,GMAX_DK);
        else
            GTOL_DK = 0.02*(GMAX_DK - GMIN_DK);
        end
    else
        IC_DK = NOMINAL_DK;
    end

    if auto_dk==0 | auto_visual_dk==1
        mnum_dk = computer;
        if strcmp(mnum_dk,'MAC2')
            clc;home
        end
        disp(' ');disp(' ');disp(' ')
        disp(['Iteration Number:  ', int2str(iter_num_dk)])
        disp(setstr(ones(1,19+length(int2str(iter_num_dk)))*'-'));disp(' ')
    end

%   Design an H-infinity control law for the interconnection structure in IC_DK
    if auto_dk==0
        disp('Information about the Interconnection Structure IC_DK:');
        minfo(IC_DK)
    end
    hinf_go = 1;
    cnt_dk = 0;
    while hinf_go
        if DISCRETE_DK==0
            [k_dk,g_dk,gf_dk]=hinfsyn(IC_DK,NMEAS_DK,NCONT_DK,GMIN_DK,GMAX_DK, ...
                GTOL_DK,RICMTHD_DK,EPR_DK,EPP_DK,auto_visual_dk);
        else
            [k_dk,g_dk,gf_dk]=dhfsyn(IC_DK,NMEAS_DK,NCONT_DK,GMIN_DK,GMAX_DK, ...
                GTOL_DK,1,inf,1-2*auto_visual_dk,RICMTHD_DK,EPR_DK,EPP_DK);
        end
        SKIP_DK = 1;
        if isempty(gf_dk)
            SKIP_DK= 0;
            if auto_dk == 0
                disp('----  Upper bound for GAMMA is too small!!  ----');
                disp('-----  Need to increase GAMMA Upper bound  -----');
                [GMAX_DK,GMIN_DK,GTOL_DK,EPP_DK,EPR_DK] = ...
                    chhsparm(GMAX_DK,GMIN_DK,GTOL_DK,EPP_DK,EPR_DK);
            else
                % GMIN_DK = GMAX_DK;
                GMAX_DK = 2*GMAX_DK;
		GTOL_DK = 2*GTOL_DK;
                cnt_dk = cnt_dk + 1;
                if cnt_dk == 8
                    error('Cannot find a stabilizing controller, check GMAX_DK');
                    return
                end
            end
        elseif gf_dk==-1           % A, B_2 unstabilizable
            SKIP_DK = 0;
            error('Open-Loop Interconnection is not stabilizable through U (B_2)');
            return
        elseif gf_dk==-2           % A, C_2 detectable
            SKIP_DK = 0;
            error('Open-Loop Interconnection is not detectable through Y (C_2)');
            return
        end
        if SKIP_DK==1
            chflg_dk = 1;
            while chflg_dk == 1
                clpic_dk = starp(NOMINAL_DK,k_dk);
                clpic_dk_g = frsp(clpic_dk,OMEGA_DK,DISCRETE_DK);
                g_dk_g = frsp(g_dk,OMEGA_DK,DISCRETE_DK);  % has rational scalings
                if auto_visual_dk==1
                    g_dk_gs = vsvd(g_dk_g);
                    vplot(axisvar_dk,g_dk_gs)
                    title('SINGULAR VALUE PLOT: CLOSED-LOOP RESPONSE')
                    xlabel('FREQUENCY (rad/s)')
                    ylabel(' MAGNITUDE')
                    drawnow
                end
                if auto_dk==0
                    disp(' '); disp(' ')
                    disp('Singular Value plot of closed-loop system in GRAPHICS window')
                    disp('Make sure that chosen Frequency range is appropriate')
                    RE_DK = reomega(1);
                    if RE_DK == 1
                        [OMEGA_DK,chflg_dk] = chomega(OMEGA_DK);
                        axisvar_dk = 'liv,m';
                        if abs(max(diff(OMEGA_DK)) - min(diff(OMEGA_DK))) < 1e-5
                            axisvar_dk = 'iv,m';
                        end
                    else
                        chflg_dk = 0;
                    end
                    RE_DK = rerunhi(1);
                    if RE_DK == 0
                        hinf_go = 0;
                    else
                        [GMAX_DK,GMIN_DK,GTOL_DK,EPP_DK,EPR_DK] = ...
                            chhsparm(GMAX_DK,GMIN_DK,GTOL_DK,EPP_DK,EPR_DK);
                    end
                else
                    chflg_dk = 0;
                    hinf_go = 0;
                end
            end
        end
    end     % while hinf_go
    if auto_dk==0
        disp(' ')
    end

    K_DK = ['k_dk',apstr_dk];
    eval([K_DK,' = k_dk;']);
    GF_DK = ['gf_dk',apstr_dk];
    eval([GF_DK,' = gf_dk;']);

%   now calculate an upper and lower bounds for mu for the control design
    if auto_visual_dk==1
        disp('Calculating MU of closed-loop system:')
        [bnds_dk,Dscale_dk,sens_dk] = mu(clpic_dk_g,abs(BLK_DK),'c');
        if min(min(BLK_DK)) < 0
            mbnds_dk = mu(clpic_dk_g,BLK_DK,'c');
        end
    else
        [bnds_dk,Dscale_dk,sens_dk] = mu(clpic_dk_g,abs(BLK_DK),'csw');
        if min(min(BLK_DK)) < 0
            mbnds_dk = mu(clpic_dk_g,BLK_DK,'csw');
        end
    end
    [ddd_dk,ddrp_dk,ddindv_dk,dder_dk] = vunpck(Dscale_dk);
    [ddrows_dk,ddcols_dk] = size(ddd_dk);
    ddd_dkn = ddd_dk(:,ddcols_dk*ones(1,ddcols_dk)).\ddd_dk;
    Dscale_dk(1:ddrows_dk,1:ddcols_dk) = ddd_dkn; % normalized D
    DSCALE_DK = ['Dscale_dk',apstr_dk];
    eval([DSCALE_DK,' = Dscale_dk;']);
    SENS_DK = ['sens_dk',apstr_dk];
    eval([SENS_DK,' = sens_dk;']);
    BNDS_DK = ['bnds_dk',apstr_dk];
    eval([BNDS_DK,' = bnds_dk;']);
    if min(min(BLK_DK)) < 0 & auto_visual_dk==1
        clf; subplot(211)
        vplot(axisvar_dk,bnds_dk)
        title(['CLOSED-LOOP COMPLEX MU: CONTROLLER #', int2str(iter_num_dk)])
        xlabel('FREQUENCY  (rad/s)')
        ylabel('COMPLEX MU')
        subplot(212)
        vplot(axisvar_dk,mbnds_dk)
        title(['CLOSED-LOOP MIXED MU: CONTROLLER #', int2str(iter_num_dk)])
        xlabel('FREQUENCY  (rad/s)')
        ylabel('MIXED MU')
        %subplot(111)
        disp('')
        if auto_dk==0
            disp(' MU plots for control design:      Strike any key to continue')
            pause;
        else
            drawnow
        end
    elseif auto_visual_dk==1
        vplot(axisvar_dk,bnds_dk)
        title(['CLOSED-LOOP MU: CONTROLLER #', int2str(iter_num_dk)])
        xlabel('FREQUENCY  (rad/s)')
        ylabel('MU')
        disp('')
        if auto_dk==0
            disp(' MU plots for control design:      Strike any key to continue')
            pause;
        else
            drawnow
        end
    end

%----------------------------------------------------%
%                                                    %
%    YOU CAN EASILY ADD MORE PLOTS/CALCULATIONS      %
%          AND DISPLAYS AT THIS POINT                %
%                                                    %
%----------------------------------------------------%

    [mtype_dk,mrows_dk,mcols_dk,tmpdl_dk] = minfo(dl_dk);
    [mtype_dk,mrows_dk,mcols_dk,tmpdr_dk] = minfo(dr_dk);
    [mtype_dk,mrows_dk,mcols_dk,mnum_dk] = minfo(k_dk);
    prevd_dk = tmpdl_dk+tmpdr_dk;    % order of D's
    mtype_dk = [iter_num_dk;mnum_dk;prevd_dk;gf_dk;pkvnorm(bnds_dk,'inf')];
    dispdata_dk = [dispdata_dk mtype_dk];
    [mrows_dk,mcols_dk] = size(dispdata_dk);
    if mcols_dk > 5
        mtype_dk = dkdispla(dispdata_dk(:,mcols_dk-4:mcols_dk));
    else
        mtype_dk = dkdispla(dispdata_dk);
    end

    first_dk = 0;     % no longer first iteration
    iter_num_dk = iter_num_dk + 1;
    clear K_DK GF_DK BNDS_DK DSC_DK DL_DK IC_DK_g x_dk_g mnum_dk x_dk
    clear DSCALE_DK SENS_DK DR_DK  RE_DK SKIP_DK
    if auto_visual_dk==1
        clc;home
        disp(mtype_dk)
        disp(' ')
    end
    if auto_dk==0
        ag_dk = notherdk(1);
        if ag_dk > 0
            again_dk = 1;
        else
            again_dk = 0;
        end
    end
end  %while again_dk
if auto_visual_dk==1
    disp([' Next MU iteration number:  ', int2str(iter_num_dk)]);
end

% Clean up the workspace now
if exist('CLEAR_DK_DATA')
    eval(['clear ', CLEAR_DK_DATA ]);
else
    clear NOMINAL_DK NMEAS_DK NCONT_DK BLK_DK GMIN_DK EPR_DK
    clear GMAX_DK GTOL_DK GTOLS_DK RICMTHD_DK
    clear EPP_DK MUDIM_DK AUTOINFO_DK
    clear NAME_DK GMAX_DK_PLAN
end
if exist('CLEAR_DK_DATA')
    clear CLEAR_DK_DATA
end
if exist('CLEAR_DK_IT_DATA')
    eval(['clear ', CLEAR_DK_IT_DATA ]);
else
    clear g_dk g_dk_g g_dk_gs gf_dk k_dk IC_DK
    clear Dscale_dk dl_dk dr_dk sens_dk bnds_dk
end
if exist('CLEAR_DK_IT_DATA')
    clear CLEAR_DK_IT_DATA
end

clear apstr_dk_old mcols_dk mrows_dk mtype_dk
clear prevd_dk tmpdl_dk tmpdr_dk
clear ag_dk ddd_dk ddcols_dk  ddd_dkn
clear ddindv_dk ddrows_dk  ddrp_dk hinf_go oldgm_dk
clear apstr_dk fiti_dk k_dk dder_dk axisvar_dk
clear again_dk first_dk iter_num_dk chflg_dk rego_dk
clear auto_dk cnt_dk autoord_dk clpic_dk clpic_dk_g
clear dispdata_dk iter_stop_dk auto_visual_dk
