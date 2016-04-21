function varargout = fdpzedit(varargin)
%fdpzedit  Pole/Zero Editor Module for filtdes.
% $Revision: 1.20.4.2 $

%   Author: T. Krauss
%   Copyright 1988-2003 The MathWorks, Inc.

% define objects for this module:
persistent c1 c2 cpop conjpairCheckBox sendToBack 
persistent defMode newp newz eraseMode cleanslate 
persistent G Lp Lz unitCircle
persistent ax multIndicators
% measurements (fdmeas objects):
persistent numZeros numPoles stabflag phaseflag
persistent coordMeasFrame magMeas angleMeas xMeas yMeas

% Define the index of the selected pole or zero
persistent L_INDEX
% Is the selection a pole or a zero?  POLE_FLAG == 1 ==> it's a pole
persistent POLE_FLAG

switch varargin{1}
case 'init'

    % LOCK DOWN CURRENT M-FILE SO IT CAN'T BE CLEARED (and persistent vars
    %  stay around):
    mlock   
    
    filt = varargin{2};
    Fs = filt.Fs;
        
    if isempty(c1) | ~ishandle(c1.h)
        filtdes('clear')
    
    % create objects:
    fstr = '%1.4g';

% Gain
    G = fdspec('style','edit','label','Gain','tag','Gain',...
                 'position',1,...
                 'complex',1,...
                 'callback','fdpzedit(''Gain'')',...
                 'help','fdobjhelp');
  
% Coordinate popup:
    cpop = fdspec('style','popupmenu','label','Coordinates',...
                  'string',{'Rectangular' 'Polar'},...
                  'value',2,'tag','cpop','position',3,...
                  'callback','fdpzedit(''cpop'')',...
                  'help','fdobjhelp');
% coordinate 1:
    c1 = fdspec('style','edit','label','Mag','value',0,'tag','c1','position',4,...
                'callback','fdpzedit(''c1_change'')','help','fdobjhelp','format',fstr);
% coordinte 2:
    c2 = fdspec('style','edit','label','Angle','value',0,'tag','c2','position',5,...
                'callback','fdpzedit(''c2_change'')','help','fdobjhelp','format',fstr);

% Conjugate Pair checkbox:
    conjpairCheckBox = fdspec('style','checkbox','string','Conjugate Pair',...
                    'value',0,...
                    'tag','conjpairCheckBox','position',6,...
                    'callback','fdpzedit(''conjpairCheckBox'')',...
                    'help','fdobjhelp');
                    
% Send to Back button
    sendToBack = fdspec('style','pushbutton','string','Send To Back','tag','sendToBack',...
                 'position',[4 2 94 20 2],...
                 'callback','fdpzedit(''sendToBack'')',...
                 'tooltipstring','Use this to select obscured Poles/Zeros',...
                 'help','fdobjhelp');

   [defModeCdata,newpCdata,newzCdata,eraseModeCdata] = LocalMakeIcons;

% Default Mode toggle button
    defMode = fdspec('style','togglebutton','tag','defMode',...
                 'position',[(0*25) -24 25 24 1],...
                 'cdata',defModeCdata,...
                 'callback','fdpzedit(''modecallback'',''defMode'')',...
                 'modepointer','arrow',...
                 'modebuttondownmsg','leavemode',...
                 'tooltipstring','Drag Poles/Zeros',...
                 'help','fdobjhelp');

    % the defaultmode and value props need to be set with the 'set' function:
    set(defMode,'defaultmode','on','value',1)

% New Pole toggle button
    newp = fdspec('style','togglebutton','tag','newp',...
                 'position',[(1*25) -24 25 24 1],...
                 'cdata',newpCdata,...
                 'callback','fdpzedit(''modecallback'',''newp'')',...
                 'modepointer','addpole',...
                 'modebuttondownmsg','newp',...
                 'modemotionfcn','updateCoords',...
                 'leavemodecallback','leavemode',...
                 'tooltipstring','Add Poles',...
                 'help','fdobjhelp');
                 
% New Zero toggle button
    newz = fdspec('style','togglebutton','tag','newz',...
                 'position',[(2*25) -24 25 24 1],...
                 'cdata',newzCdata,...
                 'callback','fdpzedit(''modecallback'',''newz'')',...
                 'modepointer','addzero',...
                 'modebuttondownmsg','newz',...
                 'modemotionfcn','updateCoords',...
                 'leavemodecallback','leavemode',...
                 'tooltipstring','Add Zeros',...
                 'help','fdobjhelp');
                 
% Erase Mode toggle button
    eraseMode = fdspec('style','togglebutton','tag','eraseMode',...
                 'position',[(3*25) -24 25 24 1],...
                 'cdata',eraseModeCdata,...
                 'callback','fdpzedit(''modecallback'',''eraseMode'')',...
                 'modepointer','eraser',...
                 'modebuttondownmsg','del',...
                 'tooltipstring','Delete Poles/Zeros',...
                 'help','fdobjhelp');

% Delete All button
    cleanslate = fdspec('style','pushbutton','string','Delete All','tag','cleanslate',...
                 'position',[-97 2 94 20 3],...
                 'callback','fdpzedit(''cleanslate'')',...
                 'tooltipstring','Deletes all Poles & Zeros - can''t undo!',...
                 'help','fdobjhelp');
                 
% MEASUREMENTS
    numZeros = fdmeas('style','text','label','Zeros:','tag','numZeros',...
                 'position',1,...
                 'help','fdobjhelp');

    numPoles = fdmeas('style','text','label','Poles:','tag','numPoles',...
                 'position',2,...
                 'help','fdobjhelp');
                 
    stabflag = fdmeas('style','text','string','STABLE','tag','stabflag',...
                 'position',3,...
                 'help','fdobjhelp');
                 
    phaseflag = fdmeas('style','text','string','','tag','phaseflag',...
                 'position',4,...
                 'help','fdobjhelp');

    coordMeasFrame = fdmeas('style','frame','label','Coordinates',...
                 'tag','coordMeasFrame',...
                 'position',[5 9],...
                 'visible','off',...
                 'help','fdobjhelp');
    
    magMeas = fdmeas('style','text','label','Mag',...
                 'tag','magMeas',...
                 'position',6,...
                 'visible','off',...
                 'help','fdobjhelp');
    angleMeas = fdmeas('style','text','label','Angle',...
                 'tag','angleMeas',...
                 'position',7,...
                 'visible','off',...
                 'help','fdobjhelp');
    xMeas = fdmeas('style','text','label','X',...
                 'tag','xMeas',...
                 'position',8,...
                 'visible','off',...
                 'help','fdobjhelp');
    yMeas = fdmeas('style','text','label','Y',...
                 'tag','yMeas',...
                 'position',9,...
                 'visible','off',...
                 'help','fdobjhelp');
    
    set(magMeas,'string','-')
    set(angleMeas,'string','-')
    set(xMeas,'string','-')
    set(yMeas,'string','-')

% MAIN AXES:    
    ax = fdax('tag','pzax','title','Z-plane',...
              'xlabel','X - Real Part',...
              'ylabel','Y - Imaginary Part',...
              'aspectmode','equal',...
              'overlay','off',...
              'help','fdobjhelp');

    % initialize multiplicity indicator text objects
    %   these must be at the bottom of the stacking order
    %   so clicking near them does not mask root selection
    %   These text objects are 'cached' as invisible objects
    %   until they are needed... the list might grow but
    %   never shrink (see setMeasurements function)
    multIndicators = zeros(15,1);
    for j=1:length(multIndicators)
        multIndicators(j) = text('parent',ax.h,'visible','off');
    end
    % create fdline which is the unit circle for reference
    Nc = 511;  % number of points in circle
    unitCircle = fdline('tag','unitCircle','erasemode','normal',...
                    'color',get(0,'defaultaxesxcolor'),...
                    'xdata',cos((0:Nc)/Nc*2*pi),'ydata',sin((0:Nc)/Nc*2*pi),...
                    'linestyle',':',...
                    'help','fdobjhelp');
                    
       % ----  done creating objects ----
    elseif strcmp(c1.visible,'off')  % need to make all the objects visible
        objCell = {c1 c2 cpop conjpairCheckBox sendToBack ...
                   newp newz G ax unitCircle ...
                   numZeros numPoles stabflag phaseflag};
        for j=1:length(objCell)
            set(objCell{j},'visible','on')
        end
    end 

    if ~strcmp(filt.specs.currentModule,'fdpzedit')
        filt.specs.fdpzedit.oldModule = filt.specs.currentModule;
    end
            
    lo = get(0,'defaultaxeslinestyleorder');
    
    if isempty(filt.zpk)
        z = roots(filt.tf.num);
        p = roots(filt.tf.den);
        k = filt.tf.num(1)/filt.tf.den(1);
