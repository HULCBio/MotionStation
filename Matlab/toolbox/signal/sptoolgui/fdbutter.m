function varargout = fdbutter(varargin)
%fdbutter  Butterworth Module for filtdes.

%   Author: T. Krauss
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.10.4.2 $

% Change this global to static when available:
%  following are common to several modules
global minOrdCheckbox bandpop order pbspecs sbspecs pbmeasures sbmeasures
global passframe stopframe passframe1 stopframe1
%  following static to fdbutter
global f1 f2 f3 f4 w3db1 w3db2 Rp Rs 
global Rpm w3db1m w3db2m 
global order0 order1
global ax L1 L2 Lresp L3db1 L3db2
global Fs

switch varargin{1}
case 'init'

    filt = varargin{2};
    Fs = filt.Fs;
    [setOrderFlag_init, type_init, f_init, Rp_init, Rs_init, ...
      order_init, w3db_init] = initSpecs(filt);
      
    [minOrdCheckbox bandpop order pbspecs sbspecs ...
         pbmeasures sbmeasures passframe stopframe ...
         passframe1 stopframe1 ax Lresp L1 L2 order1 ...
         L3db1 L3db2] = fdutil('commonObjects');
    order0 = order;
             
    if ~strcmp(bandpop.userdata,'fdbutter')
       % this module is not current
        bandpop.userdata = 'fdbutter';
            
        minOrdCheckbox.callback = 'fdbutter(''checkbox'')';
        bandpop.callback = 'fdbutter(''newtype'')';         

        order0.callback = 'fdbutter(''dirty'')';
                
        f3 = pbspecs(2);
        f4 = sbspecs(2);
        Rp = pbspecs(3);
        Rs = sbspecs(3);
        w3db1 = pbspecs(1);
        w3db2 = sbspecs(2);
        w3dbm1 = sbmeasures(1);
        w3dbm2 = sbmeasures(2);
        
        Rpm = pbmeasures(3);
        
        set(ax,'title',xlate('Frequency Response'),...
              'xlabel',xlate('Frequency'),...
              'ylabel',xlate('Magnitude (dB)'),...
              'ylim',[-150 10],'xlim',[0 Fs/2],...
              'xlimbound',[0 Fs/2]);

        sethelp

        
        set(Lresp,'buttondownfcn','fdbutter(''LrespDown'')')
                       
        set(L1,'buttondownfcn','fdbutter(''L1down'')',...
               'buttonupfcn','fdbutter(''L1up'')');
    
        set(L2,'buttondownfcn','fdbutter(''L2down'')',...
               'buttonupfcn','fdbutter(''L2up'')');
               
        set(L3db1,'xdata',w3db_init([1 1]),...
                  'segmentdragcallback',{'fdbutter(''3db_drag'',1)'},...
                  'buttondownfcn','fdbutter(''3db_down'',1)',...
                  'buttonupfcn','fdbutter(''L1up'')');
                  
        set(L3db2,'xdata',w3db_init([end end]),...
                  'segmentdragcallback',{'fdbutter(''3db_drag'',2)'},...
                  'buttondownfcn','fdbutter(''3db_down'',2)',...
                  'buttonupfcn','fdbutter(''L1up'')');
    end
    set(minOrdCheckbox,'visible','on','enable','on')
    set(pbspecs(1),'visible','on')
    
    fdbutter('newfilt',setOrderFlag_init,type_init,f_init,Rp_init,...
               Rs_init,w3db_init,order_init)
               
    if setOrderFlag_init
    % set these fields since 'Apply' gets them from the specifications struc
    % to make the measurements
        filt.specs.fdbutter.Rp = Rp_init;
        filt.specs.fdbutter.Rs = Rs_init;
    end
    
    [filt, errstr] = fdutil('callModuleApply',...
                               'fdbutter',filt,'');
                               
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
        [n,w3db] = estimateOrder(type,Rp.value,Rs.value,Fs,...
                 f1.value,f2.value,f3.value,f4.value);
    else
        n = order.value;
        w3db = w3db1.value * 2/Fs;
        if type > 2  % pass/stop
            w3db(2) = w3db2.value * 2/Fs;
        end
    end
    
    % save specifications in specifications structure:
    specstruc.setOrderFlag = setOrderFlag;
    specstruc.type = type;
    if ~setOrderFlag
        f = getFrequencyValues(type,f1,f2,f3,f4,Fs);
        specstruc.f = f;
        specstruc.Rp = Rp.value;
        specstruc.Rs = Rs.value;
    else
        specstruc.f = [];  % place holder, will be defined by measureFilt
        specstruc.Rp = filt.specs.fdbutter.Rp;
        specstruc.Rs = filt.specs.fdbutter.Rs;
    end
    specstruc.w3db = w3db;
    if specstruc.type > 2
    % butter(N,...) returns a 2N order filter for bandpass and bandstop filter
        specstruc.order = 2*n; 
    else
        specstruc.order = n;
    end
                          
