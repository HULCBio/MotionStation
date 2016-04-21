function out=idwb(title,value,mode)
% CREATEWB is the waitbar constructor. 
% Usage: 
%   WBAR=CREATEWB(TITLE)
%   WBAR=CREATEWB(TITLE,CV)
%
% Inputs:
%   TITLE: title of the waitbar figure  
%   CV: initial criterion value 
%
% Output: 
%   WBAR: reference to the waitbar structure.
%
% See also:
%   CHECKWB, CLEARWB
%

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.5.4.2 $  $Date: 2004/04/10 23:18:38 $
cv = '';
ni=nargin;

switch mode
case 'create'
   xt=[0,.2,.4,.6,.8,1];
   xtl=[' 0 ';'20 ';'40 ';'60 ';'80 ';'100'];
   layout
   butw = mStdButtonWidth;
   FigW = iduilay2(3);
   f = figure('NumberTitle','off','Name',title,...
      'Integerhandle','off',...
      'DockControls','off',...
      'Color',get(0,'DefaultUIControlBackgroundColor'),'vis','off');
   wbar.win = f;
   set(f,'Menubar','none');         
   pos = iduilay1(FigW,3); 
   uicontrol(f,'pos',pos(1,:),'style','frame');
   wbat.buti = uicontrol(f,'pos',pos(2,:),'string',...
      'Interrupt','style','push','callback',...
      'global WAITBARSTOP; WAITBARSTOP=1;');
   wbar.butn = uicontrol(f,'pos',pos(3,:),'string','No Cov',...
      'style','push','callback',  'global WAITBARSTOP; WAITBARSTOP=2;');
   uicontrol(f,'pos',pos(4,:),'string','Help','style',...
      'push','callback',...
      'iduihelp(''idparest.hlp'',''Help: Estimating Models'');');
   lev3 = pos(1,2)+pos(1,4);
   pos = iduilay1(FigW,1,1,lev3);              
   lev4 = pos(1,2)+pos(1,4)+25;
   pos1 = iduilay1(FigW,4,4,lev4);
   text1 = str2mat(... 
      'The translation of covariance information may take some time.',...
      'Push ''INTERRUPT'' to stop the calculations. No uncertainty',...
      'measures will then be shown.',...
      'Push ''NO COV'' to interrupt and to kill covariance information',...
      'in the model. The covariance calculations will then never',...
      'be attempted again.');
   uicontrol(f,'pos',pos1(1,:),'style','frame');
   uicontrol(f,'pos',pos1(2,:)+[0 -70 0 70],'style','text','string',text1,...
   'HorizontalAlignment','left'); 
   %uicontrol(f,'pos',pos1(3,:),'style','text','string',''); 
   FigH=pos1(1,2)+pos1(1,4)+mEdgeToFrame;
   
   FigWH=[FigW,FigH];
   ssz=get(0,'screensize');
   FigXY = [ssz(3)/2-FigW/2,ssz(4)/2-FigH/2];
   set(f,'pos',[FigXY FigWH]);
      figure(f)
   hw = axes('unit','pixel','pos', pos(2,:)+[0 10 0 0]);
   set(hw,'nextplot', 'add','box','on','fontsize', 10)
   set(hw,'ytick', [],'xtick',xt,'xticklabel',xtl)
   axis(axis)
   tit = get(hw,'title');
   set(tit,'string','% Completed');
   wbar.xdat=0.0;
   %drawnow
   hold on
   %drawnow
   wbar.bar=patch('facecolor','r','edgecolor','r','erase',...
      'none','ydata',[0,1,1,0],'xdata',[0,0,0,0]);
   set(get(f,'children'),'units','normal')
   set(f,'vis','on')

   drawnow 
   out = wbar;
   
case 'update'
   wbar = title;
   
   % end of waitfor.m
   
   % CHECK checks iwaitbar stop property and refrech waitbar
   % Usage: 
   %   IND=CHECK(WBAR,VALUE)
   %   IND=CHECK(WBAR,VALUE,CV)
   %
   % Inputs:
   %   WBAR: reference to the wbar structure created by CREATEWB  
   %   VALUE: value (0<VALUE<1) of the wait bar
   %   CV: criterion value 
   %
   % Output: 
   %   IND: 1 if the interrupt button was pressed, 0 if not.
   %
   % See also:
   %   CREATEWB, CLEARWB
   %
   
   global WAITBARSTOP
   ni=nargin;
   error(nargchk(1,3,ni))
   ind=WAITBARSTOP;
   if ni>=2,
      set(wbar.bar,'xdata',[wbar.xdat,wbar.xdat,value,value]);
      wbar.xdat=value;
   end
   %if ni==3 
   %   cvv=num2str(cv);
   %   set(wbar.txt,'string','');
    %  set(wbar.txt,'string', [' Criterion value is ',cvv])
   %end
   out = ind;
case 'close'
   wbar = title;
   
   % CLOSEWB clears WBAR structure from memory and close
   % WBAR figure
   % Usage: 
   %   CLOSEWB(WBAR)
   %
   % See also:
   %   CREATEWB, CHECKWB
   
   
   close(wbar.win)
   clear wbar
   clear global WAITBARSTOP
   % end of closewb.m
end
