function varargout = fdcheby1(varargin)
%fdcheby1  Chebyshev Type I Module for filtdes.

%   Author: T. Krauss
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.10.4.2 $

% Change this global to static when available:
%  following are common to several modules
global minOrdCheckbox bandpop order pbspecs sbspecs pbmeasures sbmeasures
global passframe stopframe passframe1 stopframe1
%  following static to fdcheby1
global f1 f2 f3 f4 Fp1 Fp2 Rp Rs 
global Fs1m Fs2m 
global order0 order1
global ax L1 L2 Lresp L3_1 L3_2
global Fs

switch varargin{1}
case 'init'

    filt = varargin{2};
    Fs = filt.Fs;
    [setOrderFlag_init, type_init, f_init, Rp_init, Rs_init, ...
      order_init, Fpass_init] = initSpecs(filt);

    [minOrdCheckbox bandpop order pbspecs sbspecs ...
         pbmeasures sbmeasures passframe stopframe ...
         passframe1 stopframe1 ax Lresp L1 L2 order1 ...
         L3_1 L3_2] = fdutil('commonObjects');
    order0 = order;

    co = get(0,'defaultaxescolororder');
    lo = get(0,'defaultaxeslinestyleorder');

    if ~strcmp(bandpop.userdata,'fdcheby1')
       % this module is not current
        bandpop.userdata = 'fdcheby1';
            
        minOrdCheckbox.callback = 'fdcheby1(''checkbox'')';
        bandpop.callback = 'fdcheby1(''newtype'')';         

        order0.callback = 'fdcheby1(''dirty'')';
                        
        set(ax,'title', xlate('Frequency Response'),...
              'xlabel',xlate('Frequency'),...
              'ylabel',xlate('Magnitude (dB)'),...
              'ylim',[-150 10],'xlim',[0 Fs/2],...
              'xlimbound',[0 Fs/2]);

        sethelp
        
        set(Lresp,'buttondownfcn','fdcheby1(''LrespDown'')')
                       
        set(L1,'buttondownfcn','fdcheby1(''L1down'')',...
               'buttonupfcn','fdcheby1(''L1up'')',...
               'color',co(min(2,size(co,1)),:))
        set(L2,'buttondownfcn','fdcheby1(''L2down'')',...
               'buttonupfcn','fdcheby1(''L2up'')',...
               'color',co(min(2,size(co,1)),:))
        set(L3_1,'xdata',Fpass_init([1 1]),...
                 'segmentdragcallback',{'fdcheby1(''L3_drag'',1)'},...
                 'buttondownfcn','fdcheby1(''L3_down'',1)',...
                 'buttonupfcn','fdcheby1(''L1up'')');
        set(L3_2,'xdata',Fpass_init([end end]),...
                 'segmentdragcallback',{'fdcheby1(''L3_drag'',2)'},...
                 'buttondownfcn','fdcheby1(''L3_down'',2)',...
                 'buttonupfcn','fdcheby1(''L1up'')');
        Rp = pbspecs(3);
        set(Rp,'value',Rp_init,'label','Rp')
        Rs = sbspecs(3);
        set(Rs,'value',Rs_init,'label','Rs')
        set(Rp,'callback','fdcheby1(''Rpchange'')')
        set(Rs,'callback','fdcheby1(''Rschange'')')
        Fp1 = pbspecs(1);
        Fp2 = pbspecs(2);
        Fs1m = sbmeasures(1);
        Fs2m = sbmeasures(2);
        % fdutil('changeToEdit',pbmeasures(1:3))
        fdutil('changeToText',[Fs1m Fs2m])
    end
    set(minOrdCheckbox,'visible','on','enable','on')
    set(Rp,'visible','on')
    set(Rs,'visible','on')
    set(sbmeasures(1),'visible','on')
    set(pbmeasures(1),'visible','off')
    set(pbmeasures(2),'visible','off')
    set(pbmeasures(3),'visible','off')
    set(sbmeasures(3),'visible','off')
        
    fdcheby1('newfilt',setOrderFlag_init,type_init,f_init,Rp_init,...
               Rs_init,Fpass_init,order_init)

    if setOrderFlag_init
    % set these fields since 'Apply' gets them from the specifications struc
    % to make the measurements
        filt.specs.fdcheby1.Rs = Rs_init;
    end

    [filt, errstr] = fdutil('callModuleApply',...
                               'fdcheby1',filt,'');
    varargout{1} = filt;
    varargout{2} = errstr;

