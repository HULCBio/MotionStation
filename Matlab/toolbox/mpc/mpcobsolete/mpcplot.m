function  FigHandl=mpcplot(Action,Data,Name,Offset)

% MPCPLOT -- graphical display of time-dependent data for MPC
% 
% FigHandl=mpcplot(Action,Data,Name,Offset)
%
% action    switch governing current action.
% data      structure containing information to be plotted:
%     .x    independent variable.  Column vector.  Applies to all plots.
%     .y    dependent variables.   Column vector or matrix.  Number of
%           rows must be same as length of x.  Each column is a dependent
%           variable.
%     .iy   M-by-N array, where M is number of plots, and N is the number
%           of curves per plot.  Thus iy(i,:) designates the columns of y
%           that are to appear in the ith plot.
%     .title M by 1 cell array containing the title for each plot.
%     .xlabel  String to be used to label x-axis of each plot.
%     .legend  N by 1 cell array containing the legend strings.  If empty,
%           legend is omitted.  Legend only appears on the last plot 
%           on page, assuming that all plots have same format.
% Name      Name to go in figure bar.
% Offset    Number of pixels to offset this figure down and to right
%           (relative to default position).  Useful when creating multiple
%           windows.
% FigHandl  Returns handle of the figure.


% N. L. Ricker, 11/97.
% Copyright 1994-2003 The MathWorks, Inc.
% $Revision: 1.1.6.2 $

Incr=[1 2 2 4 6 6 9];		% Increments depend on # plots/page in layout.
switch Action

case 'Initialize'
	% Get new figure window and set up for plotting in default format.
	% Create GUI.
	Fig=figure('IntegerHandle','off');

        %--
        % get an idea of how big a character is in this font
        h = text(0,0,'X','visible','off');
        set(h,'units','pixels');
        xx = get(h,'extent');
        delete(h);
        clf
        
        % store it for later
        h = uicontrol('style','text','visible','off','tag','fontmetric');
        set(h,'userdata',xx(3:4));
        %--

	FigHandl=Fig;
	Fpos=get(Fig,'Position');
	if nargin > 3
		Fpos(1:2)=Fpos(1:2)-Offset;
	end
	[M,N]=size(Data.iy);
	if M > 1
		% Set default layout and define list for layout popup menu
		if M < 3
			Layout=2;
			Llist={'1x1','2x1','1x2'};
		elseif M < 5
			Layout=4;
			Llist={'1x1','2x1','1x2','2x2'};
		else
			Layout=4;
			Llist={'1x1','2x1','1x2','2x2','3x2','2x3','3x3'};
		end
		First=1;		% Sets first plot on page
		Mlist=cell(M,1);
		for i=1:M
			Mlist{i,1}=[int2str(i),'-',int2str(min([M,i+Incr(Layout)-1]))];
		end
		if First+Incr(Layout)-1 < M
			NextOn='on';
		else
			NextOn='off';
		end
		FigColor=get(Fig,'Color');
		V=10; H=floor(Fpos(3)/2-(140+80+15)/2);
		Han=zeros(6,1);
		Han(1)=uicontrol('Parent',Fig, ...
		'callback','mpcplot(''Number'')',...
		'Position',[H-20 V 70 20], ...
		'String',Mlist, ...
		'Style','popupmenu', ...
		'Value',First);					% Pop-up with number of first plot on page
		Han(2)=uicontrol('Parent',Fig, ...
		'callback','mpcplot(''Next'')',...
		'Enable',NextOn, ...
		'Position',[H+128 V 55 20], ...
		'String','Next >>');				% NEXT button
		Han(3)=uicontrol('Parent',Fig, ...
		'callback','mpcplot(''Back'')',...
		'Enable','off', ...
		'Position',[H+67 V 55 20], ...
		'String','<< Back');				% BACK button
		Han(4)=uicontrol('Parent',Fig, ...
		'callback','mpcplot(''Layout'')',...
		'Position',[H+256 V 60 20], ...
		'String',Llist, ...
		'Style','popupmenu', ...
		'Value',Layout);					% Pop-up with layout options
		Han(5)=uicontrol('Parent',Fig, ...
		'Position',[H+200 V 50 xx(4)], ...
		'String','Layout:', ...
		'BackgroundColor',FigColor,...
		'FontWeight','bold',...
		'Style','text');					% Layout label
		Han(6)=uicontrol('Parent',Fig, ...
		'Position',[H-70 V 50 xx(4)], ...
		'String','Plots:', ...
		'BackgroundColor',FigColor,...
		'FontWeight','bold',...
		'Style','text');					% Plot counter label

		Data.Han=Han;
		Data.First=First;
		Data.Last=M;
		Data.Layout=Layout;
		Data.AxHan=[];
		set(Fig,'Name',Name,'NumberTitle','off','HandleVisibility','callback',...
		'ResizeFcn','mpcplot(''Resize'')','UserData',Data,'Position',Fpos);
	else
		set(Fig,'Name',Name,'NumberTitle','off',...
		'HandleVisibility','callback','Position',Fpos)
		Data.Layout=1;
	end
	plotnow(Fig,Data);
