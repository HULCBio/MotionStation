function varargout = fdfirls(varargin)
%fdfirls  Firls - Least Squares Module for filtdes.

%   Author: T. Krauss
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.9.4.2 $

% Change this global to static when available:
%  following are common to several modules
global minOrdCheckbox bandpop order pbspecs sbspecs pbmeasures sbmeasures
global passframe stopframe passframe1 stopframe1
%  following static to fdfirls
global f1 f2 f3 f4 wt1 wt2 Rp Rs 
global Rpm Rsm wt1m wt2m
global order0 order1
global ax L1 L2 Lresp
global Fs

switch varargin{1}
case 'init'

    filt = varargin{2};
    Fs = filt.Fs;

    [setOrderFlag_init, type_init, f_init, Rp_init, Rs_init, ...
      order_init, wt_init] = initSpecs(filt);
        
    [minOrdCheckbox bandpop order pbspecs sbspecs ...
         pbmeasures sbmeasures passframe stopframe ...
         passframe1 stopframe1 ax Lresp L1 L2 order1 ...
         L3_1 L3_2] = fdutil('commonObjects');
    order0 = order;
    order = order1;
        
    if ~strcmp(bandpop.userdata,'fdfirls')
       % this module is not current
        bandpop.userdata = 'fdfirls';
            
        minOrdCheckbox.callback = 'fdfirls(''checkbox'')';
        
        bandpop.callback = 'fdfirls(''newtype'')';         
        set(pbspecs(1),'callback','fdfirls(''fchange'')','range',[0 Fs/2])
        set(pbspecs(2),'callback','fdfirls(''fchange'')','range',[0 Fs/2])
        set(sbspecs(1),'callback','fdfirls(''fchange'')','range',[0 Fs/2])
        set(sbspecs(2),'callback','fdfirls(''fchange'')','range',[0 Fs/2])

        f3 = pbspecs(2);
        f4 = sbspecs(2);
        Rp = pbspecs(3);
        Rs = sbspecs(3);
        
        Rpm = pbmeasures(1);
        set(Rpm,'label','Actual Rp','format','%1.4g','visible','on')
        Rsm = sbmeasures(1);
        set(Rsm,'label','Actual Rs','format','%1.4g','visible','on')
        wt1m = pbmeasures(2);
        wt2m = sbmeasures(2);
        set(wt1m,'label','Weight','format','%1.4g')
        set(wt2m,'label','Weight','format','%1.4g')
        
        fdutil('changeToText',[pbmeasures(1:2); sbmeasures(1:2)])

        set(ax,'title', xlate('Frequency Response'),'xlimbound',[0 Fs/2],...
              'xlim',[0 Fs/2],...
              'xlabel',xlate('Frequency'),...
              'ylabel',xlate('Magnitude (dB)'));
              
        sethelp
            
        co = get(0,'defaultaxescolororder');
        lo = get(0,'defaultaxeslinestyleorder');
        
        % response line needs to be at bottom of stacking order:
        set(Lresp,'buttondownfcn','fdfirls(''LrespDown'')')
                       
        set(L1,'buttondownfcn','fdfirls(''L1down'')',...
               'buttonupfcn','fdfirls(''L1up'')');
    
        set(L2,'buttondownfcn','fdfirls(''L2down'')',...
               'buttonupfcn','fdfirls(''L2up'')');
    end    
    
    set(minOrdCheckbox,'visible','on','enable','off','value',0)
    set(Rpm,'visible','on')
    set(Rsm,'visible','on')
    pbspecs(1).visible = 'on';
    pbspecs(3).visible = 'on';
    sbspecs(1).visible = 'on';
    sbspecs(3).visible = 'on';
    set(pbmeasures(3),'visible','off')
    set(sbmeasures(3),'visible','off')
    set(L3_1,'visible','off')
    set(L3_2,'visible','off')
    
    fdfirls('newfilt',setOrderFlag_init,type_init,f_init,Rp_init,...
               Rs_init,wt_init,order_init)
    
    [filt, errstr] = fdutil('callModuleApply',...
                               'fdfirls',filt,'');
    varargout{1} = filt;
    varargout{2} = errstr;

