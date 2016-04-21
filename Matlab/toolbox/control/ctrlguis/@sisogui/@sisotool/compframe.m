function Frame = compframe(sisodb)
%COMPFRAME  Create frame for compensator display.
%
%   See also SISOTOOL.

%   Author(s): K. Gondoly and P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.27.4.2 $  $Date: 2004/04/10 23:14:24 $

% Help topics
CompHelpTopic = 'currentcompensator';

% Main figure
SISOfig = sisodb.Figure;
StdUnit = get(SISOfig,'Unit');
FigColor = get(SISOfig,'Color');

% Dimensions parameters
FigPos = get(SISOfig,'Position');
fHeight = 3.8;
xBorder = 2.5;
fWidth = FigPos(3)-25-2*xBorder-1.5;
X0 = xBorder;

FrameBase = FigPos(4)-1-fHeight;
TextBase = FrameBase + 1.2;
FrameHeight = 3.8;
FrameHandle = uicontrol('Parent',SISOfig, ...
    'ButtonDownFcn',{@LocalEditComp sisodb}, ...
    'Units',StdUnit, ...
    'Enable','inactive',...
    'Position',[X0 FrameBase fWidth FrameHeight], ...
    'BackgroundColor',FigColor,...
    'Style','frame');
CompensatorText = uicontrol('Parent',SISOfig, ...
    'Units',StdUnit, ...
    'Enable','inactive',...
    'Position',[X0+4 FrameBase+FrameHeight-.55 23 1.1], ...
    'BackgroundColor',FigColor,...
    'String','Current Compensator', ...
    'Style','text',...
    'HelpTopicKey',CompHelpTopic);
DomainText = uicontrol('Parent',SISOfig, ...
    'Enable','inactive',...
    'Units',StdUnit, ...
    'String','C(s) =',...
    'BackgroundColor',FigColor,...
    'ButtonDownFcn',{@LocalEditComp sisodb}, ...
    'Position',[X0+1 TextBase 7 1.1], ...
    'Style','text',...
    'HelpTopicKey',CompHelpTopic);

% Compensator num/den display
MultiplyText = uicontrol('Parent',SISOfig, ...
    'Enable','inactive',...
    'Units',StdUnit, ...
    'ButtonDownFcn',{@LocalEditComp sisodb}, ...
    'Position',[X0+23.5 TextBase+0.1 2 1], ...
    'BackgroundColor',FigColor,...
    'Visible','off',...
    'Style','text',...
    'String','x',...
    'HelpTopicKey',CompHelpTopic);
FractionText = uicontrol('Parent',SISOfig, ...
    'Enable','inactive',...
    'Units',StdUnit, ...
    'ButtonDownFcn',{@LocalEditComp sisodb}, ...
    'Position',[X0+26 TextBase+0.35 10 0.7], ...
    'BackgroundColor',FigColor,...
    'Style','text',...
    'HelpTopicKey',CompHelpTopic);
NumText = uicontrol('Parent',SISOfig, ...
    'Enable','inactive',...
    'Units',StdUnit, ...
    'ButtonDownFcn',{@LocalEditComp sisodb}, ...
    'Position',[X0+26 TextBase+0.7 10 1.1], ...
    'BackgroundColor',FigColor,...
    'Style','text', ...
    'Max',1, ...
    'Min',1,...
    'HelpTopicKey',CompHelpTopic);
DenText = uicontrol('Parent',SISOfig, ...
    'Enable','inactive',...
    'Units',StdUnit, ...
    'ButtonDownFcn',{@LocalEditComp sisodb}, ...
    'Position',[X0+26 TextBase-0.8 10 1.1], ...
    'BackgroundColor',FigColor,...
    'Max',1, ...
    'Min',1, ...
    'Style','text',...
    'HelpTopicKey',CompHelpTopic);

% w = (z-1)/Ts text
wText = zeros(1,3);
Xw = X0+fWidth-8;
wText(2) = uicontrol('Parent',SISOfig, ...
    'Units',StdUnit, ...
    'Position',[Xw TextBase 7 1.1],... 
    'BackgroundColor',FigColor,...
    'Style','text',...
    'String','w=-----');