%         [z,p,k] = tf2zp(filt.tf.num,filt.tf.den);
    else
        z = filt.zpk.z;
        p = filt.zpk.p;
        k = filt.zpk.k;
    end
    if isreal(filt.tf.num) & isreal(filt.tf.den)
        % arrange in complex conjugate pairs
        z = cplxpair(z);
        p = cplxpair(p);
    end
    
    % Create vector Lz of fdline objects.  Each object's x and ydata contain the
    % real and imag parts respectively of a zero, or a zero pair.
    if ~isempty(Lz) & ishandle(Lz(1).h)  % first reinitialize if coming from another filter
        for i=1:length(Lz)
            delete(Lz(i))
        end
    end
    Lz = unitCircle;  Lz(1)=[];  % initialize to empty array of fdlines
    i = 1;
    while i<=length(z)
        if i<length(z) & z(i+1)==conj(z(i))
        % pair
            zi = z(i+[0 1]);
            i = i+2;
        else
        % single
            zi = z(i);
            i = i+1;
        end
        Lztemp = newZeroLine(zi);
        if i-length(zi) == 1
            Lz = Lztemp;
        else
            Lz(end+1) = Lztemp;
        end
    end

    % Create vector Lp of fdline objects.  Each object's x and ydata contain the
    % real and imag parts respectively of a pole, or a pole pair.
    if ~isempty(Lp) & ishandle(Lp(1).h)  % first reinitialize if coming from another filter
        for i=1:length(Lp)
            delete(Lp(i))
        end
    end
    Lp = unitCircle;  Lp(1)=[];  % initialize to empty array of fdlines
    i = 1;
    while i<=length(p)
        if i<length(p) & p(i+1)==conj(p(i))
        % pair
            p_i = p(i+[0 1]);
            i = i+2;
        else
        % single
            p_i = p(i);
            i = i+1;
        end
        Lptemp = newPoleLine(p_i);
        if i-length(p_i) == 1
            Lp = Lptemp;
        else
            Lp(end+1) = Lptemp;
        end
    end
    if length(Lp)==0 & length(Lz)==0
        c1.enable = 'off';
        c1.string = '-';
        c2.enable = 'off';
        c2.string = '-';
        cpop.enable = 'off';
        conjpairCheckBox.enable = 'off';
        cleanslate.enable = 'off';
        L_INDEX = [];
        POLE_FLAG = 1;
    elseif length(Lz)==0
        select(Lp(1),c1,c2,cpop,conjpairCheckBox,cleanslate,sendToBack)
        L_INDEX = 1;
        POLE_FLAG = 1;
    else
        select(Lz(1),c1,c2,cpop,conjpairCheckBox,cleanslate,sendToBack)
        L_INDEX = 1;
        POLE_FLAG = 0;
    end
    G.value = k;

    filtdes('zoom','zoomout',findobj('type','figure','tag','filtdes'))
        
    multIndicators = setMeasurements(z,p,numZeros,numPoles,stabflag,phaseflag,...
              ax,multIndicators);

    [filt, errstr] = fdutil('callModuleApply',...
                               'fdpzedit',filt,'');
                               
    varargout{1} = filt;
    varargout{2} = errstr;

case 'apply'    
    
    filt = varargin{2};
    msg = varargin{3};
    
    if strcmp(msg,'motion')
        %stabflag.string = '';
        %phaseflag.string = '';
        varargout{1} = filt;
        varargout{2} = '';
        return
    end

    [z,p,k] = getZPK(Lz,Lp,G);
    multIndicators = setMeasurements(z,p,numZeros,numPoles,stabflag,phaseflag,...
                  ax,multIndicators);
    b = poly(z)*k;
    a = poly(p);
    
    % alter filt fields:
    filt.tf.num = b;
    filt.tf.den = a;
    filt.zpk.z = z; 
    filt.zpk.p = p; 
    filt.zpk.k = k; 
    filt.specs.fdpzedit.z = z;
    filt.specs.fdpzedit.p = p;
    filt.specs.fdpzedit.k = k;
    filt.type = 'imported';
    
    filt.ss = [];
    filt.sos = [];

    varargout{1} = filt;
    varargout{2} = '';
        
case 'revert'
    filt = filtdes('filt');
        
case 'help'
    str = fdhelpstr('fdpzedit');
    varargout{1} = str{2};

case 'description'
    varargout{1} = 'Pole/Zero Editor';

case 'Fs'
% Sampling frequency has changed

%   The filter spec does not depend on the sampling frequency
    filt = varargin{2};
    varargout{1} = filt;
    
case 'disallowModuleChange'
% On change of modules from pzedit:
%   prompt user and cancel if desired
%   Return 1 if user cancels
    if length(Lz)==0 & length(Lp==0)
        varargout{1} = 0;
        return
    end
    
    filt = varargin{2};
    str = { 'Changing from the Pole/Zero Editor to another Filter Algorithm'
            'will cause all pole and zero positions of this filter to be lost.'
            'This operation cannot be undone.'
            'Are you sure you want to change algorithms for this filter?'
            '(hit return for Yes)'};

    ans = questdlg(str,'Lose Root Locations?','Yes','No','Yes');
    continueFlag = strcmp(ans,'Yes');
    
    varargout{1} = ~continueFlag;

%---------------------------------------------------------------------
% fdpzedit('keypressfcn')
%  Respond to 'delete' key being pressed
case 'keypressfcn'
    cc = get(gcf,'currentcharacter');
    doDelete = isequal(abs(cc),8) | isequal(abs(cc),127);    
    if doDelete
        if length(Lz)==0 & length(Lp)==0
            return
        end
        if POLE_FLAG
            Ltemp = Lp(L_INDEX);
        else
            Ltemp = Lz(L_INDEX);
        end
        fdpzedit('del',Ltemp.h)
    end
    
%---------------------------------------------------------------------
% -------- following cases are module specific --------- 
%---------------------------------------------------------------------
    
%---------------------------------------------------------------------
% fdpzedit('c1_change')
%    callback of coordinate 1 edit box
case 'c1_change'
    if POLE_FLAG
        Ltemp = Lp(L_INDEX);
    else
        Ltemp = Lz(L_INDEX);
    end
    switch cpop.value
    case 1   % rectangular
        if length(Ltemp.xdata) == 2
            Ltemp.xdata = c1.value([1 1]);
        else
            Ltemp.xdata = c1.value;
        end
    case 2   % polar
        if length(Ltemp.xdata) == 2
            Ltemp.xdata = c1.value([1 1]).*[cos(c2.value) cos(c2.value)];
            Ltemp.ydata = c1.value([1 1]).*[sin(c2.value) -sin(c2.value)];
        else
            Ltemp.xdata = c1.value*cos(c2.value);
            Ltemp.ydata = c1.value*sin(c2.value);
        end
    end
    x = Ltemp.xdata;
    y = Ltemp.ydata;
    if ~all(pinrect([x(:) y(:)],[ax.xlim ax.ylim]))
        filtdes('zoom','zoomout',findobj('type','figure','tag','filtdes'))
    end
    