case 'apply'
    filt = varargin{2};
    msg = varargin{3};
    if strcmp(msg,'motion')
        Lresp.erasemode = 'xor';
    end
    
    setOrderFlag = 1;
    type = bandpop.value;
    
    % setup measurements:
    set(order1,'visible','off')
    set(wt1m,'visible','off')
    set(wt2m,'visible','off')
    
    % DESIGN FILTER!!!!
    n = order.value;
    switch type
    case 1   % lowpass
        f = [0 f1.value f2.value Fs/2]*2/Fs;
        m = [1 1 0 0];
        wt = [wt1.value wt2.value];
    case 2
        f = [0 f1.value f2.value Fs/2]*2/Fs;
        m = [0 0 1 1];
        wt = [wt2.value wt1.value];
    case 3
        f = [0 f1.value f2.value f3.value f4.value Fs/2]*2/Fs;
        m = [0 0 1 1 0 0];
        wt = [wt2.value wt1.value wt2.value];
    case 4
        f = [0 f1.value f2.value f3.value f4.value Fs/2]*2/Fs;
        m = [1 1 0 0 1 1];
        wt = [wt1.value wt2.value wt1.value];
    end
    if n>1000
        [continueFlag,errstr] = fdutil('largeWarning',n,msg);
        if ~continueFlag
            varargout{1} = filt;
            varargout{2} = errstr;
            return
        end
    end
    if ((type==2)|(type==4)) & rem(n,2)
        error('For highpass and bandstop filters, order must be even.')
    end
    b = firls(order.value,f,m,wt);
    a = 1;
    
    nfft = filtdes('nfft');
    [H,ff] = freqz(b,a,nfft,Fs);
    Hlog = 20*log10(abs(H));
    set(Lresp,'xdata',ff,'ydata',Hlog);

    [maxpass,minpass,minstop] = getMeasurements(ff,Hlog,bandpop.value,...
                                          f1.value,f2.value,f3.value,f4.value);
    Rpm.value = maxpass - minpass;
    Rsm.value = -minstop;
    ylim = [minpass maxpass];
    dyl = (ylim(2)-ylim(1))*.15;
    ax.ylimPassband = ylim + [-dyl/2 dyl/2];

    specstruc.setOrderFlag = 1;
    specstruc.type = bandpop.value;
    specstruc.f = f;
    specstruc.m = m;
    specstruc.Rp = Rpm.value;
    specstruc.Rs = Rsm.value;
    specstruc.wt = wt;
    specstruc.order = order.value;
    
    filt.tf.num = b;
    filt.tf.den = a;
    filt.specs.fdfirls = specstruc;
    filt.zpk = [];
    filt.ss = [];
    filt.sos = [];
    filt.type = 'design';

    varargout{1} = filt;
    varargout{2} = '';
    
    switch type
    case 1   % lowpass
        set(L1,'xdata',[f(1:2) NaN f(1:2)]*Fs/2,...
               'ydata',[maxpass maxpass NaN minpass minpass])
        set(L2,'xdata',[f(3:4)]*Fs/2,'ydata',[minstop minstop])
    case 2   % highpass
        set(L1,'xdata',[f(3:4) NaN f(3:4)]*Fs/2,...
               'ydata',[maxpass maxpass NaN minpass minpass ])
        set(L2,'xdata',[f(1:2)]*Fs/2,'ydata',[ minstop minstop])
    case 3   % bandpass
        set(L1,'xdata',[f(3:4) NaN f(3:4)]*Fs/2,...
               'ydata',[maxpass maxpass NaN minpass minpass])
        set(L2,'xdata',[f(1:2) NaN f(5:6)]*Fs/2,...
               'ydata',[ minstop minstop NaN minstop minstop])
    case 4   % bandstop
        set(L1,'xdata',[f(1:2) NaN f(1:2) NaN f(5:6) NaN f(5:6)]*Fs/2,...
               'ydata',[ maxpass maxpass NaN minpass minpass NaN ...
                         maxpass maxpass NaN minpass minpass])
        set(L2,'xdata',[f(3:4)]*Fs/2,'ydata',[minstop minstop])
    end
    
    for i=1:3
        set(pbmeasures(i),'enable','on')
        set(sbmeasures(i),'enable','on')
    end
    set(order1,'enable','on')

    if strcmp(msg,'motion')
        return
    end
    
    Lresp.linestyle = '-';
    L1.linestyle = '-';
    L2.linestyle = '-';