wText(1) = uicontrol('Parent',SISOfig, ...
    'Units',StdUnit, ...
    'Position',[Xw+3 TextBase+0.7 4 1.1],... 
    'BackgroundColor',FigColor,...
    'Style','text',...
    'String','z-1');
wText(3) = uicontrol('Parent',SISOfig, ...
    'Units',StdUnit, ...
    'Position',[Xw+3 TextBase-0.8 4 1.1],... 
    'BackgroundColor',FigColor,...
    'Style','text',...
    'String','Ts');
set(wText,'Enable','inactive',...
    'ButtonDownFcn',{@LocalEditComp sisodb}, ...
    'Visible','off',...
    'HelpTopicKey',CompHelpTopic);

% Gain edit box
GainEdit = uicontrol('Parent',SISOfig, ...
    'Enable','off',...
    'Units',StdUnit, ...
    'BackgroundColor',[1 1 1], ...
    'Horiz','left', ...
    'Position',[X0+9 TextBase-0.15 13 1.5], ...
    'Style','edit', ...
    'TooltipString','Compensator gain',...
    'HelpTopicKey',CompHelpTopic,...
    'Callback',{@LocalEditGain sisodb});

Frame = struct(...
    'FrameHandle',FrameHandle,...
    'CompensatorText',CompensatorText,...
    'DomainText',DomainText,...
    'GainEdit',GainEdit,...
    'Multiply',MultiplyText,...
    'NumText',NumText,...
    'DenText',DenText,...
    'FractionText',FractionText,...
    'wText',wText);

% Install listeners
LoopData = sisodb.LoopData;
CompData = LoopData.Compensator;
lsnr(1) = handle.listener(CompData,...
    findprop(CompData,'Gain'),'PropertyPostSet',{@LocalUpdateGain GainEdit});
lsnr(2) = handle.listener(CompData,...
    findprop(CompData,'Ts'),'PropertyPostSet',{@LocalUpdateDomain DomainText});
lsnr(3) = handle.listener(CompData,...
    findprop(CompData,'Format'),'PropertyPostSet',{@LocalUpdateTF CompData Frame});
lsnr(4) = handle.listener(LoopData,'LoopDataChanged',{@LocalUpdateTF CompData Frame});
% Resize listener
fh = handle(FrameHandle);
lsnr(5) = handle.listener(fh,findprop(fh,'Position'),...
    'PropertyPostSet',{@LocalAdjustDisplay Frame});
set(FrameHandle,'UserData',lsnr)


%-------------------------Callback Functions-------------------------

%%%%%%%%%%%%%%%%%%%%%
%%% LocalEditComp %%%
%%%%%%%%%%%%%%%%%%%%%
function LocalEditComp(hSrcProp,event,sisodb)
% Brings up Edit Compensator window
if ~(strcmp(get(sisodb.Figure,'Selectiontype'),'open'))
    sisodb.TextEditors(1).show(sisodb.LoopData.Compensator);
end

%%%%%%%%%%%%%%%%%%%%%
%%% LocalEditGain %%%
%%%%%%%%%%%%%%%%%%%%%
function LocalEditGain(hEdit,event,sisodb)
% Edit compensator gain value

NewValue = str2num(get(hEdit,'String'));
LoopData = sisodb.LoopData;
EventMgr = sisodb.EventManager;

if isequal(size(NewValue),[1 1]) & isreal(NewValue) & isfinite(NewValue) 
    % Commit change 
    OldSign = LoopData.Compensator.getgain('sign');
    
    % Record transaction
    T = ctrluis.transaction(LoopData,'Name','Edit Gain',...
        'OperationStore','on','InverseOperationStore','on');
    
    % Set new value
    LoopData.Compensator.setgain(NewValue);
    
    % Commit and stack transaction, and trigger plot update
    EventMgr.record(T);
    if OldSign*NewValue<0,
        % Change of feedback sign: update all plot data
        LoopData.dataevent('all');
    else
        % Lightweight update
        LoopData.dataevent('gainC');
    end
    % Notify status bar and history listeners
    Status = sprintf('Loop gain changed to %0.3g',NewValue);
    EventMgr.newstatus(Status);
    EventMgr.recordtxt('history',Status);
else
    % Revert to old value
    set(hEdit,'String',sprintf('%0.3g',LoopData.Compensator.getgain))
end


