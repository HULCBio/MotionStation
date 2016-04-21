function varargout = cbthrw1d(option,in2,in3,in4,in5,in6)
%CBTHRW1D Callbacks for threshold utilities 1-D.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 23-May-97.
%   Last Revision: 18-Dec-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.10.4.2 $  $Date: 2004/03/15 22:39:45 $

% MB1 of stored values.
%----------------------
n_membloc1   = 'ReturnTHR_Bloc';
ind_ret_fig  = 1;
ind_tog_thr  = 2;
ind_status   = 3;
nb1_stored   = 3;

% Same bloc in utthrw1d.
%-----------------------
n_memblocTHR   = 'MB_ThrStruct';
ind_thr_struct = 1;
ind_int_thr    = 2;

% Tag property.
%--------------
tag_lineH_up   = 'LH_u';
tag_lineH_down = 'LH_d';
tag_lineV      = 'LV';

% First test DYNVTOOL Select Option.
%----------------------------------
if ~ischar(option)
    varargout = {[],[]};
    x   = option;
    y   = in2;
    axe = in3;
    ok  = find(axe==in4);
    if isempty(ok) , return; end
    %-------------------------------
    lines = findobj(axe,'type','line');
    lHu   = findobj(lines,'tag',tag_lineH_up);
    lHd   = findobj(lines,'tag',tag_lineH_down);
    ll    = findobj(lines,'tag',tag_lineV);
    NB_LV = length(ll);
    tol   = 0.01;
    xh    = get(lHu,'Xdata');
    i_inf = max(find(xh<=x));
    i_sup = min(find(xh>x));
    if ~isequal(i_sup,i_inf+1) , return; end
    yh = get(lHu,'Ydata');
    [ecx,ii] = min([x-xh(i_inf),xh(i_sup)-x]);
    xlim = get(axe,'Xlim');
    dlim = xlim(2)-xlim(1);
    ecx  = ecx/dlim;
    fig = get(axe,'Parent');
    if ecx>tol              % Create line
        if NB_LV>=10 , return; end
        xh = [xh(1:i_inf)  x          NaN  x          xh(i_sup:end)];
        yh = [yh(1:i_inf)  yh(i_inf)  NaN  yh(i_inf)  yh(i_sup:end)];
        set(lHu,'Xdata',xh,'Ydata',yh)
        set(lHd,'Xdata',xh,'Ydata',-yh)
        ylim = get(axe,'Ylim');
        cbthrw1d('plotLV',[fig ; lHu ; lHd],[x x NaN; ylim NaN]);
    else
        if NB_LV==0
            return
        end
        xval = get(ll,'Xdata');
        if NB_LV>1
            xval = cat(1,xval{:});
        end
        xval = xval(:,1);
        if ii==1
            i_suppress = [i_inf-2:i_inf];
        else
            i_suppress = [i_sup:i_sup+2];
        end
        ind_lv = find((abs(xval-x)/dlim)<tol);
        if ~isempty(ind_lv)
            lv = ll(ind_lv);
            delete(lv);
            drawnow
        else
            return
        end
        xh(i_suppress) = [];
        ynew = (yh(i_suppress(1))+yh(i_suppress(3)))/2;
        yh(i_suppress(1)-1) = ynew;
        yh(i_suppress(3)+1) = ynew;
        yh(i_suppress) = [];
        set(lHu,'Xdata',xh,'Ydata',yh)
        set(lHd,'Xdata',xh,'Ydata',-yh)
    end
    cbthrw1d('upd_thrStruct',fig,lHu);
    pause(0.5)
    return
end