case 'apply'    
    
    filt = varargin{2};
    msg = varargin{3};
    if strcmp(msg,'motion') | strcmp(msg,'up')
        inputLine = varargin{4};
        if ~minOrdCheckbox.value & isequal(inputLine,L2)
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
        [n,Fpass] = estimateOrder(type,Rp.value,Rs.value,Fs,...
                 f1.value,f2.value,f3.value,f4.value);
    else
        n = order.value;
        Fpass = Fp1.value * 2/Fs;
        if type > 2  % pass/stop
            Fpass(2) = Fp2.value * 2/Fs;
        end
    end
    
    % save specifications in specifications structure:
    specstruc.setOrderFlag = setOrderFlag;
    specstruc.type = type;
    if ~setOrderFlag
        f = getFrequencyValues(type,f1,f2,f3,f4,Fs);
        specstruc.f = f;
        specstruc.Rs = Rs.value;
    else
        specstruc.f = [];  % place holder, will be defined by measureFilt
        specstruc.Rs = filt.specs.fdcheby1.Rs;
    end
    specstruc.Rp = Rp.value;
    specstruc.Fpass = Fpass;
    if specstruc.type > 2
    % cheby1(N,...) returns a 2N order filter for bandpass and bandstop filter
        specstruc.order = 2*n;
    else
        specstruc.order = n;
    end
                          
%     if ~setOrderFlag & isfield(filt.specs,'fdcheby1') & ...
%         isequal(specstruc.Fpass,filt.specs.fdcheby1.Fpass) ...
%         & isequal(specstruc.order,filt.specs.fdcheby1.order)
%         filt.specs.fdcheby1 = specstruc;
%         varargout{1} = filt;
%         varargout{2} = '';
%         return
%     end

    if n>50
        [continueFlag,errstr] = fdutil('largeWarning',n,msg);
        if ~continueFlag
            varargout{1} = filt;
            varargout{2} = errstr;
            return
        end
    end
        
    % design filter:
    if type == 2
        [b,a] = cheby1(n,specstruc.Rp,Fpass,'high');
    elseif type == 4
        [b,a] = cheby1(n,specstruc.Rp,Fpass,'stop');
    else
        [b,a] = cheby1(n,specstruc.Rp,Fpass);
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
       (~setOrderFlag & (filt.specs.fdcheby1.type ~= type))
        objSetupFlag = 1;
    else
        objSetupFlag = 0;
    end
    
    [Rp,Rs,f1,f2,f3,f4,specstruc] = ...
      measureFilt(objSetupFlag,specstruc,Fs,order,order1,stopframe1,ax,...
                  pbmeasures,sbmeasures,pbspecs,sbspecs,Rp,Rs,Fs1m,Fs2m,f1,f2,f3,f4,...
                  ff,Hlog,L1,L2);
    %specstruc = measureFilt(objSetupFlag,specstruc,Fs,order1,...
    %              sbmeasures,Fs1m,Fs2m,ff,Hlog,L1,L2,ax);
                      
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
    filt.specs.fdcheby1 = specstruc;
    filt.zpk = [];  % clear out in case filtview has written these
    filt.ss = [];
    filt.sos = [];
    filt.type = 'design';

    varargout{1} = filt;
    varargout{2} = '';
        
case 'revert'
    filt = filtdes('filt');
    oldtype = filt.specs.fdcheby1.type;
    % need to restore filter type
    setOrderFlag = filt.specs.fdcheby1.setOrderFlag;
    oldSetOrderFlag = ~minOrdCheckbox.value;
    f = filt.specs.fdcheby1.f;
    Rpass = filt.specs.fdcheby1.Rp;
    Rstop = filt.specs.fdcheby1.Rs;
    Fpass = filt.specs.fdcheby1.Fpass;
    N = filt.specs.fdcheby1.order;
    fdcheby1('newfilt',setOrderFlag,oldtype,f,Rpass,Rstop,Fpass,N)

%    [Rp,Rs,f1,f2,f3,f4,specStruc] = ...
%      measureFilt(objSetupFlag,specstruc,Fs,order,order1,stopframe1,ax,...
%                  pbmeasures,sbmeasures,pbspecs,sbspecs,Rp,Rs,Fs1m,Fs2m,...
%                  f1,f2,f3,f4,ff,Hlog,L1,L2);

%    specStruc = measureFilt(1,filt.specs.fdcheby1,Fs,order1,...
%                  sbmeasures,Fs1m,Fs2m,Lresp.xdata,Lresp.ydata,L1,L2,ax);

    [Rp,Rs,f1,f2,f3,f4,specStruc] = ...
       measureFilt(1,...
                  filt.specs.fdcheby1,Fs,order,order1,stopframe1,ax,...
                  pbmeasures,sbmeasures,pbspecs,sbspecs,Rp,Rs,Fs1m,Fs2m,...
                  f1,f2,f3,f4,Lresp.xdata,Lresp.ydata,L1,L2);

    Lresp.linestyle = '-';
    L1.linestyle = '-';
    L2.linestyle = '-';
    set(L3_1,'linestyle','-')
    set(L3_2,'linestyle','-')
    
    for i=1:2
        set(sbmeasures(i),'enable','on')
    end
    set(order1,'enable','on')
    
case 'help'
    str = fdhelpstr('fdcheby1');
    varargout{1} = str{2};

case 'description'
    varargout{1} = 'Chebyshev Type I IIR';

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
    
    if ~filt.specs.fdcheby1.setOrderFlag
        Fs1m.value = Fs1m.value*Fs/oldFs;
        Fs2m.value = Fs2m.value*Fs/oldFs;
    end
    
%---------------------------------------------------------------------
% -------- following cases are module specific --------- 
%---------------------------------------------------------------------

