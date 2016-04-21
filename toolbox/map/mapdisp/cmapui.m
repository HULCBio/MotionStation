function cmap = cmapui(nlevels)
%CMAPUI GUI to generate colormap by interactively picking colors
%
%   cmap = CMAPUI is a graphical user interface to create a colormap.
%   Colors slots in the colormap are selected by clicking in the
%   colorbar on the right side of the panel. The current color
%   slot is outlined in black. The color components for that color 
%   in HSV space are shown by the position of the dot in the 
%   colorwheel and of the red bar in the value slider. To change 
%   the color, use the mouse to drag the dot and/or the red bar. 
%   To close the GUI and return the matrix of colors as RGB 
%   components, click the ACCEPT button. Clicking CANCEL closes
%   the GUI and returns an empty matrix. CMAPUI is a modal GUI.
%   There is no access to the MATLAB command line while CMAPUI is
%   active.
%
%   cmap = CMAPUI(n) creates a colormap with n colors. 
% 
%   cmap = CMAPUI(cmapin) initializes the colorbar to colors defined 
%   by cmapin, where cmapin is a three column matrix containing RGB 
%   color components.
%
%   Examples:
%
%     cmap = cmapui(20);
%     cmap = cmapui(colorcube(10));
%
%   See also COLORMAPEDITOR.

%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.5.4.1 $ $Date: 2003/08/01 18:17:59 $

% Written by: L. Job
% 5-4-98

if nargin == 1 & isstr(nlevels)
   action = nlevels;
   cmapuiutil(action);
   return
end

if nargin == 0
	nlevels = 5;
end	

numrows = size(nlevels,1);
numcols = size(nlevels,2);

% colorbar
figure; hold on;set(gcf,'tag','cm','windowstyle','modal',...
	'buttondownfcn','cmapui unselect',...
	'keypressfcn','cmapui selectcolors','Number','off','Name','CMAPUI')
% pass in number of colorlevels
if numrows == 1 & numcols == 1
	delta = 1/(nlevels-1);
	saturation = 0:delta:1;
	hueangle = 0:(360/nlevels-1):360;
	for i = 1:nlevels
		color = hsv2rgb([hueangle(i)/360 saturation(i) 1]);
		C(i,:,1) = color(1);
		C(i,:,2) = color(2);
		C(i,:,3) = color(3);
	end	
else % pass in colormap
	for i = 1:numrows
		C(i,:,1) = nlevels(i,1);
		C(i,:,2) = nlevels(i,2);
		C(i,:,3) = nlevels(i,3);
		if C(i,:,1) == 0 & C(i,:,2) == 0 & C(i,:,3) == 0
			C(i,:,1) = eps;
		end	
	end	
	nlevels = numrows;
end
h = image(1,1,C,'tag','cbar','erasemode','normal',...
		 'buttondownfcn','cmapui initializecolor');
set(gca,'xlim',[0.5 1.5],'ylim',[0.5 nlevels+0.5],'ydir','normal');
set(gca,'pos',[0.8867    0.1068    0.0684    0.8385])
set(gca,'visible','off')
hold on;
% draw empty line segments
for i = 1:nlevels
   line([0.5 1.5],[i-0.5 i-0.5],'tag',['l',num2str(i)],'color','k','visible','off','linewidth',4);
   line([1.5 1.5],[i-0.5 i+0.5],'tag',['l',num2str(i)],'color','k','visible','off','linewidth',4);
   line([1.5 0.5],[i+0.5 i+0.5],'tag',['l',num2str(i)],'color','k','visible','off','linewidth',4);
   line([0.5 0.5],[i+0.5 i-0.5],'tag',['l',num2str(i)],'color','k','visible','off','linewidth',4);
end	
zdatam('allline',1)

