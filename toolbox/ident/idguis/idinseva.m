function idinseva(ax1,tag2,silent)
%IDINSEVA Inserts the working or validation data set.
%   The data information in ax1 is placed as working data
%   (tag2='seles') or validation data (tag2='selva');
%   if silent==1, no status messages are displayed

%   L. Ljung 9-27-94
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.20.4.2 $ $Date: 2004/04/10 23:19:24 $

oo = get(0,'Showhiddenhandles');
set(0,'Showhiddenhandles','on')
Xsum = findobj(get(0,'children'),'flat','tag','sitb16');
set(0,'Showhiddenhandles',oo);
XID = get(Xsum,'Userdata');

if nargin<3,silent=0;end
if strcmp(tag2,'seles'), %estimation data
    ax2=XID.hw(3,1);
else 
    ax2=XID.hw(4,1);
end
oldusd = get(ax2,'userdata');
par1=get(ax1,'parent');par2=get(ax2,'parent');
tag1=get(ax1,'tag');
oldtag=get(get(ax2,'zlabel'),'userdata');
if strcmp(tag1,oldtag)
    if strcmp(tag2,'seles')
        dtype='Working ';
    else
        dtype='Validation ';
    end
    iduistat([dtype,'data unchanged. No update necassary.'])
    return
end
pos2=get(ax2,'pos');pos1=get(ax1,'pos');
usd2=get(ax2,'userdata');
if isempty(usd2),
    usd2.ny = 0;usd2.nu=0;
end
hnrstring2=findobj(ax2,'type','text','tag','name');
hnrline2=findobj(ax2,'tag','selline');
hnrstring1=findobj(ax1,'type','text','tag','name');
hnrline1=findobj(ax1,'tag','dataline');
set(get(ax2,'zlabel'),'userdata',tag1); % Tagging the working/validation
% data with a name tag
set(hnrstring2,'string',get(hnrstring1,'string'),'userdata',...
    get(hnrstring1,'userdata'),'vis','on')
data = get(hnrline1,'userdata');
data_n = pvget(data,'Name');
set(hnrline2,'xdata',get(hnrline1,'xdata'),...
    'ydata',get(hnrline1,'ydata'),'vis','on',...
    'userdata',data);
set(ax2,'color',get(ax1,'color'));
[N,ny,nu]=sizedat(data);
newusd.ny = ny;
newusd.nu = nu;
dom = 't';
if isa(data,'idfrd')
    dom = 'f';
elseif strcmp(pvget(data,'Domain'),'Frequency')
    dom = 'f';
end
ts = pvget(data,'Ts');
if iscell(ts),ts = ts{1};end
if ts>0,ts=1;end % only flags CT/DT
newusd.ts = ts;
newusd.dom = dom;
newusd.ynames = pvget(data,'OutputName');
newusd.unames = pvget(data,'InputName');
uynames ={};
for kkk = 1:length(newusd.unames)
    uynames{kkk} = newusd.ynames;
end

newusd.uynames = uynames;
set(ax2,'xlim',get(ax1,'xlim'),...
    'ylim',get(ax1,'ylim'),'userdata',newusd);
newax=0;
if strcmp(tag2(1:5),'selva')
    Plotcolors=idlayout('plotcol');
    textcolor=Plotcolors(6,:);
    set(hnrline2,'color',textcolor);
    if iduiwok(3)
        hpred=findobj(XID.plotw(3,1),'tag','predict');
        hsim=findobj(XID.plotw(3,1),'tag','simul');
        if nu==0,
            if strcmp(get(hsim,'checked'),'on')
                idopttog('check',hpred,0);
            end
            set(hsim,'enable','off');
        else
            set(hsim,'enable','on');
        end
    end
    sampp=get(XID.plotw(3,2),'userdata');
    sampp=str2mat(sampp(1,:),sampp(2,:),'[]',sampp(4,:));
    set(XID.plotw(3,2),'userdata',sampp);
    if dom=='f'&nu==0
        iduiiono('set',newusd,6);
    else
    iduiiono('set',newusd,[3 6]);
end
    iduiexp('set',3);%%LL
    if dom=='f'&nu==0
         set(XID.plotw(3,2),'enable','off','value',0)
     else
         [lla,llb] =fiactham;
         if ~(isempty(lla)&isempty(llb))
          set(XID.plotw(3,2),'enable','on') % this should really not happen if there are no models
          
      end
  end
    if ishandle(XID.plotw(3,1))
        if dom~=usd2.dom
            pos = get(XID.plotw(3,1),'pos');
            vis = get(XID.plotw(3,1),'vis');
            close(XID.plotw(3,1))
            if ~(dom=='f'&nu==0)
            idbuildw(3);
            XID = get(Xsum,'Userdata');
            
            set(XID.plotw(3,1),'pos',pos);
           
            set(XID.plotw(3,1),'vis',vis);
        else
            vis = 'off';
            warndlg('No Model Output View for frequency domain data with no input.',...
                'Warning','modal');
            %set(XID.plotw(3,2),'enable','off')
        end
            if strcmp(vis,'on')
                set(XID.plotw(3,2),'value',1);
                iduimod(3,fiactham);
            end
        else
            iduiclpw(3);
        end
    end
    %    iduiclpw(3);
    iduiclpw(6);
    if ~silent
        iduistat(['Validation data changed to ',data_n,'.'])
    end