case 'dirty'
% fdcheby1('dirty')
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
        set(sbmeasures(i),'enable','off')
    end
    set(order1,'enable','off')

%---------------------------------------------------------------------
% fdcheby1('clean')
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
        set(sbmeasures(i),'enable','on')
    end
    set(order1,'enable','on')
    filtdes('setenable','off')
    
%---------------------------------------------------------------------
% fdcheby1('fchange',i)
%    Callback when frequency i has changed
%    Need to update ranges and lines L1, L2
case 'fchange'
    type = bandpop.value;
    if nargin == 1
    % a passband freq spec has changed  (we are in set mode)
        if type >= 3
            Fpass = [Fp1.value Fp2.value];
            if Fpass(1) >= Fpass(2)
                FpassOld = [L3_1.xdata(1) L3_2.xdata(1)];
                i = find(Fpass~=FpassOld);  % index of changed band edge
                if i == 1
                    Fpass(2) = (Fpass(1)+Fs/2)/2;
                    set(Fp2,'value',Fpass(2))
                else
                    Fpass(1) = Fpass(2)/2;
                    set(Fp1,'value',Fpass(1))
                end
            end
            set(L3_1,'xdata',Fpass([1 1]))
            set(L3_2,'xdata',Fpass([2 2]))
        else
            Fpass = Fp1.value;
            set(L3_1,'xdata',Fpass([1 1]))
        end
        
        fdcheby1('dirty')
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
    
    if ~minOrdCheckbox.value   % set order
        passbandChange = ...
          (type==(1:4))*[1 0 0 0; 0 1 0 0;...
                 0 1 1 0; 1 0 0 1 ]*(i==(1:4))';
        if ~passbandChange
            fChangeMeas(i,type,Fs,Lresp,L1,L2,f1,f2,f3,f4,Rp,Rs)
            return
        end
        L3_1.xdata = Fp1.value([1 1]);
        if type>2
            L3_2.xdata = Fp2.value([1 1]);
        end
    else
        [xd1,xd2] = fdutil('validateBands',xd1,xd2,...
                           type,i,f,f1,f2,f3,f4,Fs);
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

    if dirty  % Specs changed; update passband limits; show dotted lines
        ax.xlimPassband = fdutil('xlimpassband',type,...
                         Fs,f1.value,f2.value,f3.value,f4.value);
        fdcheby1('dirty')
   end
  
%---------------------------------------------------------------------
% fdcheby1('Rpchange')
%  Callback when Rp has changed
%  Need to update line L1
case 'Rpchange'
    type = bandpop.value;
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
    
    fdcheby1('dirty')

    
%---------------------------------------------------------------------
% fdcheby1('Rschange')
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
        fdcheby1('dirty')
    else
        RChangeMeas(0,type,Fs,Lresp,L1,L2,f1,f2,f3,f4,Rp,Rs)
    end

%---------------------------------------------------------------------
% fdcheby1('checkbox')
%  Callback of minimum order checkbox
case 'checkbox'
    filt = filtdes('filt');
    
    newSetOrderFlag = ~get(minOrdCheckbox,'value');
    type = bandpop.value;
    oldtype = filt.specs.fdcheby1.type;
    if ~newSetOrderFlag   % from set to estimate order 
        if filt.specs.fdcheby1.setOrderFlag
            % obtain frequencies from measurements
            c = {pbspecs(1) pbspecs(2) sbmeasures(1) sbmeasures(2)};
            if (type==2) | (type==3)
                ind = [3 1 2 4];
            else
                ind = [1 3 4 2];
            end
            f = getFrequencyValues(oldtype,c{ind},Fs);
        else
            % obtain frequencies from filter specs field
            f = filt.specs.fdcheby1.f;
        end
        f = filt.specs.fdcheby1.f;
        f = [0; fdutil('changeFilterType',type,oldtype,sort(f(2:end-1))); 1];
        Fpass = [0 0];  % place holder - ignored by 'newfilt'     
    else   % from estimate to set order 
        Fpass = Fp1.value * 2/Fs;
        if type > 2
            if oldtype > 2
                Fpass(2) = Fp2.value * 2/Fs;
            else
                Fpass(2) = (Fpass(1)+1)/2;
            end
        end
        f = [];  % place holder - ignored by 'newfilt'
    end
    
    fdcheby1('newfilt',newSetOrderFlag,...
                       type,f,Rp.value,...
                       Rs.value,Fpass,order.value)
    fdcheby1('dirty')

