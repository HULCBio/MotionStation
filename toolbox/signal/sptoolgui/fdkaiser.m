function varargout = fdkaiser(varargin)
%fdkaiser  Kaiser Window FIR filter design Module for filtdes.

%   Author: T. Krauss
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.9.4.2 $

% Change this global to static when available:
%  following are common to several modules
global minOrdCheckbox bandpop order pbspecs sbspecs pbmeasures sbmeasures
global passframe stopframe passframe1 stopframe1
%  following static to fdkaiser
global f1 f2 f3 f4 Rp Rs Wn1 Wn2 Beta 
global Wn1m Wn2m Betam Rpm Rsm 
global order0 order1
global ax L1 L2 Lresp L3_1 L3_2
global Fs

switch varargin{1}
case 'init'

    filt = varargin{2};
    Fs = filt.Fs;
    [setOrderFlag_init, type_init, f_init, Rp_init, Rs_init, ...
      order_init, Wn_init, Beta_init] = initSpecs(filt);
         
    [minOrdCheckbox bandpop order pbspecs sbspecs ...
         pbmeasures sbmeasures passframe stopframe ...
         passframe1 stopframe1 ax Lresp L1 L2 order1 ...
         L3_1 L3_2] = fdutil('commonObjects');
    order0 = order;
    
    if ~strcmp(bandpop.userdata,'fdkaiser')
       % this module is not current
        bandpop.userdata = 'fdkaiser';
            
        minOrdCheckbox.callback = 'fdkaiser(''checkbox'')';
        bandpop.callback = 'fdkaiser(''newtype'')';         

        order0.callback = 'fdkaiser(''dirty'')';
                
        f3 = pbspecs(2);
        f4 = sbspecs(2);
        Rp = pbspecs(3);
        Rs = sbspecs(3);
        Wn1 = pbspecs(1);
        Wn2 = pbspecs(2);
        Beta = pbspecs(3);
        Wn1m = pbmeasures(1);
        Wn2m = pbmeasures(2);
        Betam = pbmeasures(3);

        Rpm = sbmeasures(1);
        Rsm = sbmeasures(2);
                
        set(ax,'title',xlate('Frequency Response'),...
              'xlabel',xlate('Frequency'),...
              'ylabel',xlate('Magnitude (dB)'),...
              'ylim',[-150 10],'xlim',[0 Fs/2],...
              'xlimbound',[0 Fs/2]);

        sethelp

        set(Lresp,'buttondownfcn','fdkaiser(''LrespDown'')')
                       
        set(L1,'buttondownfcn','fdkaiser(''L1down'')',...
               'buttonupfcn','fdkaiser(''L1up'')');
    
        set(L2,'buttondownfcn','fdkaiser(''L2down'')',...
               'buttonupfcn','fdkaiser(''L2up'')');
               
        set(L3_1,'xdata',Wn_init([1 1]),...
                  'segmentdragcallback',{'fdkaiser(''3db_drag'',1)'},...
                  'buttondownfcn','fdkaiser(''3db_down'',1)',...
                  'buttonupfcn','fdkaiser(''L1up'')');
                  
        set(L3_2,'xdata',Wn_init([end end]),...
                  'segmentdragcallback',{'fdkaiser(''3db_drag'',2)'},...
                  'buttondownfcn','fdkaiser(''3db_down'',2)',...
                  'buttonupfcn','fdkaiser(''L1up'')');
    end  
    set(minOrdCheckbox,'visible','on','enable','on')
    set(pbspecs(1),'visible','on')
    set(sbmeasures(3),'visible','off')
          
    fdkaiser('newfilt',setOrderFlag_init,type_init,f_init,Rp_init,...
               Rs_init,Wn_init,order_init,Beta_init)
               
    if setOrderFlag_init
    % set these fields since 'Apply' gets them from the specifications struc
    % to make the measurements
        filt.specs.fdkaiser.Rp = Rp_init;
        filt.specs.fdkaiser.Rs = Rs_init;
    end
    
    [filt, errstr] = fdutil('callModuleApply',...
                               'fdkaiser',filt,'');
    varargout{1} = filt;
    varargout{2} = errstr;

case 'apply'    

    filt = varargin{2};
    msg = varargin{3};
    if strcmp(msg,'motion') | strcmp(msg,'up')
        inputLine = varargin{4};
        if ~minOrdCheckbox.value & (isequal(inputLine,L1) | isequal(inputLine,L2))
            varargout{1} = filt;
            varargout{2} = '';
            return
        end
    end
    if strcmp(msg,'motion') & ~strcmp(get(Lresp,'erasemode'),'xor')
        Lresp.erasemode = 'xor';
        drawnow
    end
    
    % DESIGN FILTER!!!!
    type = bandpop.value;
    setOrderFlag = ~minOrdCheckbox.value;
    if ~setOrderFlag     % estimate order
        [n,Wn,beta_val] = estimateOrder(type,Rp.value,Rs.value,Fs,...
                 f1.value,f2.value,f3.value,f4.value);
        if ((type==2)|(type==4)) & rem(n,2)
            n = n + 1;
        end
    else
        n = order.value;
        Wn = Wn1.value * 2/Fs;
        if type > 2  % pass/stop
            Wn(2) = Wn2.value * 2/Fs;
        end
        beta_val = Beta.value;
    end
    
    % save specifications in specifications structure:
    specStruc.setOrderFlag = setOrderFlag;
    specStruc.type = type;
    if ~setOrderFlag
        f = getFrequencyValues(type,f1,f2,f3,f4,Fs);
        specStruc.f = f;
        specStruc.Rp = Rp.value;
        specStruc.Rs = Rs.value;
    else
        specStruc.f = [];  % place holder, will be defined by measureFilt
        specStruc.Rp = filt.specs.fdkaiser.Rp;
        specStruc.Rs = filt.specs.fdkaiser.Rs;
    end
    specStruc.Wn = Wn;
    specStruc.order = n;
    specStruc.Beta = beta_val;
                          
%     if ~setOrderFlag & isfield(filt.specs,'fdkaiser') & ...
%         isequal(specStruc.Wn,filt.specs.fdkaiser.Wn) ...
%         & isequal(specStruc.order,filt.specs.fdkaiser.order)
%         filt.specs.fdkaiser = specStruc;
%         varargout{1} = filt;
%         varargout{2} = '';
%         return
%     end
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
    
    % obtain Kaiser window:
    if isfield(filt.specs,'fdkaiser') & ...
       isfield(filt.specs.fdkaiser,'order') & ...
      ( (filt.specs.fdkaiser.order == n) ...
             & (filt.specs.fdkaiser.Beta == beta_val) )
        % recycle already computed window
        wind = filt.specs.fdkaiser.wind;
    else
        % compute and save window
        wind = kaiser(n+1,beta_val);
    end
    specStruc.wind = wind;
    
    % design filter:
    if type == 2
        [b,a] = fir1(n, Wn, 'high', wind, 'noscale');
    elseif type == 4
        [b,a] = fir1(n, Wn, 'stop', wind, 'noscale');
    else
        [b,a] = fir1(n, Wn, wind, 'noscale');
    end
        
    % compute frequency response:
    nfft = filtdes('nfft');
    [H,ff] = freqz(b,a,nfft,Fs);
    % avoid log of 0 at 0 and Fs/2:
    if H(1) == 0, H(1) = H(2); end
    if H(end) == 0, H(end) = H(end-1); end
    Hlog = 20*log10(abs(H(:)));
    set(Lresp,'xdata',ff,'ydata',Hlog);
    
    % make measurements:
    if ~ ((strcmp(msg,'motion') | strcmp(msg,'up')) & ~setOrderFlag ...
             & strcmp(get(order1,'visible'),'on') )  | ...
       (~setOrderFlag & (filt.specs.fdkaiser.type ~= type))
        objSetupFlag = 1;
    else
        objSetupFlag = 0;
    end
    
    [Rp,Rs,f1,f2,f3,f4,specStruc] = ...
      measureFilt(objSetupFlag,specStruc,Fs,order,order1,passframe1,stopframe1,ax,...
                  pbmeasures,sbmeasures,Rp,Rs,Wn1m,Wn2m,Betam,Rpm,Rsm,f1,f2,f3,f4,...
                  ff,Hlog,L1,L2);
                      
    if ~strcmp(msg,'motion')
        % if design is due to a drag operation, lines are already solid
        % so we can skip this step
        Lresp.linestyle = '-';
        L1.linestyle = '-';
        L2.linestyle = '-';
        set(L3_1,'linestyle','-')
        set(L3_2,'linestyle','-')
        if strcmp(L3_1.erasemode,'normal')
            warning('L3_1 erasemode is normal... why?')
            L3_1.erasemode = 'xor';
            L3_2.erasemode = 'xor';
        end
    end
    
    % alter filt fields:
    filt.tf.num = b;
    filt.tf.den = a;
    filt.specs.fdkaiser = specStruc;
    filt.zpk = [];  % clear out in case filtview has written these
    filt.ss = [];
    filt.sos = [];
    filt.type = 'design';

    varargout{1} = filt;
    varargout{2} = '';
        
