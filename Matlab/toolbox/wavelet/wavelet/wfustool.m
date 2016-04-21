function varargout = wfustool(varargin)
%WFUSTOOL Discrete wavelet 2D tool for image fusion.
%   VARARGOUT = WFUSTOOL(VARARGIN)

% WFUSTOOL M-file for wfustool.fig
%      WFUSTOOL, by itself, creates a new WFUSTOOL or raises the existing
%      singleton*.
%
%      H = WFUSTOOL returns the handle to a new WFUSTOOL or the handle to
%      the existing singleton*.
%
%      WFUSTOOL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in WFUSTOOL.M with the given input arguments.
%
%      WFUSTOOL('Property','Value',...) creates a new WFUSTOOL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before wfustool_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to wfustool_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help wfustool

% Last Modified by GUIDE v2.5 15-Dec-2003 15:23:00
%
%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Feb-2003.
%   Last Revision: 12-Nov-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/03/15 22:42:54 $ 


%*************************************************************************%
%                BEGIN initialization code - DO NOT EDIT                  %
%                ----------------------------------------                 %
%*************************************************************************%

gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @wfustool_OpeningFcn, ...
                   'gui_OutputFcn',  @wfustool_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

%*************************************************************************%
%                END initialization code - DO NOT EDIT                    %
%*************************************************************************%


%*************************************************************************%
%                BEGIN Opening Function                                   %
%                ----------------------                                   %
% --- Executes just before wfustool is made visible.                      %
%*************************************************************************%

function wfustool_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to wfustool (see VARARGIN)

% Choose default command line output for wfustool
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes wfustool wait for user response (see UIRESUME)
% uiwait(handles.wfustool_Win);

%%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%
% TOOL INITIALISATION Intodruced manualy in the automatic generated code  %
%%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%
Init_Tool(hObject,eventdata,handles);

%*************************************************************************%
%                END Opening Function                                     %
%*************************************************************************%

%*************************************************************************%
%                BEGIN Output Function                                    %
%                ---------------------                                    %
% --- Outputs from this function are returned to the command line.        %
%*************************************************************************%

function varargout = wfustool_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%*************************************************************************%
%                END Output Function                                      %
%*************************************************************************%


%=========================================================================%
%                BEGIN Create Functions                                   %
%                ----------------------                                   %
% --- Executes during object creation, after setting all properties.      %
%=========================================================================%