%---------------------------------------------------------------------
% fdcheby1('newfilt',setOrderFlag,type,f,Rp,Rs,Fpass,order)
%  set values of SPECIFICATIONS objects ...  DOES NOT DESIGN FILTER
case 'newfilt'
    setOrderFlag = varargin{2};
    type = varargin{3};
    f = varargin{4};     % in range (0,1)
    Rpass = varargin{5};
    Rstop = varargin{6};
    Fpass = varargin{7};  % in range (0,1)
    N = varargin{8};
    
    bandpop.value = type;
    % save last value of bandpop in passframe userdata:
    passframe.userdata = type;
    minOrdCheckbox.value = ~setOrderFlag;
    
    co = get(0,'defaultaxescolororder');

    if ~setOrderFlag  % estimate order
        % initialize specs:
        order = order1;
        set(order0,'visible','off')

        [f1,f2,f3,f4] = setupFrequencyObjects(type,'fdcheby1',...
                           pbspecs,sbspecs,f,Fs,ax);
        
        pbspecs(1).visible = 'on';
        pbspecs(3).visible = 'on';
        sbspecs(1).visible = 'on';
        sbspecs(3).visible = 'on';
                
        Rp = pbspecs(3);
        Rs = sbspecs(3);
        set(Rp,'value',Rpass)
        set(Rs,'value',Rstop)
        set(L2,'color',co(min(2,size(co,1)),:))
        set(L3_1,'visible','off')     
        set(L3_2,'visible','off')     
    else  % set order
        order = order0;
        set(order0,'visible','on')
        
        set(sbspecs(1),'visible','off')
        set(sbspecs(2),'visible','off')
        set(sbspecs(3),'visible','off')
        
        set(L2,'color',co(min(3,size(co,1)),:))
        set(L3_1,'visible','on','xdata',Fpass([1 1])*Fs/2)     
        if type < 3  % low/high
            set(Fp1,'value',Fpass(1)*Fs/2,'range',[0 1]*Fs/2,...
               'label','Fp','callback','fdcheby1(''fchange'')',...
               'visible','on')
            Fp2.visible = 'off';
            set(L3_2,'visible','off')
        else  % pass/stop
            set(Fp1,'value',Fpass(1)*Fs/2,'range',[0 Fpass(2)]*Fs/2,...
               'label','Fp1','callback','fdcheby1(''fchange'')',...
               'visible','on')
            set(Fp2,'value',Fpass(2)*Fs/2,'range',[Fpass(1) 1]*Fs/2,...
               'label','Fp2','callback','fdcheby1(''fchange'')',...
               'visible','on')
            set(L3_2,'visible','on','xdata',Fpass([2 2])*Fs/2)     
        end
        order.value = N;
    end

    if ax.xlimbound(2) ~= Fs/2
        set(ax,'xlimbound',[0 Fs/2],'xlim',[0 Fs/2])
    end
    
    if ~setOrderFlag  % estimate order
        minpass = -Rpass;
        maxpass = 0;
        minstop = -Rstop;
        fdutil('setLines','fdcheby1',...
            L1,L2,0,type,f(:)',Fs,minpass,maxpass,minstop)
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
% fdcheby1('newtype')
%  callback of band configuration popup
case 'newtype'
    filt = filtdes('filt');
    newtype = bandpop.value;
    oldtype = get(passframe,'userdata');
    if isempty(oldtype)
        oldtype = filt.specs.fdcheby1.type;
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
            Fpass = Fp1.value * 2/Fs;
            if newtype > 2
                Fpass(2) = Fp2.value * 2/Fs;
                if Fpass(2) <= Fpass(1) | Fpass(2)>1
                    Fpass(2) = (Fpass(1) + 1)/2;
                    Fp2.value = Fpass(2)*Fs/2;
                end
            end
        else
            Fpass = [0 0]; % place holder - ignored by newfilt
        end
        fdcheby1('newfilt',~minOrdCheckbox.value,newtype,f,Rp.value,...
                  Rs.value,Fpass,order.value)
        fdcheby1('dirty')
        
    else
       % disp('no change of type')
    end
    
%---------------------------------------------------------------------
% fdcheby1('Lrespdown')
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
% fdcheby1('L1down')
%  Button down fcn of L1
% fdcheby1('L2down')
%  Button down fcn of L2
% fdcheby1('L3_down',i)
%   buttondown fcn of stopband edge line 1 or 2 (i==1 or 2)
case {'L1down', 'L2down', 'L3_down'}
    L1.erasemode = 'xor';
    L2.erasemode = 'xor';
        
%---------------------------------------------------------------------
% fdcheby1('L1up')
%  Button up fcn of L1
% fdcheby1('L2up')
%  Button up fcn of L2
case {'L1up', 'L2up'}
    L1.erasemode = 'normal';
    L2.erasemode = 'normal';
    Lresp.erasemode = 'normal';
    
%---------------------------------------------------------------------
% fdcheby1('L3_drag',ind)
%  segment drag callback of L3_1 and L3_2 - stopband edge frequency lines
%  Inputs:
%     ind - index of line being dragged, 1 or 2
case 'L3_drag'
    ind = varargin{2};
    minspacing = Fs/500;
    if ind == 1
        xd = L3_1.xdata;
        newFpass1 = inbounds(xd(1),[minspacing Fp1.range(2)-minspacing]);
        if newFpass1 ~= Fp1.value
            Fp1.value = newFpass1;
            Fp2.range = [newFpass1 Fs/2];
            if newFpass1 ~= xd(1)
                L3_1.xdata = newFpass1([1 1]);
            end
        end
    else
        xd = L3_2.xdata;
        newFpass2 = inbounds(xd(1),[Fp2.range(1)+minspacing Fs/2-minspacing]);
        if newFpass2 ~= Fp2.value
            Fp2.value = newFpass2;
            Fp1.range = [0 newFpass2];
            if newFpass2 ~= xd(1)
                L3_2.xdata = newFpass2([1 1]);
            end
        end
    end

%---------------------------------------------------------------------
% fdcheby1('L1drag',type,ind)
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
    ax.xlimPassband = fdutil('xlimpassband',type,...
                         Fs,f1.value,f2.value,f3.value,f4.value);

%---------------------------------------------------------------------
% fdcheby1('L2drag',type,ind)
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
% fdcheby1('Rpdrag',type,ind)
%  drag callback of L1 - passband line
%  Inputs:
%     type - band configuration 1==low, 2=high, 3=pass, 4=stop
%     ind - index of segment being dragged
case 'Rpdrag'
    type = varargin{2};
    ind = varargin{3};
    yd = L1.ydata;
    
    below = yd(ind);
    if below >= 0 
        below = -.00001;
    elseif below < -10
        below = -10;
    end
    above = 0;
    
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
    Rp.value = newRp;
    ylim = [below above];
    dyl = (ylim(2)-ylim(1))*.15;
    ax.ylimPassband = ylim + [-dyl/2 dyl/2];
    
%---------------------------------------------------------------------
% fdcheby1('Rsdrag',type,ind)
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
global minOrdCheckbox bandpop 
global passframe stopframe passframe1 stopframe1
global f1 f2 f3 f4 Fp1 Fp2 order Rp Rm pbspecs sbspecs
global Fs1m Fs2m
global ax L1 L2 Lresp
global Fs

% disp('setting help ... stub')

function [n,Fpass] = estimateOrder(type,Rp,Rs,Fs,f1,f2,f3,f4)
% [n,Fpass] = estimateOrder(type,Rp,Rs,Fs,f1,f2,f3,f4)
%   estimate filter order
%   takes the specifications as given by the input
%   parameters and estimates the order and stopband edge frequencies
%   needed to meet those specifications.
% Inputs:
%  type - 1,2,3,4 specifies band configuration
%  Rp, Rs passband, stopband ripple
%  Fs - sampling frequency
%  f1,f2  first two frequencies in ascending order
%  f3,f4 only needed if type == 3 or 4, remaining frequencies
%    f1,f2,f3,f4 are assumed between 0 and Fs/2 on input
% Outputs:
%  n - filter order
%  Fpass - filter pass band edges for cheby1, normalized to range [0...1]

if type == 1    % low pass
    Wp = f1;   Ws = f2;
elseif type == 2   % high pass
    Wp = f2;   Ws = f1;
elseif type == 3   % band pass
    Wp = [f2 f3];   Ws = [f1 f4];
elseif type == 4   % band stop
    Wp = [f1 f4];   Ws = [f2 f3];
end
[n,Fpass] = cheb1ord(Wp*2/Fs,Ws*2/Fs,Rp,Rs);
Fpass = Fpass(:)';   % make it a row 
 

function yd = passbandlimits(Rp)
% return ydata = [minpass maxpass] of passband 
%   given Rp decibels of ripple in passband (with maximum 1 in linear scale)
    above = 0; below = -Rp;
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
%  fm - 2 or 4 element frequency vector in ascending order
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

function [Fstop,Rs] = getFreqMeasurements(ff,Hlog,type,Rp,Rs)
%getFreqMeasurements
% Finds stop band edges for cheby1 filter given passband and 
% stopband ripple and given a filter's magnitude response
% Inputs:
%  ff - xdata of response (assumed a column vector)
%  Hlog - magnitude of response at frequencies ff, in dB
%               (assumed a column vector)
%  type - band configuration (lp = 1, hp = 2, bp = 3, bs = 4)
%  Rp - passband ripple, in dB
%  Rs - stopband attenuation in dB
% Output:
%  Fstop - 1 or 2 element frequency (column) vector in ascending order
%  Rs - changed value of Rs in case given Rs is unattainable
    ff = ff(:);
    switch type
    case 1   % lowpass
        stopInd = find(Hlog(:)<=-Rs);
        if isempty(stopInd)
           [Rs1,stopInd] = min(Hlog);  Rs1 = -Rs1;
           if Rs1<Rs
               Rs = Rs1;
           else
               stopInd = passInd(end)+1;
               Rs = -Hlog(stopInd);
           end
        end
        Fstop = ff(stopInd(1));
    case 2   % highpass
        passInd = find(Hlog(:)>-Rs);
        if isempty(passInd)
            passInd = length(Hlog)-[1 0]';
        elseif passInd(1) == 1
            passInd(1) = [];
        end
        Fstop = ff(passInd(1)-1);
        Rs = -max(Hlog(1:passInd(1)-1));
    case 3   % bandpass
        passInd = find(Hlog(:)>=-Rp);
        stopInd = find((Hlog(:)<=-Rs) & (Hlog(:)<-Rp));
        if isempty(stopInd)
           [Rs1,stopInd1] = min(Hlog(1:passInd(1)));    Rs1 = -Rs1;
           [Rs2,stopInd2] = min(Hlog(passInd(end):end));  Rs2 = -Rs2;
           Rs1 = max([Rs1 Rs2]);
           if Rs1<Rs
               Rs = Rs1;
               stopInd = [stopInd1 stopInd2];
           else
               stopInd = [passInd(1)-1 passInd(end)+1];
               Rs = -max(Hlog(stopInd));
           end
        end
        %stopInd1 = find(Hlog(passInd(1):-1:1)<=-Rs);
        %stopInd2 = find(Hlog(passInd(end):end)<=-Rs);
        %Fstop = ff([passInd(1)-stopInd1(1) passInd(end)+stopInd2(1)]);
        i = min(find(stopInd>=passInd(1))); 
        if isempty(i)
            i = length(stopInd);
            if i == 1
                stopInd = [1 2];
                i = 2;
            end
        end
        Fstop = ff([stopInd(i-1); stopInd(i)]);
    case 4   % bandstop
        stopInd = find(Hlog(:)<=-Rs);
        passInd = find(Hlog(:)>=-Rp);
        if isempty(stopInd)
           [Rs1,stopInd] = min(Hlog);    Rs1 = -Rs1;
           if Rs1<Rs
               Rs = Rs1;
           else
               i = min(find(passInd>=stopInd(1)));
               stopInd = [passInd(i-1)+1 passInd(i)-1];
               Rs = -max(Hlog(stopInd))
           end
        end
        Fstop = ff(stopInd([1 end]));
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
    switch type
    case 1 % lowpass
        % stopband edge
        ind = round(f2.value/delf) + 1;
        f2.value = ff(ind);
        set(Rs,'value', -Hlog(ind))
    case 2  % highpass
        % stopband edge
        ind = round(f1.value/delf) + 1;
        f1.value = ff(ind);
        set(Rs,'value', -Hlog(ind))
    case 3 % bandpass
        switch i
        case 1     % lower stopband edge
            ind = round(f1.value/delf) + 1;
            f1.value = ff(ind);
            set(Rs,'value', -Hlog(ind))
        case 4     % upper stopband edge
            ind = round(f4.value/delf) + 1;
            f4.value = ff(ind);
            set(Rs,'value', -Hlog(ind))
        end
    case 4 % bandstop
        switch i
        case 2     % lower stopband edge
            ind = round(f2.value/delf) + 1;
            f2.value = ff(ind);
            set(Rs,'value', -Hlog(ind))
        case 3     % upper stopband edge
            ind = round(f3.value/delf) + 1;
            f3.value = ff(ind);
            set(Rs,'value', -Hlog(ind))
        end
    end
    if type >= 3  % find new freq. values in bp, bs case
        Fstop = getFreqMeasurements(ff,Hlog,type,Rp.value,Rs.value);
        switch type
        case 3 % bandpass - update f2 f3
            f1.value = Fstop(1);
            f4.value = Fstop(2);
        case 4 % bandstop - update f1 f4
            f2.value = Fstop(1);
            f3.value = Fstop(2);
        end
    end
    if type > 2
        fchange_ind = (i==(1:4)) * [1 4; 2 3; 2 3; 1 4];
    else
        fchange_ind = i;
    end
    updateLines(0,type,fchange_ind,f1,f2,f3,f4,Rp,Rs,Fs)
    fdutil('pokeFilterMeasurements','fdcheby1',type,f1,f2,f3,f4,Rp,Rs,Fs)


function RChangeMeas(passbandChange,type,Fs,Lresp,L1,L2,f1,f2,f3,f4,Rp,Rs)
%RChangeMeas - interactively track response when Rp or Rs has changed
%  This function is meant to be called when the user
%     a) changes the Rp or Rs measurement
%  or b) drags the Rp or Rs value
%  Xdata, Ydata, values of other frequencies and Rp and Rs are updated as
%  needed.
%  Note that for cheby1, only dragging Rs is allowed in this fashion, so
%  passbandChange is assumed 0 and is ignored.
%  Inputs:
%    passbandChange - boolean == 1 for Rp, 0 for Rs, or vector [0 1] for
%          both Rp and Rs
%    type - band configuration (1 = lp, 2 = hp, 3 = bp, 4 = bs)
%    Fs - sampling frequency
%    Lresp, L1, L2 - fdline objects
%    f1,f2,f3,f4,Rp,Rs - fdmeas objects

    ff = Lresp.xdata;
    delf = ff(2)-ff(1);  % frequency spacing
    Hlog = Lresp.ydata;
    Rs_val = get(Rs,'value');
    [Fstop,Rs_val1] = getFreqMeasurements(ff,Hlog,type,Rp.value,Rs_val);
    if Rs_val ~= Rs_val1
        set(Rs,'value',Rs_val1)
    end
    %Fstop = getFreqMeasurements(ff,Hlog,type,Rp.value,Rs.value);
    i = [];  % which frequencies have changed
    switch type
    case 1
        f2.value = Fstop;
        i = [i 2];
    case 2
        f1.value = Fstop;
        i = [1 i];
    case 3 % bandpass - update f2 f3
        f1.value = Fstop(1);
        f4.value = Fstop(2);
        i = [1 i 4];
    case 4 % bandstop - update f1 f4
        f2.value = Fstop(1);
        f3.value = Fstop(2);
        i = sort([i 2 3]);
    end
    updateLines(passbandChange,type,i,f1,f2,f3,f4,Rp,Rs,Fs)
    fdutil('pokeFilterMeasurements','fdcheby1',type,f1,f2,f3,f4,Rp,Rs,Fs)

    
