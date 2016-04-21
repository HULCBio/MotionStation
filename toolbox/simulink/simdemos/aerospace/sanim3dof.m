function [sys,x0,str,ts] = sanim3dof(t,x,u,flag,Config)
%SANIM3DOF S-Function for displaying 3DoF trajectories with Target motion
%
% See also: Simulink model 'aero_guidance'

%   Copyright 1990-2002 The MathWorks, Inc.
%   J.Hodgson
%   $Revision: 1.10 $  $Date: 2002/04/10 18:40:02 $

switch flag,

  %%%%%%%%%%%%%%%%%%
  % Initialization %
  %%%%%%%%%%%%%%%%%%
  case 0,
     [sys,x0,str,ts]=mdlInitializeSizes(Config);

  %%%%%%%%%%%%%%%
  % Derivatives %
  %%%%%%%%%%%%%%%
  case {1 , 3},
     sys=[];
     
  %%%%%%%%%%
  % Update %
  %%%%%%%%%%
  case 2,
     sys = [];
     if Config.Animenable
        mdlUpdate(t,x,u,Config);
     end

  %%%%%%%%%%%%%%%%%%%%%%%
  % GetTimeOfNextVarHit %
  %%%%%%%%%%%%%%%%%%%%%%%
  case 4,
    sys=mdlGetTimeOfNextVarHit(t,x,u,Config);

  %%%%%%%%%%%%%
  % Terminate %
  %%%%%%%%%%%%%
  case 9,
     sys=[];
     if Config.Animenable
       h_f= get(findobj('type','figure','Tag','3DOF anim'),'children');
       h=findobj(h_f,'type','uimenu','label','&Camera');
       if (isempty(h) & ~isempty(h_f))  
         cameramenu('noreset')
       end
     end  
otherwise
  %%%%%%%%%%%%%%%%%%%%
  % Unexpected flags %
  %%%%%%%%%%%%%%%%%%%%

   error(['Unhandled flag = ',num2str(flag)]);

end

% end sanim3dof
%
%=============================================================================
% mdlInitializeSizes
% Return the sizes, initial conditions, and sample times for the S-function.
%=============================================================================
%
function [sys,x0,str,ts]=mdlInitializeSizes(Config)

%
% Set Sizes Matrix
%
sizes = simsizes;

sizes.NumContStates  = 0;
sizes.NumDiscStates  = 0;
sizes.NumOutputs     = 0;
sizes.NumInputs      = 5;
sizes.DirFeedthrough = 0;
sizes.NumSampleTimes = 1;   % at least one sample time is needed

sys = simsizes(sizes);

%
% initialise the initial conditions
%
x0  = [];

%
% str is always an empty matrix
%
str = [];

%
% initialise the array of sample times
%
ts  = [-2 0]; % variable sample time

if ~Config.Animenable
   return
end

%
% Initialize Figure Window
%

   h_f=findobj('type','figure','Tag','3DOF anim');
   
   if isempty(h_f)
     h_anim=figure;
   else
     h_anim=h_f;
   end

   set(h_anim,'name','Animation Figure', ...
           'renderer','zbuffer','resize','off', ...
           'position',[500, 200, 525, 450], ...
           'Tag','3DOF anim');
   
   if ~isempty(h_anim)
     h_del = findobj(h_anim,'type','axes');
     delete(h_del);
     figure(h_anim);
   end

%
% Initialize Axes
%
   handle.axes(1)=axes;
   axis(Config.axes);
   set(handle.axes(1),'visible','on','xtick',[],'ytick',[],'ztick',[],'box','on', ...
           'dataaspectratio',[1 1 1], ...
           'projection','pers', ...
           'units','normal', ...
           'position',[0.1 0.1 0.75 0.75], ...
           'Color',[.8 .8 .8], ...
           'drawmode','fast'); ...

%
% Initialize Trajectory 
%
 
   handle.line(1) = line(0,0,0);
   set(handle.line(1),'linestyle','-','color',[0 0 1],'erasemode','nor','userdata',0,'clipping','off');
   handle.line(2) = line(0,0,0);
   set(handle.line(2),'linestyle','-','color',[1 0 0],'erasemode','nor','clipping','off');
      
%
% Draw in Target Position
%   
   theta = [0:45:360]*pi/180;
   handle.target = patch(0*theta,5*Config.craft*cos(theta),5*Config.craft*sin(theta),[0 0 1]);
   set(handle.target,'userdata',get(handle.target,'vertices'));