%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalUpdateGain %%%
%%%%%%%%%%%%%%%%%%%%%%%
function LocalUpdateGain(hProp,event,hEdit)
% Update display of compensator gain value
set(hEdit,'String',sprintf('%0.3g',getgain(event.AffectedObject)))
 

%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalUpdateDomain %%%
%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalUpdateDomain(hProp,event,hText)
% Update display of compensator gain value
if event.NewValue,
   set(hText,'String','C(z) =')
else
   set(hText,'String','C(s) =')
end


%%%%%%%%%%%%%%%%%%%%%
%%% LocalUpdateTF %%%
%%%%%%%%%%%%%%%%%%%%%
function LocalUpdateTF(hSrc,event,CompData,CompFrame)
% Updates display of compensator transfer function

% Display only the gain if there are no dynamics
if isempty(CompData.PZGroup)
   set([CompFrame.wText,CompFrame.Multiply,...
           CompFrame.DenText,CompFrame.NumText,CompFrame.FractionText],'Visible','off')
   return
else
    set([CompFrame.Multiply,CompFrame.DenText,...
            CompFrame.NumText,CompFrame.FractionText],'Visible','on')    
end
Format = CompData.Format;
Ts = CompData.Ts;

% Visibility of (w=z-1/Ts) text
if Ts & ~strcmpi(Format(1),'z')
   set(CompFrame.wText,'Visible','on')
else
   set(CompFrame.wText,'Visible','off')
end

% Numerator display
Zeros = get(CompData.PZGroup,{'Zero'});
NumStr = LocalFormat(cat(1,Zeros{:}),Ts,Format);
set(CompFrame.NumText,'UserData',NumStr)

% Denominator display
Poles = get(CompData.PZGroup,{'Pole'});
DenStr = LocalFormat(cat(1,Poles{:}),Ts,Format);
set(CompFrame.DenText,'UserData',DenStr)

% Display transfer function
LocalAdjustDisplay([],[],CompFrame);


%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalAdjustDisplay %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalAdjustDisplay(hProp,event,CompFrame)
% Adjusts compensator display based on frame size

NumStr = get(CompFrame.NumText,'UserData');
DenStr = get(CompFrame.DenText,'UserData');
if isempty(NumStr)
    return
end

% Geometric variables
wExtent = get(CompFrame.wText(2),'Position');
wExtent = wExtent(3);
FramePos = get(CompFrame.FrameHandle,'Position');
MultPos = get(CompFrame.Multiply,'Position');
MaxTextWidth = FramePos(3)-wExtent-(MultPos(1)+MultPos(3))-1;                                           

% Adjust numerator display
set(CompFrame.NumText,'String',NumStr)
NumExtent = get(CompFrame.NumText,'Extent');
if NumExtent(3)>MaxTextWidth, % Text is too long
   set(CompFrame.NumText,'String','NumC')
   NumExtent = get(CompFrame.NumText,'Extent');
end

% Adjust denominator display
set(CompFrame.DenText,'String',DenStr)
DenExtent = get(CompFrame.DenText,'Extent');
if DenExtent(3)>MaxTextWidth, % Text is too long
   set(CompFrame.DenText,'String','DenC')
   DenExtent = get(CompFrame.DenText,'Extent');
end

% Adjust width of text areas
TextWidth = max(NumExtent(3),DenExtent(3));
NumPos = get(CompFrame.NumText,'Position');
NumPos(3) = TextWidth + 1;
set(CompFrame.NumText,'Position',NumPos);
DenPos = get(CompFrame.DenText,'Position');
DenPos(3) = TextWidth + 1;
set(CompFrame.DenText,'Position',DenPos);

% Update length of fraction bar
FC = '-';
set(CompFrame.FractionText,'String',FC(:,ones(1,20)))
Extent = get(CompFrame.FractionText,'Extent');
ExtentRatio = TextWidth/Extent(3);
Position = get(CompFrame.FractionText,'Position');
Position(3) = TextWidth + 1;
set(CompFrame.FractionText,...
    'Position',Position,...
    'String',FC(:,ones(1,ceil(20*ExtentRatio)+2)))


%-------------------------Helper Functions----------------------

%%%%%%%%%%%%%%%%%%%
%%% LocalFormat %%%
%%%%%%%%%%%%%%%%%%%
function str = LocalFormat(P,Ts,Format)
% Formats display
Format = lower(Format);  