%---------------------------------------------------------------------
% fdpzedit('c2_change')
%    callback of coordinate 2 edit box
case 'c2_change'
    if POLE_FLAG
        Ltemp = Lp(L_INDEX);
    else
        Ltemp = Lz(L_INDEX);
    end
    switch cpop.value
    case 1   % rectangular
        if length(Ltemp.xdata) == 2
            Ltemp.ydata = c2.value([1 1]).*[1 -1];
        else
            Ltemp.ydata = c2.value;
        end
    case 2   % polar
        if length(Ltemp.xdata) == 2
            Ltemp.xdata = c1.value([1 1]).*[cos(c2.value) cos(c2.value)];
            Ltemp.ydata = c1.value([1 1]).*[sin(c2.value) -sin(c2.value)];
        else
            Ltemp.xdata = c1.value*cos(c2.value);
            Ltemp.ydata = c1.value*sin(c2.value);
        end
    end
    x = Ltemp.xdata;
    y = Ltemp.ydata;
    if ~all(pinrect([x(:) y(:)],[ax.xlim ax.ylim]))
        filtdes('zoom','zoomout',findobj('type','figure','tag','filtdes'))
    end
    


%---------------------------------------------------------------------
% fdpzedit('cpop')
%    callback of coordinate popup menu
case 'cpop'
    switch cpop.value
    case 1    
        if ~strcmp(c1.label,'X')
         % changing from polar to rectangular
            c1.label = 'X';
            c2.label = 'Y';
            r = c1.value;
            theta = c2.value;
            c1.value = r*cos(theta);
            c2.value = r*sin(theta);
        end
    case 2
        if ~strcmp(c1.label,'Mag')
         % changing from rectangular to polar
            c1.label = 'Mag';
            c2.label = 'Angle';
            x = c1.value;
            y = c2.value;
            c1.value = sqrt(x^2+y^2);
            c2.value = atan2(y,x);
        end
    end
    
%---------------------------------------------------------------------
% fdpzedit('conjpairCheckBox')
%    callback of conjugate pair checkbox
% Behavior:
%    When unchecked, one of the pair is unselected, but the filter
%    is unchanged.
%    When checked, if a conjugate root exists, it is added to the
%    selected one.  If not, a new root is added at the conjugate location.
case 'conjpairCheckBox'
    switch conjpairCheckBox.value
    case 0   % conj pair unchecked - separate conj pair
        if POLE_FLAG
            Ltemp = Lp(L_INDEX);
        else
            Ltemp = Lz(L_INDEX);
        end
        
        Ltemp.xdata = Ltemp.xdata(1);
        Ltemp.ydata = abs(Ltemp.ydata(1))*sign(c2.value);
        
        if POLE_FLAG
            Lp(end+1) = newPoleLine(Ltemp.xdata-sqrt(-1)*Ltemp.ydata);
        else
            Lz(end+1) = newZeroLine(Ltemp.xdata-sqrt(-1)*Ltemp.ydata);
        end
        
    case 1   % conj pair checked - find and group, or add a new root
        if POLE_FLAG
            Ltemp = Lp(L_INDEX);
            Ltemp_vector = Lp;
        else
            Ltemp = Lz(L_INDEX);
            Ltemp_vector = Lz;
        end
        x = Ltemp.xdata;
        y = Ltemp.ydata;
        for i = [1:L_INDEX-1 L_INDEX+1:length(Ltemp_vector)]
            xx = Ltemp_vector(i).xdata;
            yy = Ltemp_vector(i).ydata;
            if xx==x & yy==-y
                delete(Ltemp_vector(i))
                Ltemp_vector(i) = [];
                break
            end
        end
        if POLE_FLAG
            Lp = Ltemp_vector;
        else
            Lz = Ltemp_vector;
        end
        Ltemp.xdata = [x x];
        Ltemp.ydata = [y -y];
    end
    
%---------------------------------------------------------------------
% fdpzedit('sendToBack')
%    callback of sendToBack button
case 'sendToBack'
    fcnSendToBack(Lz,Lp,L_INDEX,POLE_FLAG)
    
%---------------------------------------------------------------------
% fdpzedit('del',h)
%    button down fcn in Delete mode, or 
%    called from keypressfcn
%
%   h is handle to the object that was clicked on
case 'del'
    h = varargin{2};
    
    if ~strcmp(get(h,'type'),'line')
        return   % do nothing - axis or figure was clicked
    end
    % first determine which line was clicked on:
    switch get(h,'marker')
    case 'x'
        hh = Lp(:).h;
        if length(hh)==1
            hh = {hh};
        end
        ind = find(h==[hh{:}]);
        Ltemp_vector = Lp;
        deleteSelected = POLE_FLAG & (L_INDEX == ind);
    case 'o'
        hh = Lz(:).h;
        if length(hh)==1
            hh = {hh};
        end
        ind = find(h==[hh{:}]);
        Ltemp_vector = Lz;
        deleteSelected = ~POLE_FLAG & (L_INDEX == ind);
    otherwise
        return
    end
    
    if deleteSelected
        % first unselect and delete the currently selected root
        if length(Ltemp_vector)==1 & ((POLE_FLAG & length(Lz)==0) | ...
            (~POLE_FLAG & length(Lp)==0))
            % This is the last pole or zero!
            trivialFilter = 1;
        else
            trivialFilter = 0;
        end
        unselect(Ltemp_vector(L_INDEX),c1,c2,cpop,conjpairCheckBox,cleanslate,sendToBack,...
                  ~trivialFilter)
        delete(Ltemp_vector(L_INDEX))
        Ltemp_vector(L_INDEX) = [];
        if POLE_FLAG
            Lp = Ltemp_vector;
        else
            Lz = Ltemp_vector;
        end
            
        % now select another root if possible
        % NOTE: should select NEAREST root, not by index
        L_INDEX = min([L_INDEX length(Ltemp_vector)]);
        if L_INDEX == 0 & ~trivialFilter
            % need to select one of the other type (either pole or zero)
            POLE_FLAG = ~POLE_FLAG;
            if POLE_FLAG
                Ltemp_vector = Lp;
            else
                Ltemp_vector = Lz;
            end
            L_INDEX = length(Ltemp_vector);
            if L_INDEX > 0
                select(Ltemp_vector(L_INDEX),c1,c2,cpop,conjpairCheckBox,cleanslate,sendToBack)
            end
        elseif ~trivialFilter
            select(Ltemp_vector(L_INDEX),c1,c2,cpop,conjpairCheckBox,cleanslate,sendToBack)
        end
    else % just delete the root that was clicked on -
         % no need to change selection
        hmarker = get(h,'marker');      
        delete(Ltemp_vector(ind))
        Ltemp_vector(ind) = [];
        switch hmarker
        case 'x'
            Lp = Ltemp_vector;
            if POLE_FLAG & (ind < L_INDEX)
                L_INDEX = L_INDEX - 1;
            end
        case 'o'
            Lz = Ltemp_vector;
            if ~POLE_FLAG & (ind < L_INDEX)
                L_INDEX = L_INDEX - 1;
            end
        end    
    end
    
    % need to call filtdes('apply') since this uicontrol button doesn't have a value,
    % hence filtdes won't reapply since nothing has changed:
    filtdes('apply')

    if eraseMode.value & strcmp(get(gcf,'selectiontype'),'normal')
        % eraseMode.value = 0;  % leave "Eraser" mode
        defMode.value = 1;    % enter default mode
    end
    
%---------------------------------------------------------------------
% fdpzedit('cleanslate')
%    callback of clear button
case 'cleanslate'
    if length(Lz)==0 & length(Lp)==0
        return   % do nothing - no zeros or poles to clear
    end

    % first unselect and delete the currently selected root
    if POLE_FLAG
        Ltemp_vector = Lp;
    else
        Ltemp_vector = Lz;
    end
    unselect(Ltemp_vector(L_INDEX),c1,c2,cpop,conjpairCheckBox,cleanslate,sendToBack,0)

    for i=1:length(Lp)
        delete(Lp(i))
    end
    for i=1:length(Lz)
        delete(Lz(i))
    end
    if length(Lz)>0
        Lz(:) = [];
    end
    if length(Lp)>0
        Lp(:) = [];
    end
    L_INDEX = 0;
    
    % Set the gain value to 1 since we're starting with a clean slate.
    G.value = 1;
    
    % Zoom out after deleting all the poles and zeros
    filtdes('zoom','zoomout',findobj('type','figure','tag','filtdes'));
    
    % need to call filtdes('apply') since this uicontrol button doesn't have a value,
    % hence filtdes won't reapply since nothing has changed:
    filtdes('apply')

