function editpath(Action)
%EDITPATH Modify the search path.
%   EDITPATH allows the user to modify the current MATLABPATH using a GUI.
%   EDITPATH uses the built-in path editor when available.
%   See also PATHTOOL.

%   Loren Dean
%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 1.1.6.5 $  $Date: 2003/11/06 15:42:01 $

switch nargin,
  case 1,
    PathFig=findobj(get(0,'Children'),'flat','Tag','PathFigure');
    Data=get(PathFig,'UserData');
    set(PathFig,'Pointer','watch');
    PathLoc=get(Data.PathListHandle,'Value');  
    PathListString=get(Data.PathListHandle,'String');
    PathStringLen=size(PathListString,1);
  
    DirName=LocalGetName(Data);

    switch Action,
      %%%%%%%%%%%%%%
      %%% MoveUp %%%
      %%%%%%%%%%%%%%
      case 'MoveUp',
        set([Data.SaveHandle Data.ApplyHandle Data.OrigHandle],'Enable','on');
        PathListStringLocs=1:PathStringLen;
        TopDispValue=get(Data.PathListHandle,'ListboxTop');

        if PathLoc~=1,
          PathListStringLocs(PathLoc-1:PathLoc)=[PathLoc PathLoc-1];
          PathLoc=PathLoc-1;
          if PathLoc<TopDispValue,TopDispValue=PathLoc;end        
        end

        PathListString=PathListString(PathListStringLocs);
        set(Data.PathListHandle, ...
            'String'            ,PathListString, ...
            'Value'             ,PathLoc       , ...
            'ListboxTop'        ,TopDispValue    ...
            );
  
      %%%%%%%%%%%%%%%%
      %%% MoveDown %%%
      %%%%%%%%%%%%%%%%
      case 'MoveDown',
        set([Data.SaveHandle Data.ApplyHandle Data.OrigHandle],'Enable','on');
        PathListStringLocs=1:size(PathListString,1);
 
        if PathLoc~=size(PathListString,1),
          PathListStringLocs(PathLoc:PathLoc+1)=[PathLoc+1 PathLoc];
          PathLoc=PathLoc+1;
        end

        PathListString=PathListString(PathListStringLocs);
        TopDispValue=get(Data.PathListHandle,'ListboxTop');
        set(Data.PathListHandle, ...
           'String'            ,PathListString, ...
           'Value'             ,PathLoc       , ...
           'ListboxTop'        ,TopDispValue    ...
           );
  
    
      %%%%%%%%%%%%%%
      %%% Append %%%
      %%%%%%%%%%%%%%
      case 'Append',
        set([Data.SaveHandle Data.ApplyHandle Data.OrigHandle],'Enable','on');
        DirName=strrep(DirName,matlabroot,Data.RootName);
        if PathLoc==PathStringLen,
          PathListString=[PathListString;{DirName}];
        else
          PathListString=[PathListString(1:PathLoc)
                          {DirName}
                          PathListString(PathLoc+1:PathStringLen)
                         ];
        end
   
        TopDispValue=get(Data.PathListHandle,'ListboxTop');
        set(Data.PathListHandle, ...
           'String'            ,PathListString, ...
           'Value'             ,PathLoc       , ...
           'ListboxTop'        ,TopDispValue    ...
           );
  
      %%%%%%%%%%%%%%
      %%% Insert %%%
      %%%%%%%%%%%%%%
      case 'Insert',
        set([Data.SaveHandle Data.ApplyHandle Data.OrigHandle],'Enable','on');
        DirName=strrep(DirName,matlabroot,Data.RootName);
       
        if PathLoc==1,
          PathListString=[{DirName};PathListString];
        else
          PathListString=[PathListString(1:PathLoc-1)
                          {DirName}
                          PathListString(PathLoc:PathStringLen)
                         ];
        end % if PathLoc
        TopDispValue=get(Data.PathListHandle,'ListboxTop');
        set(Data.PathListHandle, ...
           'String'            ,PathListString, ...
           'Value'             ,PathLoc       , ...
           'ListboxTop'        ,TopDispValue    ...
           );
    
      %%%%%%%%%%%%%%
      %%% Remove %%%
      %%%%%%%%%%%%%%
      case 'Remove',
        set([Data.SaveHandle Data.ApplyHandle Data.OrigHandle],'Enable','on');
        PathListString(PathLoc)=[];
        if numel(PathListString)~=0,
          if PathLoc~=1,PathLoc=PathLoc-1;end
        else
          PathListString={' '};        
        end          
        TopDispValue=get(Data.PathListHandle,'ListboxTop');
        if PathLoc<TopDispValue,TopDispValue=PathLoc;end        
        set(Data.PathListHandle, ...
           'String'            ,PathListString, ...
           'Value'             ,PathLoc       , ...
           'ListboxTop'        ,TopDispValue    ...
           );
   
      %%%%%%%%%%%%%
      %%% Apply %%%
      %%%%%%%%%%%%%    
      case 'Apply',
        set(Data.ApplyHandle,'Enable','off');
        PathListString=LocalMakeMatlabPath(Data,PathListString);          
        path(PathListString);
         
      %%%%%%%%%%%%
      %%% Save %%%
      %%%%%%%%%%%%
      case 'Save',       
        set(Data.ApplyHandle,'Enable','off');
        PathListString=LocalMakeMatlabPath(Data,PathListString);          
        path(PathListString);
        % When uiputfile works correctly, I will use this.        
        %Loc=which('pathdef.m');
        %if isempty(Loc),
        %  Loc='pathdef.m';
        %end          
        [FileName,PathName]=uiputfile('pathdef.m', ...
                                      'Location to save pathdef.m');
                                            
        if ~isequal(FileName,0) && ~isequal(PathName,0),
          savepath(fullfile(PathName,FileName));
          set(Data.SaveHandle,'Enable','off');
        end % if ~isequal          

      %%%%%%%%%%%%%%%%
      %%% Original %%%
      %%%%%%%%%%%%%%%%    
      case 'Original',
        set([Data.SaveHandle Data.ApplyHandle Data.OrigHandle], ...
            {'Enable'},{'on';'on';'off'});
        LocalRefreshPath(Data);
      
      %%%%%%%%%%%%
      %%% Help %%%
      %%%%%%%%%%%%
      case 'Help',
        HelpString={['This tool allows the user to modify the current ' ...
                     'working path in MATLAB and to save the path in ' ...
                     'the specified file.']};
        helpdlg(HelpString,'MATLAB Path Tool Help');
  
      %%%%%%%%%%%%%
      %%% Close %%%
      %%%%%%%%%%%%%
      case 'Close',
        path(path)
        delete(PathFig);
    
      %%%%%%%%%%%%%%%%%
      %%% ChangeDir %%%
      %%%%%%%%%%%%%%%%%
      case 'ChangeDir',
        if strcmp(get(PathFig,'SelectionType'),'open') || ...
           strcmp(get(PathFig,'CurrentCharacter'),13),

          Data.CurDir=DirName;      
          set(Data.CurDirHandle,'String',Data.CurDir);        
          set(PathFig,'UserData',Data);        
          LocalRefreshCurDir(Data);
        
        end % if strcmp

      %%%%%%%%%%%%%%
      %%% CurDir %%%
      %%%%%%%%%%%%%%
      case 'CurDir',    
        NewDir=deblank(get(Data.CurDirHandle,'String'));
        ValidDir=dir(NewDir);
        if ~isempty(ValidDir),
          Data.CurDir=NewDir;
        else
          warndlg({['You must enter a valid directory and path!  ' ...
                   'Old path now being used.']},'Invalid Directory');
        end
        set(Data.CurDirHandle,'String',Data.CurDir);
        set(PathFig,'UserData',Data);    
        LocalRefreshCurDir(Data);

    end % switch

  %%%%%%%%%%%%%%%%%%
  %%% Initialize %%%
  %%%%%%%%%%%%%%%%%%  
  case 0,
    PathFig=[];  
    if usejava('mwt')
		pathtool;
    else
      PathFig=LocalInitFig;
    end
	
  otherwise,
    error('MATLAB:editpath:WrongNumOfInputArgs', ...
	'Wrong number of input arguments to EDITPATH.');
     
