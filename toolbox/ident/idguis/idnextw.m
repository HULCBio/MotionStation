function [axh,texh,linh]=idnextw(type,sbnr,pos,col)
%IDNEXTW Finds the next available data or model axes.

%   L. Ljung 9-27-94
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.9 $ $Date: 2001/04/06 14:22:35 $

sstat = get(0,'showhiddenhandles');
set(0,'showhiddenhandles','on')
Xsum = findobj(get(0,'children'),'flat','tag','sitb16');
set(0,'showhiddenhandles',sstat)
XID = get(Xsum,'Userdata');

if strcmp(type,'data')
    tag='dataline0';
else
    tag='modelline0';
end

if nargin==4
	create=0;
	try
		if ~(strcmp(get(XID.sumb(sbnr),'tag'),'sitb30')...
				&get(XID.sumb(sbnr),'userdata')==sbnr)
			create=1;
		end
	catch
		create=1;
	end
	if create==1&sbnr>1,
		set(Xsum,'UserData',XID);
        iddmtab(sbnr); 
        XID = get(Xsum,'UserData');
    end
    axh=findobj(XID.sumb(sbnr),'type','axes','vis','on');%,'pos',pos);
    axh1 = [];
    for kk = 1:length(axh) 
        if norm(get(axh(kk),'pos')-pos)<1e-4
            axh1 = axh(kk);
            break
        end
    end
    axh = axh1;
    if isempty(axh)
        texh=[];linh=[];
    else
        texh=findobj(axh,'tag','name');
        linh=findobj(axh,'tag',tag,'type','line');
        set(linh,'color',col);
    end
else
    ks=1;
    stopp=0;
    while stopp==0
        create=0;
        if ks==1,tagwin='sitb16';else tagwin='sitb30';end
		try
        if ~strcmp(get(XID.sumb(ks),'tag'),tagwin)
			create=1;
		end
		catch
            create=1;
		end
        if create==1,iddmtab(ks);end
        XID = get(Xsum,'UserData');
        set(XID.sumb(ks),'vis','on')
        hn=findobj(XID.sumb(ks),'type','line','tag',tag);
        if ~isempty(hn),
            stopp=1;
            kk=1;
            for kh=hn'
                pos=get(get(kh,'parent'),'pos');
                ps(kk)=pos(2)*1000-pos(1);
                kk=kk+1;
            end
            [dum,index]=max(ps);
            linh=hn(index);
            axh=get(linh,'parent');
            texh=findobj(axh,'tag','name');
        end
        ks=ks+1;
    end
end