%     if ~setOrderFlag & isfield(filt.specs,'fdbutter') & ...
%         isequal(specstruc.w3db,filt.specs.fdbutter.w3db) ...
%         & isequal(specstruc.order,filt.specs.fdbutter.order)
%         filt.specs.fdbutter = specstruc;
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
        [b,a] = butter(n,w3db,'high');
    elseif type == 4
        [b,a] = butter(n,w3db,'stop');
    else
        [b,a] = butter(n,w3db);
    end
        
    % compute frequency response:
    nfft = filtdes('nfft');
    [H,ff] = freqz(b,a,nfft,Fs);
    % avoid log of 0 at 0 and Fs/2:
    if H(1) == 0, H(1) = H(2); end
    if H(end) == 0, H(end) = H(end-1); end
    w = warning('off');
    Hlog = 20*log10(abs(H(:)));
    warning(w);
    set(Lresp,'xdata',ff,'ydata',Hlog);
    
    % make measurements:
    if ~ ((strcmp(msg,'motion') | strcmp(msg,'up')) & ~setOrderFlag ...
             & strcmp(get(order1,'visible'),'on') )  | ...
       (~setOrderFlag & (filt.specs.fdbutter.type ~= type))
        objSetupFlag = 1;
    else
        objSetupFlag = 0;
    end
    
    [Rp,Rs,w3db1m,w3db2m,Rpm,f1,f2,f3,f4,specstruc] = ...
      measureFilt(objSetupFlag,specstruc,Fs,order,order1,stopframe1,ax,...
                  pbmeasures,sbmeasures,Rp,Rs,w3db1m,w3db2m,Rpm,f1,f2,f3,f4,...
                  ff,Hlog,L1,L2);
                      
    if ~strcmp(msg,'motion')
        % if design is due to a drag operation, lines are already solid
        % so we can skip this step
        Lresp.linestyle = '-';
        L1.linestyle = '-';
        L2.linestyle = '-';
        set(L3db1,'linestyle','-')
        set(L3db2,'linestyle','-')
        if strcmp(L3db1.erasemode,'normal')
            warning('L3db1 erasemode is normal... why?')
            L3db1.erasemode = 'xor';
            L3db2.erasemode = 'xor';
        end
    end
    
    % alter filt fields:
    filt.tf.num = b;
    filt.tf.den = a;
    filt.specs.fdbutter = specstruc;
    filt.zpk = [];  % clear out in case filtview has written these
    filt.ss = [];
    filt.sos = [];
    filt.type = 'design';

    varargout{1} = filt;
    varargout{2} = '';
        
case 'revert'
    filt = filtdes('filt');
    oldtype = filt.specs.fdbutter.type;
    % need to restore filter type
    setOrderFlag = filt.specs.fdbutter.setOrderFlag;
    oldSetOrderFlag = ~minOrdCheckbox.value;
    f = filt.specs.fdbutter.f;
    Rpass = filt.specs.fdbutter.Rp;
    Rstop = filt.specs.fdbutter.Rs;
    w3db = filt.specs.fdbutter.w3db;
    N = filt.specs.fdbutter.order;
    fdbutter('newfilt',setOrderFlag,oldtype,f,Rpass,Rstop,w3db,N)

    [Rp,Rs,w3db1m,w3db2m,Rpm,f1,f2,f3,f4] = ...
      measureFilt(1,...
                  filt.specs.fdbutter,Fs,order,order1,stopframe1,ax,...
                  pbmeasures,sbmeasures,Rp,Rs,w3db1m,w3db2m,Rpm,f1,f2,f3,f4,...
                  Lresp.xdata,Lresp.ydata,L1,L2);    
    
    Lresp.linestyle = '-';
    L1.linestyle = '-';
    L2.linestyle = '-';
    set(L3db1,'linestyle','-')
    set(L3db2,'linestyle','-')
    
    for i=1:3
        set(pbmeasures(i),'enable','on')
        set(sbmeasures(i),'enable','on')
    end
    set(order1,'enable','on')
    
case 'help'
    str = fdhelpstr('fdbutter');
    varargout{1} = str{2};