%---------------------------------------------------------------------
% fdpzedit('modecallback',modeStr)
%    callback of mode (toggle) button
case 'modecallback'
    switch varargin{2}
    case {'defMode','eraseMode'}
        theButton = newp;  % when user clicks on these
                           % buttons, just make sure to execute
                           % LOWER branch of if statement below
                           % to turn off coordinate readouts
    case 'newp'
        theButton = newp;
    case 'newz'
        theButton = newz;
    end
    if theButton.value
        % show coordinate readouts
        set(coordMeasFrame,'visible','on')
        set(magMeas,'visible','on')
        set(angleMeas,'visible','on')
        set(xMeas,'visible','on')
        set(yMeas,'visible','on')
    else
        % hide coordinate readouts
        set(coordMeasFrame,'visible','off','string','-')
        set(magMeas,'visible','off','string','-')
        set(angleMeas,'visible','off','string','-')
        set(xMeas,'visible','off','string','-')
        set(yMeas,'visible','off','string','-')
    end
    
%---------------------------------------------------------------------
% fdpzedit('leavemode',modeObject)
%    callback when filtdes leaves a mode
case 'leavemode'
    % hide coordinate readouts
    set(coordMeasFrame,'visible','off','string','-')
    set(magMeas,'visible','off','string','-')
    set(angleMeas,'visible','off','string','-')
    set(xMeas,'visible','off','string','-')
    set(yMeas,'visible','off','string','-')
    
%---------------------------------------------------------------------
% fdpzedit('updateCoords')
%  Update coordinate measurements based on current point of ax
case 'updateCoords'
    fig = get(ax,'parent');
    ud = get(fig,'userdata');
    pos = get(ud.ht.axFrame,'position');
    pt = get(fig,'currentpoint');
    if pinrect(pt,[pos(1) pos(1)+pos(3) pos(2) pos(2)+pos(4)])
        cp = get(ax,'currentpoint');
        x = cp(1,1);
        y = cp(1,2);
        mag = abs(x+sqrt(-1)*y);
        ang = angle(x+sqrt(-1)*y);
        set(magMeas,'value',mag)
        set(angleMeas,'value',ang)
        set(xMeas,'value',x)
        set(yMeas,'value',y)
    else
        set(magMeas,'string','-')
        set(angleMeas,'string','-')
        set(xMeas,'string','-')
        set(yMeas,'string','-')
    end
    
%---------------------------------------------------------------------
% fdpzedit('newp',h)
%    callback of New Pole button
%    h is (hg) object that was clicked on
%    locate new pole or pole pair (depending on conj pair checkbox)
%    near currently selected root
case 'newp'
    trivialFilter = (length(Lp)==0)&(length(Lz)==0);
    if ~trivialFilter
        if POLE_FLAG
            unselect(Lp(L_INDEX),c1,c2,cpop,conjpairCheckBox,cleanslate,sendToBack,1)
        else 
            unselect(Lz(L_INDEX),c1,c2,cpop,conjpairCheckBox,cleanslate,sendToBack,1)
        end
    end
    cp = get(ax,'currentpoint');
    x = cp(1,1);
    y = cp(1,2);
    if conjpairCheckBox.value
        x = [x x];
        y = [y -y];
    end
    
    % locate upper root at mouse down location:
    Ltemp = newPoleLine(x+sqrt(-1)*y);
    if length(Lp)>0
        Lp(end+1) = Ltemp;
    else
        Lp = Ltemp;
    end
    select(Lp(end),c1,c2,cpop,conjpairCheckBox,cleanslate,sendToBack)
    if ~trivialFilter
        unselect([],c1,c2,cpop,conjpairCheckBox,cleanslate,sendToBack)
    end
    L_INDEX = length(Lp);
    POLE_FLAG = 1;
    if ~all(pinrect([x(:) y(:)],[ax.xlim ax.ylim]))
        filtdes('zoom','zoomout',findobj('type','figure','tag','filtdes'))
    end

    % need to call filtdes('apply') since this uicontrol button doesn't have a value,
    % hence filtdes won't reapply since nothing has changed:
    filtdes('apply')
    
    if strcmp(get(gcf,'selectiontype'),'normal')
        %newp.value = 0;  % leave "Add Pole" mode
        defMode.value = 1;  % enter default mode
        fdpzedit('leavemode')
    end
    
%---------------------------------------------------------------------
% fdpzedit('newz',h)
%    callback of New Zero button
%    h is (hg) object that was clicked on
case 'newz'
    trivialFilter = (length(Lp)==0)&(length(Lz)==0);
    if ~trivialFilter
        if POLE_FLAG
            unselect(Lp(L_INDEX),c1,c2,cpop,conjpairCheckBox,cleanslate,sendToBack,1)
        else 
            unselect(Lz(L_INDEX),c1,c2,cpop,conjpairCheckBox,cleanslate,sendToBack,1)
        end
    end
    cp = get(ax,'currentpoint');
    x = cp(1,1);
    y = cp(1,2);
    if conjpairCheckBox.value
        x = [x x];
        y = [y -y];
    end
    
    % locate upper root at mouse down location:
    Ltemp = newZeroLine(x+sqrt(-1)*y);
    if length(Lz)>0
        Lz(end+1) = Ltemp;
    else
        Lz = Ltemp;
    end
    select(Lz(end),c1,c2,cpop,conjpairCheckBox,cleanslate,sendToBack)
    if ~trivialFilter
        unselect([],c1,c2,cpop,conjpairCheckBox,cleanslate,sendToBack)
    end
    L_INDEX = length(Lz);
    POLE_FLAG = 0;
    if ~all(pinrect([x(:) y(:)],[ax.xlim ax.ylim]))
        filtdes('zoom','zoomout',findobj('type','figure','tag','filtdes'))
    end

    % need to call filtdes('apply') since this uicontrol button doesn't have a value,
    % hence filtdes won't reapply since nothing has changed:
    filtdes('apply')
    
    if strcmp(get(gcf,'selectiontype'),'normal')
        %newz.value = 0;  % leave "Add Zero" mode
        defMode.value = 1;  % enter default mode
        fdpzedit('leavemode')
    end
    

%---------------------------------------------------------------------
% fdpzedit('Gain')
%    callback of Gain edit box
case 'Gain'
    % no-op
   
