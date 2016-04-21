function iduital(window,cb)
%IDUITAL Callback for 'Title and Labels' menu item.
%   Toggles title off and on.

%   L. Ljung 9-27-94
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.16.4.1 $  $Date: 2004/04/10 23:20:00 $

Xsum = findobj(get(0,'children'),'flat','tag','sitb16');
XID = get(Xsum,'Userdata');

if nargin<2,cb='set';end
hax1=findobj(get(XID.plotw(window,1),'children'),'flat',...
    'tag','axis1','vis','on');
t1=get(hax1,'title');x1=get(hax1,'xlabel');y1=get(hax1,'ylabel');
hax2=findobj(get(XID.plotw(window,1),'children'),'flat',...
    'tag','axis2','vis','on');
if ~isempty(hax2)
    t2=get(hax2,'title');x2=get(hax2,'xlabel');y2=get(hax2,'ylabel');
else
    t2=[];x2=[];y2=[];
end
chns=get(XID.plotw(window,3),'userdata');
if iscell(chns);
    chns = chns{1};
end


if strcmp(cb,'tog')
    men=gcbo;%get(gcf,'Currentmenu');
    onoff=get(men,'checked');
    if strcmp(onoff,'off')
        set(men,'checked','on')
        set([t1,t2,x1,x2,y1,y2],'vis','on')
    else
        set(men,'checked','off')
        set([t1,t2,x1,x2,y1,y2],'vis','off')
    end
    
else
    
    if any(window==[1,14])
        set(y1,'string',[chns{1}]);
        set(t1,'string','Input and output signals');
        if  ~isempty(hax2),
            set(y2,'string',[chns{2}]);
            set(x2,'string','Time');
            set(x1,'string','     ');
        else
            set(x1,'string','Time');
        end
        
    elseif window==2
        usd=get(XID.plotw(2,2),'userdata');
        if eval(usd(3,:))==1,
            xtext=['Frequency (rad/s)'];
        else
            xtext=['Frequency (Hz)'];
        end
        set(t1,'string',['Frequency response']);
        set(y1,'string',['Amplitude']);
        set(x2,'string',xtext);
        set(t2,'string','')
        set(y2,'string','Phase (deg)')
        
    elseif window==3
        vdat = iduigetd('v');
        if isa(vdat,'idfrd')
            frdflag = 1;
            dom = 'f';
        else
            dom = pvget(vdat,'Domain');
            dom = lower(dom(1));
            frdflag = 0;
        end
        
        usd=get(XID.plotw(3,2),'userdata');
        predh=deblank(usd(1,:));if strcmp(predh,'[]'),predh=int2str(5);end
        if frdflag
            tt = ['Frequency Functions'];
        elseif dom=='f'
            tt = ['Measured and simulated model outputs (abs values)'];
        else
            if eval(usd(4,:))==0
                if eval(usd(2,:))==2
                    tt=['Measured and ',predh,' step predicted output'];
                else
                    tt=['Measured and simulated model output'];
                end
            else
                if eval(usd(2,:))==2
                    tt=['Measured minus ',predh,' step predicted output'];
                else
                    tt=['Measured minus simulated model output'];
                end
            end
        end
        set(t1,'string',tt);
        if dom=='f'
            
            hand = XID.plotw(3,1);
            un = 'rad/s';
            try
                hzh = findobj(hand,'tag','hz');
                if strcmp(get(hzh,'checked'),'on')
                    un = 'Hz';
                else
                    un = 'rad/s';
                end
            end
            
            fr = ['Frequency (',un,')'];
            set(x1,'string',fr);
        else
            set(x1,'string','Time');
        end
    elseif window==4
        set(t1,'string','Poles (x) and Zeros (o)')
        
    elseif window==5
        usd=get(XID.plotw(5,2),'userdata');
        if eval(usd(3,:))==1
            tt='Step Response';
        else
            tt='Impulse Response';
        end
        set(t1,'string',tt);
        set(x1,'string','Time');
    elseif window==6
        vdat = iduigetd('v','me');
        dom = pvget(vdat,'Domain'); dom=lower(dom(1));
        if dom=='t'
            set(t1,'string',...
                ['Autocorrelation of residuals for output ',chns{1}]);
        else
            set(t1,'string', ['Power spectrum of residuals at output ',chns{1}]);
        end
        if ~isempty(hax2)
            if dom=='t'
                set(t2,'string',...
                    ['Cross corr for input ',chns{2},...
                        ' and output ',chns{1},' resids']);
                set(x2,'string','Samples')
                set(x1,'string','        ')
            else set(t2,'string',['Transfer function from input ',chns{2},...
                        ' to residuals at output ',chns{1}]);
                set(x2,'string','Frequency (rad/s)')     
                set(x1,'string','        ')
            end
        else
            if dom=='t'
                set(x1,'string','Samples')
            else
                set(x1,'string','Frequency (rad/s)')
            end
        end
        elseif window==7
            usd=get(XID.plotw(7,2),'userdata');
            if eval(usd(3,:))==1,
                xtext=['Frequency (rad/s)'];
            else
                xtext=['Frequency (Hz)'];
            end
            set(t1,'string',['Power Spectrum']);
            set(x1,'string',xtext);
            
        elseif any(window==[13,15])
            usd=get(XID.plotw(window,2),'userdata');
            if eval(usd(5,:))==2
                met='Periodogram';
            else
                met='Spectrum estimate';
            end
            if eval(usd(3,:))==1,
                xtext=['Frequency (rad/s)'];
            else
                xtext=['Frequency (Hz)'];
            end
            set(t1,'string',[met]);
            set(y1,'string',[chns{1}]);
            if  ~isempty(hax2),
                set(y2,'string',[chns{2}]);
                set(x2,'string',xtext);
                set(x1,'string','           ');
            else
                set(x1,'string',xtext);
            end
        elseif window==9
            set(t1,'string','Model Misfit vs number of par''s');
            set(x1,'string','Number of par''s')
            set(y1,'string','Unexplained output variance (in %)')
        end
    end