case 'description'
    varargout{1} = 'Butterworth IIR';

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
    L3db1.xdata = L3db1.xdata*Fs/oldFs;
    L3db2.xdata = L3db2.xdata*Fs/oldFs;
    
    if minOrdCheckbox.value
        w3db1m.value = w3db1m.value*Fs/oldFs;
        w3db2m.value = w3db2m.value*Fs/oldFs;
    elseif ~any(w3db1==[f1 f2 f3 f4])
        w3db1.value = w3db1.value*Fs/oldFs;
        w3db2.value = w3db2.value*Fs/oldFs;
        w3db1.range = w3db1.range*Fs/oldFs;
        w3db2.range = w3db2.range*Fs/oldFs;
    end
    
%---------------------------------------------------------------------
% -------- following cases are module specific --------- 
%---------------------------------------------------------------------

case 'dirty'
% fdbutter('dirty')
% Callback of a spec ... to change appearance so user can
%  see that the specs and the currently designed filter
%  don't match
    if Lresp.linestyle ~= ':'
        Lresp.linestyle = ':';
        L1.linestyle = ':';
        L2.linestyle = ':';
        L3db1.linestyle = ':';
        L3db2.linestyle = ':';
    end
    for i=1:3
        set(pbmeasures(i),'enable','off')
        set(sbmeasures(i),'enable','off')
    end
    set(order1,'enable','off')

%---------------------------------------------------------------------
% fdbutter('clean')
% opposite of 'dirty'
case 'clean'
    if Lresp.linestyle ~= '-'
        Lresp.linestyle = '-';
        L1.linestyle = '-';
        L2.linestyle = '-';
        L3db1.linestyle = '-';
        L3db2.linestyle = '-';
    end
    for i=1:3
        set(pbmeasures(i),'enable','on')
        set(sbmeasures(i),'enable','on')
    end
    set(order1,'enable','on')
    filtdes('setenable','off')
    
%---------------------------------------------------------------------
% fdbutter('fchange',i)
%    Callback when frequency i has changed
%    Need to update ranges and lines L1, L2
% fdbutter('fchange')
%    called w/o input i when a 3db frequency spec has 
%    changed (in case ~minOrdCheckbox.val==1)
case 'fchange'
    type = bandpop.value;
    if nargin == 1
    % a 3db freq spec has changed  (we are in set mode)
        
        if type >= 3
            w3db = [w3db1.value w3db2.value];
            set(L3db1,'xdata',w3db([1 1]))
            set(L3db2,'xdata',w3db([2 2]))
            w3db1.range = [0 w3db(2)];
            w3db2.range = [w3db(1) Fs/2];
        else
            w3db = w3db1.value;
            set(L3db1,'xdata',w3db([1 1]))
        end
        fdbutter('dirty')
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
        fdbutter('dirty')
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
% fdbutter('Rpchange')
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
    
        fdbutter('dirty')
    else
        RChangeMeas(1,type,Fs,Lresp,L1,L2,f1,f2,f3,f4,Rp,Rs)
    end

    
%---------------------------------------------------------------------
% fdbutter('Rschange')
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
        fdbutter('dirty')
    else
        RChangeMeas(0,type,Fs,Lresp,L1,L2,f1,f2,f3,f4,Rp,Rs)
    end


%---------------------------------------------------------------------
% fdbutter('checkbox')
%  Callback of minimum order checkbox
case 'checkbox'
    filt = filtdes('filt');
    
    newSetOrderFlag = ~get(minOrdCheckbox,'value');
    type = bandpop.value;
    oldtype = filt.specs.fdbutter.type;
    
    if ~newSetOrderFlag   % from set to estimate order 
        if filt.specs.fdbutter.setOrderFlag
            % obtain frequencies from measurements
            c = {pbmeasures(1) pbmeasures(2) sbmeasures(1) sbmeasures(2)};
            if (type==2) | (type==3)
                ind = [3 1 2 4];
            else
                ind = [1 3 4 2];
            end
            f = getFrequencyValues(oldtype,c{ind},Fs);
        else
            % obtain frequencies from filter specs field
            f = filt.specs.fdbutter.f;
        end
        f = [0; fdutil('changeFilterType',type,oldtype,sort(f(2:end-1))); 1];
        w3db = [0 0];  % place holder - ignored by 'newfilt'     
    else   % from estimate to set order 
        w3db = sbmeasures(1).value * 2/Fs;
        if type > 2
            if oldtype > 2
                w3db(2) = sbmeasures(2).value * 2/Fs;
            else
                w3db(2) = (w3db(1)+1)/2;
            end
        end
        f = [];  % place holder - ignored by 'newfilt'
    end
    fdbutter('newfilt',newSetOrderFlag,...
                       type,f,Rp.value,...
                       Rs.value,w3db,order.value)
    fdbutter('dirty')