end % switch  

if ishandle(PathFig),
  set(PathFig,'Pointer','arrow');
end  


%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalGetName %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%
function DirName=LocalGetName(Data)

DirLoc=get(Data.DirListHandle,'Value');
DirListString=get(Data.DirListHandle,'String');

DirName=DirListString{DirLoc};

if strcmp(DirName(end-2:end),[Data.FileSep '..']),
  SepLocs=findstr(Data.CurDir,Data.FileSep);
  DirName=Data.CurDir(1:max(SepLocs)-1);
    
elseif strcmp(DirName(end-1:end),[Data.FileSep '.']),
  DirName=Data.CurDir;
    
elseif isempty(DirName),
  DirName=Data.CurDir;

else
  if isunix,if strcmp(Data.CurDir,'/'),Data.CurDir='';end;end   

end % if DirName
 
switch Data.SysString
  case 'pc',
    % c: --> c:\
    if length(DirName)==2,DirName=[DirName Data.FileSep];end
  case 'unix',
    % '' --> /
    if isempty(DirName),DirName=Data.FileSep;end
      
end % switch   

DirName=deblank(DirName);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalMakeMatlabPath %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SetPathString=LocalMakeMatlabPath(Data,PathListString)
% Set the MATLABPATH Variable and Path String


% V5 LPD
%PathListString=strrep(PathListString,Data.RootName,LocalMatlabroot);
% setpath(PathListString)