case 'revert'
    filt = filtdes('filt');
    oldtype = filt.specs.fdkaiser.type;
    % need to restore filter type
    setOrderFlag = filt.specs.fdkaiser.setOrderFlag;
    oldSetOrderFlag = ~minOrdCheckbox.value;
    f = filt.specs.fdkaiser.f;
    Rpass = filt.specs.fdkaiser.Rp;
    Rstop = filt.specs.fdkaiser.Rs;
    Wn = filt.specs.fdkaiser.Wn;
    N = filt.specs.fdkaiser.order;
    b = filt.specs.fdkaiser.Beta;
    fdkaiser('newfilt',setOrderFlag,oldtype,f,Rpass,Rstop,Wn,N,b)

    [Rp,Rs,f1,f2,f3,f4] = ...
      measureFilt(1,...
                  filt.specs.fdkaiser,Fs,order,order1,passframe1,stopframe1,ax,...
                  pbmeasures,sbmeasures,Rp,Rs,Wn1m,Wn2m,Betam,Rpm,Rsm,f1,f2,f3,f4,...
                  Lresp.xdata,Lresp.ydata,L1,L2);    
    
    Lresp.linestyle = '-';
    L1.linestyle = '-';
    L2.linestyle = '-';
    set(L3_1,'linestyle','-')
    set(L3_2,'linestyle','-')
    
    for i=1:3
        set(pbmeasures(i),'enable','on')
        set(sbmeasures(i),'enable','on')
    end
    set(order1,'enable','on')
    
case 'help'
    str = fdhelpstr('fdkaiser');
    varargout{1} = str{2};

case 'description'
    varargout{1} = 'Kaiser Window FIR';

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
    L3_1.xdata = L3_1.xdata*Fs/oldFs;
    L3_2.xdata = L3_2.xdata*Fs/oldFs;
    
    if minOrdCheckbox.value
        Wn1m.value = Wn1m.value*Fs/oldFs;
        Wn2m.value = Wn2m.value*Fs/oldFs;
    elseif ~any(Wn1==[f1 f2 f3 f4])
        Wn1.value = Wn1.value*Fs/oldFs;
        Wn2.value = Wn2.value*Fs/oldFs;
        Wn1.range = Wn1.range*Fs/oldFs;
        Wn2.range = Wn2.range*Fs/oldFs;
    end
    
%---------------------------------------------------------------------
% -------- following cases are module specific --------- 
%---------------------------------------------------------------------

case 'dirty'
% fdkaiser('dirty')
% Callback of a spec ... to change appearance so user can
%  see that the specs and the currently designed filter
%  don't match
    if Lresp.linestyle ~= ':'
        Lresp.linestyle = ':';
        L1.linestyle = ':';
        L2.linestyle = ':';
        L3_1.linestyle = ':';
        L3_2.linestyle = ':';
    end
    for i=1:3
        set(pbmeasures(i),'enable','off')
        set(sbmeasures(i),'enable','off')
    end
    set(order1,'enable','off')

%---------------------------------------------------------------------
% fdkaiser('clean')
% opposite of 'dirty'
case 'clean'
    if Lresp.linestyle ~= '-'
        Lresp.linestyle = '-';
        L1.linestyle = '-';
        L2.linestyle = '-';
        L3_1.linestyle = '-';
        L3_2.linestyle = '-';
    end
    for i=1:3
        set(pbmeasures(i),'enable','on')
        set(sbmeasures(i),'enable','on')
    end
    set(order1,'enable','on')
    filtdes('setenable','off')
    
%---------------------------------------------------------------------
% fdkaiser('fchange',i)
%    Callback when frequency i has changed
%    Need to update ranges and lines L1, L2
% fdkaiser('fchange')
%    called w/o input i when a 3db frequency spec has 
%    changed (in case ~minOrdCheckbox.val==1)
case 'fchange'
    type = bandpop.value;
    if nargin == 1
    % a 3db freq spec has changed  (we are in set mode)
        
        if type >= 3
            Wn = [Wn1.value Wn2.value];
            set(L3_1,'xdata',Wn([1 1]))
            set(L3_2,'xdata',Wn([2 2]))
            Wn1.range = [0 Wn(2)];
            Wn2.range = [Wn(1) Fs/2];
        else
            Wn = Wn1.value;
            set(L3_1,'xdata',Wn([1 1]))
        end
        fdkaiser('dirty')
        return
    end
    i = varargin{2};
    xd1 = L1.xdata;
    xd2 = L2.xdata;
    f = [f1.value,f2.value,f3.value,f4.value];
    % update lines
    switch type
    case 1
      % L1 xdata = [0 f1 NaN 0 f1]
      % L2 xdata = [f2 Fs/2]
        if i==1
            xd1([2 5]) = f(1);
        else
            xd2(1) = f(2);
        end
    case 2
      % L1 xdata = [f2 Fs/2 NaN f2 Fs/2]
      % L2 xdata = [0 f1]
        if i == 1
            xd2(2) = f(1);
        else
            xd1([1 4]) = f(2);
        end
    case 3  % bandpass
      % L1 xdata = [f2 f3 NaN f2 f3]
      % L2 xdata = [0 f1 NaN f4 Fs/2]
        if xd2(2) ~= f(1)
            xd2(2) = f(1);
        elseif xd1(1) ~= f(2)
            xd1([1 4]) = f(2);
        elseif xd1(2) ~= f(3)
            xd1([2 5]) = f(3);
        elseif xd2(4) ~= f(4)
            xd2(4) = f(4);
        end
    case 4
      % L1 xdata = [0 f1 NaN 0 f1 NaN f4 Fs/2 NaN f4 Fs/2]
      % L2 xdata = [f2 f3]
        if xd1(2) ~= f(1)
            xd1([2 5]) = f(1);
        elseif xd2(1) ~= f(2)
            xd2(1) = f(2);
        elseif xd2(2) ~= f(3)
            xd2(2) = f(3);
        elseif xd1(7) ~= f(4)
            xd1([7 10]) = f(4);
        end
    end
    
    if minOrdCheckbox.value
        [xd1,xd2] = fdutil('validateBands',xd1,xd2,...
                           type,i,f,f1,f2,f3,f4,Fs);
        fdkaiser('dirty')
    else
        fChangeMeas(i,type,Fs,Lresp,L1,L2,f1,f2,f3,f4,Rp,Rs)
        return
    end
    
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

    if dirty  % Specs have changed; update passband limits
        ax.xlimPassband = fdutil('xlimpassband',type,...
                         Fs,f1.value,f2.value,f3.value,f4.value);
    end

    % fdutil('updateRanges',i,f1,f2,f3,f4)    % update ranges
    
%---------------------------------------------------------------------
% fdkaiser('Rpchange')
%  Callback when Rp has changed
%  Need to update line L1
case 'Rpchange'
    type = bandpop.value;
    if minOrdCheckbox.value
        Rpass = Rp.value;
        above = 0; below = -Rpass;
    
        if type ~= 4
        % 'ydata':[maxpass maxpass NaN minpass minpass]
            yd = [above above NaN below below];
        else
        % 'ydata': [ maxpass maxpass NaN minpass minpass NaN ...
        %                    maxpass maxpass NaN minpass minpass])
            yd = [above above NaN below below ...
                   above above NaN below below ];
        end
        L1.ydata = yd;
        ylim = [below above];
        dyl = (ylim(2)-ylim(1))*.15;
        
        ax.ylimPassband = ylim + [-dyl/2 dyl/2];
    
        fdkaiser('dirty')
    else
        RChangeMeas(1,type,Fs,Lresp,L1,L2,f1,f2,f3,f4,Rp,Rs)
    end

    