case 'revert'
    filt = filtdes('filt');
    oldtype = filt.specs.fdfirls.type;
    % need to restore filter type
    setOrderFlag = filt.specs.fdfirls.setOrderFlag;
    f = filt.specs.fdfirls.f;
    Rpass = filt.specs.fdfirls.Rp;
    Rstop = filt.specs.fdfirls.Rs;
    wt = filt.specs.fdfirls.wt;
    N = filt.specs.fdfirls.order;
    fdfirls('newfilt',setOrderFlag,oldtype,f,Rpass,Rstop,wt,N)
    
    Rpm.value = L1.ydata(1)-L1.ydata(4);
    Rsm.value = -L2.ydata(1);
    
    Lresp.linestyle = '-';
    L1.linestyle = '-';
    L2.linestyle = '-';
    for i=1:3
        set(pbmeasures(i),'enable','on')
        set(sbmeasures(i),'enable','on')
    end
    set(order1,'enable','on')
    
case 'help'
    str = fdhelpstr('fdfirls');
    varargout{1} = str{2};

case 'description'
    varargout{1} = 'Least Squares FIR';

case 'Fs'
% Sampling frequency has changed

%   The filter spec does not depend on the sampling frequency
    filt = varargin{2};
    varargout{1} = filt;
    
% update various lines and specifications:
    oldFs = varargin{3};
    Fs = filt.Fs;  % new Fs
    f1.value = f1.value*Fs/oldFs;
    f2.value = f2.value*Fs/oldFs;
    f3.value = f3.value*Fs/oldFs;
    f4.value = f4.value*Fs/oldFs;
    f1.range = f1.range*Fs/oldFs;
    f2.range = f2.range*Fs/oldFs;
    f3.range = f3.range*Fs/oldFs;
    f4.range = f4.range*Fs/oldFs;

    ax.xlimbound = [0 Fs/2];
    ax.xlim = ax.xlim*Fs/oldFs;
    ax.xlimpassband = ax.xlimpassband*Fs/oldFs;
    L1.xdata = L1.xdata*Fs/oldFs;
    L2.xdata = L2.xdata*Fs/oldFs;
    Lresp.xdata = Lresp.xdata*Fs/oldFs;
    
%---------------------------------------------------------------------
% -------- following cases are module specific --------- 
%---------------------------------------------------------------------

case 'dirty'
% fdfirls('dirty')
% Callback of a spec ... to change appearance so user can
%  see that the specs and the currently designed filter
%  don't match
    if Lresp.linestyle ~= ':'
        Lresp.linestyle = ':';
        L1.linestyle = ':';
        L2.linestyle = ':';
    end
    for i=1:3
        set(pbmeasures(i),'enable','off')
        set(sbmeasures(i),'enable','off')
    end
    set(order1,'enable','off')