% color wheel
axes('pos',[0.0664    0.1545    0.76    0.76]);
% denote the angle locations
h = polar([0 2*pi],[0 1]);hold on;
delete(h)
clmo allline
h = findobj(gcf,'type','patch');
set(h,'facecolor','n','edgecolor','n');
% change the strings
h = findobj(gcf,'type','text');
for i = 1:length(h);
	string = get(h(i),'string');
	switch string
		case '  0.2';
			string = '';
		case '  0.4';
			string = '';
		case '  0.6';
			string = '';
		case '  0.8'
			string = '';
		case '  1';
			string = '';
		case '0'
			string = [string,degchar];
		case '30'
			string = [string,degchar];
		case '60'
			string = [string,degchar];
		case '90'
			string = [string,degchar];
		case '120'
			string = [string,degchar];
		case '150'
			string = [string,degchar];
		case '180'
			string = [string,degchar];
		case '210'
			string = [string,degchar];
		case '240'
			string = [string,degchar];
		case '270'
			string = [string,degchar];
		case '300'
			string = [string,degchar];
		case '330'
			string = [string,degchar];
	end
	set(h(i),'string',string)
end	

% polar coordinates
hueanglein = [0:5:360]; % input hue angles
saturatein = [0:0.05:1];% input saturation values
[th,r] = meshgrid(hueanglein*pi/180,saturatein);
% preallocate cdata vector
cdata(size(th,1),size(th,2),3) = 0;
% hue, saturation and value matrices
hue(size(th,1),size(th,2)) = 0;
hue(:,:) = th(:,:)./(2*pi);
sat(size(th,1),size(th,2)) = 0;
sat(:,:) = r(:,:);
val(size(th,1),size(th,2)) = 0;
val(:,:) = 1;
% hue,saturation and value vectors
huev = hue(:);
satv = sat(:);
valv = val(:);
% define rgb color triplets
rgbcolor(length(huev),3) = 0;
rgbcolor = hsv2rgb([huev satv valv]);
cdata(:,:,1) = reshape(rgbcolor(:,1),size(th,1),size(th,2));
cdata(:,:,2) = reshape(rgbcolor(:,2),size(th,1),size(th,2));
cdata(:,:,3) = reshape(rgbcolor(:,3),size(th,1),size(th,2));	
% convert to cartesian coordinates and plot surface
[X,Y] = pol2cart(th,r);
h = surf(X,Y,zeros(size(X)));
set(h,'cdata',cdata,'edgecolor','n','tag','cimage','facecolor','interp')
view(2)
axis equal
set(gca,'visible','off','tag','cpalette','drawmode','f')

% VALUE SLIDER
axes('pos',[ 0.1916    0.045    0.3496    0.0521])
plot([1 1],[0 1],'r-','linewidth',10,...
	'tag','valueslider','userdata',nlevels,...
	'buttondownfcn','cmapui initializevalue');
set(gca,'xlim',[0 1],'ylim',[0 1])
set(gca,'fontsize',9)
set(gca,'ytick',0.5,'yticklabel','Value [%] ',...
'xtick',[0:.25:1],'xticklabel',[0:25:100],'box','on')

% ACCEPT and CANCEL BUTTONS
uicontrol('style','pushbutton','units','normalized',...
		  'pos',[0.79 0.02 0.09 0.05],'string','Cancel','callback',...
		  'close(gcf)')
		  
uicontrol('style','pushbutton','units','normalized',...
		  'pos',[0.89 0.02 0.09 0.05],'string','Accept',...
		  'callback','uiresume')

% pre-select the top level
cmapuiutil('selecttop');		  

uiwait;
% check to see if currentfigure has been deleted (cancel selected)
curfig = get(0,'currentfigure');
if isempty(curfig) == 1
	% no other figures were open, cancel mode selected
	cmap = [];
else
	figtag = get(gcf,'tag');
	switch figtag
		case 'cm'
			% save mode selected
			cmap = cmapuiutil('cmapout');
			close(gcf)
		otherwise
			% other figures were open, cancel mode selected
			cmap = [];
	end			
end		
		  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function h = cmapuiutil(action)
