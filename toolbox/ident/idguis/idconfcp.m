function idconfcp(modaxes,docalc)
%IDCONFCP Asks if confidence intervals should be computed, and does so if desired.

%   L. Ljung 9-27-94
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.8 $ $Date: 2001/04/06 14:22:33 $

Xsum = findobj(get(0,'children'),'flat','tag','sitb16');
XID = get(Xsum,'Userdata');

if nargin<2,docalc=0;end

for axh=modaxes(:)'
   axmod=findobj(axh,'tag','modelline');
   axnam=findobj(axh,'tag','name');
   axdum=findobj(axh,'tag','ny0');
   complex=get(axdum(1),'userdata');
   calc=1;
   if ~docalc
      time=complex*XID.counters(6);time=ceil(time/5)*5;
      text=...
         ['It will take about ',int2str(time),' seconds to compute confidence',...
         'intervals for the model ',get(axnam,'string'),...
         'Do you want these calculations to be carried out?',...
         '(If you answer ''no'', the question won''t be repeated for this model)'];
      click=questdlg(text,'Computing Time');
      if strcmp(click,'No')
         delete(axdum),calc=0;
      end
      if strcmp(click,'Cancel')
         calc=0;
      end
   end % if docalc
   if calc
      tic
      Model=get(axmod,'userdata');
      modtem=Model;
      delete(axdum);
      [nr,nc]=size(Model);ny=Model(1,4);
      sizeinfo=[ny;nr;nc;nr*nc+3*ny+5];Model=Model(:);
      for ky=1:ny
         modelky=thss2th(modtem,ky,'noises');[nr,nc]=size(modelky);
         Model=[Model;modelky(:)];
         sizeinfo=[sizeinfo;nr;nc;sizeinfo(length(sizeinfo))+nr*nc];
      end
      Model=[sizeinfo;Model];
      set(axmod,'UserData',Model)
      modtag=get(axh,'tag');
      eltime=toc;XID.counters(6)=eltime/complex;
      modnr=eval(modtag(6:length(modtag)));
      for fig=2:7,iduiclpw(fig,1,modnr);end
   end
end
set(Xsum,'Userdata',XID)