%---------------------------------------------------------------------
% fdfirls('fchange')
%  Callback when a frequency has changed
%  Need to update ranges and lines L1, L2
case 'fchange'
    xd1 = L1.xdata;
    xd2 = L2.xdata;
    f = [f1.value,f2.value,f3.value,f4.value];
    % update lines and find i, index of frequency which changed
    %  (i = 1, 2, 3, 4 for f1, f2, f3, or f4)
    i = [];
    type = bandpop.value;
    switch type
    case 1
        if xd1(2) ~= f(1)
            xd1([2 5]) = f(1);
            i = 1;
        else
            xd2(1) = f(2);
            i = 2;
        end
    case 2 % highpass
        if xd2(2) ~= f(1)
            xd2(2) = f(1);
            i = 1;
        else
            xd1([1 4]) = f(2);
            i = 2;
        end
    case 3  % bandpass
      % L1 xdata = [f2 f3 NaN f2 f3]
      % L2 xdata = [0 f1 NaN f4 Fs/2]
        if xd2(2) ~= f(1)
            xd2(2) = f(1);
            i = 1;
        elseif xd1(1) ~= f(2)
            xd1([1 4]) = f(2);
            i = 2;
        elseif xd1(2) ~= f(3)
            xd1([2 5]) = f(3);
            i = 3;
        elseif xd2(4) ~= f(4)
            xd2(4) = f(4);
            i = 4;
        end
    case 4
      % L1 xdata = [0 f1 NaN 0 f1 NaN f4 Fs/2 NaN f4 Fs/2]
      % L2 xdata = [f2 f3]
        if xd1(2) ~= f(1)
            xd1([2 5]) = f(1);
            i = 1;
        elseif xd2(1) ~= f(2)
            xd2(1) = f(2);
            i = 2;
        elseif xd2(2) ~= f(3)
            xd2(2) = f(3);
            i = 3;
        elseif xd1(7) ~= f(4)
            xd1([7 10]) = f(4);
            i = 4;
        end
    end
    [xd1,xd2] = fdutil('validateBands',xd1,xd2,...
                       type,i,f,f1,f2,f3,f4,Fs);

    dirty = 0; % Flag used to indicate that specs have changed.
    
    % If there's a NaN in the data being compared the if-statement will
    % fail (return false) even tough the two variables are equal.  So,
    % remove the NaNs before comparing.
    nonNaNindx_L1 = ~isnan(L1.xdata);
    nonNaNindx_xd1 = ~isnan(xd1);
    if ~isequal(xd1(nonNaNindx_xd1),L1.xdata(nonNaNindx_L1)) 
        % only set if changed
        L1.xdata = xd1;
        dirty = 1;
    end

    % If there's a NaN in the data being compared the if-statement will
    % fail (return false) even tough the two variables are equal.  So,
    % remove the NaNs before comparing.
    nonNaNindx_L2 = ~isnan(L2.xdata);
    nonNaNindx_xd2 = ~isnan(xd2);
    if ~isequal(xd2(nonNaNindx_xd2),L2.xdata(nonNaNindx_L2)) 
        % only set if changed
        L2.xdata = xd2;
        dirty = 1;
    end

    if dirty  % Specs changed; update passband limits; show dotted lines
        ax.xlimPassband = fdutil('xlimpassband',type,...
                         Fs,f(1),f(2),f(3),f(4));
        fdfirls('dirty')
    end
               
%---------------------------------------------------------------------
% fdfirls('Rpchange')
%  Callback when Rp has changed
%  Need to update line L1
case 'Rpchange'

    Rpass = Rp.value;
    dev = (10^(Rpass/20)-1)/(10^(Rpass/20)+1);
    above = 20*log10(1+dev); below = 20*log10(1-dev);

    type = bandpop.value;
    if type ~= 4
    % 'ydata':[maxpass maxpass NaN minpass minpass]
        yd = [above above NaN below below];
    else
    % 'ydata': [ maxpass maxpass NaN minpass minpass NaN ...
    %                    maxpass maxpass NaN minpass minpass])
        yd = [above above NaN below below NaN ...
               above above NaN below below ];
    end
    L1.ydata = yd;
    ylim = [below above];
    dyl = (ylim(2)-ylim(1))*.15;
    ax.ylimPassband = ylim + [-dyl/2 dyl/2];

    fdfirls('dirty')
    
%---------------------------------------------------------------------
% fdfirls('Rschange')
%  Callback when Rs has changed
%  Need to update line L2
case 'Rschange'

    Rstop = Rs.value;
    type = bandpop.value;
    if type ~= 3
        yd = [-Rstop -Rstop];
    else
        yd = [-Rstop -Rstop NaN -Rstop -Rstop];
    end
    L2.ydata = yd;

    fdfirls('dirty')

%---------------------------------------------------------------------
% fdremez('checkbox')
%  Callback of minimum order checkbox
% case 'checkbox'
%     
%     set(minOrdCheckbox,'value',0)
%     
%     error('For FIRLS, you can''t select "Minimum Order".')
    
