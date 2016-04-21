function [out1,out2] = dw1dsupm(option,win_dw1dtool,in3,in4,in5)
%DW1DSUPM Discrete wavelet 1-D superimpose mode manager.
%   [OUT1,OUT2] = DW1DSUPM(OPTION,WIN_DW1DTOOL,IN3,IN4,IN5)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 27-Jun-2001.
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.16 $

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

% Tag property of objects.
%-------------------------
tag_axeappini = 'Axe_AppIni';
tag_axedetini = 'Axe_DetIni';
tag_axecfsini = 'Axe_CfsIni';
tag_axecolmap = 'Axe_ColMap';
tag_s_inapp   = 'Sig_in_App';
tag_ss_inapp  = 'SSig_in_App';
tag_s_indet   = 'Sig_in_Det';
tag_ss_indet  = 'SSig_in_Det';
tag_app       = 'App';
tag_det       = 'Det';
tag_img_cfs   = 'Img_Cfs';
tag_img_sca   = 'Img_Sca';

children    = get(win_dw1dtool,'Children');
axe_handles = findobj(children,'flat','type','axes');
uic_handles = findobj(children,'flat','type','uicontrol');
txt_handles = findobj(uic_handles,'Style','text');

switch option
    case 'view'
        % in3 = old_mode or ...
        % in3 = -1 : same mode
        % in3 =  0 : clean
        %-------------------------
        [Wave_Name,opt_act,Level_Anal] = ...
                        wmemtool('rmb',win_dw1dtool,n_param_anal,...
                                ind_wav_name,ind_act_option,ind_lev_anal);
        old_mode = in3;
        [flg_axe,flg_sa,flg_app,flg_sd,flg_det,ccfs_m] = ...
                        dw1dvmod('get_vm',win_dw1dtool,4);
        lev2    = Level_Anal+2;
        v_flg   = [flg_sa , flg_app , flg_sd , flg_det , flg_axe(3)];
        if flg_axe(1)== 0 , v_flg(1:lev2) = zeros(1,lev2); end
        if flg_axe(2)== 0 , v_flg(lev2+1:2*lev2) = zeros(1,lev2); end
        if flg_axe(3)== 0 , v_flg(2*lev2+1) = 0; end

        vis_str = getonoff(v_flg);
        v_s_app = vis_str(1,:);
        v_ss_app= vis_str(2,:);
        v_app   = vis_str(3:lev2,:);
        v_s_det = vis_str(lev2+1,:);
        v_ss_det= vis_str(lev2+2,:);
        v_det   = vis_str(lev2+3:2*lev2,:);
        v_cfs   = vis_str(2*lev2+1,:);

        axe_hdl     = dw1dscrm('axes',win_dw1dtool,flg_axe);
        lin_handles = findobj(axe_hdl,'Type','line');
        img_handles = findobj(axe_hdl,'Type','image');
        s_in_app    = findobj(lin_handles,'Tag',tag_s_inapp);
        s_in_det    = findobj(lin_handles,'Tag',tag_s_indet);
        app         = findobj(lin_handles,'Tag',tag_app);
        ss_in_app   = findobj(lin_handles,'Tag',tag_ss_inapp);
        ss_in_det   = findobj(lin_handles,'Tag',tag_ss_indet);
        det         = findobj(lin_handles,'Tag',tag_det);
        img_cfs     = findobj(img_handles,'Tag',tag_img_cfs);
        img_sca     = findobj(img_handles,'Tag',tag_img_sca);

        if isempty(s_in_app)
            x = dw1dfile('sig',win_dw1dtool);
            xmin = 1;               xmax = length(x);
            ymin = min(x)-eps;      ymax = max(x)+eps;
            set(axe_hdl(1:3),'Xlim',[xmin xmax]);
            col_s = wtbutils('colors','sig');
            line(...
                 'Parent',axe_hdl(1),            ...
                 'Xdata',[xmin:xmax],'Ydata',x,  ...
                 'Color',col_s,'Visible',v_s_app,'Tag',tag_s_inapp);
            line(...
                 'Parent',axe_hdl(2),            ...
                 'Xdata',[xmin:xmax],'Ydata',x,  ...
                 'Color',col_s,'Visible',v_s_det,'Tag',tag_s_indet);
        else
            set(s_in_app,'Visible',v_s_app);
            set(s_in_det,'Visible',v_s_det);
        end
        if isempty(ss_in_app)
            x = dw1dfile('ssig',win_dw1dtool);
            col_ss = wtbutils('colors','ssig');
            line(...
                 'Parent',axe_hdl(1),              ...
                 'Xdata',[1:length(x)],'Ydata',x,  ...
                 'Color',col_ss,'Visible',v_ss_app,...
                 'Tag',tag_ss_inapp);
            line(...
                 'Parent',axe_hdl(2),              ...
                 'Xdata',[1:length(x)],'Ydata',x,  ...
                 'Color',col_ss,'Visible',v_ss_det,...
                 'Tag',tag_ss_indet);
        else
            set(ss_in_app,'Visible',v_ss_app);
            set(ss_in_det,'Visible',v_ss_det);
        end

        if isempty(app)
            x       = dw1dfile('app',win_dw1dtool,1:Level_Anal);
            app     = zeros(1,Level_Anal);
            col_app = wtbutils('colors','app',Level_Anal);
            axAct   = axe_hdl(1);
            axes(axAct);
            for k = 1:Level_Anal
                app(k) = line('Parent',axAct,       ...
                              'Xdata',[1:size(x,2)],...
                              'Ydata',x(k,:),       ...
                              'Color',col_app(k,:), ...
                              'Visible',v_app(k,:), ...
                              'Tag',tag_app,        ...
                              'Userdata',k          ...
                              );
            end
        else
            for k =1:Level_Anal
                lin = app(k);
                ind = get(lin,'Userdata');
                set(lin,'Visible',v_app(ind,:)); 
            end
        end

        if strcmp(opt_act,'synt')
            ini_str = 'Orig. Synt. Sig.';
        else
            ini_str = 'Signal';
        end

        ss_type = wmemtool('rmb',win_dw1dtool,n_param_anal,ind_ssig_type);
        switch ss_type
            case 'ss', str_ss = 'Synthesized Signal';
            case 'ds', str_ss = 'De-noised Signal';
            case 'cs', str_ss = 'Compressed Signal';
        end

        if v_flg(1)==1
            if v_flg(2)==1
                str_tit = [ini_str ', ' str_ss];        
            else    
                str_tit = ini_str;      
            end
        else
            if v_flg(2)==1
                str_tit = str_ss;       
            else    
                str_tit = '';   
            end
        end
        ind = find(flg_app==1);
        if ~isempty(ind)
            if isempty(str_tit) , s = '' ; else , s = ' and '; end
            str_tit = [str_tit s 'Approximation(s) at level(s) :'];
            for k = ind
                str_tit = [str_tit ' ' sprintf('%.0f',k)];
            end
        end
        wtitle(str_tit,'Parent',axe_hdl(1));
        if isempty(det)
            ll = findobj([s_in_det,ss_in_det],'Visible','on');
            if isempty(ll)
                [x,set_ylim,ymin,ymax] = ...
                        dw1dfile('det',win_dw1dtool,1:Level_Anal,1);
                ymin = min(ymin);
                ymax = max(ymax);
                set_ylim = prod(set_ylim);
            else
                set_ylim = 0;
                x = dw1dfile('det',win_dw1dtool,1:Level_Anal);
            end
            det     = zeros(1,Level_Anal);
            col_det = wtbutils('colors','det',Level_Anal);
            axAct   = axe_hdl(2);
            for k = 1:Level_Anal
                det(k) = line(...
                              'Parent',axAct, ...
                              'Xdata',[1:size(x,2)],...
                              'Ydata',x(k,:),       ...
                              'Color',col_det(k,:), ...
                              'Visible',v_det(k,:), ...
                              'Tag',tag_det,        ...
                              'Userdata',k          ...
                              );
            end
            if set_ylim , set(axAct,'Ylim',[ymin ymax]); end
        else
            for k =1:Level_Anal
                lin = det(k);
                ind = get(lin,'Userdata');
                set(lin,'Visible',v_det(ind,:)); 
            end
        end
        if v_flg(lev2+1)==1
            if v_flg(lev2+2)==1
                str_tit = [ini_str ', ' str_ss];        
            else    
                str_tit = ini_str;      
            end
        else
            if v_flg(lev2+2)==1
                str_tit = str_ss;       
            else    
                str_tit = '';   
            end
        end
        ind = find(flg_det==1);
        if ~isempty(ind)
            if isempty(str_tit) , s = '' ; else , s = ' and '; end
            str_tit = [str_tit s 'Detail(s) at level(s) :'];
            for k = ind
                str_tit = [str_tit ' ' sprintf('%.0f',k)];
            end
        end
        wtitle(str_tit,'Parent',axe_hdl(2));

        ax_hdl = axe_hdl(3);
        [rep,ccfs_vm,levs,xlim,nb_cla] = ...
        dw1dmisc('tst_vm',win_dw1dtool,4,ax_hdl,[1:Level_Anal]);
        if rep==1 ,  delete(img_cfs); img_cfs = []; end
        if isempty(img_cfs)
            [x,xlim1,xlim2,ymax,ymin,nb_cla,levs,ccfs_vm] = ...
                    dw1dmisc('col_cfs',win_dw1dtool,ccfs_vm,levs,xlim,nb_cla);
            levlab  = flipud(int2str(levs(:)));
            xmax    = length(x);
            img_cfs = image(flipud(x),...
                    'Visible',v_cfs,'Tag',tag_img_cfs,...
                    'Userdata',[ccfs_vm,levs,xlim1,xlim2,nb_cla],...
                    'Parent',ax_hdl);
            xlim    = get(axe_hdl(1),'Xlim');
            set(ax_hdl, ...
                      'Xlim',xlim,              ...
                      'YTicklabelMode','manual',...
                      'YTick',[1:length(levs)], ...
                      'YTicklabel',levlab,      ...
                      'Ylim',[0.5 Level_Anal+0.5], ...
                      'Tag',tag_axecfsini       ...
                      );
            wylabel('Level number','Parent',ax_hdl);
            clear x
            ax_hdl = axe_hdl(4);
            image([0 1],[0 1],[1:nb_cla],...
                    'Visible',v_cfs,...
                    'Tag',tag_img_sca,...
                    'Parent',ax_hdl);
            set(ax_hdl,...
                    'XTicklabel',[],'YTicklabel',[],...
                    'XTick',[],'YTick',[],'Tag',tag_axecolmap);
        else
            set([img_cfs img_sca],'Visible',v_cfs);
        end
        set(axe_hdl(3:4),'Visible',v_cfs);

        axe_act = axe_hdl(3);
        wylabel('Level number','Parent',axe_act);
        wtitle('Details Coefficients','Parent',axe_act);
        if strcmp(deblankl(v_cfs),'on')
            drawnow
            wsetxlab(axe_hdl(4),'Scale of colors from MIN to MAX');
        end

        % Axes attachment.
        %-----------------
        dw1dsupm('dynv',win_dw1dtool,old_mode);

        % Reference axes used by stat. & histo & ...
        %-------------------------------------------
        wmemtool('wmb',win_dw1dtool,n_param_anal,ind_axe_ref,axe_hdl(1));

    case 'dynv'
        % Axes attachment.
        %-----------------
        okNew = dw1dvdrv('test_mode',win_dw1dtool,'sup',in3);
        if okNew>0
            axe_app_ini = findobj(axe_handles,'flat','Tag',tag_axeappini);
            axe_det_ini = findobj(axe_handles,'flat','Tag',tag_axedetini);
            axe_cfs_ini = findobj(axe_handles,'flat','Tag',tag_axecfsini);
            Level_Anal = wmemtool('rmb',win_dw1dtool,n_param_anal,...
                                            ind_lev_anal);
            dynvtool('get',win_dw1dtool,0,'force');
            dynvtool('init',win_dw1dtool,...
                    [],[axe_app_ini axe_det_ini,axe_cfs_ini],[],[1 0], ...
                    '','','dw1dcoor',[win_dw1dtool,axe_cfs_ini,Level_Anal]);
        end

    case 'del_ss'
        lin_handles = findobj(axe_handles,'Type','line');
        ss_app = findobj(lin_handles,'Tag',tag_ss_inapp);
        ss_det = findobj(lin_handles,'Tag',tag_ss_indet);
        delete([ss_app ss_det]);

    case 'clear'
        % in3 new_mode or ...
        % in3 = 0 : clean 
        %--------------------
        new_mode = in3;
        axe_app_ini = findobj(axe_handles,'flat','Tag',tag_axeappini);
        axe_det_ini = findobj(axe_handles,'flat','Tag',tag_axedetini);
        axe_cfs_ini = findobj(axe_handles,'flat','Tag',tag_axecfsini);
        axe_col_map = findobj(axe_handles,'flat','Tag',tag_axecolmap);
        okNew = dw1dvdrv('test_mode',win_dw1dtool,'sup',new_mode);
        switch okNew
          case 1
              dynvtool('stop',win_dw1dtool);
              hdl_axes = [axe_app_ini,axe_det_ini,axe_cfs_ini,axe_col_map];
              set(findobj(hdl_axes),'visible','off');
              cleanaxe(hdl_axes);
              drawnow;

          case 2  % Show and Scroll Mode
              lin_handles = findobj(axe_handles,'Type','line');
              img_handles = findobj(axe_handles,'Type','image');
              s_in_app    = findobj(lin_handles,'Tag',tag_s_inapp);
              s_in_det    = findobj(lin_handles,'Tag',tag_s_indet);
              ss_in_app   = findobj(lin_handles,'Tag',tag_ss_inapp);
              ss_in_det   = findobj(lin_handles,'Tag',tag_ss_indet);
              img_cfs     = findobj(img_handles,'Tag',tag_img_cfs);
              old_app = findobj(axe_app_ini,'Tag',tag_app);
              out1    = findobj(old_app,'Userdata',1);
              if ~isempty(out1)
                  old_app = old_app(find(old_app~=out1));
              end
              old_det = findobj(axe_det_ini,'Tag',tag_det);
              out2    = findobj(old_det,'Userdata',1);
              if ~isempty(out2)
                  old_det = old_det(find(old_det~=out2));
              end
              set([s_in_app s_in_det out1 ...
                   ss_in_app ss_in_det out2 img_cfs],'Visible','off');
              delete([old_app' old_det']);
        end

    otherwise
        errargt(mfilename,'Unknown Option','msg');
        error('*');
end
        