%---------------------------------------------------------------------
% fdkaiser('Rschange')
%  Callback when Rs has changed
%  Need to update line L2
case 'Rschange'
    type = bandpop.value;
    
    if minOrdCheckbox.value

        Rstop = Rs.value;
        if type ~= 3
            yd = [-Rstop -Rstop];
        else
            yd = [-Rstop -Rstop NaN -Rstop -Rstop];
        end
        L2.ydata = yd;
        fdkaiser('dirty')
    else
        RChangeMeas(0,type,Fs,Lresp,L1,L2,f1,f2,f3,f4,Rp,Rs)
    end


%---------------------------------------------------------------------
% fdkaiser('checkbox')
%  Callback of minimum order checkbox
case 'checkbox'
    filt = filtdes('filt');
    
    newSetOrderFlag = ~get(minOrdCheckbox,'value');
    type = bandpop.value;
    oldtype = filt.specs.fdkaiser.type;
    
    if ~newSetOrderFlag   % from set to estimate order 
        if filt.specs.fdkaiser.setOrderFlag
            % obtain frequencies from measurements
            c = {pbmeasures(1) pbmeasures(2) sbmeasures(1) sbmeasures(2)};
            if type == 2 | type == 3
                ind = [3 1 2 4];
            else
                ind = [1 3 4 2];
            end
            f = getFrequencyValues(oldtype,c{ind},Fs);
        else
            % obtain frequencies from filter specs field
            f = filt.specs.fdkaiser.f;
        end
        f = [0; fdutil('changeFilterType',type,oldtype,sort(f(2:end-1))); 1];
        Wn = [0 0];  % place holder - ignored by 'newfilt'     
        beta_val = Beta.value;
    else   % from estimate to set order 
        Wn = mean([f1.value f2.value])*2/Fs;
        if type > 2
            Wn(2) = mean([f3.value f4.value]) * 2/Fs;
        end
        f = [];  % place holder - ignored by 'newfilt'
        beta_val = Betam.value;
    end
    fdkaiser('newfilt',newSetOrderFlag,...
                       type,f,Rp.value,...
                       Rs.value,Wn,order.value,beta_val)
    fdkaiser('dirty')


