function varargout = rtdxlmsdemo(varargin)
%RTDXLMSDEMO Run GUI-based RTDX(tm) automation demo.
%    RTDXLMSDEMO demonstrates the use of RTDX methods to transfer data
%    between MATLAB and the target TI(tm) DSP.  The target application
%    adaptively cancels broadband noise by employing a normalized LMS
%    algorithm.
%    
%    Unfiltered noise data along with the signal plus low-pass filtered
%    noise data are transferred to the target DSP by employing RTDX object
%    methods. The target DSP applies the adaptive LMS algorithm and sends
%    back to the MATLAB workspace the estimated low-pass filter taps at
%    each iteration along with the streaming filtered time series data.
%
%    Plots include the incremental tap updates and frequency responses, and
%    time series data of signal, signal plus noise, and the filtered signal
%    plus noise.
%
%    To run the RTDXLMSDEMO from MATLAB, type 'rtdxlmsdemo' at the command
%    prompt.
%
%    See also CCSFIRDEMO, RTDXTUTORIAL, CCSTUTORIAL

%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.16.4.4 $  $Date: 2004/04/06 01:04:35 $

% Last Modified by GUIDE v2.0 09-Dec-2000 21:51:15

if nargin == 0  % LAUNCH GUI

	fig = openfig(mfilename,'reuse');

	% Generate a structure of handles to pass to callbacks, and store it. 
    % and initialize values
	handles = guihandles(fig);
    handles.Filter_Order  = 16;
    handles.Frame_Size    = 128;
    handles.Num_Of_Frames = 1;
	guidata(fig, handles);
    
    set(0,'showhiddenhandles','on');
    axes(handles.rtdxaxes);
    rtdxlmsmodel(handles.rtdxaxes);
    set(0,'showhiddenhandles','on');
        
	if nargout > 0
		varargout{1} = fig;
	end

elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK

	try
		[varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
	catch
		disp(lasterr);
	end

end

% --------------------------------------------------------------------
function varargout = Runbtn_Callback(h, eventdata, handles, varargin)
BoardNum    = get(handles.boardnum,'UserData');
ProcNum     = get(handles.procnum, 'UserData');
FilterOrder = handles.Filter_Order;
FrameSize   = handles.Frame_Size;
NumOfFrames = handles.Num_Of_Frames;

rtdxlmsdemo_script( BoardNum, ProcNum,  FilterOrder,  FrameSize,  NumOfFrames);

% --------------------------------------------------------------------
function varargout = EditScriptbtn_Callback(h, eventdata, handles, varargin)
rtdxscript_file = 'rtdxlmsdemo_script.m';
if exist(rtdxscript_file) == 2,
    open(rtdxscript_file);
else
    msgbox({'File ''rtdxlmsdemo_script.m'' not found, please check your path';...
            'originally, should be in < .../toolbox/ccslink/ccsdemos >.'}, ...
        'File Not Found','modal');
end

% --------------------------------------------------------------------
function varargout = FilterOrder_Callback(h, eventdata, handles, varargin);

AllFilterOrder = get(handles.FilterOrder,'string');
FilterOrderindex = get(handles.FilterOrder,'Value');
FilterOrder = str2num(AllFilterOrder{FilterOrderindex}) ;
handles.Filter_Order = FilterOrder;
guidata(h, handles);

% --------------------------------------------------------------------
function varargout = FrameSize_Callback(h, eventdata, handles, varargin);

AllFrameSizes = get(handles.FrameSize,'string');
FrameSizeindex = get(handles.FrameSize,'Value');
FrameSize = str2num(AllFrameSizes{FrameSizeindex}) ;
handles.Frame_Size = FrameSize;
guidata(h, handles);

% --------------------------------------------------------------------
function varargout = NumOfFrames_Callback(h, eventdata, handles, varargin);

AllFrames = get(handles.NumOfFrames,'string');
Frameindex = get(handles.NumOfFrames,'Value');
NumOfFrames = str2num(AllFrames{Frameindex}) ;
handles.Num_Of_Frames = NumOfFrames;
guidata(h, handles);

% --------------------------------------------------------------------
function varargout = boardnum_Callback(h, eventdata, handles, varargin)
% Callback for Board number entry box.  This allows user to directly
% define the 'boardnum' parameter of the Link
oldval = get(h,'UserData');
newstr = get(h,'String');
newval = eval(newstr,num2str(oldval));
if newval<0, newval = oldval; end
newval = round(newval);
set(h,'Userdata',newval,'String',num2str(newval));

% --------------------------------------------------------------------
function varargout = procnum_Callback(h, eventdata, handles, varargin)
% Callback for Processor number entry box.  This allows user to directly
% define the 'procnum' parameter of the Link
oldval = get(h,'UserData');
newstr = get(h,'String');
newval = eval(newstr,num2str(oldval));
if newval<0, newval = oldval; end
newval = round(newval);
set(h,'Userdata',newval,'String',num2str(newval));

% --------------------------------------------------------------------
function varargout = select_Callback(h, eventdata, handles, varargin)
% Invokes the Board/Processor Selection GUI
try
    [bdnum,prnum] = boardprocsel;
catch
    warndlg(...
    { 'Unable to run Board Selection Utility',...
      '[bdnum,prnum] = boardprocsel;',...
      'Board and Processor must be entered manually',...
      lasterr},'GUI Error');
end
if ~isempty(bdnum),
    set(handles.boardnum,'String',int2str(bdnum));
    set(handles.boardnum,'UserData',bdnum);
end
if ~isempty(prnum),
    set(handles.procnum,'String',int2str(prnum));
    set(handles.procnum,'UserData',prnum);
end


% --------------------------------------------------------------------
function varargout = lmsdiagram_Callback(h, eventdata, handles, varargin)
rtdxlmsmodel(handles.rtdxaxes);

% --------------------------------------------------------------------
function varargout = ccsdiagram_Callback(h, eventdata, handles, varargin)
blockdiagram(handles.rtdxaxes)

%====================== D R A W I N G   F U N C T I O N S =============

% functions used to create block diagram of MATLAB <-> CCS <-> Target
function blockdiagram(ph)
% Inserts a sketch of the Link for Code Composer Studio(R) IDE
patch([0 1 1 0 0],[0 0 1 1 0],'w','LineStyle','none','Parent',ph);
box(ph,0.02,0.98,0.78,0.95,'c','Host Computer');
box(ph,0.04,0.85,0.30,0.78,[0.9 0.9 0.9],{'MATLAB', 'Application'});
box(ph,0.06,0.60,0.26,0.25,'w',{'Link to CCS:', 'cc = ccsdsp;'});
box(ph,0.06,0.35,0.26,0.25,'w',{'Link to RTDX:', 'cc.rtdx;'});
box(ph,0.38,0.85,0.38,0.78,[0.7 0.7 0.9],{'Code Composer', 'Studio(R) IDE'})
box(ph,0.40,0.60,0.30,0.40,[0.9 0.7 0.7],{'DSP Project:', 'rtdxdemo.pjt'})
box(ph,0.82,0.80,0.17,0.60,[0.8 0.8 0.8],{'Board'});
box(ph,0.84,0.67,0.13,0.40,[0.9 0.8 0.7],{'Target', 'DSP','Proc.'});
arrow(ph,0.23,0.20,0.51,0.36,0.04);
arrow(ph,0.23,0.42,0.50,0.40,0.04);
arrow(ph,0.60,0.30,0.9,0.42,0.04);

%***************************************************************
function box(ph,x,y,xle,yle,color,tstr)
% upper left hand corner + length
pH = patch([x x x+xle x+xle x],[y y-yle y-yle y y],color,'Parent',ph); 
set(pH,'LineWidth',2);
tH = text(x+0.02,y-0.02,tstr,'Parent',ph);
set(tH,'VerticalAlignment','Top');

%***************************************************************
function arrow(ph,x1,y1,x2,y2,len)
% Draws an arrow that is +/-25 degrees from straight
el = atan2(y2-y1,x2-x1);
dle = 0.3;
x1a = x1+len*cos(el+dle);
x1b = x1+len*cos(el-dle);
y1a = y1+len*sin(el+dle);
y1b = y1+len*sin(el-dle);
el = atan2(y1-y2,x1-x2);
x2a = x2+len*cos(el-dle);
x2b = x2+len*cos(el+dle);
y2a = y2+len*sin(el-dle);
y2b = y2+len*sin(el+dle);
lH = line([x1 x1a x1b x1 x2 x2a x2b x2],[y1 y1a y1b y1 y2 y2a y2b y2],'Parent',ph);
set(lH,'Color','r')

%***************************************************************
function rtdxlmsmodel(ph)
warning off
patch([0 1 1 0 0],[0 0 1 1 0],[1 1 1],'LineStyle','none','Parent',ph);

% DRAW BOXES

% From RTDX
box(ph,0.03,0.8,0.13,0.22,'g',{' Sine', 'Wave'});
box(ph,0.03,0.5,0.13,0.22,'g',' Noise');
box(ph,0.21,0.45,0.13,0.12,'g','  FIR');

% Target DSP
box(ph,0.4,0.33,0.2,0.15,'c','     nLMS');
h = rectangle('position',[0.39 0.635 0.08 0.08],'curvature',[1 1]); 
set(h,'FaceColor','c','linewidth',0.9);
h = rectangle('position',[0.59 0.635 0.08 0.08],'curvature',[1 1]);
set(h,'FaceColor','c','linewidth',0.9);

% To RTDX
box(ph,0.69,0.55,0.09,0.17,'y',' [ ]');
box(ph,0.81,0.3,0.15,0.18,'y',{'   Tap', 'Updates'});
box(ph,0.835,0.95,0.13,0.22,'y',{'Filtered', 'Signal'});


% Draw arrows
myarrow(0.16, 0.205, 0.39, 0.39);    % From Noise --> FIR

line([0.1825 0.1825], [0.39 0.29],'color',[0 0 0]);
myarrow(0.1825, 0.397, 0.29, 0.29);    % From FIR --> nLMS

line([0.6 0.63], [0.255 0.255],'color',[0 0 0]);
line([0.63 0.63], [0.255 0.465],'color',[0 0 0]); 
myarrow(0.63, 0.685, 0.465, 0.465);  % From nLMS --> [] flip

line([0.78 0.79], [0.465 0.465],'color',[0 0 0]);
line([0.79 0.79], [0.465 0.21],'color',[0 0 0]); 
myarrow(0.79, 0.805, 0.21, 0.21);    % From [] --> Tap Updates

myarrow(0.37, 0.395, 0.22, 0.22);
line([0.37 0.37], [0.22 0.05],'color',[0 0 0]); 
line([0.37 0.97], [0.05 0.05],'color',[0 0 0]); 
line([0.97 0.97], [0.05 0.67],'color',[0 0 0]);     
line([0.97 0.67], [0.67 0.67],'color',[0 0 0]); 
myarrow(0.89, 0.89, 0.67, 0.72);      % From nLMS --> Filtered Signal


line([0.63, 0.63], [0.465, 0.633],'color',[0 0 0]);    % From [] --> +/-

myarrow(0.47, 0.59, 0.67, 0.67);      % From +/+ --> +/-

myarrow(0.16, 0.39, 0.67, 0.67);      % From Sine Wave --> +/+  

line([0.34 0.425],[0.43 0.43],'color',[0 0 0])
line([0.425 0.425] ,[0.43 0.635],'color',[0 0 0]);    % From FIR +/+ 

h = text(0.395,0.673,'+');    
h = text(0.415,0.655,'+');    
h = text(0.595,0.675,'+');    
h = text(0.625,0.655,'-');   
set(h,'fontsize',13);

% Add text
h = text(0.17, 0.69, 'Input Signal');
set(h,'fontsize',7);
h = text(0.183, 0.26, 'From RTDX');
set(h,'fontsize',7);
h = text(0.67, 0.635, ' To RTDX');
set(h,'fontsize',7);
h = text(0.715, 0.35, 'Flip');
set(h,'fontsize',7);

height = 0.88;

h = text(0.11,height, 'From RTDX');
set(h,'FontWeight','demi');
myarrow(0.31,0.37,height,height);

h = text(0.41,height, 'Target DSP');
myarrow(0.60,0.65,height,height);
set(h,'FontWeight','demi');

h = text(0.67,height, 'To RTDX');
set(h,'FontWeight','demi');

%***************************************************************
function myarrow(x1,x2,y1,y2)
% Myarrow(x1,x2,y1,y2) draws an arrow

x=[x1 x2];
y=[y1 y2];
hdl_line=line(x,y,'color',[0 0 0]);
if y2==y1
    hdl_head=patch([x2-0.01 x2-0.01 x2],[y2-0.01 y2+0.01 y2],'k');
elseif x2==x1
    hdl_head=patch([x2-0.01 x2+0.01 x2],[y2+0.01 y2+0.01 y2],'k');
end

% [EOF] rtdxlmsdemo.m