% CMAPUIUTIL(ACTION) callbacks for COLORWHEELCMAP


switch action
	case 'unselect'
		% delete the pointer if it exists
		h = findobj(gcf,'tag','pointer');
		if isempty(h) == 0
			s = get(h,'userdata');
			set(findobj('tag',['l',num2str(s.indx)]),'visible','off')
			delete(h)
		end	
	case 'initializecolor'
		% delete the pointer if it exists
		h = findobj(gcf,'tag','pointer');
		if isempty(h) == 0
			s = get(h,'userdata');
			set(findobj('tag',['l',num2str(s.indx)]),'visible','off')
			delete(h)
		end	
		% find the currentposition
		cp = get(gca,'currentpoint');
		y = round(cp(1,2));
		% get the color data
		cdata = get(gco,'cdata');
		% rgb components
		r = cdata(y,1,1);
		g = cdata(y,1,2);
		b = cdata(y,1,3);
		rgbcolor = [r g b];
		% hsv components
		hsvcolor = rgb2hsv(rgbcolor);
		hueangle = hsvcolor(1);
		saturation = hsvcolor(2);
		s.indx = y;
		s.value = hsvcolor(3);
		% highlight the edges
		h = findobj('tag',['l',num2str(s.indx)]);
		for i = 1:length(h)
			set(h(i),'visible','on')
		end	
		% find the color in the color palette and plot a marker there;
		axes(findobj(gcf,'tag','cpalette'))
		if saturation > 0.98 % don't allow marker to fall outside colorwheel
			saturation = 0.98;
		end	
		[x,y] = pol2cart(hueangle*2*pi,saturation);
		plot(x,y,'ko','linewidth',2.5,'markersize',10,...
			'markerfacecolor','w',...
			'tag','pointer','userdata',s,...
			'buttondownfcn','cmapui initialize');
		% update the color palette and slider value if necessary
		currvalue = get(findobj('tag','valueslider'),'xdata');
		if s.value ~= currvalue
			set(findobj('tag','valueslider'),'xdata',[s.value s.value]);
			% change the color palette
			cdata = get(findobj('tag','cimage'),'cdata');
			r = cdata(:,:,1);
			g = cdata(:,:,2);
			b = cdata(:,:,3);
			hsvcolor = rgb2hsv([r(:) g(:) b(:)]);
			hsvcolor(:,3) = s.value;
			rgbcolor = hsv2rgb(hsvcolor);
			cdata(:,:,1) = reshape(rgbcolor(:,1),size(r,1),size(r,2));
			cdata(:,:,2) = reshape(rgbcolor(:,2),size(r,1),size(r,2));
			cdata(:,:,3) = reshape(rgbcolor(:,3),size(r,1),size(r,2));	
			set(findobj('tag','cimage'),'cdata',cdata)
		end	
	case 'initialize'
		set(gcf,'windowbuttonmotionfcn','cmapui cyclecolors')
		set(gcf,'windowbuttonupfcn','cmapui pickcolor')
	case 'cyclecolors'	
		% constrain marker movement within hsv space
		cp = get(gca,'currentpoint');
		x = cp(1,1);
		y = cp(1,2);
		r = sqrt(x^2 + y^2);
		if r > 0.98
			switch x
				case 0
					theta = 0;
					if y > 0; y = 0.98; end
					if y < 0; y = -0.98; end
				otherwise	
					theta = atan2(y,x);
					x = 0.98*cos(theta);
					y = 0.98*sin(theta);
			end		
		end	
		set(gco,'xdata',x,'ydata',y,'erasemode','xor');
		% map the hsv value to the current position
		[th,r] = cart2pol(x,y);
		hueangle = atan2(y,x);
		if hueangle < 0; hueangle = hueangle + 2*pi; end
		hueangle = hueangle/(2*pi);
		saturation = r;
		s = get(gco,'userdata');
		value = s.value;
		rgbcolor = hsv2rgb([hueangle saturation value]);
		% update the color
		h = findobj(gcf,'tag','cbar');
		cdata = get(h,'Cdata');
		s = get(gco,'userdata');
		cdata(s.indx,:,1) = rgbcolor(1);
		cdata(s.indx,:,2) = rgbcolor(2);
		cdata(s.indx,:,3) = rgbcolor(3);
		set(findobj(gcf,'tag','cbar'),'cdata',cdata);
	case 'pickcolor'
		set(gco,'erasemode','normal')
		set(gcf,'windowbuttonmotionfcn','');
		set(gcf,'windowbuttonupfcn','')
	case 'initializevalue' % button down of value control
		set(gcf,'windowbuttonmotionfcn','cmapui cyclevalues')
		set(gcf,'windowbuttonupfcn','cmapui pickvalue')
	case 'cyclevalues' % change the value component
		% constrain slider to move between 0.05 and 1
		cp = get(gca,'currentpoint');
		if cp(1,1) < 0.01; cp(1,1) = 0.01; end
		if cp(1,1) > 1; cp(1,1) = 1; end
		set(gco,'xdata',[cp(1,1) cp(1,1)],'erasemode','xor')
		% change the color palette
		cdata = get(findobj('tag','cimage'),'cdata');
		r = cdata(:,:,1);
		g = cdata(:,:,2);
		b = cdata(:,:,3);
		hsvcolor = rgb2hsv([r(:) g(:) b(:)]);
		hsvcolor(:,3) = cp(1,1);
		rgbcolor = hsv2rgb(hsvcolor);
		cdata(:,:,1) = reshape(rgbcolor(:,1),size(r,1),size(r,2));
		cdata(:,:,2) = reshape(rgbcolor(:,2),size(r,1),size(r,2));
		cdata(:,:,3) = reshape(rgbcolor(:,3),size(r,1),size(r,2));	
		set(findobj('tag','cimage'),'cdata',cdata)
		% check to see if pointer exists, if it does update colorbar index also
		obj = findobj('tag','pointer');
		s = get(obj,'userdata');
		cbcdata  = get(findobj('tag','cbar'),'cdata');
		if isempty(obj) == 0 % does exist
			rgbcolor = [cbcdata(s.indx,:,1) cbcdata(s.indx,:,2) cbcdata(s.indx,:,3)];
			hsvcolor = rgb2hsv(rgbcolor);
			hsvcolor(3) = cp(1,1);
			rgbcolor = hsv2rgb(hsvcolor);
			cbcdata(s.indx,:,1) = rgbcolor(1);
			cbcdata(s.indx,:,2) = rgbcolor(2);
			cbcdata(s.indx,:,3) = rgbcolor(3);
			set(findobj('tag','cbar'),'cdata',cbcdata);
		end		
	case 'pickvalue' % select a new value
		cp = get(gca,'currentpoint');
		if cp(1,1) < 0.01; cp(1,1) = 0.01; end
		if cp(1,1) > 1; cp(1,1) = 1; end
		obj = get(findobj('tag','pointer'),'userdata');
		obj.value = cp(1,1);
		set(findobj('tag','pointer'),'userdata',obj);
		set(gco,'xdata',[cp(1,1) cp(1,1)],'erasemode','normal')
		set(gcf,'windowbuttonmotionfcn','')
		set(gcf,'windowbuttonupfcn','')
		refresh
	case 'cmapout'		
		% output colormap
		cbcdata = get(findobj('tag','cbar'),'cdata');
		h = [cbcdata(:,:,1) cbcdata(:,:,2) cbcdata(:,:,3)];
	case 'selecttop'
		% pick the color at the top of the colorbar 
		% get the color data
		cdata = get(findobj(gcf,'tag','cbar'),'cdata');
		nlevels = size(cdata,1);
		% rgb components
		r = cdata(nlevels,1,1);
		g = cdata(nlevels,1,2);
		b = cdata(nlevels,1,3);
		rgbcolor = [r g b];
		% hsv components
		hsvcolor = rgb2hsv(rgbcolor);
		hueangle = hsvcolor(1);
		saturation = hsvcolor(2);
		s.indx = nlevels;
		s.value = hsvcolor(3);
		% highlight the edges
		h = findobj('tag',['l',num2str(s.indx)]);
		for i = 1:length(h)
			set(h(i),'visible','on')
		end	
		% find the color in the color palette and plot a marker there;
		axes(findobj(gcf,'tag','cpalette'))
		if saturation > 0.98 % don't allow marker to fall outside colorwheel
			saturation = 0.98;
		end	
		[x,y] = pol2cart(hueangle*2*pi,saturation);
		plot(x,y,'ko','linewidth',2.5,'markersize',10,...
			'markerfacecolor','w',...
			'tag','pointer','userdata',s,...
			'buttondownfcn','cmapui initialize');
		% update the color palette and slider value if necessary
		currvalue = get(findobj('tag','valueslider'),'xdata');
		if s.value ~= currvalue
			set(findobj('tag','valueslider'),'xdata',[s.value s.value]);
			% change the color palette
			cdata = get(findobj('tag','cimage'),'cdata');
			r = cdata(:,:,1);
			g = cdata(:,:,2);
			b = cdata(:,:,3);
			hsvcolor = rgb2hsv([r(:) g(:) b(:)]);
			hsvcolor(:,3) = s.value;
			rgbcolor = hsv2rgb(hsvcolor);
			cdata(:,:,1) = reshape(rgbcolor(:,1),size(r,1),size(r,2));
			cdata(:,:,2) = reshape(rgbcolor(:,2),size(r,1),size(r,2));
			cdata(:,:,3) = reshape(rgbcolor(:,3),size(r,1),size(r,2));	
			set(findobj('tag','cimage'),'cdata',cdata)
		end	
	case 'selectcolors'
		% select colors on colorbar with up and down arrow keys
		keychar = abs(get(gcf,'CurrentCharacter'));
		if isempty(keychar); return; end
		switch keychar 
			case 30,     cmapuiutil('cycleup');      %  Up Arrow
			case 31,     cmapuiutil('cycledown');    %  Down Arrow
		end 
	case 'cycleup'
		% select color above currently selected color or top color
		% if no color is selected
		% find the pointer
		h = findobj(gcf,'tag','pointer');
		if isempty(h) == 0
			s = get(h,'userdata');
			% get the color data
			cdata = get(findobj(gcf,'tag','cbar'),'cdata');
			nlevels = size(cdata,1);
			if s.indx < nlevels & s.indx+1 > 0
				delete(h) % delete the marker
				% unselect current color in colorbar
				set(findobj('tag',['l',num2str(s.indx)]),'visible','off')
				% get the color data
				cdata = get(findobj(gcf,'tag','cbar'),'cdata');
				% rgb components
				r = cdata(s.indx+1,1,1);
				g = cdata(s.indx+1,1,2);
				b = cdata(s.indx+1,1,3);
				rgbcolor = [r g b];
				% hsv components
				hsvcolor = rgb2hsv(rgbcolor);
				hueangle = hsvcolor(1);
				saturation = hsvcolor(2);
				s.indx = s.indx+1;
				s.value = hsvcolor(3);
				% highlight the edges
				h = findobj('tag',['l',num2str(s.indx)]);
				for i = 1:length(h)
					set(h(i),'visible','on')
				end	
				% find the color in the color palette and plot a marker there;
				axes(findobj(gcf,'tag','cpalette'))
				if saturation > 0.98 % don't allow marker to fall outside colorwheel
					saturation = 0.98;
				end	
				[x,y] = pol2cart(hueangle*2*pi,saturation);
				plot(x,y,'ko','linewidth',2.5,'markersize',10,...
					'markerfacecolor','w',...
					'tag','pointer','userdata',s,...
					'buttondownfcn','cmapui initialize');
				% update the color palette and slider value if necessary
				currvalue = get(findobj('tag','valueslider'),'xdata');
				if s.value ~= currvalue
					set(findobj('tag','valueslider'),'xdata',[s.value s.value]);
					% change the color palette
					cdata = get(findobj('tag','cimage'),'cdata');
					r = cdata(:,:,1);
					g = cdata(:,:,2);
					b = cdata(:,:,3);
					hsvcolor = rgb2hsv([r(:) g(:) b(:)]);
					hsvcolor(:,3) = s.value;
					rgbcolor = hsv2rgb(hsvcolor);
					cdata(:,:,1) = reshape(rgbcolor(:,1),size(r,1),size(r,2));
					cdata(:,:,2) = reshape(rgbcolor(:,2),size(r,1),size(r,2));
					cdata(:,:,3) = reshape(rgbcolor(:,3),size(r,1),size(r,2));	
					set(findobj('tag','cimage'),'cdata',cdata)
				end	
			end	
		end	
		if isempty(h) == 1
			cmapuiutil('selecttop');
		end	
	case 'cycledown'
		% select color above currently selected color or top color
		% if no color is selected
		% find the pointer
		h = findobj(gcf,'tag','pointer');
		if isempty(h) == 0
			s = get(h,'userdata');
			% get the color data
			cdata = get(findobj(gcf,'tag','cbar'),'cdata');
			nlevels = size(cdata,1);
			if s.indx > 0 & s.indx-1 > 0
				delete(h) % delete the marker
				% unselect current color in colorbar
				set(findobj('tag',['l',num2str(s.indx)]),'visible','off')
				% get the color data
				cdata = get(findobj(gcf,'tag','cbar'),'cdata');
				% rgb components
				r = cdata(s.indx-1,1,1);
				g = cdata(s.indx-1,1,2);
				b = cdata(s.indx-1,1,3);
				rgbcolor = [r g b];
				% hsv components
				hsvcolor = rgb2hsv(rgbcolor);
				hueangle = hsvcolor(1);
				saturation = hsvcolor(2);
				s.indx = s.indx-1;
				s.value = hsvcolor(3);
				% highlight the edges
				h = findobj('tag',['l',num2str(s.indx)]);
				for i = 1:length(h)
					set(h(i),'visible','on')
				end	
				% find the color in the color palette and plot a marker there;
				axes(findobj(gcf,'tag','cpalette'))
				if saturation > 0.98 % don't allow marker to fall outside colorwheel
					saturation = 0.98;
				end	
				[x,y] = pol2cart(hueangle*2*pi,saturation);
				plot(x,y,'ko','linewidth',2.5,'markersize',10,...
					'markerfacecolor','w',...
					'tag','pointer','userdata',s,...
					'buttondownfcn','cmapui initialize');
				% update the color palette and slider value if necessary
				currvalue = get(findobj('tag','valueslider'),'xdata');
				if s.value ~= currvalue
					set(findobj('tag','valueslider'),'xdata',[s.value s.value]);
					% change the color palette
					cdata = get(findobj('tag','cimage'),'cdata');
					r = cdata(:,:,1);
					g = cdata(:,:,2);
					b = cdata(:,:,3);
					hsvcolor = rgb2hsv([r(:) g(:) b(:)]);
					hsvcolor(:,3) = s.value;
					rgbcolor = hsv2rgb(hsvcolor);
					cdata(:,:,1) = reshape(rgbcolor(:,1),size(r,1),size(r,2));
					cdata(:,:,2) = reshape(rgbcolor(:,2),size(r,1),size(r,2));
					cdata(:,:,3) = reshape(rgbcolor(:,3),size(r,1),size(r,2));	
					set(findobj('tag','cimage'),'cdata',cdata)
				end	
			end	
		end	
		if isempty(h) == 1
			cmapuiutil('selecttop');
		end	
end % action
