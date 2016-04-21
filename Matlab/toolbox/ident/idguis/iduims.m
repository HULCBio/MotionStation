function iduims(arg,Mtype,nu,ny,clean)
%IDUIMS Enables the right popups in the Orders Editor dialog.
%   Also sets the correct text in the Parametric Estimation dialog.

%   L. Ljung 9-27-94
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.12.4.1 $  $Date: 2004/04/10 23:19:50 $

%global XIDparest XIDio  XIDmse XIDss XIDarx
Xsum = findobj(get(0,'children'),'flat','tag','sitb16');
XID = get(Xsum,'Userdata');
if nargin<5
    clean = 1;
end
e=iduigetd('e');ts=pvget(e,'Ts');if iscell(ts),ts=ts{1};end
mse=0;oldMtype=0;
ll1=iduiwok(21);if ishandle(ll1),if strcmp(get(ll1,'vis'),'on')
        mse=1;
    end,end

if nu>4|ny>1,nmu=min(1,nu);else nmu=nu;end
if mse,
    oldMtype=get(XID.parest(15),'userdata');
    if Mtype~=6,set(XID.parest(15),'userdata',Mtype);end
end
if strcmp(arg,'both')
    h=XID.parest(4);f=[' ',int2str(4)];t=[' ',int2str(2)];o=[' ',int2str(1)];
    if nu>1
        fu=[' [',int2str(4)];ou=[' [',int2str(1)];tu=[' [',int2str(2)];
        for ku=1:nu-1
            fu=[fu,f];tu=[tu,t];ou=[ou,o];
        end
        fu=[fu,']'];tu=[tu,']'];ou=[ou,']'];
    else
        fu=f;ou=o;tu=t;
    end
    if Mtype==1
        cb=['goto_ws=iduiarx(''estimate'');',...
                'if goto_ws,XIDarg=''arx'';idgtws;end'];
        set([XID.ss(1,[2,5]),XID.parest(11)],'vis','off')
        set(XID.arx(1,[2,5]),'vis','on');
    elseif Mtype==5
        cb=['goto_ws=iduiss(''estimate'');',...
                'if goto_ws,XIDarg=''ss'';idgtws;end'];
        
        set([XID.arx(1,[2,5]),XID.parest(11)],'vis','off');
        set(XID.ss(1,[2,5]),'vis','on')
    else
        cb=['goto_ws=iduiio(''estimate'');',...
                'if goto_ws,XIDarg=''io'';idgtws;end'];
        set([XID.arx(1,[2,5]),XID.ss(1,[2,5])],'vis','off');
        set(XID.parest(11),'vis','on')
    end
    set(XID.parest(2),'callback',['iduipoin(1);iduistat(''Compiling ... '');',...
            cb,',iduipoin(2);']);
    
    % Now we shall set the default orders in the 'chosen model structure' box
    % First check if the MSE is open, and if so read its values
    if Mtype==1
        if nu==0,
            str='Ay=e';
            if ny==1
                sm=f;
            else
                sm=['4*ones(',int2str(ny),',',int2str(ny),')'];
            end
        else
            str='Ay=Bu+e';
            if ny==1
                if ts==0
                    sm=[f,fu];
                else
                    sm=[f,fu,ou];
                end
                if mse,if any(oldMtype==[3 4])
                        nav=0;
                        for ku=1:nmu
                            nav=nav+get(XID.io(ku,2),'value');
                        end
                        set(XID.io(1,4),'value',min(max(1,nav),9));
                    end,end
            else
                sm=['[2*ones(',int2str(ny),',',int2str(ny),'), 2*ones(',...
                        int2str(ny),',',int2str(nu),'), ones(',int2str(ny),',',...
                        int2str(nu),')]'];
            end
        end
        
    elseif Mtype==2
        if nu==0
            str='Ay=Ce';  sm=[f,f];
            if mse,if oldMtype==1,set(XID.io(1,5),'value',2);end,end
        else
            str='Ay=Bu+Ce'; sm=[t,tu,t,ou];
            if mse,if any(oldMtype==[1,3]),set(XID.io(1,5),'value',2);end
                if any(oldMtype==[3,4])
                    nav=0;
                    for ku=1:nmu
                        nav=nav+get(XID.io(ku,2),'value');
                    end
                    set(XID.io(1,4),'value',min(max(nav,1),9));
                end
            end
        end
    elseif Mtype==3
        str='y=[B/F]u+e'; 
        if ts >0
            sm=[tu,tu,ou];
        else
            sm =[tu,tu];
        end
        if mse,if any(oldMtype==[1 2 5 6])
                set(XID.io(1:nmu,2),'value',...
                    min(max(get(XID.io(1,4),'value'),1),9))
            end,end
        
    elseif Mtype==4
        if mse,if any(oldMtype==[1 2 5 6])
                set(XID.io(1:nmu,2),'value',...
                    min(max(get(XID.io(1,4),'value'),1),9))
            end,
            if any(oldMtype==[1,3])
                set(XID.io(1,5),'value',2);
            end
            if any(oldMtype==[1,2,3,5,6])
                set(XID.io(1,6),'value',2);
            end
        end
        str='y=[B/F]u+[C/D]e';  sm=[tu,t,t,tu,ou];
    elseif Mtype==5
        if nu==0,
            str='xnew=Ax+Ke; y=Cx+e';   sm=f;
        else
            str='xnew=Ax+Bu+Ke; y=Cx+Du+e';  sm=f;
        end
        if mse,if any(oldMtype==[3 4])
                nav=0;
                for ku=1:nmu
                    nav=nav+get(XID.io(ku,2),'value');
                end
                set(XID.io(1,4),'value',min(max(2,nav),9));
            end,end
        
    elseif Mtype==6
        str='Defined by initial model';
    end
    
    set(XID.parest(10),'string',str);
    if mse
        set(XID.parest(15),'string',str);
    end
    if Mtype==6,
        if clean,set(XID.parest(3),'string','');end
        set(XID.parest(16),'string','Initial model:');
    else
        set(XID.parest(16),'string','Orders:');
    end
    if Mtype~=6&~mse,set(XID.parest(3),'str',sm);end
    set(Xsum,'UserData',XID);
    
    if mse,idparest('orders');end
    if mse==0,return,end