switch option
    case 'downH'
        % in2 = [fig ; lin_max ; lin_min]
        %     in2(4:6) =  [pop_int ; sli_lev ; edi_lev] (optional)
        % in3 = +1 or -1
        %---------------------------------------------------------
        flag_HDL = (length(in2)>3);
        axe = get(in2(2),'Parent');
        if (axe~=gca) , axes(axe); drawnow discard; end;
        fig   = in2(1);
        p     = get(axe,'currentpoint');
        xold  = get(in2(2),'Xdata');
        i_inf = max(find(xold<p(1,1)));
        i_sup = min(find(xold>p(1,1)));
        if ~isequal(i_sup,i_inf+1) , return; end
        calledFUN = wfigmngr('getWinPROP',fig,'calledFUN');
        feval(calledFUN,'clear_GRAPHICS',fig);
        if flag_HDL
            num_int = fix(i_inf/3)+1;
            val_pop = get(in2(4),'Value');
            if num_int~=val_pop
                yold = get(in2(2),'Ydata');
                thr  = abs(yold(i_inf));
                set(in2(4),'Value',num_int)
                set(in2(5),'Value',thr);
                set(in2(6),'string',sprintf('%1.4g',thr));
            end
        end
        set(in2(2:3),'Color','g');
        drawnow

        handles  = num2mstr(in2);
        cba_move = [mfilename '(''moveH'',' handles ...
                        ',' int2str(in3) ',' int2str(i_inf) ');'];
        cba_up   = [mfilename '(''upH'',' handles ');'];
        wtbxappdata('new',fig,'save_WindowButtonUpFcn',get(fig,'WindowButtonUpFcn'));
        set(fig,'WindowButtonMotionFcn',cba_move,'WindowButtonUpFcn',cba_up);
        setptr(fig,'uddrag');

    case 'moveH'
        % in2 = [fig ; lin_max ; lin_min]
        %      in2(4:6) =  [pop_int ; sli_lev ; edi_lev] (optional)
        % in3 = +1 or -1
        % in4 = index point
        %-----------------------------------------------------------
        flag_HDL = (length(in2)>3);
        lin_max  = in2(2);
        axe = get(lin_max,'Parent'); 
        p   = get(axe,'currentpoint');
        new_thresh = p(1,2)*in3;
        if flag_HDL
            min_sli = get(in2(5),'Min');
            max_sli = get(in2(5),'Max');
            new_thresh = max([min_sli,min([new_thresh,max_sli])]);
        else
            lineUD = get(lin_max,'Userdata');
            new_thresh = min([max([new_thresh,0]),lineUD.max]);
        end

        yold = get(lin_max,'Ydata');
        if isequal(yold(in4),new_thresh) , return; end

        ynew = yold;
        ynew([in4 in4+1]) = [new_thresh new_thresh];
        set(lin_max,'Ydata',ynew);
        if new_thresh<sqrt(eps)
            ynew([in4 in4+1]) = [NaN NaN];
        end
    
        set(in2(3),'Ydata',-ynew);
        if flag_HDL
            set(in2(5),'Value',new_thresh);
            set(in2(6),'string',sprintf('%1.4g',new_thresh));
        end

    case 'upH'
        % in2 = [fig ; lin_max ; lin_min]
        %      in2(4:6) =  [pop_int ; sli_lev ; edi_lev] (optional)
        %----------------------------------------------------------- 
        fig = in2(1);
        lHu = in2(2);
        lHd = in2(3);
        save_WindowButtonUpFcn = wtbxappdata('del',fig,'save_WindowButtonUpFcn');
        set(fig,'WindowButtonMotionFcn','wtmotion', ...
            'WindowButtonUpFcn',save_WindowButtonUpFcn);
        cbthrw1d('upd_thrStruct',fig,lHu);
        figDef = get(fig,'Default');
        try
          linCol  = figDef.defaultAxesColorOrder(1,:);
        catch
          linCol  = figDef.axesColorOrder(1,:);
        end
        set([lHu;lHd],'Color',linCol);
        drawnow;
        utthrw1d('show_LVL_perfos',fig);
        setptr(fig,'arrow');

    case 'plotLH'
        % in2 = ax_hdl or...
        % in2 = [pop_ind ; sli_lev ; edi_lev ; ax_hdl] (optional)
        % in3 = xHOR
        % in4 = yHOR
        % in5 = ind_lev
        % in6 = max(abs(sig))
        %--------------------
        flg_HDL = (length(in2)>1);
        if flg_HDL==0 , ax_hdl = in2(1); else , ax_hdl = in2(4); end
        xHOR    = in3;
        yHOR    = in4;
        ind_lev = in5;  
        fig     = get(ax_hdl,'Parent');
        figDef  = get(fig,'Default');
        try
          linCol  = figDef.defaultAxesColorOrder(1,:);
        catch
          linCol  = figDef.axesColorOrder(1,:);
        end
        lineUD.lev = ind_lev;
        lineUD.hdl = in2;
        lineUD.max = in6;
        vis = get(ax_hdl,'Visible');
        commonProp = {...
            'Parent',ax_hdl,   ...
            'Visible',vis,     ...
            'Xdata',xHOR,      ...
            'Linestyle','--',  ...
            'linewidth',2,     ...
            'Color',linCol,    ...
            'EraseMode','xor', ...
            'Userdata',lineUD  ...
            };        
        lHu = line(commonProp{:},'Ydata',yHOR,'Tag',tag_lineH_up);
        ind = find(abs(yHOR)<sqrt(eps));
        if ~isempty(ind) , yHOR(ind) = NaN; end
        lHd = line(commonProp{:},'Ydata',-yHOR,'Tag',tag_lineH_down);
        handles = [fig ;lHu ;lHd];
        if flg_HDL , handles = [handles ; in2(1:3)]; end
        hdl_str = num2mstr(handles);
        cba_thr_max = [mfilename '(''downH'',' hdl_str ',' int2str(+1) ');'];
        cba_thr_min = [mfilename '(''downH'',' hdl_str ',' int2str(-1) ');'];
        set(lHu,'ButtonDownFcn',cba_thr_max)
        set(lHd,'ButtonDownFcn',cba_thr_min)
        varargout = {lHu,lHd};
        setappdata(lHu,'selectPointer','H')
        setappdata(lHd,'selectPointer','H')

    case 'downV'
        % in2 = [fig ; lin_ver ; lin_max ; lin_min]
        %------------------------------------------
        mousefrm(0,'arrow');
        lin_ver = in2(2); 
        axe = get(lin_ver,'Parent');
        if (axe~=gca), axes(axe); drawnow discard; end;
        fig   = in2(1);
        p     = get(axe,'currentpoint');
        xv    = get(lin_ver,'Xdata');
        xv    = xv(1);
        xh    = get(in2(3),'Xdata');
        i_inf = min(find(xh==xv));
        i_sup = max(find(xh==xv));
        if ~isequal(i_sup,i_inf+2) , return; end
        calledFUN = wfigmngr('getWinPROP',fig,'calledFUN');
        feval(calledFUN,'clear_GRAPHICS',fig);
        set(lin_ver,'Color','g');
        drawnow

        % Getting memory blocks.
        %-----------------------
        handles  = num2mstr([in2]);
        cba_move = [mfilename '(''moveV'',' handles ',' ...
                        num2mstr([i_inf i_sup]) ');'];
        cba_up   = [mfilename '(''upV'',' handles ');'];
        wtbxappdata('new',fig,'save_WindowButtonUpFcn',get(fig,'WindowButtonUpFcn'));
        set(fig,'WindowButtonMotionFcn',cba_move,'WindowButtonUpFcn',cba_up);
        setptr(fig,'lrdrag');

    case 'moveV'
        % in2 = [fig ; lin_ver ; lin_max ; lin_min]
        % in3 = point indices
        %------------------------------------------
        lin_ver = in2(2);
        if ~ishandle(lin_ver) , return; end    
        axe = get(lin_ver,'Parent');
        p   = get(axe,'currentpoint');
        new_thresh = p(1,1);
        xold = get(lin_ver,'Xdata');
        xnew = [new_thresh new_thresh];
        if isequal(xold,xnew) , return; end
        xh = get(in2(3),'Xdata');
        if (new_thresh<=xh(in3(1)-1)+sqrt(eps)) | ...
           (new_thresh>=xh(in3(2)+1)-sqrt(eps))
           return
        end    
        xh(in3) = xnew;
        set(lin_ver,'Xdata',xnew);
        set(in2(3),'Xdata',xh);
        set(in2(4),'Xdata',xh);

    case 'upV'
        % in2 = [fig ; lin_ver ; lin_max ; lin_min]
        %------------------------------------------- 
        fig = in2(1);
        lv  = in2(2);
        lHu = in2(3);
        save_WindowButtonUpFcn = wtbxappdata('del',fig,'save_WindowButtonUpFcn');
        set(fig,'WindowButtonMotionFcn','wtmotion',...
			'WindowButtonUpFcn',save_WindowButtonUpFcn);
        if ~ishandle(lv) , vide = 2; return; end
        cbthrw1d('upd_thrStruct',fig,lHu);
        set(lv,'Color','r');
        drawnow;
        utthrw1d('show_LVL_perfos',fig);
        setptr(fig,'arrow');

    case 'plotLV'
        % in2 = [fig ; lin_max ; lin_min]
        % in3 = [xHOR ; yHOR]
        % in4 = yVMin (optional)
        %--------------------------------
        fig  = in2(1);
        lHu  = in2(2);
        lHd  = in2(3);
        xHOR = in3(1,:);
        yHOR = in3(2,:);
        if nargin<4
            yVMin   = 0;
        else
            yVMin   = in4;
        end
        ax_hdl = get(lHu,'Parent');
        vis    = get(ax_hdl,'Visible');
        NB_int = fix(length(xHOR)/3)+ 1;
        for k=1:NB_int-1;
            x    = xHOR(3*k-1);
            xVER = [x x];
            y    = max(abs([yHOR(3*k-1),yVMin]));
            yVER = [-y y];
            lv   = line(...
                        'Parent',ax_hdl,   ...
                        'Visible',vis,     ...
                        'Xdata',xVER,      ...
                        'Ydata',yVER,      ...
                        'Linestyle','--',  ...
                        'Markersize',2,    ...
                        'linewidth',2,     ...
                        'Color','r',       ...
                        'EraseMode','xor', ...
                        'Tag',tag_lineV    ...
                        );
            hdl_str = num2mstr([fig ; lv ; lHu ; lHd]);
            cba_LV  = [mfilename '(''downV'',' hdl_str ');'];
            set(lv,'ButtonDownFcn',cba_LV)
            setappdata(lv,'selectPointer','V')
        end

    case 'upd_thrStruct'
        % in2 = fig
        % in3 = lHu
        %-----------
        fig     = in2;
        lHu     = in3;
        x       = get(lHu,'Xdata');
        y       = get(lHu,'Ydata');
        lineUD  = get(lHu,'Userdata');
        level   = lineUD.lev;
        handles = lineUD.hdl;
        thrStruct = wmemtool('rmb',fig,n_memblocTHR,ind_thr_struct);
        thrParams = getparam(x,y);
        thrStruct(level).thrParams = thrParams;
        if length(handles)>1
            pop_int = handles(1);
            nb_int  = size(thrParams,1);
            nb_val  = size(get(pop_int,'String'),1);
            if nb_int~=nb_val
                set(pop_int,'String',int2str([1:nb_int]'),'Value',1)
                thr = thrParams(1,3);
                set(handles(2),'String','Value',thr);           % Slider
                set(handles(3),'String',sprintf('%1.4g',thr));  % Edit
            end
        end
        wmemtool('wmb',fig,n_memblocTHR,ind_thr_struct,thrStruct);
        hmb = wmemtool('hmb',fig,n_membloc1);
        if ~isempty(hmb) , wmemtool('wmb',fig,n_membloc1,ind_status,1); end

    otherwise
        errargt(mfilename,'Unknown Option','msg');
        error('*');
end

%--------------------------------------%
function param = getparam(x,y)

lx    = length(x);
x_beg = x(1:3:lx);
x_end = x(2:3:lx);
y     = y(1:3:lx);
param = [x_beg(:) , x_end(:) , y(:)];
%--------------------------------------%