case 'Number'
	% Callback for popup controlling first plot on the page.
	Obj=gcbo;
	Fig=get(Obj,'Parent');
	Data=get(Fig,'UserData');
	First=get(Data.Han(1),'Value');
	if First == Data.First
		% Plot number hasn't changed, so just return.
		return
	else
		% User has changed number of first plot on page.  
		% Replot with new selection.
		Data.First=First;
		set(Fig,'UserData',Data);
		setnabl(Data);
		plotnow(Fig,Data);
	end
case 'Next'
	% User has pushed NEXT.  Increment First, enable BACK, and disable
	% NEXT if we're at the last plot.
	Fig=get(gcbo,'Parent');
	Data=get(Fig,'UserData');
	First=get(Data.Han(1),'Value');
	First=min([Data.Last, First+Incr(Data.Layout)]);
	Data.First=First;
	setnabl(Data);
	set(Fig,'UserData',Data);
	set(Data.Han(1),'Value',First);
	set(Data.Han(3),'Enable','on');
	plotnow(Fig,Data);
case 'Back'
	% User has pushed BACK.  Increment First, enable NEXT, and disable
	% BACK if we're at the first plot.
	Fig=get(gcbo,'Parent');
	Data=get(Fig,'UserData');
	First=get(Data.Han(1),'Value');
	First=max([1, First-Incr(Data.Layout)]);
	Data.First=First;
	setnabl(Data);
	set(Fig,'UserData',Data);
	set(Data.Han(1),'Value',First);
	plotnow(Fig,Data);
case 'Layout'
	Obj=gcbo;
	Fig=get(Obj,'Parent');
	Data=get(Fig,'UserData');
	Layout=get(Obj,'Value');
	if Data.Layout == Layout
		% No change, so just return
		return
	else
		% User has changed the layout.  
		% Re-evaluate the status of the other uicontrols.
		Data.Layout=Layout;
		Mlist=cell(Data.Last,1);
		if Layout == 1
			for i=1:Data.Last
				Mlist{i,1}=int2str(i);
			end
		else
			for i=1:Data.Last
				Mlist{i,1}=[int2str(i),'-',int2str(min([Data.Last,i+Incr(Layout)-1]))];
			end
		end	
		set(Data.Han(1),'String',Mlist,'Value',Data.First);
		setnabl(Data);
		set(Fig,'UserData',Data);
		plotnow(Fig,Data);
	end
case 'Resize'
	% Keep the UIs centered.
	Fig=gcbf;
	Fpos=get(Fig,'Position');
	Data=get(Fig,'UserData');
	V=1; H=floor(Fpos(3)/2-(140+80+15)/2);
    set(Data.Han(1),'Position',[H-20 V 70 20]);
	set(Data.Han(2),'Position',[H+128 V 55 20]);
	set(Data.Han(3),'Position',[H+67 V 55 20]);
	set(Data.Han(4),'Position',[H+250 V 60 20]);
	set(Data.Han(5),'Position',[H+200 V 45 20]);
	set(Data.Han(6),'Position',[H-70 V 50 20]);
	% Scale the positions of the axes
	Pos=subsize(Fpos(3),Fpos(4),Data.Layout);
	for i=1:length(Data.AxHan)
		set(Data.AxHan(i),'Position',Pos(i,:));
	end
end

% end of MPCPLOT

function plotnow(Fig,Data)

% Helper function for MPCPLOT.  Plots the data on the screen.

set(Fig,'HandleVisibility','on');
[M,N]=size(Data.iy);
Fpos=get(Fig,'Position');
Pos=subsize(Fpos(3),Fpos(4),Data.Layout);
if M == 1
	% If there's only one plot, just do it and we're done.
	% No callbacks.
	subplot('Position',Pos(1,:));
	plot(Data.x,Data.y(:,Data.iy(1,:)))
	title(Data.title{1})
	xlabel(Data.xlabel)
	if ~isempty(Data.legend) & N > 1
		plotleg(Data.legend)
	end