%---------------------------------------------------------------------
% fdkaiser('newfilt',setOrderFlag,type,f,Rp,Rs,Wn,order,beta_val)
%  set values of SPECIFICATIONS objects ...  DOES NOT DESIGN FILTER
case 'newfilt'
    setOrderFlag = varargin{2};
    type = varargin{3};
    f = varargin{4};     % in range (0,1)
    Rpass = varargin{5};
    Rstop = varargin{6};
    Wn = varargin{7};  % in range (0,1)
    N = varargin{8};
    beta_val = varargin{9};

    co = get(0,'defaultaxescolororder');
    
    bandpop.value = type;
    % save last value of bandpop in passframe userdata:
    passframe.userdata = type;
    minOrdCheckbox.value = ~setOrderFlag;

    if ~setOrderFlag  % estimate order
        % initialize specs:
        passframe.visible = 'on';
        stopframe.visible = 'on';
        order = order1;
        set(order0,'visible','off')

        [f1,f2,f3,f4] = setupFrequencyObjects(type,'fdkaiser',...
                           pbspecs,sbspecs,f,Fs,ax);
        
        pbspecs(3).visible = 'on';
        sbspecs(1).visible = 'on';
        sbspecs(3).visible = 'on';
                
        Rp = pbspecs(3);
        Rs = sbspecs(3);
        set(Rp,'value',Rpass,'label','Rp','callback','fdkaiser(''Rpchange'')')
        set(Rs,'value',Rstop,'label','Rs','callback','fdkaiser(''Rschange'')')
                
        L1.color = co(min(2,size(co,1)),:);
        L2.color = co(min(2,size(co,1)),:);   
        set(L3_1,'visible','off')     
        set(L3_2,'visible','off')     
    else  % set order
        passframe.visible = 'off';
        stopframe.visible = 'off';
        order = order0;
        order.value = N;
        set(order0,'visible','on')
                        
        set(sbspecs(1),'visible','off')
        set(sbspecs(2),'visible','off')
        set(sbspecs(3),'visible','off')
       
        set(L3_1,'visible','on','xdata',Wn([1 1])*Fs/2)     
        if type < 3  % low/high
            set(Wn1,'value',Wn(1)*Fs/2,'range',[0 1]*Fs/2,...
               'label','Fc','callback','fdkaiser(''fchange'')',...
               'visible','on')
            Wn2.visible = 'off';
            set(L3_2,'visible','off')
        else  % pass/stop
            set(Wn1,'value',Wn(1)*Fs/2,'range',[0 Wn(2)]*Fs/2,...
               'label','Fc1','callback','fdkaiser(''fchange'')',...
               'visible','on')
            set(Wn2,'value',Wn(2)*Fs/2,'range',[Wn(1) 1]*Fs/2,...
               'label','Fc2','callback','fdkaiser(''fchange'')',...
               'visible','on')
            set(L3_2,'visible','on','xdata',Wn([2 2])*Fs/2)     
        end
                
        L1.color = co(min(3,size(co,1)),:);
        L2.color = co(min(3,size(co,1)),:);
        
        set(Beta,'label','Beta','value',beta_val,...
                 'range',[0 Inf],'inclusive',[1 0],'visible','on')
    end

    if ax.xlimbound(2) ~= Fs/2
        set(ax,'xlimbound',[0 Fs/2],'xlim',[0 Fs/2])
    end
    
    if ~setOrderFlag  % estimate order
        yd = passbandlimits(Rpass);
        minpass = yd(1);
        maxpass = yd(2);
        minstop = -Rstop;
        fdutil('setLines','fdkaiser',L1,L2,0,...
                           type,f(:)',Fs,minpass,maxpass,minstop,1)
    else  % set order
        set(L1,'segmentdragmode',{'none'},...
               'segmentpointer',{'forbidden'},...
               'vertexdragmode',{'none'},...
               'vertexpointer',{'forbidden'})
        set(L2,'segmentdragmode',{'none'},...
               'segmentpointer',{'forbidden'},...
               'vertexdragmode',{'none'},...
               'vertexpointer',{'forbidden'})
    end
    
%---------------------------------------------------------------------
% fdkaiser('newtype')
%  callback of band configuration popup
case 'newtype'
    filt = filtdes('filt');
    newtype = bandpop.value;
    oldtype = get(passframe,'userdata');
    if isempty(oldtype)
        oldtype = filt.specs.fdkaiser.type;
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
        
        if ~minOrdCheckbox.value
            Wn = Wn1.value * 2/Fs;
            if newtype > 2
                Wn(2) = Wn2.value * 2/Fs;
                if Wn(2) <= Wn(1) | Wn(2)>1
                    Wn(2) = (Wn(1) + 1)/2;
                    Wn2.value = Wn(2)*Fs/2;
                end
            end
        else
            Wn = [0 0]; % place holder - ignored by newfilt
        end
        fdkaiser('newfilt',~minOrdCheckbox.value,newtype,f,Rp.value,...
                  Rs.value,Wn,order.value,Beta.value)
        fdkaiser('dirty')
        
    else
       % disp('no change of type')
    end
    
%---------------------------------------------------------------------
% fdkaiser('Lrespdown')
%  Button down fcn of Lresp (response line) - pan
case 'LrespDown'
    bounds.xlim = [0 Fs/2];
    bounds.ylim = [-500 30];
    h = ax.h;
    panfcn('Ax',h,...
           'Bounds',bounds,...
           'UserHand',get(h,'zlabel'),...
           'Invisible',[L3_1.h L3_2.h])
           
%---------------------------------------------------------------------
% fdkaiser('L1down')
%  Button down fcn of L1
% fdkaiser('L2down')
%  Button down fcn of L2
% fdkaiser('3db_down',i)
%   buttondown fcn of 3db line 1 or 2 (i==1 or 2)
case {'L1down', 'L2down', '3db_down'}
    L1.erasemode = 'xor';
    L2.erasemode = 'xor';
   
%---------------------------------------------------------------------
% fdkaiser('L1up')
%  Button up fcn of L1
% fdkaiser('L2up')
%  Button up fcn of L2
case {'L1up', 'L2up'}
    L1.erasemode = 'normal';
    L2.erasemode = 'normal';
    Lresp.erasemode = 'normal';
    
%---------------------------------------------------------------------
% fdkaiser('3db_drag',ind)
%  segment drag callback of L3_1 and L3_2 - 3db frequency lines
%  Inputs:
%     ind - index of line being dragged, 1 or 2
case '3db_drag'
    ind = varargin{2};
    minspacing = Fs/500;
    if ind == 1
        xd = L3_1.xdata;
        newFc1 = inbounds(xd(1),[minspacing Wn1.range(2)-minspacing]);
        if newFc1 ~= Wn1.value
            Wn1.value = newFc1;
            Wn2.range = [newFc1 Fs/2];
            if newFc1 ~= xd(1)
                L3_1.xdata = newFc1([1 1]);
            end
        end
    else
        xd = L3_2.xdata;
        newFc2 = inbounds(xd(1),[Wn2.range(1)+minspacing Fs/2-minspacing]);
        if newFc2 ~= Wn2.value
            Wn2.value = newFc2;
            Wn1.range = [0 newFc2];
            if newFc2 ~= xd(1)
                L3_2.xdata = newFc2([1 1]);
            end
        end
    end

%---------------------------------------------------------------------
% fdkaiser('L1drag',type,ind)
%  vertex drag callback of L1 - passband line
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
        i = 1;
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
    if ~minOrdCheckbox.value
        fChangeMeas(i,type,Fs,Lresp,L1,L2,f1,f2,f3,f4,Rp,Rs)
        return
    end
    ax.xlimPassband = fdutil('xlimpassband',type,...
                         Fs,f1.value,f2.value,f3.value,f4.value);

%---------------------------------------------------------------------
% fdkaiser('L2drag',type,ind)
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
    if ~minOrdCheckbox.value
        fChangeMeas(i,type,Fs,Lresp,L1,L2,f1,f2,f3,f4,Rp,Rs)
    end
    
%---------------------------------------------------------------------
% fdkaiser('Rpdrag',type,ind)
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
        if get(minOrdCheckbox,'value')==1    % estimate order
        % drag indicates change in desired spec for Rp 
            if below >= 0 
                below = -.00001;
            elseif below < -10
                below = -10;
            end
            dev = 1-10^(below/20);
            above = 20*log10(1+dev);
        else
        % drag indicates changing measurement
            above = yd(1);    
        end
        RpInd = 1;
    case {1,7}    % dragging upper line
        above = yd(ind);
        if get(minOrdCheckbox,'value')==1    % estimate order
        % drag indicates change in desired spec for Rp 
            if above > 10 
                above = 10;
            elseif above <= 0
                above = .00001;
            end
            dev = 10^(above/20)-1;
            below = 20*log10(1-dev);
        else
        % drag indicates changing measurement
            below = yd(4);    
        end
        RpInd = 2;
    end
    
    newRp = above-below;

    if minOrdCheckbox.value
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
        Rp.value = newRp;
        ylim = [below above];
        dyl = (ylim(2)-ylim(1))*.15;
        ax.ylimPassband = ylim + [-dyl/2 dyl/2];
    else
        % Rp.value = newRp;
        RChangeMeas(1,type,Fs,Lresp,L1,L2,f1,f2,f3,f4,Rp,Rs,[below above],RpInd)
    end
 
%---------------------------------------------------------------------
% fdkaiser('Rsdrag',type,ind)
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
    if minOrdCheckbox.value
        switch type
        case {1,2,4}
            L2.ydata = [-newRs -newRs];
        case 3
            L2.ydata = [-newRs -newRs NaN -newRs -newRs];
        end
        set(Rs,'value', newRs)
    else
        set(Rs,'value', newRs)
        RChangeMeas(0,type,Fs,Lresp,L1,L2,f1,f2,f3,f4,Rp,Rs)
    end
    
end  % of function switch-yard

%---------------------------------------------------------------------
% -------- LOCAL FUNCTIONS START HERE  --------- 
%---------------------------------------------------------------------

function sethelp
%  following are common to several modules
global minOrdCheckbox bandpop order pbspecs sbspecs pbmeasures sbmeasures
global passframe stopframe passframe1 stopframe1
%  following static to fdkaiser
global f1 f2 f3 f4 Rp Rs Wn1 Wn2 Beta 
global Wn1m Wn2m Betam Rpm Rsm 
global order0 order1
global ax L1 L2 Lresp L3_1 L3_2
global Fs

% disp('setting help ... stub')


function [n,Wn,beta_val] = estimateOrder(type,Rp,Rs,Fs,f1,f2,f3,f4)
% [n,Wn,beta_val] = estimateOrder(type,Rp,Rs,Fs,f1,f2,f3,f4)
%   estimate filter order
%   takes the specifications as given by the input
%   parameters and estimates the order, and beta value
%   needed to meet those specifications.
%   Also returns Wn - cutoff frequencies for fir1 filter.
% Inputs:
%  type - 1,2,3,4 specifies band configuration
%  Rp, Rs passband, stopband ripple
%  Fs - sampling frequency
%  f1,f2  first two frequencies in ascending order
%  f3,f4 only needed if type == 3 or 4, remaining frequencies
%    f1,f2,f3,f4 are assumed between 0 and Fs/2 on input
% Outputs:
%  n - filter order
%  Wn - filter band edges for fir1, normalized to range [0...1]
%  beta_val - beta parameter of Kaiser window

% compute deviations and estimate order
if type == 1    % low pass
    dev = [ (10^(Rp/20)-1)/(10^(Rp/20)+1)  10^(-Rs/20) ];
    f = [f1 f2];  m = [1 0];
elseif type == 2   % high pass
    dev = [ 10^(-Rs/20) (10^(Rp/20)-1)/(10^(Rp/20)+1)];
    f = [f1 f2];  m = [0 1];
elseif type == 3   % band pass
    dev = [ 10^(-Rs/20) (10^(Rp/20)-1)/(10^(Rp/20)+1) 10^(-Rs/20)];
    f = [f1 f2 f3 f4];  m = [0 1 0];
elseif type == 4   % band stop
    dev = [(10^(Rp/20)-1)/(10^(Rp/20)+1) ...
              10^(-Rs/20) (10^(Rp/20)-1)/(10^(Rp/20)+1)];
    f = [f1 f2 f3 f4];  m = [1 0 1];
end
[n,Wn,beta_val] = kaiserord(f,m,dev,Fs);
Wn = Wn(:)';   % make Wn a row 
 

function yd = passbandlimits(Rp)
% return ydata = [minpass maxpass] of passband 
%   given Rp decibels of ripple
%   in passband (centered at 1 in linear scale)
    dev = (10^(Rp/20)-1)/(10^(Rp/20)+1);
    above = 20*log10(1+dev); below = 20*log10(1-dev);
    yd = [below above];

function [maxpass,minpass,minstop] = getMagMeasurements(ff,Hlog,type,...
                                          f1,f2,f3,f4);
%getMagMeasurements
% Finds passband and stopband ripple for given band edges 
% given a filter's magnitude response
% Inputs:
%  ff - xdata of response
%  Hlog - magnitude of response at frequencies ff, in dB
%  type - band configuration (lp = 1, hp = 2, bp = 3, bs = 4)
%  f1, f2, f3, f4 - band edges (f3 and f4 ignored if type < 3)
%           in same units as ff
% Output:
%  maxpass - maximum passband value - 2 element vector if type == 4 (bandstop)
%  minpass - minimum passband value - 2 element vector if type == 4 (bandstop)
%  minstop - maximum stopband value - 2 element vector is type == 3 (bandpass)
    switch type
    case 1   % lowpass
        passInd = find(ff<=f1);
        stopInd = find(ff>=f2);
    case 2   % highpass
        stopInd = find(ff<=f1);
        passInd = find(ff>=f2);
    case 3   % bandpass
        stopInd1 = find(ff<=f1);
        stopInd2 = find(ff>=f4);
        [Hmax,centerInd] = max(Hlog);
        passInd1 = find((ff>=f2)&(ff<=ff(centerInd)));
        passInd2 = find((ff>ff(centerInd))&(ff<=f3));
    case 4   % bandstop
        passInd1 = find(ff<=f1);
        passInd2 = find(ff>=f4);       
        [peakInd,peaks] = fdutil('findpeaks',Hlog);
        [Hmin,ind] = min(peaks);
        centerInd = peakInd(ind);        
        stopInd1 = find((ff>=f2)&(ff<=ff(centerInd)));
        stopInd2 = find((ff>ff(centerInd))&(ff<=f3));
    end
    switch type
    case {3,4}
        maxpass = [max(Hlog(passInd1)) max(Hlog(passInd2))];
        minpass = [min(Hlog(passInd1)) min(Hlog(passInd2))];
        minstop = [max(Hlog(stopInd1)) max(Hlog(stopInd2))];
    otherwise
        maxpass = max(Hlog(passInd));
        minpass = min(Hlog(passInd));
        minstop = max(Hlog(stopInd));
    end

    
function [fm,Rp_range,Rs] = getFreqMeasurements(passbandChange,ff,Hlog,type,Rp_range,...
                               Rs,RpInd)
%getFreqMeasurements
% Finds band edges for a given passband and stopband ripple
% given a filter's magnitude response
% Inputs:
%  passbandChange - 1 if given Rp is a desired quantity, 0 if Rp is known valid
%  ff - xdata of response (assumed a column vector)
%  Hlog - magnitude of response at frequencies ff, in dB
%               (assumed a column vector)
%  type - band configuration (lp = 1, hp = 2, bp = 3, bs = 4)
%  Rp_range - this is either a scalar Rp = passband ripple, in dB
%        or a 2 element range Rp_range = [below above], diff(Rp_range) = Rp 
%  Rs - stopband attenuation in dB
%  RpInd - index into Rp_range indicating which passband line is being dragged
%      1 ==> lower, 2 ==> upper, [] ==> neither.  Defaults to [].
% Output:
%  fm - 2 or 4 element frequency vector in ascending order
%  Rp, Rs - actual value of ripple across entire band
%  Rp_range - two element vector [below above], diff(Rp_range) = Rp 
    Hlog = Hlog(:);
    ff = ff(:);
    
    if nargin < 7
        RpInd = [];
    end
    stopInd = find(Hlog<=-Rs);
    if length(Rp_range)==1
        if passbandChange
            Rp = Rp_range;
            switch type 
            case 1
                rminHlog = fdutil('rmin',Hlog);
                rmaxHlog = fdutil('rmax',Hlog);
                i = find((rmaxHlog - rminHlog)>=Rp);
                Rp_range = [rminHlog(i(1)) rmaxHlog(i(1))];
            case 2
                rminHlog = flipud(fdutil('rmin',Hlog(end:-1:1)));
                rmaxHlog = flipud(fdutil('rmax',Hlog(end:-1:1)));
                i = find((rmaxHlog - rminHlog)>=Rp);
                Rp_range = [rminHlog(i(end)) rmaxHlog(i(end))];
            case 3  % bandpass
              % define center of passband as frequency of maximum magnitude
                [Hmax,centerInd] = max(Hlog);
                rminHlog1 = fdutil('rmin',Hlog(centerInd:-1:1));
                rminHlog2 = fdutil('rmin',Hlog(centerInd+1:end));
                i1 = find((Hmax - rminHlog1)>=Rp);
                i2 = find((Hmax - rminHlog2)>=Rp);
                Rp_range = [min(Hlog([centerInd-i1(1)+1 centerInd+i2(1)])) Hmax];
            case 4  % bandstop
                rminHlog = fdutil('rmin',Hlog);
                rmaxHlog = fdutil('rmax',Hlog);
                i = find((rmaxHlog - rminHlog)>=Rp);
                Rp_range = [rminHlog(i(1)) rmaxHlog(i(1))];
            end
        else
            Rp_range = [-Rp_range 0];
        end
    end
    if isequal(RpInd,1)
        passInd = find(Hlog>=Rp_range(1));
    elseif isequal(RpInd,2)
        passInd = find(Hlog<=Rp_range(2));
    else
        passInd = find(Hlog>=Rp_range(1) & Hlog<=Rp_range(2));
    end
    switch type
    case 1   % lowpass
        if isempty(passInd)
            Rp_range = Hlog([1 2]);
            passInd = [1 2];
        end
        passIndEdges = find(diff(passInd)>1);
        if ~isempty(passIndEdges)
            passInd = passInd(1:passIndEdges(1));
        end
        if isempty(stopInd)
            Rs = -max(Hlog([end-1 end]));
            stopInd = length(Hlog)+[-1 0];
        end
        stopIndEdges = find(diff(stopInd)>1);
        if ~isempty(stopIndEdges)
            stopInd = stopInd(stopIndEdges(end)+1:end);
        end
        fm = ff([passInd(end); stopInd(1)]);
        Rp_range(1) = min(Hlog(1:passInd(end)));
        Rp_range(2) = max(Hlog(1:passInd(end)));
        Rs = -max([Hlog(stopInd(1):end); -Rs]);        

    case 2   % highpass
        if isempty(passInd)
            Rp_range = Hlog(end - [1 0]);
            passInd = length(Hlog) - [1 0];
        end
        passIndEdges = find(diff(passInd)>1);
        if ~isempty(passIndEdges)
            passInd = passInd(passIndEdges(end)+1:end);
        end
        if isempty(stopInd)
            Rs = -max(Hlog([1 2]));
            stopInd = [1 2];
        end
        stopIndEdges = find(diff(stopInd)>1);
        if ~isempty(stopIndEdges)
            stopInd = stopInd(1:stopIndEdges(1));
        end
        fm = ff([stopInd(end); passInd(1)]);
        Rp_range(1) = min(Hlog(passInd(1):end));
        Rp_range(2) = max(Hlog(passInd(1):end));
        Rs = -max([Hlog(1:stopInd(end)); -Rs]);        

    case 3   % bandpass
        %  index of beginning of upper stop band
%        i = min(find(stopInd>=passInd(1))); 
%        fm = ff([stopInd(i-1); passInd([1 end]); stopInd(i)]);
        [Hmax,centerInd] = max(Hlog);
        if isempty(passInd)
            passInd = centerInd+[0 1]';
            Rp_range = sort(Hlog(passInd));
        end
        passIndEdges = find(diff(passInd)>1);
        if ~isempty(passIndEdges)
            % reduce passband to region that includes centerInd
            passIndEdges = [passIndEdges(:)'; passIndEdges(:)'+1];
            passIndEdges = [1; passIndEdges(:); length(passInd)];
            ii = find(centerInd>passInd(passIndEdges(1:2:end)) & ...
                      centerInd<=passInd(passIndEdges(2:2:end)));
            if isempty(ii)   % current passband does not include centerInd -
                             % need to make sure it does
                Rp_range(2) = Hmax;                 
                if isequal(RpInd,2)
                    passInd = find(Hlog<=Rp_range(2));
                else
                    passInd = find(Hlog>=Rp_range(1) & Hlog<=Rp_range(2));
                end
                if isempty(passInd)
                    passInd = centerInd+[0 1];
                    Rp_range = sort(Hlog(passInd));
                end
                passIndEdges = find(diff(passInd)>1);
                if ~isempty(passIndEdges)
                    % reduce passband to region that includes centerInd
                    passIndEdges = [passIndEdges(:)'; passIndEdges(:)'+1];
                    passIndEdges = [1; passIndEdges(:); length(passInd)];
                    ii = find(centerInd>passInd(passIndEdges(1:2:end)) & ...
                              centerInd<=passInd(passIndEdges(2:2:end)));
                    passInd = passInd(passIndEdges(2*ii-1):passIndEdges(2*ii));
                end
            else
                passInd = passInd(passIndEdges(2*ii-1):passIndEdges(2*ii));
            end
        end
        if isempty(stopInd)
            stopInd = [1 2 length(Hlog)+[-1 0]]';
            Rs = -max(Hlog(stopInd));
        end
        i = min(find(stopInd>=centerInd));
        if isempty(i) % no upper stopband!
            stopInd = [stopInd; length(Hlog)+[-1 0]'];
            Rs = -max(Hlog(stopInd));
            i = length(stopInd)-1;
        elseif i==1  % no lower stopband!
            stopInd = [1; 2; stopInd];
            Rs = -max(Hlog(stopInd));
            i = 3;
        end
        stopInd1 = stopInd(1:i-1);
        stopInd2 = stopInd(i:end);
        stopIndEdges1 = find(diff(stopInd1)>1);
        if ~isempty(stopIndEdges1)
            stopInd1 = 1:stopInd1(stopIndEdges1(1));
        end
        stopIndEdges2 = find(diff(stopInd2)>1);
        if ~isempty(stopIndEdges2)
            stopInd2 = stopInd2(stopIndEdges2(end)+1):length(Hlog);
        end
        fm = ff([stopInd1(end); passInd([1 end]); stopInd2(1)]);
        Rp_range(1) = min(Hlog(passInd));
        Rp_range(2) = max(Hlog(passInd));
        Rs = -max([Hlog([stopInd1(:); stopInd2(:)]); -Rs]);        
    case 4   % bandstop
        % define center of stopband as frequency where peak of minimum magnitude
        % occurs
        [peakInd,peaks] = fdutil('findpeaks',Hlog);
        [Hmin,ind] = min(peaks);
        centerInd = peakInd(ind);        
        
        if isempty(passInd)
            passInd = [1 2 length(Hlog)+[-1 0]]';
            Rp_range = [min(Hlog(passInd)) max(Hlog(passInd))];
        end
        
        if isempty(stopInd)
            stopInd = centerInd + [-1 0]';
            Rs = -Hmin;
        end

        stopIndEdges = find(diff(stopInd)>1);
        if ~isempty(stopIndEdges)
            % reduce passband to region that includes centerInd
            stopIndEdges = [stopIndEdges(:)'; stopIndEdges(:)'+1];
            stopIndEdges = [1; stopIndEdges(:); length(stopInd)];
            ii = find(centerInd>stopInd(stopIndEdges(1:2:end)) & ...
                      centerInd<=stopInd(stopIndEdges(2:2:end)));
            if isempty(ii)   % current stopband does not include centerInd -
                             % need to make sure it does
                Rs = -Hmin;  
                stopInd = find(Hlog<=-Rs);
                stopIndEdges = find(diff(stopInd)>1);
                if ~isempty(stopIndEdges)
                    % reduce stopband to region that includes centerInd
                    stopIndEdges = [stopIndEdges(:)'; stopIndEdges(:)'+1];
                    stopIndEdges = [1; stopIndEdges(:); length(stopInd)];
                    ii = find(centerInd>stopInd(stopIndEdges(1:2:end)) & ...
                              centerInd<=stopInd(stopIndEdges(2:2:end)));
                    stopInd = stopInd(stopIndEdges(2*ii-1):stopIndEdges(2*ii));
                end
            else
                stopInd = stopInd(stopIndEdges(2*ii-1):stopIndEdges(2*ii));
            end
        end
        
        i = min(find(passInd>=centerInd));
        if isempty(i) % no upper passband!
            passInd = [passInd; length(Hlog)+[-1 0]'];
            Rp_range = [min(Hlog(passInd)) max(Hlog(passInd))];
            i = length(passInd)-1;
        elseif i==1  % no lower passband!
            stopInd = [1; 2; stopInd];
            Rp_range = [min(Hlog(passInd)) max(Hlog(passInd))];
            i = 3;
        end
        passInd1 = passInd(1:i-1);
        passInd2 = passInd(i:end);
        passIndEdges1 = find(diff(passInd1)>1);
        if ~isempty(passIndEdges1)
            passInd1 = 1:passInd1(passIndEdges1(1));
        end
        passIndEdges2 = find(diff(passInd2)>1);
        if ~isempty(passIndEdges2)
            passInd2 = passInd2(passIndEdges2(end)+1):length(Hlog);
        end
        fm = ff([passInd1(end); stopInd([1 end]); passInd2(1)]);
        Rp_range(1) = min(Hlog(passInd));
        Rp_range(2) = max(Hlog(passInd));
        Rs = -max([Hlog(stopInd); -Rs]); 
    end

function fChangeMeas(i,type,Fs,Lresp,L1,L2,f1,f2,f3,f4,Rp,Rs)
%fChangeMeas - interactively track response when a frequency has changed
%  This function is meant to be called when the user
%     a) changes the f1,f2,f3, or f4 measurement
%  or b) drags the f1,f2,f3, f4 value
%  Xdata, Ydata, values of other frequencies and Rp and Rs are updated as
%  needed.
%  Inputs:
%    i - which frequency has just changed
%    type - band configuration (1 = lp, 2 = hp, 3 = bp, 4 = bs)
%    Fs - sampling frequency
%    Lresp, L1, L2 - fdline objects
%    f1,f2,f3,f4,Rp,Rs - fdmeas objects

    ff = Lresp.xdata;
    delf = ff(2)-ff(1);  % frequency spacing
    Hlog = Lresp.ydata;
    [maxpass,minpass,minstop] = getMagMeasurements(ff,Hlog,type,...
                                          f1.value,f2.value,f3.value,f4.value);
    switch type
    case 1 % lowpass
        if i == 1     % passband edge
            passbandChange = 1;
        else  % stopband edge
            passbandChange = 0;
        end
        Rp.value = maxpass-minpass;
        Rs.value = -minstop;
    case 2  % highpass
        if i == 1     % stopband edge
            passbandChange = 0;
        else  % passband edge
            passbandChange = 1;
        end
        Rp.value = maxpass-minpass;
        Rs.value = -minstop;
    case 3 % bandpass
        switch i
        case {1,4}     % stopband edge
            passbandChange = 0;
            stopIndex = 1 + (i==4);
            [dummy,passIndex] = max(maxpass-minpass);
        case {2,3}     % passband edge
            passbandChange = 1;
            [dummy,stopIndex] = max(minstop);
            passIndex = 1 + (i==3);
        end
        [fm,Rp_range,Rs_val] = ...
             getFreqMeasurements(passbandChange,ff,Hlog,type,...
                 [minpass(passIndex) maxpass(passIndex)],-minstop(stopIndex));
        if passbandChange
            if i == 3
                f2.value = fm(2);
            else
                f3.value = fm(3);
            end
        else
            if i == 4
                f1.value = fm(1);
            else
                f4.value = fm(4);
            end
        end
        minpass = Rp_range(1);
        maxpass = Rp_range(2);
        minstop = -Rs_val;
        if passbandChange
            Rp.value = diff(Rp_range);
        else
            Rs.value = Rs_val;
        end
    case 4 % bandstop
        switch i
        case {1,4}     % passband edge
            passbandChange = 1;
            [dummy,stopIndex] = max(minstop);
            passIndex = 1 + (i==4);
        case {2,3}     % stopband edge
            passbandChange = 0;
            [dummy,passIndex] = max(maxpass-minpass);
            stopIndex = 1 + (i==3);
        end
        [fm,Rp_range,Rs_val] = ...
             getFreqMeasurements(passbandChange,ff,Hlog,type,...
                 [minpass(passIndex) maxpass(passIndex)],-minstop(stopIndex));
        if ~passbandChange
            if i == 3
                f2.value = fm(2);
            else
                f3.value = fm(3);
            end
        else
            if i == 4
                f1.value = fm(1);
            else
                f4.value = fm(4);
            end
        end
        minpass = Rp_range(1);
        maxpass = Rp_range(2);
        minstop = -Rs_val;
        if passbandChange
            Rp.value = diff(Rp_range);
        else
            Rs.value = Rs_val;
        end
    end
    if type > 2
        fchange_ind = (i==(1:4)) * [1 4; 2 3; 2 3; 1 4];
    else
        fchange_ind = i;
    end
    updateLines(passbandChange,type,fchange_ind,f1,f2,f3,f4,Rp,Rs,Fs,[minpass maxpass])
    fdutil('pokeFilterMeasurements','fdkaiser',type,f1,f2,f3,f4,Rp,Rs,Fs)
    
function RChangeMeas(passbandChange,type,Fs,Lresp,L1,L2,f1,f2,f3,f4,Rp,Rs,...
                      Rp_range,RpInd)
%RChangeMeas - interactively track response when Rp or Rs has changed
%  This function is meant to be called when the user
%     a) changes the Rp or Rs measurement
%  or b) drags the Rp or Rs value
%  Xdata, Ydata, values of other frequencies and Rp and Rs are updated as
%  needed.
%  Inputs:
%    passbandChange - boolean == 1 for Rp, 0 for Rs, or vector [0 1] for
%          both Rp and Rs
%    type - band configuration (1 = lp, 2 = hp, 3 = bp, 4 = bs)
%    Fs - sampling frequency
%    Lresp, L1, L2 - fdline objects
%    f1,f2,f3,f4,Rp,Rs - fdmeas objects
%    Rp_range - two element range vector of Rp, for when dragging measurement
%        line
%    RpInd - when dragging passband measurement line, indicates which one:
%        1 ==> lower, 2 ==> upper

    ff = Lresp.xdata;
    delf = ff(2)-ff(1);  % frequency spacing
    Hlog = Lresp.ydata;
    Rp_val = get(Rp,'value');
    Rs_val = get(Rs,'value');
    
    if nargin < 13
        [fm,Rp_range,Rs_val1] = ...
                getFreqMeasurements(passbandChange,ff,Hlog,type,Rp_val,Rs_val);
    else
        [fm,Rp_range,Rs_val1] = ...
                getFreqMeasurements(1,ff,Hlog,type,Rp_range,Rs_val,RpInd); 
    end
    Rp_val1 = diff(Rp_range);
    if Rp_val1 ~= Rp_val
        set(Rp,'value',Rp_val1);
    end
    if Rs_val1 ~= Rs_val
        set(Rs,'value',Rs_val1);
    end
    i = [];  % which frequencies have changed
    switch type
    case 1
        if any(passbandChange==1)
            f1.value = fm(1);
            i = 1;
        end
        if any(passbandChange==0)
            f2.value = fm(2);
            i = [i 2];
        end
    case 2
        if any(passbandChange==1)
            f2.value = fm(2);
            i = 2;
        end
        if any(passbandChange==0)
            f1.value = fm(1);
            i = [1 i];
        end
    case 3 % bandpass - update f2 f3
        if any(passbandChange==1)
            f2.value = fm(2);
            f3.value = fm(3);
            i = [2 3];
        end
        if any(passbandChange==0)
            f1.value = fm(1);
            f4.value = fm(4);
            i = [1 i 4];
        end
    case 4 % bandstop - update f1 f4
        if any(passbandChange==1)
            f1.value = fm(1);
            f4.value = fm(4);
            i = [1 4];
        end
        if any(passbandChange==0)
            f2.value = fm(2);
            f3.value = fm(3);
            i = sort([i 2 3]);
        end
    end
    updateLines(passbandChange,type,i,f1,f2,f3,f4,Rp,Rs,Fs,Rp_range)
    fdutil('pokeFilterMeasurements','fdkaiser',type,f1,f2,f3,f4,Rp,Rs,Fs)
    