function updateLines(passbandChange,type,fchange_ind,f1,f2,f3,f4,Rp,Rs,Fs)
% assume values of f1,f2,f3,f4,Rp and Rs are correct now
% fchange_ind - vector of indices indicating which frequencies have
%               changed
    global L1 L2 ax
    
    f = getFrequencyValues(type,f1,f2,f3,f4,Fs)*Fs/2;
    
    if any(passbandChange==1)
        maxpass = 0;
        minpass = -Rp.value;
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
    %fdutil('updateRanges',fchange_ind,f1,f2,f3,f4)
    set(f1,'range',[0 Fs/2])
    set(f2,'range',[0 Fs/2])
    set(f3,'range',[0 Fs/2])
    set(f4,'range',[0 Fs/2])
    
function [f1,f2,f3,f4] = setupFrequencyObjects(type,module,pbobjects,...
                   sbobjects,f,Fs,ax,setValueFlag)

    if nargin<8
        setValueFlag = 1;
    end
    
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
    set(f1,'range',[0 Fs/2])
    set(f2,'range',[0 Fs/2])
    set(f3,'range',[0 Fs/2])
    set(f4,'range',[0 Fs/2])
    
    f1.callback = [module '(''fchange'',1)'];
    f2.callback = [module '(''fchange'',2)'];
    f3.callback = [module '(''fchange'',3)'];
    f4.callback = [module '(''fchange'',4)'];
        
