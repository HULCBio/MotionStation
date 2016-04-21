function iduibn(arg,nu,ny)
%IDUIBN Handles model estimation for model that are defined By Name.
%   NU and NY are the number of inputs and outputs in the data set.
%   The argument ARG takes the following values:
%    open  Opens the dialog box
%    close Closes the dialog box
%   All estimation is handled by IDUIIO.

%   L. Ljung 4-4-94
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.8 $  $Date: 2001/04/06 14:22:36 $

%global XIDss XIDparest XIDmse XIDmen XIDplotw XIDlayout
 Xsum = findobj(get(0,'children'),'flat','tag','sitb16');
XID = get(Xsum,'Userdata');


if strcmp(arg,'open')
   FigName='MODEL BY NAME';
   if ~figflag(FigName,0)
       iduistat('Opening model structure editor ...')
       eval('pepos=get(XID.parest(1),''pos'');','pepos=[50 200 204 187];')
       layout
       butwh=[mStdButtonWidth mStdButtonHeight];%butw=55;buth=25;
       butw=butwh(1);buth=butwh(2);
       ftb=2;  % Frame to button
       bb = 2; % between buttons
       etf = mEdgeToFrame;
       lev1=etf; % Level for bottommost frame-buttons
       lev2=lev1+2*ftb+buth+2*bb;  %Level for Method
       PW=3*butw+4*bb+4*ftb;PH=lev2+4*ftb+2.5*buth;
       FigWH=[PW PH];
       XID.mse(4)=figure('pos',[pepos(1)+pepos(3) pepos(2) FigWH],...
       'NumberTitle','off','Vis',ondef,'Name',FigName,'HandleVisibility','callback',...
       'Color',get(0,'DefaultUIControlBackgroundColor'),'userdata',[nu,ny]);
       set(XID.mse(4),'Menubar','none');

% ******************
       % LEVEL 1
       pos = iduilay(FigWH,butwh,ftb,bb,bb,etf,lev1,2);
       uicontrol(XID.mse(4),'pos',pos(1,:),'style','frame');
       uicontrol(XID.mse(4),'pos',pos(2,:),'string','Close','style','push',...
                 'callback','iduibn(''close'');');
       uicontrol(XID.mse(4),'pos',pos(3,:),'string','Help','style','push',...
                 'callback','iduihelp(''iduibn.hlp'',''Defining Model Structure by Name'');');


       %LEVEL 2 CHOICE ARX -IV

       text=str2mat(...
             'Enter the chosen model',...
             'structure in the ESTIMATING',...
             'MODELS window');
       uicontrol(XID.mse(4),'pos',...
               [etf+3*bb lev2 PW-2*(etf+3*bb) 2.5*buth+ftb],'style','edit',...
                 'max',2,'string',text);
       set(XID.parest(4),'value',4);
       set(get(XID.mse(3),'children'),'units','normal')
       if length(XID.layout)>23,if XID.layout(24,3)
          eval('set(XID.mse(4),''pos'',XID.layout(24,1:4))','')
       end,end
       iduistat('Done.',1)
   end
   set(get(XID.mse(4),'children'),'units','normal')
   set(XID.mse(4),'vis','on')
elseif strcmp(arg,'close')
   set(XID.mse(4),'vis','off')
%   set(XID.parest(6),'value',0)
end