%---------------------------------------------------------------------
% fdfirls('newfilt',setOrderFlag,type,f,Rp,Rs,wt,order)
%  set values of specs objects  DOES NOT DESIGN FILTER
case 'newfilt'
    setOrderFlag = varargin{2};
    type = varargin{3};
    f = varargin{4};
    Rpass = varargin{5};
    Rstop = varargin{6};
    wt = varargin{7};
    N = varargin{8};

    co = get(0,'defaultaxescolororder');
    
    bandpop.value = type;  
    % save last value of bandpop in passframe userdata:
    passframe.userdata = type;

    set(order0,'visible','on')
    order = order0;
    order.value = N;
    wt1 = pbspecs(3);
    wt2 = sbspecs(3);
    set(wt1,'value',wt(1+(type == 2 | type == 3)),...
       'label','Weight','callback','fdfirls(''dirty'')')
    set(wt2,'value',wt(2-(type == 2 | type == 3)),...
       'label','Weight','callback','fdfirls(''dirty'')')
    L1.color = co(min(2,size(co,1)),:);
    L2.color = co(min(2,size(co,1)),:);

    switch type
    case 1 % lowpass
        f1 = pbspecs(1);
        f2 = sbspecs(1);
        pbspecs(2).visible = 'off';
        sbspecs(2).visible = 'off';
        set(f1,'value',f(2)*Fs/2,'label','Fp')
        set(f2,'value',f(3)*Fs/2,'label','Fs')
    case 2 % highpass
        f1 = sbspecs(1);
        f2 = pbspecs(1);
        pbspecs(2).visible = 'off';
        sbspecs(2).visible = 'off';
        set(f1,'value',f(2)*Fs/2,'label','Fs')
        set(f2,'value',f(3)*Fs/2,'label','Fp')
    case 3 % bandpass
        f2 = pbspecs(1);
        f3 = pbspecs(2);
        f1 = sbspecs(1);
        f4 = sbspecs(2);
        pbspecs(2).visible = 'on';
        sbspecs(2).visible = 'on';
        set(f1,'value',f(2)*Fs/2,'label','Fs1')
        set(f2,'value',f(3)*Fs/2,'label','Fp1')
        set(f3,'value',f(4)*Fs/2,'label','Fp2')
        set(f4,'value',f(5)*Fs/2,'label','Fs2')
    case 4
        f1 = pbspecs(1);
        f4 = pbspecs(2);
        f2 = sbspecs(1);
        f3 = sbspecs(2);
        pbspecs(2).visible = 'on';
        sbspecs(2).visible = 'on';
        set(f1,'value',f(2)*Fs/2,'label','Fp1')
        set(f2,'value',f(3)*Fs/2,'label','Fs1')
        set(f3,'value',f(4)*Fs/2,'label','Fs2')
        set(f4,'value',f(5)*Fs/2,'label','Fp2')
    end
    ax.xlimPassband = fdutil('xlimpassband',type,...
                         Fs,f1.value,f2.value,f3.value,f4.value);

    if ax.xlimbound(2) ~= Fs/2
        set(ax,'xlimbound',[0 Fs/2],'xlim',[0 Fs/2])
    end
    
    f = f(:)';
    minpass = L1.ydata(end);
    maxpass = L1.ydata(1);
    minstop = L2.ydata(1);
    fdutil('setLines','fdfirls',L1,L2,0,type,f,Fs,minpass,maxpass,minstop,1)

%---------------------------------------------------------------------
% fdfirls('newtype')
%  Button down fcn band configuration popup
case 'newtype'
    filt = filtdes('filt');
    newtype = bandpop.value;
    oldtype = passframe.userdata;
    if isempty(oldtype)
        oldtype = filt.specs.fdfirls.type;
    end
    passframe.userdata = newtype;
    if (newtype ~= oldtype) | strcmp(filtdes('getenable'),'on')
        if oldtype < 3  % low or high pass
            edges = [f1.value f2.value]'*2/Fs;
        else
            edges = [f1.value f2.value f3.value f4.value]'*2/Fs;
        end
        edges = fdutil('changeFilterType',newtype,oldtype,edges);
        f = [0; edges(:); 1];
        wp = get(wt1,'value');
        ws = get(wt2,'value');
        switch newtype
        case 1
            wt = [wp ws];
        case 2
            wt = [ws wp];
        case 3
            wt = [ws wp ws];
        case 4
            wt = [wp ws wp];
        end
        fdfirls('newfilt',1,...
                     newtype,f,Rp.value,...
                     Rs.value,wt,...
                     order.value)
        fdfirls('dirty')
    else
       % disp('no change of type')
    end
    
%---------------------------------------------------------------------
% fdfirls('Lrespdown')
%  Button down fcn of Lresp (response line) - pan
case 'LrespDown'
    bounds.xlim = [0 Fs/2];
    bounds.ylim = [-500 30];
    h = ax.h;
    panfcn('Ax',h,...
           'Bounds',bounds,...
           'UserHand',get(h,'zlabel'))
           