%---------------------------------------------------------------------
% fdbutter('newfilt',setOrderFlag,type,f,Rp,Rs,w3db,order)
%  set values of SPECIFICATIONS objects ...  DOES NOT DESIGN FILTER
case 'newfilt'
    setOrderFlag = varargin{2};
    type = varargin{3};
    f = varargin{4};     % in range (0,1)
    Rpass = varargin{5};
    Rstop = varargin{6};
    w3db = varargin{7};  % in range (0,1)
    N = varargin{8};

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

        [f1,f2,f3,f4] = setupFrequencyObjects(type,'fdbutter',...
                           pbspecs,sbspecs,f,Fs,ax);
        
        pbspecs(3).visible = 'on';
        sbspecs(1).visible = 'on';
        sbspecs(3).visible = 'on';
                
        Rp = pbspecs(3);
        Rs = sbspecs(3);
        set(Rp,'value',Rpass,'label','Rp','callback','fdbutter(''Rpchange'')')
        set(Rs,'value',Rstop,'label','Rs','callback','fdbutter(''Rschange'')')
                
        L1.color = co(min(2,size(co,1)),:);
        L2.color = co(min(2,size(co,1)),:);   
        set(L3db1,'visible','off')     
        set(L3db2,'visible','off')     
    else  % set order
        passframe.visible = 'off';
        stopframe.visible = 'off';
        order = order0;
        set(order0,'visible','on')
                        
        w3db1 = pbspecs(1);
        w3db2 = pbspecs(2);
        set(pbspecs(3),'visible','off')
        set(sbspecs(1),'visible','off')
        set(sbspecs(2),'visible','off')
        set(sbspecs(3),'visible','off')
       
        set(L3db1,'visible','on','xdata',w3db([1 1])*Fs/2)     
        if type < 3  % low/high
            set(w3db1,'value',w3db(1)*Fs/2,'range',[0 1]*Fs/2,...
               'label','F3db','callback','fdbutter(''fchange'')',...
               'visible','on')
            w3db2.visible = 'off';
            set(L3db2,'visible','off')
        else  % pass/stop
            set(w3db1,'value',w3db(1)*Fs/2,'range',[0 w3db(2)]*Fs/2,...
               'label','F3db 1','callback','fdbutter(''fchange'')',...
               'visible','on')
            set(w3db2,'value',w3db(2)*Fs/2,'range',[w3db(1) 1]*Fs/2,...
               'label','F3db 2','callback','fdbutter(''fchange'')',...
               'visible','on')
            set(L3db2,'visible','on','xdata',w3db([2 2])*Fs/2)     
        end
                
        L1.color = co(min(3,size(co,1)),:);
        L2.color = co(min(3,size(co,1)),:);
        order.value = N;
    end

    if ax.xlimbound(2) ~= Fs/2
        set(ax,'xlimbound',[0 Fs/2],'xlim',[0 Fs/2])
    end
    
    if ~setOrderFlag  % estimate order
        minpass = -Rpass;
        maxpass = 0;
        minstop = -Rstop;
        fdutil('setLines','fdbutter',L1,L2,0,...
                           type,f(:)',Fs,minpass,maxpass,minstop)
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
% fdbutter('newtype')
%  callback of band configuration popup
case 'newtype'
    filt = filtdes('filt');
    newtype = bandpop.value;
    oldtype = get(passframe,'userdata');
    if isempty(oldtype)
        oldtype = filt.specs.fdbutter.type;
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
            w3db = w3db1.value * 2/Fs;
            if newtype > 2
                w3db(2) = w3db2.value * 2/Fs;
                if w3db(2) <= w3db(1) | w3db(2)>1
                    w3db(2) = (w3db(1) + 1)/2;
                    w3db2.value = w3db(2)*Fs/2;
                end
            end
        else
            w3db = [0 0]; % place holder - ignored by newfilt
        end
        fdbutter('newfilt',~minOrdCheckbox.value,newtype,f,Rp.value,...
                  Rs.value,w3db,order.value)
        fdbutter('dirty')
        
    else
       % disp('no change of type')
    end
    
%---------------------------------------------------------------------
% fdbutter('Lrespdown')
%  Button down fcn of Lresp (response line) - pan
case 'LrespDown'
    bounds.xlim = [0 Fs/2];
    bounds.ylim = [-500 30];
    h = ax.h;
    panfcn('Ax',h,...
           'Bounds',bounds,...
           'UserHand',get(h,'zlabel'),...
           'Invisible',[L3db1.h L3db2.h])
           
%---------------------------------------------------------------------
% fdbutter('L1down')
%  Button down fcn of L1
% fdbutter('L2down')
%  Button down fcn of L2
% fdbutter('3db_down',i)
%   buttondown fcn of 3db line 1 or 2 (i==1 or 2)
case {'L1down', 'L2down', '3db_down'}
    L1.erasemode = 'xor';
    L2.erasemode = 'xor';
   
%---------------------------------------------------------------------
% fdbutter('L1up')
%  Button up fcn of L1
% fdbutter('L2up')
%  Button up fcn of L2
case {'L1up', 'L2up'}
    L1.erasemode = 'normal';
    L2.erasemode = 'normal';
    Lresp.erasemode = 'normal';
    
%---------------------------------------------------------------------
% fdbutter('3db_drag',ind)
%  segment drag callback of L3db1 and L3db2 - 3db frequency lines
%  Inputs:
%     ind - index of line being dragged, 1 or 2
case '3db_drag'
    ind = varargin{2};
    minspacing = Fs/500;
    if ind == 1
        xd = L3db1.xdata;
        newf3db1 = inbounds(xd(1),[minspacing w3db1.range(2)-minspacing]);
        if newf3db1 ~= w3db1.value
            w3db1.value = newf3db1;
            w3db2.range = [newf3db1 Fs/2];
            if newf3db1 ~= xd(1)
                L3db1.xdata = newf3db1([1 1]);
            end
        end
    else
        xd = L3db2.xdata;
        newf3db2 = inbounds(xd(1),[w3db2.range(1)+minspacing Fs/2-minspacing]);
        if newf3db2 ~= w3db2.value
            w3db2.value = newf3db2;
            w3db1.range = [0 newf3db2];
            if newf3db2 ~= xd(1)
                L3db2.xdata = newf3db2([1 1]);
            end
        end
    end

%---------------------------------------------------------------------
% fdbutter('L1drag',type,ind)
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
    if minOrdCheckbox.value
%         [n,w3db] = estimateOrder(type,Rp.value,Rs.value,Fs,...
%                  f1.value,f2.value,f3.value,f4.value);
%         order.value = n;
%         w3db1m.value = w3db(1) * Fs/2;
%         if length(w3db)>1
%             w3db2m.value = w3db(2) * Fs/2;
%         end
    else
        fChangeMeas(i,type,Fs,Lresp,L1,L2,f1,f2,f3,f4,Rp,Rs)
        return
    end
    ax.xlimPassband = fdutil('xlimpassband',type,...
                         Fs,f1.value,f2.value,f3.value,f4.value);

    % fdutil('updateRanges',i,f1,f2,f3,f4)

%---------------------------------------------------------------------
% fdbutter('L2drag',type,ind)
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
% fdbutter('Rpdrag',type,ind)
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
        Rp.value = newRp;
        RChangeMeas(1,type,Fs,Lresp,L1,L2,f1,f2,f3,f4,Rp,Rs)
    end
 
%---------------------------------------------------------------------
% fdbutter('Rsdrag',type,ind)
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
global f1 f2 f3 f4 w3db1 w3db2 order Rp Rm pbspecs sbspecs
global Rpm w3db1m w3db2m
global ax L1 L2 Lresp
global Fs

% disp('setting help ... stub')

function [n,w3db] = estimateOrder(type,Rp,Rs,Fs,f1,f2,f3,f4)
% [n,w3db] = estimateOrder(type,Rp,Rs,Fs,f1,f2,f3,f4)
%   estimate filter order
%   takes the specifications as given by the input
%   parameters and estimates the order and 3db frequencies
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
%  w3db - filter band edges for butter, normalized to range [0...1]

if type == 1    % low pass
    Wp = f1;   Ws = f2;
elseif type == 2   % high pass
    Wp = f2;   Ws = f1;
elseif type == 3   % band pass
    Wp = [f2 f3];   Ws = [f1 f4];
elseif type == 4   % band stop
    Wp = [f1 f4];   Ws = [f2 f3];
end
[n,w3db] = buttord(Wp*2/Fs,Ws*2/Fs,Rp,Rs);
w3db = w3db(:)';   % make it a row 
 

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

function [fm,Rs] = getFreqMeasurements(ff,Hlog,type,Rp,Rs)
%getFreqMeasurements
% Finds band edges for a given passband and stopband ripple
% given a filter's magnitude response
% Inputs:
%  ff - xdata of response (assumed a column vector)
%  Hlog - magnitude of response at frequencies ff, in dB
%               (assumed a column vector)
%  type - band configuration (lp = 1, hp = 2, bp = 3, bs = 4)
%  Rp - passband ripple, in dB
%  Rs - stopband attenuation in dB
% Output:
%  fm - 2 or 4 element frequency vector in ascending order
%  Rs - changed value of Rs in case given Rs is unattainable
    passInd = find(Hlog(:)>=-Rp);
    stopInd = find((Hlog(:)<=-Rs) & (Hlog(:)<-Rp));
    switch type
    case 1   % lowpass
        if isempty(stopInd)
           [Rs1,stopInd] = min(Hlog);  Rs1 = -Rs1;
           if Rs1<Rs
               Rs = Rs1;
           else
               stopInd = passInd(end)+1;
               Rs = -Hlog(stopInd);
           end
        end
        fm = ff([passInd(end); stopInd(1)]);
    case 2   % highpass
        if isempty(stopInd)
           [Rs1,stopInd] = min(Hlog);  Rs1 = -Rs1;
           if Rs1<Rs
               Rs = Rs1;
           else
               stopInd = passInd(1)-1;
               Rs = -Hlog(stopInd);
           end
        end
        fm = ff([stopInd(end); passInd(1)]);
    case 3   % bandpass
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
        %  index of beginning of upper stop band
        i = min(find(stopInd>=passInd(1))); 
        if isempty(i)
            i = length(stopInd);
            if i == 1
                stopInd = [1 2];
                i = 2;
            end
        end
        fm = ff([stopInd(i-1); passInd([1 end]); stopInd(i)]);
    case 4   % bandstop
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
        %  index of beginning of upper pass band
        i = min(find(passInd>=stopInd(1)));
        fm = ff([passInd(i-1); stopInd(1); stopInd(end); passInd(i)]);
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
        if i == 1     % passband edge
            ind = round(f1.value/delf) + 1;
            f1.value = ff(ind);
            Rp.value = -Hlog(ind);
            passbandChange = 1;
        else  % stopband edge
            ind = round(f2.value/delf) + 1;
            f2.value = ff(ind);
            set(Rs,'value', -Hlog(ind))
            passbandChange = 0;
        end
    case 2  % highpass
        if i == 1     % stopband edge
            ind = round(f1.value/delf) + 1;
            f1.value = ff(ind);
            set(Rs,'value', -Hlog(ind))
            passbandChange = 0;
        else  % passband edge
            ind = round(f2.value/delf) + 1;
            f2.value = ff(ind);
            Rp.value = -Hlog(ind);
            passbandChange = 1;
        end
    case 3 % bandpass
        switch i
        case 1     % lower stopband edge
            ind = round(f1.value/delf) + 1;
            f1.value = ff(ind);
            set(Rs,'value', -Hlog(ind))
            passbandChange = 0;
        case 2     % lower passband edge
            ind = round(f2.value/delf) + 1;
            f2.value = ff(ind);
            Rp.value = -Hlog(ind);
            passbandChange = 1;
        case 3     % upper passband edge
            ind = round(f3.value/delf) + 1;
            f3.value = ff(ind);
            Rp.value = -Hlog(ind);
            passbandChange = 1;
        case 4     % upper stopband edge
            ind = round(f4.value/delf) + 1;
            f4.value = ff(ind);
            set(Rs,'value', -Hlog(ind))
            passbandChange = 0;
        end
    case 4 % bandstop
        switch i
        case 1     % lower passband edge
            ind = round(f1.value/delf) + 1;
            f1.value = ff(ind);
            Rp.value = -Hlog(ind);
            passbandChange = 1;
        case 2     % lower stopband edge
            ind = round(f2.value/delf) + 1;
            f2.value = ff(ind);
            set(Rs,'value', -Hlog(ind))
            passbandChange = 0;
        case 3     % upper stopband edge
            ind = round(f3.value/delf) + 1;
            f3.value = ff(ind);
            set(Rs,'value', -Hlog(ind))
            passbandChange = 0;
        case 4     % upper passband edge
            ind = round(f4.value/delf) + 1;
            f4.value = ff(ind);
            Rp.value = -Hlog(ind);
            passbandChange = 1;
        end
    end
    if type >= 3  % find new freq. values in bp, bs case
        fm = getFreqMeasurements(ff,Hlog,type,Rp.value,Rs.value);
        switch type
        case 3 % bandpass - update f2 f3
            if passbandChange
                f2.value = fm(2);
                f3.value = fm(3);
            else
                f1.value = fm(1);
                f4.value = fm(4);
            end
        case 4 % bandstop - update f1 f4
            if passbandChange
                f1.value = fm(1);
                f4.value = fm(4);
            else
                f2.value = fm(2);
                f3.value = fm(3);
            end
        end
    end
    if type > 2
        fchange_ind = (i==(1:4)) * [1 4; 2 3; 2 3; 1 4];
    else
        fchange_ind = i;
    end
    updateLines(passbandChange,type,fchange_ind,f1,f2,f3,f4,Rp,Rs,Fs)
    fdutil('pokeFilterMeasurements','fdbutter',type,f1,f2,f3,f4,Rp,Rs,Fs)

function RChangeMeas(passbandChange,type,Fs,Lresp,L1,L2,f1,f2,f3,f4,Rp,Rs)
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

    ff = Lresp.xdata;
    delf = ff(2)-ff(1);  % frequency spacing
    Hlog = Lresp.ydata;
    Rs_val = get(Rs,'value');
    [fm,Rs_val1] = getFreqMeasurements(ff,Hlog,type,Rp.value,Rs_val);
    if Rs_val ~= Rs_val1
        set(Rs,'value',Rs_val1)
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
    updateLines(passbandChange,type,i,f1,f2,f3,f4,Rp,Rs,Fs)
    fdutil('pokeFilterMeasurements','fdbutter',type,f1,f2,f3,f4,Rp,Rs,Fs)
    
    
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

function [Rp,Rs,w3db1m,w3db2m,Rpm,f1,f2,f3,f4] = ...
      setupMeasurementObjects(specStruc,Fs,order,order1,stopframe1,ax,...
                  pbmeasures,sbmeasures,Rp,Rs,w3db1m,w3db2m,Rpm,f1,f2,f3,f4)
%  set values of MEASUREMENTS objects ... assumes specStruct is current

    setOrderFlag = specStruc.setOrderFlag;
    type = specStruc.type;
    f = specStruc.f;
    Rpass = specStruc.Rp;
    Rstop = specStruc.Rs;
    w3db = specStruc.w3db;
    N = specStruc.order;
    
    if ~setOrderFlag  % estimate order

        set(order1,'visible','on')

        stopframe1.visible = 'off';
        set(pbmeasures(2),'visible','off')
        set(pbmeasures(3),'visible','off')
        set(sbmeasures(3),'visible','off')
        
        Rpm = pbmeasures(1);
        set(Rpm,'visible','on','label','Actual Rp')
        w3db1m = sbmeasures(1);
        w3db2m = sbmeasures(2);
        set(w3db1m,'visible','on','value',w3db(1)*Fs/2,...
            'format','%1.4g')
        if type > 2
            set(w3db1m,'label','F3db 1')
            set(w3db2m,'visible','on','value',w3db(2)*Fs/2,...
                'format','%1.4g','label','F3db 2')
        else
            set(w3db1m,'label','F3db')
            set(w3db2m,'visible','off')
        end
        fdutil('changeToText',[Rpm w3db1m w3db2m])

        order.value = N;
        
    else
        set(order1,'visible','off')
    
        stopframe1.visible = 'on';
        
        pbmeasures(1).visible = 'on';
        sbmeasures(1).visible = 'on';

        [f1,f2,f3,f4] = setupFrequencyObjects(type,'fdbutter',pbmeasures,...
                                     sbmeasures,f,Fs,ax,0);
                                             
        Rp = pbmeasures(3);        
        Rs = sbmeasures(3);        
        set(Rp,'value',Rpass,'label','Rp',...
            'visible','on','callback','fdbutter(''Rpchange'')')
        set(Rs,'value',Rstop,'label','Rs',...
            'visible','on','callback','fdbutter(''Rschange'')')
    
    end
    for i=1:3
        set(pbmeasures(i),'enable','on')
        set(sbmeasures(i),'enable','on')
    end
    set(order1,'enable','on')


function [Rp,Rs,w3db1m,w3db2m,Rpm,f1,f2,f3,f4,specStruc] = ...
      measureFilt(objSetupFlag,specStruc,Fs,order,order1,stopframe1,ax,...
                  pbmeasures,sbmeasures,Rp,Rs,w3db1m,w3db2m,Rpm,f1,f2,f3,f4,...
                  ff,Hlog,L1,L2)

    if objSetupFlag
        [Rp,Rs,w3db1m,w3db2m,Rpm,f1,f2,f3,f4] = ...
          setupMeasurementObjects(specStruc,Fs,order,order1,stopframe1,ax,...
                     pbmeasures,sbmeasures,Rp,Rs,w3db1m,w3db2m,Rpm,f1,f2,f3,f4);
    end

    n = specStruc.order;    
    f = specStruc.f;
    setOrderFlag = specStruc.setOrderFlag;
    w3db = specStruc.w3db;
    
    set(f1,'range',[0 Fs/2])
    set(f2,'range',[0 Fs/2])
    set(f3,'range',[0 Fs/2])
    set(f4,'range',[0 Fs/2])

    if ~setOrderFlag
        order.value = n;
        w3db1m.value = w3db(1) * Fs/2;
        if length(w3db)>1
            w3db2m.value = w3db(2) * Fs/2;
        end
        [maxpass,minpass,minstop] = getMagMeasurements(ff,Hlog,specStruc.type,...
                                          f1.value,f2.value,f3.value,f4.value);
        Rpm.value = maxpass - minpass;
    else
        [fm,Rs_val] = getFreqMeasurements(ff,Hlog,specStruc.type,Rp.value,Rs.value);
        Rs.value = Rs_val;
        f1.value = fm(1);  f2.value = fm(2);
        if length(fm)>2
            f3.value = fm(3);  f4.value = fm(4);
        end
%         fdutil('updateRanges',1:length(fm),f1,f2,f3,f4)    % update ranges

        f = [0 fm(:)' Fs/2 0];  % for updating L1 and L2 later;
                                % extra zero is for call to xlimpassband when
                                % type == 1 or 2
        ax.xlimPassband = fdutil('xlimpassband',specStruc.type,...
                             Fs,f(2),f(3),f(4),f(5));
        f = f*2/Fs;
        specStruc.f = f;    
    end
    maxpass = 0;   minpass = -Rp.value;   minstop = -Rs.value;
    ylim = [-Rp.value 0];
    dyl = (ylim(2)-ylim(1))*.15;
    ax.ylimPassband = ylim + [-dyl/2 dyl/2];
    
    % update L1 and L2 xdata and ydata, pointers, dragmodes
    fdutil('setLines','fdbutter',L1,L2,0,...
                      specStruc.type,f(:)',Fs,minpass,maxpass,minstop)


function f = getFrequencyValues(type,f1,f2,f3,f4,Fs);            
if type < 3  % low or high pass
    f = [0 f1.value f2.value Fs/2]*2/Fs;
else
    f = [0 f1.value f2.value f3.value f4.value Fs/2]*2/Fs;
end


function [setOrderFlag_init, type_init, f_init, Rp_init, Rs_init, ...
         order_init, w3db_init] = initSpecs(filt)
%initSpecs   Initial specifications for butterworth filter, from
%            filt input
%Switches off of filt.currentModule and if it finds any of
% fdcheby1, fdcheby2, fdellip, fdremez, fdfirls, or fdkaiser
% retains the type, order, band edge, and any other relevant
% parameters

    % first define default values
    setOrderFlag_init = 0;   % by default, estimate order 
    type_init = 1;  % 1=lowpass, 2=highpass, 3=bandpass, 4=bandstop
    f_init = [0 .1 .15 .5];
    Rp_init = 3;
    Rs_init = 20;
    order_init = 30;
    w3db_init = .22;
    if strcmp(filt.specs.currentModule,'fdpzedit')
        if isfield(filt.specs.fdpzedit,'oldModule')
            filt.specs.currentModule = filt.specs.fdpzedit.oldModule;
        end
    end
    switch filt.specs.currentModule
    case {'fdcheby1','fdcheby2','fdellip','fdremez','fdkaiser','fdfirls'}
        s = eval(['filt.specs.' filt.specs.currentModule]);
        setOrderFlag_init = s.setOrderFlag;
        type_init = s.type;
        f_init = s.f;
        Rp_init = s.Rp;
        Rs_init = s.Rs;
        order_init = s.order;
        switch filt.specs.currentModule
        case 'fdcheby1'
            w3db_init = s.Fpass;
        case 'fdcheby2'
            w3db_init = s.Fstop;
        case 'fdellip'
            w3db_init = s.Fpass;
        case {'fdremez','fdfirls'}
            switch s.type
            case {1,2}
                w3db_init = s.f(2);
            case 3
                w3db_init = s.f(3:4);
            case 4
                w3db_init = s.f([2 5]);
            end            
        case 'fdkaiser'
            w3db_init = s.Wn;
        end
        if any(strcmp(filt.specs.currentModule,...
                 {'fdremez','fdkaiser','fdfirls'}))
            order_init = ceil(order_init/10); 
             %  FIR filters are much higher order than IIR
        end

    case 'fdbutter'
        if isfield(filt.specs,'fdbutter')
            setOrderFlag_init = filt.specs.fdbutter.setOrderFlag;
            type_init = filt.specs.fdbutter.type;
            f_init = filt.specs.fdbutter.f;
            Rp_init = filt.specs.fdbutter.Rp;
            Rs_init = filt.specs.fdbutter.Rs;
            order_init = filt.specs.fdbutter.order;
            w3db_init = filt.specs.fdbutter.w3db;
        end
    end
