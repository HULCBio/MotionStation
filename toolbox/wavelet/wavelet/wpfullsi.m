function wpfullsi(option,win_wptool,in3,in4,in5,in6,in7);
%WPFULLSI Manage full size for axes.
%   WPFULLSI(OPTION,WIN_WPTOOL,IN3,IN4,IN5,IN6,IN7)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 08-Jun-1999.
%   Copyright 1995-2002 The MathWorks, Inc.
% $Revision: 1.11 $

if strcmp(option,'squish')
    % in3 = lst_handles
    % in4 = text handle
    % in5 = 'beg or 'end'
    % in6 = num full
    % in7 optional (redraw xlab)
    %-----------------------------
    WP_Axe_Cfs = in3(1);
    WP_Axe_Col = in3(2);
    usr = get(in4,'Userdata');
    if in5=='beg'
        old_pos = usr(1,:);
        new_pos = usr(2,:);
        if in6==4
            pos1 = get(WP_Axe_Cfs,'Position');
            pos2 = get(WP_Axe_Col,'Position');
            old_pos = [pos1(1) pos2(2) pos1(3) pos1(2)-pos2(2)+pos1(4)];
            dx = pos1(1)-pos2(1);
            dw = pos1(3)-pos2(3);
            dy = (pos1(2)-pos2(2)-pos2(4))/2;
            if abs(dx)>eps
                set(WP_Axe_Col,'Position',pos2+[dx 0 dw 0]);
            end
            set(WP_Axe_Cfs,'Position',pos1+[0 -dy 0 dy]);
            delta = [dx dy dw 0];
            set(in4,'Userdata',[old_pos;new_pos;delta]);
        end
    else
        new_pos = usr(1,:);
        old_pos = usr(2,:);
    end
    pos = new_pos(3:4)./old_pos(3:4);
    pos = [new_pos(1:2)-old_pos(1:2).*pos pos];
    for k=1:length(in3)
        p = get(in3(k),'position');
        p(1:2) = p(1:2).*pos(3:4)+pos(1:2);
        p(3:4) = p(3:4).*pos(3:4);
        set(in3(k),'position',p);
    end
    if (in6==4) & (in5=='end')
        delta = usr(3,:);
        dx = delta(1); dy = delta(2); dw = delta(3);
        if abs(dx)>eps
             set(WP_Axe_Col,'Position',get(WP_Axe_Col,'Position')-[dx 0 dw 0]);
        end
        set(WP_Axe_Cfs,'Position',get(WP_Axe_Cfs,'Position')+[0 dy 0 -dy]);                    
    end
    if nargin==7
        if (in6==4) | (in5=='end')
            xlab   = get(WP_Axe_Cfs,'xlabel');
            strlab = get(xlab,'String');
            wsetxlab(WP_Axe_Cfs,strlab);
            xlab   = get(WP_Axe_Col,'xlabel');
            strlab = get(xlab,'String');
            wsetxlab(WP_Axe_Col,strlab);
        end
    end
    return
end

% MemBloc2 of stored values.
%---------------------------
n_wp_utils = 'WP_Utils';
ind_tree_lin  = 1;
ind_tree_txt  = 2;
ind_type_txt  = 3;
ind_sel_nodes = 4;
ind_gra_area  = 5;
ind_nb_colors = 6;
nb2_stored    = 6;

% Tag property of objects.
%-------------------------
tag_txt_full  = 'Txt_Full';
tag_pus_full  = ['Pus_Full.1';'Pus_Full.2';'Pus_Full.3';'Pus_Full.4'];
tag_axe_t_lin = 'Axe_TreeLines';
tag_axe_sig   = 'Axe_Sig';
tag_axe_pack  = 'Axe_Pack';
tag_axe_cfs   = 'Axe_Cfs';
tag_axe_col   = 'Axe_Col';
tag_sli_size  = 'Sli_Size';
tag_sli_pos   = 'Sli_Pos';

