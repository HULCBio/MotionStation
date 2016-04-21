function quatdemo(varargin)
% QUATDEMO Quaternion demonstration.
%   QUATDEMO runs a demo for quaternions through the use of a
%   simple aircraft orientation graphical interface.  The aircraft
%   can be rotated using the traditional body rotations Psi, Theta,
%   and Phi.  It can also be rotated using the quaternion
%   representation.
%

%   Loren Dean
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.17.4.3 $ $Date: 2004/04/10 23:25:43 $

QuatFig=findall(0,'Type','figure','Tag','QuatWorkingFig');

if ~isempty(QuatFig),
  Data=get(QuatFig,'UserData');
  Data.QuatFig=Data.QuatFig(ishandle(Data.QuatFig));

  % Don't flash the watch during simulation
  if nargin~=4,
    set(Data.QuatFig,'Pointer','watch');
  end

end

switch nargin,
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%% Initialize from Command Line %%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  case 0,
    Data=LocalInitFig('Figure');

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%% Action Being Performed %%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  case 1,
    Action=varargin{1};

    if ~ischar(Action),
      error('Invalid Action for Quatdemo.');
    end

    if isempty(QuatFig),
      return;
    end

    switch Action,
      case 'Close',
        set(Data.DynamicButton,'UserData',1);
        delete(Data.QuatFig);

      case 'Help',
        IsDynamic=get(Data.DynamicButton,'Value');
        LocalHelp(IsDynamic);
      case 'StaticDynamic',
        LocalStaticDynamic(Data)

      otherwise,
        error('Invalid Action for Quatdemo.');

    end % switch

  % This is called by the slider and text fields for PTP and PQR.
  % If SL is driving the dynamics then we don't want to loop through
  % the dynamic portion of the LocalDraw function.
  case 2,

    SimQuatIsOpen=0;
    SimQuatIsRunning=0;
    if Data.LicensedForSL,
      SimQuatIsOpen=~isempty( ...
        find_system('Type','block_diagram','Name','simquat') ...
                            );
      if SimQuatIsOpen,
        SimQuatStatus=get_param('simquat','SimulationStatus');
        SimQuatIsRunning=~strcmp(SimQuatStatus,'stopped');
      end % if
    end % if
    [IsDynamic,TransMat]=LocalCalcTransform(QuatFig,Data,'Figure',varargin{:});

    if SimQuatIsRunning,
      LocalDraw(TransMat,IsDynamic,QuatFig,Data,'Simulink',varargin{1});
    else
      LocalDraw(TransMat,IsDynamic,QuatFig,Data,'Figure',varargin{1});
    end % if

    if SimQuatIsOpen,
      Sys='simquat/Quaternion';
      set_param(Sys,'Psi'  ,get(Data.Psi(2)  ,'String'));
      set_param(Sys,'Theta',get(Data.Theta(2),'String'));
      set_param(Sys,'Phi'  ,get(Data.Phi(2)  ,'String'));
      set_param('simquat/Inputs/P','Value',get(Data.P(2),'String'));
      set_param('simquat/Inputs/Q','Value',get(Data.Q(2),'String'));
      set_param('simquat/Inputs/R','Value',get(Data.R(2),'String'));

    end % if

  % called by openfcn from any of the simquat systems
  case 3,
    Data=LocalInitFig('Simulink');
    if strcmp(varargin{1},'Static'),
      LocalStaticDynamic(Data,'Static');
    else
      LocalStaticDynamic(Data);
    end

  % called by output function in eulrotdisplay
  case 4,
    QuatFig=varargin{1};
    Data=get(QuatFig,'UserData');
    RotType=get(Data.ResetHandle,'UserData');
    [IsDynamic,TransMat]=LocalCalcTransform(QuatFig,Data, ...
                                           'Simulink','PTP',varargin{2:end});
    if strcmp(RotType,'Reset'),
      P=get(Data.P(1),'Value');
      Q=get(Data.Q(1),'Value');
      R=get(Data.R(1),'Value');
      [P,Q,R]=LocalResetVal(Data,P,Q,R);
      if P==0 && Q==0 && R==0,
        set(Data.ResetHandle,'Enable','off','UserData','P');
      else
        set(Data.ResetHandle,'UserData','Reset');
      end % if
      set_param('simquat/Inputs/P','Value',get(Data.P(2),'String'));
      set_param('simquat/Inputs/Q','Value',get(Data.Q(2),'String'));
      set_param('simquat/Inputs/R','Value',get(Data.R(2),'String'));

    end % if RotType

    LocalDraw(TransMat,IsDynamic,QuatFig,Data,'Simulink','PTP');

  otherwise,
    error('Quaternion Figure does not exist. Cannot Execute Callback.');

end % switch

Data.QuatFig=Data.QuatFig(ishandle(Data.QuatFig));
set(Data.QuatFig,'Pointer','arrow');

%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalCalcRot %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%
function Rot=LocalCalcRot(Handles,Rot,Min,Max,QuatFig,MinTol,MaxTol)

% Was the slider clicked on
if ~isempty(gcbo) && gcbo==Handles(1),
  set(Handles(2),'String',num2str(Rot));

% No, the text field was changed or the simulation is terminating
else
  Rot=str2double(get(Handles(2),'String'));
  if isnan(Rot),Rot=0;set(Handles(2),'String',num2str(Rot));end
  if Rot>Max,
    Rot=Max-MaxTol;set(Handles(2),'String',num2str(Rot));
  elseif Rot<Min,
    Rot=Min+MinTol;set(Handles(2),'String',num2str(Rot));
  end
  set(Handles(1),'Value',Rot);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalCalcTransform %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [IsDynamic,TransMat]=LocalCalcTransform(QuatFig,Data,Caller,varargin)
