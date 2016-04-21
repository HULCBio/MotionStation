function varargout = utentpar(option,fig,varargin)
%UTENTPAR Utilities for wavelet packets entropy.
%   VARARGOUT = UTENTPAR(OPTION,FIG,VARARGIN)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 13-May-98.
%   Last Revision: 26-Dec-2001.
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.9 $

% Tag property of objects.
%-------------------------
tag_ent_par = 'Fra_EntPar';

switch option
    case 'create'

        % Get Globals.
        %--------------
        [Def_Txt_Height,Def_Btn_Height,Def_Btn_Width,Pop_Min_Width, ...
         X_Spacing,Y_Spacing,Def_FraBkColor,Def_EdiBkColor] = ...
            mextglob('get',...
                'Def_Txt_Height','Def_Btn_Height','Def_Btn_Width', ...
                'Pop_Min_Width','X_Spacing','Y_Spacing', ...
                'Def_FraBkColor','Def_EdiBkColor');

        % Positions utilities.
        %---------------------
        dx = X_Spacing; bdx = 3;
        dy = Y_Spacing; bdy = 4;        
        d_txt  = (Def_Btn_Height-Def_Txt_Height);
        deltaY = (Def_Btn_Height+dy);

        % Defaults.
        %----------
        xleft = Inf; xright  = Inf; xloc = Inf;
        ytop  = Inf; ybottom = Inf; yloc = Inf;
        bkColor = Def_FraBkColor;
        enaVAL  = 'on';
        ent_Nam = 'default';
        ent_Par = 0;

        % Parsing Inputs.
        %----------------        
        nbarg = nargin-2;
        for k=1:2:nbarg
            arg = lower(varargin{k});
            switch arg
              case 'left'    , xleft   = varargin{k+1};
              case 'right'   , xright  = varargin{k+1};
              case 'xloc'    , xloc    = varargin{k+1};
              case 'bottom'  , ybottom = varargin{k+1};
              case 'top'     , ytop    = varargin{k+1};
              case 'yloc'    , yloc    = varargin{k+1};
              case 'bkcolor' , bkColor = varargin{k+1};              
              case 'enable'  , enaVAL  = varargin{k+1};
              case 'nam' ,     ent_Nam = lower(deblankl(varargin{k+1}));
              case 'par' ,     ent_Par = varargin{k+1};
              case 'ent'
                ent_Nam = lower(deblankl(varargin{k+1}{1}));
                ent_Par = varargin{k+1}{2};
            end 
        end
        str_numfig = num2mstr(fig);
        old_units  = get(fig,'units');
        fig_units  = 'pixels';
        if ~isequal(old_units,fig_units), set(fig,'units',fig_units); end       

        % Setting frame position.
        %------------------------
        w_fra   = wfigmngr('get',fig,'fra_width');
        h_fra   = Def_Btn_Height+2*bdy;
        xleft   = utposfra(xleft,xright,xloc,w_fra);
        ybottom = utposfra(ybottom,ytop,yloc,h_fra);
        pos_fr1 = [xleft,ybottom,w_fra,h_fra];
        pos_fr2 = [xleft,ybottom-deltaY,w_fra,h_fra+deltaY];
 
        % Position property of objects.
        %------------------------------
        xleft = xleft+bdx;
        ylow  = ybottom+h_fra-Def_Btn_Height-bdy;
        pos_txt_ent = [xleft, ylow+d_txt/2, Def_Btn_Width, Def_Txt_Height];
        xl          = pos_txt_ent(1)+pos_txt_ent(3);
        pos_pop_ent = [xl, ylow, 2*Pop_Min_Width, Def_Btn_Height];
        ylow        = ylow-deltaY;

        pos_txt_par    = pos_txt_ent;
        pos_txt_par(2) = ylow+d_txt/2;
        xl             = pos_txt_par(1)+pos_txt_par(3);
        pos_uic_ent    = [xl, ylow, 2*Pop_Min_Width, Def_Btn_Height];

        % String property of objects.
        %----------------------------
        str_txt_ent = 'Entropy';
        str_pop_ent = strvcat('shannon','threshold','norm', ...
                              'log energy','sure','user');
        str_txt_par = 'Ent. Param.';
        str_uic_ent = '';

        % Create objects.
        %----------------
        comFigProp = {'Parent',fig,'Unit',fig_units};
        fra_ent = uicontrol(...
                            comFigProp{:}, ...
                            'Style','frame', ...
                            'Position',pos_fr1, ...
                            'Backgroundcolor',bkColor, ...
                            'Tag',tag_ent_par ...
                            );

        txt_ent = uicontrol(...
                            comFigProp{:},                  ...
                            'Style','text',                 ...
                            'HorizontalAlignment','left',   ...
                            'Position',pos_txt_ent,         ...
                            'String',str_txt_ent,           ...
                            'Backgroundcolor',Def_FraBkColor...
                            );

        pop_ent = uicontrol(...
                            comFigProp{:},          ...
                            'Style','Popup',        ...
                            'Position',pos_pop_ent, ...
                            'String',str_pop_ent,   ...
                            'Enable',enaVAL         ...
                            );

        txt_par = uicontrol(...
                            comFigProp{:}, ...
                            'Style','text',                 ...
                            'Visible','off',                ...
                            'HorizontalAlignment','left',   ...
                            'Position',pos_txt_par,         ...
                            'String',str_txt_par,           ...
                            'Backgroundcolor',Def_FraBkColor...
                            );

        uic_ent = uicontrol(...
                            comFigProp{:},          ...
                            'Style','edit',         ...
                            'Position',pos_uic_ent, ...
                            'Visible','off',        ...
                            'HorizontalAlignment','center', ...
                            'String',str_uic_ent,   ...
                            'Enable',enaVAL,        ...
                            'Backgroundcolor',Def_EdiBkColor...
                            );

        % Store data.
        %------------
        pos_fig = get(fig,'Position');
        nor_rat = [pos_fig(3) pos_fig(4) pos_fig(3) pos_fig(4)];
        pos_fr1_Norm = pos_fr1./nor_rat;
        pos_fr2_Norm = pos_fr2./nor_rat;
        ud.handles   = [fra_ent,txt_ent,pop_ent,txt_par,uic_ent];
        ud.positions = [pos_fr1 ; pos_fr2 ; pos_fr1_Norm ; pos_fr2_Norm];
        set(fra_ent,'Userdata',ud);
        if ~isequal(old_units,fig_units)
            set([fig;ud.handles],'units',old_units);
        end       

		% Add Context Sensitive Help (CSHelp).
		%-------------------------------------
		wfighelp('add_ContextMenu',fig,ud.handles,'WP_ENTROPY');
		%-------------------------------------

        % Callbacks update.
        %------------------
        cba_pop_ent = [mfilename  '(''set'',' str_numfig ');'];
        set(pop_ent,'Callback',cba_pop_ent);
 
        % Initialize entropy.
        %-------------------       
        if ~isequal(ent_Nam,'default')
            utentpar('set',fig,'ent',{ent_Nam,ent_Par});
        end
        if nargout>0
            varargout = {get(fra_ent,'Position') , [pos_fr1_Norm ; pos_fr2_Norm]};
        end

    case 'create_copy'
        createArg = varargin{1};
        [varargout{1},varargout{2}] = utentpar('create',fig,createArg{:});
        [pop_ent,uic_ent] = utentpar('handles',fig,'act');
        Def_FraBkColor = mextglob('get','Def_FraBkColor');
        copyOpt = 1;
        if copyOpt
            prop = get(pop_ent,{'Value','String'});
            newProp = {'Style','Edit','BackGroundColor',Def_FraBkColor, ...
                       'Enable','Inactive', ...
                       'String',prop{2}(prop{1},:)};
            set(pop_ent,newProp{:});
        else
            inactCol = mextglob('get','Def_TxtBkColor');
            set(pop_ent,'enable','inactive','ForeGroundColor',inactCol);
        end
        set(uic_ent,'enable','inactive','BackGroundColor',Def_FraBkColor);

    case 'handles'
        fra = findobj(get(fig,'Children'),'flat','style','frame',...
                      'tag',tag_ent_par);
        ud = get(fra,'Userdata');
        varargout = num2cell(ud.handles);

        % One more input to get "active" handles.
        if length(varargin)>0 , varargout = varargout([3 5]); end

    case {'toolPosition','position'}
        fra = findobj(fig,'style','frame','tag',tag_ent_par);
        varargout = get(fra,{'Position','Units'});

    case 'set'
        nbarg = length(varargin);
        [fra_ent,txt_ent,pop_ent,txt_par,uic_ent] = utentpar('handles',fig);
        if nbarg==0
           tmp = get(pop_ent,{'String','Value'});
           ent_Nam = lower(deblankl(tmp{1}(tmp{2},:)));
           ent_Par = '';
        end
        for k = 1:2:nbarg
           argType = varargin{k};
           argVal  = varargin{k+1};
           switch argType
             case 'nam' , ent_Nam = lower(deblankl(argVal));
             case 'par' , ent_Par = argVal;
             case 'ent'
               ent_Nam = lower(deblankl(argVal{1}));
               ent_Par = argVal{2};
           end
        end
        num = getNum(ent_Nam);
        switch ent_Nam
            case {'shannon','logenergy'}
              vis     = 'off';
              str_txt = 'Ent. Param.';
              str_val = '';  

            case {'threshold','sure'}
              vis     = 'on';
              str_txt = 'Threshold';
              str_val = num2str(ent_Par);  

            case 'norm'
              vis     = 'on';
              str_txt = 'Power';
              str_val = num2str(ent_Par);  

            case 'user'
              vis     = 'on';
              str_txt = 'Funct. Name';
              str_val = ent_Par;  
        end
        old_vis = get(txt_par,'Visible');
        if ~isequal(old_vis,vis)
            ud = get(fra_ent,'Userdata');
            positions = ud.positions;
            units = get(fig,'units');
            units = lower(units(1:3));
            if isequal(units,'pix') , dPOS = 0; else , dPOS = 2; end 
            switch vis
              case 'off' , pos_fra = positions(1+dPOS,:);
              case 'on'  , pos_fra = positions(2+dPOS,:);
            end
            set(fra_ent,'Position',pos_fra);
        end
        set(pop_ent,'Value',num);        
        set(txt_par,'String',str_txt,'Visible',vis);
        set(uic_ent,'String',str_val,'Visible',vis);

    case 'get'
        nbarg = length(varargin);
        if nbarg<1 , return; end
        [pop_ent,uic_ent] = utentpar('handles',fig,'act');
        tmp = get(pop_ent,{'Style','String','Value'});
        if isequal(tmp{1},'popupmenu')
            ent_Nam = tmp{2}(tmp{3},:);
        else
            ent_Nam = tmp{2};
        end
        ent_Nam = lower(deblankl(ent_Nam));
        ent_Par = deblankl(get(uic_ent,'String'));
        switch ent_Nam
          case {'shannon','logenergy'} , ent_Par = 0; err = 0;

          case {'threshold','norm','sure'}
            err = isempty(abs(ent_Par));
            if ~err
                 ent_Par = wstr2num(ent_Par);
                 err = isempty(ent_Par);
                 if ~err
                    if isequal(ent_Nam,'norm')
                        err = (ent_Par<1);
                    else
                        err = (ent_Par<=0);
                    end
                 end
            end

          case 'user'         
            ok = exist(ent_Par);
            if isempty(ok) | ~ismember(ok,[2 3 5 6])
                err = 2;
            else
                err = 0;
            end

        end
        varargout = {};
        ind = 1;
        for k = 1:nbarg
           outType = varargin{k};
           switch outType
             case 'nam' , varargout{ind} = ent_Nam; ind = ind+1;
             case 'par' , varargout{ind} = ent_Par; ind = ind+1;
             case 'ent' 
               varargout{ind} = ent_Nam; ind = ind+1;
               varargout{ind} = ent_Par; ind = ind+1;
             case 'txt'
                switch ent_Nam
                   case {'shannon','logenergy'}
                       varargout{ind} = '';
                   case {'threshold','sure'}
                       varargout{ind} = 'Threshold';
                   case 'norm'
                       varargout{ind} = 'Power';
                   case 'user'
                       varargout{ind} = 'Funct. Name';
                end
                ind = ind+1;
           end
        end
        varargout{ind} = err; 

    case 'enable'
        [pop_ent,uic_ent] = utentpar('handles',fig,'act');
        set([pop_ent,uic_ent],'enable',varargin{1});

    case 'clean'
        utentpar('set',fig,'nam','shannon');

    otherwise
        errargt(mfilename,'Unknown Option','msg');
        error('*');
end


%--------------------------------
function num = getNum(entNam)

switch entNam
  case 'shannon'  , num = 1;
  case 'threshold', num = 2;
  case 'norm'     , num = 3;
  case 'logenergy', num = 4;
  case 'sure'     , num = 5;
  case 'user'     , num = 6;
end
%--------------------------------