function [Rp,Rs,f1,f2,f3,f4] = ...
      setupMeasurementObjects(specStruc,Fstop,Fs,order,order1,stopframe1,ax,...
                  pbmeasures,sbmeasures,pbspecs,...
                  sbspecs,Rp,Rs,Fs1m,Fs2m,f1,f2,f3,f4)
%function setupMeasurementObjects(specStruc,Fstop,Fs,...
%                  order1,sbmeasures,Fs1m,Fs2m)
%  set values of MEASUREMENTS objects ... assumes specStruct is current    

    setOrderFlag = specStruc.setOrderFlag;
    type = specStruc.type;
    f = specStruc.f;
    Rpass = specStruc.Rp;
    Rstop = specStruc.Rs;
    Fpass = specStruc.Fpass;
    N = specStruc.order;
    
    if ~setOrderFlag  % estimate order
        set(order1,'visible','on')
        
        fdutil('changeToText',sbmeasures(1:2))
        set(sbmeasures(3),'visible','off')
        
        set(Fs1m,'visible','on','value',Fstop(1),...
            'format','%1.4g')
        if type > 2
            set(Fs1m,'label','Actual Fs1')
            set(Fs2m,'visible','on','value',Fstop(2),...
                'format','%1.4g','label','Actual Fs2')
        else
            set(Fs1m,'label','Actual Fs')
            set(Fs2m,'visible','off')
        end

        order1.value = N;
    else  % set order
        set(order1,'visible','off')
        
        set(sbspecs(1),'visible','off')
        set(sbspecs(2),'visible','off')
        set(sbspecs(3),'visible','off')
        
        fdutil('changeToEdit',sbmeasures(1:2))
        set(sbmeasures(3),'visible','on')
        
        [f1,f2,f3,f4] = setupFrequencyObjects(type,'fdcheby1',pbspecs,...
                                     sbmeasures,f,Fs,ax,0);
                                             
        set(sbmeasures(1),'value',Fstop(1))
        if type > 2
            set(sbmeasures(2),'value',Fstop(2))
        end

        Rs = sbmeasures(3);        
        set(Rs,'value',Rstop,'label','Rs',...
            'visible','on','callback','fdcheby1(''Rschange'')')
    end
    for i=1:3
        set(sbmeasures(i),'enable','on')
    end
    set(order1,'enable','on')


