% updownb2
%
% make up a scrolling up/down buttons a single entity
%

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.9.2.3 $

function [out1,out2,out3] = updownb2(in1,in2,in3,in4,in5,in6,in7,in8,in9,in10)

if strcmp(in1,'create')
   fighand     = in2;
   dimvec      = in3;
   textname1   = in4;
   buttoncolor = in5;
   callbacks   = in6;
   default     = in7;
   textname2   = in8;
   if nargin>8
     minmax_vals = in9;
   else
     minmax_vals = [0 inf];
   end

%       BASIC DIMENSIONS
% dimvec = [ fx; fy; yybo; myybo; xxbo; mxgap; ybotbo; ytopbo;...
%            txt1_ht; txt1_w; etxt1_w; pb_w; pb_gap; txt2_w; etxt2_w];
    fx = dimvec(1);
    fy = dimvec(2);
    yybo = dimvec(3);
    myybo = dimvec(4);
    xxbo = dimvec(5);
    mxgap = dimvec(6);
    ybotbo = dimvec(7);
    ytopbo = dimvec(8);

    txt1_ht = dimvec(9);
    txt1_w = dimvec(10);
    etxt1_w = dimvec(11);
    pb_w  = dimvec(12);
    pb_gap = dimvec(13);
    txt2_w = dimvec(14);
    etxt2_w = dimvec(15);
    pb_ht = txt1_ht-4;
    ofrh = yybo + txt1_ht + yybo;
    ofrw = xxbo + pb_w + pb_gap + pb_w + mxgap + ...
		txt1_w  + mxgap + etxt1_w + mxgap + ...
		txt2_w  + mxgap + etxt2_w + xxbo;
%%%%%%%%%%%%%%%%%%%%%
    % FRAME LOCATION
    ofrx = fx;
    ofry = fy;
%%%%%%%%%%%%%%%%%%%%%
%   FRAME
        frame = uicontrol(fighand,'style','frame',...
            'position',[ofrx ofry ofrw ofrh]);

        dechan = uicontrol(fighand,'style','pushbutton',...
            'position',[ofrx+xxbo ofry+yybo+2 pb_w pb_ht],...
            'string','--',...
	    'userdata',frame,...
            'callback',['updownb2(''butdec'');' deblank(callbacks(3,:))]);
        inchan = uicontrol(fighand,'style','pushbutton',...
            'position',[ofrx+xxbo+pb_w+pb_gap ofry+yybo+2 pb_w pb_ht],...
            'string','++',...
	    'userdata',frame,...
            'callback',['updownb2(''butinc'');' deblank(callbacks(2,:))]);

	dechanx = ofrx+xxbo+pb_w+pb_gap+pb_w;
        text1han = uicontrol(fighand,'style','text',...
            'position',[dechanx+mxgap ofry+yybo-1 txt1_w txt1_ht-2],...
            'string',textname1,...
            'horizontalalignment','right');
	txt1hanx = dechanx+txt1_w+mxgap;

        edit1han = uicontrol(fighand,'style','edit',...
            'position',...
        [txt1hanx+mxgap ofry+yybo etxt1_w-2 txt1_ht-2],...
            'string',int2str(default(1)),...
            'enable','on',...
            'backgroundcolor',buttoncolor(1,:),...
	    'userdata',frame,...
            'callback',['updownb2(''edit1'');' deblank(callbacks(1,:))]);

	ed1x = txt1hanx+mxgap+etxt1_w-2;
        text2han = uicontrol(fighand,'style','text',...
            'position',[ed1x+mxgap ofry+yybo-1 txt2_w txt1_ht-2],...
            'string',textname2,...
            'horizontalalignment','right');
	txt2x = ed1x+mxgap+txt2_w;

        edit2han = uicontrol(fighand,'style','edit',...
            'position',[txt2x+mxgap ofry+yybo etxt2_w-2 txt1_ht-2],...
            'string',int2str(default(2)),...
            'enable','on',...
            'backgroundcolor',buttoncolor(1,:),...
            'userdata',frame,...
            'callback',['updownb2(''edit2'');' deblank(callbacks(4,:))]);

	stdata = [frame;text1han;edit1han;inchan;dechan;...
			default(1);minmax_vals(1);minmax_vals(2);nan;...
			text2han;edit2han;default(2);nan];
        out1 = [frame];
	set(frame,'userdata',stdata);
elseif strcmp(in1,'butdec')
	fh = get(get(gcf,'currentobject'),'userdata');
	updownb2('dec',fh);
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
	updownb2('inc',fh);
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
   fighand     = in2;
   dimvec      = in3;