%---------------------------------------------------------------------
% fdfirls('L1down')
%  Button down fcn of L1
case 'L1down'
    L1.erasemode = 'xor';
    L2.erasemode = 'xor';
    
%---------------------------------------------------------------------
% fdfirls('L2down')
%  Button down fcn of L2
case 'L2down'
    L1.erasemode = 'xor';
    L2.erasemode = 'xor';
    
%---------------------------------------------------------------------
% fdfirls('L1up')
%  Button up fcn of L1
case 'L1up'
    L1.erasemode = 'normal';
    L2.erasemode = 'normal';
    Lresp.erasemode = 'normal';
    
%---------------------------------------------------------------------
% fdfirls('L2up')
%  Button up fcn of L2
case 'L2up'
    L1.erasemode = 'normal';
    L2.erasemode = 'normal';
    Lresp.erasemode = 'normal';

%---------------------------------------------------------------------
% fdfirls('L1drag',type,ind)
%  drag callback of L1 - passband line
%  Inputs:
%     type - band configuration 1==low, 2=high, 3=pass, 4=stop
%     ind - index of vertex being dragged
case 'L1drag'
    type = varargin{2};
    ind = varargin{3};
    xd = L1.xdata;
    minspacing = Fs/500;
    switch type
    case 1  % lowpass
        newf1 = inbounds(xd(ind),[minspacing f2.value-minspacing]);
        xd([2 5]) = newf1;
        L1.xdata = xd;
        f1.value = newf1;
        i = 1;  % index of changed frequency
    case 2  % highpass
        newf2 = inbounds(xd(ind),[f1.value+minspacing Fs/2-minspacing]);
        xd([1 4]) = newf2;
        L1.xdata = xd;
        f2.value = newf2;
        i = 2;
    case 3  % bandpass
    % L1 xdata = [f2 f3 NaN f2 f3]
        if any(ind == [1 4])   % dragging f2
            newf2 = inbounds(xd(ind),[f1.value+minspacing f3.value-minspacing]);
            xd([1 4]) = newf2;
            L1.xdata = xd;
            f2.value = newf2;
            i = 2;
        else % dragging f3
            newf3 = inbounds(xd(ind),[f2.value+minspacing f4.value-minspacing]);
            xd([2 5]) = newf3;
            L1.xdata = xd;
            f3.value = newf3;
            i = 3;
        end
    case 4   % bandstop
    % L1 xdata = [0 f1 NaN 0 f1 NaN f4 Fs/2 NaN f4 Fs/2]
        if any(ind == [2 5])   % dragging f1
            newf1 = inbounds(xd(ind),[minspacing f2.value-minspacing]);
            xd([2 5]) = newf1;
            L1.xdata = xd;
            f1.value = newf1;
            i = 1;
        else % dragging f4
            newf4 = inbounds(xd(ind),[f3.value+minspacing Fs/2-minspacing]);
            xd([7 10]) = newf4;
            L1.xdata = xd;
            f4.value = newf4;
            i = 4;
        end
    end
    if type < 3
        f = {f1.value, f2.value};
    else
        f = {f1.value, f2.value, f3.value, f4.value};
    end
    ax.xlimPassband = fdutil('xlimpassband',type,Fs,f{:});
    
%---------------------------------------------------------------------
% fdfirls('L2drag',type,ind)
%  drag callback of L2 - stopband line
%  Inputs:
%     type - band configuration 1==low, 2=high, 3=pass, 4=stop
%     ind - index of vertex being dragged
case 'L2drag'
    type = varargin{2};
    ind = varargin{3};
    xd = L2.xdata;
    minspacing = Fs/500;
    switch type
    case 1  % lowpass
        newf2 = inbounds(xd(ind),[f1.value+minspacing Fs/2-minspacing]);
        xd(1) = newf2;
        L2.xdata = xd;
        f2.value = newf2;
        i = 2;
    case 2  % highpass
        newf1 = inbounds(xd(ind),[minspacing f2.value-minspacing]);
        xd(2) = newf1;
        L2.xdata = xd;
        f1.value = newf1;
        i = 1;
    case 3  % bandpass
    % L2 xdata = [0 f1 NaN f4 Fs/2]
        if ind == 2   % dragging f1
            newf1 = inbounds(xd(ind),[minspacing f2.value-minspacing]);
            xd(2) = newf1;
            L2.xdata = xd;
            f1.value = newf1;
            i = 1;
        else % dragging f4
            newf4 = inbounds(xd(ind),[f3.value+minspacing Fs/2-minspacing]);
            xd(4) = newf4;
            L2.xdata = xd;
            f4.value = newf4;
            i = 4;
        end
    case 4   % bandstop
    % L2 xdata = [f2 f3]
        if ind == 1   % dragging f2
            newf2 = inbounds(xd(ind),[f1.value+minspacing f3.value-minspacing]);
            xd(1) = newf2;
            L2.xdata = xd;
            f2.value = newf2;
            i = 2;
        else % dragging f3
            newf3 = inbounds(xd(ind),[f2.value+minspacing f4.value-minspacing]);
            xd(2) = newf3;
            L2.xdata = xd;
            f3.value = newf3;
            i = 3;
        end
    end
    