%
% Draw in Missile and Store Craft shape in Axes Userdata
%      

   [xcraft,ycraft,zcraft]=miss_shape;
   handle.craft = patch(xcraft,ycraft,zcraft,[1 0 0]);
   set(handle.axes(1),'userdata',50*Config.craft*get(handle.craft,'vertices'))
   set(handle.craft,'facecolor',[1 0 0], ...
                    'edgecolor',[0 0 0], ...
                    'erasemode','nor','clipping','off');
%
% Set Handles of graphics in Figure UserData
%   
   set(h_anim,'userdata',handle);

%
%=============================================================================
% mdlUpdate
% Handle discrete state updates, sample time hits, and major time step
% requirements.
%=============================================================================
%
function mdlUpdate(t,x,u,Config)

%
% Obtain Handles of Figure Objects
%
    handle = get(findobj('type','figure','Tag','3DOF anim'),'userdata');

    if isempty(findobj('type','figure','Tag','3DOF anim'))
     %figure has been manually closed
     return
    end

%
% Form Transformation Matrix
%
    cth = cos(u(3));            % Pitch
    sth = sin(u(3));
    attitude = [cth 0 sth; ...  % xxx ??
                0   1   0; ...
               -sth 0  cth];
             
%
% Update Craft Object 
%
   vert  = get(handle.axes(1),'userdata');
   [a,b] = size(vert);
   dum   = (attitude*vert'+[u(1) 0 u(2)]'*ones(1,a))';
   set(handle.craft,'vertices',dum);

%
% Update Line Objects
%
    x1 = get(handle.line(1),'Xdata');  
    x2 = get(handle.line(1),'Ydata');
    x3 = get(handle.line(1),'Zdata');
    init = get(handle.line(1),'userdata');
    if init
       x1 = [x1 u(1)];
       x2 = [x2 0];
       x3 = [x3 u(2)];
    else
       x1 = u(1);
       x2 = 0;
       x3 = u(2);
       set(handle.line(1),'userdata',1);
    end

    set(handle.line(1),'Xdata',x1, ...
                       'Ydata',x2, ...
                       'Zdata',x3);     
                    
    x1 = get(handle.line(2),'Xdata');  
    x2 = get(handle.line(2),'Ydata');
    x3 = get(handle.line(2),'Zdata');
    if init
       x1 = [x1 u(4)];
       x2 = [x2 0];
       x3 = [x3 u(5)];
    else
       x1 = [u(4)];
       x2 = [0];
       x3 = [u(5)];
    end
    set(handle.line(2),'Xdata',x1, ...
                      'Ydata',x2, ...
                      'Zdata',x3);      
    
%
% Update Target Position
%
        x=get(handle.target,'userdata');
        set(handle.target,'vertices',x+ones(length(x),1)*[u(4) 0 u(5)]);

%
% Set position and orientation of camera
%
        switch Config.camera_view 
   
        case 1,                 % Fixed Observer Position
        set(handle.axes(1),        'cameraupvector',               [0 0 -1], ...
                              'cameraposition',    Config.camera_pos, ...
                        'cameratarget',      [u(1) 0 u(2)], ...
                                        'cameraviewangle',   Config.view);
         
        case 2,                 % Cockpit View
        Target= [u(4) 0 u(5)]';
           ax = Config.axes;
           seeker_dir = sqrt(sum((ax(2)-ax(1))^2 + ...
				 (ax(4)-ax(3))^2 + ...
				 (ax(6)-ax(5))^2)) ...
	                *attitude*[1;0;0];
           seeker_pos = attitude*[Config.craft 0 0]';
           set(handle.axes(1),'cameraupvector',attitude*[0 0 -1]', ...
                   'cameraposition',[u(1) 0 u(2)]'+seeker_pos, ...
                   'cameratarget',  [u(1) 0 u(2)]'+seeker_dir, ...
                   'cameraviewangle',Config.view);
        
        case 3,                 % Relative Position View
           set(handle.axes(1),'cameraupvector',[0 0 -1], ...
                   'cameraposition',[u(1) 0 u(2)]'+Config.camera_pos', ...
                   'cameratarget',  [u(1) 0 u(2)]', ...
                   'cameraviewangle',Config.view);
        end

%
% Force MATLAB to Update Drawing
%
        drawnow

% end mdlUpdate

%
%=============================================================================
% mdlGetTimeOfNextVarHit
% Return the time of the next hit for this block.  
%=============================================================================
%
function sys=mdlGetTimeOfNextVarHit(t,x,u,Config)
    
   sys = ceil(t/Config.update)*Config.update+Config.update;