children    = get(win_wptool,'Children');
axe_handles = findobj(children,'flat','type','axes');
uic_handles = findobj(children,'flat','type','uicontrol');
pus_handles = findobj(uic_handles,'style','pushbutton');
for k =1:size(tag_pus_full,1)
    pus_full(k) = (findobj(uic_handles,'Tag',tag_pus_full(k,:)))';
end
txt_full    = findobj(uic_handles,'style','text','Tag',tag_txt_full);
WP_Axe_Tree = findobj(axe_handles,'flat','Tag',tag_axe_t_lin);
WP_Axe_Sig  = findobj(axe_handles,'flat','Tag',tag_axe_sig);
WP_Axe_Pack = findobj(axe_handles,'flat','Tag',tag_axe_pack);
WP_Axe_Cfs  = findobj(axe_handles,'flat','Tag',tag_axe_cfs);
WP_Axe_Col  = findobj(axe_handles,'flat','Tag',tag_axe_col);
Sli_Pos     = findobj(uic_handles,'Tag',tag_sli_pos);
Sli_Size    = findobj(uic_handles,'Tag',tag_sli_size);

lst_handles = [WP_Axe_Cfs,WP_Axe_Col,WP_Axe_Tree,...
               WP_Axe_Pack,WP_Axe_Sig,Sli_Pos,Sli_Size];

switch option
    case 'full'
        % in3 = btn number. 
        %------------------
        Def_TxtBkColor = mextglob('get','Def_TxtBkColor');

        mx = 0.06; my =0.06;
        pos_gra = wmemtool('rmb',win_wptool,n_wp_utils,ind_gra_area);
        pos_gra(1:2) = pos_gra(1:2)+[mx my];
        pos_gra(3:4) = pos_gra(3:4)-2*[mx my];

        % Test begin or end.
        %-------------------
        num = in3;
        btn = pus_full(num);
        act = get(btn,'Userdata');
        if act==0
            % begin full size
            %----------------
            col = get(btn,'Backgroundcolor');
            old_num = 0;
            for k=1:length(pus_full)
                act_old = get(pus_full(k),'Userdata');
                if act_old==1
                    old_num = k;
                    set(pus_full(k),...
                        'Backgroundcolor',col,...
                        'String',sprintf('%.0f',k),...
                        'Userdata',0);
                    break;
                end
            end
            set(btn,'Backgroundcolor',Def_TxtBkColor,      ...
                    'String',['end ' sprintf('%.0f',num)], ...
                    'Userdata',1);
            if old_num~=0;
               pos_param = get(txt_full,'Userdata');
               wpfullsi('squish',win_wptool,lst_handles,txt_full,'end',old_num);
            end
            delta = zeros(1,4);
            switch num
                case 1 , pos = get(WP_Axe_Tree,'Position');
                case 2 , pos = get(WP_Axe_Pack,'Position');
                case 3 , pos = get(WP_Axe_Sig,'Position');
                case 4 , pos = get(WP_Axe_Cfs,'Position');
            end
            if num==1 , vis = 'on'; else , vis = 'off'; end
            set([Sli_Pos Sli_Size],'Visible','on');
            set(txt_full,'Userdata',[pos;pos_gra;delta]);
            wpfullsi('squish',win_wptool,lst_handles,txt_full,'beg',num,'xlab');
        else
            % end full size.
            %---------------
            col = get(pus_full(5-num),'Backgroundcolor');
            set(btn,'Backgroundcolor',col,...
                    'String',sprintf('%.0f',num),...
                    'Userdata',0);
            wpfullsi('squish',win_wptool,lst_handles,txt_full,'end',num,'xlab');
            set([Sli_Pos Sli_Size],'Visible','on');
        end

    case 'clean'
        for k=1:length(pus_full)
            act_old = get(pus_full(k),'Userdata');
            if act_old==1
                col = get(pus_full(5-k),'Backgroundcolor');
                old_num = k;
                set(pus_full(k),...
                    'Backgroundcolor',col,...
                    'String',sprintf('%.0f',k),...
                    'Userdata',0);
                wpfullsi('squish',win_wptool,lst_handles,txt_full,'end',k);
                set([Sli_Pos Sli_Size],'Visible','on');  
                break;
            end
        end
end
