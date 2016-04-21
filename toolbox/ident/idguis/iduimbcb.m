function iduimbcb(flag,window)
%IDUIMBCB Handles the Mouse Button Callbacks for ident plot windows.
%   The WindowButtonDownFcn is set to iduimbcb in all plot windows.

%   L. Ljung 4-4-94
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.8 $ $Date: 2001/04/06 14:22:39 $

%global XIDplotw

Xsum = findobj(get(0,'children'),'flat','tag','sitb16');
XID = get(Xsum,'Userdata');

if strcmp(flag,'setzoom')
	if window==3
		set(XID.plotw(3,1),'windowbuttonmotionfcn','iduimbcb(''resize'');')
	end
	hmen=findobj(XID.plotw(window,1),'tag','zoom');
	if strcmp(get(hmen,'checked'),'off')
		set(hmen,'checked','on')
		set(XID.plotw(window,1),'windowbuttondownfcn',['iduimbcb(''def'',',int2str(window),');'])
	else
		set(hmen,'checked','off')
		iduimbcb('reset_zoom',window);
		if any(window==[1 2 3 4 5 6 7 13])
			set(gcf,'windowbuttondownfcn',...
				['iduimbcb(''infobox'',',int2str(window),');'])
		elseif window==14
			set(gcf,'windowbuttondownfcn',...
				['iduisel(''down'');'])
		elseif window==15
			set(gcf,'windowbuttondownfcn',...
				['iduifilt(''down'');'])
		elseif window==9
			set(gcf,'windowbuttondownfcn',...
				['iduiarx(''down'');'])
		elseif window==10
			set(gcf,'windowbuttondownfcn',...
				['iduiss(''down'');'])
		end
	end
elseif strcmp(flag,'def')
	
	type=get(gcf,'Selectiontype');
	if strcmp(type,'extend')
		if any(window==[1 2 3 4 5 6 7 13])
			iduimbcb('infobox',window)
		elseif window==9
			iduiarx('down');
		elseif window==10
			iduiss('down');
		elseif window==14
			iduisel('down');
		elseif window==15
			iduifilt('down');
		end
	else
		if window==3
			pos=get(gcf,'pos');
			posxy=get(gcf,'currentpoint');
			if posxy(1)>0.7*pos(3),return,end % This means that we have clicked
			%  in the 'fits' region
		end
		
		set(gcf,'windowbuttonmotionfcn','')
		%iduistat('Zoom activated',0,window)
		zoom('down')
		% The following is due to the unreliability of 'gca':
		axhand=get(gcf,'userdata');axhand=idnonzer(axhand(3:length(axhand)));
		if length(axhand)>1
			if strcmp(get(axhand(2),'vis'),'on')
				pos=get(gcf,'pos');
				x=get(gcf,'currentpoint');
				if x(2)>0.5*pos(4),
					curax=axhand(1);altax=axhand(2);
				else
					curax=axhand(2);altax=axhand(1);
				end
				set(altax,'xlim',get(curax,'xlim'))
			end % strcmp
		end  % if length ...
		%iduistat('',0,window);
		if window==3
			set(XID.plotw(3,1),'windowbuttonmotionfcn','iduimbcb(''resize'');')
		end
	end
	
elseif strcmp(flag,'infobox')
	h=findobj(get(gcf,'children'),'flat','tag','infobox');
	pos=get(h,'pos');posp=get(gcf,'currentpoint');
	posf=get(gcf,'pos'); posf=posf(3:4);
	if posp(1)>posf(1)/2,pos1(1)=posp(1)-pos(3);else pos1(1)=posp(1);end
	if posp(2)>posf(2)/2,pos1(2)=posp(2)-pos(4);else pos1(2)=posp(2);end
	pos=[pos1,pos(3:4)];
	pt=get(gca,'currentpoint');
	lineobj=get(gcf,'currentobject');
	if strcmp(get(lineobj,'tag'),'fits'),return,end
	nam_no=get(lineobj,'userdata');name=[];yval=[];xval=[];
	if length(nam_no)==1
		name=get(nam_no,'string');
		name=[' ',name];
		xdat=get(lineobj,'xdata');ydat=get(lineobj,'ydata');
		nr=find(xdat>pt(1,1));
		if ~isempty(nr)
			nr=nr(1);
			if nr>1,
				xval=num2str(pt(1,1));
				yval=num2str(ydat(nr-1)+(ydat(nr)-ydat(nr-1))*...
					(pt(1,1)-xdat(nr-1))/(xdat(nr)-xdat(nr-1)));
			end
		end
	end
	set(h,'string',str2mat(name,[' x=',xval],...
		[' y=',yval]),'pos',pos,'vis','on');
	swind=int2str(window);
	set(gcf,'windowbuttonupfcn',['iduimbcb(''nobox'',',swind,');']);
	
elseif strcmp(flag,'nobox')
	h=findobj(get(gcf,'children'),'flat','tag','infobox');
	set(h,'vis','off')
	set(gcf,'windowbuttonupfcn','');
	set(gcf,'windowbuttonmotionfcn','');
elseif strcmp(flag,'resize')
	pos=get(XID.plotw(3,1),'pos');
	usd=get(XID.plotw(3,1),'userdata');
	if usd(1,1)~=pos(4)
		iduipoin(1);
		usd(1,1)=pos(4);
		set(XID.plotw(3,1),'userdata',usd);
		idgenfig(0,3);
		iduipoin(2);
	end
	
elseif strcmp(flag,'reset_zoom')
	usd=get(XID.plotw(window,1),'userdata');[rusd,cusd]=size(usd);
	xax=usd(3:rusd,1);
	try
		set(get(xax(1),'zlabel'),'user',[])
	end
	try
		set(get(xax(2),'zlabel'),'user',[])
	end
end
