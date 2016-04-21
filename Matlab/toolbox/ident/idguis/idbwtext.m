function idbwtext(figure_name,posXY)
%IDBWTEXT This function builds the INFO TEXT dialog.

%   L. Ljung 9-27-94
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.8 $ $Date: 2001/04/06 14:22:33 $

Xsum = findobj(get(0,'children'),'flat','tag','sitb16');
XID = get(Xsum,'Userdata');
layout
butwh=[mStdButtonWidth mStdButtonHeight];%butw=55;buth=25;
butw=0.6*butwh(1);buth=butwh(2);
ftb=mFrameToText;  % Frame to button
bb = 2; % between buttons
etf = mEdgeToFrame;
figW=iduilay2(3);
set(figure_name,'Color',get(0,'DefaultUIControlBackgroundcolor'));
s1='iduipoin(1);';s3='iduipoin(2);';

   % LEVEL 1

   pos = iduilay1(figW,3);
   uicontrol(figure_name,'pos',pos(1,:),'style','frame');

   uicontrol(figure_name,'pos',pos(2,:),'style',...
   'push','string','Present','callback',[s1,'iduiedit(''present'');',s3]);
   uicontrol(figure_name,'pos',pos(3,:),'style',...
   'push','string','Close','callback',[s1,'iduiaxes(''close'',8);',s3]);
   uicontrol(figure_name,'pos',pos(4,:),'style',...
   'push','string','Help','callback','iduihelp(''idtexti.hlp'',''Help: Text Information'');');

   % LEVEL 2 MAIN INFO BOX

   lev2=pos(1,2)+pos(1,4);
   uicontrol(figure_name,'pos',[etf lev2+mEdgeToFrame figW-2*etf ...
           5*buth+2*ftb],'style','frame');
adj=0.67;
   h(1)=uicontrol(figure_name,'pos',...
             [etf+ftb lev2+etf+mStdButtonHeight/2 ...
             figW-2*(etf+ftb)-buth*adj 4.5*buth],...
             'style','edit','max',2,'Backgroundcolor','w','callback',...
           [s1,'iduiedit(''update_info'');',s3],'Horizontalalignment','left');
   h(2)=uicontrol(figure_name,'pos',...
            [figW-(etf+ftb)-buth*adj lev2+etf+mStdButtonHeight/2  buth*adj 4.5*buth],...
            'style','slider','callback',[s1,'iduiedit(''slide'');',s3]);
   uicontrol(figure_name,...
             'pos',[etf+ftb lev2+etf+mStdButtonHeight/2+4.5*buth+bb figW-2*(etf+ftb) buth],...
             'style','text','string','Diary And Notes');

   % LEVEL 3 INFO BOX

   lev3=lev2+5*buth+etf+2*ftb;
  uicontrol(figure_name,'pos',[etf lev3+etf figW-2*etf ...
            9*mLineHeight+mStdButtonHeight],'style','frame');
   h(3)=uicontrol(figure_name,'pos',...
          [etf+ftb lev3+etf+mStdButtonHeight/2 figW-2*(etf+ftb) 9*mLineHeight],...
          'style','listbox','max',2,'enable','inactive','value',[]);

   % LEVEL 4: HEADING

  lev4 = lev3+etf+9*mLineHeight+mStdButtonHeight;
  pos = iduilay1(figW,4,2,lev4,[],[1 2]);
  uicontrol(figure_name,'pos',pos(1,:),'style','frame');
  uicontrol(figure_name,'pos',pos(4,:),...
             'style','text',...
             'string','Color:','horizontalalignment','left');
   h(6)=uicontrol(figure_name,'pos',pos(5,:),'style','edit',...
             'backgroundcolor','w','HorizontalAlignment','left',...
             'callback',[s1,'iduiedit(''update_color'');',s3],'tag','color');

   h(4)=uicontrol(figure_name,'pos',pos(2,:),...
             'style','text','horizontalalignment','left',...
             'string','Doubleclick on model/data  for info!');
   h(5)= uicontrol(figure_name,'pos',pos(3,:),'style','edit',...
             'backgroundcolor','w','HorizontalAlignment','left',...
             'callback',[s1,'iduiedit(''update_name'');',s3]);
   figH=pos(1,2)+pos(1,4)+etf;
   FigWH=[figW figH];
   set(figure_name,'pos',[posXY FigWH]);
   set(figure_name,'userdata',h);
   set(get(figure_name,'children'),'unit','norm');
   if length(XID.layout)>=8,
	   if XID.layout(8,3)
		   try
			   set(figure_name,'pos',XID.layout(8,1:4));
		   end
	   end,
   end
   iduistat('Done!',1)
 