function updateLines(passbandChange,type,fchange_ind,f1,f2,f3,f4,Rp,Rs,Fs,Rp_range)
% assume values of f1,f2,f3,f4,Rp and Rs are correct now
% fchange_ind - vector of indices indicating which frequencies have
%               changed
    global L1 L2 ax
    
    f = getFrequencyValues(type,f1,f2,f3,f4,Fs)*Fs/2;
    
    if any(passbandChange==1)
        if nargin < 11
            Rp_range = passbandlimits(Rp.value);
        end
        minpass = Rp_range(1);
        maxpass = Rp_range(2);
        % update L1 xdata and ydata
        switch type
        case 1   % lowpass
            set(L1,'xdata',[f(1:2) NaN f(1:2)],...
                   'ydata',[maxpass maxpass NaN minpass minpass])
        case 2   % highpass
            set(L1,'xdata',[f(3:4) NaN f(3:4)],...
                   'ydata',[maxpass maxpass NaN minpass minpass ])
        case 3   % bandpass
            set(L1,'xdata',[f(3:4) NaN f(3:4)],...
                   'ydata',[maxpass maxpass NaN minpass minpass])
        case 4   % bandstop
            set(L1,'xdata',[f(1:2) NaN f(1:2) NaN f(5:6) NaN f(5:6)],...
                   'ydata',[ maxpass maxpass NaN minpass minpass NaN ...
                             maxpass maxpass NaN minpass minpass])
        end
        ylim = [minpass maxpass];
        dyl = (ylim(2)-ylim(1))*.15;
        ax.ylimPassband = ylim + [-dyl/2 dyl/2];
        if length(f)==4
            f(6)=0;  % zeropad for call to xlimpassband
        end
        ax.xlimPassband = fdutil('xlimpassband',type,...
                             Fs,f(2),f(3),f(4),f(5));
    end
    if any(passbandChange==0)
        minstop = -Rs.value;
        % update L2 xdata and ydata
        switch type
        case 1   % lowpass
            set(L2,'xdata',[f(3:4)],'ydata',[minstop minstop])
        case 2   % highpass
            set(L2,'xdata',[f(1:2)],'ydata',[ minstop minstop])
        case 3   % bandpass
            set(L2,'xdata',[f(1:2) NaN f(5:6)],...
                   'ydata',[ minstop minstop NaN minstop minstop])
        case 4   % bandstop
            set(L2,'xdata',[f(3:4)],'ydata',[minstop minstop])
        end
    end