R2D=180/pi;

if isempty(QuatFig),return;end

if strcmp(Caller,'Figure'),
  Action=varargin{1};
  RotType=varargin{2};

  IsDynamic  = logical(get(Data.DynamicButton,'Value'));
  Psi        = get(Data.Psi(1),'Value');
  Theta      = get(Data.Theta(1),'Value');
  Phi        = get(Data.Phi(1),'Value');
  Beta       = get(Data.Beta(1),'Value');
  Azimuth    = get(Data.Azimuth(1),'Value');
  Elevation  = get(Data.Elevation(1),'Value');

else
  IsDynamic=false;
  Action=varargin{1};
  Psi=varargin{2};
  Theta=varargin{3};
  Phi=varargin{4};
  RotType='Euler';
  Beta       = get(Data.Beta(1),'Value');
end

%%% Static Rotation %%%
if ~IsDynamic,
  switch RotType,

    %%% Euler %%%
    case 'Euler',
      switch Action,
        case 'Psi',
          Psi=LocalCalcRot(Data.Psi,Psi,-180,180,QuatFig,0.1,0.1);

        case 'Theta',
          Theta=LocalCalcRot(Data.Theta,Theta,-90,90,QuatFig,0.1,0.1);

        case 'Phi',
          Phi=LocalCalcRot(Data.Phi,Phi,-180,180,QuatFig,0.1,0.1);

        case 'PTP',
          set(Data.Psi(2),'String',num2str(Psi));
          set(Data.Theta(2),'String',num2str(Theta));
          set(Data.Phi(2),'String',num2str(Phi));

      end % switch

      Psi=Psi/R2D;Theta=Theta/R2D;Phi=Phi/R2D;

      Quat=[ ...
        cos(Psi/2)*cos(Theta/2)*sin(Phi/2)-cos(Phi/2)*sin(Psi/2)*sin(Theta/2)
        sin(Psi/2)*cos(Theta/2)*sin(Phi/2)+cos(Phi/2)*cos(Psi/2)*sin(Theta/2)
        sin(Psi/2)*cos(Theta/2)*cos(Phi/2)-sin(Phi/2)*cos(Psi/2)*sin(Theta/2)
        cos(Psi/2)*cos(Theta/2)*cos(Phi/2)+sin(Phi/2)*sin(Psi/2)*sin(Theta/2)
           ]';

      TransMat=[1           0         0
             0           cos(Phi)  sin(Phi)
             0          -sin(Phi)  cos(Phi)]  ...
            * ...
            [cos(Theta)  0        -sin(Theta)
             0           1         0
             sin(Theta)  0         cos(Theta)] ...
            * ...
            [cos(Psi)   sin(Psi)  0
            -sin(Psi)    cos(Psi)  0
             0           0         1         ];

      [Azimuth,Elevation,Beta]=LocalSetBeta(Data,Beta,Quat);
      if strcmp(Caller,'Figure'),
        set(Data.Beta(1),'Value',Beta);
        set(Data.Azimuth(1),'Value',Azimuth);
        set(Data.Elevation(1),'Value',Elevation);
      end

      set(Data.Beta(2),'String',num2str(Beta));
      set(Data.Azimuth(2),'String',num2str(Azimuth));
      set(Data.Elevation(2),'String',num2str(Elevation));

    %%% Camera %%%
    case 'Camera',
      switch Action,
        case 'Azimuth',
          Azimuth=LocalCalcRot(Data.Azimuth,Azimuth,-360,360,QuatFig,0.1,0.1);

        case 'Elevation',
          Elevation= ...
            LocalCalcRot(Data.Elevation,Elevation,-180,180,QuatFig,0,0);

      end % switch


      TransAz=[cos(Azimuth/R2D) -sin(Azimuth/R2D) 0
               sin(Azimuth/R2D)  cos(Azimuth/R2D) 0
               0                    0                   1];
      TransEl=[cos(Elevation/R2D) 0  sin(Elevation/R2D)
               0                  1  0
              -sin(Elevation/R2D) 0  cos(Elevation/R2D)];
      TransMat=TransAz*TransEl;
      Quat=[(TransMat*[0;0;1])'*sin(Beta/R2D/2) cos(Beta/2/R2D)];

    %%% Beta %%%
    case 'Beta',
      Beta=LocalCalcRot(Data.Beta,Beta,0,360,QuatFig,0,0.1);
      if Beta==360,Beta=0;end
      if Beta==0,Azimuth=0;Elevation=0;end
      Quat=LocalGetQuat(Data,Beta);

    %%% Reset %%%
    case 'Reset',
      if ~isequal(Beta,0),
        if rem(Beta,5)==0,
          Beta=Beta-5;
        else
          Beta=Beta-rem(Beta,5);
        end
      end % if ~isequal
      set(Data.Beta(1),'Value',Beta);
      set(Data.Beta(2),'String',num2str(Beta));

      if Beta==0,Azimuth=0;Elevation=0;end
      Quat=LocalGetQuat(Data,Beta);

    %%% Nothing %%%
    case 'Nothing',
      Quat=LocalGetQuat(Data,Beta);

  end % switch RotType

  if ~isequal(RotType,'Euler'),
    TransMat=LocalQuat2TransMat(Quat);
    [Psi,Theta,Phi]=LocalGetPTP(TransMat);
    LocalSetPsiThetaPhi(Data,Psi,Theta,Phi)

  end % if ~e

%%% Dynamic Rotation %%%
else

  P=get(Data.P(1),'Value');
  Q=get(Data.Q(1),'Value');
  R=get(Data.R(1),'Value');

  switch RotType,
    case 'P',
      P=LocalCalcRot(Data.P,P,-10,10,QuatFig,0,0);

    case 'Q',
      Q=LocalCalcRot(Data.Q,Q,-10,10,QuatFig,0,0);

    case 'R',
      R=LocalCalcRot(Data.R,R,-10,10,QuatFig,0,0);

    case 'Reset',
      [P,Q,R]=LocalResetVal(Data,P,Q,R);

  end % switch

  P=P/R2D;Q=Q/R2D;R=R/R2D;
  Psi=Psi/R2D;Theta=Theta/R2D;Phi=Phi/R2D;

  Quat=get(Data.QuatText,'UserData');
  QuatRates=[-Q*Quat(3)+P*Quat(4)+R*Quat(2) ...
              P*Quat(3)+Q*Quat(4)-R*Quat(1) ...
              Q*Quat(1)-P*Quat(2)+R*Quat(4) ...
             -P*Quat(1)-Q*Quat(2)-R*Quat(3)
            ]/2;

  Quat=Quat+QuatRates;Quat=Quat/norm(Quat);
  TransMat=LocalQuat2TransMat(Quat);
  [Psi,Theta,Phi]=LocalGetPTP(TransMat);
  LocalSetPsiThetaPhi(Data,Psi,Theta,Phi)

  [Azimuth,Elevation,Beta]=LocalSetBeta(Data,Beta,Quat);

  set(Data.Beta(1),'Value',Beta);
  set(Data.Beta(2),'String',num2str(Beta));
  set(Data.Azimuth(1),'Value',Azimuth);
  set(Data.Azimuth(2),'String',num2str(Azimuth));
  set(Data.Elevation(1),'Value',Elevation);
  set(Data.Elevation(2),'String',num2str(Elevation));

  if P==0 && Q==0 && R==0,
    set(Data.ResetHandle,'Enable','off');
  else
    set(Data.ResetHandle,'Enable','on');
  end % if P
end % if IsDynamic

set(Data.QuatText,'UserData',Quat);
set(Data.ResetHandle,'UserData',RotType);

%%%%%%%%%%%%%%%%%
%%% LocalDraw %%%
%%%%%%%%%%%%%%%%%
function LocalDraw(TransMat,IsDynamic,QuatFig,Data,Caller,Action)
R2D=180/pi;
DrawFlag=get(Data.DynamicButton,'UserData');

% Protection from reentering the dynamic loop
if DrawFlag~=1,return;end
DrawFlag=false;

while ~DrawFlag,

  RotType=get(Data.ResetHandle,'UserData');

  Psi=get(Data.Psi(1),'Value');
  Theta=get(Data.Theta(1),'Value');
  Phi=get(Data.Phi(1),'Value');

  Beta=get(Data.Beta(1),'Value');
  Azimuth=get(Data.Azimuth(1),'Value');
  Elevation=get(Data.Elevation(1),'Value');

  P=get(Data.P(1),'Value');
  Q=get(Data.Q(1),'Value');
  R=get(Data.R(1),'Value');

  Quat=get(Data.QuatText,'UserData');
  set(Data.QuatText,'String',mat2str(Quat,2));
  set(Data.DynamicButton,'UserData',true);

  %%% Draw Everything
  [L1,L2,L3]=LocalGetL(Quat);
  set(Data.PointerHandles, ...
     'XData',[0  L2*80], ...
     'YData',[0  L1*80], ...
     'ZData',[0 -L3*80]  ...
     );


  TransE2S=[0 1 0;1 0 0;0 0 -1];
  PData=get(Data.PlaneHandles,{'UserData'});
  for lp=1:length(Data.PlaneHandles),
    NewData(lp,:)=num2cell(TransE2S'*TransMat'*PData{lp},2)';
  end % for lp
  set(Data.PlaneHandles,{'XData','YData','ZData'},NewData);

  % Check to see if called by the figure or by SIMULINK
  if strcmp(Caller,'Figure'),

    %%% Dynamic %%%
    % Called by the figure and in dynamic mode so keep looping
    if IsDynamic,
      if ~(P==0 && Q==0 && R==0),
        set(QuatFig,'Pointer','arrow');
        set(Data.DynamicButton,'UserData',false);

        if strcmp(RotType,'Reset'),
          [P,Q,R]=LocalResetVal(Data,P,Q,R);
        end % if RotType

        % Convert to Radians
        P=P/R2D;Q=Q/R2D;R=R/R2D;
        Psi=Psi/R2D;Theta=Theta/R2D;Phi=Phi/R2D;

        Quat=get(Data.QuatText,'UserData');
        QuatRates=[-Q*Quat(3)+P*Quat(4)+R*Quat(2) ...
                    P*Quat(3)+Q*Quat(4)-R*Quat(1) ...
                    Q*Quat(1)-P*Quat(2)+R*Quat(4) ...
                   -P*Quat(1)-Q*Quat(2)-R*Quat(3)
                  ]/2;

        Quat=Quat+QuatRates;Quat=Quat/norm(Quat);
        TransMat=LocalQuat2TransMat(Quat);
        [Psi,Theta,Phi]=LocalGetPTP(TransMat);
        LocalSetPsiThetaPhi(Data,Psi,Theta,Phi)
        [Azimuth,Elevation,Beta]=LocalSetBeta(Data,Beta,Quat);

        set(Data.Beta(1),'Value',Beta);
        set(Data.Beta(2),'String',num2str(Beta));
        set(Data.Azimuth(1),'Value',Azimuth);
        set(Data.Azimuth(2),'String',num2str(Azimuth));
        set(Data.Elevation(1),'Value',Elevation);
        set(Data.Elevation(2),'String',num2str(Elevation));

        if P==0 && Q==0 && R==0,
          set(Data.ResetHandle,'Enable','off');
          set(Data.DynamicButton,'UserData',true);
        else
          set(Data.ResetHandle,'Enable','on');
        end % if P
        set(Data.QuatText,'UserData',Quat);
      end % if P

    %%% Static %%%
    else
      if Beta==0||Beta==360,
        set([Data.Azimuth(1) Data.Elevation(1) Data.Beta(1)], ...
            'Value',0,'Enable','off');
        set([Data.Azimuth(2) Data.Elevation(2) Data.Beta(2)], ...
           'String',num2str(0),'Enable','off');
        set(Data.ResetHandle,'Enable','off');
        set([Data.Psi(1),Data.Phi(1),Data.Beta(1)],'Value',0);
        set([Data.Psi(2),Data.Phi(2),Data.Theta(2)],'String',num2str(0));
      else
        set([Data.Azimuth Data.Elevation Data.Beta Data.ResetHandle], ...
            'Enable','on');
      end % if Beta

      if strcmp(Action,'Reset'),
        if Beta~=0,
          if rem(Beta,5)==0,
            Beta=Beta-5;
          else
            Beta=Beta-rem(Beta,5);
          end
          set(Data.Beta(1),'Value',Beta);
          set(Data.Beta(2),'String',num2str(Beta));
          if Beta==0,Azimuth=0;Elevation=0;end

          Quat=LocalGetQuat(Data,Beta);
          TransMat=LocalQuat2TransMat(Quat);

          [Psi,Theta,Phi]=LocalGetPTP(TransMat);
          LocalSetPsiThetaPhi(Data,Psi,Theta,Phi)
          set(Data.QuatText,'UserData',Quat);

          set(Data.DynamicButton,'UserData',false);
        end % if Beta ~=0
      end % if strcmp

    end % if IsDynamic

    drawnow;
    if ~ishandle(QuatFig),return;end
    DrawFlag=get(Data.DynamicButton,'UserData');

  else %called by Simulink

    DrawFlag=true;
    drawnow;
    
  end % if strcmp
  
end % while ~DrawFlag

set(Data.DynamicButton,'UserData',true);

%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalGetL %%%%%
%%%%%%%%%%%%%%%%%%%%%
function [L1,L2,L3]=LocalGetL(Quat)
CosBetaOver2=Quat(4);
SinBetaOver2=sqrt(1-CosBetaOver2^2);
if SinBetaOver2==0,SinBetaOver2=1;end
L1=Quat(1)/SinBetaOver2;
L2=Quat(2)/SinBetaOver2;
L3=Quat(3)/SinBetaOver2;

%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalGetQuat %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%
function Quat=LocalGetQuat(Data,Beta)

R2D=180/pi;

LTemp=[get(Data.PointerHandles,'XData')
       get(Data.PointerHandles,'YData')
       get(Data.PointerHandles,'ZData')];

if any(any(LTemp)),
  TransE2S=[0 1 0;1 0 0;0 0 -1];
  L=LTemp(:,2);L=TransE2S*L/norm(L);
  Quat=[L'*sin(Beta/R2D/2) cos(Beta/R2D/2)];
else
  Quat=[0 0 0 1];
end

%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalGetPTP %%%%%
%%%%%%%%%%%%%%%%%%%%%%%
function [Psi,Theta,Phi]=LocalGetPTP(TransMat)

R2D=180/pi;

Phi=atan2(TransMat(2,3),TransMat(3,3))*R2D;
Psi=atan2(TransMat(1,2),TransMat(1,1))*R2D;
Theta=atan2(-TransMat(1,3),norm([TransMat(1,1) TransMat(1,2)]))*R2D;


%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalHelp %%%%%
%%%%%%%%%%%%%%%%%%%%%
function LocalHelp(IsDynamic)
if IsDynamic,
  Page=2;
else
  Page=1;
end % if IsDynamic

HelpData={'Static Help for Quaternion Demonstration' , ...
    [' This demonstration shows how three degree of  '
     ' freedom Euler rotations are related to        '
     ' Quaternion rotations (Euler Parameters).      '
     ' Clicking on Yaw, Pitch or Roll rotates the    '
     ' aircraft in heading (Psi), pitch (Theta), and '
     ' roll (Phi), respectively.                     '
     '                                               '
     ' The blue line represents the axis of a single '
     ' simple rotation that brings the aircraft back '
     ' to wings level flying north. The quaternion   '
     ' representation of the aircraft is shown below '
     ' the Euler angles.  Changing Azimuth and       '
     ' Elevation changes the "blue line" axis of     '
     ' rotation and changing Beta changes the amount '
     ' the aircraft is rotated about this axis.      '
     ' Azimuth is defined as a rotation about the    '
     ' "down" axis and Elevation is defined as a     '
     ' rotation about the intermediate "east" axis.  '
     ' The "blue line" originates from the "down"    '
     ' axis. Clicking on reset rotates the aircraft  '
     ' through the angle Beta to wings level flying  '
     ' north. It is also possible to change the      '
     ' viewing angle by clicking and dragging the    '
     ' axes.                                         '
     '                                               '
     ' The Dynamic radio button changes the Euler    '
     ' angles to body rates of rotation.  Click on   '
     ' Info when the Dynamic button is selected for  '
     ' more detailed information.                    ']

  'Dynamic Help for Quaternion Demonstration', ...
    [' The dynamic rates of rotation (P,Q,R) are body'
     ' fixed rates that take place about the roll,   '
     ' pitch and yaw axes respectively.  The rates   '
     ' are given in Degrees/Frame and can            '
     ' automatically be set to zero using the Reset  '
     ' button.                                       '
     '                                               '
     ' The Static button allows you to return to the '
     ' Euler angle display.                          ']
  };

helpwin(HelpData,HelpData{Page,1});


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalQuat2TransMat %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function TransMat=LocalQuat2TransMat(Quat)
TransMat=[                                 ...
       1-2*Quat(2)^2-2*Quat(3)^2           ...
       2*(Quat(1)*Quat(2)+Quat(3)*Quat(4)) ...
       2*(Quat(3)*Quat(1)-Quat(2)*Quat(4));
                                           ...
       2*(Quat(1)*Quat(2)-Quat(3)*Quat(4)) ...
       1-2*Quat(3)^2-2*Quat(1)^2           ...
       2*(Quat(2)*Quat(3)+Quat(1)*Quat(4));
                                           ...
       2*(Quat(3)*Quat(1)+Quat(2)*Quat(4)) ...
       2*(Quat(2)*Quat(3)-Quat(1)*Quat(4)) ...
       1-2*Quat(1)^2-2*Quat(2)^2
      ];

%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalResetVal %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%
function [P,Q,R]=LocalResetVal(Data,P,Q,R)

if rem(P*10,2)==0,P=P-sign(P)*0.2;else P=P-rem(P*10,2)/10;end
if rem(Q*10,2)==0,Q=Q-sign(Q)*0.2;else Q=Q-rem(Q*10,2)/10;end
if rem(R*10,2)==0,R=R-sign(R)*0.2;else R=R-rem(R*10,2)/10;end
set(Data.P(1),'Value',P);set(Data.P(2),'String',num2str(P));
set(Data.Q(1),'Value',Q);set(Data.Q(2),'String',num2str(Q));
set(Data.R(1),'Value',R);set(Data.R(2),'String',num2str(R));

%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalSetBeta %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%
function [Azimuth,Elevation,Beta]=LocalSetBeta(Data,Beta,Quat)
R2D=180/pi;

Beta=2*acos(Quat(4))*R2D;

if Beta==360,
  set([Data.Psi(1),Data.Phi(1),Data.Beta(1)],'Value',0);
  set([Data.Psi(2),Data.Phi(2),Data.Theta(2)],'String',num2str(0));
  Beta=0;
elseif Beta<0,
  Beta=0;
end

if Beta==0,
  Azimuth=0;Elevation=0;
else
  [L1,L2,L3]=LocalGetL(Quat);
  NormL=norm([L1 L2 L3]);
  if NormL==0,
    Azimuth=0;
    Elevation=0;
  else
    Azimuth=atan2(L2,L1)*R2D;
    Elevation=acos(L3/norm([L1 L2 L3]))*R2D;
  end % if
end % if Beta

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalSetPsiThetaPhi %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalSetPsiThetaPhi(Data,Psi,Theta,Phi)

set(Data.Psi(1),'Value',Psi);
set(Data.Psi(2),'String',num2str(Psi));

set(Data.Phi(1),'Value',Phi);
set(Data.Phi(2),'String',num2str(Phi));

set(Data.Theta(1),'Value',Theta);
set(Data.Theta(2),'String',num2str(Theta));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalStaticDynamic %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalStaticDynamic(Data,StaticFlag)
if (strcmp(get(gcbo,'Tag'),get(Data.StaticButton,'Tag')))||nargin==2,
  IsDynamic=false;
  set(Data.DynamicButton,'UserData',true);
  set([Data.P(1),Data.Q(1),Data.R(1)],'Value',0);
  set([Data.P(2),Data.Q(2),Data.R(2)],'String',num2str(0));
  quatdemo('Nothing','Nothing');
  drawnow
  set(Data.EulText,'String','Euler Angles');
  set(Data.StatHandles,'Visible','on');
  set(Data.DynHandles,'Visible','off');
  Beta=get(Data.Beta(1),'Value');
  if Beta~=0,
    set([Data.Azimuth Data.Elevation Data.Beta Data.ResetHandle], ...
        'Enable','on');
  else
    set([Data.Azimuth Data.Elevation Data.Beta Data.ResetHandle], ...
        'Enable','off');
  end % if Beta
else
  IsDynamic=true;
  set(Data.EulText,'String','Body Rates');
  set(Data.StatHandles,'Visible','off');
  set(Data.DynHandles,'Visible','on');
  set([Data.Azimuth Data.Elevation Data.Beta],'Enable','off');
  set([Data.P(1),Data.Q(1),Data.R(1)],'Value',0);
  set([Data.P(2),Data.Q(2),Data.R(2)],'String',num2str(0));
  set(Data.ResetHandle,'Enable','off');
end
set(Data.StaticButton,'Value',1-IsDynamic);
set(Data.DynamicButton,'Value',IsDynamic);

%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalInitFig %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%
function Data=LocalInitFig(Caller)

% This is called if the subsystem block is double clicked on
QuatFig=findall(0,'Type','figure','Tag','QuatWorkingFig');
if ~isempty(QuatFig),
  if length(QuatFig)>1,
    delete(QuatFig(2:end));
  end

  QuatFig=QuatFig(1);

  if strcmp(Caller,'Simulink'),
    set_param('simquat/Rotation Demo/eulrotdisplay','UserData',QuatFig);
  end % if strcmp

  Data=get(QuatFig,'UserData');
  figure(QuatFig)
  return

end

%%% General Info.
Black      =[0       0        0      ]/255;
White      =[255     255      255    ]/255;
UIBackColor=get(0,'DefaultUIControlBackgroundColor');
FigColor=UIBackColor;
UIForeColor=Black;

Info.Units           = 'points'  ;
Info.Visible         = 'on'      ;
Info.Interruptible   = 'on'      ;
Info.BusyAction      = 'queue'   ;
Info.HandleVisibility= 'callback';

UIInfo=Info;
UIInfo.BackGroundColor    = UIBackColor;
UIInfo.ForeGroundColor    = UIForeColor;
UIInfo.HorizontalAlignment= 'center'   ;

ButtonStrings={'Reset';'Dynamic';'Static';'Help';'Close'};
ButtonCBs=strcat({'quatdemo '},ButtonStrings);
ButtonCBs{1}='quatdemo Reset Reset';
ButtonCBs(2:3)={'quatdemo StaticDynamic'};
ButtonTags=strcat(ButtonStrings,' Button');
ButtonStyle(1:5)={'pushbutton'};
ButtonStyle(2:3)={'radiobutton'};

RotCallback={'Psi'    ,'Theta'    ,'Phi' , ...
            'Azimuth','Elevation','Beta', ...
            'P'      ,'Q'        ,'R'     ...
            };

RotUnit={'Deg','Deg','Deg','Deg','Deg','Deg','Deg/Frm','Deg/Frm','Deg/Frm'};
RotMin=[-180 -90 -180 -360 -180   0   -10 -10 -10];
RotMax=[ 180  90  180  360  180   360  10  10  10];
RotVal=[   0    0    0  0    0     0     0   0   0];

RotLabel={'Yaw'     ,'Pitch'    ,'Roll'   , ...
          'Azimuth' ,'Elevation','Beta'   , ...
          'P (Roll)','Q (Pitch)','R (Yaw)'  ...
         }';
RotType(1:3,1)={'Euler'};RotType(4:5)={'Camera'};
RotType(6:9)={'Beta';'P';'Q';'R'};

NumInputs=size(RotLabel,1);

%%% Set Positions
ScreenUnits=get(0,'Units');
set(0,'Units','points');
ScreenSize=get(0,'ScreenSize');
set(0,'Units',ScreenUnits);

FigWidth=600;
FigHeight=440;
FigPos=[(ScreenSize(3:4)-[FigWidth FigHeight])/2 FigWidth FigHeight];

Offset     =5  ; SmallOffset=2;
SliderWidth=120; TextWidth  =30 ;  NameWidth=65   ;
UIHeight   =20 ;
CombHeight=2*UIHeight+Offset;

InputPos=zeros(NumInputs,4);
InputPos(NumInputs,1:2)=[0 ...
                       FigHeight-NumInputs*CombHeight-2*UIHeight-2*Offset ];
for lp=NumInputs-1:-1:1,
  InputPos(lp,:)=InputPos(lp+1,:)+[0 CombHeight 0 0];
end
InputPos(1:3,2)=InputPos(1:3,2)+2*Offset;
InputPos(4:6,2)=InputPos(4:6,2)-2*UIHeight-Offset;
InputPos(6  ,2)=InputPos(6,2)-Offset-UIHeight;
InputPos(7:9,:)=InputPos(1:3,:);

InPos=zeros(6,4);
InPos(1,:)=[TextWidth 0 SliderWidth UIHeight];
InPos(2,:)=[InPos(1,1)+2*Offset UIHeight SliderWidth-6*Offset UIHeight];
InPos(3,:)=[InPos(1,1)-NameWidth-SmallOffset UIHeight NameWidth UIHeight];
InPos(4,:)=[InPos(2,1)+InPos(2,3)+SmallOffset UIHeight NameWidth UIHeight];
InPos(5,:)=[InPos(1,1)-TextWidth-SmallOffset 0 TextWidth UIHeight]; %Low
InPos(6,:)=[InPos(1,1)+InPos(1,3)+SmallOffset 0 TextWidth UIHeight]; % High

CombWidth=sum(InPos([2 3 4],3));
InputPos(:,1)=ones(size(InputPos,1),1)*FigWidth-CombWidth-Offset;

QPos=zeros(2,4);
QPos(1,:)=[InputPos(1,1) InputPos(4,2)+2*InPos(4,4)+Offset ...
           InPos(6,1)+InPos(6,3)-Offset UIHeight];
QPos(2,:)=[QPos(1,1)-TextWidth QPos(1,2) TextWidth UIHeight];

FramePos=zeros(4,4);
FramePos(1,1)=InputPos(6,1)+InPos(3,1)-SmallOffset;
FramePos(1,2)=InputPos(6,2)-Offset;
FramePos(1,3)=CombWidth+2*SmallOffset+3*Offset;
FramePos(1,4)=CombHeight*3+2*UIHeight+3*Offset+QPos(1,4);
FramePos(2,1)=FramePos(1,1);
FramePos(2,2)=InputPos(3,2)-Offset;
FramePos(2,3)=FramePos(1,3);
FramePos(2,4)=3*CombHeight+2*Offset+UIHeight;

TextPos=zeros(2,4);
TextPos(1,:)=[FramePos(1,1)+Offset                          ...
              FramePos(1,2)+FramePos(1,4)-UIHeight-SmallOffset ...
              FramePos(1,3)-2*Offset                        ...
              UIHeight];
TextPos(2,:)=[FramePos(2,1)+Offset                          ...
              FramePos(2,2)+FramePos(2,4)-UIHeight-SmallOffset ...
              FramePos(2,3)-2*Offset                        ...
              UIHeight];

UIWidth=80;UIHeight=25;

FramePos(3,:)=[FramePos(1,1) Offset FramePos(1,3) UIHeight+2*Offset];
FramePos(4,:)=[2*Offset FramePos(3,2) ...
               FramePos(1,1)-4*Offset FramePos(3,4)];

ResetPos=[FramePos(4,1)+Offset FramePos(4,2)+Offset ...
          UIWidth UIHeight];
DynamicPos=[FramePos(4,1)+FramePos(4,3)-2*(UIWidth+Offset) ...
            FramePos(4,2)+Offset   UIWidth UIHeight];
StaticPos=DynamicPos+[DynamicPos(3)+Offset 0 0 0];

HelpPos=[FramePos(3,1)+(FramePos(3,3)-2*UIWidth-2*Offset)/2 ...
         FramePos(3,2)+Offset UIWidth UIHeight];
ClosePos=[HelpPos(1)+HelpPos(3)+2*Offset HelpPos(2) UIWidth UIHeight];

ButtonPos=[ResetPos;DynamicPos;StaticPos;HelpPos;ClosePos];

AxesPos(1:2)=[FramePos(4,1) sum(FramePos(4,[2 4]))+Offset];
AxesPos(3:4)=[FramePos(4,3) FigHeight-3*Offset-AxesPos(2)];

%%% Create InputFig
QuatFig=figure(Info            , ...
              'BackingStore'   ,'off'                     , ...
              'Color'          , FigColor                 , ...
              'MenuBar'        ,'none'                    , ...
              'Name'           ,'Quaternion Demonstration', ...
              'NumberTitle'    ,'off'                     , ...
              'Pointer'        ,'arrow'                   , ...
              'Position'       ,FigPos                    , ...
              'Renderer'       ,'zbuffer'                 , ...
              'Tag'            ,'QuatWorkingFig'          , ...
              'CloseRequestFcn','quatdemo Close'          , ...
              'IntegerHandle'  ,'off'                     , ...
              'Visible'        ,'off'                       ...
              );


%%% Create axes
Info.Parent=QuatFig;
UIInfo.Parent=QuatFig;

QuatAxes=axes(Info               , ...
             'Position'          ,AxesPos          , ...
             'Tag'               ,'Quaternion Axes', ...
             'DataAspectRatio'   ,[1 1 1]          , ...
             'PlotboxAspectRatio',[1 1 1]          , ...
             'View'              ,[10 10  ]        , ...
             'Box'               ,'on'             , ...
             'Color'             ,Black            , ...
             'XColor'            ,White            , ...
             'YColor'            ,White            , ...
             'ZColor'            ,White            , ...
             'DrawMode'          ,'fast'           , ...
             'Projection'        ,'perspective'    , ...
             'XLim'              ,[-100 100]       , ...
             'XTick'             ,[]               , ...
             'YLim'              ,[-100 100]       , ...
             'YTick'             ,[]               , ...
             'ZLim'              ,[-100 100]       , ...
             'ZTick'             ,[]                 ...
             );

set([QuatFig,QuatAxes],'HandleVisibility','on');
figure(QuatFig)
set([QuatFig,QuatAxes],'HandleVisibility','callback');


for lp=1:size(FramePos,1),
   Frames(lp)=uicontrol(UIInfo   , ...
                       'Position',FramePos(lp,:)        , ...
                       'Tag'     ,['Frame ' num2str(lp)], ...
                       'Style'   ,'frame'                 ...
                       );
end % for lp

for lp=1:size(ButtonPos,1),
  ButtonHandles(lp)=uicontrol(UIInfo   , ...
                             'Callback',ButtonCBs{lp}    , ...
                             'Position',ButtonPos(lp,:)  , ...
                             'Enable'  ,'on'             , ...
                             'Style'   ,ButtonStyle{lp}  , ...
                             'String'  ,ButtonStrings{lp}, ...
                             'Tag'     ,ButtonTags{lp}     ...
                             );
end % lp

set(ButtonHandles(2),'UserData',1,'Value',0);
set(ButtonHandles(3),'Value',1);

InHandle=zeros(1,NumInputs*2);
for lp=1:NumInputs,
  CBString=['quatdemo ' RotCallback{lp} ' ' RotType{lp}];
  Base=(lp-1)*6;
  IPos=InputPos(lp,:);
  InHandle(Base+1)=uicontrol(UIInfo   , ...
                            'Callback',CBString                 , ...
                            'Max'     ,RotMax(lp)               , ...
                            'Min'     ,RotMin(lp)               , ...
                            'Position',IPos+InPos(1,:)          , ...
                            'Enable'  ,'on'                     , ...
                            'Style'   ,'slider'                 , ...
                            'Value'   ,RotVal(lp)               , ...
                            'Tag'     ,[RotLabel{lp} ' Slider']   ...
                            );

  InHandle(Base+2)=uicontrol(UIInfo              , ...
                            'BackGroundColor'    ,White                 , ...
                            'Callback'           ,CBString              , ...
                            'HorizontalAlignment','left'                , ...
                            'Position'           ,IPos+InPos(2,:)       , ...
                            'Enable'             ,'on'                  , ...
                            'Style'              ,'edit'                , ...
                            'String'             ,num2str(RotVal(lp))   , ...
                            'Tag'                ,[RotLabel{lp} ' Edit']  ...
                            );

 InHandle(Base+3)=uicontrol(UIInfo              , ...
                           'HorizontalAlignment','right'               , ...
                           'Position'           ,IPos+InPos(3,:)       , ...
                           'Enable'             ,'on'                  , ...
                           'String'             ,RotLabel{lp}          , ...
                           'Style'              ,'text'                , ...
                           'Tag'                ,[RotLabel{lp} ' Text']  ...
                           );

 InHandle(Base+4)=uicontrol(UIInfo              , ...
                           'HorizontalAlignment','left'               , ...
                           'Position'           ,IPos+InPos(4,:)      , ...
                           'Enable'             ,'on'                 , ...
                           'String'             ,RotUnit{lp}          , ...
                           'Style'              ,'text'               , ...
                           'Tag'                ,[RotLabel{lp} 'Unit']  ...
                           );
 InHandle(Base+5)=uicontrol(UIInfo              , ...
                           'HorizontalAlignment','right'              , ...
                           'Position'           ,IPos+InPos(5,:)      , ...
                           'Enable'             ,'on'                 , ...
                           'String'             ,num2str(RotMin(lp))  , ...
                           'Style'              ,'text'               , ...
                           'Tag'                ,[RotLabel{lp} '-360']  ...
                           );
 InHandle(Base+6)=uicontrol(UIInfo              , ...
                           'HorizontalAlignment','left'               , ...
                           'Position'           ,IPos+InPos(6,:)      , ...
                           'Enable'             ,'on'                 , ...
                           'String'             ,num2str(RotMax(lp))  , ...
                           'Style'              ,'text'               , ...
                           'Tag'                ,[RotLabel{lp} ' 360']  ...
                           );

end % for lp

set(InHandle([19 20 25 26 31 32]),'Enable','off');
set(InHandle(37:54),'Visible','off');

QuatHandle=uicontrol(UIInfo              , ...
                    'HorizontalAlignment','left'              , ...
                    'Position'           ,QPos(1,:)           , ...
                    'Enable'             ,'on'                , ...
                    'String'             ,mat2str([0 0 0 1],2), ...
                    'Style'              ,'text'              , ...
                    'UserData'           ,[0 0 0 1]           , ...
                    'Tag'                ,'QuatVals'            ...
                    );
Junk=uicontrol(UIInfo              , ...
              'HorizontalAlignment','right'   , ...
              'Position'           ,QPos(2,:) , ...
              'Enable'             ,'on'      , ...
              'String'             ,'Q = '    , ...
              'Style'              ,'text'    , ...
              'Tag'                ,'QuatText'  ...
              );

Junk=uicontrol(UIInfo   , ...
              'Position',TextPos(1,:)               , ...
              'String'  ,'Quaternion Representation', ...
              'Style'   ,'text'                     , ...
              'Tag'     ,'Quaternion Text'            ...
              );
EulText=uicontrol(UIInfo   , ...
                 'Position',TextPos(2,:)  , ...
                 'String'  ,'Euler Angles', ...
                 'Style'   ,'text'        , ...
                 'Tag'     ,'Euler Text'    ...
                 );

set(allchild(QuatFig),'Units','normalized');

ArrowLineX=[ 0 90  80 90 80
            0  0   0  0  0
             0  0  -5  0  5
           ]';
ArrowLineY=[ 0  0  -5  0  5
             0 90  80 90 80
             0  0   0  0  0
           ]';
ArrowLineZ=[ 0   0   0   0   0
             0   0  -5   0   5
             0  90  80  90  80
           ]';

for lp=1:3,
  LineHandles(lp,1)=line('XData'    ,ArrowLineY(:,lp) , ...
                         'Ydata'    ,ArrowLineX(:,lp) , ...
                         'ZData'    ,-ArrowLineZ(:,lp), ...
                         'Color'    ,[1 1 1]          , ...
                         'Parent'   ,QuatAxes         , ...
                         'LineWidth',2                  ...
                         );
end % for lp
LineText(1)=text(0,100,0,'North','Color',[1 1 1],'Parent',QuatAxes);
LineText(2)=text(92,0,0,'East','Color',[1 1 1],'Parent',QuatAxes);
LineText(3)=text(0,0,-100,'Down','Color',[1 1 1],'Parent',QuatAxes);

PointerHandle=line('XData'    ,0       , ...
                   'YData'    ,0       , ...
                   'ZData'    ,0       , ...
                   'Color'    ,[0 0 1] , ...
                   'Parent'   ,QuatAxes, ...
                   'LineWidth',3       , ...
                   'UserData' , ...
                   [ArrowLineX(:,3)';ArrowLineY(:,3)';ArrowLineZ(:,3)']   ...
                   );

PlaneX=[75  40
         0   0
         0   0
       ];
PlaneY=[ 0   0
        30   0
       -30   0
       ];
PlaneZ=[ 0   0
         0   0
         0 -20
       ];

for lp=1:size(PlaneX,2),
  PlaneHandles(lp)=patch(PlaneY(:,lp),PlaneX(:,lp),-PlaneZ(:,lp),[1 0 0], ...
                         'LineWidth',1      , ...
                         'Parent'   ,QuatAxes, ...
                         'EdgeColor',[0 0 0]  ...
                         );
  set(PlaneHandles(lp), ...
     'UserData',[PlaneX(:,lp)';PlaneY(:,lp)';PlaneZ(:,lp)'] ...
     )
end % for lp

% Need to check to see if licensed for Simulink
ErrorFlag=0;
eval('new_system thisisatesttoseeifslislicensed','ErrorFlag=1;');
if ErrorFlag,
  Data.LicensedForSL=0;
else
  close_system thisisatesttoseeifslislicensed
  Data.LicensedForSL=1;
end

Data.DynamicButton=ButtonHandles(2);
Data.EulText=EulText;
Data.Frames=Frames;
Data.PlaneHandles=PlaneHandles;
Data.PointerHandles=PointerHandle;
Data.QuatAxes=QuatAxes;
Data.QuatAxesPos=get(Data.QuatAxes,'Position');
Data.QuatFig=QuatFig;
Data.QuatText=QuatHandle;
Data.ResetHandle=ButtonHandles(1);
Data.StaticButton=ButtonHandles(3);
Data.DynHandles=InHandle(37:54);
Data.StatHandles=InHandle(1:18);
Data.Psi=InHandle(1:6);
Data.Phi=InHandle(13:18);
Data.Theta=InHandle(7:12);
Data.Azimuth=InHandle(19:24);
Data.Elevation=InHandle(25:30);
Data.Beta=InHandle(31:36);
Data.P=InHandle(37:42);
Data.Q=InHandle(43:48);
Data.R=InHandle(49:54);

if strcmp(Caller,'Simulink'),
  set_param('simquat/Rotation Demo/eulrotdisplay','UserData',QuatFig);
end
rotate3d(QuatFig,'on');
set(QuatFig,'Visible','on','UserData',Data,'Pointer','watch');
