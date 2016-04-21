function icondisp(Names)
%ICONDISP Display icons in BTNICON
%  ICONDISP(NAMES) displays icons that are used by BTNICON.  
%
%  NAMES is a string matrix with icons to be displayed.  If no
%  arguments are passed to ICONDISP, NAMES will display all
%  icons.
%
%  See also BTNICON.

%  Loren Dean 3-30-95
%  Copyright 1984-2002 The MathWorks, Inc.
%  $Revision: 1.11 $

if nargin==0,
  Names=[];
  Names=str2mat(Names,'bigzoom'    ,'circle'    ,'deltaomega','doublearrow');
  Names=str2mat(Names,'downarrow'  );
  Names=str2mat(Names,'ellpc'      ,'ellp'      ,'equal'     ,'eraser'     );
  Names=str2mat(Names,'fillcircle' );
  Names=str2mat(Names,'fillellipse','littlezoom','omega'     ,'pause'      );
  Names=str2mat(Names,'play'       ,'polyfill'  ,'polygon'   ,'polyline'   );
  Names=str2mat(Names,'pixel'      );
  Names=str2mat(Names,'record'     ,'rect'      ,'rectc'     ,'select'     );
  Names=str2mat(Names,'select'     ,'spline'    ,'stop'      ,'text'       );
  Names=str2mat(Names,'triangle'   ,'triangle2' ,'uparrow'   ,'zoom'       );
  Names(1,:)=[];
end % if nargin


%%%%%%%%%%%%%%%%%%%% Do Not change anything below this line. %%%%%%%%%%%%%%%%%%
TotalNumBtn=length(Names(:,1));

BtnIconFunctions=[];
BtnButtonIDs=[];
for lp=1:TotalNumBtn;
  BtnIconFunctions=str2mat(BtnIconFunctions                       , ...
                          ['btnicon(''' deblank(Names(lp,:)) ''')'] ...
                          );
  BtnButtonIDs=str2mat(BtnButtonIDs,num2str(lp));
end
BtnIconFunctions(1,:)=[];
BtnButtonIDs(1,:)=[];

BtnGroupID='test';
BtnPressTypes=['flash'];
BtnExclusive=['no'];
BtnCallBack=[''];
BtnOrientation='vertical';

MaxNumBtn=20;
NumCols=ceil(TotalNumBtn/MaxNumBtn);
FigHandle=figure('Units'        ,'inches'      , ...
                 'Position'     ,[0.5 0 8.5 11], ...
                 'PaperPosition',[0 0 8.5 11]    ...
                 );

BtnHeight=0.04;
BtnWidth=0.05;
for lp=1:NumCols,
  BtnNumbers=(lp-1)*MaxNumBtn+1 : min(TotalNumBtn,lp*MaxNumBtn);
  NumBtn=length(BtnNumbers);
  
  BtnPosition=[lp/(NumCols+1)  0.9-BtnHeight*NumBtn  ...
               BtnWidth        BtnHeight*NumBtn      ...
              ];
              
  BtnGroupSize=[NumBtn 1];
  
  BtnHandles=btngroup( ...
                     'IconFunctions',BtnIconFunctions(BtnNumbers,:), ...
                     'GroupID'      ,BtnGroupID                    , ...
                     'ButtonID'     ,BtnButtonIDs(BtnNumbers,:)    , ...
                     'PressType'    ,BtnPressTypes                 , ...
                     'Exclusive'    ,BtnExclusive                  , ...
                     'Callbacks'    ,BtnCallBack                   , ...
                     'GroupSize'    ,BtnGroupSize                  , ...
                     'Position'     ,BtnPosition                   , ...
                     'Orientation'  ,BtnOrientation                  ...
                     );
                   
  TextHandle=text(zeros(NumBtn,1)-0.05    ,1-(1:NumBtn)/NumBtn, ...
                  Names(BtnNumbers,:)             , ...
                 'HorizontalAlignment','right'    , ...
                 'VerticalAlignment'  ,'bottom'     ...
                  );
end