%     fdutil('updateRanges',fchange_ind,f1,f2,f3,f4)
    set(f1,'range',[0 Fs/2])
    set(f2,'range',[0 Fs/2])
    set(f3,'range',[0 Fs/2])
    set(f4,'range',[0 Fs/2])
    
function [f1,f2,f3,f4] = setupFrequencyObjects(type,module,pbobjects,...
                   sbobjects,f,Fs,ax,setValueFlag)

    if nargin<8
        setValueFlag = 1;
    end
    
    fdutil('changeToEdit',[pbobjects(1:2); sbobjects(1:2)])
    
    switch type
    case 1 % lowpass
        f1 = pbobjects(1);
        f2 = sbobjects(1);
        f3 = sbobjects(2);
        f4 = pbobjects(2);
        pbobjects(2).visible = 'off';
        sbobjects(2).visible = 'off';
        set(f1,'label','Fp')
        set(f2,'label','Fs')
    case 2 % highpass
        f1 = sbobjects(1);
        f2 = pbobjects(1);
        f3 = pbobjects(2);
        f4 = sbobjects(2);
        pbobjects(2).visible = 'off';
        sbobjects(2).visible = 'off';
        set(f1,'label','Fs')
        set(f2,'label','Fp')
    case 3 % bandpass
        f1 = sbobjects(1);
        f2 = pbobjects(1);
        f3 = pbobjects(2);
        f4 = sbobjects(2);
        pbobjects(2).visible = 'on';
        sbobjects(2).visible = 'on';
        set(f1,'label','Fs1')
        set(f2,'label','Fp1')
        set(f3,'label','Fp2')
        set(f4,'label','Fs2')
    case 4
        f1 = pbobjects(1);
        f2 = sbobjects(1);
        f3 = sbobjects(2);
        f4 = pbobjects(2);
        pbobjects(2).visible = 'on';
        sbobjects(2).visible = 'on';
        set(f1,'label','Fp1')
        set(f2,'label','Fs1')
        set(f3,'label','Fs2')
        set(f4,'label','Fp2')
    end
    if setValueFlag
        if type < 3
            set(f1,'value',f(2)*Fs/2,'range',[0 f(3)]*Fs/2)
            set(f2,'value',f(3)*Fs/2,'range',[f(2) 1]*Fs/2)
        else
            set(f1,'value',f(2)*Fs/2,'range',[0 f(3)*Fs/2])
            set(f2,'value',f(3)*Fs/2,'range',[f(2) f(4)]*Fs/2)
            set(f3,'value',f(4)*Fs/2,'range',[f(3) f(5)]*Fs/2)
            set(f4,'value',f(5)*Fs/2,'range',[f(4) 1]*Fs/2)
        end
        ax.xlimPassband = fdutil('xlimpassband',type,...
                             Fs,f1.value,f2.value,f3.value,f4.value);
    end

    f1.callback = [module '(''fchange'',1)'];
    f2.callback = [module '(''fchange'',2)'];
    f3.callback = [module '(''fchange'',3)'];
    f4.callback = [module '(''fchange'',4)'];