%---------------------------------------------------------------------
% fdfirls('Rpdrag',type,ind)
%  drag callback of L1 - passband line
%  Inputs:
%     type - band configuration 1==low, 2=high, 3=pass, 4=stop
%     ind - index of segment being dragged
case 'Rpdrag'
    type = varargin{2};
    ind = varargin{3};
    yd = L1.ydata;
    
    switch ind
    case {4,10}    % dragging lower line
        below = yd(ind);
        if below >= 0 
            below = -.00001;
        elseif below < -10
            below = -10;
        end
        dev = 1-10^(below/20);
        above = 20*log10(1+dev);
    case {1,7}    % dragging upper line
        above = yd(ind);
        if above > 10 
            above = 10;
        elseif above <= 0
            above = .00001;
        end
        dev = 10^(above/20)-1;
        below = 20*log10(1-dev);
    end
    
    newRp = above-below;
    if type ~= 4
    % 'ydata':[maxpass maxpass NaN minpass minpass]
        yd = [above above NaN below below];
    else
    % 'ydata': [ maxpass maxpass NaN minpass minpass NaN ...
    %                    maxpass maxpass NaN minpass minpass])
        yd = [above above NaN below below ...
               NaN above above NaN below below ];
    end
    L1.ydata = yd;
    ylim = [below above];
    dyl = (ylim(2)-ylim(1))*.15;
    ax.ylimPassband = ylim + [-dyl/2 dyl/2];
    
    devs = [(10^(newRp/20)-1)/(10^(newRp/20)+1) 10^(-Rsm.value/20)].^2;
    bw = bandwidths(bandpop.value,f1.value,f2.value,f3.value,f4.value,Fs);
    wt = 1./(devs.*bw);
    wt = wt/min(wt);
    set(wt1,'value',wt(1))
    set(wt2,'value',wt(2))
 
%---------------------------------------------------------------------
% fdfirls('Rsdrag',type,ind)
%  drag callback of L2 - stopband line
%  Inputs:
%     type - band configuration 1==low, 2=high, 3=pass, 4=stop
%     ind - index of segment being dragged
case 'Rsdrag'
    type = varargin{2};
    ind = varargin{3};
  
    yd = L2.ydata;
    newRs = -yd(ind);
    if newRs < 0
        newRs = 0;
    end
    switch type
    case {1,2,4}
        L2.ydata = [-newRs -newRs];
    case 3
        L2.ydata = [-newRs -newRs NaN -newRs -newRs];
    end
    devs = [(10^(Rpm.value/20)-1)/(10^(Rpm.value/20)+1) 10^(-newRs/20)].^2;
    bw = bandwidths(bandpop.value,f1.value,f2.value,f3.value,f4.value,Fs);
    wt = 1./(devs.*bw);
    wt = wt/min(wt);
    set(wt1,'value',wt(1))
    set(wt2,'value',wt(2))
        
end  % of function switch-yard

%---------------------------------------------------------------------
% -------- LOCAL FUNCTIONS START HERE  --------- 
%---------------------------------------------------------------------

function sethelp
global minOrdCheckbox bandpop 
global passframe stopframe passframe1 stopframe1
global f1 f2 f3 f4 wt1 wt2 order Rp Rm pbspecs sbspecs
global Rpm Rsm wt1m wt2m
global ax L1 L2 Lresp
global Fs