PathSep(1:size(PathListString,1),1)={Data.PathSep};
PathListString=strcat(PathListString,PathSep);
% V5 LPD
%PathListString=[PathListString{:}];
Temp='';
for lp=1:size(PathListString,1),Temp=[Temp PathListString{lp}];end
PathListString=Temp;
SetPathString=strrep(PathListString,Data.RootName,matlabroot);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalRefreshPath %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalRefreshPath(Data)
 
% Get Current Paths
% V5 LPD
% CurrentPath=getpath;
% CurrentPath=strrep(CurrentPath,LocalMatlabroot,Data.RootName);
CurrentPath=path;
CurrentPath=strrep(CurrentPath,matlabroot,Data.RootName);
PathList=eval(['{''' strrep(CurrentPath,Data.PathSep,''';''') '''}']);
 
set(Data.PathListHandle,'String',PathList);
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalRefreshCurDir %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalRefreshCurDir(Data)

% Get Current listing of directories
CurFileDir=dir(Data.CurDir);
DirLoc=find([CurFileDir.isdir]);

PrePend={[Data.CurDir Data.FileSep]};

CurrentDirs={CurFileDir(DirLoc).name}';
CurrentDirs=strcat(PrePend(ones(size(CurrentDirs,1),1)),CurrentDirs);    
set(Data.DirListHandle,'String',CurrentDirs,'Value',1);


%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalInitFig %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%
function PathFig=LocalInitFig

Temp=get(0,'ShowHiddenHandles');set(0,'ShowHiddenHandles','on');
OldFigs=findobj(get(0,'Children'),'flat','Tag','PathFigure');
set(0,'ShowHiddenHandles',Temp);

if ~isempty(OldFigs),
  if length(OldFigs)>1,
    delete(OldFigs(2:end));
    OldFigs(2:end)=[];
  end % if length

  Data=get(OldFigs,'UserData');
  LocalRefreshPath(Data);
  LocalRefreshCurDir(Data);  
else % Create the figure
  
  %%%%%%%%%%%%%%%%%%%%%%
  %%% Get basic info %%%
  %%%%%%%%%%%%%%%%%%%%%%
    
  Black      =[0       0        0      ]/255;
  White      =[255     255      255    ]/255;
  
  %%%%%%%%%%%%%%%%%%%%%%%%
  %%% Set up positions %%%
  %%%%%%%%%%%%%%%%%%%%%%%%
  FigPos=get(0,'DefaultFigurePosition');
  FigWidth=650;
  FigHeight=360;
  FigPos(3:4)=[FigWidth FigHeight];
  
  ButtonHeight=30;
  ButtonWidth=100;
  Offset=10;
    
  ListWidth=220;  
  ListHeight=250;  
  % UpArrow DownArrow
  ArrowPos=zeros(2,4);
  ArrowPos(1,:)=[Offset Offset ButtonWidth ButtonHeight];
  ArrowPos(2,:)=ArrowPos(1,:);
  ArrowPos(2,1)=ArrowPos(1,1)+ListWidth-ArrowPos(2,3);
  
  % List,Root,Title
  PathPos=zeros(2,4);      
  PathPos(1,:)=[ArrowPos(1,1)                                  ...
                sum(ArrowPos(1,[2 4]))+Offset+2*ButtonHeight ...
                ListWidth                                      ...
                ListHeight
               ];
  PathPos(2,:)=[PathPos(1,1) sum(PathPos(1,[2 4])) ...
          PathPos(1,3) ButtonHeight];
  PathPos(2,3)=PathPos(2,3)+100;
  
  %Insert, Remove, Apply, Save, Original
  ControlPos=zeros(5,4);
  ControlPos(1,:)=[sum(PathPos(1,[1 3]))+Offset       ...
                   sum(PathPos(1,[2 4]))-ButtonHeight ...
                   ButtonWidth ButtonHeight];
  ControlPos(1:5,:)=ControlPos(ones(5,1),:);
  ControlPos(2,2)=ControlPos(1,2)-ButtonHeight-Offset;
  
  ControlPos(5,2)=PathPos(1,2);
  ControlPos(4,2)=sum(ControlPos(5,[2 4]))+Offset;
  ControlPos(3,2)=sum(ControlPos(4,[2 4]))+Offset;
  
  
  %% CurDir, String, List, Edit, String
  DirPos=zeros(4,4);
  DirPos(3:4,:)=PathPos;
  DirPos(:,1)=sum(ControlPos(1,[1 3]))+Offset;
  DirPos(:,3)=PathPos(1,3);  
  DirPos(1,[2 4])=[sum(ArrowPos(1,[2 4]))+Offset ButtonHeight];
  DirPos(2,[2 4])=[sum(DirPos(1,[2 4]))  ButtonHeight];
  
  %% Help Close
  MiscPos=ArrowPos;
  MiscPos(1,1)=DirPos(1,1);
  MiscPos(2,1)=sum(DirPos(1,[1 3]))-MiscPos(2,3);
  
  ArrowPos(:,2)=PathPos(1,2)-Offset-ArrowPos(1,4);
  
  Position=[ArrowPos;PathPos;ControlPos;MiscPos;DirPos];      
  
  FigHeight=sum(DirPos(4,[2 4]))+Offset;
  FigWidth =sum(DirPos(4,[1 3]))+Offset;
  FigPos(3:4)=[FigWidth FigHeight];
  
  %%%%% Other Info
  FigColor=get(0,'DefaultUicontrolBackgroundColor');

  UIInfo={'Units'              ,'pixels';'HandleVisibility' ,'callback'
          'ForeGroundColor'    ,Black   ;'Interruptible'    ,'on'
          'HorizontalAlignment','center' 
         };
  
  
  ArrowTags={'Up';'Down'};
  ArrowStyle={'pushbutton';'pushbutton'};
  ArrowBackColor(1:2,1)={get(0,'DefaultUIControlBackgroundColor')};
  ArrowString=ArrowTags;
  ArrowCallback={'editpath MoveUp';'editpath MoveDown'};
  
  PathTags={'PathListBox';'PathRoot'};
  PathStyle={'listbox';'text'};
  PathBackColor={White;FigColor};
  PathString={' ';' '};
  PathCallback={'';''};
  
  ControlTags={'Insert';'Remove';'Apply';'Save';'Original'};
  ControlStyle(1:5,1)={'pushbutton'};      
  ControlBackColor(1:5,1)=ArrowBackColor(1);
  ControlString={'<< Add'      ;'Remove >>'
                 'Apply Path'  ;'Save Path'
                 'Original Path'
                };
  ControlCallback={'editpath Insert' ;'editpath Remove'
                   'editpath Apply'  ;'editpath Save'
                   'editpath Original'
                  }; 
  
  MiscTags={'Help';'Close'};
  MiscStyle(1:2,1)={'pushbutton'};
  MiscBackColor(1:2,1)=ArrowBackColor(1);
  MiscString={'Help';'Close'};
  MiscCallback={'editpath Help';'editpath Close'};

  DirTags={'DirEdit';'DirDir';'DirList';'DirDirs'};
  DirStyle={'edit';'text';'listbox';'text'};
  DirBackColor={White;FigColor;White;FigColor};
  DirString={matlabroot;'Current Directory:';{' '};'Directories:'};
  DirCallback={'editpath CurDir';'';'editpath ChangeDir';''};
  
  Tags=[ArrowTags;PathTags;ControlTags;MiscTags;DirTags];      
  Style=[ArrowStyle;PathStyle;ControlStyle;MiscStyle;DirStyle];      
  BackColor=[ArrowBackColor;PathBackColor;ControlBackColor;
             MiscBackColor ;DirBackColor
            ]; 
  String=[ArrowString;PathString;ControlString;MiscString;DirString]; 
  Callback=[ArrowCallback;PathCallback;ControlCallback
            MiscCallback ;DirCallback
           ];
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%% Set up Figure & buttons %%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  PathFig=figure(                                       ...
                'Color'          ,FigColor            , ...
                'MenuBar'        ,'None'              , ...
                'Name'           ,'MATLAB Search Path', ...
                'IntegerHandle'  ,'off'                , ...
                'NumberTitle'    ,'off'               , ...
                'Pointer'        ,'arrow'             , ...
                'Units'          ,'pixels'            , ...
                'Position'       ,FigPos              , ...
                'Resize'         ,'on'                , ...
                'Visible'        ,'off'               , ...
                'WindowStyle'    ,'normal'            , ...
                'CloseRequestFcn','editpath Close'    , ...
                'Colormap'       ,[]                  , ...
                'Tag'            ,'PathFigure'          ...
                );
  
  Handles = zeros(1, size(Callback, 1));
  for lp=1:size(Callback,1),
    Handles(lp)=uicontrol( ...
        'Parent'         ,PathFig        , ...
        'Style'          ,Style{lp,1}    , ...
        UIInfo(:,1)      ,UIInfo(:,2)'   , ...
        'Position'       ,Position(lp,:) , ...
        'Tag'            ,Tags{lp,1}     , ...
        'BackgroundColor',BackColor{lp,:}, ...
        'String'         ,String{lp,1}   , ...
        'Callback'       ,Callback{lp,1}   ...
        );
  end % for lp                         
  set(Handles,'Units','normalized');
  set(Handles([3 4  12 13 14 15]),'HorizontalAlignment','left');
  set(Handles([3    12]),'Value',1)   

  % Get the MATLAB path and set up the machine specific parameters.
  PathSep = ':';
  FileSep = '/';
  CompType = computer;
  SysString = 'unix';

  if strcmp(CompType(1:2),'PC'),
    PathSep = ';';
    FileSep = '\';
    SysString = 'pc';
  end % if CompType

  Data.DirListHandle=Handles(14);
  Data.PathListHandle=Handles(3);
  Data.CurDirHandle=Handles(12);
  Data.ApplyHandle=Handles(7);  
  Data.SaveHandle=Handles(8); 
  Data.OrigHandle=Handles(9);  
  Data.PathSep=PathSep;
  Data.FileSep=FileSep;
  Data.SysString=SysString; 
  Data.CurDir=matlabroot;      
  Data.RootName='ROOT';
  Data.OriginalPath=path;
  
  set(Data.CurDirHandle,'String',Data.CurDir);
  set(Handles(4),'String',[Data.RootName ' = ' matlabroot]);
  set([Data.SaveHandle Data.ApplyHandle Data.OrigHandle],'Enable','off');
  
  set(PathFig          , ...
     'Visible'         ,'on'      , ...
     'Pointer'         ,'watch'   , ...     
     'UserData'        ,Data      , ...
     'HandleVisibility','callback'  ...    
     );                

end % if ~isempty

LocalRefreshPath(Data);

LocalRefreshCurDir(Data);