function [Rp,Rs,f1,f2,f3,f4] = ...
      setupMeasurementObjects(specStruc,Fs,order,order1,passframe1,stopframe1,ax,...
                     pbmeasures,sbmeasures,Rp,Rs,...
                     Wn1m,Wn2m,Betam,Rpm,Rsm,f1,f2,f3,f4)
%  set values of MEASUREMENTS objects ... assumes specStruct is current

    setOrderFlag = specStruc.setOrderFlag;
    type = specStruc.type;
    f = specStruc.f;
    Rpass = specStruc.Rp;
    Rstop = specStruc.Rs;
    Wn = specStruc.Wn;
    N = specStruc.order;
    beta_val = specStruc.Beta;
    
    if ~setOrderFlag  % estimate order

        set(order1,'visible','on')

        set(passframe1,'visible','off')
        set(stopframe1,'visible','off')
        
        fdutil('changeToText',[Rpm Rsm Wn1m Wn2m Betam])
        set(sbmeasures(3),'visible','off')
        
        set(Rpm,'visible','on','label','Actual Rp')
        set(Rsm,'visible','on','label','Actual Rs')
        set(Betam,'visible','on','label','Beta','value',beta_val)
        
        set(Wn1m,'visible','on','value',Wn(1)*Fs/2,...
            'format','%1.4g')
        if type > 2
            set(Wn1m,'label','Fc1')
            set(Wn2m,'visible','on','value',Wn(2)*Fs/2,...
                'format','%1.4g','label','Fc2')
        else
            set(Wn1m,'label','Fc')
            set(Wn2m,'visible','off')
        end

        order.value = N;
        
    else
        set(order1,'visible','off')
    
        set(passframe1,'visible','on')
        set(stopframe1,'visible','on')
        
        fdutil('changeToEdit',[pbmeasures(1:3) sbmeasures(1:3)])

        pbmeasures(1).visible = 'on';
        sbmeasures(1).visible = 'on';

        [f1,f2,f3,f4] = setupFrequencyObjects(type,'fdkaiser',pbmeasures,...
                                     sbmeasures,f,Fs,ax,0);
                                             
        Rp = pbmeasures(3);        
        Rs = sbmeasures(3);        
        set(Rp,'value',Rpass,'label','Rp',...
            'visible','on','callback','fdkaiser(''Rpchange'')')
        set(Rs,'value',Rstop,'label','Rs',...
            'visible','on','callback','fdkaiser(''Rschange'')')
    
    end


