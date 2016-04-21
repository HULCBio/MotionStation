function [x,y] = manswitch(command)
%MANSWITCH Manual switch helper function.

%   Author(s): D. Orofino, L.Dean
%   Copyright 1990-2003 The MathWorks, Inc.
%   $Revision: 1.17.2.3 $

% NOTE: The Manual Switch block's open function sets
%       action='1'.  Otherwise, it is '0'.

if nargin,
  switch command
    case 'Open'
      if strcmp(get_param(bdroot(gcbh),'BlockDiagramType'),'library') && ...
            strcmp(get_param(bdroot(gcbh),'Lock'),'on'),
        errordlg(['Manual Switch block must be placed in a model or ' ...
              'unlocked library in order to operate.'])
      else
        blk = gcbh;
        mdl = bdroot(blk);
        dirty = get_param(mdl,'dirty');
        set_param(gcbh,'action','1');
        set_param(mdl,'dirty',dirty);
      end
  end

  return
end

blk = gcbh;
mdl = bdroot(blk);
dirty = get_param(mdl,'dirty');
sw  = get_param(blk,'sw');

if (sw ~= '0' && sw ~= '1')
    %tmp = display('Warning: Any nonzero input for parameter ''sw'' will be considered as ''1''.');
    sw = '1';
    set_param(blk,'sw','1');
end
    

% Only toggle switch if OpenFcn got us here:
if (get_param(blk,'action') == '1'),
  set_param(blk,'action','0');
  if sw=='1', sw='0'; else sw='1'; end
  set_param(blk,'sw',sw);
end

sfcnBlock=find_system(blk            , ...
                      'LookUnderMasks','all' , ...
                      'FollowLinks'   ,'on'  , ...
                      'Name'          ,'SimValue'  ...
                      );

if ~isempty(sfcnBlock)
  rtwblk = sprintf('%s/RTWValue',gcb);
  set_param(sfcnBlock,'Parameters',['boolean(',sw,')']);
  try
     % protect against inline parameters
     set_param(rtwblk,'Value',['boolean(',sw,')']);
  catch
  end
