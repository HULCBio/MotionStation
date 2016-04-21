function varargout = cf2dtool(option,varargin)
%CF2DTOOL Wavelet Coefficients Selection 2-D tool.
%   VARARGOUT = CF2DTOOL(OPTION,VARARGIN)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 16-Apr-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.12.4.2 $  $Date: 2004/03/15 22:39:51 $

% Test inputs.
%-------------
if nargin==0 , option = 'create'; end
[option,winAttrb] = utguidiv('ini',option,varargin{:});

% Default values.
%----------------
max_lev_anal = 5;
default_nbcolors = 255;

% Memory Blocs of stored values.
%===============================
% MB0.
%-----
n_membloc0 = 'MB0';
ind_sig    = 1;
ind_coefs  = 2;
ind_longs  = 3;
ind_first  = 4;
ind_last   = 5;
ind_sort   = 6;
ind_By_Lev = 7;
ind_sizes  = 8;
nb0_stored = 8;

% MB1.
%-----
n_membloc1   = 'MB1';
ind_img_name = 1;
ind_img_size = 2;
ind_wav_name = 3;
ind_lev_anal = 4;
ind_nbcolors = 5;
nb1_stored   = 4;

% MB2.
%-----
n_membloc2   = 'MB2';
ind_filename = 1;
ind_pathname = 2;
nb2_stored   = 2;

% MB3.
%-----
n_membloc3 = 'MB3';
ind_s_img  = 1;
nb3_stored = 1;

% Tag property of objects.
%-------------------------
tag_pus_ana = 'Pus_Anal';

if ~isequal(option,'create') , win_tool = varargin{1}; end

switch option
  case 'create'
  case 'pos_axes'
  otherwise
    toolATTR = wfigmngr('getValue',win_tool,'ToolATTR');
    hdl_UIC  = toolATTR.hdl_UIC;
    hdl_MEN  = toolATTR.hdl_MEN;
    pos_GRA  = toolATTR.pos_GRA;
    hdl_BIG_AXE = toolATTR.hdl_BIG_AXE;
    hdl_DEC_AXE = toolATTR.hdl_DEC_AXE;
    hdl_BIG_IMG = toolATTR.hdl_BIG_IMG;
    hdl_DEC_IMG = toolATTR.hdl_DEC_IMG;
    pus_ana  = hdl_UIC.pus_ana;
    c_axeBIG = struct2cell(hdl_BIG_AXE);
    [axe_ori_IMG,axe_syn_IMG,axe_ori_DEC,axe_syn_DEC] = deal(c_axeBIG{:});
    axe_dec_ORI = hdl_DEC_AXE.axe_dec_ORI;
    axe_dec_SYN = hdl_DEC_AXE.axe_dec_SYN;
end