else
	% Multiple plots.  Format depends on number of plots per page.
	Incr=[1 2 2 4 6 6 9];		% Increments depend on # plots/page.
	% Delete any existing axes.
	delete(Data.AxHan);
	AxHan=[];
	for iplt=Data.First:min([Data.First+Incr(Data.Layout)-1,M])
		i=iplt-Data.First+1;
		AxHan(i)=axes('Position',Pos(i,:));
		plot(Data.x,Data.y(:,Data.iy(iplt,:)))
		title(Data.title{iplt});
		xlabel(Data.xlabel);
	end
	if ~isempty(Data.legend) & N > 1
		plotleg(Data.legend)
	end
	Data.AxHan=AxHan;
end
set(Fig,'HandleVisibility','callback','UserData',Data);

% end of PLOTNOW

function plotleg(Legend)

% Helper function for PLOTNOW.  Picks out legends from cell array Legend.
% Will display a maximum of 5.

N=length(Legend);
if N == 2
	legend(Legend{1},Legend{2});
elseif N == 3
	legend(Legend{1},Legend{2},Legend{3});
elseif N == 4
	legend(Legend{1},Legend{2},Legend{3},Legend{4});
else
	legend(Legend{1},Legend{2},Legend{3},Legend{4},Legend{5});
end

% end of PLOTLEG

function setnabl(Data)

% Helper function for MPCPLOT.  Logic to determine whether or
% not buttons are enabled.

Incr=[1 2 2 4 6 6 9];

% BACK button
if Data.First > 1
	set(Data.Han(3),'Enable','on');
else
	set(Data.Han(3),'Enable','off');
end
% NEXT button
if Data.First+Incr(Data.Layout)-1 < Data.Last
	set(Data.Han(2),'Enable','on');
else
	set(Data.Han(2),'Enable','off');
end

% end of SETNABL

function Pos=subsize(Fwidth,Fheight,Layout)

% Helper function for MPCPLOT.  Returns location of axes for
% subplots.  Designed to avoid conflict with UI controls at
% bottom of figure, as well as crowding when figure size is reduced.
%
% Fwidth   Figure width in pixels
% Fheight  Figure height in pixels
% Layout   1 = 1x1
%          2 = 2x1
%          3 = 1x2
%          4 = 2x2
%          5 = 3x2
%          6 = 2x3
%          7 = 3x3

h = findobj(gcf,'tag','fontmetric');
if isempty(h)
  xx = [9 18];
else
  xx = get(h(1),'userdata');
end

Bot =2.5*xx(2);	% Space needed at bottom for UIcontrols, pixels
Tit =2.0*xx(2);	% Space needed for title on each subplot, pixels
Xlab=1.5*xx(2); % Space needed for x-axis labeling, pixels
Ylab=2.5*xx(2); % Space needed for y-axis labeling, pixels
Yrt =1.5*xx(1); % Space allowance on right of each axis, pixels

Rows=[1 2 1 2 3 2 3];
Cols=[1 1 2 2 2 3 3];
Rows=Rows(Layout);
Cols=Cols(Layout);

% Compute normalized height and width of each axis.
% Also compute location of lower-left corner of figure #1
Ah=(Fheight-Rows*(Tit+Xlab)-Bot)/Fheight/Rows;
Aw=(Fwidth-Cols*(Ylab+Yrt))/Fwidth/Cols;
Xinc=Aw+(Ylab+Yrt)/Fwidth;
Yinc=-(Ah+(Xlab+Tit)/Fheight);
PosOne=[Ylab/Fwidth, 1-Ah-(Tit/Fheight)];
AWH=[Aw Ah];

if Layout == 1
	Pos=[PosOne AWH];
elseif Layout == 2
	Pos=[PosOne AWH ; PosOne+[0 Yinc] AWH];
elseif Layout == 3
	Pos=[PosOne AWH ; PosOne+[Xinc 0] AWH];
elseif Layout == 4
	Pos=[PosOne AWH
	     PosOne+[Xinc 0] AWH
		 PosOne+[0 Yinc] AWH
		 PosOne+[Xinc Yinc] AWH];
else
	M=Rows*Cols;
	Pos=[zeros(M,2) AWH(ones(M,1),:)];
	ii=0;
	for i=1:Rows
		for j=1:Cols
			ii=ii+1;
			Pos(ii,1:2)=PosOne+[(j-1)*Xinc, (i-1)*Yinc];
		end
	end
end

% end of SUBSIZE
