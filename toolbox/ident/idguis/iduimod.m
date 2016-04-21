function iduimod(Figno,Kmod,CKmod)
%IDUIMOD Main manager of the plot windows.
%   Makes sure that the models/data with numbers Kmod are visible/plotted
%   (and CKmod invisible) in the windows with numbers Figno.

%   L. Ljung 4-4-94
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.9.4.1 $ $Date: 2004/04/10 23:19:49 $

 
Xsum = findobj(get(0,'children'),'flat','tag','sitb16');
XID = get(Xsum,'Userdata');
XIDplotw = XID.plotw;
 
iduistat('Showing desired curves ...')
if nargin==2, CKmod=[];end
for fig=Figno  % Generating the curves if they have not been computed
	% before
	if any(fig==[14,15]),iddatfig(Kmod,Figno);return,end
	if any(fig==[1,13,14,15,40]),isdata=1;else isdata=0;end
	if isempty(iduiwok(fig)) % Check that plot window is OK
		XIDplotw(fig,1)=idbuildw(fig);
	end
	Fighand=XIDplotw(fig,1);
	if ~isdata,   hsd=findobj(Fighand,'tag','confonoff');end
	fusd=get(Fighand,'userdata');[rfusd,cfusd]=size(fusd);
	axch=fusd(3:rfusd,1)';
	genall=0;
	try
		xusd=get(axch(1),'UserData');
	catch
		genall=1;xusd=[];
	end
	[rrusd,ccusd]=size(xusd);mkmod=max(2*Kmod+1);
	if rrusd<mkmod,xusd=[xusd;zeros(mkmod-rrusd,ccusd)];end
	try
		index=find(xusd(2*Kmod+1,1)==0);
	catch
		genall=1;
	end
	if genall
		genmod=Kmod;
	else
		if isempty(index),genmod=[];else genmod=Kmod(index);end
	end
	
	if ~isempty(genmod),
		if ~isdata
			idgenfig(genmod,fig)
		else
			iddatfig(genmod,fig)
		end
	end
	
	for kk=axch   % Setting the visibility status of the curves
		xusd=get(kk,'Userdata');
		if strcmp(get(kk,'visible'),'on')
			[rusd,cusd]=size(xusd);maxmod=max([CKmod Kmod]');
			if rusd<2*maxmod+2
				xusd(2*maxmod+2,1)=0;set(kk,'Userdata',xusd);
			end
			if ~isempty(Kmod),iduivis(xusd(2*Kmod+1,:),'on'),end
			if ~isempty(CKmod),iduivis(xusd(2*CKmod+1,:),'off'),end
			if ~isdata,
				if strcmp(get(hsd,'checked'),'on')
					if ~isempty(Kmod),iduivis(xusd(2*Kmod+2,:),'on'),end
					if any(any(xusd(2*Kmod+2,:)==-1))
						iduistat('No confidence region for this model.',0,fig)
					elseif any(any(xusd(2*Kmod+2,:)==-2))
						iduistat('No confidence region for ETFE models.',0,fig)
					end
					if ~isempty(CKmod),
						try
							iduivis(xusd(2*CKmod+2,:),'off')
						end
					end
				end,
			end
		end
	end
end

iduistat('')
