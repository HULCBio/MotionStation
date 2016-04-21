%% Example of a free rigid body (no torques)

%% Inital orientation
% The princicpal axis of the body in the [1 1 1] diagonal. We assume the body
% has the principal axis in the Y-direction
  ang = acos(1/sqrt(3))*[-1 1 0];
  [R M] = EAmatrix(0,[3 1 3],true);
  q0 = mat2quat(R(ang));

%% Inital angular velocities
% Body is rotating around its principal axis
  w0 = [0 4*2*pi 0];

  x0 = [w0 q0];

%% Set the system
% Circular cylinder with revolution axis in Y-direction
  opt.Mass = 1;
  r = 1;
  h = 2;
  opt.CoM = (3/4)*[0 h 0];
  opt.InertiaMoment = opt.Mass*[(3/5)*h^2 + (3/20)*r^2 (3/10)*r^2 (3/5)*h^2 + (3/20)*r^2];
  opt.Gravity = [0 0 -1];
  sys = @(t_,x_)RBequations_rot(t_,x_,opt);
 
%% Set integration
tspan = [0 6];
odeopt = odeset('RelTol',1e-3,'AbsTol',1e-3,...
             'InitialStep',1e-3,'MaxStep',1/10);

%% Euler equations + Quaternions
tic
[t y] = ode45 (sys, tspan, x0, odeopt);
nT = length(t);
toc

% Vector from vertex to end
r0 = [0 1 0];

%% quaternions
r = quatvrot (repmat(r0,nT,1), y(:,4:7) );

figure(1)
cla
drawAxis3D([0 0 0], eye(3), eye(3));
line([0 r(1,1)],[0 r(1,2)],[0 r(1,3)],'color','k','linewidth',2);
hold on
plot3(r(:,1),r(:,2),r(:,3),'.k');
hold off
axis tight;
axis equal;
axis square;
view(150,30)
