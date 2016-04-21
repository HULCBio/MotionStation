% updownb
%
% make up a scrolling up/down buttons a single entity
%

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.8.2.3 $

function [out1,out2,out3] = updownb(in1,in2,in3,in4,in5,in6,in7,in8)

if strcmp(in1,'create')
   fighand     = in2;
   dimvec      = in3;
   textname    = in4;
   buttoncolor = in5;
   callbacks   = in6;
   default     = in7;
   if nargin>7
     minmax_vals = in8;
   else
     minmax_vals = [0 inf];
   end

%       BASIC DIMENSIONS
% dimvec = [ fx; fy; yybo; myybo; xxbo; mxgap; ybotbo; ytopbo;...
%            txt_ht; txt_w;etxt_w; pb_ht; pb_gap];
    fx = dimvec(1);
    fy = dimvec(2);
    yybo = dimvec(3);
    myybo = dimvec(4);
    xxbo = dimvec(5);
    mxgap = dimvec(6);
    ybotbo = dimvec(7);
    ytopbo = dimvec(8);

    txt_ht = dimvec(9);
    txt_w = dimvec(10);
    etxt_w = dimvec(11);
    pb_ht = dimvec(12);
    pb_gap = dimvec(13);
    pb_w = (txt_w+mxgap+etxt_w-pb_gap)/2;
    ofrh = yybo + txt_ht + myybo + pb_ht  + yybo;
    ofrw = xxbo + txt_w  + mxgap + etxt_w + xxbo;
%%%%%%%%%%%%%%%%%%%%%
    % FRAME LOCATION
    ofrx = fx;
    ofry = fy;
%%%%%%%%%%%%%%%%%%%%%
%   FRAME
        frame = uicontrol(fighand,'style','frame',...
            'position',[ofrx ofry ofrw ofrh]);

        dechan = uicontrol(fighand,'style','pushbutton',...
            'position',[ofrx+xxbo ofry+yybo pb_w pb_ht],...
            'string','--',...
	    'userdata',frame,...
            'callback',['updownb(''butdec'');' deblank(callbacks(3,:))]);
        inchan = uicontrol(fighand,'style','pushbutton',...
            'position',[ofrx+xxbo+pb_w+pb_gap ofry+yybo pb_w pb_ht],...
            'string','++',...
	    'userdata',frame,...
            'callback',['updownb(''butinc'');' deblank(callbacks(2,:))]);

        texthan = uicontrol(fighand,'style','text',...
            'position',[ofrx+xxbo ofry+yybo+pb_ht+myybo-2 txt_w txt_ht],...
            'string',textname,...
            'horizontalalignment','right');
        edithan = uicontrol(fighand,'style','edit',...
            'position',...
        [ofrx+xxbo+txt_w+mxgap ofry+yybo+pb_ht+myybo etxt_w-2 txt_ht-2],...
            'string',int2str(default),...
            'enable','on',...
            'backgroundcolor',buttoncolor(1,:),...
	    'userdata',frame,...
            'callback',['updownb(''edit'');' deblank(callbacks(1,:))]);

	stdata = [frame;texthan;edithan;inchan;dechan;default;minmax_vals(1);minmax_vals(2);nan];

        out1 = [frame];
	set(frame,'userdata',stdata);
elseif strcmp(in1,'butdec')
	fh = get(get(gcf,'currentobject'),'userdata');
	updownb('dec',fh);
elseif strcmp(in1,'dec')
	stdata = get(in2,'userdata');
	value = stdata(6);
	minval = stdata(7);
	eshan = stdata(3);
	stdata(9) = value;
	if value-1 >= minval
		value = value-1;
		set(eshan,'string',int2str(value))
		stdata(6) = value;
	end
	set(in2,'userdata',stdata);
elseif strcmp(in1,'butinc')
	fh = get(get(gcf,'currentobject'),'userdata');
	updownb('inc',fh);
elseif strcmp(in1,'inc')
	stdata = get(in2,'userdata');
	value = stdata(6);
	maxval = stdata(8);
	eshan = stdata(3);
	stdata(9) = value;
	if value+1 <= maxval
		value = value+1;
		set(eshan,'string',int2str(value))
		stdata(6) = value;
	end
	set(in2,'userdata',stdata);