% Defaults
str = '';
if Ts == 0
    Var = 's';
elseif strcmp(Format(1), 'z')
    % ZeroPoleGain format
    Var = 'z';
else
    Var = 'w';
    P = (P-1)/Ts;  % Equivalent s-domain root is (z-1)/Ts 
end

% Sort roots
P = [P(~imag(P),:) ; P(imag(P)>0,:)];

% Put roots at the origin (s=0 or z=1) upfront
if strcmp(Var,'z')
   indint = find(P==1);
else
   indint = find(P==0);
end
nint = length(indint);
P(indint,:) = [];
switch Var
case 's'
   if nint>1
      str = sprintf('%s^%d',Var,nint);
   elseif nint==1
      str = Var;
   end
case {'z','w'}
   if nint>1
      str = sprintf('(z-1)^%d',nint);
   elseif nint==1
      str = sprintf('(z-1)');
   end
end
   
% Loop over remaining roots
Signs = {'+','-'};
switch Format
case 'zeropolegain'  % zero/pole/gain
   for ct = 1:length(P)
      Pct = P(ct);
      SignType = Signs{1+(real(Pct)>0)};
      if ~imag(Pct),
         if real(Pct)
            NextStr = sprintf('(%s %s %0.3g)',Var,SignType,abs(real(Pct)));
         else
            NextStr = Var;
         end
      else
         if real(Pct)
            NextStr = sprintf('(%s^2 %s %0.3g%s + %0.3g)',Var,SignType,...
               2*abs(real(Pct)),Var,(real(Pct)^2+imag(Pct)^2));
         else
            NextStr = sprintf('(%s^2 + %0.3g)',Var,real(Pct)^2+imag(Pct)^2);
         end
      end
      str = sprintf('%s %s',str,NextStr);
   end
   
case 'timeconstant1'  % time constant 1, i.e., (1 + Tp s)
    for ct = 1:length(P)
        Pct = P(ct);
        SignType = Signs{1+(real(Pct)>0)};
        if ~imag(Pct),
            % Real root
            rp = 1/abs(real(Pct));
            if rp==1, 
                NextStr = sprintf('(1 %s %s)',SignType,Var);
            else
                NextStr = sprintf('(1 %s %0.2g%s)',SignType,rp,Var);
            end
        elseif real(Pct)
            % Complex root with nonzero real part
            w = abs(Pct);
            rp = 2*abs(real(Pct))/w^2;
            if w==1, 
                NextStr = sprintf('(1 %s %0.2g%s + %s^2)',SignType,rp,Var,Var);
            else         
                NextStr = sprintf('(1 %s %0.2g%s + (%0.2g%s)^2)',SignType,rp,Var,1/w,Var);
            end
        else
            % Root j*b
            NextStr = sprintf('(1 + (%0.2g%s)^2)',1/abs(Pct),Var);
        end
        str = sprintf('%s %s',str,NextStr);
    end
    
case 'timeconstant2'  % time constant 2 (natural frequency), i.e., (1 + s/p)
    for ct = 1:length(P)
        Pct = P(ct);
        SignType = Signs{1 + (real(Pct)>0)};
        if ~imag(Pct)
            % Real root
            rp = abs(real(Pct));
            if rp == 1, 
                NextStr = sprintf('(1 %s %s)', SignType, Var);
            else
                NextStr = sprintf('(1 %s %s/%0.2g)', SignType, Var, rp);
            end
        elseif real(Pct)
            % Complex root with nonzero real part
            wn = sqrt(real(Pct)^2 + imag(Pct)^2);
            rp = 2 * abs(real(Pct)) / wn;
            if wn == 1
                NextStr = sprintf('(1 %s %0.2g%s + %s^2)', ...
                    SignType, rp, Var, Var);
            else         
                NextStr = sprintf('(1 %s %0.2g%s/%0.2g + (%s/%0.2g)^2)', ...
                    SignType, rp, Var, wn, Var, wn);
            end
        else
            % Complex root with zero real part (root j*b)
            NextStr = sprintf('(1 + (%s/%0.2g)^2)', Var, abs(Pct));
        end
        str = sprintf('%s %s', str, NextStr);
    end
    
end

% Set string to 1 if no root
if isempty(str)
    str = '1';
end