% end mdlGetTimeOfNextVarHit

%
%=============================================================================
% miss_shape
% Function to draw shape of missile object
%=============================================================================
%
function [x,y,z]=miss_shape

   num=9;                          % Number of z-y segments to make the circle
   count=1;                        % Counter for number of individual patches
   theta=[360/2/num:360/num:(360+360/2/num)]*pi/180;

   len       = 25.7;               % Total Length (no units)
   radius    = 1.5/2;              % Radius of body
   s_fore    = 5;                  % Start of main body (w.r.t. nose)
   thr_len   = 1.4;                % Length of Motor exit
   rad_throt = 1.3/2;              % radius of motor exit
   l_fore    = len-s_fore-thr_len; % Length of main body
   c_g       = 14;                 % Position of c.g. w.r.t nose
   
%
% Fore Body Shape
%
   yc_range =  radius*sin(theta);
   zc_range = -radius*cos(theta);
   for i = 1:num
     xcraft{i}=[s_fore s_fore s_fore+l_fore s_fore+l_fore ]-c_g;
     ycraft{i}=[yc_range(i) yc_range(i+1) yc_range(i+1) yc_range(i)];
     zcraft{i}=[zc_range(i) zc_range(i+1) zc_range(i+1) zc_range(i)];
   end
   count=num+1;   
%
% Throttle Shape
%
   yc_range2 =  rad_throt*sin(theta);
   zc_range2 = -rad_throt*cos(theta);
   for i = 1:num
     xcraft{count}=[len-thr_len len-thr_len len len]-c_g;
     ycraft{count}=[yc_range(i) yc_range(i+1) yc_range2(i+1) yc_range2(i)];
     zcraft{count}=[zc_range(i) zc_range(i+1) zc_range2(i+1) zc_range2(i)];
     count=count+1;
   end

%
% Nose Shape
%
   for i = 1:num
     xcraft{count}=[s_fore s_fore 0 s_fore]-c_g;
     ycraft{count}=[yc_range(i) yc_range(i+1) 0 yc_range(i)];
     zcraft{count}=[zc_range(i) zc_range(i+1) 0 zc_range(i)];
     count=count+1;
   end
%
% Wing shapes 
%
   xcraft{count}=[10.2 13.6 14.6 15]-c_g;
   ycraft{count}=[-zc_range(1) -zc_range(1)+1.5 -zc_range(1)+1.5 -zc_range(1)];
   zcraft{count}=[0 0 0 0 ];
   xcraft{count+1}=xcraft{count};
   ycraft{count+1}=-ycraft{count};
   zcraft{count+1}=zcraft{count};
   xcraft{count+2}=xcraft{count};
   ycraft{count+2}=zcraft{count};
   zcraft{count+2}=ycraft{count};
   xcraft{count+3}=xcraft{count};
   ycraft{count+3}=zcraft{count};
   zcraft{count+3}=-ycraft{count};
%
% Tail shapes 
%
   count=count+4;
   xcraft{count}=[22.1 22.9 23.3 23.3]-c_g;
   ycraft{count}=[-zc_range(1) -zc_range(1)+1.1 -zc_range(1)+1.1 -zc_range(1)];
   zcraft{count}=[0 0 0 0];
   xcraft{count+1}=xcraft{count};
   ycraft{count+1}=-ycraft{count};
   zcraft{count+1}=zcraft{count};
   xcraft{count+2}=xcraft{count};
   ycraft{count+2}=zcraft{count};
   zcraft{count+2}=ycraft{count};
   xcraft{count+3}=xcraft{count};
   ycraft{count+3}=zcraft{count};
   zcraft{count+3}=-ycraft{count};
   count=count+3;
   
%
% Combine individual objects into a single set of co-ordinates and roll through 45 degrees
%
   x=[];y=[];z=[];
   roll = [1 0 0;0 cos(45/180*pi) sin(45/180*pi);0 -sin(45/180*pi) cos(45/180*pi)];
   for i = 1:count
     x = [x xcraft{i}'];
     y = [y ycraft{i}'];
     z = [z zcraft{i}'];
   end
   
   for i =1:4
      dum = [x(i,:);y(i,:);z(i,:)];
      dum = roll*dum;
      x(i,:)=dum(1,:);
      y(i,:)=dum(2,:);
      z(i,:)=dum(3,:);
   end
%
% Rescale vertices
%
   x = -x/len;
   y = y/len;
   z = z/len;
   
% End miss_shape