% disp('setting help ... stub')

 
function yd = passbandlimits(Rp)
% return ydata = [minpass maxpass] of passband 
%   given Rp decibels of ripple
%   in passband (centered at 1 in linear scale)
    dev = (10^(Rp/20)-1)/(10^(Rp/20)+1);
    above = 20*log10(1+dev); below = 20*log10(1-dev);
    yd = [below above];


function [maxpass,minpass,minstop] = getMeasurements(ff,Hlog,type,...
                                          f1,f2,f3,f4);
    switch type
    case 1   % lowpass
        passInd = find(ff<=f1);
        stopInd = find(ff>=f2);
    case 2   % highpass
        stopInd = find(ff<=f1);
        passInd = find(ff>=f2);
    case 3   % bandpass
        stopInd = find((ff<=f1)|(ff>=f4));
        passInd = find((ff>=f2)&(ff<=f3));
    case 4   % bandstop
        passInd = find((ff<=f1)|(ff>=f4));
        stopInd = find((ff>=f2)&(ff<=f3));
    end
    maxpass = max(Hlog(passInd));
    minpass = min(Hlog(passInd));
    minstop = max(Hlog(stopInd));


function [setOrderFlag_init, type_init, f_init, Rp_init, Rs_init, ...
         order_init, wt_init] = initSpecs(filt)
%initSpecs   Initial specifications for firls filter, from
%            filt input
%Switches off of filt.currentModule and if it finds any of
% fdcheby1, fdcheby2, fdellip, fdbutter, fdfirls, or fdkaiser
% retains the type, order, band edge, and any other relevant
% parameters

    % first define default values
    setOrderFlag_init = 1;   % ALWAYS 1 for firls, since we can't
                             % estimate the order...
                             % this field is a placeholder used by
                             % the other modules 
    type_init = 1;  % 1=lowpass, 2=highpass, 3=bandpass, 4=bandstop
    f_init = [0 .1 .15 .5];
    Rp_init = 3;   % for measurements only
    Rs_init = 20;  % for measurements only
    order_init = 30;
    wt_init = [1 1];
    if strcmp(filt.specs.currentModule,'fdpzedit')
        if isfield(filt.specs.fdpzedit,'oldModule')
            filt.specs.currentModule = filt.specs.fdpzedit.oldModule;
        end
    end
    switch filt.specs.currentModule
    case {'fdcheby1','fdcheby2','fdellip','fdbutter','fdkaiser','fdremez'}
        s = eval(['filt.specs.' filt.specs.currentModule]);
        type_init = s.type;
        f_init = s.f;
        order_init = s.order;
        
        if strcmp(filt.specs.currentModule,'fdremez')
            wt_init = s.wt;
        else
            devs = [(10^(s.Rp/20)-1)/(10^(s.Rp/20)+1) 10^(-s.Rs/20)];
            switch s.type
            case 3
                devs = devs([2 1 2]);
            case 4
                devs = devs([1 2 1]);
            end
            wt_init = ones(size(devs))*max(devs)./devs;
        end
        if any(strcmp(filt.specs.currentModule,...
                 {'fdcheby1','fdcheby2','fdellip','fdbutter'}))
            order_init = order_init*10;  %  FIR filters are much higher order
                                         %  than IIR
        end
    
    case 'fdfirls'
        if isfield(filt.specs,'fdfirls')
            type_init = filt.specs.fdfirls.type;
            f_init = filt.specs.fdfirls.f;
            Rp_init = filt.specs.fdfirls.Rp;
            Rs_init = filt.specs.fdfirls.Rs;
            order_init = filt.specs.fdfirls.order;
            wt_init = filt.specs.fdfirls.wt;
        end
    end

function bw = bandwidths(type,f1,f2,f3,f4,Fs)
% Returns bandwidths of passband and stopband in a two element vector
% The larger of the two bandwidths will be 1, and the smaller
% is expressed as a fraction of the larger

    switch type
    case 1 % lowpass
        bw = [f1 Fs/2-f2];
    case 2 % high
        bw = [Fs/2-f2 f1];
    case 3 % bandpass
        bw = [f3-f2 f1+(Fs/2-f4)];
    case 4 % bandstop
        bw = [f1+(Fs/2-f4) f3-f2];
    end
    bw = bw/max(bw);
