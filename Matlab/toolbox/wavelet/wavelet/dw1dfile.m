function [out1,out2,out3,out4] = dw1dfile(option,win_dw1dtool,in3,in4)
%DW1DFILE Discrete wavelet 1-D file manager.
%   [OUT1,OUT2,OUT3,OUT4] = DW1DFILE(OPTION,WIN_DW1DTOOL,IN3,IN4)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 27-Jun-2001.
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.17 $

% MemBloc0 of stored values.
%---------------------------
n_InfoInit   = 'DW1D_InfoInit';
ind_filename =  1;
ind_pathname =  2;
nb0_stored   =  2;

% MemBloc1 of stored values.
%---------------------------
n_param_anal   = 'DWAn1d_Par_Anal';
ind_sig_name   = 1;
ind_sig_size   = 2;
ind_wav_name   = 3;
ind_lev_anal   = 4;
ind_axe_ref    = 5;
ind_act_option = 6;
ind_ssig_type  = 7;
ind_thr_val    = 8;
nb1_stored     = 8;

% MemBloc2 of stored values.
%---------------------------
n_coefs_longs = 'Coefs_and_Longs';
ind_coefs     = 1;
ind_longs     = 2;
nb2_stored    = 2;

% MemBloc3 of stored values.
%---------------------------
n_synt_sig = 'Synt_Sig';
ind_ssig   =  1;
nb3_stored =  1;

% MemBloc4 of stored values.
%---------------------------
n_miscella     = 'DWAn1d_Miscella';
ind_graph_area =  1;
ind_view_mode  =  2;
ind_savepath   =  3;
nb4_stored     =  3;

% Figure handle.
%---------------
numfig = int2str(win_dw1dtool);

% Default values.
%---------------- 
epsilon = 0.01;
nbMinPt = 20;