%
%       BASIC DIMENSIONS
% dimvec = [ fx; fy; yybo; myybo; xxbo; mxgap; ybotbo; ytopbo;...
%            txt1_ht; txt1_w; etxt1_w; pb_w; pb_gap; txt2_w; etxt2_w];
    fx = dimvec(1);
    fy = dimvec(2);
    yybo = dimvec(3);
    myybo = dimvec(4);
    xxbo = dimvec(5);
    mxgap = dimvec(6);
    ybotbo = dimvec(7);
    ytopbo = dimvec(8);

    txt1_ht = dimvec(9);
    txt1_w = dimvec(10);
    etxt1_w = dimvec(11);
    pb_w = dimvec(12);
    pb_gap = dimvec(13);
    txt2_w = dimvec(14);
    etxt2_w = dimvec(15);
    ofrh = yybo + txt1_ht + yybo;
    ofrw = xxbo + pb_w + pb_gap + pb_w + mxgap + ...
		txt1_w  + mxgap + etxt1_w + mxgap + ...
		txt2_w  + mxgap + etxt2_w + xxbo;
    out1 = [fx fy ofrw ofrh];
elseif strcmp(in1,'edit1')
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
elseif strcmp(in1,'edit2')
    fh = get(get(gcf,'currentobject'),'userdata');
    stdata = get(fh,'userdata');
    maxval = stdata(8);
    minval = stdata(7);
    ed1val = stdata(6);
    stdata(13) = stdata(12);
    data = str2double(get(stdata(11),'string'));
    if ~isempty(data)
      if ceil(data)==floor(data) & data>0 & length(data)==1 ...
	 & ~isnan(data) & ~isinf(data)
	if data<round(ed1val)
	  set(stdata(11),'string',int2str(ed1val));
	  stdata(12) = ed1val;
	  stdata(8)  = ed1val;
        elseif data<round(minval)
	  set(stdata(11),'string',int2str(stdata(12)));
	  stdata(11) = stdata(12);
	else
	  set(stdata(11),'string',int2str(data));
	  stdata(12) = data;
	  stdata(8)  = data;
        end
      else
	set(stdata(11),'string',int2str(stdata(12)));
      end
    else
	set(stdata(11),'string',int2str(stdata(12)));
    end
    set(fh,'userdata',stdata);
elseif strcmp(in1,'getetxt1')
    hand = in2;
    stdata = get(hand,'userdata');
    out1 = get(stdata(3),'string');
elseif strcmp(in1,'setetxt1')
    hand = in2;
    stdata = get(hand,'userdata');
    set(stdata(3),'string',deblank(in3));
elseif strcmp(in1,'getetxt2')
    hand = in2;
    stdata = get(hand,'userdata');
    out1 = get(stdata(11),'string');
elseif strcmp(in1,'setetxt2')
    hand = in2;
    stdata = get(hand,'userdata');
    set(stdata(11),'string',deblank(in3));
elseif strcmp(in1,'gettxt1')
    hand = in2;
    stdata = get(hand,'userdata');
    out1 = get(stdata(2),'string');
elseif strcmp(in1,'settxt1')
    hand = in2;
    stdata = get(hand,'userdata');
    set(stdata(2),'string',deblank(in3));
elseif strcmp(in1,'gettxt2')
    hand = in2;
    stdata = get(hand,'userdata');
    out1 = get(stdata(10),'string');
elseif strcmp(in1,'settxt2')
    hand = in2;
    stdata = get(hand,'userdata');
    set(stdata(10),'string',deblank(in3));
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
elseif strcmp(in1,'getval1')
    hand = in2;
    stdata = get(hand,'userdata');
    out1 = stdata(6);
elseif strcmp(in1,'getvals1')
    hand = in2;
    stdata = get(hand,'userdata');
    out1 = [stdata(6) stdata(9)]; % current, previous
elseif strcmp(in1,'getval2')
    hand = in2;
    stdata = get(hand,'userdata');
    out1 = stdata(12);
elseif strcmp(in1,'getvals2')
    hand = in2;
    stdata = get(hand,'userdata');
    out1 = [stdata(12) stdata(13)]; % current, previous
elseif strcmp(in1,'setval1')
    hand = in2;
    stdata = get(hand,'userdata');
    stdata(9) = stdata(6);
    stdata(6) = in3;
    set(hand,'userdata',stdata);
elseif strcmp(in1,'setval2')
    hand = in2;
    stdata = get(hand,'userdata');
    stdata(13) = stdata(12);
    stdata(12) = in3;
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
    display('Error in updownb2 calling routine')
end