%---------------------------------------------------------------------
% fdpzedit('Lz_down')
% fdpzedit('Lp_down')
%    buttondownfcn of zeros line
%    At this point, there must be at least one root... we can count on that
case {'Lz_down','Lp_down'}
   if POLE_FLAG
       unselect(Lp(L_INDEX),c1,c2,cpop,conjpairCheckBox,cleanslate,sendToBack,1)
   else
       unselect(Lz(L_INDEX),c1,c2,cpop,conjpairCheckBox,cleanslate,sendToBack,1)
   end
   if length(Lz)==0
       zk = [];
   else
       zHandCell = Lz(:).h;
       if length(zHandCell)==1
           zHandCell = {zHandCell};  % force it to be a cell array
       end
       zHand = [zHandCell{:}];
       zk = find(zHand==gcbo);  % may be empty
   end
   if isempty(zk)
       pHandCell = Lp(:).h;
       if length(pHandCell)==1
           pHandCell = {pHandCell};  % force it to be a cell array
       end
       pk = find([pHandCell{:}]==gcbo);  % this will not be empty (since zk is empty)
       L_INDEX = pk;
       POLE_FLAG = 1;
       select(Lp(L_INDEX),c1,c2,cpop,conjpairCheckBox,cleanslate,sendToBack)
       unselect([],c1,c2,cpop,conjpairCheckBox,cleanslate,sendToBack)
       % Change the line to xor mode to prevent axes redraws during dragging.
       Lp(L_INDEX).erasemode = 'xor';
   else
       L_INDEX = zk;
       POLE_FLAG = 0;
       select(Lz(L_INDEX),c1,c2,cpop,conjpairCheckBox,cleanslate,sendToBack)
       unselect([],c1,c2,cpop,conjpairCheckBox,cleanslate,sendToBack)
       Lz(L_INDEX).erasemode = 'xor';
   end

   % if the shift key is down, constrain drag to coordinate of
   % largest first motion
   global firstXY constraintMode
   if strcmp(get(get(ax,'parent'),'SelectionType'),'extend')
       constraintMode = 0;  % 1==>X, 2==>Y, 3==>R, 4==>theta
       if POLE_FLAG
           firstXY = [Lp(L_INDEX).xdata(1) Lp(L_INDEX).ydata(1)];
       else
           firstXY = [Lz(L_INDEX).xdata(1) Lz(L_INDEX).ydata(1)];
       end
       % make sure firstXY reflects the correct (the one that was
       % clicked on) root in a conjugate pair:
       cp = get(ax,'currentpoint');
       if abs(cp(1,2)-firstXY(2)) > abs(cp(1,2)+firstXY(2))
           firstXY(2) = -firstXY(2);
       end
   else 
       constraintMode = [];
   end
   
   % NOW get ready for drag updating FVTool
   global stabVal phaseVal focusIndex
   global zz pp k hFVTs Listeners
   
   % first get unselected zeros and poles
   filt = filtdes('filt');
   if POLE_FLAG   
       zs = []; ps = Lp(L_INDEX).xdata + sqrt(-1)*Lp(L_INDEX).ydata;
       zz = filt.zpk.z;
       pp = filt.zpk.p;
       for i=1:length(ps)
           pp(find(pp==ps(i))) = [];
       end
       % [zz,pp,k] = getZPK(Lz,Lp([1:L_INDEX-1 L_INDEX+1:end]),G);  do this a faster
   else
       zs = Lz(L_INDEX).xdata + sqrt(-1)*Lz(L_INDEX).ydata; ps = [];
       zz = filt.zpk.z;
       pp = filt.zpk.p;
       for i=1:length(zs)
           zz(find(zz==zs(i))) = [];
       end
       % [zz,pp,k] = getZPK(Lz([1:L_INDEX-1 L_INDEX+1:end]),Lp,G);   
   end

   k = filt.zpk.k;
   [stabVal,phaseVal] = setMeasurementsDifferential(...
       [zz(:); zs(:)],...
       [pp(:); ps(:)],...
       stabflag,phaseflag,0,0);
   
   FiltdesFig = findobj(0,'tag','filtdes');
   FDud = get(FiltdesFig,'userdata');
   focusIndex = get(FDud.ht.filtMenu,'value');

   % Obtain the handles for FVTools opened from SPTool
   SPToolFig = findobj(0,'type','figure','tag','sptool');
   ud = get(SPToolFig,'userdata');
   for m = 1 : length(ud.components(2).verbs),
       if strcmpi('filtview',ud.components(2).verbs(m).owningClient);
           break;
       end
   end
   hFVTs = ud.components(2).verbs(m).hFVTs; % FVTool handles
   Listeners = ud.components(2).verbs(m).listeners;
   % Disable the listeners on FVTool
   set(Listeners,'Enable','off');
   set(hFVTs, 'FastUpdate', 'On');
   
%---------------------------------------------------------------------
% fdpzedit('Lz_drag',vertexInd)
% fdpzedit('Lp_drag',vertexInd)
%    motionfcn of zeros / poles line
%    vertexInd will be 1 for the first vertex, 2 for the second, indicating
%      which vertex is being dragged.  If the pole or zero line is not a conjugate
%      pair, vertexInd will always be 1.
case {'Lz_drag','Lp_drag'}
    vertexInd = varargin{2};
    if POLE_FLAG 
        Ltemp = Lp(L_INDEX);
    else
        Ltemp = Lz(L_INDEX);
    end
    xd = Ltemp.xdata;
    yd = Ltemp.ydata;
    x = xd(vertexInd);
    y = yd(vertexInd);

    writeXYdata = 0;  % do we need to update the X and Y data?
    
    % if the shift key is down, constrain drag to coordinate of
    % largest first motion
    global firstXY constraintMode
    if ~isempty(constraintMode)
        % constraintMode values: 1==>X, 2==>Y, 3==>R, 4==>theta
        if constraintMode == 0 % need to initialize
            if cpop.value == 1  % X/Y
                if abs(firstXY(1)-x) > abs(firstXY(2)-y)
                    constraintMode = 1;
                else
                    constraintMode = 2;
                end
            else
                r0 = sqrt(firstXY(1)^2+firstXY(2)^2);
                theta0 = atan2(firstXY(2),firstXY(1));
                r = sqrt(x^2 + y^2);
                theta = atan2(y,x);
                if abs(r*exp(sqrt(-1)*theta0)-r0*exp(sqrt(-1)*theta0)) > ...
                   abs(r0*exp(sqrt(-1)*theta)-r0*exp(sqrt(-1)*theta0))
                    % only R changes
                    constraintMode = 3;
                else
                    % only theta changes
                    constraintMode = 4;
                end
            end
        end
        if constraintMode > 2
            r0 = sqrt(firstXY(1)^2+firstXY(2)^2);
            theta0 = atan2(firstXY(2),firstXY(1));
            r = sqrt(x^2 + y^2);
            theta = atan2(y,x);
        end
        switch constraintMode
        case 1   % only X can change
            y = firstXY(2);
        case 2   % only Y can change
            x = firstXY(1);
        case 3   % only R can change
            x = real(r*exp(sqrt(-1)*theta0));
            y = imag(r*exp(sqrt(-1)*theta0));
        case 4   % only theta can change
            x = real(r0*exp(sqrt(-1)*theta));
            y = imag(r0*exp(sqrt(-1)*theta));
        end    
        xd(vertexInd) = x;
        yd(vertexInd) = y;
        writeXYdata = 1;
    end
    
    if length(xd)==2  % enforce conjugate symmetry
        xd(1+1-(vertexInd-1)) = xd(vertexInd);
        yd(1+1-(vertexInd-1)) = -yd(vertexInd);
        writeXYdata = 1;
    end
    if writeXYdata
        set(Ltemp,'xdata',xd,'ydata',yd)
    end
    
    % update coordinate readouts
    switch cpop.value
    case 1    % rectangular
        c1.value = x;;
        c2.value = y;
    case 2    % polar
        r = sqrt(x^2 + y^2);
        theta = atan2(y,x);
        c1.value = r;
        c2.value = theta;
    end       
     
        
    % update FVTool
    global stabVal phaseVal focusIndex
    global zz pp k hFVTs Listeners
    
    % first define selected zero(s)/pole(s)
    if POLE_FLAG
        zs = []; ps = xd+sqrt(-1)*yd;
    else
        zs = xd+sqrt(-1)*yd; ps = [];
    end
    [stabVal,phaseVal] = setMeasurementsDifferential([zz(:); zs(:)],[pp(:); ps(:)],...
        stabflag,phaseflag,...
        stabVal,phaseVal);
    
    if ~isempty(hFVTs)
        % first define transfer func form of selected zero(s)/pole(s)
        
        % Remove leading and trailing zeros.
        filtStruc.tf.num = signalpolyutils('removezeros', poly([zz(:); zs(:)])*k);
        filtStruc.tf.den = poly([pp(:); ps(:)]);
        
        % Update FVTool on the fly
        update_fvtool(hFVTs,filtStruc,'pzedit',focusIndex);
    end
    