function [Rp,Rs,f1,f2,f3,f4,specStruc] = ...
      measureFilt(objSetupFlag,specStruc,Fs,order,order1,passframe1,stopframe1,ax,...
                  pbmeasures,sbmeasures,Rp,Rs,Wn1m,Wn2m,Betam,Rpm,Rsm,f1,f2,f3,f4,...
                  ff,Hlog,L1,L2)

    if objSetupFlag
        [Rp,Rs,f1,f2,f3,f4] = ...
          setupMeasurementObjects(specStruc,Fs,order,order1,passframe1,stopframe1,ax,...
                     pbmeasures,sbmeasures,Rp,Rs,...
                     Wn1m,Wn2m,Betam,Rpm,Rsm,f1,f2,f3,f4);
    end

    n = specStruc.order;
    f = specStruc.f;
    setOrderFlag = specStruc.setOrderFlag;
    Wn = specStruc.Wn;
    beta_val = specStruc.Beta;
    
    for i=1:3
        set(pbmeasures(i),'enable','on')
        set(sbmeasures(i),'enable','on')
    end
    set(order1,'enable','on')
    
    set(f1,'range',[0 Fs/2])
    set(f2,'range',[0 Fs/2])
    set(f3,'range',[0 Fs/2])
    set(f4,'range',[0 Fs/2])

    if ~setOrderFlag
        order.value = n;
        Wn1m.value = Wn(1) * Fs/2;
        if length(Wn)>1
            Wn2m.value = Wn(2) * Fs/2;
        end
        [maxpass,minpass,minstop] = getMagMeasurements(ff,Hlog,specStruc.type,...
                                          f1.value,f2.value,f3.value,f4.value);
        set(Betam,'value',beta_val)
        set(Rpm,'value',max(maxpass - minpass))
        set(Rsm,'value',-max(minstop))
        yd = passbandlimits(Rp.value);
        maxpass = yd(2);
        minpass = yd(1);
        minstop = -Rs.value;
    else
        [fm,Rp_range,Rs_val] = ...
             getFreqMeasurements(1,ff,Hlog,specStruc.type,Rp.value,Rs.value);
        f1.value = fm(1);  f2.value = fm(2);
        if length(fm)>2
            f3.value = fm(3);  f4.value = fm(4);
        end
        Rp.value = diff(Rp_range);
        maxpass = Rp_range(2);   minpass = Rp_range(1);   minstop = -Rs_val;
        Rs.value = Rs_val;
        f = [0 fm(:)' Fs/2 0];  % for updating L1 and L2 later;
                                % extra zero is for call to xlimpassband when
                                % type == 1 or 2
        ax.xlimPassband = fdutil('xlimpassband',specStruc.type,...
                             Fs,f(2),f(3),f(4),f(5));
        f = f*2/Fs;
        specStruc.f = f;    
    end
    ylim = [minpass maxpass];
    dyl = (ylim(2)-ylim(1))*.15;
    ax.ylimPassband = ylim + [-dyl/2 dyl/2];
    
    % update L1 and L2 xdata and ydata, pointers, dragmodes
    % note - can't drag upper passband measurement for bandpass
    fdutil('setLines','fdkaiser',L1,L2,0,...
                      specStruc.type,f(:)',Fs,minpass,maxpass,minstop,...
                        ~(setOrderFlag & (specStruc.type==3)))


function f = getFrequencyValues(type,f1,f2,f3,f4,Fs);            
if type < 3  % low or high pass
    f = [0 f1.value f2.value Fs/2]*2/Fs;
else
    f = [0 f1.value f2.value f3.value f4.value Fs/2]*2/Fs;
end


function [setOrderFlag_init, type_init, f_init, Rp_init, Rs_init, ...
         order_init, Wn_init, Beta_init] = initSpecs(filt)
%initSpecs   Initial specifications for kaiser filter, from
%            filt input
%Switches off of filt.currentModule and if it finds any of
% fdcheby1, fdcheby2, fdellip, fdremez, fdfirls, or fdbutter
% retains the type, order, band edge, and any other relevant
% parameters

    % first define default values
    setOrderFlag_init = 0;   % by default, estimate order 
    type_init = 1;  % 1=lowpass, 2=highpass, 3=bandpass, 4=bandstop
    f_init = [0 .1 .15 1];
    Rp_init = 3;
    Rs_init = 20;
    order_init = 30;
    Wn_init = .225;
    Beta_init = 5;
    if strcmp(filt.specs.currentModule,'fdpzedit')
        if isfield(filt.specs.fdpzedit,'oldModule')
            filt.specs.currentModule = filt.specs.fdpzedit.oldModule;
        end
    end
    switch filt.specs.currentModule
    case {'fdcheby1','fdcheby2','fdellip','fdremez','fdbutter','fdfirls'}
        s = eval(['filt.specs.' filt.specs.currentModule]);
        setOrderFlag_init = s.setOrderFlag;
        type_init = s.type;
        f_init = s.f;
        Rp_init = s.Rp;
        Rs_init = s.Rs;
        order_init = s.order;
        switch filt.specs.currentModule
        case 'fdcheby1'
            Wn_init = s.Fpass;
        case 'fdcheby2'
            Wn_init = s.Fstop;
        case 'fdellip'
            Wn_init = s.Fpass;
        case {'fdremez','fdfirls'}
            switch s.type
            case {1,2}
                Wn_init = s.f(2);
            case 3
                Wn_init = s.f(3:4);
            case 4
                Wn_init = s.f([2 5]);
            end            
        case 'fdbutter'
            Wn_init = s.w3db;
        end
        if any(strcmp(filt.specs.currentModule,...
                 {'fdbutter','fdcheby1','fdcheby2','fdellip'}))
            order_init = ceil(order_init*10); 
             %  FIR filters are much higher order than IIR
        end
        if isfield(filt.specs,'fdkaiser')
            Beta_init = filt.specs.fdkaiser.Beta;
        end
    case 'fdkaiser'
        if isfield(filt.specs,'fdkaiser')
            setOrderFlag_init = filt.specs.fdkaiser.setOrderFlag;
            type_init = filt.specs.fdkaiser.type;
            f_init = filt.specs.fdkaiser.f;
            Rp_init = filt.specs.fdkaiser.Rp;
            Rs_init = filt.specs.fdkaiser.Rs;
            order_init = filt.specs.fdkaiser.order;
            Wn_init = filt.specs.fdkaiser.Wn;
            Beta_init = filt.specs.fdkaiser.Beta;
        end
    end