switch option
    case 'anal'
        %******************************************************%
        %** OPTION = 'anal' -  Computing and saving Analysis.**%
        %******************************************************%
        % in3 optional (for 'load_dec' or 'synt' or 'new_anal')
        %------------------------------------------------------
        if nargin==2
            numopt = 1;
        elseif strcmp(in3,'new_anal')
            numopt = 2;
        else
            numopt = 3;
        end     

        % Getting  Analysis parameters.
        %------------------------------
        [Signal_Name,Signal_Size,Wave_Name,Level_Anal] =   ...
                wmemtool('rmb',win_dw1dtool,n_param_anal,  ...
                               ind_sig_name,ind_sig_size, ...
                               ind_wav_name,ind_lev_anal  ...
                               );
        pathname = wmemtool('rmb',win_dw1dtool,n_InfoInit,ind_pathname);
        filename = wmemtool('rmb',win_dw1dtool,n_InfoInit,ind_filename);
        if numopt<3
            if numopt==1
                try
                    load([pathname filename],'-mat');
                    Signal_Anal = eval(Signal_Name);
                    if size(Signal_Anal,1)>1 , Signal_Anal = Signal_Anal'; end         
                catch
                    [Signal_Anal,ok] = utguidiv('direct_load_sig',win_dw1dtool,pathname,filename);
                    if ~ok
                        msg = sprintf('File %s is not a valid file.',filename);
                        wwaiting('off',win_dw1dtool);
                        errordlg(msg,'Load Signal ERROR','modal');
                        return
                    end
                end
            else
                Signal_Anal = dw1dfile('sig',win_dw1dtool);
            end
            [coefs,longs] = wavedec(Signal_Anal,Level_Anal,Wave_Name);

            % Writing coefficients.
            %----------------------
            wmemtool('wmb',win_dw1dtool,n_coefs_longs,...
                           ind_coefs,coefs,ind_longs,longs);
        else
            [coefs,longs] = wmemtool('rmb',win_dw1dtool,n_coefs_longs,...
                                           ind_coefs,ind_longs);
        end

        % Cleaning files.
        %----------------
        dw1dfile('del',win_dw1dtool);

        % Test for saving.
        %-----------------
        try
          err = 0;
          sig_rec = 1;
          save(['sig_rec.' numfig],'sig_rec','-mat');
        catch
          err = 1;
        end

        if err==0
            % Computing and Saving Approximations
            %------------------------------------
            pathname = cd;
            if ~isequal(pathname(length(pathname)),filesep)
                pathname = [pathname filesep];
            end
            wmemtool('wmb',win_dw1dtool,n_miscella,...
                           ind_savepath,pathname);
            app_rec = wrmcoef('a',coefs,longs,Wave_Name);
            if nargin==2
                sig_rec = Signal_Anal;
            else
                sig_rec = app_rec(1,:);
            end
            save(['sig_rec.' numfig],'sig_rec','-mat');
            clear sig_rec
            ssig_rec = app_rec(1,:);
            save(['ssig_rec.' numfig],'ssig_rec','-mat');
            if nargin==3 , out1 = ssig_rec; end
            wmemtool('wmb',win_dw1dtool,n_synt_sig,ind_ssig,ssig_rec);
            clear ssig_rec
            app_rec = app_rec(2:Level_Anal+1,:);
            save(['app_rec.' numfig],'app_rec','-mat');
            clear app_rec

            % Computing and Saving Details
            %-------------------------------
            det_rec = wrmcoef('d',coefs,longs,Wave_Name);
            save(['det_rec.' numfig],'det_rec','-mat');
            clear det_rec

            % Computing and Saving Coefficients
            %----------------------------------
            cfs_beg = wrepcoef(coefs,longs);
            save(['cfs_beg.' numfig],'cfs_beg','-mat');
        else
            out1 = wrcoef('a',coefs,longs,Wave_Name);
            wmemtool('wmb',win_dw1dtool,n_synt_sig,ind_ssig,out1);
        end

    case 'comp_ss'
        %***********************************************************%
        %** OPTION = 'comp_ss' -  Computing and saving Synt. Sig. **%
        %***********************************************************%
        % Used by return_comp & return_deno
        % in3 = hdl_lin
        %------------------------------------
        ssig_rec = get(in3,'Ydata');
        pathname = wmemtool('rmb',win_dw1dtool,n_miscella,ind_savepath);
        filename = ['ssig_rec.' numfig];
        saveStr  = 'ssig_rec';
        try
          save([pathname filename],saveStr)
        catch
          wmemtool('wmb',win_dw1dtool,n_synt_sig,ind_ssig,ssig_rec);
        end

    case 'app'
        pathname = wmemtool('rmb',win_dw1dtool,n_miscella,ind_savepath);
        filename = ['app_rec.' numfig];
        try
          load([pathname filename],'-mat')
          out1 = app_rec(in3,:);
        catch
          [coefs,longs] = wmemtool('rmb',win_dw1dtool,n_coefs_longs,...
                                         ind_coefs,ind_longs);
          Wave_Name = wmemtool('rmb',win_dw1dtool,n_param_anal,ind_wav_name);
          out1 = wrmcoef('a',coefs,longs,Wave_Name,in3);
        end
        if nargin<4 , return; end;
        switch in4
            case 1
                mx = (2.^(in3+1));
                lx = size(out1,2);
                l3 = length(in3);
                out2 = zeros(1,l3);
                out4 = epsilon*ones(1,l3);
                out3 = -out4;
                for k = 1:l3
                    bord = mx(k);
                    lrem = lx+1-2*bord;
                    if lrem>nbMinPt
                        out2(k) = 1;
                        xmax = lrem+bord;
                        out3(k) = min(out1(k,bord:xmax))-epsilon;
                        out4(k) = max(out1(k,bord:xmax))+epsilon;
                    end
                end

            case 2
                out2 = (min(out1'))'-epsilon;
                out3 = (max(out1'))'+epsilon;

            case 3
                mx  = (2.^(in3+1));
                lx  = size(out1,2);
                lx2 = lx/2;
                l3  = length(in3);
                for k = 1:l3
                    bord = mx(k);
                    lrem = lx+1-2*bord;
                    if lrem>nbMinPt
                        xmax = lrem+bord;
                        out2(k) = min(out1(k,bord:xmax))-epsilon;
                        out3(k) = max(out1(k,bord:xmax))+epsilon;
                    else
                        out2(k) = min(out1(k,:))-epsilon;
                        out3(k) = max(out1(k,:))+epsilon;
                    end
                end
        end

    case 'det'
        pathname = wmemtool('rmb',win_dw1dtool,n_miscella,ind_savepath);
        filename = ['det_rec.' numfig];
        try
          load([pathname filename],'-mat')
          out1 = det_rec(in3,:);
        catch
          [coefs,longs] = wmemtool('rmb',win_dw1dtool,n_coefs_longs,...
                                         ind_coefs,ind_longs);
          Wave_Name = wmemtool('rmb',win_dw1dtool,n_param_anal,ind_wav_name);
          out1 = wrmcoef('d',coefs,longs,Wave_Name,in3);
        end
        if nargin<4 , return; end;
        if in4==1
            mx = (2.^(in3+1));
            lx = size(out1,2);
            l3 = length(in3);
            out2 = zeros(1,l3);
            out4 = epsilon*ones(1,l3);
            out3 = -out4;
            for k = 1:l3
                bord = mx(k);
                lrem = lx+1-2*bord;
                if lrem>nbMinPt
                    out2(k) = 1;
                    xmax = lrem+bord;
                    out3(k) = min(out1(k,bord:xmax))-epsilon;
                    out4(k) = max(out1(k,bord:xmax))+epsilon;
                end
            end
        elseif in4==2
            out2 = (min(out1'))'-epsilon;
            out3 = (max(out1'))'+epsilon;
        end

    case 'sig'
        pathname = wmemtool('rmb',win_dw1dtool,n_miscella,ind_savepath);
        filename = ['sig_rec.' numfig];
        try
          load([pathname filename],'-mat')
          out1 = sig_rec;
        catch
          [coefs,longs] = wmemtool('rmb',win_dw1dtool,n_coefs_longs,...
                                         ind_coefs,ind_longs);
          Wave_Name = wmemtool('rmb',win_dw1dtool,n_param_anal,ind_wav_name);
          out1 = wrcoef('a',coefs,longs,Wave_Name,0);
        end
        if nargin==3
            out2 = min(out1)-epsilon;
            out3 = max(out1)+epsilon;
        end

    case 'ssig'
        pathname = wmemtool('rmb',win_dw1dtool,n_miscella,ind_savepath);
        filename = ['ssig_rec.' numfig];
        try
          load([pathname filename],'-mat')
          out1 = ssig_rec;
        catch
          out1 = wmemtool('rmb',win_dw1dtool,n_synt_sig,ind_ssig);
        end
        if nargin==3
            out2 = min(out1)-epsilon;
            out3 = max(out1)+epsilon;
        end

    case 'cfs_beg'
        pathname = wmemtool('rmb',win_dw1dtool,n_miscella,ind_savepath);
        filename = ['cfs_beg.' numfig];
        try
          load([pathname filename],'-mat')
        catch
          [coefs,longs] = wmemtool('rmb',win_dw1dtool,n_coefs_longs,...
                                         ind_coefs,ind_longs);
          cfs_beg = wrepcoef(coefs,longs);
        end
        out1 = cfs_beg(in3,:);
        if nargin<4 , return; end;
        if in4==1
            mx = (2.^(in3+1));
            lx = size(out1,2);
            l3 = length(in3);
            out2 = zeros(1,l3);
            out4 = epsilon*ones(1,l3);
            out3 = -out4;
            for k = 1:l3
                bord = mx(k);
                lrem = lx+1-2*bord;
                if lrem>nbMinPt
                    out2(k) = 1;
                    xmax = lrem+bord;
                    out3(k) = min(out1(k,bord:xmax))-epsilon;
                    out4(k) = max(out1(k,bord:xmax))+epsilon;
                end
            end
        elseif in4==2
            out2 = (min(out1'))'-epsilon;
            out3 = (max(out1'))'+epsilon;
        end

    case 'app_cfs'
        [coefs,longs] = wmemtool('rmb',win_dw1dtool,n_coefs_longs,...
                                       ind_coefs,ind_longs);
        Wave_Name = wmemtool('rmb',win_dw1dtool,n_param_anal,ind_wav_name);
        out1 = appcoef(coefs,longs,Wave_Name,in3);
        if nargin<4 , return; end;
        if in4==1
            bord = (2.^(in3+1));
            lx = size(out1,2);
            out2 = 0;
            out3 = -epsilon;
            out4 = epsilon;
            lrem = lx+1-2*bord;
            if lrem>nbMinPt
                out2 = 1;
                xmax = lrem+bord;
                out3 = min(out1(bord:xmax))-epsilon;
                out4 = max(out1(bord:xmax))+epsilon;
            end
        elseif in4==2
            out2 = (min(out1'))'-epsilon;
            out3 = (max(out1'))'+epsilon;
        end

    case 'det_cfs'
        [coefs,longs] = wmemtool('rmb',win_dw1dtool,n_coefs_longs,...
                                       ind_coefs,ind_longs);
        out1 = detcoef(coefs,longs,in3);
        if nargin<4 , return; end;
        if in4==1
            bord = (2.^(in3+1));
            lx = size(out1,2);
            out2 = 0;
            out3 = -epsilon;
            out4 = epsilon;
            lrem = lx+1-2*bord;
            if lrem>nbMinPt
                out2 = 1;
                xmax = lrem+bord;
                out3 = min(out1(bord:xmax))-epsilon;
                out4 = max(out1(bord:xmax))+epsilon;
            end
        elseif in4==2
            out2 = (min(out1'))'-epsilon;
            out3 = (max(out1'))'+epsilon;
        end

    case 'del'
        %************************************%
        %** OPTION = 'del' -  Delete files.**%
        %************************************%
        pathname = wmemtool('rmb',win_dw1dtool,n_miscella,ind_savepath);
        if ~isempty(pathname)
           olddir = cd;
           try   , cd(pathname);
           catch , return;
           end
           sig_file = ['sig_rec.' numfig];
           deleteFile(sig_file)
           ssig_file = ['ssig_rec.' numfig];
           deleteFile(ssig_file);
           app_file = ['app_rec.' numfig];
           deleteFile(app_file);
           det_file = ['det_rec.' numfig];
           deleteFile(det_file);
           cfs_file = ['cfs_beg.' numfig];
           deleteFile(cfs_file);
           cd(olddir);
        end
        wmemtool('wmb',win_dw1dtool,n_miscella,ind_savepath,'');

    otherwise
        errargt(mfilename,'Unknown Option','msg');
        error('*');
end


%----------------------------
function deleteFile(f)
if exist(f)==2 ,
    try , delete(f); end
end
%----------------------------

