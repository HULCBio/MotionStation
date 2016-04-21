% function [out1,out2,out3,out4] = ourslid(objhan,message,in1,in2,in3,in4,in5)

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.9.2.3 $

function [out1,out2,out3,out4] = ourslid(objhan,message,in1,in2,in3,in4,in5)

 mlvers = version;
 mlvers = str2double(mlvers(1));
 if mlvers < 4
    error('Need at least MATLAB Version 4 to run this');
    return
 end

 if nargin <= 6
    winhan = gcf;
 else
    winhan = in5;
 end
 if nargin == 0
   objhan = 0; % dummy, not used
   message = 'create';
   winhan = gcf;
 elseif isempty(objhan)
    objhan = get(gcf,'currentobject');
 end

if strcmp(message,'create')
    pos = in1;
    nl = in2(1);
    lpp = in2(2);
    ourval = in2(3);
    val = (ourval-nl+lpp-1)/(lpp-nl);
    out1 = uicontrol(winhan,'style','slider','position',pos,...
        'callback',['ourslid([],''slidermotion'');' in3],'value',val);
    allinfo = [nl lpp val ourval in4];  % in4 is master tool
    set(out1,'userdata',allinfo);
    % Horizontal:  LEFT == nl-lpp+1, RIGHT = 1;
    % Vertical:    TOP == 1, Bottom = nl-lpp+1;
elseif strcmp(message,'slidermotion')
    allinfo = get(objhan,'userdata');
    val = get(objhan,'value');
    nl = allinfo(1);
    lpp = allinfo(2);
    lastval = allinfo(3);
    ourval = allinfo(4);
    [clo,index] = min(abs([val-lastval-.1 val-lastval-.01 val-lastval+.1 val-lastval+.01 val-lastval]));
%                           1 page up         1 line up       1 page down   1 line down    same
    if index(1) == 1 & abs(clo(1)) < 2e-3
        ourval = max([ourval-lpp+1 1]);     %page up
        val = (ourval-nl+lpp-1)/(lpp-nl);
    elseif index(1) == 2 & abs(clo(1)) < 2e-3
        ourval = max([ourval-1 1]);   % line up
        val = (ourval-nl+lpp-1)/(lpp-nl);
    elseif index(1) == 3 & abs(clo(1)) < 2e-3
        ourval = min([ourval+(lpp-1) nl-lpp+1]);   % page down
        val = (ourval-nl+lpp-1)/(lpp-nl);
    elseif index(1) == 4 & abs(clo(1)) < 2e-3
        ourval = min([ourval+1 nl-lpp+1]);    % line down
        val = (ourval-nl+lpp-1)/(lpp-nl);
    elseif index(1) == 5 & abs(clo(1)) < 2e-3
        % disp('same');
        ourval = ourval;
        val = (ourval-nl+lpp-1)/(lpp-nl);
    else
        % disp('General Move')
        ourval = round((lpp-nl)*val + (nl-lpp+1));
        val = (ourval-nl+lpp-1)/(lpp-nl);
    end
    allinfo(3:4) = [val ourval];
    set(objhan,'value',val,'userdata',allinfo);
elseif strcmp(message,'getourval')
    allinfo = get(objhan,'userdata');
    out1 = allinfo(4);
elseif strcmp(message,'setourval')
    allinfo = get(objhan,'userdata');
    allinfo(4) = in1;
    nl = allinfo(1);
    lpp = allinfo(2);
    val = (allinfo(4)-nl+lpp-1)/(lpp-nl);
    allinfo(3) = [val];
    set(objhan,'value',val,'userdata',allinfo);
elseif strcmp(message,'setnl')
    allinfo = get(objhan,'userdata');
    allinfo(1) = in1;
    nl = allinfo(1);
    lpp = allinfo(2);
    ourval = allinfo(4);
    val = (ourval-nl+lpp-1)/(lpp-nl);
    allinfo(3) = [val];
    set(objhan,'value',val,'userdata',allinfo);
elseif strcmp(message,'setlpp')
    allinfo = get(objhan,'userdata');
    allinfo(2) = in1;
    nl = allinfo(1);
    lpp = allinfo(2);
    ourval = allinfo(4);
    val = (ourval-nl+lpp-1)/(lpp-nl);
    allinfo(3) = [val];
    set(objhan,'value',val,'userdata',allinfo);
elseif strcmp(message,'getlpp')
    allinfo = get(objhan,'userdata');
    out1 = allinfo(2);
elseif strcmp(message,'getinfo')
    allinfo = get(objhan,'userdata');
    out1 = allinfo(4);
else
    disp('Warning: Message Not found')
end
