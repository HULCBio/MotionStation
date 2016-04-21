function handlenr=iduiinsm(Model,active,axinfo,import)
%IDUIINSM Handles the insertion of models into the Model Summary Board
%      Model:      The actual model, in theta-format or CRA or SPA model
%      model_info: The associated model information
%      model_name: The name (a string) of the model.
%      active:     If active==1 then the model should become active immediately
%      HANDLENR:   The handle number of the model pushbutton

%   L. Ljung 4-4-94
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.21.4.3 $ $Date: 2004/04/10 23:19:44 $

sstat = get(0,'showhiddenhandles');
set(0,'showhiddenhandles','on')
Xsum = findobj(get(0,'children'),'flat','tag','sitb16');
set(0,'showhiddenhandles',sstat)
XID = get(Xsum,'Userdata');
XID.counters(5)=1; 
set(Xsum,'UserData',XID);

if isempty(Model),peflag=1;else peflag=0;end
if peflag
    mess=[...
            'There were numerical problems to compute the model.',...
            '\nThe model order might have been too high, or the input',...
            ' signal is not persistently exciting.',...
            ' Use other input or lower model orders.',...
            '\nNo model inserted.'];
    warndlg(mess);
    return
end
if nargin <4
    import = 0;
end

if nargin < 2,active=1;end
if active,iduistat('Model being inserted ...');end
if nargin<3
    axinfo =[];
end

if isempty(axinfo)
    [axh,texh,linh]=idnextw('model');
else
    [axh,texh,linh]=idnextw('model',axinfo(1),axinfo(2:5),axinfo(6:8));
    if isempty(linh),   [axh,texh,linh]=idnextw('model');end
end
XID = get(Xsum,'UserData');
tag=get(axh,'tag');
try
    set(XID.parest(3),'userdata',tag); %this will link the estimated model to ''by initial model''
end
modnr=eval(tag(6:length(tag)));
theta_model=1;

if import  
    chanupd(Model)
    XID = get(Xsum,'UserData');
end
switch class(Model)
    case 'idfrd'
        [ny,nu]=size(Model);
        if nu>0
            set(XID.plotw([2,7],2),'enable','on')
        else
            set(XID.plotw(7,2),'enable','on')
        end
        mmp=Model;
        lpl = pvget(mmp,'ResponseData');
        if isempty(lpl)
            lpl = pvget(mmp,'SpectrumData');
        end
        lpl = abs(squeeze(lpl(1,1,:)));
        if any(isnan(lpl))
            warndlg(char({'There were numerical difficulties in calculating the frequency',...
                    'response. Probably the resolution parameter was too large,'}))
            return
        end
        Model_name = pvget(Model,'Name');
    otherwise
        %if strcmp(get(XID.plotw(3,2),'enable'),'off')
        set(XID.plotw(4:7,2),'enable','on')
        %end
        [ny,nu] = size(Model);
        if nu >0
            set(XID.plotw([2,3],2),'enable','on')
        else
            dv = iduigetd('v','me');
            dom = lower(pvget(dv,'Domain'));
            if strcmp(dom,'time')
                set(XID.plotw(3,2),'enable','on')
            end
        end
        if isa(Model,'idmodel')&~(isaimp(Model)|isa(Model,'idpoly'))
            try
            setcov(Model); % to do these calc once and for all
        end
        end
        Model_name = pvget(Model,'Name');
        pars  = pvget(Model,'ParameterVector');
        peflag=any(isnan(pars))|any(isinf(pars));
        if peflag
            mess=str2mat(...
                'WARNING: There were numerical problems to compute the model.',...
                '      The model order might have been too high, or the input',...
                '      signal is not persistently exciting.',...
                '      Use other input or lower model orders.',...
                '      No model inserted.');
            warndlg(mess);
            return
        end
        Ts = pvget(Model,'Ts');
        if Ts==0
            ut = pvget(Model,'Utility');
            try
                Td = ut.Tsdata;
            catch
                try
                    es = pvget(Model,'EstimationInfo');
                    Td = es.DataTs;
                catch
                    Td = [];
                end
                if isempty(Td), [dum,Td] = iddeft(Model);end
                ut.Tsdata = Td;
                Model = pvset(Model,'Utility',ut);
            end
        end
        if isaimp(Model)
            lpl = pvget(Model,'B');
            lpl = squeeze(lpl(1,1,:));
            llpl = length(lpl);
            if llpl>35
                lpl = lpl(11:35);
            else
                lpl = lpl;
            end
        else
            was = warning;
            warning('off')
            lpl=sim(Model,[[1;zeros(24,1)],zeros(25,max(nu+ny-1,0))],[],1);
            warning(was)
        end
        
end
if ~isreal(lpl),
    lpl=abs(lpl);
end
lpl=lpl(:,1);
set(axh,'vis','off')
set(linh,'UserData',Model,'tag','modelline')
set(texh,'String',Model_name,'vis','on')
handlenr=axh;
%set(texh,'UserData',model_info)

set(linh,'xdata',1:length(lpl),'ydata',lpl,'vis','off');
Plotcolors=idlayout('plotcol');
axescolor=Plotcolors(4,:);

ylim = [2*min(lpl)-max(lpl) max(lpl)];
if ylim(1)>=ylim(2),
    ylim = [ylim(1)-1 ylim(2)+1];
end
try
    set(axh,'ylim',ylim,'xlim',[0 length(lpl)],...
        'color',axescolor);
catch
    errordlg('Failed to insert model.','Error Dialog','modal');
    set(axh,'vis','on')
    set(linh,'UserData',Model,'tag','')
    set(texh,'String','','vis','on')
    return
end
if active,
    set(linh,'linewidth',3);
end   
set(linh,'vis','on')
set(axh,'vis','on')

if active,
    Figno=fiactha(XID.plotw(2:7,2))+1;
    iduimod(Figno,modnr,[])
    set(XID.sbmen([3 5]),'enable','on')
    if strcmp(get(XID.sbmen(1),'tag'),'open')
        [label,acc]=menulabel('&Merge session... ^o');
        set(XID.sbmen(1),'label',label,'tag','merge');
    end
    iduistat(['Model ',Model_name,' inserted.',...
            '  Double click on icon (right mouse) for text information.'])
    
end
