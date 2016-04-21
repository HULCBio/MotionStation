function cbthrw2d(option,in2,in3,in4)
%CBTHRW2D Callbacks for threshold utilities 2-D.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 03-Oct-98.
%   Last Revision: 31-Jan-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.6.4.2 $  $Date: 2004/03/15 22:39:46 $

switch option
    case 'down'
        % in2 = [fig; pop_dir; dir; level;
        %        h_CMD_LVL(2:3,dir,level); <-- lin_min & lin_max ...
        %        h_CMD_LVL(2:3,level)]     <-- slider & edit
        % in3 = +1 or -1
        % in4 = maxval
        %--------------------------------------------------------------
        fig = in2(1);
        sel_type = get(fig,'SelectionType');
        if strcmp(sel_type,'open') , return; end

        calledFUN = wfigmngr('getWinPROP',fig,'calledFUN');
        feval(calledFUN,'clear_GRAPHICS',fig);
                 
        axe = get(in2(5),'Parent');
        if (axe~=gca) , axes(axe); drawnow discard; end;
        xval = get(in2(5),'Xdata');
        set(in2(5),'Userdata',xval(1)); 
        dir_pop = get(in2(2),'Value');

        if ~isequal(dir_pop,in2(3))
            cb = get(in2(2),'callback');
            dir_pop = in2(3);
            set(in2(2),'Value',dir_pop);
            eval(cb)
        end

        % Setting the compressed coefs axes invisible.
        %---------------------------------------------
        set(in2(5:6),'Color','g');
        drawnow

        argStr   = [num2mstr(in2) ',' int2str(in3)];
        cba_move = [mfilename '(''move'',' argStr ',' num2mstr(in4) ');'];
        cba_up   = [mfilename '(''up'',' argStr ');'];
        wtbxappdata('set',fig,'save_WindowButtonUpFcn',get(fig,'WindowButtonUpFcn'));
        set(fig,'WindowButtonMotionFcn',cba_move,'WindowButtonUpFcn',cba_up);
        setptr(fig,'lrdrag');

    case 'move'
        % in2 = [fig; pop_dir; dir; level;
        %        h_CMD_LVL(2:3,dir,level); <-- lin_min & lin_max ...
        %        h_CMD_LVL(2:3,level)]     <-- slider & edit
        % in3 = +1 or -1
        % in4 = maxval
        %--------------------------------------------------------------
        axe = get(in2(5),'Parent');
        p   = get(axe,'currentpoint');
        new_thresh = p(1,1)*in3;
        if     (new_thresh<=0)   , new_thresh = 0;
        elseif (new_thresh>=in4) , new_thresh = in4;
        end

        sli_lev = in2(7);
        if sli_lev~=0
           min_sli = get(sli_lev,'Min');
           max_sli = get(sli_lev,'Max');
           new_thresh = max(min_sli,min(new_thresh,max_sli));
        end

        xnew = [new_thresh new_thresh];
        xold = get(in2(6),'Xdata');
        if isequal(xold,xnew) , return; end
        if sli_lev~=0
           set(sli_lev,'Value',new_thresh);
           set(in2(8),'string',sprintf('%1.4g',new_thresh));
        end
        if norm(xnew)==0 , vis = 'off'; else , vis = 'on'; end
        set(in2(5),'Xdata',xnew,'Userdata',new_thresh);
        set(in2(6),'Visible',vis,'Xdata',-xnew);

    case 'up'
        % in2 = [fig; pop_dir; dir; level;
        %        h_CMD_LVL(2:3,dir,level); <-- lin_min & lin_max ...
        %        h_CMD_LVL(2:3,level)]     <-- slider & edit
        % in3 = +1 or -1
        %--------------------------------------------------------------
        fig = in2(1);
        save_WindowButtonUpFcn = wtbxappdata('del',fig,'save_WindowButtonUpFcn');
        set(fig,'WindowButtonMotionFcn','wtmotion',...
			'WindowButtonUpFcn',save_WindowButtonUpFcn);
        set(in2(5:6),'Color',wtbutils('colors','linTHR'));
        mousefrm(0,'watch');
        drawnow;
        new_thresh = get(in2(5),'Userdata');
        dir_sel = in2(3);
        lev_sel = in2(4);
        sli_lev = in2(7);    
        utthrw2d('update_thrStruct',fig,dir_sel,lev_sel,new_thresh);
        utthrw2d('show_LVL_perfos',fig);
        mousefrm(0,'arrow');
end
