function varargout = utanapar(option,fig,varargin)
%UTANAPAR Utilities for wavelet analysis parameters.
%   VARARGOUT = UTANAPAR(OPTION,FIG,VARARGIN)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 04-May-98.
%   Last Revision: 13-Feb-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.6.4.2 $  $Date: 2004/03/15 22:42:04 $

% Default values.
%----------------
max_lev_anal = 12;

% Tag property of objects.
%-------------------------
tag_ana_par = 'Fra_AnaPar';

switch option
    case {'Install_V3','Install_V3_CB','create'}
        % Defaults.
        %----------
        xleft = Inf; xright  = Inf; xloc = Inf;
        ytop  = Inf; ybottom = Inf; yloc = Inf;
        bkColor = '';
        datFlag = 1;
        levFlag = 1;
        enaVAL  = 'on';
        wtype   = 'dwt';
        deflev  = 1;
        maxlev  = max_lev_anal;

        % Inputs.
        %--------        
        nbarg = length(varargin);
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
              case 'datflag' , datFlag = varargin{k+1};
              case 'levflag' , levFlag = varargin{k+1};
              case 'enable'  , enaVAL  = varargin{k+1};
              case 'wtype'   , wtype   = varargin{k+1};
              case 'deflev'  , deflev  = varargin{k+1};
              case 'maxlev'  , maxlev  = varargin{k+1};
            end 
        end
        str_numfig = num2mstr(fig);
    
        % String property of objects (Not all are used).
        %-----------------------------------------------
        str_txt_typ = 'Data  (Size)';
        str_txt_nam = '';
        str_txt_wav = 'Wavelet';
        str_pop_fam = wavemngr('tfsn',wtype);
        str_pop_num = wavemngr('fields',{'fsn',str_pop_fam(1,:)},'tabNums');
        if isempty(str_pop_num) , str_pop_num = 'no'; end
        str_txt_lev = 'Level';
        str_levels  = int2str([1:maxlev]');
        
        switch option
            case {'Install_V3','Install_V3_CB'}
                % Get Handles.
                %-------------
                handles = guihandles(fig);
                Fra_AnaPar  = handles.Fra_AnaPar;
                try
                    Txt_Data_NS = handles.Txt_Data_NS;
                    Edi_Data_NS = handles.Edi_Data_NS;
                catch
                    datFlag = false;
                end
                Txt_Wav     = handles.Txt_Wav;
                Pop_Wav_Fam = handles.Pop_Wav_Fam;
                Pop_Wav_Num = handles.Pop_Wav_Num; 
                try
                    Txt_Lev     = handles.Txt_Lev;
                    Pop_Lev     = handles.Pop_Lev;
                catch
                    levFlag = false;
                end
                if ~datFlag
                    Txt_Data_NS = NaN;
                    Edi_Data_NS = NaN;
                end
                if ~levFlag
                    Txt_Lev = NaN;
                    Pop_Lev = NaN;
                end
                
                % UIC Updates.
                %-------------
                set(Pop_Wav_Fam,'String',str_pop_fam);
                set(Pop_Wav_Num,'String',str_pop_num);
                if levFlag
                    set(Pop_Lev,'String',str_levels,'Enable',enaVAL);
                end
                set([Pop_Wav_Fam,Pop_Wav_Num],'Enable',enaVAL);
                
            case 'create'
                % Get Globals.
                %--------------
                [Def_Txt_Height,Def_Btn_Height, ...
                        X_Spacing,Y_Spacing,Def_FraBkColor] = ...
                    mextglob('get',...
                    'Def_Txt_Height','Def_Btn_Height', ...
                    'X_Spacing','Y_Spacing','Def_FraBkColor');
                if isempty(bkColor)
                    bkColor = mextglob('get','Def_FraBkColor');
                end
                
                % Positions utilities.
                %---------------------
                dx = X_Spacing; bdx = 3;
                dy = Y_Spacing; bdy = 4;        
                d_txt  = (Def_Btn_Height-Def_Txt_Height);
                deltaY = (Def_Btn_Height+dy);
                
                old_units  = get(fig,'units');
                fig_units  = 'pixels';
                if ~isequal(old_units,fig_units), set(fig,'units',fig_units); end       
                
                % Setting frame position.
                %------------------------
                w_fra   = wfigmngr('get',fig,'fra_width');
                h_fra   = Def_Btn_Height+(datFlag+levFlag)*deltaY+2*bdy;
                xleft   = utposfra(xleft,xright,xloc,w_fra);
                ybottom = utposfra(ybottom,ytop,yloc,h_fra);
                pos_fra = [xleft,ybottom,w_fra,h_fra];
                
                % Position property of objects.
                %------------------------------
                w_uic = (w_fra-3*bdx)/3;
                x_uic = pos_fra(1)+bdx;
                ylow  = ybottom+h_fra-Def_Btn_Height-bdy;
                
                if datFlag
                    pos_txt_typ = [x_uic, ylow+d_txt/2, w_uic, Def_Txt_Height];
                    xleft       = pos_txt_typ(1)+pos_txt_typ(3);
                    pos_txt_nam = [xleft , ylow , 2*w_uic , Def_Btn_Height];
                    ylow        = ylow-deltaY;
                end
                xplus = 2;     
                pos_txt_wav    = [x_uic, ylow+d_txt/2, w_uic, Def_Txt_Height];
                xleft          = pos_txt_wav(1)+pos_txt_wav(3);
                pos_pop_fam    = [xleft, ylow, w_uic-xplus, Def_Btn_Height];
                pos_pop_num    = pos_pop_fam;
                pos_pop_num(1) = pos_pop_fam(1)+w_uic;
                pos_pop_num(3) = w_uic;
                
                if levFlag
                    ylow           = ylow-deltaY;
                    pos_txt_lev    = pos_txt_wav;
                    pos_txt_lev(2) = ylow+d_txt/2;
                    xleft          = pos_txt_lev(1)+pos_txt_lev(3);
                    pos_pop_lev    = [xleft, ylow, w_uic-xplus, Def_Btn_Height];
                end
                
                % Create objects.
                %----------------
                comFigProp = {'Parent',fig,'Unit',fig_units};
                Fra_AnaPar = uicontrol(comFigProp{:},...
                    'Style','frame', ...
                    'Position',pos_fra, ...
                    'Backgroundcolor',bkColor, ...
                    'Tag',tag_ana_par ...
                );
                
                if datFlag
                    Txt_Data_NS = uicontrol(comFigProp{:},...
                        'Style','text',               ...
                        'HorizontalAlignment','left', ...
                        'Position',pos_txt_typ,       ...
                        'String',str_txt_typ,         ...
                        'Backgroundcolor',bkColor     ...
                    );
                    
                    Edi_Data_NS = uicontrol(comFigProp{:},...
                        'Style','Edit',           ...
                        'Position',pos_txt_nam,   ...
                        'String',str_txt_nam,     ...
                        'Enable','inactive',      ...
                        'Backgroundcolor',bkColor ...
                    );
                else
                    Txt_Data_NS = NaN;
                    Edi_Data_NS = NaN;
                end
                Txt_Wav = uicontrol(comFigProp{:},...
                    'Style','text',               ...
                    'HorizontalAlignment','left', ...
                    'Position',pos_txt_wav,       ...
                    'String',str_txt_wav          ...
                );
                
                Pop_Wav_Fam = uicontrol(comFigProp{:},...
                    'Style','Popup',        ...
                    'Position',pos_pop_fam, ...
                    'String',str_pop_fam,   ...
                    'Enable',enaVAL         ...
                );
                
                Pop_Wav_Num = uicontrol(comFigProp{:},...
                    'Style','Popup',        ...
                    'Position',pos_pop_num, ...
                    'String',str_pop_num,   ...
                    'Visible','Off',        ...
                    'Enable',enaVAL         ...
                );
                if levFlag
                    Txt_Lev = uicontrol(comFigProp{:},...
                        'Style','text',               ...
                        'HorizontalAlignment','left', ...
                        'Position',pos_txt_lev,       ...
                        'String',str_txt_lev,         ...
                        'Backgroundcolor',bkColor     ...
                    );
                    
                    Pop_Lev = uicontrol(comFigProp{:},...
                        'Style','Popup',        ...
                        'Position',pos_pop_lev, ...
                        'String',str_levels,    ...
                        'Enable',enaVAL,        ...
                        'Value',deflev          ...
                    );
                else
                    Txt_Lev = NaN;
                    Pop_Lev = NaN;
                end
               
                if ~isequal(old_units,fig_units)
                    set([fig;ud.handles],'units',old_units);
                end       
                drawnow;
                
        end
        
        % Set Wavelet Buttons.
        %---------------------
        cbanapar('cba_fam',fig,[Pop_Wav_Fam,Pop_Wav_Num]);

        % Callbacks update.
        %------------------
        switch option
            case {'Install_V3'} ,
            case {'Install_V3_CB','create'}
                cbanapar('cba_fam',fig,[Pop_Wav_Fam,Pop_Wav_Num]);
                pop_str     = num2mstr([Pop_Wav_Fam;Pop_Wav_Num]);
                cba_pop_fam = ['cbanapar(''cba_fam'',' str_numfig ',' pop_str ');']; 
                cba_pop_num = ['cbanapar(''cba_num'',' str_numfig ',' pop_str ');'];
                set(Pop_Wav_Fam,'Callback',cba_pop_fam);
                set(Pop_Wav_Num,'Callback',cba_pop_num);
        end
                       
		% Add Context Sensitive Help (CSHelp).
		%-------------------------------------
		hdl_UT_WAVELET = [Txt_Wav,Pop_Wav_Fam,Pop_Wav_Num];
		wfighelp('add_ContextMenu',fig,hdl_UT_WAVELET,'UT_WAVELET');
		%-------------------------------------

        % Store handles.
        %---------------
        ud.handles = [Fra_AnaPar;Txt_Data_NS;Edi_Data_NS;...
                      Txt_Wav;Pop_Wav_Fam;Pop_Wav_Num;Txt_Lev;Pop_Lev];
        set(Fra_AnaPar,'Userdata',ud);
        if nargout>0 , varargout = {get(Fra_AnaPar,'Position') , ud.handles}; end

    case 'create_copy'
        createArg = varargin{1};
        cbArg     = varargin{2};
        [toolPos,hdlNew] = utanapar('create',fig,createArg{:});
        popNew = findobj(hdlNew,'style','popupmenu');
        cbanapar('set',fig,cbArg{:});
        copyOpt = 1;
        if copyOpt
            Def_FraBkColor = mextglob('get','Def_FraBkColor');
            prop    = get(popNew,{'Value','String'});
            newProp = {'Style','Edit','BackGroundColor',Def_FraBkColor, ...
                       'Enable','Inactive', ...
                       'String'};
            for k = 1:size(prop,1)
               set(popNew(k),newProp{:},prop{k,2}(prop{k,1},:));
            end
        else
            inactCol = mextglob('get','Def_TxtBkColor');
            set(popNew,'enable','inactive','ForeGroundColor',inactCol);
        end
        if nargout>0 , varargout = {toolPos,hdlNew}; end

    case 'create_copyB'
        inFig = varargin{1};
        uic = findobj(get(fig,'Children'),'flat','type','uicontrol');
        fra = findobj(uic,'style','frame','tag',tag_ana_par);
        ud  = get(fra,'userdata');
        handles = ud.handles;
        handles = copyobj(handles,inFig);
	
        % Store handles.
        %---------------
        ud.handles = handles;
        set(handles(1),'Userdata',ud);
		
        pop = findobj(handles,'style','popupmenu');
        if ~isempty(pop)
            Def_FraBkColor = mextglob('get','Def_FraBkColor');
            prop    = get(pop,{'Value','String'});
            newProp = {'Style','Edit','BackGroundColor',Def_FraBkColor, ...
                       'Enable','Inactive', ...
                       'String'};
            for k = 1:size(prop,1)
               set(pop(k),newProp{:},prop{k,2}(prop{k,1},:));
            end
        end

		% Add Context Sensitive Help (CSHelp).
		%-------------------------------------
		[Txt_Wav,Pop_Wav_Fam,Pop_Wav_Num] = utanapar('handles',inFig,'nam','fam','num');
		hdl_UT_WAVELET = [Txt_Wav,Pop_Wav_Fam,Pop_Wav_Num];
		wfighelp('add_ContextMenu',inFig,hdl_UT_WAVELET,'UT_WAVELET');
		%-------------------------------------

    case 'handles'
        uic = findobj(get(fig,'Children'),'flat','type','uicontrol');
        fra = findobj(uic,'style','frame','tag',tag_ana_par);
        ud  = get(fra,'userdata');
        handles = ud.handles;
        handles([1,4,7]) = [];
        nbarg = length(varargin);
        if nbarg>0 & isequal(varargin{1},'all')
            varargout{1} = handles; return
        end       
        varargout = num2cell(handles);
        if  nbarg<1 , return; end
        ind = [];
        for k = 1:nbarg
           hdlType = varargin{k};
           switch hdlType
             case 'typ' , ind = [ind;1];
             case 'nam' , ind = [ind;2];
             case 'fam' , ind = [ind;3];
             case 'num' , ind = [ind;4];
             case 'lev' , ind = [ind;5];
             case 'pop' , ind = [ind;[3:5]'];
           end       
        end
        varargout = varargout(ind);

    case {'toolPosition','position'}
        fra = findobj(fig,'style','frame','tag',tag_ana_par);
        varargout = get(fra,{'Position','Units'});

    case 'set_cba_num'
        [Pop_Wav_Fam,Pop_Wav_Num] = utanapar('handles',fig,'fam','num');
        if nargin>2
            ena_hdl = varargin{1};
            pop_str = num2mstr([Pop_Wav_Fam ; Pop_Wav_Num]);
            cba_pop_num = ['cbanapar(''cba_num'','        ...
                            num2mstr(fig) ',' pop_str ',[],' ...
                            num2mstr([ena_hdl]) ');'];
            set(Pop_Wav_Num,'Callback',cba_pop_num);
        end 

    otherwise
        errargt(mfilename,'Unknown Option','msg');
        error('*');
end

%------------------------------------------------------------------------