%---------------------------------------------------------------------
% fdpzedit('Lz_up')
%    buttonupfcn of zeros line
case {'Lz_up','Lp_up'}
    % restore to normal erasemode (and hence normal appearance)
    if POLE_FLAG
        Lp(L_INDEX).erasemode = 'normal';
        x = Lp(L_INDEX).xdata;
        y = Lp(L_INDEX).ydata;
    else
        Lz(L_INDEX).erasemode = 'normal';
        x = Lz(L_INDEX).xdata;
        y = Lz(L_INDEX).ydata;
    end
    if ~all(pinrect([x(:) y(:)],[ax.xlim ax.ylim]))
        filtdes('zoom','zoomout',findobj('type','figure','tag','filtdes'))
    end
    
    global firstXY constraintMode
    clear global firstXY constraintMode
    
    global stabVal phaseVal
    global zz pp k hFVTs Listeners
    set(Listeners,'Enable','on');
    set(hFVTs, 'FastUpdate', 'Off');

    clear global stabVal phaseVal
    clear global zz pp k hFVTs Listeners
    
end  % of function switch-yard

%---------------------------------------------------------------------
% -------- LOCAL FUNCTIONS START HERE  --------- 
%---------------------------------------------------------------------

function select(L,c1,c2,cpop,conjpairCheckBox,cleanslate,sendToBack)
%SELECT
%  Selects the given pole/zero or pole/zero pair contained in fdline L
%  by highlighting its color and thickness, and updating the 
%  coordinates and other SPECIFICATIONS objects
%  Inputs:
%    L - fdline object which you want to select
%    c1, c2, cpop, conjpairCheckBox, cleanslate, sendToBack - fdspec objects
%  Outputs:
%    none
    
    c1UD = c1.userdata;
    Lh = L.h;
    if ~isempty(c1UD) & isequal(c1UD.h,Lh)  
       % prevent unselection of the currently selected root
        c1.userdata = [];
    end
    z = get(Lh,'xdata') + sqrt(-1)*get(L,'ydata');
    if length(z)>1
        % select upper or lower conjugate root based on current point of axes
        cp = get(get(Lh,'parent'),'currentpoint');
        if cp(1,2) < 0
            z = real(z(1))-sqrt(-1)*abs(imag(z(1)));
        else
            z = real(z(1))+sqrt(-1)*abs(imag(z(1)));
        end
    end
    set(c1,'enable','on')
    set(c2,'enable','on')
    set(cpop,'enable','on')
    set(conjpairCheckBox,'enable','on')
    set(cleanslate,'enable','on')
    set(sendToBack,'enable','on')
    switch cpop.value
    case 1  % rectangular
        c1.value = real(z);
        c2.value = imag(z);
    case 2  % polar
        c1.value = abs(z);
        c2.value = angle(z);
    end
    conjpairCheckBox.value = length(L.xdata)>1;
    co = get(0,'defaultaxescolororder');
    set(L,'color',co(min(2,end),:),'linewidth',2)
    switch get(L,'marker')
    case 'x'  % pole
        set(L,'markersize',10)
    case 'o'  % zero
        set(L,'markersize',8)
    end
    
    
function unselect(L,c1,c2,cpop,conjpairCheckBox,cleanslate,sendToBack,waitFlag)
%UNSELECT
%  Unselects the given pole/zero or pole/zero pair contained in fdline L
%  by highlighting its color and thickness, and updating the 
%  coordinates and other SPECIFICATIONS objects
%  Inputs:
%    L - fdline object which you want to select
%    c1, c2, cpop, conjpairCheckBox, cleanslate, sendToBack - fdspec objects
%    waitFlag - optional, defaults to 0
%      if 1, will not change line properties of L until 
%              unselect([],c1,c2,cpop,conjpairCheckBox,cleanslate,sendToBack,del) 
%          is called, and will not change the fdspec properties
%  Outputs:
%    none

    if nargin < 8
        waitFlag = 0;
    end
    if waitFlag
        c1.userdata = L;
        return
    end
    if isempty(L)
        L = c1.userdata;
        if isempty(L)
            return
        end
        co = get(0,'defaultaxescolororder');
        set(L,'markersize',6,'color',co(1,:),'linewidth',1)
        return
    end
    set(c1,'enable','off')
    set(c2,'enable','off')
    set(cpop,'enable','off')
    set(conjpairCheckBox,'enable','off')
    set(cleanslate,'enable','off')
    set(sendToBack,'enable','off')
    c1.string = '-';
    c2.string = '-';
    co = get(0,'defaultaxescolororder');
    set(L,'markersize',6,'color',co(1,:),'linewidth',1)


function Lztemp = newZeroLine(zi);
%Create (unselected) zero line
%  zi input is complex location of zero or zero pair
%  Returns fdline object

    co = get(0,'defaultaxescolororder');
    Lztemp = fdline('tag','Lz','erasemode','normal','color',co(1,:),...
                    'xdata',real(zi),'ydata',imag(zi),...
                    'marker','o','markersize',6,...
                    'linestyle','none',...
                    'buttondownfcn','fdpzedit(''Lz_down'')',...
                    'buttonupfcn','fdpzedit(''Lz_up'')',...
                    'vertexdragmode',{'both'},...
                    'vertexdragcallback',...
                       {'fdpzedit(''Lz_drag'',1)' 'fdpzedit(''Lz_drag'',2)'},...
                    'help','fdobjhelp');


function Lptemp = newPoleLine(p_i);
%Create (unselected) pole line
%  p_i input is complex location of pole or pole pair
%  Returns fdline object

    co = get(0,'defaultaxescolororder');
    Lptemp = fdline('tag','Lp','erasemode','normal','color',co(1,:),...
                    'xdata',real(p_i),'ydata',imag(p_i),...
                    'marker','x','markersize',6,...
                    'linestyle','none',...
                    'buttondownfcn','fdpzedit(''Lp_down'')',...
                    'buttonupfcn','fdpzedit(''Lp_up'')',...
                    'vertexdragmode',{'both'},...
                    'vertexdragcallback',...
                       {'fdpzedit(''Lp_drag'',1)' 'fdpzedit(''Lp_drag'',2)'},...
                    'help','fdobjhelp');

function fcnSendToBack(Lz,Lp,L_INDEX,POLE_FLAG)
%fcnSendToBack
%  reorders fdline children Lz and Lp so that 
%  the currently selected line is at the bottom of the stacking
%  order relative the other lines in Lz and Lp.

   if length(Lz)>0
       Hz = Lz(:).h;
       if length(Hz) == 1
           Hz = {Hz};
       end
   else
       Hz = {};
   end
   if length(Lp)>0
       Hp = Lp(:).h;
       if length(Hp) == 1
           Hp = {Hp};
       end
   else
       Hp = {};
   end
   
   h = [Hz{:} Hp{:}]';  % vector of handles
   ax = get(h(1),'parent');
   ch = get(ax,'children');
   [c,ia,ib] = intersect(ch,h);
   bottom = ch;
   bottom(ia) = [];
   top = ch(sort(ia));
         
   if POLE_FLAG
       hBack = Lp(L_INDEX).h;
   else
       hBack = Lz(L_INDEX).h;
   end
   top(find(top==hBack)) = [];
   
   set(ax,'children',[top(:); hBack; bottom(:)])
   

function [z,p,k] = getZPK(Lz,Lp,G)
% Get zeros, poles, and gain vectors from 
% fdline vectors Lz and Lp, and fdspec G
    z = [];
    for i=1:length(Lz)
        x = Lz(i).xdata;
        y = Lz(i).ydata;
        z = [z; x(:)+sqrt(-1)*y(:)];
    end
    p = [];
    for i=1:length(Lp)
        x = Lp(i).xdata;
        y = Lp(i).ydata;
        p = [p; x(:)+sqrt(-1)*y(:)];
    end
    k = G.value;
    
    
function multIndicators = ...
     setMeasurements(z,p,numZeros,numPoles,stabflag,phaseflag,ax,multIndicators)