function EdiPop_CreateFcn(hObject,eventdata,handles)
% hObject    handle to Edi_Object or Pop_Object (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
% Hint: popupmenu controls usually have a white background on Windows.
% See ISPC and COMPUTER.
if ispc
    % set(hObject,'BackgroundColor','white');
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
%--------------------------------------------------------------------------

function Sli_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Sli_Object (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
%--------------------------------------------------------------------------

%=========================================================================%
%                END Create Functions                                     %
%=========================================================================%


%=========================================================================%
%                BEGIN Callback Functions                                 %
%                ------------------------                                 %
%=========================================================================%

% --- Executes on button press in Pus_CloseWin.
function Pus_CloseWin_Callback(hObject, eventdata, handles)
% hObject    handle to Pus_CloseWin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

hdl_Menus = wtbxappdata('get',hObject,'hdl_Menus');
m_save = hdl_Menus.m_save;
ena_Save = get(m_save,'Enable');
if isequal(lower(ena_Save),'on')
    hFig = get(hObject,'Parent');
    status = wwaitans({hFig,'Image Fusion'},...
        'Save the synthesized image ?',2,'Cancel');
    switch status
        case -1 , return;
        case  1
            wwaiting('msg',hFig,'Wait ... computing');
            save_FUN(m_save,eventdata,handles)
            wwaiting('off',hFig);
        otherwise
    end
end
close(gcbf)
%--------------------------------------------------------------------------

% --- Executes Menu Load_Img1.
function Load_Img1_Callback(hObject,eventdata,handles)

% Get figure handle.
%-------------------
hFig = handles.output;

% Testing file.
%--------------
def_nbCodeOfColors = 255;
imgFileType = ['*.mat;*.bmp;*.hdf;*.jpg;*.jpeg;*.pcx;*.tif;*.tiff;*.gif'];
[imgInfos,img_anal,map,ok] = ...
    utguidiv('load_img',hFig,imgFileType,'Load Image',def_nbCodeOfColors);
if ~ok, return; end
okSize = tst_ImageSize(hFig,1,imgInfos);

% Cleaning.
%----------
wwaiting('msg',hFig,'Wait ... cleaning');
CleanTOOL(hFig,eventdata,handles,'Load_Img1_Callback','beg');

% Setting GUI values and Analysis parameters.
%--------------------------------------------
max_lev_anal = 8;
levm   = wmaxlev(imgInfos.size,'haar');
levmax = min(levm,max_lev_anal);
[curlev,curlevMAX] = cbanapar('get',hFig,'lev','levmax');
if levmax<curlevMAX
    cbanapar('set',hFig, ...
        'lev',{'String',int2str([1:levmax]'),'Value',min(levmax,curlev)} ...
        );
end
%---------------------------------
if isequal(imgInfos.true_name,'X')
    img_Name = imgInfos.name;
else
    img_Name = imgInfos.true_name;
end
img_Size = imgInfos.size;
%---------------------------------
NB_ColorsInPal = size(map,1);
if imgInfos.self_map , arg = map; else , arg = []; end
curMap = get(hFig,'Colormap');
NB_ColorsInPal = max([NB_ColorsInPal,size(curMap,1)]);
cbcolmap('set',hFig,'pal',{'pink',NB_ColorsInPal,'self',arg});
%---------------------------------
n_s = [img_Name '  (' , int2str(img_Size(2)) 'x' int2str(img_Size(1)) ')'];
set(handles.Edi_Data_NS,'String',n_s);                
axes(handles.Axe_Image_1); 
image(img_anal); 
setAxesTitle(handles.Axe_Image_1,'Image 1');

% End waiting.
%-------------
CleanTOOL(hFig,eventdata,handles,'Load_Img1_Callback','end');
wwaiting('off',hFig);
%--------------------------------------------------------------------------
% --- Executes on Menu or Load_Img2.
function Load_Img2_Callback(hObject, eventdata, handles)

% Get figure handle.
%-------------------
hFig = handles.output;

% Testing file.
%--------------
def_nbCodeOfColors = 255;
imgFileType = ['*.mat;*.bmp;*.hdf;*.jpg;*.jpeg;*.pcx;*.tif;*.tiff;*.gif'];
[imgInfos,img_anal,map,ok] = ...
    utguidiv('load_img',hFig,imgFileType,'Load Image',def_nbCodeOfColors);
if ~ok, return; end
okSize = tst_ImageSize(hFig,2,imgInfos);
% if ~okSize, return; end

% Cleaning.
%----------
wwaiting('msg',hFig,'Wait ... cleaning');
CleanTOOL(hFig,eventdata,handles,'Load_Img2_Callback','beg');

% Setting GUI values and Analysis parameters.
%--------------------------------------------
max_lev_anal = 8;
levm   = wmaxlev(imgInfos.size,'haar');
levmax = min(levm,max_lev_anal);
[curlev,curlevMAX] = cbanapar('get',hFig,'lev','levmax');
if levmax<curlevMAX
    cbanapar('set',hFig, ...
        'lev',{'String',int2str([1:levmax]'),'Value',min(levmax,curlev)} ...
        );
end
%---------------------------------
if isequal(imgInfos.true_name,'X')
    img_Name = imgInfos.name;
else
    img_Name = imgInfos.true_name;
end
img_Size = imgInfos.size;
%---------------------------------
NB_ColorsInPal = size(map,1);
if imgInfos.self_map , arg = map; else , arg = []; end
curMap = get(hFig,'Colormap');
NB_ColorsInPal = max([NB_ColorsInPal,size(curMap,1)]);
cbcolmap('set',hFig,'pal',{'pink',NB_ColorsInPal,'self',arg});
%---------------------------------
n_s = [img_Name '  (' , int2str(img_Size(2)) 'x' int2str(img_Size(1)) ')'];
set(handles.Edi_Image_2,'String',n_s);                
axes(handles.Axe_Image_2); 
image(img_anal); 
setAxesTitle(handles.Axe_Image_2,'Image 2');
setAxesXlabel(handles.Axe_Image_Fus,'Synthesized Image');

% End waiting.
%-------------
CleanTOOL(hFig,eventdata,handles,'Load_Img2_Callback','end');
wwaiting('off',hFig);
%--------------------------------------------------------------------------

% --- Executes on button press in Pus_Decompose.
function Pus_Decompose_Callback(hObject, eventdata, handles)

hFig = handles.output;
axe_IND = [...
        handles.Axe_ImgDec_1 , ...
        handles.Axe_ImgDec_2 , ...
        handles.Axe_ImgDec_Fus ...
    ];
axe_CMD = [...
        handles.Axe_Image_1 , ...
        handles.Axe_Image_2 , ...
        handles.Axe_Image_Fus ...
    ];
axe_ACT = [];

% Cleaning.
%----------
wwaiting('msg',hFig,'Wait ... cleaning');
CleanTOOL(hFig,eventdata,handles,'Pus_Decompose_Callback','beg');

% Decomposition.
%---------------
[wname,level] = cbanapar('get',hFig,'wav','lev');
Image_1 = findobj(handles.Axe_Image_1,'type','image');
X = get(Image_1,'Cdata');
tree_1 = wfustree(X,level,wname);
Image_2 = findobj(handles.Axe_Image_2,'type','image');
X = get(Image_2,'Cdata');
tree_2 = wfustree(X,level,wname);

% Store Decompositions Parameters.
%--------------------------------
tool_PARAMS = wtbxappdata('get',hFig,'tool_PARAMS');
tool_PARAMS.DecIMG_1 = tree_1;
tool_PARAMS.DecIMG_2 = tree_2;
dwt_ATTRB = struct('type','dwt','wname',wname,'level',level);
tool_PARAMS.dwt_ATTRB = dwt_ATTRB;
wtbxappdata('set',hFig,'tool_PARAMS',tool_PARAMS);

% Show Decompositions.
%---------------------
axes(handles.Axe_ImgDec_1);
DecIMG_1 = getdec(tree_1);
image(DecIMG_1);
setAxesTitle(handles.Axe_ImgDec_1,'Decomposition 1');
axes(handles.Axe_ImgDec_2);
DecIMG_2 = getdec(tree_2);
image(DecIMG_2);
setAxesTitle(handles.Axe_ImgDec_2,'Decomposition 2');
dynvtool('init',hFig,axe_IND,axe_CMD,axe_ACT,[1 1],'','','','int');

% End waiting.
%-------------
CleanTOOL(hFig,eventdata,handles,'Pus_Decompose_Callback','end');
wwaiting('off',hFig);
%--------------------------------------------------------------------------

% --- Executes on selection change in Pop_Fus_App.
function Pop_Fus_App_Callback(hObject, eventdata, handles)

Edi = handles.Edi_Fus_App;
Txt = handles.Txt_Edi_App;
set_Fus_Param(hObject,Edi,Txt,eventdata,handles)
set(handles.Tog_Inspect,'Enable','Off');
%--------------------------------------------------------------------------

% --- Executes on selection change in Pop_Fus_Det.
function Pop_Fus_Det_Callback(hObject, eventdata, handles)

Edi = handles.Edi_Fus_Det;
Txt = handles.Txt_Edi_Det;
set_Fus_Param(hObject,Edi,Txt,eventdata,handles)
set(handles.Tog_Inspect,'Enable','Off');
%--------------------------------------------------------------------------

% --- Executes on selection change in Edi_Fus_Det.
function Edi_Fus_App_Callback(hObject, eventdata, handles)

Pop = handles.Pop_Fus_App;
Edi = handles.Edi_Fus_App;
ok  = tst_Fus_Param(Pop,Edi,eventdata,handles);
%--------------------------------------------------------------------------

% --- Executes on selection change in Edi_Fus_Det.
function Edi_Fus_Det_Callback(hObject, eventdata, handles)

Pop = handles.Pop_Fus_Det;
Edi = handles.Edi_Fus_Det;
ok  = tst_Fus_Param(Pop,Edi,eventdata,handles);
%--------------------------------------------------------------------------

% --- Executes on button press in Pus_Fusion.
function Pus_Fusion_Callback(hObject, eventdata, handles)

hFig = handles.output;

% Cleaning.
%----------
wwaiting('msg',hFig,'Wait ... cleaning');
CleanTOOL(hFig,eventdata,handles,'Pus_Fusion_Callback','beg');

% Get Decompositions Parameters.
%-------------------------------
tool_PARAMS = wtbxappdata('get',hFig,'tool_PARAMS');
tree_1 = tool_PARAMS.DecIMG_1;
tree_2 = tool_PARAMS.DecIMG_2;
dwt_ATTRB = tool_PARAMS.dwt_ATTRB;
type  = dwt_ATTRB.type;
wname = dwt_ATTRB.wname;
level = dwt_ATTRB.level;

% Get Fusion Parameters.
%-----------------------
AfusMeth = get_Fus_Param('app',handles);
DfusMeth = get_Fus_Param('det',handles);

% Make Fusion.
%-------------
[XFus,tree_F] = wfusdec(tree_1,tree_2,AfusMeth,DfusMeth);
DecImgFus = getdec(tree_F);
tool_PARAMS.DecIMG_F = tree_F;
wtbxappdata('set',hFig,'tool_PARAMS',tool_PARAMS);

% Plot Decomposition and Image.
%------------------------------
axes(handles.Axe_ImgDec_Fus); 
image(DecImgFus);
setAxesXlabel(handles.Axe_ImgDec_Fus,'Fusion of Decompositions');
axes(handles.Axe_Image_Fus);
image(XFus);
setAxesXlabel(handles.Axe_Image_Fus,'Synthesized Image');
%---------------------------------------------
axe_IND = [...
        handles.Axe_ImgDec_1 , ...
        handles.Axe_ImgDec_2 , ...
        handles.Axe_ImgDec_Fus ...
    ];
axe_CMD = [...
        handles.Axe_Image_1 , ...
        handles.Axe_Image_2 , ...
        handles.Axe_Image_Fus ...
    ];
axe_ACT = [];
dynvtool('init',hFig,axe_IND,axe_CMD,axe_ACT,[1 1],'','','','int');

% End waiting.
%-------------
set(handles.Tog_Inspect,'Enable','On');
CleanTOOL(hFig,eventdata,handles,'Pus_Fusion_Callback','end');
wwaiting('off',hFig);
%--------------------------------------------------------------------------

% --- Executes on button press in Tog_Inspect.
function Tog_Inspect_Callback(hObject,eventdata,handles)

hFig = handles.output;
Val_Inspect = get(hObject,'Value');

% Cleaning.
%----------
wwaiting('msg',hFig,'Wait ... cleaning');
CleanTOOL(hFig,eventdata,handles,'Tog_Inspect_Callback','beg',Val_Inspect);

axe_INI = [...
        handles.Axe_ImgDec_1 , handles.Axe_ImgDec_2 , handles.Axe_ImgDec_Fus ,...
        handles.Axe_Image_1  , handles.Axe_Image_2 ,  handles.Axe_Image_Fus...
    ];
child = allchild(axe_INI);
child = cat(1,child{:})';
child_INI = findobj(child)';
axe_TREE = [...
        handles.Axe_Tree_Dec , ...
        handles.Axe_Tree_Img1  , handles.Axe_Tree_Img2 ,  handles.Axe_Tree_ImgF...
    ];
child = allchild(axe_TREE);
child_DEC = cat(1,child{:})';
child_DEC = findobj(child_DEC)';

hdl_Arrows = wtbxappdata('get',hFig,'hdl_Arrows');
switch Val_Inspect
    case 0 ,
        set([axe_TREE , child_DEC],'Visible','Off');
        delete(child_DEC);
        set([axe_INI  , child_INI , hdl_Arrows(:)'],'Visible','On');
        dynvtool('init',hFig,axe_INI(1:3),axe_INI,[],[1 1],'','','','int');
        set(hObject,'String','Inspect Fusion Tree');
        set(handles.Pus_CloseWin,'Enable','On');
    case 1 ,
        dynvtool('ini_his',hFig,-1);
        set([axe_INI  , child_INI , hdl_Arrows(:)'],'Visible','Off');        
        set([axe_TREE , child_DEC],'Visible','On');
        Tree_MANAGER('create',hFig,eventdata,handles);
        set(hObject,'String','Return to Decompositions');
        set(handles.Pus_CloseWin,'Enable','Off');
end

% End waiting.
%-------------
CleanTOOL(hFig,eventdata,handles,'Tog_Inspect_Callback','end',Val_Inspect);
wwaiting('off',hFig);
%--------------------------------------------------------------------------

% --- Executes on selection change in Pop_Nod_Lab.
function Pop_Nod_Lab_Callback(hObject,eventdata,handles)

hFig = handles.output;
lab_Value  = get(hObject,'Value');
lab_String = get(hObject,'String');
NodeLabType = deblank(lab_String{lab_Value,:});
node_PARAMS = wtbxappdata('get',hFig,'node_PARAMS');
if isequal(NodeLabType,node_PARAMS.nodeLab) , return; end
node_PARAMS.nodeLab = NodeLabType;
wtbxappdata('set',hFig,'node_PARAMS',node_PARAMS);
Tree_MANAGER('setNodeLab',hFig,eventdata,handles,lab_Value)
%--------------------------------------------------------------------------

% --- Executes on selection change in Pop_Nod_Act.
function Pop_Nod_Act_Callback(hObject,eventdata, handles)

hFig = handles.output;
act_Value = get(hObject,'Value');
act_String = get(hObject,'String');
NodeActType = deblank(act_String{act_Value,:});
node_PARAMS = wtbxappdata('get',hFig,'node_PARAMS');
if isequal(NodeActType,node_PARAMS.nodeAct) , return; end
node_PARAMS.nodeAct = NodeActType;
wtbxappdata('set',hFig,'node_PARAMS',node_PARAMS);
Tree_MANAGER('setNodeAct',hFig,eventdata,handles,act_Value)

%=========================================================================%
%                END Callback Functions                                   %
%=========================================================================%



%=========================================================================%
%                    TREE MANAGEMENT and CALLBACK FUNCTIONS               %
%-------------------------------------------------------------------------%
function varargout = Tree_MANAGER(option,hFig,eventdata,handles,varargin)

% Miscelleanous Values.
%----------------------
line_color = [0 0 0];
actColor   = 'b';
inactColor = 'r';

% MemBloc of stored values.
%--------------------------
n_stored_val = 'NTREE_Plot';
ind_tree     = 1;
ind_Class    = 2;
ind_hdls_txt = 3;
ind_hdls_lin = 4;
ind_menu_NodeLab =  5;
ind_type_NodeLab =  6;
ind_menu_NodeAct =  7;
ind_type_NodeAct =  8;
ind_menu_TreeAct =  9;
ind_type_TreeAct = 10;
nb1_stored = 10;

% Handles.
%---------
tool_hdl_AXES = wtbxappdata('get',hFig,'tool_hdl_AXES');
axe_TREE = tool_hdl_AXES.axe_TREE;
Axe_Tree_Dec  = axe_TREE(1);
Axe_Tree_Img1 = axe_TREE(2);
Axe_Tree_Img2 = axe_TREE(3);
Axe_Tree_ImgF = axe_TREE(4);

% tool_PARAMS.
%-------------
tool_PARAMS = wtbxappdata('get',hFig,'tool_PARAMS');
tree_F = tool_PARAMS.DecIMG_F;

str_numf = sprintf('%20.15f',hFig);
switch option
    case 'create'
        % node_PARAMS.
        %-------------
        node_PARAMS = wtbxappdata('get',hFig,'node_PARAMS');
        type_NodeLab = node_PARAMS.nodeLab;
        type_NodeAct = node_PARAMS.nodeAct;
        
        Tree_Colors = struct(...
            'line_color',line_color, ...
            'actColor',actColor,     ...
            'inactColor',inactColor);  
        wtbxappdata('set',hFig,'Tree_Colors',Tree_Colors);
        set(Axe_Tree_Dec,'DefaultTextFontSize',8)
        order = treeord(tree_F);
        depth = treedpth(tree_F);
        allN  = allnodes(tree_F);
        NBnod = (order^(depth+1)-1)/(order-1);
        table_node = -ones(1,NBnod);
        table_node(allN+1) = allN;
        [xnpos,ynpos] = xynodpos(table_node,order,depth);
        
        hdls_lin = zeros(1,NBnod);
        hdls_txt = zeros(1,NBnod);
        i_fath  = 1;
        i_child = i_fath+[1:order];
        for d=1:depth
            ynT = ynpos(d,:);
            ynL = ynT+[0.01 -0.01];
            for p=0:order^(d-1)-1
                if table_node(i_child(1)) ~= -1
                    for k=1:order
                        ic = i_child(k);
                        hdls_lin(ic) = line(...
                            'Parent',Axe_Tree_Dec, ...
                            'XData',[xnpos(i_fath) xnpos(ic)],...
                            'YData',ynL,...
                            'Color',line_color);
                    end
                end
                i_child = i_child+order;
                i_fath  = i_fath+1;
            end
        end
        labels = tlabels(tree_F,'i'); % Indices
        textProp = {...
                'Parent',Axe_Tree_Dec,          ...
                'FontWeight','bold',            ...
                'Color',actColor,               ...
                'HorizontalAlignment','center', ...
                'VerticalAlignment','middle',   ...
                'Clipping','on'                 ...
            };    
        
        i_node = 1;   
        hdls_txt(i_node) = ...
            text(textProp{:},...
            'String', labels(i_node,:),   ...
            'Position',[0 0.1 0],         ...
            'UserData',table_node(i_node) ...
            );
        i_node = i_node+1;
        
        i_fath  = 1;
        i_child = i_fath+[1:order];
        for d=1:depth
            for p=0:order:order^d-1
                if table_node(i_child(1)) ~= -1
                    p_child = p + [0:order-1];
                    for k=1:order
                        ic = i_child(k);
                        hdls_txt(ic) = text(...
                            textProp{:},...
                            'String',labels(i_node,:), ...
                            'Position',[xnpos(ic) ynpos(d,2) 0],...
                            'Userdata',table_node(ic)...
                            );
                        i_node = i_node+1;
                    end
                end
                i_child = i_child+order;
            end
        end
        nodeAction = ...
            [mfilename '(''nodeAction_CallBack'',gco,[],' num2mstr(hFig) ');'];
        set(hdls_txt(hdls_txt~=0),'ButtonDownFcn',nodeAction);
        [nul,notAct] = findactn(tree_F,allN,'na');
        set(hdls_txt(notAct+1),'Color',inactColor);
        %----------------------------------------------
        switch type_NodeLab
            case 'Index' ,
            otherwise    , plot(tree_F,'setNodeLabel',hFig,type_NodeLab);
        end        
        %----------------------------------------------
        m_lab = [];
        wmemtool('wmb',hFig,n_stored_val, ...
            ind_tree,tree_F,      ...
            ind_hdls_txt,hdls_txt, ...
            ind_hdls_lin,hdls_lin, ...
            ind_menu_NodeLab,m_lab, ...
            ind_type_NodeLab,'Index', ...
            ind_type_NodeAct,'' ...
            );        
        %----------------------------------------------
        setAxesTitle(Axe_Tree_Dec,'Wavelet Decomposition Tree');
        %================ BUG for Title ==================
        h_Title = get(Axe_Tree_Dec,'title');
        pos = get(h_Title,'Position');
        set(h_Title,'Position',[0  0.0354  1.000]);
        %=================================================
        show_Node_IMAGES(hFig,'Visualize',0)
        
    case 'setNodeLab'
        if length(varargin)>1
            labValue = varargin{1};
        else
            handles = guihandles(hFig);
            labValue = get(handles.Pop_Nod_Lab,'Value');
        end
        switch labValue
            case 1 , labtype = 'i'; 
            case 2 , labtype = 'dp';
            case 3 , labtype = 's';
            case 4 , labtype = 't';
        end
        labels = tlabels(tree_F,labtype);
        hdls_txt = wmemtool('rmb',hFig,n_stored_val,ind_hdls_txt);
        hdls_txt = hdls_txt(hdls_txt~=0);
        for k=1:length(hdls_txt), set(hdls_txt(k),'String',labels(k,:)); end

    case 'setNodeAct'
        actValue = varargin{1};
        nodeAction = ...
            [mfilename '(''nodeAction_CallBack'',gco,[],' num2mstr(hFig) ');'];
        hdls_txt = wmemtool('rmb',hFig,n_stored_val,ind_hdls_txt);
        set(hdls_txt(hdls_txt~=0),'ButtonDownFcn',nodeAction);        
end
%-------------------------------------------------------------------------%
function nodeAction_CallBack(hObject,eventdata,hFig)

node = plot(ntree,'getNode',hFig);
if isempty(node) , return; end
node_PARAMS = wtbxappdata('get',hFig,'node_PARAMS');
nodeAct = node_PARAMS.nodeAct;
if isequal(nodeAct,'Split_Merge') | isequal(nodeAct,'Split / Merge')
    tool_PARAMS = wtbxappdata('get',hFig,'tool_PARAMS');
    tree_F = tool_PARAMS.DecIMG_F;
    tnrank = findactn(tree_F,node);
    if isnan(tnrank) , return;  end
    plot(tree_F,'Split-Merge',hFig);
    tree_1 = tool_PARAMS.DecIMG_1;
    tree_2 = tool_PARAMS.DecIMG_2;
    if tnrank>0
        tree_1 = nodesplt(tree_1,node);
        tree_2 = nodesplt(tree_2,node);
        tree_F = nodesplt(tree_F,node);
    else
        tree_1 = nodejoin(tree_1,node);
        tree_2 = nodejoin(tree_2,node);
        tree_F = nodejoin(tree_F,node);
    end
    tool_PARAMS.DecIMG_1 = tree_1;
    tool_PARAMS.DecIMG_2 = tree_2;
    tool_PARAMS.DecIMG_F = tree_F;
    wtbxappdata('set',hFig,'tool_PARAMS',tool_PARAMS);
    Tree_MANAGER('setNodeLab',hFig,eventdata,guihandles(hFig))
else
    show_Node_IMAGES(hFig,nodeAct,node);
end
%-------------------------------------------------------------------------%
function show_Node_IMAGES(hFig,nodeAct,node)

tool_hdl_AXES = wtbxappdata('get',hFig,'tool_hdl_AXES');
axe_TREE = tool_hdl_AXES.axe_TREE;
Axe_Tree_Img1 = axe_TREE(2);
Axe_Tree_Img2 = axe_TREE(3);
Axe_Tree_ImgF = axe_TREE(4);
tool_PARAMS = wtbxappdata('get',hFig,'tool_PARAMS');
tree_1 = tool_PARAMS.DecIMG_1;
tree_2 = tool_PARAMS.DecIMG_2;
tree_F = tool_PARAMS.DecIMG_F;

mousefrm(hFig,'watch')
NBC = cbcolmap('get',hFig,'nbColors');
flag_INVERSE = false;
show_One_IMAGE(nodeAct,tree_1,node,NBC,flag_INVERSE,Axe_Tree_Img1,'Image 1')
show_One_IMAGE(nodeAct,tree_2,node,NBC,flag_INVERSE,Axe_Tree_Img2,'Image 2')
show_One_IMAGE(nodeAct,tree_F,node,NBC,flag_INVERSE,Axe_Tree_ImgF,'Synthesized Image')
lind = tlabels(tree_F,'i',node);
ldep = tlabels(tree_F,'p',node);
axeTitle = ['Coefficients: node ' lind ' or ' ldep];
if isequal(nodeAct,'Reconstruct')
    axeTitle = ['Reconstructed ' axeTitle];
end

setAxesTitle(Axe_Tree_ImgF,axeTitle);
mousefrm(hFig,'arrow')
dynvtool('init',hFig,axe_TREE(1),axe_TREE(2:4),[],[1 1],'','','','int');
%-------------------------------------------------------------------------%
function show_One_IMAGE(nodeAct,treeOBJ,node,NBC,flag_INVERSE,axe,xlab)

X = getCoded_IMAGE(nodeAct,treeOBJ,node,NBC,flag_INVERSE);
axes(axe); 
image(X);
setAxesXlabel(axe,xlab);
%-------------------------------------------------------------------------%
function X = getCoded_IMAGE(nodeAct,treeOBJ,node,NBC,flag_INVERSE)

switch nodeAct
    case 'Visualize' , [nul,X] = nodejoin(treeOBJ,node);
    case 'Reconstruct' , X = rnodcoef(treeOBJ,node);
end
if node>0 , 
    X = wcodemat(X,NBC,'mat',1);
    if flag_INVERSE & rem(node,4)~=1 , X = max(max(X))-X; end
end
%==========================================================================


%=========================================================================%
%                BEGIN Callback Menus                                     %
%                --------------------                                     %
%=========================================================================%

function demo_FUN(hObject,eventdata,handles,numDEM)

switch numDEM
    case 1 
        I_1 = 'detail_1'; I_2 = 'detail_2';
        wname = 'db1' ; level = 2;
        AfusMeth = 'max';
        DfusMeth = 'max'; 
    case 2
        I_1 = 'cathe_1'; I_2 = 'cathe_2';
        wname = 'db1' ; level = 2;
        AfusMeth = 'max'; 
        DfusMeth = 'max';       
    case 3
        I_1 = 'mask'; I_2 = 'bust';
        wname = 'db1' ; level = 2;
        AfusMeth = 'max';
        DfusMeth = 'max';
    case 4
        I_1 = 'mask'; I_2 = 'bust';
        wname = 'bior6.8' ; level = 3;
        AfusMeth = 'rand';
        DfusMeth = 'max';         
    case 5
        I_1 = 'mask'; I_2 = 'bust';
        wname = 'db1' ; level = 3;
        AfusMeth = struct('name','UD_fusion','param',4);
        DfusMeth = struct('name','UD_fusion','param',1);
    case 6
        I_1 = 'mask'; I_2 = 'bust';
        wname = 'db1' ; level = 3;
        AfusMeth = 'DU_fusion'; DfusMeth = 'DU_fusion';
    case 7
        I_1 = 'mask'; I_2 = 'bust';
        wname = 'db1' ; level = 3;
        AfusMeth = 'LR_fusion'; DfusMeth = 'LR_fusion';
    case 8
        I_1 = 'mask'; I_2 = 'bust';
        wname = 'db1' ; level = 3;
        AfusMeth = 'RL_fusion'; DfusMeth = 'RL_fusion';
    case 9
        I_1 = 'mask'; I_2 = 'bust';
        wname = 'sym6' ; level = 3;
        AfusMeth = struct('name','UD_fusion','param',2);
        DfusMeth = struct('name','UD_fusion','param',4);
    case 10
        I_1 = 'face_mos'; I_2 = 'mask';
        wname = 'sym4' ; level = 3;
        AfusMeth = 'mean';
        DfusMeth = 'max'; 
    case 11
        I_1 = 'face_pai'; I_2 = 'mask';
        wname = 'sym4' ; level = 3;
        AfusMeth = 'mean';
        DfusMeth = 'max';
    case 12
        I_1 = 'fond_bou'; I_2 = 'mask';
        wname = 'sym4' ; level = 3;
        AfusMeth = struct('name','UD_fusion','param',1);
        DfusMeth = 'max'; 
    case 13
        I_1 = 'fond_mos'; I_2 = 'mask';
        wname = 'sym4' ; level = 3;
        AfusMeth = struct('name','UD_fusion','param',1);
        DfusMeth = 'max'; 
    case 14
        I_1 = 'fond_pav'; I_2 = 'mask';
        wname = 'sym4' ; level = 3;
        AfusMeth = struct('name','UD_fusion','param',0.5);
        DfusMeth = 'max';
    case 15
        I_1 = 'fond_tex'; I_2 = 'mask';
        wname = 'sym4' ; level = 3;
        AfusMeth  = struct('name','UD_fusion','param',0.5);
        DfusMeth = 'img1';
    case 16
        I_1 = 'pile_mos'; I_2 = 'mask';
        wname = 'sym4' ; level = 3;
        AfusMeth  = struct('name','UD_fusion','param',0.5);
        DfusMeth = 'img1'; 
    case 17
        I_1 = 'arms.jpg'; I_2 = 'fond_tex';
        wname = 'sym4' ; level = 3;
        AfusMeth = 'img1'; 
        DfusMeth = 'max'; 
end

% Get figure handle.
%-------------------
hFig = handles.output;

% Testing file.
%--------------
def_nbCodeOfColors = 255;
filename = I_1;
idx = findstr(filename,'.');
if isempty(idx) , filename = [filename '.mat']; end
pathname = utguidiv('WTB_DemoPath',filename);
[imgInfos_1,X_1,map,ok] = ...
    utguidiv('load_dem2D',hFig,pathname,filename,def_nbCodeOfColors);
if ~ok, return; end
okSize = tst_ImageSize(hFig,1,imgInfos_1);

filename = I_2;
idx = findstr(filename,'.');
if isempty(idx) , filename = [filename '.mat']; end
[imgInfos_2,X_2,map,ok] = ...
    utguidiv('load_dem2D',hFig,pathname,filename,def_nbCodeOfColors);
if ~ok, return; end
okSize = tst_ImageSize(hFig,2,imgInfos_2);

% Cleaning.
%----------
wwaiting('msg',hFig,'Wait ... cleaning');
CleanTOOL(hFig,eventdata,handles,'demo_FUN');

% Setting Analysis parameters
%----------------------------
cbanapar('set',hFig,'wav',wname,'lev',level);
set_Fus_Methode('app',AfusMeth,eventdata,handles);
set_Fus_Methode('det',DfusMeth,eventdata,handles);

% Loading Images and Setting GUI.
%-------------------------------
if isequal(imgInfos_1.true_name,'X')
    img_Name_1 = imgInfos_1.name;
else
    img_Name_1 = imgInfos_1.true_name;
end
img_Size_1 = imgInfos_1.size;
NB_ColorsInPal = size(map,1);
if imgInfos_1.self_map , arg = map; else , arg = []; end
cbcolmap('set',hFig,'pal',{'pink',NB_ColorsInPal,'self',arg});
n_s = [img_Name_1 '  (' , int2str(img_Size_1(2)) 'x' int2str(img_Size_1(1)) ')'];
set(handles.Edi_Data_NS,'String',n_s);                
axes(handles.Axe_Image_1); 
image(X_1);
setAxesTitle(handles.Axe_Image_1,'Image 1');
%--------------------------------------------
if isequal(imgInfos_2.true_name,'X')
    img_Name_2 = imgInfos_2.name;
else
    img_Name_2 = imgInfos_2.true_name;
end
img_Size_2 = imgInfos_2.size;
NB_ColorsInPal = size(map,1);
if imgInfos_2.self_map , arg = map; else , arg = []; end
cbcolmap('set',hFig,'pal',{'pink',NB_ColorsInPal,'self',arg});
n_s = [img_Name_2 '  (' , int2str(img_Size_2(2)) 'x' int2str(img_Size_2(1)) ')'];
set(handles.Edi_Image_2,'String',n_s);                
axes(handles.Axe_Image_2); 
image(X_2);
setAxesTitle(handles.Axe_Image_2,'Image 2');
%--------------------------------------------

% Decomposition and Fusion.
%--------------------------
Pus_Decompose_Callback(handles.Pus_Decompose,eventdata,handles);
Pus_Fusion_Callback(handles.Pus_Fusion,eventdata,handles);
%--------------------------------------------------------------------------

function set_Fus_Methode(type,fusMeth,eventdata,handles)

switch type
    case 'app'
        Pop = handles.Pop_Fus_App;
        Edi = handles.Edi_Fus_App;
    case 'det'
        Pop = handles.Pop_Fus_Det;
        Edi = handles.Edi_Fus_Det;
end
if ischar(fusMeth)
    fusMeth.name  = fusMeth;
    fusMeth.param = '';
end
methName = fusMeth.name;
tabMeth = get(Pop,'String');
numMeth = strmatch(methName,tabMeth);
set(Pop,'Value',numMeth);
switch type
    case 'app'
        Pop_Fus_App_Callback(Pop,eventdata,handles);
    case 'det'
        Pop_Fus_Det_Callback(Pop,eventdata,handles);
end
ediVAL = get(Edi,'String');
newVAL = num2str(fusMeth.param);
if isempty(newVAL) , newVAL = ediVAL; end
set(Edi,'String',newVAL);
%-------------------------------------------------------------------------%

function save_FUN(hObject,eventdata,handles)

% Get figure handle.
%-------------------
hFig = handles.output;

% Testing file.
%--------------
[filename,pathname,ok] = utguidiv('test_save',hFig, ...
    '*.mat','Save Synthesized Image');
if ~ok, return; end

% Begin waiting.
%--------------
wwaiting('msg',hFig,'Wait ... saving');

% Getting Synthesized Image.
%---------------------------
axe = handles.Axe_Image_Fus;
img_Fus = findobj(axe,'Type','image');
X = round(get(img_Fus,'Cdata'));
map = cbcolmap('get',hFig,'self_pal');
if isempty(map)
    mi = round(min(min(X)));
    ma = round(max(max(X)));
    if mi<=0 , ma = ma-mi+1; end
    ma  = min([default_nbcolors,max([2,ma])]);
    map = pink(ma);
end

% Saving file.
%--------------
[name,ext] = strtok(filename,'.');
if isempty(ext) | isequal(ext,'.')
    ext = '.mat'; filename = [name ext];
end

wwaiting('off',hFig);
try
    save([pathname filename],'X','map');
catch
    errargt(mfilename,'Save FAILED !','msg');
end
%-------------------------------------------------------------------------%

function close_FUN(hObject,eventdata,handles)

Pus_CloseWin = handles.Pus_CloseWin;
Pus_CloseWin_Callback(Pus_CloseWin,eventdata,handles);
%--------------------------------------------------------------------------

%=========================================================================%
%                END Callback Menus                                       %
%=========================================================================%


%=========================================================================%
%                BEGIN CleanTOOL function                                 %
%                ------------------------                                 %
%=========================================================================%

function CleanTOOL(hFig,eventdata,handles,callName,option,varargin)

tool_PARAMS = wtbxappdata('get',hFig,'tool_PARAMS');
hdl_Menus   = wtbxappdata('get',hFig,'hdl_Menus');
ena_LOAD_DEC = 'On';
switch callName
    case 'demo_FUN'
        tool_PARAMS.flagIMG_1 = true;
        tool_PARAMS.flagIMG_2 = true;
        tool_PARAMS.flagDEC   = false;
        tool_PARAMS.flagFUS   = false;
        tool_PARAMS.flagINS   = false;
        hAXE = [handles.Axe_ImgDec_1,  handles.Axe_ImgDec_2,...
                handles.Axe_Image_Fus, handles.Axe_ImgDec_Fus];
        hIMG = findobj(hAXE,'type','image');
        delete(hIMG);
                
    case 'Load_Img1_Callback'
        switch option
            case 'beg'
                tool_PARAMS.flagIMG_1 = true;
                tool_PARAMS.flagDEC   = false;
                tool_PARAMS.flagFUS   = false;
                tool_PARAMS.flagINS   = false;
                hAXE = [handles.Axe_ImgDec_1,handles.Axe_ImgDec_2 ...
                        handles.Axe_Image_Fus,handles.Axe_ImgDec_Fus ...
                        ];
                hIMG = findobj(hAXE,'type','image');
                delete(hIMG);
            case 'end'
        end
        
    case 'Load_Img2_Callback'
        switch option
            case 'beg' 
                tool_PARAMS.flagIMG_2 = true;
                tool_PARAMS.flagDEC   = false;
                tool_PARAMS.flagFUS   = false;
                tool_PARAMS.flagINS   = false;
                hAXE = [handles.Axe_ImgDec_1,handles.Axe_ImgDec_2 ...
                        handles.Axe_Image_Fus,handles.Axe_ImgDec_Fus ...
                        ];
                hIMG = findobj(hAXE,'type','image');
                delete(hIMG);
            case 'end'
        end
        
    case 'Pus_Decompose_Callback'
        switch option
            case 'beg' , 
                tool_PARAMS.flagDEC = true;
                tool_PARAMS.flagFUS = false;
                hAXE = [handles.Axe_Image_Fus,handles.Axe_ImgDec_Fus];
                hIMG = findobj(hAXE,'type','image');
                delete(hIMG);
            case 'end'
        end
        
    case 'Pus_Fusion_Callback'
        switch option
            case 'beg' ,
            case 'end' , tool_PARAMS.flagFUS = true;
        end
        
    case 'Tog_Inspect_Callback'
        Val_Inspect = varargin{1};
        flag_Enable = logical(1-Val_Inspect);
        switch option
            case 'beg' ,
                tool_PARAMS.flagDEC = false;
                ena_LOAD_DEC = 'Off';
                ena_FUS_PAR  = 'Off';
                ena_NOD_OPT  = 'Off';
            case 'end' ,
                tool_PARAMS.flagDEC = flag_Enable;
                if flag_Enable
                    ena_LOAD_DEC = 'On';
                    ena_FUS_PAR  = 'On';
                    ena_NOD_OPT  = 'Off';
                else
                    ena_LOAD_DEC = 'Off';
                    ena_FUS_PAR  = 'Off';
                    ena_NOD_OPT  = 'On';
                end
        end
        m_Load_Img1 = hdl_Menus.m_Load_Img1;
        m_Load_Img2 = hdl_Menus.m_Load_Img2;
        m_demo = hdl_Menus.m_demo;
        set([m_Load_Img1,m_Load_Img2,m_demo....
             handles.Pus_Decompose],'Enable',ena_LOAD_DEC);
        set([handles.Txt_Fus_Params, ...
             handles.Txt_Fus_App,handles.Pop_Fus_App,  ...
             handles.Txt_Edi_App,handles.Edi_Fus_App,  ...
             handles.Txt_Fus_Det,handles.Pop_Fus_Det,  ...
             handles.Txt_Edi_Det,handles.Edi_Fus_Det],  ...         
            'Enable',ena_FUS_PAR);
        set([handles.Txt_Nod_Lab,handles.Pop_Nod_Lab, ...
             handles.Txt_Nod_Act,handles.Pop_Nod_Act,], ...
            'Enable',ena_NOD_OPT);
end
Ok_DEC = tool_PARAMS.flagIMG_1 & tool_PARAMS.flagIMG_2;
if Ok_DEC & isequal(ena_LOAD_DEC,'On')
    set(handles.Pus_Decompose,'Enable','On');
else
    set(handles.Pus_Decompose,'Enable','Off');
end
if tool_PARAMS.flagDEC
    set(handles.Pus_Fusion,'Enable','On');
else
    set(handles.Pus_Fusion,'Enable','Off');
end

m_save = hdl_Menus.m_save;
if tool_PARAMS.flagFUS
    set(handles.Tog_Inspect,'Enable','On');
    set(m_save,'Enable','On')
else
    set(handles.Tog_Inspect,'Enable','Off');
    set(m_save,'Enable','Off')
end

wtbxappdata('set',hFig,'tool_PARAMS',tool_PARAMS);
%--------------------------------------------------------------------------

%=========================================================================%
%                END CleanTOOL function                                   %
%=========================================================================%



%=========================================================================%
%                BEGIN Tool Initialization                                %
%                -------------------------                                %
%=========================================================================%

function Init_Tool(hObject,eventdata,handles)

% WTBX -- Install DynVTool
%-------------------------
dynvtool('Install_V3',hObject,handles);

% WTBX MENUS -- Install
%----------------------
wfigmngr('extfig',hObject,'ExtFig_GUIDE')
wfigmngr('attach_close',hObject);
set(hObject,'HandleVisibility','On')

% WTBX -- Install ANAPAR FRAME
%-----------------------------
wnameDEF  = 'db1';
maxlevDEF = 5;
levDEF    = 2;
utanapar('Install_V3_CB',hObject,'maxlev',maxlevDEF,'deflev',levDEF);
set(hObject,'Visible','On'); pause(0.01) %%% MiMi : BUG MATLAB %%%
cbanapar('set',hObject,'wav',wnameDEF,'lev',levDEF);

% WTBX -- Install COLORMAP FRAME
%-------------------------------
utcolmap('Install_V3',hObject,'enable','On');
default_nbcolors = 128;
cbcolmap('set',hObject,'pal',{'pink',default_nbcolors})

%-------------------------------------------------------------------------
% TOOL INITIALISATION
%-------------------------------------------------------------------------
% UIMENU INSTALLATION
%--------------------
hdl_Menus = Install_MENUS(hObject);
wtbxappdata('set',hObject,'hdl_Menus',hdl_Menus);
%------------------------------------------------
set(hObject,'DefaultAxesXtick',[],'DefaultAxesYtick',[])
hdl_Arrows = arrowfus(hObject,handles);
wtbxappdata('set',hObject,'hdl_Arrows',hdl_Arrows);
%-------------------------------------------------------------------------
axe_INI = [...
    handles.Axe_ImgDec_1 , handles.Axe_ImgDec_2 , handles.Axe_ImgDec_Fus ,...
    handles.Axe_Image_1  , handles.Axe_Image_2 ,  handles.Axe_Image_Fus...
    ];
axe_TREE = [...
    handles.Axe_Tree_Dec , ...
    handles.Axe_Tree_Img1  , handles.Axe_Tree_Img2 ,  handles.Axe_Tree_ImgF...
    ];
tool_hdl_AXES = struct('axe_INI',axe_INI,'axe_TREE',axe_TREE);
wtbxappdata('set',hObject,'tool_hdl_AXES',tool_hdl_AXES);
%-------------------------------------------------------------------------
setAxesTitle(handles.Axe_Image_1,'Image 1');
setAxesTitle(handles.Axe_Image_2,'Image 2');
setAxesXlabel(handles.Axe_Image_Fus,'Synthesized Image');
setAxesTitle(handles.Axe_ImgDec_1,'Decomposition 1');
setAxesTitle(handles.Axe_ImgDec_2,'Decomposition 2');
setAxesXlabel(handles.Axe_ImgDec_Fus,'Fusion of Decompositions');
%----------------------------------------------------------------
dwt_ATTRB   = struct('type','lwt','wname','','level',[]);
tool_PARAMS = struct(...
    'infoIMG_1',[],'infoIMG_2',[],...    
    'flagIMG_1',false,'flagIMG_2',false,...
    'flagDEC',false,'flagFUS',false, 'flagINS',false, ...
    'DecIMG_1',[],'DecIMG_2',[],'DecIMG_F',[], ...
    'dwt_ATTRB',dwt_ATTRB);
wtbxappdata('set',hObject,'tool_PARAMS',tool_PARAMS);
%-------------------------------------------------------------
node_PARAMS = struct('nodeLab','Index','nodeAct','Visualize');
wtbxappdata('set',hObject,'node_PARAMS',node_PARAMS);
%--------------------------------------------------------------

% End Of initialization.
%-----------------------
redimfig('On',hObject);
set(hObject,'HandleVisibility','Callback')

%=========================================================================%
%                END Tool Initialization                                  %
%=========================================================================%


%=========================================================================%
%                BEGIN Internal Functions                                 %
%                ------------------------                                 %
%=========================================================================%

function hdl_Menus = Install_MENUS(hFig)

m_files = wfigmngr('getmenus',hFig,'file');
m_close = wfigmngr('getmenus',hFig,'close');
cb_close = [mfilename '(''close_FUN'',gcbo,[],guidata(gcbo));'];
set(m_close,'Callback',cb_close);

m_Load_Img1  = uimenu(m_files, ...
    'Label','&Load Image 1',   ...
    'Position',1,              ...
    'Enable','On',             ...
    'Callback',                ...
    [mfilename '(''Load_Img1_Callback'',gcbo,[],guidata(gcbo));']  ...
    );

m_Load_Img2  = uimenu(m_files, ...
    'Label','&Load Image 2',   ...
    'Position',2,              ...
    'Enable','On',             ...
    'Callback',                ...
    [mfilename '(''Load_Img2_Callback'',gcbo,[],guidata(gcbo));']  ...
    );

m_save  = uimenu(m_files,...
    'Label','&Save Synthesized Image ', ...
    'Position',3,    ...
    'Enable','Off',  ...
    'Callback',      ...
    [mfilename '(''save_FUN'',gcbo,[],guidata(gcbo));'] ...
    );
m_demo  = uimenu(m_files,'Label','&Example ','Position',4,'Separator','On');
tab = setstr(9);
demoSET = {...
        ['Magic Square' tab '- wavelet: db1 - level: 2 - fusion method (max,max)'];       ...
        ['Catherine' tab  '- wavelet: db1 - level: 2 - fusion method (max,max)'];         ...
        ['Mask and Bust' tab  '- wavelet: db1 - level: 2 - fusion method (max,max)'];  ...
        ['Mask and Bust' tab  '- wavelet: bior6.8 - level: 3 - fusion method (rand,max)'];  ...
        ['Mask and Bust' tab  '- wavelet: db1 - level: 3 - fusion method (UD_fusion,UD_fusion)'];  ...    
        ['Mask and Bust' tab  '- wavelet: db1 - level: 3 - fusion method (DU_fusion,DU_fusion)'];  ... 
        ['Mask and Bust' tab  '- wavelet: db1 - level: 3 - fusion method (LR_fusion,LR_fusion)'];  ...    
        ['Mask and Bust' tab  '- wavelet: db1 - level: 3 - fusion method (RL_fusion,RL_fusion)'];   ...
        ['Mask and Bust' tab  '- wavelet: sym6 - level: 3 - fusion method ( [UD_fusion,2] , [UD_fusion,4] )'];  ...
        ['Texture (1) and Mask' tab  '- wavelet: sym4 - level: 3 - fusion method (mean,max)'];  ...
        ['Texture (2) and Mask' tab  '- wavelet: sym4 - level: 3 - fusion method (mean,max)'];  ...
        ['Texture (3) and Mask' tab  '- wavelet: sym4 - level: 3 - fusion method ( [UD_fusion,1] , max)']; ... 
        ['Texture (4) and Mask' tab  '- wavelet: sym4 - level: 3 - fusion method ( [UD_fusion,1] , max)']; ... 
        ['Texture (5) and Mask' tab  '- wavelet: sym4 - level: 3 - fusion method ( [UD_fusion,0.5] , max)']; ... 
        ['Texture (6) and Mask' tab  '- wavelet: sym4 - level: 3 - fusion method  ( [UD_fusion,0.5] , img1)'];  ...
        ['Texture (7) and Mask' tab  '- wavelet: sym4 - level: 3 - fusion method  ( [UD_fusion,0.5] , img1)'];  ...
        ['Texture (8) and Arms' tab  '- wavelet: sym4 - level: 3 - fusion method  (img1,max)']  ...        
    };
nbDEM = size(demoSET,1);
sepSET = [3,10];
for k = 1:nbDEM
    strNUM = int2str(k);
    action = [mfilename '(''demo_FUN'',gcbo,[],guidata(gcbo),' strNUM ');'];
    if find(k==sepSET) , Sep = 'On'; else , Sep = 'Off'; end
    uimenu(m_demo,'Label',[demoSET{k,1}],'Separator',Sep,'Callback',action);
end
hdl_Menus = struct('m_files',m_files,'m_close',m_close,...
    'm_Load_Img1',m_Load_Img1,'m_Load_Img2',m_Load_Img2,...
    'm_save',m_save,'m_demo',m_demo);

% Add Help for Tool.
%------------------
wfighelp('addHelpTool',hFig,'&Image Fusion','WFUS_GUI');

%-------------------------------------------------------------------------

% BEGIN: Arrows for WTBX FUSION TOOL %
%------------------------------------%
function hdl_Arrows = arrowfus(fig,handles)
%ARROWFUS Plot the arrows for WFUSTOOL.

colArrowDir = [0.925 0.925 0.925]; % Gray 
colArrowRev = colArrowDir;
axe_arrow = handles.Axe_Utils;
axes(axe_arrow);
Axe_Image_1    = handles.Axe_Image_1;
Axe_ImgDec_1   = handles.Axe_ImgDec_1;
Axe_Image_2    = handles.Axe_Image_2;
Axe_ImgDec_2   = handles.Axe_ImgDec_2;
Axe_Image_Fus  = handles.Axe_Image_Fus;
Axe_ImgDec_Fus = handles.Axe_ImgDec_Fus;
[ar1,t1] = PlotArrow('direct',axe_arrow, ...
    Axe_Image_1,Axe_ImgDec_1,colArrowDir,'On');
[ar2,t2] = PlotArrow('direct',axe_arrow, ...
    Axe_Image_2,Axe_ImgDec_2,colArrowDir,'On');
[ar3,t3] = PlotArrow('reverse',axe_arrow, ...
    Axe_Image_Fus,Axe_ImgDec_Fus,colArrowRev,'On');
[ar4,t4] = PlotArrowVER('direct',axe_arrow, ...
    Axe_ImgDec_1,Axe_ImgDec_2,Axe_ImgDec_Fus,colArrowDir,'On');
set(axe_arrow,'Xlim',[0,1],'Ylim',[0,1])
hdl_Arrows = [ [ar1,t1] ; [ar2,t2] ; [ar3,t3] ; [ar4,t4]];        
%----------------------------------------------------------------
function [ar,t] = ...
    PlotArrow(option,axe_arrow,axeINI,axeEND,colArrow,visible)

pImg = get(axeINI,'Position');
pDec = get(axeEND,'Position');
xAR_ini = pImg(1) + pImg(3);
xAR_end = pDec(1);
dx      = (xAR_end - xAR_ini);
yAR     = pImg(2) + pImg(4)/2;
pt1 = [xAR_ini+dx/6 yAR];
pt2 = [xAR_end-dx/6 yAR];
if isequal(option,'reverse')
    rot = pi; Pini = pt2; strTXT = 'idwt'; colorTXT = 'r';
else
    rot = 0;  Pini = pt1; strTXT = 'dwt';  colorTXT = 'b';
end
ar = wtbarrow('create','axes',axe_arrow,...
    'Scale',[pt2(1)-pt1(1) 1/9],'Trans',Pini,'Rotation',rot, ...
    'Color',colArrow,'Visible',visible);
t = text(...
    'Position',[xAR_ini + dx/3 yAR],...
    'String',strTXT,'FontSize',12,'FontWeight','demi','Color',colorTXT);
%----------------------------------------------------------------
function [ar,t] = PlotArrowVER(option,axe_arrow,...
    Axe_ImgDec_1,Axe_ImgDec_2,Axe_ImgDec_Fus,colArrow,visible)

pDec1 = get(Axe_ImgDec_1,'Position');
pDec2 = get(Axe_ImgDec_2,'Position');
pDecF = get(Axe_ImgDec_Fus,'Position');
dx = pDec1(3)/4;
dy = pDec1(4)/4;
E  = 11*dy/60; 

xAR_ini = pDec1(1) + pDec1(3);
yAR_ini = pDec1(2) + pDec1(4)/2;
Pini  = [xAR_ini , yAR_ini];

x1 = 0;
x2 = pDec1(2)-pDec2(2);
x3 = pDec1(2)-pDecF(2);
XVal = [x1 , x2 , x3];
YVal = [E , 2.5*E , 6*E];

typeARROW_VER = 'special_1';
ar = wtbarrow(typeARROW_VER,'axes',axe_arrow,...
    'XVal',XVal,'YVal',YVal, ...
    'HArrow',dy/4,'WArrow',dy/5,'Width',E, ...
    'Trans',Pini,'Rotation',pi/2, ...   
    'Color',colArrow,'Visible',visible);
xT = xAR_ini + 7*E;
yT = ((pDec1(2) + pDec1(2) + pDec1(4)/2)/2 + pDecF(2)+pDecF(4)/2)/2;
t = text(...
    'Position',[xT yT],...
    'String','FUSION', ...
    'FontWeight','bold','FontSize',10,'Rotation',-90);

%-------------------------------------------------------------------------
% END: Arrows for WTBX FUSION TOOL 
%-------------------------------------------------------------------------

%--------------------------------------------------------------------------
function method = get_Fus_Param(type,handles)

switch type
    case 'app'
        Pop = handles.Pop_Fus_App;
        Edi = handles.Edi_Fus_App;
    case 'det'
        Pop = handles.Pop_Fus_Det;
        Edi = handles.Edi_Fus_Det;
end
numMeth = get(Pop,'Value');
tabMeth = get(Pop,'String');
methName = tabMeth{numMeth};
switch methName
    case {'max','min','mean','rand','img1','img2'} , 
        param = get(Edi,'String');
    case 'linear' ,  
        param = str2double(get(Edi,'String'));
    case {'UD_fusion','DU_fusion','LR_fusion','RL_fusion'}
        param = str2double(get(Edi,'String'));
    case 'userDEF' 
        ok = tst_Fus_Param(Pop,Edi,[],handles);
        param = get(Edi,'String');
        
end
method  = struct('name',methName,'param',param);
%--------------------------------------------------------------------------

function set_Fus_Param(Pop,Edi,Txt,eventdata,handles)

numMeth = get(Pop,'Value');
tabMeth = get(Pop,'String');
methName = tabMeth{numMeth};
switch methName
    case {'max','min','mean','rand','img1','img2'} , 
        vis = 'Off'; ediVAL = ''; txtSTR = '';
    case 'linear' ,  
        vis = 'On'; ediVAL = 0.5; txtSTR = '0 <= Param. <= 1';
    case {'UD_fusion','DU_fusion','LR_fusion','RL_fusion'}
        vis = 'On'; ediVAL = 1;   txtSTR = '0 <= Param.';
    case 'userDEF' 
        vis = 'On'; ediVAL = '';  txtSTR = 'Func. Name';
end
set(Txt,'String',txtSTR);
set(Edi,'String',num2str(ediVAL));
set([Edi,Txt],'Visible',vis);
%--------------------------------------------------------------------------

function ok = tst_Fus_Param(Pop,Edi,eventdata,handles)

numMeth = get(Pop,'Value');
tabMeth = get(Pop,'String');
methName = tabMeth{numMeth};
switch methName
    case 'linear' ,  
        def_ediVAL = 0.5;
        param = str2double(get(Edi,'String'));
        ok = ~isnan(param);
        if ok , ok = (0 <= param) & (param <= 1); end
        
    case {'UD_fusion','DU_fusion','LR_fusion','RL_fusion'}
        def_ediVAL = 1;
        param = str2double(get(Edi,'String'));
        ok = ~isnan(param);
        if ok , ok = (0 <= param); end
        
    case 'userDEF' 
        def_ediVAL = 'wfusfun';
        param = get(Edi,'String');
        ok = ~isempty(param) & ischar(param);
        if ok ,
            userFusFUN = which(param);
            ok = ~isempty(userFusFUN);
        end
        
    otherwise
        ok = true; param = get(Edi,'String');
end
if ok , def_ediVAL = param; end
set(Edi,'String',num2str(def_ediVAL));

%--------------------------------------------------------------------------

function okSize = tst_ImageSize(hFig,numIMG,info_IMG)

tool_PARAMS = wtbxappdata('get',hFig,'tool_PARAMS');  
switch numIMG
    case 1 , info_OTHER = tool_PARAMS.infoIMG_2;
    case 2 , info_OTHER = tool_PARAMS.infoIMG_1;
end
if isempty(info_OTHER)
    okSize = true;
else
    okSize = isequal(info_IMG.size,info_OTHER.size);
end
if ~okSize
    h = warndlg('The two images must be of the same size','Caution','modal');
    waitfor(h);
    wwaiting('off',hFig);
else
    switch numIMG
        case 1 , tool_PARAMS.infoIMG_1 = info_IMG;
        case 2 , tool_PARAMS.infoIMG_2 = info_IMG;
    end
    wtbxappdata('set',hFig,'tool_PARAMS',tool_PARAMS);
end

%=========================================================================%
%                END Internal Functions                                   %
%=========================================================================%


%=========================================================================%
%                BEGIN General Utilities                                  %
%                -----------------------                                  %
%=========================================================================%
function h = setAxesTitle(axe,label)
axes(axe); 
h = title(label,'Color','k','FontWeight','demi');
%----------------------------------------------------------
function h = setAxesXlabel(axe,label)
axes(axe); 
h = xlabel(label,'Color','k','FontWeight','demi');
%=========================================================================%
%                END Tool General Utilities                               %
%=========================================================================%


%=========================================================================%
%                      BEGIN Demo Utilities                               %
%                      ---------------------                              %
%=========================================================================%
function closeDEMO(hFig,eventdata,handles,varargin)
close(hFig);
%----------------------------------------------------------
function demoPROC(hFig,eventdata,handles,varargin)
handles = guidata(hFig);
numDEM  = varargin{1};
demo_FUN(hFig,eventdata,handles,numDEM);
%=========================================================================%
%                   END Tool Demo Utilities                               %
%=========================================================================%