else
  stepBlock=find_system(blk            , ...
			'LookUnderMasks','all' , ...
			'FollowLinks'   ,'on'  , ...
			'Name'          ,'Step'  ...
			);
  if ~isempty(stepBlock)
    set_param(stepBlock,'After',sw);
  else
    constBlock=find_system(blk            , ...
			   'LookUnderMasks','all' , ...
			   'FollowLinks'   ,'on'  , ...
			   'BlockType'     ,'Constant'  ...
			   );
    if ~isempty(constBlock)
      set_param(constBlock,'Value',sw)
    end
  end
  warning(['You are using an old version of the Manual Switch block. '...
	   'Please update block ''' ...
	   strrep(getfullname(blk),sprintf('\n'),' ') ''' '...
	   'with the latest version from the Simulink library']);

end



% Construct switch icon:
%
% --- Switch stub circles:
BlockPos=get_param(blk,'Position');
Width=BlockPos(3)-BlockPos(1);
Height=BlockPos(4)-BlockPos(2);

PortInfo=get_param(blk,'PortConnectivity');
PortPos=cat(1,PortInfo.Position);
% Port locations in global Simulink coordinates
x=PortPos(:,1);
y=PortPos(:,2);
% Move locations inside of block icon (still global coordinates)
x = x + 5*(x < BlockPos(1)) - 5*(x > BlockPos(3));
y = y + 5*(y < BlockPos(2)) - 5*(y > BlockPos(4));
% Convert to plot coordinates
x = x - BlockPos(1);
y = BlockPos(4) - y;
PortPos=[x y];

Radius=ceil(min(Height,Width)/15);
LineLength=min(6,10*Radius/3);
Offset=Radius+LineLength;

switch get_param(blk,'Orientation'),
  case 'down',
    OutportX=PortPos(3,1);
    OutportY=PortPos(3,2)+Offset;
    Inport1X=PortPos(1,1);
    Inport1Y=PortPos(1,2)-Offset;
    Inport2X=PortPos(2,1);
    Inport2Y=PortPos(2,2)-Offset;
    ConnectLinesX=[Inport1X Inport1X NaN ...
                   Inport2X Inport2X NaN ...
                   OutportX OutportX ];
    ConnectLinesY=[Height-LineLength Height     NaN ...
                   Height-LineLength Height     NaN ...
                   0                 LineLength ];
    FlapiX=OutportX;
    FlapiY=OutportY+Radius;

    if sw=='0',
      [FlapfX,FlapfnY] = ...
        LocalCalcRot(FlapiX,FlapiY,Inport2X,Inport2Y,Radius,'XLow');
    else
      [FlapfX,FlapfnY] = ...
        LocalCalcRot(FlapiX,FlapiY,Inport1X,Inport1Y,Radius,'XHigh');
    end
    FlapfY=FlapfnY+3*Radius/4;
    FlapfX=FlapiX+(FlapfX-FlapiX)*(abs(FlapfY-FlapiY)/abs(FlapfnY-FlapiY));

  case 'up',
    OutportX=PortPos(3,1);
    OutportY=PortPos(3,2)-Offset;
    Inport1X=PortPos(1,1);
    Inport1Y=PortPos(1,2)+Offset;
    Inport2X=PortPos(2,1);
    Inport2Y=PortPos(2,2)+Offset;
    ConnectLinesX=[Inport1X Inport1X NaN ...
                   Inport2X Inport2X NaN ...
                   OutportX OutportX ];
    ConnectLinesY=[0                 LineLength NaN ...
                   0                 LineLength NaN ...
                   Height-LineLength Height     ];

    FlapiX=OutportX;
    FlapiY=OutportY-Radius;

    if sw=='0',
      [FlapfX,FlapfnY] = ...
        LocalCalcRot(FlapiX,FlapiY,Inport2X,Inport2Y,Radius,'XLow');
    else
      [FlapfX,FlapfnY] = ...
        LocalCalcRot(FlapiX,FlapiY,Inport1X,Inport1Y,Radius,'XHigh');
    end
    FlapfY=FlapfnY-3*Radius/4;
    FlapfX=FlapiX+(FlapfX-FlapiX)*(abs(FlapfY-FlapiY)/abs(FlapfnY-FlapiY));

  case 'left',
    OutportX=PortPos(3,1)+Offset;
    OutportY=PortPos(3,2);
    Inport1X=PortPos(1,1)-Offset;
    Inport1Y=PortPos(1,2);
    Inport2X=PortPos(2,1)-Offset;
    Inport2Y=PortPos(2,2);
    ConnectLinesX=[Width-LineLength Width      NaN ...
                   Width-LineLength Width      NaN ...
                   0                LineLength ];
    ConnectLinesY=[Inport1Y Inport1Y NaN ...
                   Inport2Y Inport2Y NaN ...
                   OutportY OutportY ];
    FlapiX=OutportX+Radius;
    FlapiY=OutportY;

    if sw=='0',
      [FlapfnX,FlapfY] = ...
        LocalCalcRot(FlapiX,FlapiY,Inport2X,Inport2Y,Radius,'YHigh');
    else
      [FlapfnX,FlapfY] = ...
        LocalCalcRot(FlapiX,FlapiY,Inport1X,Inport1Y,Radius,'YLow');
    end
    FlapfX=FlapfnX+3*Radius/4;
    FlapfY=FlapiY+(FlapfY-FlapiY)*(abs(FlapfX-FlapiX)/abs(FlapfnX-FlapiX));

  case 'right',
    OutportX=PortPos(3,1)-Offset;
    OutportY=PortPos(3,2);
    Inport1X=PortPos(1,1)+Offset;
    Inport1Y=PortPos(1,2);
    Inport2X=PortPos(2,1)+Offset;
    Inport2Y=PortPos(2,2);
    ConnectLinesX=[0                LineLength NaN ...
                   0                LineLength NaN ...
                   Width-LineLength Width      ];
    ConnectLinesY=[Inport1Y Inport1Y NaN ...
                   Inport2Y Inport2Y NaN ...
                   OutportY OutportY ];

    FlapiX=OutportX-Radius;
    FlapiY=OutportY;

    if sw=='0',
      [FlapfnX,FlapfY] = ...
        LocalCalcRot(FlapiX,FlapiY,Inport2X,Inport2Y,Radius,'YHigh');
    else
      [FlapfnX,FlapfY] = ...
        LocalCalcRot(FlapiX,FlapiY,Inport1X,Inport1Y,Radius,'YLow');
    end
    FlapfX=FlapfnX-3*Radius/4;
    FlapfY=FlapiY+(FlapfY-FlapiY)*(abs(FlapfX-FlapiX)/abs(FlapfnX-FlapiX));
end

t=(0:20)/20*2*pi;   CircX=cos(t)*Radius;   CircY=sin(t)*Radius;
AllCircX=[CircX+Inport1X NaN CircX+Inport2X NaN CircX+OutportX ];
AllCircY=[CircY+Inport1Y NaN CircY+Inport2Y NaN CircY+OutportY ];

% --- Switch Flap:
FlapX=[FlapiX FlapfX];
FlapY=[FlapiY FlapfY];

% --- Icon coordinate vectors:
x=[ConnectLinesX NaN AllCircX NaN FlapX];
y=[ConnectLinesY NaN AllCircY NaN FlapY];

% --- restore the dirty flag:
set_param(mdl,'dirty',dirty);
% [EOF] manswitch.m


%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalCalcRot %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%
function [X,Y]=LocalCalcRot(FlapX,FlapY,CircX,CircY,Radius,LowHigh)

% (CircX-X)^2+(CircY-Y)^2=Radius^2
% (FlapX-CircX)(X-CircX)+(FlapY-CircX)(Y-CircY)=Radius^2
%
% Solving:

R2=Radius^2;

S = (FlapY-CircY)/(FlapX-CircX);
S2=S^2;

b = R2/(FlapY-CircY);
c = (CircY^2)+((b^2)*S2-R2+2*CircY*b*S2)/(S2+1);
d = CircY+b*S2/(S2+1);

pmterm=sqrt(d^2-c);
Yminus = d-pmterm;
Yplus  = d+pmterm;

Xminus = R2/(FlapY-CircY)*S-Yminus*S+CircY*S+CircX;
Xplus  = R2/(FlapY-CircY)*S-Yplus*S+CircY*S+CircX;

switch LowHigh,
  case 'XLow',
    if Xminus<Xplus,
      X=Xminus;Y=Yminus;
    else
      X=Xplus;Y=Yplus;
    end

  case 'YLow',
    if Yminus<Yplus,
      X=Xminus;Y=Yminus;
    else
      X=Xplus;Y=Yplus;
    end

  case 'XHigh',
    if Xminus>Xplus,
      X=Xminus;Y=Yminus;
    else
      X=Xplus;Y=Yplus;
    end

  case 'YHigh',
    if Yminus>Yplus,
      X=Xminus;Y=Yminus;
    else
      X=Xplus;Y=Yplus;
    end

end  % switch
