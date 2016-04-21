function vibes
%VIBES  Vibrating L-shaped membrane.
%
% This demonstration solves the wave equation for the vibrations
% of an L-shaped membrane.  The solution is expressed as a linear
% combination, with time-dependent coefficients, of two-dimensional
% spatial eigenfunctions.  The eigenfunctions are computed during
% initialization by the function MEMBRANE.  The first of these
% eigenfunctions, the fundamental mode, is the MathWorks logo.
%
% The L-shaped geometry is of particular interest mathematically because
% the stresses approach infinity near the reentrant corner.  Conventional
% finite difference and finite element methods require considerable
% time and storage to achieve reasonable accuracy.  The approach used
% here employs Bessel functions with fractional order to match the
% corner singularity.

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 5.14 $  $Date: 2002/04/15 03:34:45 $

% Eigenvalues.
lambda = [9.6397238445, 15.19725192, 2*pi^2, ...
    29.5214811, 31.9126360, 41.4745099, 44.948488, ...
    5*pi^2, 5*pi^2, 56.709610, 65.376535, 71.057755];

% Eigenfunctions
for k = 1:12
   L{k} = membrane(k);
end

% Get coefficients from eigenfunctions.
for k = 1:12
    c(k) = L{k}(25,23)/3;
end
 
% Set graphics parameters.
fig = figure;
set(fig,'color','k')
x = (-15:15)/15;
h = surf(x,x,L{1});
[a,e] = view; view(a+270,e);
axis([-1 1 -1 1 -1 1]);
caxis(26.9*[-1.5 1]);
colormap(hot);
axis off

% Buttons
uicontrol('pos',[20 20 60 20],'string','done','fontsize',12, ...
   'callback','close(gcbf)');
uicontrol('pos',[20 40 60 20],'string','slower','fontsize',12, ...
   'callback','set(gcbf,''userdata'',sqrt(0.5)*get(gcbf,''userdata''))');
uicontrol('pos',[20 60 60 20],'string','faster','fontsize',12, ...
   'callback','set(gcbf,''userdata'',sqrt(2.0)*get(gcbf,''userdata''))');

% Run
t = 0;
dt = 0.025;
set(fig,'userdata',dt)
while ishandle(fig)
    % Coefficients
    dt = get(fig,'userdata');
    t = t + dt;
    s = c.*sin(sqrt(lambda)*t);

    % Amplitude
    A = zeros(size(L{1}));
    for k = 1:12
      A = A + s(k)*L{k};
    end

    % Velocity
    s = lambda .*s;
    V = zeros(size(L{1}));
    for k = 1:12
      V = V + s(k)*L{k};
    end
    V(16:31,1:15) = NaN;

    % Surface plot of height, colored by velocity.
    set(h,'zdata',A,'cdata',V);
    drawnow
end;