end % if arg=='both'

%  Now follows operations on the model structure editor
if strcmp(arg,'both')|strcmp(arg,'setpop')
    
    if Mtype==5
        set(XID.parest(12),'string','Model order');
        set([XID.ss(1,7),XID.ss([2 3],[7])'],'vis','on');
        set([XID.ss(1,6)],'vis','off');
        
        if nu>0,
            set(XID.io(1:nmu+1,[1 2 7]),'vis','off');
            if ts>0
                set(XID.io(1:nmu+1,3),'vis','off');
            end
            set(XID.ss([1,2],8),'vis','on');
            %set(XID.ss(1,6),'vis','on')
        else
            %set(XID.ss(1,6),'value',2,'enable','off');
        end
        
        set(XID.io(1,[5,6]),'vis','off');
    else
        set([XID.ss(1,6)],'vis','on');
        
        set(XID.parest(12),'string','Common poles:');
        set([XID.ss(1,[7]),XID.ss([2 3],[7])'],'vis','off');
        if nu>0,
            set(XID.io(1:nmu+1,[1 2 7]),'vis','on');
            if ts>0
                set(XID.io(1:nmu+1,3),'vis','on');
            end
            set(XID.ss([1,2],8),'vis','off');
        end
        set(XID.io(1,[5,6]),'vis','on');
    end
    
    strflag=0;
    if Mtype==1
        if ny==1
            hlp1='''iduiarx.hlp''';hlp2='''Help: The ARX Structure''';
        else
            hlp1='''mvarx.hlp''';hlp2='''Help: The Multivariable ARX Structure''';
        end
        if oldMtype~=1
            if ny==1
                nas='na=0|na=1|na=2|na=3|na=4|na=5|na=6|na=7|na=8|na=9|na>9|1:5|1:10';
                nbs='nb=0|nb=1|nb=2|nb=3|nb=4|nb=5|nb=6|nb=7|nb=8|nb=9|nb>9|1:5|1:10';
                nks='nk=0|nk=1|nk=2|nk=3|nk=4|nk=5|nk=6|nk=7|nk=8|nk=9|nk>9|1:5|1:10';
            else
                nas='na=0|na=1|na=2|na=3|na=4|na=5|na=6|na=7|na=8|na=9|na>9';
                nbs='nb=0|nb=1|nb=2|nb=3|nb=4|nb=5|nb=6|nb=7|nb=8|nb=9|nb>9';
                nks='nk=0|nk=1|nk=2|nk=3|nk=4|nk=5|nk=6|nk=7|nk=8|nk=9|nk>9';
            end
            strflag=1;
        end
    elseif any(Mtype==[2 3 4])
        hlp1='''iduiio.hlp''';hlp2='''Help: The ARMAX, OE and BJ Structures''';
        if ~any(oldMtype==[2 3 4])
            nas='na=0|na=1|na=2|na=3|na=4|na=5|na=6|na=7|na=8|na=9|na>9';
            nbs='nb=0|nb=1|nb=2|nb=3|nb=4|nb=5|nb=6|nb=7|nb=8|nb=9|nb>9';
            nks='nk=0|nk=1|nk=2|nk=3|nk=4|nk=5|nk=6|nk=7|nk=8|nk=9|nk>9';
            strflag=1;
        end
    elseif Mtype==5
        hlp1='''iduiss.hlp''';hlp2='''Help: The State-Space Structure''';
        if ~any(oldMtype==5)
            nas='n=0|n=1|n=2|n=3|n=4|n=5|n=6|n=7|n=8|n=9|n>9|1:5|1:10';
            strflag=1;
        end
    elseif Mtype==6
        hlp1='''iduibn.hlp''';hlp2='''Help: Defining Model Structures By Initial Model''';
    end
    hh=findobj(XID.mse(2),'string','Help');
    set(hh,'callback',['iduihelp(',setstr(hlp1),',',setstr(hlp2),');']);
    if strflag
        set(XID.io(1,4),'string',nas);
        if any(Mtype==[1 2 3 4])
            set(XID.io(1:nmu,1),'string',nbs);
            if ts>0,set(XID.io(1:nmu,3),'string',nks);end
        end
    end
    controls=[];conon=[];
    if any(Mtype==[1 2 6])      %nf
        controls=[controls;XID.io(1:nmu,2)];
    else
        conon=[conon;XID.io(1:nmu,2)];
    end
    if any(Mtype==[3 4 6]) % na
        controls=[controls;XID.io(1,4)];
    else
        conon=[conon;XID.io(1,4)];
    end
    if any(Mtype==[6])    % nb
        controls=[controls;XID.io(1:nmu,1)];
    else
        conon=[conon;XID.io(1:nmu,1)];
    end
    if any(Mtype==[1 3 6])  % nc
        controls=[controls;XID.io(1,5)];
    else
        conon=[conon;XID.io(1,5)];
    end
    if any(Mtype==[1 2 3 6])
        controls=[controls;XID.io(1,6)];  % nd
    else
        conon=[conon;XID.io(1,6)];
    end
    if nu==0|(any(Mtype==[6]))
        controls=[controls;XID.io(1:nmu,3)];
    elseif ts>0
        conon=[conon;XID.io(1:nmu,3)];
    end
    set(controls,'enable','off');
    if Mtype~=6,set(controls,'value',1);end
    set(conon,'enable','on')
end % end if both/setpop