else %estimation data
    poph = findobj(get(Xsum,'children'),'flat','tag','sitbpreppop');
    popusd = XID.pop;pop1=popusd{1};
    if dom=='t'
        pop1{8}='Filter...';
    else
        pop1{8}='Select range...';
    end
    [N,ny,nu]=sizedat(data);
    set(hnrline2,'color',get(hnrline1,'color'));
    if isa(data,'idfrd')
        nrp = [1,2,8,10];
        pop1 = pop1(nrp);
        dtyp = 'ff';
    elseif strcmp(pvget(data,'Domain'),'Frequency')
        nrp = [1,2,3,4,8,10];
        pop1 = pop1(nrp);
        dtyp = 'fd';
    else
      %  if nu>0
        nrp = [1:11];
        %else
        %nrp = [1:9,11];
        %end
    pop1 = pop1(nrp);
        dtyp = 'ti';
    end
    popusd{2}=nrp;
    set(poph,'string',pop1); XID.pop=popusd;
    set(Xsum,'userdata',XID);
    ll1=iduiwok(35);
    if ishandle(ll1)
        if dtyp=='ff'
            close(ll1)
        else
            if strcmp(get(ll1,'vis'),'on')
                iduisel('revert_exp');
            end
        end
    end
    
    ll1=iduiwok(36);
    if ishandle(ll1)
        if dtyp=='ff'
            close(ll1)
        else
            if strcmp(get(ll1,'vis'),'on')
                iduiexp('merge');
            end
        end
    end
    
    ll1=iduiwok(28);if ishandle(ll1),if strcmp(get(ll1,'vis'),'on')
            iduisel('revert_io');
        end,end
    ll1=iduiwok(41);
    if ishandle(ll1),
        if dtyp=='ff'|dtyp=='fd'
            close(ll1)
        else
            if strcmp(get(ll1,'vis'),'on')
                iduisel('revert_dec');
            end,
        end
    end
    ll1=iduiwok(14);
    if ishandle(ll1),
        if dtyp=='ti'
            if strcmp(get(ll1,'vis'),'on')
                iduisel('open_portions');
            end
        else
            close(ll1)
        end
    end
    ll1=iduiwok(15);
    if ishandle(ll1),
        if dom~=usd2.dom, 
            vs = get(ll1,'vis');
            pos = get(ll1,'pos');
            close(ll1),
            if strcmp(vs,'on')
                iduifilt('open')
                ll1 = iduiwok(15);
                set(ll1,'pos',pos);
            end
            
        else
            
            if strcmp(get(ll1,'vis'),'on')
                iduifilt('open');
            end,
        end
    end
    ll1=iduiwok(39);if ishandle(ll1),if strcmp(get(ll1,'vis'),'on')
            iduitrf('open');
        end,end
   
    if nu~=usd2.nu|ny~=usd2.ny|dom~=usd2.dom|usd2.ts~=ts
        ll1=iduiwok(20);
        if ishandle(ll1),
            if strcmp(get(ll1,'vis'),'on')
                idparest('open');
            end,
        end
        ll1=iduiwok(37);
        if ishandle(ll1),
            %if strcmp(get(ll1,'vis'),'on')
            vv = get(ll1,'vis');
            close(ll1)
            idprocest('open');
            ll1 = iduiwok(37);
            set(ll1,'vis',vv);
            %end,
        end
    else
        if nu>0,
            if ~allstr(newusd.unames,usd2.unames)|~allstr(newusd.ynames,usd2.ynames)
                ll1=iduiwok(21);
                if ishandle(ll1),
                    if strcmp(get(ll1,'vis'),'on')
                        iduiio('open');
                    end,
                end
            end
        else
            if ~allstr(newusd.ynames,usd2.ynames)
                ll1=iduiwok(21);
                if ishandle(ll1),
                    if strcmp(get(ll1,'vis'),'on')
                        iduiio('open');
                    end,
                end
            end
        end
        
    end
    if ~silent
        iduistat(['Working data changed to ',data_n '.'])
    end
end

function ok = allstr(str1,str2)
ok = 1;
if length(str1)~=length(str2)
    ok = 0;
    return
end
for k = 1:length(str1)
    if ~any(strcmp(str1{k},str2))
        ok = 0;
        break
    end
end
