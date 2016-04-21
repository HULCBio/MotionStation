function slide = notchdemo_sls(slidenum)
%NOTCHDEMO_SLS  Slide show for INFO button in notch demo.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2002/04/10 06:40:53 $

persistent H_ct

if nargin
    %---Slide code
	cla, legend off
	switch slidenum
	case 1
		set(gca,'Position',[0.085 0.5 0.65 0.45])
		set(findobj(allchild(gcf),'flat','type','uicontrol','string','Info'),...
			'visible','off')
		DrawProblem
	case 2
		axis(gca,'normal');
		H_ct = tf([1 0.5 100],[1 5 100]);
		bodemag(H_ct)
        h = gcr;
        set(h.AxesGrid,'Xlimmode','auto','Ylimmode','auto');
        set(h.AxesGrid,'XUnits','Hz','YUnits',{'dB';'deg'},'Grid','off','Xscale','log');
        set(gca,'xlim',[0.3 10]);
        title('Continuous-Time Notch Filter');
	case 3
        set(gca,'Position',[0.085 0.5 0.65 0.45])
		DrawIssues
	case 4
		axis(gca,'normal');
		H1 = c2d(H_ct,0.1,'zoh');
		H2 = c2d(H_ct,0.1,'tustin');
		H3 = c2d(H_ct,0.1,'matched');
		bodemag(H_ct,'b',H1,'r',H2,'m',H3,'g')
                h = gcr;
        set(h.AxesGrid,'Xlimmode','auto','Ylimmode','auto');
        set(h.AxesGrid,'XUnits','Hz','YUnits',{'dB';'deg'},'Grid','off','Xscale','log');
        set(gca,'xlim',[0.3 10]);
        title('Discretized Notch Filters');
		legend('continuous','zoh','tustin','matched',3)
	end
	
    
elseif nargout<1
    %---Start demo
    fg = playshow(mfilename);
    set(fg,'Name','Details on the Notch Filter Demo');
    
    
else
    %---Construct slides
    slidenum = 0;
    
    %========== Slide 1 ==========
    slidenum = slidenum+1;
    slide(slidenum).code={sprintf('%s(%d)',mfilename,slidenum)};
    slide(slidenum).text={
        ' While control system components are often designed in continuous'
		' time, they must generally be discretized for implementation on'
		' digital computers and embedded processors.'
		' '
 		' This demo compares several techniques for discretizing a notch'
		' filter. The notch filter transfer function is shown above.' 
    };
    
    %========== Slide 2 ==========
    slidenum = slidenum+1;
    slide(slidenum).code={sprintf('%s(%d)',mfilename,slidenum)};
    slide(slidenum).text={
        ' Use these commands to create the notch filter model and plot its'
        ' magnitude against frequency:'
        ' '
        ' >> H_ct = tf([1 0.5 100],[1 5 100])'
        ' >> bodemag(H_ct)'
    };
    
    %========== Slide 3 ==========
    slidenum = slidenum+1;
    slide(slidenum).code={sprintf('%s(%d)',mfilename,slidenum)};
    slide(slidenum).text={
        ' Several methods are available for discretizing linear models.'
		' In addition, an appropriate choice of sample time is important'
		' for the performance of the digital system.'
		' '
		' The C2D command in the Control System Toolbox lets you easily'
		' explore the tradeoffs between methods and sample rates'
		' '
		' >> H_dt = c2d(H_ct,Ts,method)        % Ts = sample time'
    };
    
    %========== Slide 4 ==========
    slidenum = slidenum+1;
    slide(slidenum).code={sprintf('%s(%d)',mfilename,slidenum)};
	slide(slidenum).text={
		' This plot compares the magnitude curve of the continuous-time'
		' filter (blue) with three discretizations at 10 Hz using the'
		' zero-order hold (ZOH), Tustin, and matched methods'
		' '
		' >> H1 = c2d(H_ct,0.1,''zoh'')'
		' >> H2 = c2d(H_ct,0.1,''tustin'')'
		' >> H3 = c2d(H_ct,0.1,''matched'')'
		' >> bodemag(H_ct,''b'',H1,''r'',H2,''m'',H3,''g'')'
		' '
		' The matched method is a clear winner in this simple case.'
	};
    


end

%%%%%%%%%%%%%%%%%

function DrawProblem
% Sketches problem description
axis equal
ax = gca;
set(ax,'visible','off','xlim',[0 24],'ylim',[0 5])
y0 = 2;  x0 = 0;
wire('x',x0+[-1 0.5],'y',y0+[0 0],'parent',ax,'arrow',0.5);
sysblock('position',[x0+0.5 y0-2 8 4],'name','H(s)',...
	'num','s^2 + 0.5 s + 100','den','s^2 + 5 s + 100',...
    'fontweight','bold','facecolor',[1 1 0.9],'fontsize',10);
wire('x',x0+[8.5 10],'y',y0+[0 0],'parent',ax,'arrow',0.5);
x1 = 15;
wire('x',x1+[0 2],'y',y0+[0 0],'parent',ax,'arrow',0.5);
sysblock('position',[x1+2 y0-2 4 4],'name','H(z)',...
	'num','?','fontweight','bold','facecolor',[1 1 0.9],'fontsize',10);
wire('x',x1+[6 8],'y',y0+[0 0],'parent',ax,'arrow',0.5);
wire('x',[x0+11 x1-1.5],'y',y0+[-2 -2],'parent',ax,'linewidth',4,'color','r');
wire('x',[x1-1 x1-1],'y',y0+[-2 -2],'parent',ax,'arrow',1,'color','r');

function DrawIssues
% Sketches problem issues
axis equal
ax = gca;
set(ax,'visible','off','xlim',[0 10],'ylim',[0 5])
y0 = 2;  x0 = 0;
text(x0+1,4,'Sample Time = ?','fontweight','bold','fontsize',14);
text(x0+1,2,'Discretization Method = ?','fontweight','bold','fontsize',14);