% Set measurements including
%    - number of zeros and poles
%    - stability indicator
%    - minimum phase / maximum phase indicator
%    - multiple zeros and poles indicators
    numZeros.value = length(z);
    numPoles.value = length(p);
    if length(z)==0 & length(p)==0
        stabflag.string = 'Trivial Filter';
        phaseflag.string = '';
    else
        if any(ge(abs(p),1.0)),
            stabflag.string = 'UNSTABLE';
            stabflag.foregroundcolor = 'r';
        else
            stabflag.string = 'STABLE';
            stabflag.foregroundcolor = get(0,'defaultuicontrolforegroundcolor');
        end
        if all(abs(p)>1.0) & all(abs(z)>1.0)
            phaseflag.string = 'Strictly Maximum Phase';
        elseif all(abs(p)<1.0) & all(abs(z)<1.0)
            phaseflag.string = 'Strictly Minimum Phase';
        elseif all(abs(p)>=1.0) & all(abs(z)>=1.0)
            phaseflag.string = 'Maximum Phase';
        elseif all(abs(p)<=1.0) & all(abs(z)<=1.0)
            phaseflag.string = 'Minimum Phase';
        else
            phaseflag.string = '';
        end
    end
    % find and indicate multiple zeros / poles:
    %   multIndicators is a vector of handles to text objects
    if length(z)==0 & length(p)==0
        set(multIndicators,'visible','off')
        return
    end
    indCount = 0;  % how many indicators (both zero and pole) we have
    sendToBackFlag = 0;  % if we create new indicators, we need to send them
                         % to the bottom of the stacking order
    % use a tolerance of 1.5 pixels in current magnification
    pixDist = 1.5;
    axh = ax.h;
    axpos = get(axh,'position');
    axDist = pixDist * diff(get(ax,'xlim'))/axpos(3);
    [m,i] = mpoles(z,axDist);
    ii=find(diff(m)<0);
    if length(m)>0 & m(end)>1
        ii = [ii(:); length(z)];
    end
    % z(i(ii)) <-- root values
    % m(ii) <--  multiplicity
    for j=1:length(ii)
        zi = z(i(ii(j)));
        mult = m(ii(j));
        indCount = indCount + 1;
        if length(multIndicators)<indCount
            t = text('parent',ax.h);
            if length(multIndicators)==0
                multIndicators = t;
            else
                multIndicators(indCount) = t;
            end
            sendToBackFlag = 1;
        end
        set(multIndicators(indCount),'position',[real(zi) imag(zi) 0],...
                'string',['  ' num2str(mult)],'visible','on',...
                'verticalalignment','middle',...
                'horizontalalignment','left')
    end
    [m,i] = mpoles(p,axDist);
    ii=find(diff(m)<0);
    if length(m)>0 & m(end)>1
        ii = [ii(:); length(p)];
    end
    % p(i(ii)) <-- root values
    % m(ii) <--  multiplicity
    for j=1:length(ii)
        p_i = p(i(ii(j)));
        mult = m(ii(j));
        indCount = indCount + 1;
        if length(multIndicators)<indCount
            t = text('parent',ax.h);
            if length(multIndicators)==0
                multIndicators = t;
            else
                multIndicators(indCount) = t;
            end
            sendToBackFlag = 1;
        end
        set(multIndicators(indCount),'position',[real(p_i) imag(p_i) 0],...
                'string',[num2str(mult) '  '],'visible','on',...
                'verticalalignment','middle',...
                'horizontalalignment','right')
    end
    % hide any indicators still around
    set(multIndicators(indCount+1:end),'visible','off')
    if sendToBackFlag
        h = get(ax.h,'children');
        [c,ia,ib]=intersect(h,multIndicators);
        h(ia) = [];
        % reorder children: (involves ugly axes redraw)
        set(ax.h,'children',[h(:); multIndicators(:)])
    end
    
    
function [stabVal,phaseVal] = setMeasurementsDifferential(z,p,stabflag,phaseflag,...
                                stabVal,phaseVal)
% Only update stabflag and phaseflag fdspecs during drag if the status has changed
    if any(abs(p)>1.0)
        if stabVal == 1
            stabflag.string = 'UNSTABLE';
            stabflag.foregroundcolor = 'r';
            stabVal = 0;  % unstable
        end
    else
        if stabVal == 0
            stabflag.string = 'STABLE';
            stabflag.foregroundcolor = get(0,'defaultuicontrolforegroundcolor');
            stabVal = 1;  % unstable
        end
    end
    %phaseVal can take on values:
    %  -2 strictly min phase
    %  -1 minimum phase
    %   0 nothing
    %   1 maximum phase
    %   2 strictly maximum phase
    if all(abs(p)>1.0) & all(abs(z)>1.0)
        if phaseVal ~= 2
            phaseflag.string = 'Strictly Maximum Phase';
            phaseVal = 2;
        end
    elseif all(abs(p)<1.0) & all(abs(z)<1.0)
        if phaseVal ~= -2
            phaseflag.string = 'Strictly Minimum Phase';
            phaseVal = -2;
        end
    elseif all(abs(p)>=1.0) & all(abs(z)>=1.0)
        if phaseVal ~= 1
            phaseflag.string = 'Maximum Phase';
            phaseVal = 1;
        end
    elseif all(abs(p)<=1.0) & all(abs(z)<=1.0)
        if phaseVal ~= -1
            phaseflag.string = 'Minimum Phase';
            phaseVal = -1;
        end
    elseif phaseVal ~= 0
        phaseflag.string = '';
        phaseVal = 0;
    end
        
function setstem(h,x,y)
%SETSTEM Set xdata and ydata of two handles for stem plots
%  taken from filtview

    set(h(1),'xdata',x,'ydata',y)
    x = x(:);  % make it a column
    xx = x(:,[1 1 1])';
    xx = xx(:);
    n = nan;
    y = [zeros(size(x)) y(:) n(ones(length(x),1),:)]';
    set(h(2),'xdata',xx,'ydata',y(:));


function [x,y] = newPos(x,y,ax)
% newPos
%   given x and y data of the currently selected root (or conjugate pair of roots), 
%   find x and y positions of a new root (or conjugate pair of roots)
%   The new position is given by some small arbitrary # of pixels 
%   up and to the right of the currently selected root.
%   Input ax is an fdax object, the parent of the roots lines.  This is
%   needed for position and limits information.
    pixDist = 10;
    axh = ax.h;
    axpos = get(axh,'position');
    axDist = pixDist * diff(get(ax,'xlim'))/axpos(3);
    switch length(x)
    case 1
        x = x+axDist;
        y = y+axDist;
    case 2
        x = x+axDist;
        if y(1)<=0
            y(1) = y(1)-axDist;
            y(2) = y(2)+axDist;
        else
            y(1) = y(1)+axDist;
            y(2) = y(2)-axDist;
        end
    end


%%%%%%%%%%%%%%%%%%%%%%
%%% LocalMakeIcons %%%
%%%%%%%%%%%%%%%%%%%%%%
function [default,addpole,addzero,erase] = LocalMakeIcons;