switch option
  case 'create'
    % Get Globals.
    %--------------
    [Def_Btn_Height,Def_Btn_Width,Pop_Min_Width,  ...
     Def_Txt_Height,X_Spacing,Y_Spacing,Def_FraBkColor ] = ...
        mextglob('get',...
            'Def_Btn_Height','Def_Btn_Width','Pop_Min_Width',  ...
            'Def_Txt_Height','X_Spacing','Y_Spacing','Def_FraBkColor' ...
            );

    % Window initialization.
    %----------------------
    win_title = 'Wavelet Coefficients Selection 2-D';
    [win_tool,pos_win,win_units,str_numwin,...
        frame0,pos_frame0,Pos_Graphic_Area,pus_close] = ...
            wfigmngr('create',win_title,winAttrb,'ExtFig_Tool_3',mfilename,1,1,0);
    if nargout>0 , varargout{1} = win_tool; end
		
	% Add Coloration Mode Submenu.
	%-----------------------------
	wfigmngr('add_CCM_Menu',win_tool);

	% Add Help for Tool.
	%------------------
	wfighelp('addHelpTool',win_tool,'Two-Dimensional &Selection','CF2D_GUI');
	
    % Menus construction.
    %--------------------
    m_files = wfigmngr('getmenus',win_tool,'file');	
    m_load = uimenu(m_files,...
                    'Label','&Load Image ', ...
                    'Position',1,          ...
                    'Callback',            ...
                    [mfilename '(''load'',' str_numwin ');'] ...
                    );

    m_save = uimenu(m_files,...
                    'Label','&Save Synthesized Image ',...
                    'Position',2,     ...
                    'Enable','Off',   ...
                    'Callback',       ...
                    [mfilename '(''save'',' str_numwin ');'] ...
                    );

    m_demo = uimenu(m_files,...
                    'Label','&Example Analysis ','Position',3);

    % Submenu for DEMOS.
    %-------------------
    demoCell = {...
      'Noisy Woman',         'noiswom' , 'haar'   , 3, '{''Global''}' ; ...
      'Noisy Woman (movie)', 'noiswom' , 'haar'   , 3, ...
             '{''Stepwise'',[144,100,3144]}'; ...
      'Fingerprint',         'detfingr', 'sym4'   , 3, '{''Global''}' ; ...
      'Fingerprint (movie)', 'detfingr', 'sym4'   , 3, ...
             '{''Stepwise'',[1849,200,6149]}'; ...
      'Facets',              'facets'  , 'bior6.8', 5, '{''Global''}' ; ...
      'Facets (movie)',      'facets'  , 'bior6.8', 5, ...
             '{''Stepwise'',[576,200,4076]}'  ...
      };

    beg_call_str = [mfilename '(''demo'',' str_numwin ','''];
    for i=1:size(demoCell,1)
        levstr = int2str(demoCell{i,4});
        libel  = ['with ' demoCell{i,3} ' at level ' levstr  ...
                 '  --->  ' demoCell{i,1}];
        action = [beg_call_str demoCell{i,2} ''',''' ...
                        demoCell{i,3} ''',' levstr ',' demoCell{i,5} ');'];
        uimenu(m_demo,'Label',libel,'Callback',action);
    end

    % Begin waiting.
    %---------------
    wwaiting('msg',win_tool,'Wait ... initialization');

    % General parameters initialization.
    %-----------------------------------
    dx = X_Spacing;   dx2 = 2*dx;
    dy = Y_Spacing;   dy2 = 2*dy;
    d_txt = (Def_Btn_Height-Def_Txt_Height);
 
    % Command part of the window.
    %============================
    % Data, Wavelet and Level parameters.
    %------------------------------------
    xlocINI = pos_frame0([1 3]);
    ytopINI = pos_win(4)-dy;
    toolPos = utanapar('create',win_tool, ...
                  'xloc',xlocINI,'top',ytopINI,...
                  'enable','off', ...
                  'wtype','dwt'   ...
                  );
 
    w_uic   = 1.5*Def_Btn_Width;
    h_uic   = 1.5*Def_Btn_Height;
    bdx     = (pos_frame0(3)-w_uic)/2;
    x_left  = pos_frame0(1)+bdx;
    y_low   = toolPos(2)-1.5*Def_Btn_Height-2*dy;
    pos_ana = [x_left, y_low, w_uic, h_uic];

    commonProp = {...
        'Parent',win_tool, ...
        'Unit',win_units,  ...
        'Enable','off'     ...
        };

    str_ana = xlate('Analyze');
    cba_ana = [mfilename '(''anal'',' str_numwin ');'];
    pus_ana = uicontrol(commonProp{:},...
                         'Style','Pushbutton', ...
                         'Position',pos_ana,   ...
                         'String',str_ana,     ...
                         'Callback',cba_ana,   ...
                         'Tag',tag_pus_ana,    ...
                         'Interruptible','On'  ...
                         );

    % Create coefficients tool.
    %--------------------------
    ytopCFS = pos_ana(2)-4*dy;
    toolPos = utnbcfs('create',win_tool,'toolOPT','cf2d',...
                       'xloc',xlocINI,'top',ytopCFS);

    % Adding colormap GUI.
    %---------------------
    utcolmap('create',win_tool, ...
             'xloc',xlocINI,'bkcolor',Def_FraBkColor);

    % Callbacks update.
    %------------------
    hdl_den = utnbcfs('handles',win_tool);
    utanapar('set_cba_num',win_tool,[m_files;hdl_den(:)]);
    pop_lev = utanapar('handles',win_tool,'lev');
    cba_pop_lev = [mfilename '(''update_level'',' str_numwin ');'];
    set(pop_lev,'Callback',cba_pop_lev);

    %  Normalisation.
    %----------------
    Pos_Graphic_Area = wfigmngr('normalize',win_tool,Pos_Graphic_Area);

    % Axes contruction.
    %------------------
    [pos_axe,pos_dec_ori,pos_dec_new] = ...
                cf2dtool('pos_axes',win_tool,Pos_Graphic_Area);

    axeProp = {...
      'Parent',win_tool,     ...
      'Unit','normalized',   ...
      'Xtick',[],'Ytick',[], ...
      'Box','on',            ...
      'Visible','Off'        ...
      };
          
    axe = zeros(4,1);
    axe_dec_ORI = zeros(4,max_lev_anal);
    axe_dec_SYN = zeros(4,max_lev_anal);
    for k = 1:4
        axe(k) = axes(axeProp{:},'Position',pos_axe(k,:));
    end
    for j = 1:max_lev_anal
       for k=1:4;
           axe_dec_ORI(k,j) = axes(axeProp{:}, ...
                                   'Position',pos_dec_ori(k,:,j));
       end
    end
    for j = 1:max_lev_anal
       for k=1:4;
           axe_dec_SYN(k,j) = axes(axeProp{:}, ...
                                   'Position',pos_dec_new(k,:,j));
       end
    end

    % Memory for stored values.
    %--------------------------
    wmemtool('ini',win_tool,n_membloc0,nb0_stored);
    wmemtool('ini',win_tool,n_membloc1,nb1_stored);
    wmemtool('ini',win_tool,n_membloc2,nb2_stored);
    wmemtool('ini',win_tool,n_membloc3,nb3_stored);
    hdl_UIC = struct('pus_ana',pus_ana);
    hdl_MEN  = struct('m_load',m_load,'m_save',m_save,'m_demo',m_demo);
    toolATTR = struct('hdl_UIC',hdl_UIC,'hdl_MEN',hdl_MEN);
    hdl_BIG_AXE = struct(...
        'axe_ori_IMG',axe(1),'axe_syn_IMG',axe(2), ...
        'axe_ori_DEC',axe(3),'axe_syn_DEC',axe(4)  ...
        );
    hdl_DEC_AXE = struct(...
        'axe_dec_ORI', axe_dec_ORI,'axe_dec_SYN',axe_dec_SYN ...
        );
    hdl_BIG_IMG = struct('img_ori',[],'img_syn',[]);
    hdl_DEC_IMG = struct('img_dec_ORI', [],'img_dec_SYN',[]);
    toolATTR = struct(...
        'hdl_MEN',hdl_MEN,          ...
        'hdl_UIC',hdl_UIC,          ...
        'pos_GRA',Pos_Graphic_Area, ...
        'hdl_BIG_AXE',hdl_BIG_AXE,  ...
        'hdl_DEC_AXE',hdl_DEC_AXE,  ...
        'hdl_BIG_IMG',hdl_BIG_IMG,  ...
        'hdl_DEC_IMG',hdl_DEC_IMG   ...
        );
    wfigmngr('storeValue',win_tool,'ToolATTR',toolATTR);

    % End waiting.
    %---------------
    wwaiting('off',win_tool);

  case 'load'
    % Loading file.
    %-------------
    if length(varargin)<2
        imgFileType = ['*.mat;*.bmp;*.hdf;*.jpg;' ...
                '*.jpeg;*.pcx;*.tif;*.tiff;*.gif'];
        [imgInfos,img_anal,map,ok] = ...
            utguidiv('load_img',win_tool, ...
                imgFileType,'Load Image',default_nbcolors);
        demoFlag = 0;
    else
        img_Name = deblank(varargin{2});
        wav_Name = deblank(varargin{3});
        lev_Anal = varargin{4};
        filename = [img_Name '.mat'];
        pathname = utguidiv('WTB_DemoPath',filename);
        [imgInfos,img_anal,map,ok] = ...
            utguidiv('load_dem2D',win_tool,pathname,filename,default_nbcolors);
        demoFlag = 1;
    end
    if ~ok, return; end

    % Begin waiting.
    %---------------
    wwaiting('msg',win_tool,'Wait ... loading');

    % Getting GUI values.
    %--------------------
    if isequal(imgInfos.true_name,'X')
        img_Name = imgInfos.name;
    else
        img_Name = imgInfos.true_name;
    end
    img_Size = imgInfos.size;
    levm     = wmaxlev(img_Size,'haar');
    levmax   = min(levm,max_lev_anal);
    str_lev_data = int2str([1:levmax]');
    if ~demoFlag
        lev_Anal = min(levmax,5);
        wav_Name = cbanapar('get',win_tool,'wav');
    end

    % Cleaning.
    %----------
    dynvtool('stop',win_tool);
    utnbcfs('clean',win_tool)
    set(hdl_MEN.m_save,'Enable','Off');
    axe_hdl = [...
      axe_ori_IMG;axe_syn_IMG;      ...
      axe_ori_DEC;axe_syn_DEC;      ...
      axe_dec_ORI(:);axe_dec_SYN(:) ...
      ];
    set(wfindobj(axe_hdl),'Visible','Off')
    children = allchild(axe_hdl);
    delete(children{:});
    cf2dtool('set_axes',win_tool,imgInfos.size);
    set(axe_hdl,'Xtick',[],'Ytick',[],'Box','on');

    % Reset coefficients tool.
    %-------------------------
    utnbcfs('update_NbCfs',win_tool,'clean');
    utnbcfs('set',win_tool,'position',{1,lev_Anal})

    % Setting GUI values.
    %--------------------
    cbanapar('set',win_tool,...
             'n_s',{img_Name,img_Size}, ...
             'wav',wav_Name,...
             'lev',{'String',str_lev_data,'Value',lev_Anal});

    if imgInfos.self_map , arg = map; else , arg = []; end
    nb_ColorsInPal = size(map,1);
    cbcolmap('set',win_tool,'pal',{'pink',nb_ColorsInPal,'self',arg});

    % Drawing.
    %---------
    axeAct = axe_ori_IMG;
	codemat_v = wimgcode('get',win_tool);
    img_anal = wimgcode('cod',0,img_anal,nb_ColorsInPal,codemat_v);
    img_ori = image([1 img_Size(1)],[1 img_Size(2)], ...
                        img_anal,'Parent',axeAct);
    sizeStr = int2str(img_Size');
    strTitle = sprintf('Original Image - size = (%s, %s)', sizeStr(1,:), sizeStr(2,:));
    wtitle(strTitle,'Parent',axeAct);

    axeAct = axe_syn_IMG;
    img_syn = image([1 img_Size(1)],[1 img_Size(2)], ...
                     img_anal,'Parent',axeAct,'Visible','Off');
    wtitle('Synthesized Image','Parent',axeAct,'Visible','Off');
    set(axeAct,'Visible','Off')

    set([axe_ori_IMG,axe_syn_IMG],        ...
        'XTicklabelMode','manual',        ...
        'YTicklabelMode','manual',        ...
        'XTicklabel',[],'YTicklabel',[],  ...
        'XTick',[],'YTick',[],'Box','On'  ...
        );

    % Setting Analysis parameters.
    %-----------------------------
    wmemtool('wmb',win_tool,n_membloc0,ind_sig,img_anal);
    wmemtool('wmb',win_tool,n_membloc1, ...
                   ind_img_name,imgInfos.name, ...
                   ind_img_size,imgInfos.size, ...
                   ind_nbcolors,nb_ColorsInPal ...
                   );
    wmemtool('wmb',win_tool,n_membloc2, ...
                   ind_filename,imgInfos.filename, ...
                   ind_pathname,imgInfos.pathname  ...
                   );

    % Store Values.
    %--------------
    toolATTR.hdl_BIG_IMG.img_ori = img_ori;
    toolATTR.hdl_BIG_IMG.img_syn = img_syn;
    wfigmngr('storeValue',win_tool,'ToolATTR',toolATTR);

    % Setting enabled values.
    %------------------------
    utnbcfs('set',win_tool,'handleORI',img_ori,'handleTHR',img_syn);
    cbanapar('enable',win_tool,'on');
    cbcolmap('enable',win_tool,'on');
    set(pus_ana,'Enable','On' );

    % End waiting.
    %-------------
    wwaiting('off',win_tool);

  case 'demo'
    cf2dtool('load',varargin{:})
    if length(varargin)>4 
        parDEMO = varargin{5};
    else
        parDEMO = {'Global'};
    end

    % Begin waiting.
    %---------------
    wwaiting('msg',win_tool,'Wait ... computing');

    % Computing.
    %-----------
    cf2dtool('anal',win_tool);
    utnbcfs('demo',win_tool,parDEMO);

    % End waiting.
    %-------------
    wwaiting('off',win_tool);

  case 'save'
    % Testing file.
    %--------------
    [filename,pathname,ok] = utguidiv('test_save',win_tool, ...
                                 '*.mat','Save Synthesized Image');
    if ~ok, return; end

    % Begin waiting.
    %--------------
    wwaiting('msg',win_tool,'Wait ... saving');

    % Getting Synthesized Image.
    %---------------------------
    img_syn = toolATTR.hdl_BIG_IMG.img_syn;
    X = round(get(img_syn,'Cdata'));
    map = cbcolmap('get',win_tool,'self_pal');
    if isempty(map)
        mi = round(min(min(X)));
        ma = round(max(max(X)));
        if mi<=0 , ma = ma-mi+1; end
	ma  = min([default_nbcolors,max([2,ma])]);
        map = pink(ma);
    end

    % Saving file.
    %--------------
    wname = wmemtool('rmb',win_tool,n_membloc1,ind_wav_name);
    [name,ext] = strtok(filename,'.');
    if isempty(ext) | isequal(ext,'.')
        ext = '.mat'; filename = [name ext];
    end

    wwaiting('off',win_tool);
    try
      save([pathname filename],'X','map','wname');
    catch
      errargt(mfilename,'Save FAILED !','msg');
    end
      
  case 'anal'
    % Waiting message.
    %-----------------
    wwaiting('msg',win_tool,'Wait ... computing');

    % Cleaning and reset dynvtool.
    %-----------------------------
    axe_hdl = [axe_dec_ORI(:);axe_dec_SYN(:)];
    set(wfindobj(axe_hdl),'Visible','Off')
    children = allchild(axe_hdl);
    delete(children{:});
    set(axe_hdl,'Xtick',[],'Ytick',[],'Box','on')  
    dynvtool('ini_his',win_tool,'reset') 
    
    % Reading Analysis Parameters.
    %-----------------------------
    img_anal = wmemtool('rmb',win_tool,n_membloc0,ind_sig);
    nb_ColorsInPal = wmemtool('rmb',win_tool,n_membloc1,ind_nbcolors);
    [wav_Name,lev_Anal] = cbanapar('get',win_tool,'wav','lev');

    % Setting Analysis parameters
    %-----------------------------
    wmemtool('wmb',win_tool,n_membloc1,   ...
                   ind_wav_name,wav_Name, ...
                   ind_lev_anal,lev_Anal  ...
                   );
    % Get Values.
    %------------
    img_ori = hdl_BIG_IMG.img_ori;
    img_syn = hdl_BIG_IMG.img_syn;
    set(img_syn,'Cdata',img_anal);

    % Analyzing.
    %-----------
    [coefs,sizes] = wavedec2(img_anal,lev_Anal,wav_Name);
    longs  = sizes(1:end-1,:);
    longs  = prod(longs,2);
    indDet = [2:length(longs)];
    indDet = indDet(ones(1,3),:);
    indDet = [1,indDet(:)'];
    last   = cumsum(longs(indDet));
    first  = ones(size(last));
    first(2:end) = last(1:end-1)+1;
    longs(2:end) = 3*longs(2:end);
    longs(end+1) = sum(longs);
    [tmp,idxsort] = sort(abs(coefs));
    len = length(last);
    idxByLev = cell(1,len);
    for k=1:len
        idxByLev{k} = find((first(k)<=idxsort) & (idxsort<=last(k)));
    end
   
    % Writing coefficients.
    %----------------------
    wmemtool('wmb',win_tool,n_membloc0,...
             ind_coefs,coefs,ind_longs,longs, ...
             ind_first,first,ind_last,last,   ...
             ind_sort,idxsort,ind_By_Lev,idxByLev, ...
             ind_sizes,sizes  ...
             );

    % Drawing.
    %---------
	codemat_v = wimgcode('get',win_tool);
    axeProp = {...
       'XTicklabelMode','manual',        ...
       'YTicklabelMode','manual',        ...
       'XTicklabel',[],'YTicklabel',[],  ...
       'XTick',[],'YTick',[],'Box','On'  ...
       };
    
    img_Size = wmemtool('rmb',win_tool,n_membloc1,ind_img_size);
    dum = cell(1,4);
    for j=1:lev_Anal
        [dum{2},dum{4},dum{3}] = detcoef2('all',coefs,sizes,j);
        if j==lev_Anal
          dum{1} = appcoef2(coefs,sizes,wav_Name,j);
        else
          dum{1} = zeros(size(dum{2}));
        end
        trunc_p = [j img_Size(2) img_Size(1)];
        for k=1:4
            dum{k} = wimgcode('cod',1,dum{k},nb_ColorsInPal,codemat_v,trunc_p);
            vis = getonoff((k~=1) | j==lev_Anal);
            axeAct = axe_dec_ORI(k,j);
            img_dec_ORI(k,j) = ...
                    image([1 img_Size(1)],[1 img_Size(2)],dum{k},...
                          'Parent',axeAct,   ...
                          'Visible',vis,     ...
                          'UserData',[0;j;k] ...
                          );
            set(axeAct,axeProp{:});
            axeAct = axe_dec_SYN(k,j);
            img_dec_SYN(k,j) = ...
                    image([1 img_Size(1)],[1 img_Size(2)],dum{k},...
                          'Parent',axeAct,   ...
                          'Visible',vis,     ...
                          'UserData',[0;j;k] ...
                          );
            set(axeAct,axeProp{:});
        end
    end
    strTitle = sprintf('Original Decomposition at level %s',int2str(lev_Anal)); 
    wxlabel(strTitle,'Parent',axe_ori_DEC,'Visible','On');
    strTitle = sprintf('Modified Decomposition at level %s', int2str(lev_Anal)); 
    wxlabel(strTitle,'Parent',axe_syn_DEC,'Visible','On');
    set(wfindobj(axe_syn_IMG),'Visible','On')

    % Store handles.
    %---------------
    toolATTR.hdl_DEC_IMG.img_dec_ORI = img_dec_ORI;
    toolATTR.hdl_DEC_IMG.img_dec_SYN = img_dec_SYN;
    wfigmngr('storeValue',win_tool,'ToolATTR',toolATTR);
    
    % Reset tool coefficients.
    %-------------------------
    set(hdl_MEN.m_save,'Enable','On');
    utnbcfs('update_NbCfs',win_tool,'anal');
    utnbcfs('update_methode',win_tool,'anal');
    utnbcfs('enable',win_tool,'anal');

    % Connect dynvtool.
    %------------------
    axe_hdl = [...
      axe_ori_IMG;axe_syn_IMG;      ...
      axe_ori_DEC;axe_syn_DEC;      ...
      axe_dec_ORI(:);axe_dec_SYN(:) ...
      ];    
    dynvtool('init',win_tool,[],axe_hdl,[],[1 1],'','','','int');

    % End waiting.
    %-------------
    wwaiting('off',win_tool);

  case 'apply'
    % Waiting message.
    %-----------------
    wwaiting('msg',win_tool,'Wait ... computing');

    % Analysis Parameters.
    %--------------------
    lev_Anal = wmemtool('rmb',win_tool,n_membloc1,ind_lev_anal);
    [idxsort,idxByLev] = wmemtool('rmb',win_tool,n_membloc0,ind_sort,ind_By_Lev);

    % Compute new decomposition.
    %---------------------------
    [nameMeth,nbkept] = utnbcfs('get',win_tool,'nameMeth','nbkept');
    lenNbK = length(nbkept);
    indKept = [2:lenNbK-1];
    indKept = indKept(ones(1,3),:);
    indKept = [1 , indKept(:)' , lenNbK];
    nbkept  = nbkept(indKept);
    iBeg = 2;
    for jj = 1:lev_Anal
       iEnd = iBeg+2;
       total = nbkept(iBeg);
       tmp = sort(cat(2,idxByLev{iBeg:iEnd}));
       tmp = tmp(end-total+1:end);
       v(1) = sum(ismember(tmp,idxByLev{iBeg}));
       v(2) = sum(ismember(tmp,idxByLev{iBeg+1}));
       v(3) = sum(ismember(tmp,idxByLev{iBeg+2}));
       nbkept(iBeg:iEnd) = v;
       iBeg = iEnd+1;
    end
    len = length(idxByLev);
    switch nameMeth
      case {'Global','ByLevel'}
        ind = [];
        for k=1:len
            ind = [ind , idxByLev{k}(end-nbkept(k)+1:end)];
        end
        idx_Cfs = idxsort(ind);

        % Computing & Drawing.
        %---------------------
        cf2dtool('plot_NewDec',win_tool,idx_Cfs,nameMeth);

      case {'Manual'}
    end

    % End waiting.
    %-------------
    wwaiting('off',win_tool);

  case 'Apply_Movie'
    % Read set of kept coefficients.
    %-------------------------------
    movieSET = varargin{2};
    nbInSet = length(movieSET);
    if nbInSet==0
        cf2dtool('plot_NewDec',win_tool,[],'Stepwise');
        return
    end
    appFlag = varargin{3};
    popStop = varargin{4};
      
    % Waiting message.
    %-----------------
    if nbInSet>1
        txt_msg = wwaiting('msg',win_tool,'Wait ... computing');
    end

    % Analysis Parameters.
    %--------------------
    lev_Anal = wmemtool('rmb',win_tool,n_membloc1,ind_lev_anal);
    [first,last,idxsort,idxByLev] = ...
        wmemtool('rmb',win_tool,n_membloc0, ...
                       ind_first,ind_last, ...
                       ind_sort,ind_By_Lev ...
                       );

    % Computing.
    %-----------
    len = length(last);
    nbKept = zeros(1,len+1);
    switch appFlag
      case 1
        idx_App = idxsort(idxByLev{1});
        App_Len = length(idx_App);
        idxsort(idxByLev{1}) = [];

      case 2
        idx_App = [];
        App_Len = 0;
       
      case 3
        idx_App = [];
        App_Len = 0;       
        idxsort(idxByLev{1}) = [];
    end

    for jj = 1:length(movieSET)
        nbcfs = movieSET(jj);
        nbcfs  = nbcfs-App_Len;
        idx_Cfs = [idx_App , idxsort(end-nbcfs+1:end)];

        if nbInSet>1 ,
            for k=1:len
              dummy  = find((first(k)<=idx_Cfs) & (idx_Cfs<=last(k)));
              nbKept(k) = length(dummy);
            end
            nbKept(end) = sum(nbKept(1:end-1));
            msg1 = sprintf('Number of kept coefficients:  %s', int2str(nbKept(end)));
            msg2 = ['  = '];
            msg3 = ['[' int2str(nbKept(1)) ','];
            iBeg = 2;
            for kk=1:lev_Anal
                iEnd = iBeg+2;
                msg3 = [msg3 , ' (' int2str(nbKept(iBeg:iEnd)) ') '];
                iBeg = iEnd+1;
            end
            msg3  = [msg3 , ']'];
            lmsg3 = length(msg3);
            if lmsg3<80
                msg  = strvcat(' ', [msg1,msg2,msg3]);
            else
                msg  = strvcat(msg1,' ', msg3);
            end
            set(txt_msg,'String',msg);
        end

        % Computing & Drawing.
        %---------------------
        cf2dtool('plot_NewDec',win_tool,idx_Cfs,'Stepwise');

        if nbInSet>1 , 
            % Test for stopping.
            %-------------------
            user = get(popStop,'Userdata');
            if isequal(user,1)
               set(popStop,'Userdata',[]);
               break
            end
            pause(0.05);
        end
    end

    % End waiting.
    %-------------
    if nbInSet>1 , wwaiting('off',win_tool); end

  case 'plot_NewDec'
    % Indices of preserved coefficients & Methode.
    %---------------------------------------------
    idx_Cfs  = varargin{2};
    nameMeth = varargin{3};
    
    % Get Handles.
    %-------------
    img_dec_ORI = toolATTR.hdl_DEC_IMG.img_dec_ORI;
    img_dec_SYN = toolATTR.hdl_DEC_IMG.img_dec_SYN;
    img_syn = toolATTR.hdl_BIG_IMG.img_syn;

    % Get Analysis Parameters.
    %-------------------------
    [img_Size,wav_Name,lev_Anal,nb_ColorsInPal] = ...
        wmemtool('rmb',win_tool,n_membloc1,...
                 ind_img_size,ind_wav_name,ind_lev_anal,ind_nbcolors);
    [coefs,sizes] = wmemtool('rmb',win_tool,n_membloc0,ind_coefs,ind_sizes);

    % Compute synthezized image.
    %---------------------------
    Cnew = zeros(size(coefs));
    Cnew(idx_Cfs) = coefs(idx_Cfs);
    SS  = waverec2(Cnew,sizes,wav_Name);
    thr = min(abs(Cnew));

    % Draw modified decomposition.
    %-----------------------------
	codemat_v = wimgcode('get',win_tool);
    dum = cell(1,4);
    for j=1:lev_Anal
        [dum{2},dum{4},dum{3}] = detcoef2('all',Cnew,sizes,j);
        if j==lev_Anal
          dum{1} = appcoef2(Cnew,sizes,wav_Name,j);
        else
          dum{1} = zeros(size(dum{2}));
        end
        trunc_p = [j img_Size(2) img_Size(1)];
        for k=1:4
            dum{k} = wimgcode('cod',1,dum{k},nb_ColorsInPal,codemat_v,trunc_p);
            vis = getonoff((k~=1) | j==lev_Anal);
            axeAct = axe_dec_SYN(k,j);
            % set(img_dec_SYN(k,j),'Cdata',dum{k});
			set(img_dec_SYN(k,j),'Cdata',dum{k},'Visible',vis);
        end
    end
    set(wfindobj(axe_syn_IMG),'Visible','On')

    % Draw synthesized image.
    %------------------------
    axeAct = axe_syn_IMG;
    set(img_syn,'Cdata',SS);     
    set(hdl_MEN.m_save,'Enable','On');

  case 'update_level'
    pop_lev  = utanapar('handles',win_tool,'lev');
    lev_Anal = get(pop_lev,'Value');

    % Clean axes.
    %------------
    set(hdl_MEN.m_save,'Enable','Off');
    axe_hdl = [...
      axe_syn_IMG;                  ...
      axe_ori_DEC;axe_syn_DEC;      ...
      axe_dec_ORI(:);axe_dec_SYN(:) ...
      ];      
    set(wfindobj(axe_hdl),'Visible','Off')

    % Reset coefficients tool and dynvtool.
    %--------------------------------------
    utnbcfs('clean',win_tool)
    utnbcfs('update_NbCfs',win_tool,'clean');
    utnbcfs('set',win_tool,'position',{1,lev_Anal})
    dynvtool('ini_his',win_tool,'reset')

  case 'set_axes'
    % imgSize = varargin{2};
    %-----------------------
    [pos_axe,pos_dec_ori,pos_dec_new] = ...
        cf2dtool('pos_axes',win_tool,pos_GRA,0.08,0.08,varargin{2});
    for k=1:length(c_axeBIG)
       set(c_axeBIG{k},'Position',pos_axe(k,:));
    end
    for j = 1:max_lev_anal
       for k=1:4;
           set(axe_dec_ORI(k,j),'Position',pos_dec_ori(k,:,j));
       end
    end
    for j = 1:max_lev_anal
       for k=1:4;
           set(axe_dec_SYN(k,j),'Position',pos_dec_new(k,:,j));
       end
    end
   
  case 'pos_axes'
    switch length(varargin)
      case 2 , pos_GRA = varargin{2}; bdx = 0; bdy = 0;
      case 5 , [pos_GRA,bdx,bdy,imgSize] = deal(varargin{2:5});
    end    
    pos_axe = zeros(4,4);
    w_axe   = pos_GRA(3)/2;
    h_axe   = pos_GRA(4)/2;
    x_axe   = 0;
    xL_axe  = 0;
    xR_axe  = xL_axe+w_axe;
    yU_axe  = pos_GRA(2)+pos_GRA(4)-h_axe;
    yD_axe  = pos_GRA(2);
    pos_axe(1,:) = [xL_axe yU_axe w_axe h_axe];
    pos_axe(2,:) = [xR_axe yU_axe w_axe h_axe];
    pos_axe(3,:) = [xL_axe yD_axe w_axe h_axe];
    pos_axe(4,:) = [xR_axe yD_axe w_axe h_axe];
    if (bdx~=0) | (bdy~=0)
        w_max   = w_axe-bdx;
        h_max   = h_axe-bdy;
        [w_ini,h_ini] = wpropimg(imgSize,w_max,h_max);
        scal_XY = [w_ini/w_axe,h_ini/h_axe];
        deltaXY = [w_axe-w_ini,h_axe-h_ini];
        multiXY = [1.5 1.5];
        alfaXY  = (2*deltaXY)./(2+multiXY);
        betaXY  = (multiXY.*deltaXY)./(2+multiXY);
        pos_axe([1 3],1) = pos_axe([1 3],1)+alfaXY(1);
        pos_axe([2 4],1) = pos_axe([2 4],1)+betaXY(1);
        pos_axe([1 2],2) = pos_axe([1 2],2)+betaXY(2);
        pos_axe([3 4],2) = pos_axe([3 4],2)+alfaXY(2);
        pos_axe(:,3) = pos_axe(:,3)*scal_XY(1);
        pos_axe(:,4) = pos_axe(:,4)*scal_XY(2);
    else
        w_ini = w_axe;
        h_ini = h_axe;
        alfaXY = 1;
        betaXY = 1;        
    end
    pos_dec_ori = pos_axe([1 2 4 3],:);
    pos_dec_ori = pos_dec_ori(:,:,ones(1,max_lev_anal));
    for j = 1:max_lev_anal
        pos_dec_ori(:,[3 4],j) = pos_dec_ori(:,[3 4],j)/(2^j);
    end
    w = w_ini/2;
    h = h_ini/2;
    x = pos_axe(3,1);
    y = pos_axe(3,2)+h;
    t = 0;
    for j = 1:max_lev_anal
        tmp = [x y;x+w y;x+w y-h;x y-h]-[0 0 0 0;t t t t]';
        pos_dec_ori(:,[1 2],j) = tmp;
        y = y+h; h = h/2; w = w/2; t = t+h;
    end
    pos_dec_new = pos_dec_ori;
    pos_dec_new(:,1,:) = pos_dec_new(:,1,:)+w_axe+betaXY(1)-alfaXY(1);
    varargout = {pos_axe,pos_dec_ori,pos_dec_new};

  case 'close'
 
  otherwise
    errargt(mfilename,'Unknown Option','msg');
    error('*');
end