elseif strcmp(in1,'dimquery')
%
%       BASIC DIMENSIONS
% dimvec = [ fx; fy; yybo; myybo; xxbo; mxgap; ybotbo; ytopbo; txt_ht; txt_w;...
%            etxt_w; pb_ht; pb_gap];
   fighand     = in2;
   dimvec      = in3;
    fx = dimvec(1);
    fy = dimvec(2);
    yybo = dimvec(3);
    myybo = dimvec(4);
    xxbo = dimvec(5);
    mxgap = dimvec(6);
    ybotbo = dimvec(7);
    ytopbo = dimvec(8);

    txt_ht = dimvec(9);
    txt_w = dimvec(10);
    etxt_w = dimvec(11);
    pb_ht = dimvec(12);
    pb_gap = dimvec(13);
    pb_w = (txt_w+mxgap+etxt_w-pb_gap)/2;
    ofrh = yybo + txt_ht + myybo + pb_ht  + yybo;
    ofrw = xxbo + txt_w  + mxgap + etxt_w + xxbo;
    out1 = [fx fy ofrw ofrh];
elseif strcmp(in1,'edit')
    fh = get(get(gcf,'currentobject'),'userdata');
    stdata = get(fh,'userdata');
    maxval = stdata(8);
    minval = stdata(7);
    stdata(9) = stdata(6);
    data = str2double(get(stdata(3),'string'));
    if ~isempty(data)
      if ceil(data)==floor(data) & data>0 & length(data)==1 ...
	 & ~isnan(data) & ~isinf(data)
	if data>round(maxval)
	  set(stdata(3),'string',int2str(stdata(8)));
	  stdata(6) = stdata(8);
        elseif data<round(minval)
	  set(stdata(3),'string',int2str(stdata(7)));
	  stdata(6) = stdata(7);
	else
	  set(stdata(3),'string',int2str(data));
	  stdata(6) = data;
        end
      else
	set(stdata(3),'string',int2str(stdata(6)));
      end
    else
	set(stdata(3),'string',int2str(stdata(6)));
    end
    set(fh,'userdata',stdata);
elseif strcmp(in1,'getetxt')
    hand = in2;
    stdata = get(hand,'userdata');
    out1 = get(stdata(3),'string');
elseif strcmp(in1,'setetxt')
    hand = in2;
    stdata = get(hand,'userdata');
    set(stdata(3),'string',deblank(in3));
elseif strcmp(in1,'gettxt')
    hand = in2;
    stdata = get(hand,'userdata');
    out1 = get(stdata(2),'string');
elseif strcmp(in1,'settxt')
    hand = in2;
    stdata = get(hand,'userdata');
    set(stdata(2),'string',deblank(in3));
elseif strcmp(in1,'getminval')
    hand = in2;
    stdata = get(hand,'userdata');
    out1 = stdata(7);
elseif strcmp(in1,'setminval')
    hand = in2;
    stdata = get(hand,'userdata');
    stdata(7) = in3;
    set(hand,'userdata',stdata);
elseif strcmp(in1,'getmaxval')
    hand = in2;
    stdata = get(hand,'userdata');
    out1 = stdata(8);
elseif strcmp(in1,'setmaxval')
    hand = in2;
    stdata = get(hand,'userdata');
    stdata(8) = in3;
    set(hand,'userdata',stdata);
elseif strcmp(in1,'getval')
    hand = in2;
    stdata = get(hand,'userdata');
    out1 = stdata(6);
elseif strcmp(in1,'getvals')
    hand = in2;
    stdata = get(hand,'userdata');
    out1 = [stdata(6) stdata(9)]; % current, previous
elseif strcmp(in1,'setval')
    hand = in2;
    stdata = get(hand,'userdata');
    stdata(9) = stdata(6);
    stdata(6) = in3;
    set(hand,'userdata',stdata);
elseif strcmp(in1,'enable_++--') % in2 are handles, in3 is either 'on' or 'off'
    hand = in2;
    stdata = get(hand,'userdata');
    set(stdata(3),'enable','on');
    set(stdata(4),'enable','on');
    set(stdata(5),'enable','on');
elseif strcmp(in1,'disable_++--')
    hand = in2;
    stdata = get(hand,'userdata');
    set(stdata(3),'enable','off');
    set(stdata(4),'enable','off');
    set(stdata(5),'enable','off');
else
    display('Error in updownb calling routine')
end