%function specStruc = measureFilt(objSetupFlag,specStruc,Fs,order1,...
%                  sbmeasures,Fs1m,Fs2m,ff,Hlog,L1,L2,ax)

function [Rp,Rs,f1,f2,f3,f4,specStruc] = ...
      measureFilt(objSetupFlag,specStruc,Fs,order,order1,stopframe1,ax,...
                  pbmeasures,sbmeasures,pbspecs,sbspecs,Rp,Rs,Fs1m,Fs2m,f1,f2,f3,f4,...
                  ff,Hlog,L1,L2);

    n = specStruc.order;    
    setOrderFlag = specStruc.setOrderFlag;
    Fpass = specStruc.Fpass*Fs/2;
    
    [Fstop,Rs_val] = getFreqMeasurements(ff,Hlog,specStruc.type,...
                             specStruc.Rp,specStruc.Rs);
    Rs.value = Rs_val;

    if objSetupFlag
        [Rp,Rs,f1,f2,f3,f4] = ...
          setupMeasurementObjects(specStruc,Fstop,Fs,order,order1,stopframe1,ax,...
                     pbmeasures,sbmeasures,pbspecs,sbspecs,...
                     Rp,Rs,Fs1m,Fs2m,f1,f2,f3,f4);
        %setupMeasurementObjects(specStruc,Fstop,Fs,...
        %          order1,sbmeasures,Fs1m,Fs2m)    
    else
        set(Fs1m,'value',Fstop(1))
        if specStruc.type > 2
            set(Fs2m,'value',Fstop(2))
        end
        if ~setOrderFlag
            order1.value = n;
        end
    end

    if setOrderFlag
        % Update stopband edges in specStruc frequency vector:
        switch specStruc.type
        case 1
            f = [0 Fpass Fstop Fs/2];
        case 2
            f = [0 Fstop Fpass Fs/2];
        case 3
            f = [0 Fstop(1) Fpass(:)' Fstop(2) Fs/2];
        case 4
            f = [0 Fpass(1) Fstop(:)' Fpass(2) Fs/2];
        end
        specStruc.f = f*2/Fs;
    else
        f = specStruc.f*Fs/2;
    end
    
    maxpass = 0;   minpass = -specStruc.Rp;   minstop = -specStruc.Rs;
    
    % update L1 and L2 xdata and ydata, pointers, dragmodes
    fdutil('setLines','fdcheby1',L1,L2,0,...
                      specStruc.type,specStruc.f(:)',...
                      Fs,minpass,maxpass,minstop)
                       
    % update [ylim/xlim] passband limits
    ylim = [minpass maxpass];
    dyl = (ylim(2)-ylim(1))*.15;
    set(ax,'ylimPassband',ylim + [-dyl/2 dyl/2]);
    ax.xlimPassband = fdutil('xlimpassband',specStruc.type,...
                              Fs,f(2),f(3),f(end-2),f(end-1));
                              

function f = getFrequencyValues(type,f1,f2,f3,f4,Fs);            
if type < 3  % low or high pass
    f = [0 f1.value f2.value Fs/2]*2/Fs;
else
    f = [0 f1.value f2.value f3.value f4.value Fs/2]*2/Fs;
end

function [setOrderFlag_init, type_init, f_init, Rp_init, Rs_init, ...
         order_init, Fpass_init] = initSpecs(filt)
%initSpecs   Initial specifications for cheby 1 filter, from
%            filt input
%Switches off of filt.currentModule and if it finds any of
% fdellip, fdbutter, fdcheby2, fdremez, fdfirls, or fdkaiser
% retains the type, order, band edge, and any other relevant
% parameters

    % first define default values
    setOrderFlag_init = 0;   % by default, estimate order 
    type_init = 1;  % 1=lowpass, 2=highpass, 3=bandpass, 4=bandstop
    f_init = [0 .1 .15 1];
    Rp_init = 3;
    Rs_init = 20;
    order_init = 30;
    Fpass_init = .22;
    if strcmp(filt.specs.currentModule,'fdpzedit')
        if isfield(filt.specs.fdpzedit,'oldModule')
            filt.specs.currentModule = filt.specs.fdpzedit.oldModule;
        end
    end
    switch filt.specs.currentModule
    case {'fdellip','fdbutter','fdcheby2','fdremez','fdkaiser','fdfirls'}
        s = eval(['filt.specs.' filt.specs.currentModule]);
        setOrderFlag_init = s.setOrderFlag;
        type_init = s.type;
        f_init = s.f;
        Rp_init = s.Rp;
        Rs_init = s.Rs;
        order_init = s.order;
        switch filt.specs.currentModule
        case 'fdellip'
            Fpass_init = s.Fpass;
        case 'fdbutter'
            Fpass_init = s.w3db;
        case 'fdcheby2'
            Fpass_init = s.Fstop;
        case {'fdremez','fdfirls'}
            switch s.type
            case {1,2}
                Fpass_init = s.f(3);
            case 3
                Fpass_init = s.f([2 5]);
            case 4
                Fpass_init = s.f(3:4);
            end
        case 'fdkaiser'
            Fpass_init = s.Wn;
        end
        if any(strcmp(filt.specs.currentModule,...
                 {'fdremez','fdkaiser','fdfirls'}))
            order_init = ceil(order_init/10); 
             %  FIR filters are much higher order than IIR
        end
    case 'fdcheby1'
        if isfield(filt.specs,'fdcheby1')
            setOrderFlag_init = filt.specs.fdcheby1.setOrderFlag;
            type_init = filt.specs.fdcheby1.type;
            f_init = filt.specs.fdcheby1.f;
            Rp_init = filt.specs.fdcheby1.Rp;
            Rs_init = filt.specs.fdcheby1.Rs;
            order_init = filt.specs.fdcheby1.order;
            Fpass_init = filt.specs.fdcheby1.Fpass;
        end
    end
    