cm = [0 0 0;
     0.502 0 0;
         0    0.5020         0;
    0.5020    0.5020         0;
         0         0    0.5020;
    0.5020         0    0.5020;
         0    0.5020    0.5020;
    0.7529    0.7529    0.7529;
    0.5020    0.5020    0.5020;
    1.0000         0         0;
         0    1.0000         0;
    1.0000    1.0000         0;
         0         0    1.0000;
    1.0000         0    1.0000;
         0    1.0000    1.0000;
    1.0000    1.0000    1.0000;
    0.4000    0.4000    0.4000;
    0.4267    0.4267    0.4267;
    0.4533    0.4533    0.4533;
    0.4800    0.4800    0.4800;
    0.5067    0.5067    0.5067;
    0.5333    0.5333    0.5333;
    0.5600    0.5600    0.5600;
    0.7529    0.7529    0.7529;
    0.6133    0.6133    0.6133;
    0.6400    0.6400    0.6400;
    0.6667    0.6667    0.6667;
    0.6933    0.6933    0.6933;
    0.7200    0.7200    0.7200;
    0.7467    0.7467    0.7467;
    0.7733    0.7733    0.7733;
    0.8000    0.8000    0.8000;
    1         1         1;
    0.85      0.85       0.85];
 
 d =  [...
    32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 25
    32 24 24 24 24 1 24 24 24 24 24 24 24 24 24 24 24 24 24 17
    32 24 24 24 24 1 1 24 24 24 24 24 24 24 24 24 24 24 24 17
    32 24 24 24 24 1 33 1 24 24 24 24 24 24 24 24 24 24 24 17
    32 24 24 24 24 1 33 33 1 24 24 24 24 24 24 24 24 24 24 17
    32 24 24 24 24 1 33 33 33 1 24 24 24 24 24 24 24 24 24 17
    32 24 24 24 24 1 33 33 33 33 1 24 24 24 24 24 24 24 24 17
    32 24 24 24 24 1 33 33 33 33 33 1 24 24 24 24 24 24 24 17
    32 24 24 24 24 1 33 33 33 33 33 33 1 24 24 24 24 24 24 17
    32 24 24 24 24 1 33 33 33 33 33 33 33 1 24 24 24 24 24 17
    32 24 24 24 24 1 33 33 33 33 33 33 33 33 1 24 24 24 24 17
    32 24 24 24 24 1 33 33 33 33 33 1 1 1 1 24 24 24 24 17
    32 24 24 24 24 1 33 33 1 33 33 1 24 24 24 24 24 24 24 17
    32 24 24 24 24 1 33 1 24 1 33 33 1 24 24 24 24 24 24 17
    32 24 24 24 24 1 1 24 24 1 33 33 1 24 24 24 24 24 24 17
    32 24 24 24 24 24 24 24 24 24 1 33 33 1 24 24 24 24 24 17
    32 24 24 24 24 24 24 24 24 24 1 33 33 1 24 24 24 24 24 17
    32 24 24 24 24 24 24 24 24 24 24 1 1 1 24 24 24 24 24 17
    32 24 24 24 24 24 24 24 24 24 24 24 24 24 24 24 24 24 24 17
    25 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17];
    
 default=LocalInd2RGB(d,cm); 
    
 p=[...
    32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 25
    32 24 10 24 24 24 10 24 24 24 24 24 24 24 24 24 24 24 24 17
    32 24 24 10 24 10 24 24 24 24 24 24 24 24 24 24 24 24 24 17
    32 24 24 24 10 24 24 24 24 24 24 24 24 24 24 24 24 24 24 17
    32 24 24 10 24 10 24 24 1 24 24 24 24 24 24 24 24 24 24 17
    32 24 10 24 24 24 10 24 1 1 24 24 24 24 24 24 24 24 24 17
    32 24 24 24 24 24 24 24 1 33 1 24 24 24 24 24 24 24 24 17
    32 24 24 24 24 24 24 24 1 33 33 1 24 24 24 24 24 24 24 17
    32 24 24 24 24 24 24 24 1 33 33 33 1 24 24 24 24 24 24 17
    32 24 24 24 24 24 24 24 1 33 33 33 33 1 24 24 24 24 24 17
    32 24 24 24 24 24 24 24 1 33 33 33 33 33 1 24 24 24 24 17
    32 24 24 24 24 24 24 24 1 33 33 33 33 33 33 1 24 24 24 17
    32 24 24 24 24 24 24 24 1 33 33 33 33 1 1 1 24 24 24 17
    32 24 24 24 24 24 24 24 1 33 1 33 33 1 24 24 24 24 24 17
    32 24 24 24 24 24 24 24 1 1 24 1 33 1 24 24 24 24 24 17
    32 24 24 24 24 24 24 24 1 24 24 24 1 33 1 24 24 24 24 17
    32 24 24 24 24 24 24 24 24 24 24 24 1 33 1 24 24 24 24 17
    32 24 24 24 24 24 24 24 24 24 24 24 24 1 33 1 24 24 24 17
    32 24 24 24 24 24 24 24 24 24 24 24 24 1 1 1 24 24 24 17
    25 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17];
      
addpole=LocalInd2RGB(p,cm);
      
 z=[...
    32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 25
    32 24 24 10 10 10 24 24 24 24 24 24 24 24 24 24 24 24 24 17
    32 24 10 24 24 24 10 24 24 24 24 24 24 24 24 24 24 24 24 17
    32 24 10 24 24 24 10 24 24 24 24 24 24 24 24 24 24 24 24 17
    32 24 10 24 24 24 10 24 1 24 24 24 24 24 24 24 24 24 24 17
    32 24 24 10 10 10 24 24 1 1 24 24 24 24 24 24 24 24 24 17
    32 24 24 24 24 24 24 24 1 33 1 24 24 24 24 24 24 24 24 17
    32 24 24 24 24 24 24 24 1 33 33 1 24 24 24 24 24 24 24 17
    32 24 24 24 24 24 24 24 1 33 33 33 1 24 24 24 24 24 24 17
    32 24 24 24 24 24 24 24 1 33 33 33 33 1 24 24 24 24 24 17
    32 24 24 24 24 24 24 24 1 33 33 33 33 33 1 24 24 24 24 17
    32 24 24 24 24 24 24 24 1 33 33 33 33 33 33 1 24 24 24 17
    32 24 24 24 24 24 24 24 1 33 33 33 33 1 1 1 24 24 24 17
    32 24 24 24 24 24 24 24 1 33 1 33 33 1 24 24 24 24 24 17
    32 24 24 24 24 24 24 24 1 1 24 1 33 1 24 24 24 24 24 17
    32 24 24 24 24 24 24 24 1 24 24 24 1 33 1 24 24 24 24 17
    32 24 24 24 24 24 24 24 24 24 24 24 1 33 1 24 24 24 24 17
    32 24 24 24 24 24 24 24 24 24 24 24 24 1 33 1 24 24 24 17
    32 24 24 24 24 24 24 24 24 24 24 24 24 1 1 1 24 24 24 17
    25 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17];
         
addzero=LocalInd2RGB(z,cm);

e= [...
    32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 32 25
    32 24 24 24 24 24 24 24 24 24 24 24 24 24 24 24 24 24 24 17
    32 24 24 24 24 24 24 24 24 24 24 24 24 24 24 24 24 24 24 17
    32 24 24 24 24 24 24 24 24 24 24 24 24 24 24 24 24 24 24 17
    32 24 1 1 1 1 1 1 1 24 24 24 24 24 24 24 24 24 24 17
    32 24 1 1 33 33 33 33 33 1 24 24 24 24 24 24 24 24 24 17
    32 24 1 33 1 33 33 33 33 33 1 24 24 24 24 24 24 24 24 17
    32 24 1 33 33 1 33 33 33 33 33 1 24 24 24 24 24 24 24 17
    32 24 24 1 33 33 1 33 33 33 33 33 1 24 24 24 24 24 24 17
    32 24 24 24 1 33 33 1 33 33 33 33 33 1 24 24 24 24 24 17
    32 24 24 24 24 1 33 33 1 33 33 33 33 33 1 24 24 24 24 17
    32 24 24 24 24 24 1 33 33 1 33 33 33 33 33 1 24 24 24 17
    32 24 24 24 24 24 24 1 33 33 1 33 33 33 33 33 1 24 24 17
    32 24 24 24 24 24 24 24 1 33 33 1 1 1 1 1 1 1 24 17
    32 24 24 24 24 24 24 24 24 1 33 1 33 33 33 33 33 1 24 17
    32 24 24 24 24 24 24 24 24 24 1 1 1 1 1 1 1 1 24 17
    32 24 24 24 24 24 24 24 24 24 24 24 24 24 24 24 24 24 24 17
    32 24 24 24 24 24 24 24 24 24 24 24 24 24 24 24 24 24 24 17
    32 24 24 24 24 24 24 24 24 24 24 24 24 24 24 24 24 24 24 17
    25 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17 17];
erase=LocalInd2RGB(e,cm); 

%%%%%%%%%%%%%%%%%%%%
%%% LocalInd2RGB %%%
%%%%%%%%%%%%%%%%%%%%
function rout = LocalInd2RGB(a,cm);

% Extract r,g,b components
r = zeros(size(a)); r(:) = cm(a,1);
g = zeros(size(a)); g(:) = cm(a,2);
b = zeros(size(a)); b(:) = cm(a,3);

rout = zeros([size(r),3]);
rout(:,:,1) = r;
rout(:,:,2) = g;
rout(:,:,3) = b;

