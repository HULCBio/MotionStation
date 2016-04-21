function varargout = fdutil(varargin)
%FDUTIL Utilities for Filter Design Modules.
%    This function consists of local functions useful to several
%    filter designer modules.

%   Author: T. Krauss
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.9.4.3 $

if (nargout == 0)
  feval(varargin{:});
else
  [varargout{1:nargout}] = feval(varargin{:});
end


function f = changeFilterType(newtype,oldtype,f)
% changeFilterType
% Summary:
%    Find new frequency vector when changing from one band configuration
%    to another.  This is used when the user selects the popup which says
%    "make this bandpass filter into a lowpass filter!" (or from any
%    of the 4 types to any of the others
% Inputs:
%    newtype - integer, contains new filter type: 1 = lp, 2 = hp, 3 = bp, 4 = bs
%    oldtype - integer, contains previous filter type
%            if oldtype == newtype on entry, f is unchanged
%    f - band edge frequency vector, either 2 or 4 elements in ascending order
%        depending on oldtype.  For bandpass and bandstop filters, will
%        have 4 elements, for low and highpass, 2 elements.
%        Assumed normalized so 1.0 == Nyquist
% Outputs:
%    f - new frequency vector

    f = f(:).';
    if newtype~=oldtype
        switch newtype
        case 1  % to lowpass 
            if oldtype == 3   % from bandpass
              f(1:2) = [];
            elseif oldtype == 4  % from bandstop
              f(3:4) = [];
            end
        case 2  % to highpass 
            if oldtype == 3   % from bandpass
              f(3:4) = [];
            elseif oldtype == 4  % from bandstop
              f(1:2) = [];
            end
        case 3  % to bandpass
            if oldtype == 1   % from lowpass
                splitwidth = .15;
                xd = [0 f(1)];
                dxd = diff(xd);
                xd = xd(1)+dxd/2 + [-dxd*splitwidth/2;  dxd*splitwidth/2];
                f = [ xd(:);  f(:)];
            elseif oldtype == 2  % from highpass
                splitwidth = .15;
                xd = [f(2) 1];
                dxd = diff(xd);
                xd = xd(1)+dxd/2 + [-dxd*splitwidth/2;  dxd*splitwidth/2];
                f = f(1:2);
                f = [ f(:); xd(:)];
            end
        case 4  % to bandstop
            if oldtype == 1   % from lowpass
                splitwidth = .15;
                xd = [f(2) 1];
                dxd = diff(xd);
                xd = xd(1)+dxd/2 + [-dxd*splitwidth/2;  dxd*splitwidth/2];
                f = f(1:2);
                f = [ f(:); xd(:)];
            elseif oldtype == 2  % from highpass
                splitwidth = .15;
                xd = [0 f(1)];
                dxd = diff(xd);
                xd = xd(1)+dxd/2 + [-dxd*splitwidth/2;  dxd*splitwidth/2];
                f = [ xd(:);  f(:)];
            end
        end
    end
    f = f(:);

function hlabel = newlabel(h,label,pos,enclosingFrame,hlabel)
% Creates a new label for the specification or measurement with HG handle h
% Also sets positions of h and hlabel.
% Inputs:
%   h - handle to original object
%   label - string for label
%   pos - userdefined position, can be either 1, 2 or 4 elements:
%         length 1 - scalar specifying position in enclosingFrame (1 == top slot,
%                      2 == next slot, etc)
%         length 2 - [i1 i2] means this is a frame taking slots i1 through i2
%         length 4 - regular HG position rect
%   enclosingFrame - either ud.ht.specFrame or ud.ht.measFrame
%   hlabel - already existing handle of label - optional - defaults to []
% Outputs:
%   hlabel - HG handle to label - will be invisible if label is ''
%

if nargin < 5 
    hlabel = uicontrol('parent',get(h,'parent'),'style','text',...
                'string',label,'tag',get(h,'tag'));
    set(hlabel,'userdata',h)  % user data contains handle of 'parent' object
else
    set(hlabel,'string',label,'visible','on','userdata',h,'tag',get(h,'tag'))
end
[pos2,pos1] = specpos(pos,h,hlabel,enclosingFrame);
set(h,'position',pos2)
set(hlabel,'position',pos1)

% save a pointer to label's corresponding uicontrol in the
%  label's userdata.  This will be used for help clicks on
%  the label (see fdhelpstr).
set(hlabel,'userdata',h)


function [pos2,pos1] = specpos(pos,h,hlabel,enclosingFrame)
% Inputs:
%    pos - either integer, 2 element, or 4 element position vect
%    h   - handle of uicontrol
%    hlabel - handle of uicontrol's label
%    enclosingFrame - handle to frame encompassing objects
% Outputs:
%    pos2 - position of main uicontrol
%    pos1 - position of label uicontrol

fig = get(enclosingFrame,'parent');
ud = get(fig,'userdata');
sz = ud.sz;

% compute position:
if length(pos)==1   % position at appropriate place in spec area
    sfp = get(enclosingFrame,'position');
    pos = [sfp(1)+4 sfp(2)+sfp(4)-(sz.uh+sz.fus)*(pos+1)+sz.fus sfp(3)-8 sz.uh];
elseif length(pos)==2  % 2 element vector - position for  
                                  % frame object or toggle button...
    switch get(h,'style')
    case 'frame'
        % [p1 p2]  - label takes up p1, encloses fdspecs in p1+1 : p2
        sfp = get(enclosingFrame,'position');
        p1 = pos(1);
        p2 = pos(2);
        pos = [sfp(1)+2 sfp(2)+sfp(4)-(sz.uh+sz.fus)*(p2+1) sfp(3)-4 ...
                   (sz.uh+sz.fus)*(p2-p1)+sz.uh/2];
    case 'togglebutton'
    % Toggle Buttons are 2 specs high, and can be placed 2 side-by-side
    % For their position vectors, first element is bottom spec position,
    %  second element is between 0 and 1... use 0 for left, 1 for right,
    %  and .5 for center
        sfp = get(enclosingFrame,'position');
        p1 = pos(1);
        p2 = pos(2);
        
        width = (sfp(3)-2*6-6)/2;
        pos = [sfp(1)+6+p2*(width+6) sfp(2)+sfp(4)-(sz.uh+sz.fus)*(p1+1)+sz.fus ...
                width 2*sz.uh+sz.fus];
    end
elseif length(pos)==5
% position relative to one of the corners of the main axis frame:
%   pos(5) = 1 ==> upper left
%            2 ==> lower left
%            3 ==> lower right
%            4 ==> upper right
    afp = get(ud.ht.axFrame,'position');
    switch pos(5)
    case 1  % upper left
        pos = pos(1:4) + [afp(1) afp(2)+afp(4) 0 0];
    case 2  % lower left
        pos = pos(1:4) + [afp(1) afp(2) 0 0];
    case 3  % lower right
        pos = pos(1:4) + [afp(1)+afp(3) afp(2) 0 0];
    case 4  % upper right
        pos = pos(1:4) + [afp(1)+afp(3) afp(2)+afp(4) 0 0];
    end
    
else
    % use position as passed in by user
    % pos = pos;
end

ext = get(hlabel,'extent');
label = get(hlabel,'string');
if ~strcmp(get(h,'style'),'frame')
    if ~isempty(label)
        pos1 = [pos(1) pos(2) ext(3)+2 pos(4)];
        pos2 = [pos1(1)+pos1(3)+2 pos(2) pos(3)-(pos1(3)+2) pos(4)];
    else
        pos1 = [pos(1)-2 pos(2) 1 pos(4)];
        pos2 = pos;
        set(hlabel,'visible','off')
    end
    switch computer
    case 'MAC2'
        pos1Tweak = [0 3 0 -6];
        switch get(h,'style')
        case 'text'
            pos2Tweak = [0 3 0 -6];
        case 'popupmenu'
            pos2Tweak = [0 1 0 -2];
        otherwise
            pos2Tweak = [0 0 0 0];
        end
    case 'PCWIN'
        pos1Tweak = [0 0 0 0];
        switch get(h,'style')
        case 'text'
            pos2Tweak = [0 0 0 0];
        case 'edit'
            pos2Tweak = [0 0 0 1];
        case 'popupmenu'
            pos2Tweak = [0 0 0 0];
        otherwise
            pos2Tweak = [0 0 0 0];
        end
    otherwise
        pos1Tweak = [0 0 0 0];
        pos2Tweak = [0 0 0 0];
    end
else  % it's a frame
    if strcmp(computer,'MAC2')
        lh = 12;
    else
        lh = ext(4); % label height
    end
    pos1 = [pos(1)+sz.lfs pos(2)+pos(4)-lh/2 ext(3) lh];
    pos2 = pos;
    set(hlabel,'horizontalalignment','center')

    switch computer
    case 'MAC2'
        pos1Tweak = [0 0 0 0];
        pos2Tweak = [0 0 0 0];
    case 'PCWIN'
        pos1Tweak = [0 0 0 0];
        pos2Tweak = [0 0 0 0];
    otherwise
        pos1Tweak = [1 -3 2 0];
        pos2Tweak = [0  0 0 0];
    end
    
end
pos1 = pos1 + pos1Tweak;
pos2 = pos2 + pos2Tweak;

    
function str = formattedstring(obj)
% Return formatted string for specifications or measurement object
% Inputs:
%   obj - structure with .h field
%         .h is a HG handle whos userdata struct contains the following fields:
%            .value  - real number, value of object
%            .format - format string, e.g. '%1.5g'
% Outputs:
%   str - formatted string  
    objud = get(obj.h,'userdata');
    if ~isreal(objud.value)
        str = sprintf([objud.format '+' objud.format 'i'],...
                           real(objud.value),imag(objud.value));
    else
        str = sprintf(objud.format,objud.value);
    end

    
function sendToBack(fig,h)
%sendToBack
%  reorders children of figure fig so that handles in handle vector h
%    are on the bottom 

   if isempty(h),
       return
   end
   
   ch = allchild(fig);
   ch = ch(:);
   h = h(:);
   
   ch1 = ch;
   for i=1:length(h)
       ch1(find(ch1==h(i))) = [];
   end
   ch1 = [ch1(:); h];
   if ~isequal(ch,ch1)  % avoid redraw if child order hasn't changed
       set(fig,'children',ch1(:))
   end

function [MinOrdCheckbox,bandpop,order,pbspecs,sbspecs,...
      pbmeasures,sbmeasures,passframe,stopframe,...
      passframe1,stopframe1,ax,Lresp,L1,L2,order1,L3_1,L3_2] = commonObjects
% finds or creates objects common to filtdes modules
%   fdremez
%   fdkaiser
%   fdfirls
%   fdbutter
%   fdcheby1
%   fdcheby2
%   fdellip 
% Deletes any objects not in output list

% TPK, 6/24/97

S = filtdes('findobj','fdspec');
if ~isempty(S)
    s = struct(S);  s = [s.h];
    c = findobj(s,'tag','minordcheckbox');
    if ~isempty(c)
        mocb_ind = find(c==s);
    else
        mocb_ind = [];
    end
else
    mocb_ind = [];
end

if ~isempty(mocb_ind)
    % find all the other objects
    M = filtdes('findobj','fdmeas');
    m = struct(M);  m = [m.h];
    
    order_ind = find(findobj(s,'tag','order')==s);
    bandpop_ind = find(findobj(s,'tag','bandpop')==s);
    passframe_ind = find(findobj(s,'tag','passframe')==s);
    stopframe_ind = find(findobj(s,'tag','stopframe')==s);
    passframe1_ind = find(findobj(m,'tag','passframe1')==m);
    stopframe1_ind = find(findobj(m,'tag','stopframe1')==m);
    
    pb1_ind = find(findobj(s,'tag','pb1')==s);
    pb2_ind = find(findobj(s,'tag','pb2')==s);
    pb3_ind = find(findobj(s,'tag','pb3')==s);
    sb1_ind = find(findobj(s,'tag','sb1')==s);
    sb2_ind = find(findobj(s,'tag','sb2')==s);
    sb3_ind = find(findobj(s,'tag','sb3')==s);
    
    order1_ind = find(findobj(m,'tag','order1')==m);
    pbm1_ind = find(findobj(m,'tag','pbm1')==m);
    pbm2_ind = find(findobj(m,'tag','pbm2')==m);
    pbm3_ind = find(findobj(m,'tag','pbm3')==m);
    sbm1_ind = find(findobj(m,'tag','sbm1')==m);
    sbm2_ind = find(findobj(m,'tag','sbm2')==m);
    sbm3_ind = find(findobj(m,'tag','sbm3')==m);
    
    MinOrdCheckbox = S(mocb_ind);
    order = S(order_ind); 
    bandpop = S(bandpop_ind);
    passframe = S(passframe_ind); 
    stopframe = S(stopframe_ind);
    passframe1 = M(passframe1_ind);
    stopframe1 = M(stopframe1_ind);
    
    pb1 = S(pb1_ind);
    pb2 = S(pb2_ind);
    pb3 = S(pb3_ind);
    sb1 = S(sb1_ind);
    sb2 = S(sb2_ind);
    sb3 = S(sb3_ind);
    
    order1 = M(order1_ind);
    pbm1 = M(pbm1_ind);
    pbm2 = M(pbm2_ind);
    pbm3 = M(pbm3_ind);
    sbm1 = M(sbm1_ind);
    sbm2 = M(sbm2_ind);
    sbm3 = M(sbm3_ind);
    
    % need to delete other objects here that are not common
    Sind = 1:length(S);
    Sind([mocb_ind order_ind bandpop_ind passframe_ind ...
          stopframe_ind pb1_ind pb2_ind pb3_ind sb1_ind sb2_ind sb3_ind]) = [];
    delete(S(Sind))
    
    A = filtdes('findobj','fdax');
    a = struct(A);  a = [a.h];
    ax_ind = find(findobj(a,'tag','ax')==a);
    ax = A(ax_ind);
    Aind = 1:length(A);
    Aind(ax_ind) = [];
    delete(A(Aind))  % also deletes lines
    
    L = filtdes('findobj','fdline');
    l = struct(L);  l = [l.h];
    L1_ind = find(findobj(l,'tag','passband')==l);  L1 = L(L1_ind);
    L2_ind = find(findobj(l,'tag','stopband')==l);  L2 = L(L2_ind);
    Lresp_ind = find(findobj(l,'tag','response')==l);  Lresp = L(Lresp_ind);
    L3_1_ind = find(findobj(l,'tag','L3_1')==l);  L3_1 = L(L3_1_ind);
    L3_2_ind = find(findobj(l,'tag','L3_2')==l);  L3_2 = L(L3_2_ind);
    Lind = 1:length(L);
    Lind([L1_ind L2_ind Lresp_ind L3_1_ind L3_2_ind]) = [];
    delete(L(Lind))  % also deletes lines
    
    Mind = 1:length(M);
    Mind([passframe1_ind stopframe1_ind order1_ind pbm1_ind pbm2_ind pbm3_ind ...
         sbm1_ind sbm2_ind sbm3_ind]) = [];
    delete(M(Mind))

    % make sure certain objects are visible:
    makeVisList = {MinOrdCheckbox,bandpop,...
      passframe,stopframe,...
      passframe1,stopframe1,ax,Lresp,L1,L2};
      
    for i=1:length(makeVisList)  
        set(makeVisList{i},'visible','on')
    end
          
else  % if radio1 not created, assume none of the others are either
       % clear tool in this case
    filtdes('clear')
  
    passframe = fdspec('style','frame',...
                       'tag','passframe',...
                       'position',[4 7],'label','Passband',...
                       'help','fdobjhelp');
                       
    stopframe = fdspec('style','frame','position',[8 11],'label','Stopband',...
            'tag','stopframe',...
            'help','fdobjhelp');
            
    MinOrdCheckbox = fdspec('style','checkbox','string','Minimum Order',...
                    'value',1,...
                    'tag','minordcheckbox','position',1,...
                    'help','fdobjhelp');
    
    order = fdspec('style','edit','label','Order','tag','order','integer',1,...
                   'range',[0 Inf],'position',2,...
                   'help','fdobjhelp');
                   
    bandpop = fdspec('style','popupmenu',...
             'BackgroundColor','white',...
             'string',{'lowpass' 'highpass' 'bandpass' 'bandstop'},...
             'label','Type',...
             'tag','bandpop','position',3,...
             'help','fdobjhelp');
            
    passframe1 = fdmeas('style','frame','position',[4 7],'label','Passband',...
            'tag','passframe1',...
            'help','fdobjhelp');
    stopframe1 = fdmeas('style','frame','position',[8 11],'label','Stopband',...
            'tag','stopframe1',...
            'help','fdobjhelp');
            
    order1 = fdmeas('style','text','label','Order','tag','order1',...
            'position',2,'integer',1,...
            'range',[0 Inf],...
            'help','fdobjhelp');
            
    fstr = '%1.4g';

    pb1 = fdspec('style','edit','position',5,'tag','pb1','format',fstr,...
                       'help','fdobjhelp');
    pb2 = fdspec('style','edit','position',6,'tag','pb2','format',fstr,...
                       'help','fdobjhelp');
    pb3 = fdspec('style','edit','position',7,'tag','pb3','format',fstr,...
                       'help','fdobjhelp');
    sb1 = fdspec('style','edit','position',9,'tag','sb1','format',fstr,...
                       'help','fdobjhelp');
    sb2 = fdspec('style','edit','position',10,'tag','sb2','format',fstr,...
                       'help','fdobjhelp');
    sb3 = fdspec('style','edit','position',11,'tag','sb3','format',fstr,...
                       'help','fdobjhelp');

    pbm1 = fdmeas('style','edit','position',5,'tag','pbm1','format',fstr,...
                       'help','fdobjhelp');
    pbm2 = fdmeas('style','edit','position',6,'tag','pbm2','format',fstr,...
                       'help','fdobjhelp');
    pbm3 = fdmeas('style','edit','position',7,'tag','pbm3','format',fstr,...
                       'help','fdobjhelp');
    sbm1 = fdmeas('style','edit','position',9,'tag','sbm1','format',fstr,...
                       'help','fdobjhelp');
    sbm2 = fdmeas('style','edit','position',10,'tag','sbm2','format',fstr,...
                       'help','fdobjhelp');
    sbm3 = fdmeas('style','edit','position',11,'tag','sbm3','format',fstr,...
                       'help','fdobjhelp');
    
    ax = fdax('tag','ax','title',xlate('Frequency Response'),...
              'xlabel',xlate('Frequency'),...
              'ylabel',xlate('Magnitude (dB)'),...
              'help','fdobjhelp');
    
    co = get(0,'defaultaxescolororder');
    lo = get(0,'defaultaxeslinestyleorder');
    
    % response line needs to be at bottom of stacking order:
    Lresp = fdline('tag','response','erasemode','normal','color',co(1,:),...
                       'help','fdobjhelp');
                   
    L1 = fdline('tag','passband','color',co(min(3,size(co,1)),:),...
            'linewidth',2,...
            'help','fdobjhelp');

    L2 = fdline('tag','stopband','color',co(min(3,size(co,1)),:),...
            'linewidth',2,...
            'help','fdobjhelp');
            
    L3_1 = fdline('xdata',[0 0],'ydata',[-1000 1000],...
                   'tag','L3_1',...
                   'visible','off',...
                   'erasemode','xor',...
                   'affectlimits','off',...
                   'segmentdragmode',{'lr'},...
                   'segmentpointer',{'lrdrag'},...
                   'color',co(min(2,size(co,1)),:),...
                   'help','fdobjhelp');
                   
    L3_2 = fdline('xdata',[0 0],'ydata',[-1000 1000],...
                   'tag','L3_2',...
                   'visible','off',...
                   'erasemode','xor',...
                   'affectlimits','off',...
                   'segmentdragmode',{'lr'},...
                   'segmentpointer',{'lrdrag'},...
                   'color',co(min(2,size(co,1)),:),...
                   'help','fdobjhelp');

end
pbspecs = [pb1; pb2; pb3];
sbspecs = [sb1; sb2; sb3];
pbmeasures = [pbm1; pbm2; pbm3];
sbmeasures = [sbm1; sbm2; sbm3];


function changeToText(obj)
% changes FDSPEC or FDMEAS object's style to text
% sets position in case new style has different positioning
%  (which is the case when coming from edit on the Mac)
    bgcolor = get(0,'defaultuicontrolbackgroundcolor');
    for i = 1:length(obj) 
        set(obj(i),'style','text',...
                   'backgroundcolor',bgcolor)
        set(obj(i),'position',obj(i).position)
    end
    
function changeToEdit(obj)
% changes FDSPEC or FDMEAS object's style to edit
% sets position in case new style has different positioning
%  (which is the case when coming from text on the Mac)
    for i = 1:length(obj) 
        set(obj(i),'style','edit',...
                   'backgroundcolor','w')
        set(obj(i),'position',obj(i).position)
    end
    
function xlim = xlimpassband(type,Fs,f1,f2,f3,f4)
% returns passband xlimits 
switch type
case 1 % lowpass
    xlim = [0 f1];
case 2 % highpass
    xlim = [f2 Fs/2];
case 3 % bandpass
    xlim = [f2 f3];
case 4
    xlim = [0 Fs/2];
end
dxl = (xlim(2)-xlim(1))*.1;
xlim = inbounds(xlim+[-dxl/2 dxl/2],[0 Fs/2]);


function [ind,peaks] = findpeaks(y)
% FINDPEAKS  Find peaks in real vector.
%  ind = findpeaks(y) finds the indices (ind) which are
%  local maxima in the sequence y.  
%
%  [ind,peaks] = findpeaks(y) returns the value of the peaks at 
%  these locations, i.e. peaks=y(ind);

y = y(:)';

switch length(y)
case 0
    ind = [];
case 1
    ind = 1;
otherwise
    dy = diff(y);
    not_plateau_ind = find(dy~=0);
    ind = find( ([dy(not_plateau_ind) 0]<0) & ([0 dy(not_plateau_ind)]>0) );
    ind = not_plateau_ind(ind);
    if y(1)>y(2)
        ind = [1 ind];
    end
    if y(end-1)<y(end)
        ind = [ind length(y)];
    end
end

if nargout > 1
    peaks = y(ind);
end


function updateRanges(freq_ind,f1,f2,f3,f4)
% update ranges of frequency objects
% Inputs:
%   freq_ind - vector of indices of frequencies that have changed
%   f1,f2,f3,f4 - fdspec or fdmeas objects

    for i = 1:length(freq_ind)
        switch freq_ind(i)
        case 1
            r = get(f2,'range');
            set(f2,'range',[get(f1,'value') r(2)])
        case 2
            r = get(f1,'range');
            set(f1,'range',[r(1) get(f2,'value')])
            r = get(f3,'range');
            set(f3,'range',[get(f2,'value') r(2)])
        case 3
            r = get(f2,'range');
            set(f2,'range',[r(1) get(f3,'value')])
            r = get( f4,'range');
            set(f4,'range',[get(f3,'value') r(2)])
        case 4
            r = get(f3,'range');
            set(f3,'range',[r(1) get(f4,'value')])
        end
    end


function [continueFlag,str] = largeWarning(n,msg)
% If msg = 'motion' or 'up':
%    return an error string that the filter order is too large
% If msg = anything else:
%    issue a warning that filter order is very large 
%    and prompt user if they really want to do this
    str = { [num2str(n) ' is a very large filter order for']
            'this type of filter.  This may take a very long time'
            'and/or cause unpredictable results.  Are you sure you'
            'want to design this filter?'};
    if any(strcmp(msg,{'motion', 'up'}))
        continueFlag = 0;
        str = ['Filter order ' num2str(n) ' too large for this type of filter.'];
    else
        ans = questdlg(str,'Large Filter Order','Yes','No','No');
        continueFlag = strcmp(ans,'Yes');
        str = ['Filter order ' num2str(n) ' too large for this type of filter.'];
    end
    
    
function [xd1,xd2] = validateBands(xd1,xd2,type,f_ind,f,f1,f2,f3,f4,Fs)
% Function which makes sure frequency bands are legal, and fixes them if not
% Inputs:
%    xd1, xd2 - xdata of passband (xd1) and stopband (xd2) lines
%    type - filter type, 1=lp,2=hp,3=bp,4=bs
%    f_ind - index of frequency which has changed
%    f - frequency value vector, unnormalized
%    f1,f2,f3,f4 - fdspec or fdmeas objects - their values may be
%      changed during the execution of this function
%    Fs - sampling frequency

    if all(diff(f)>0)
        return
    end
    if type < 3
        f = f(1:2);
    end
    fobjs = [f1 f2 f3 f4];
    df = f(f_ind) - get(fobjs(f_ind),'lastvalue');
    [f,f_ind] = pushedges(f,f_ind,Fs,df);
    
    for ii = 1:length(f_ind)
        set(fobjs(f_ind(ii)),'value',f(f_ind(ii)))
    end
    
    f = [0 f Fs/2];
    switch type
    case 1   % lowpass
        xd1 = [f(1:2) NaN f(1:2)];
        xd2 = f(3:4);
    case 2   % highpass
        xd1 = [f(3:4) NaN f(3:4)];
        xd2 = f(1:2);
    case 3   % bandpass
        xd1 = [f(3:4) NaN f(3:4)];
        xd2 = [f(1:2) NaN f(5:6)];
    case 4   % bandstop
        xd1 = [f(1:2) NaN f(1:2) NaN f(5:6) NaN f(5:6)];
        xd2 = f(3:4);
    end

    
function [f,i] = pushedges(f,i,Fs,df)
% push band edges in frequency vector f, assuming edge i has changed    
% Inputs:
%    f - 2 or 4 element frequency band edge vector
%    i - index of changed element
%    Fs - sampling frequency
%    df - amount that f(i) has changed (so previous f(i) was f(i)-df)
%  Outputs:
%    f - new band edges, a row vector
%    i - indices of any band edges which have changed
    f_old = f(:);
    f = [0; f(:); Fs/2];
    j = i+1;
    sf = sign(df);
    N = length(f);
    while f(j)>0  &  f(j)<Fs/2 & sf ~= 0   % if sf=0 loop becomes infinite
        j = j + sf;
        if f(min(j,j-sf)) >= f(max(j,j - sf))   % need to push this band edge
            f(j) = f(j) + df;
            if ~rem(j,2) % j is even - push next band edge as well
                         % to keep transition band width constant
                f(j+sf) = f(j+sf) + df;
            end
        end
    end
    if (j>1) & (j<N) 
        if sf<0
            f = [linspace(0,f(i+1),i+1)'; f(i+2:end)];
        else
            f = [f(1:i); linspace(f(i+1),f(end),N-i)'];
        end
    end
    f = f(2:end-1);
    i = sort([i; find(f~=f_old)]);
    f = f(:)';
    
    
function [H,f] = chirpfreqz(num,den,fstart,fend,Fs,M)
%Compute frequency response of num,den using chirp z-transform
% Inputs:
%    num, den - filter coefficients
%    fstart, fend - starting and ending frequencies, in Hz
%    Fs - sampling frequency, in Hz 
%    M - number of points
% Outputs:
%    H - frequency response
%    f - frequencies = linspace(fstart,fend,M)

    delta_f = (fend - fstart)/(M-1)*2*pi/Fs;
    c = {M exp(-j*delta_f)  exp(j*fstart*2*pi/Fs)};
    H = czt(num,c{:})./czt(den,c{:});
    f = linspace(fstart,fend,M);
    
function H = dft(num,den,f,Fs)
%Compute frequency response of num,den using dft
% Inputs:
%    num, den - filter coefficients
%    f - frequency vector, in Hz
%    Fs - sampling frequency, in Hz 
% Outputs:
%    H - frequency response
    B = exp(-j*(f(:)*2*pi/Fs)*(0:length(num)-1))*num(:);
    A = exp(-j*(f(:)*2*pi/Fs)*(0:length(den)-1))*den(:);
    H = B./A;
    
function filt = updateFiltSpecs(filt)
%Updates filter structure (especially .specs field) from
%version 1.0 to version 2.0
    switch filt.specs.type
    case 1
    end

function [val,errstr] = fdvalidstr(str,complex,integer,range,inclusive);
% Check to see if string is valid given certain constraints.
% Inputs:
%   str - string as entered by user into edit box
%   complex - may the number entered be complex?  boolean, 1=true, 0=false
%   integer - must the string be an integer? boolean
%   range - 2 element real, range(1)<range(2), specifies interval for valid
%           values of val
%   inclusive - 2 element boolean vector, specifies whether min and max
%               in range argument are allowed as values
% Outputs:
%   val - numerical value of entered string, = [] if errstr is not empty
%   errstr - '' if value is valid, otherwise contains brief description
%             of why the str is bad.

    warnsave = warning;
    warning('off')  % turn off in case entry is empty or issues a warning
    val = evalin('base',str,'[]');
    validVal = 1;
    errstr = '';
    if all(size(val)==1)
        if ~complex & val~=real(val)
            validVal = 0;
            errstr = 'Sorry, this value must be real.';
        end
        if validVal & (integer & val~=round(val))
            validVal = 0;
            errstr = 'Sorry, this value must be an integer.';
        end
        if validVal & inclusive(1)
            validVal = validVal * (val>=range(1));
            if ~validVal
                errstr = rangeErrStr(range,inclusive);
            end
        elseif validVal & ~inclusive(1)
            validVal = validVal * (val>range(1));
            if ~validVal
                errstr = rangeErrStr(range,inclusive);
            end
        end
        if validVal & inclusive(2)
            validVal = validVal * (val<=range(2));
            if ~validVal
                errstr = rangeErrStr(range,inclusive);
            end
        elseif validVal & ~inclusive(2)
            validVal = validVal * (val<range(2));
            if ~validVal
                errstr = rangeErrStr(range,inclusive);
            end
        end
    else
        validVal = 0;
        errstr = sprintf(['Sorry, the value you entered either is' ...
                          ' the wrong size (it must be a scalar), or there' ...
                          ' was a problem evaluating it.']);
    end
    if ~isempty(errstr),
        val = [];
    end
    warning(warnsave)

function errstr = rangeErrStr(range,inclusive)
%rangeErrStr

    if all(inclusive == [1 1])
        errstr = sprintf('Sorry, this value must be at least %g and at most %g.',...
                                  range(1),range(2));
    elseif all(inclusive == [1 0])
        errstr = sprintf('Sorry, this value must be at least %g and less than %g.',...
                                  range(1),range(2));
    elseif all(inclusive == [0 1])
        errstr = sprintf('Sorry, this value must be greater than %g and at most %g.',...
                                  range(1),range(2));
    elseif all(inclusive == [0 0])
        errstr = sprintf('Sorry, this value must be greater than %g and less than %g.',...
                                  range(1),range(2));
    else
        error('inclusive value not set correctly')
    end
    

function setLines(module,L1,L2,setOrderFlag,type,f,Fs,...
                  minpass,maxpass,minstop,dragUpperPassband)
% NOTE: most modules must set setOrderFlag to 0 because it is possible
%  to drag L1 and L2 in set order mode
    if nargin<11
        % this input flag determines whether it is possible to
        % drag the upper passband line (desirable in fdkaiser, fdremez,
        % and fdfirls, but not for the 4 IIR routines)
        dragUpperPassband = 0;
    end
    switch type
    case 1   % lowpass
        set(L1,'xdata',[f(1:2) NaN f(1:2)]*Fs/2,...
               'ydata',[maxpass maxpass NaN minpass minpass])
        if ~setOrderFlag
            set(L1,...
               'vertexdragmode',{'none' 'lr' 'none' 'none' 'lr'},...
               'vertexdragcallback',...
                  {'' [module '(''L1drag'',1,2)'] '' '' ...
                  [module '(''L1drag'',1,5)']},...
               'vertexpointer',{'' 'lrdrag' '' '' 'lrdrag'})
        end
        set(L2,'xdata',[f(3:4)]*Fs/2,'ydata',[minstop minstop])
        if ~setOrderFlag
            set(L2,...
               'vertexdragmode',{'lr' 'none'},...
               'vertexdragcallback',...
                  {[module '(''L2drag'',1,1)'] ''},...
               'vertexpointer',{'lrdrag' ''})
        end
    case 2   % highpass
        set(L1,'xdata',[f(3:4) NaN f(3:4)]*Fs/2,...
               'ydata',[maxpass maxpass NaN minpass minpass ])
        if ~setOrderFlag
            set(L1,...
               'vertexdragmode',{'lr' 'none' 'none' 'lr' 'none'},...
               'vertexdragcallback',...
                  {[module '(''L1drag'',2,1)'] '' '' ...
                   [module '(''L1drag'',2,4)'] ''},...
               'vertexpointer',{'lrdrag' '' '' 'lrdrag' ''})
        end
        set(L2,'xdata',[f(1:2)]*Fs/2,'ydata',[minstop minstop])
        if ~setOrderFlag
            set(L2,...
               'vertexdragmode',{'none' 'lr'},...
               'vertexdragcallback',...
                  {'' [module '(''L2drag'',2,2)']},...
               'vertexpointer',{'' 'lrdrag'})
        end
    case 3   % bandpass
        set(L1,'xdata',[f(3:4) NaN f(3:4)]*Fs/2,...
               'ydata',[maxpass maxpass NaN minpass minpass])
        if ~setOrderFlag
            set(L1,...
               'vertexdragmode',{'lr' 'lr' 'none' 'lr' 'lr'},...
               'vertexdragcallback',...
                  {[module '(''L1drag'',3,1)'] [module '(''L1drag'',3,2)'] '' ...
                   [module '(''L1drag'',3,4)'] [module '(''L1drag'',3,5)']},...
               'vertexpointer',{'lrdrag' 'lrdrag' '' 'lrdrag' 'lrdrag'})
        end
        set(L2,'xdata',[f(1:2) NaN f(5:6)]*Fs/2,...
               'ydata',[ minstop minstop NaN minstop minstop])
        if ~setOrderFlag
            set(L2,...
               'vertexdragmode',{'none' 'lr' 'none' 'lr' 'none'},...
               'vertexdragcallback',...
                  {'' [module '(''L2drag'',3,2)'] '' ...
                   [module '(''L2drag'',3,4)'] ''},...
               'vertexpointer',{'' 'lrdrag' '' 'lrdrag' ''})
        end
    case 4   % bandstop
        set(L1,'xdata',[f(1:2) NaN f(1:2) NaN f(5:6) NaN f(5:6)]*Fs/2,...
               'ydata',[ maxpass maxpass NaN minpass minpass NaN ...
                         maxpass maxpass NaN minpass minpass])
        if ~setOrderFlag
            set(L1,...
               'vertexdragmode',{'none' 'lr'   'none' 'none' 'lr' 'none'...
                                 'lr'   'none' 'none' 'lr'   'none'},...
               'vertexdragcallback',...
                  {'' [module '(''L1drag'',4,2)'] '' '' ...
                                                [module '(''L1drag'',4,5)'] '' ...
                   [module '(''L1drag'',4,7)'] '' '' ...
                   [module '(''L1drag'',4,10)'] ''},...
               'vertexpointer',{'' 'lrdrag' '' '' 'lrdrag' '' 'lrdrag' '' '' ...
                                     'lrdrag' ''})
        end
        set(L2,'xdata',[f(3:4)]*Fs/2,'ydata',[minstop minstop])
        if ~setOrderFlag
            set(L2,...
               'vertexdragmode',{'lr' 'lr'},...
               'vertexdragcallback',...
                  {[module '(''L2drag'',4,1)'] [module '(''L2drag'',4,2)']},...
               'vertexpointer',{'lrdrag' 'lrdrag'})
        end
    end
    if setOrderFlag
        set(L1,'vertexdragmode',{'none'},'vertexpointer',{''})
        set(L2,'vertexdragmode',{'none'},'vertexpointer',{''})
    end           
    switch type
    case 1   % lowpass
        if ~dragUpperPassband
            set(L1,'segmentdragmode',{'none' 'none' 'none' 'ud'},...
                   'segmentdragcallback',...
                       {'' '' '' [module '(''Rpdrag'',1,4)']},...
                   'segmentpointer',{'' '' '' 'uddrag'})
        else
            set(L1,'segmentdragmode',{'ud' 'none' 'none' 'ud'},...
                   'segmentdragcallback',...
                       {[module '(''Rpdrag'',1,1)'] '' ...
                        '' [module '(''Rpdrag'',1,4)']},...
                   'segmentpointer',{'uddrag' '' '' 'uddrag'})
        end
        set(L2,'segmentdragmode',{'ud'},...
               'segmentdragcallback',{[module '(''Rsdrag'',1,1)']},...
               'segmentpointer',{'uddrag'})
               
    case 2   % highpass
        if ~dragUpperPassband
            set(L1,'segmentdragmode',{'ud'},...
                   'segmentdragcallback',...
                        {'' '' '' [module '(''Rpdrag'',2,4)']},...
                   'segmentpointer',{'' '' '' 'uddrag'})
        else
            set(L1,'segmentdragmode',{'ud'},...
                   'segmentdragcallback',...
                        {[module '(''Rpdrag'',2,1)'] '' ...
                         '' [module '(''Rpdrag'',2,4)']},...
                   'segmentpointer',{'uddrag' '' '' 'uddrag'})
        end
        set(L2,'segmentdragmode',{'ud' 'none' 'none' 'ud'},...
               'segmentdragcallback',{[module '(''Rsdrag'',2,1)']},...
               'segmentpointer',{'uddrag'})
               
    case 3   % bandpass
        if ~dragUpperPassband
            set(L1,'segmentdragmode',{'none' 'none' 'none' 'ud'},...
                   'segmentdragcallback',...
                      {'' '' '' [module '(''Rpdrag'',3,4)']},...
                   'segmentpointer',{'' '' '' 'uddrag'})
        else
            set(L1,'segmentdragmode',{'ud' 'none' 'none' 'ud'},...
                   'segmentdragcallback',...
                      {[module '(''Rpdrag'',3,1)'] '' ...
                       '' [module '(''Rpdrag'',3,4)']},...
                   'segmentpointer',{'uddrag' '' '' 'uddrag'})
        end      
        set(L2,'segmentdragmode',{'ud' '' '' 'ud'},...
               'segmentdragcallback',...
                  {[module '(''Rsdrag'',3,1)'] '' '' [module '(''Rsdrag'',3,4)']},...
               'segmentpointer',{'uddrag' '' '' 'uddrag'})
               
    case 4   % bandstop
        if ~dragUpperPassband
            set(L1,'segmentdragmode',{'none' 'none' 'none' 'ud' 'none' 'none'...
                                      'none' 'none' 'none' 'ud'},...
                   'segmentdragcallback',...
                      {'' '' '' ...
                       [module '(''Rpdrag'',4,4)'] '' '' ...
                       '' '' '' ...
                       [module '(''Rpdrag'',4,10)']},...
                   'segmentpointer',{'' '' '' 'uddrag' '' '' '' '' '' 'uddrag'})
        else
            set(L1,'segmentdragmode',{'ud' 'none' 'none' 'ud' 'none' 'none'...
                                      'ud' 'none' 'none' 'ud'},...
                   'segmentdragcallback',...
                      {[module '(''Rpdrag'',4,1)'] '' '' ...
                       [module '(''Rpdrag'',4,4)'] '' '' ...
                       [module '(''Rpdrag'',4,7)'] '' '' ...
                       [module '(''Rpdrag'',4,10)']},...
                   'segmentpointer',{'' '' '' 'uddrag' '' '' '' '' '' 'uddrag'})
        end
        set(L2,'segmentdragmode',{'ud'},...
               'segmentdragcallback',{[module '(''Rsdrag'',4,1)']},...
               'segmentpointer',{'uddrag'})
    end


function [newfilt, errstr] = callModuleApply(module,filt,msg,varargin)
% wrapper for feval of module's apply function, in case it errors out 
    newfilt = filt;  % in case of error, return same filter that was passed in
    errstr = '';  % assume no error
    apply_err = 0;
    eval('[newfilt, errstr]=feval(module,''apply'',filt,msg,varargin{:});',...
         'apply_err = 1;')
    if apply_err
        errstr = lasterr;
    end
 
function pokeFilterMeasurements(module,type,f1,f2,f3,f4,Rp,Rs,Fs)
% This function is called by the modules
%    fdkaiser  fdbutter  fdcheby1  fdcheby2
% after a measurement has been edited (or a red line dragged).
% This will update the filter spec in the filter designer
% according to the new values of the measurements.  Note that
% the filter will NOT be imported into the SPTool, until it has
% been redesigned.
    fig = get(f1,'parent');
    ud = get(fig,'userdata');
    f = getFrequencyValues(type,f1,f2,f3,f4,Fs);
    moduleSpecs = getfield(ud.filt.specs,module);
    moduleSpecs.f = f;
    moduleSpecs.Rp = get(Rp,'value');
    moduleSpecs.Rs = get(Rs,'value');
    ud.filt.specs = setfield(ud.filt.specs,module,moduleSpecs);
    set(fig,'userdata',ud)
    
 
function f = getFrequencyValues(type,f1,f2,f3,f4,Fs);            
if type < 3  % low or high pass
    f = [0 f1.value f2.value Fs/2]*2/Fs;
else
    f = [0 f1.value f2.value f3.value f4.value Fs/2]*2/Fs;
end


function newspecs = updateSpecStruc(specs)
% update version '1.0' filter design structure to version '2.0'
    if isempty(specs)
        newspecs = specs;
        return
    end
    % first get common fields
    moduleSpecs.setOrderFlag = (specs.ordermode == 2);
    moduleSpecs.type = specs.type;
    moduleSpecs.f = [0; specs.f(:); 1];
    moduleSpecs.Rp = specs.Rp;
    moduleSpecs.Rs = specs.Rs;
    if specs.ordermode == 1
        moduleSpecs.order = specs.order.auto;
    else
        moduleSpecs.order = specs.order.manual;
    end
    if specs.specialparamsmode == 1
        special = specs.special.auto;
    else
        special = specs.special.manual;
    end
    switch specs.method
    case 1
        newspecs.currentModule = 'fdremez';
        newspecs = setfield(newspecs,newspecs.currentModule,moduleSpecs);
        if specs.type == 1 | specs.type == 4
            newspecs.fdremez.wt = special([1 2]);
        else
            newspecs.fdremez.wt = special([2 1]);
        end
    case 2
        newspecs.currentModule = 'fdfirls';
        newspecs = setfield(newspecs,newspecs.currentModule,moduleSpecs);
        newspecs.fdfirls.setOrderFlag = 1;
        if specs.type == 1 | specs.type == 4
            newspecs.fdfirls.wt = special([1 2]);
        else
            newspecs.fdfirls.wt = special([2 1]);
        end
    case 3
        newspecs.currentModule = 'fdkaiser';
        newspecs = setfield(newspecs,newspecs.currentModule,moduleSpecs);
        newspecs.fdkaiser.Wn = special(2:end);
        newspecs.fdkaiser.Beta = special(1);
        newspecs.fdkaiser.wind = kaiser(newspecs.fdkaiser.order+1,newspecs.fdkaiser.Beta);
    case 4
        newspecs.currentModule = 'fdbutter';
        newspecs = setfield(newspecs,newspecs.currentModule,moduleSpecs);
        newspecs.fdbutter.w3db = special;
    case 5
        newspecs.currentModule = 'fdcheby1';
        newspecs = setfield(newspecs,newspecs.currentModule,moduleSpecs);
        newspecs.fdcheby1.Fpass = special;
    case 6
        newspecs.currentModule = 'fdcheby2';
        newspecs = setfield(newspecs,newspecs.currentModule,moduleSpecs);
        newspecs.fdcheby2.Fstop = special;
    case 7
        newspecs.currentModule = 'fdellip';
        newspecs = setfield(newspecs,newspecs.currentModule,moduleSpecs);
        newspecs.fdellip.Fpass = special;
    end


function y = rmax(x)
% Y=RMAX(X)   RUNNING MAXIMUM 
    y = x;
    [ind,peaks] = findpeaks(y);
    [sortPeak,sortPeakInd] = sort(peaks);
    ind = ind(sortPeakInd);
    for i = 1:length(ind)
        if i < length(ind)
            nextPeakInd = min(ind(i+1:end))-1;
            jkl = find(y(ind(i):nextPeakInd) <= sortPeak(i));
            y(ind(i):(ind(i)+length(jkl)-1)) = sortPeak(i);
        else
            y(ind(i):end) = sortPeak(i);
        end
    end
    
function y = rmin(x)
% Y=RMIN(X)   RUNNING MINIMUM 
    y = -rmax(-x);
    
    
function showBandConfigWindow(fig,h)
% Put up a figure to help people understand how the parameters 
% describe the filter specifications
    cfig = findobj(allchild(0),'tag','BandConfigWindow');
    if isempty(cfig)
    % create figure
        cfig = figure('name','Band Configurations',...
            'dockcontrols','off',...
            'tag','BandConfigWindow');
    end
    figure(cfig)
    co = get(0,'defaultaxescolororder');
    
    filt1 =   [  
     0.017943
     0.030958
    -0.018458
      -0.1084
    -0.081255
      0.15304
      0.40953
      0.40953
      0.15304
    -0.081255
      -0.1084
    -0.018458
     0.030958
     0.017943];
     
     filt2 = [
   -0.0033438
    -0.011265
     0.049015
     -0.05273
    -0.027279
     0.092079
     0.032446
     -0.31319
      0.46599
     -0.31319
     0.032446
     0.092079
    -0.027279
     -0.05273
     0.049015
    -0.011265
   -0.0033438];
   
    filt3 = [
     0.013158
    -0.015591
    -0.034564
     0.018044
    0.0080384
     0.048938
      0.10829
     -0.18719
     -0.25071
       0.2891
       0.2891
     -0.25071
     -0.18719
      0.10829
     0.048938
    0.0080384
     0.018044
    -0.034564
    -0.015591
     0.013158];
     
    filt4 = [
    -0.038718
  -4.2476e-06
     -0.10237
  -1.6168e-05
   -0.0014099
  -2.6903e-05
      0.31052
  -3.1884e-05
      0.50141
  -3.1884e-05
      0.31052
  -2.6903e-05
   -0.0014099
  -1.6168e-05
     -0.10237
  -4.2476e-06
    -0.038718];

    warnsave = warning;
    warning off   % turn off in case log of 0 shows up
         
    % LOWPASS
    subplot(2,2,1)
    h1=plot([0 .4 NaN 0 .4 NaN .6 1],[2 2 NaN -2 -2 NaN -40 -40]);
    set(h1,'color',co(2,:),'linewidth',2)
    
    set(gca,'xtick',[0 .4 .6 1],'xticklabel',{'0','Fp','Fs','Fsamp/2'})
    set(gca,'ytick',[-40 -2 2],'yticklabel',{'-Rs','',''})
    t1=text(0,0,'Rp \{ ');
    set(t1,'horizontalalignment','right','clipping','off')
    title('Lowpass')
    grid on
    [H,f]=freqz(filt1,1,300);
    hold on, plot(f/pi,20*log10(abs(H))); hold off
    set(gca,'ylim',[-60 10],'xlim',[0 1])
    
    % HIGHPASS
    subplot(2,2,2)
    h1=plot([.6 1 NaN .6 1 NaN 0 .4],[2 2 NaN -2 -2 NaN -40 -40]);
    set(h1,'color',co(2,:),'linewidth',2)
    
	 set(gca,'xtick',[0 .4 .6 1],'xticklabel',{'0','Fs','Fp','Fsamp/2'})
    set(gca,'ytick',[-40 -2 2],'yticklabel',{'-Rs','',''})
    t1=text(0,0,'Rp \{ ');
    set(t1,'horizontalalignment','right','clipping','off')
    title('Highpass')
    grid on
    [H,f]=freqz(filt2,1,300);
    hold on, plot(f/pi,20*log10(abs(H))); hold off
    set(gca,'ylim',[-60 10],'xlim',[0 1])
    
    % BANDPASS
    subplot(2,2,3)
    h1=plot([0 .2 NaN .35 .65 NaN .35 .65 NaN .8 1],[-40 -40 NaN 2 2 NaN -2 -2 NaN -40 -40]);
    set(h1,'color',co(2,:),'linewidth',2)
    
    set(gca,'xtick',[0 .2 .35 .65 .8 1],...
        'xticklabel',{'0','Fs1','Fp1','Fp2','Fs2','Fsamp/2'})
    set(gca,'ytick',[-40 -2 2],'yticklabel',{'-Rs','',''})
    t1=text(0,0,'Rp \{ ');
    set(t1,'horizontalalignment','right','clipping','off')
    title('Bandpass')
    grid on
    [H,f]=freqz(filt3,1,300);
    hold on, plot(f/pi,20*log10(abs(H))); hold off
    set(gca,'ylim',[-60 10],'xlim',[0 1])
    
    % BANDSTOP
    subplot(2,2,4)
    h1=plot([0 .2 NaN 0 .2 NaN .35 .65 NaN .8 1 NaN .8 1],...
         [2 2 NaN -2 -2 NaN -40 -40 NaN 2 2 NaN -2 -2]);
    set(h1,'color',co(2,:),'linewidth',2)
    
    set(gca,'xtick',[0 .2 .35 .65 .8 1],...
        'xticklabel',{'0','Fp1','Fs1','Fs2','Fp2','Fsamp/2'})
    set(gca,'ytick',[-40 -2 2],'yticklabel',{'-Rs','',''})
    t1=text(0,0,'Rp \{ ');
    set(t1,'horizontalalignment','right','clipping','off')
    title('Bandstop')
    grid on
    [H,f]=freqz(filt4,1,300);
    hold on, plot(f/pi,20*log10(abs(H))); hold off    
    set(gca,'ylim',[-60 10],'xlim',[0 1])
    
    warning(warnsave)
    
% [EOF] fdutil.m
