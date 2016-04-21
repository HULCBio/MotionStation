function invsurf
%INVSURF plots four surfaces of (x, y) vs (theta1, theta2) which
%   specify the direct and inverse kinematics of a two-joint
%   planar robot arm.
%
%   See also INVKINE.

%       Roger Jang, 3-31-94, 12-23-94
%   Copyright 1994-2004 The MathWorks, Inc.
%   $Revision: 1.7.2.2 $  $Date: 2004/04/10 23:15:20 $

figTitle = 'Two-Joint Planar Robot Arm: Surface Plots';
[flag, figH] = figflag(figTitle);
if ~flag
    figure('Name', figTitle, 'NumberTitle', 'off', 'DockControls', 'off');
else
    set(gcf, 'color', get(gcf, 'color'));
end
%=======================================================
% The following is for direct kinematicS
l1 = 10;
l2 = 7;
point = 31;
bound = [-pi pi;0 pi];
theta1 = linspace(bound(1,1), bound(1,2), point);
theta2 = linspace(bound(2,1), bound(2,2), point);
x = zeros(length(theta1), length(theta2));
y = zeros(length(theta1), length(theta2));
for i = 1:length(theta1),
    fprintf('Iteration count = %d\n', i);
    for j = 1:length(theta2),
        x(i,j) = l1*cos(theta1(i)) + l2*cos(theta1(i)+theta2(j));
        y(i,j) = l1*sin(theta1(i)) + l2*sin(theta1(i)+theta2(j));
    end
end

% The following operations is necessary for correct plot. 
x = x';
y = y';

subplot(221);
mesh(theta1*180/pi, theta2*180/pi, x);
set(gca, 'box', 'on'); axis xy;
xlabel('q1', 'fontname', 'symbol');
ylabel('q2', 'fontname', 'symbol');
zlabel('x');
axis([bound(1,:)*180/pi bound(2,:)*180/pi min(min(x)) max(max(x))]);
view([-20 50])

subplot(222);
mesh(theta1*180/pi, theta2*180/pi, y);
set(gca, 'box', 'on'); axis xy;
xlabel('q1', 'fontname', 'symbol');
ylabel('q2', 'fontname', 'symbol');
zlabel('y');
axis([bound(1,:)*180/pi bound(2,:)*180/pi min(min(y)) max(max(y))]);
view([-20 50])
% End of direct kinematics
%=======================================================

%=======================================================
% The following is for inverse kinematics
l1 = 10;
l2 = 7;
point = 21;
bound = [-(l1+l2) (l1+l2); -(l1+l2) (l1+l2)];
x = linspace(bound(1,1), bound(1,2), point);
y = linspace(bound(2,1), bound(2,2), point);

r = linspace(l1-l2, l1+l2, point);
theta = linspace(0, 2*pi, 2*point);
[r1,theta1] = meshgrid(r, theta);
x = r1.*cos(theta1);
y = r1.*sin(theta1);

th1 = zeros(length(r), length(theta));
th2 = zeros(length(r), length(theta));

for i = 1:length(r),
    fprintf('Iteration count = %d\n', i);
    for j = 1:length(theta),
        xx = r(i)*cos(theta(j));
        yy = r(i)*sin(theta(j));
        c2 = (xx^2 + yy^2 - l1^2 - l2^2)/(2*l1*l2);
        c2 = min(max(c2, -1), 1);
        s2 = sqrt(1 - c2^2);
        th2(i, j) = atan2(s2, c2);

        k1 = l1 + l2*c2;
        k2 = l2*s2;
        th1(i, j) = atan2(yy, xx) - atan2(k2, k1);

%       tmp1 = l1*cos(th1(i,j));
%       tmp2 = l2*sin(th1(i,j));
%       th1(i, j) = tmp1;
%       th2(i, j) = tmp2;

        if abs(c2) > 1;
        th1(i, j) = nan;
            th2(i, j) = nan;
        end
    end
end

% The following operations is necessary for correct plot. 
th1 = th1';
th2 = th2';

subplot(223);
th1 = th1*180/pi;
mesh(x, y, th1);
set(gca, 'box', 'on'); axis xy;
xlabel('x'); ylabel('y');
zlabel('q1', 'fontname', 'symbol');
tmp = th1;
index = find(isnan(tmp));
tmp(index) = zeros(size(index));
axis([bound(1,:) bound(2,:) min(min(tmp)) max(max(tmp))]);
view([-20 50])

subplot(224);
th2 = th2*180/pi;
mesh(x, y, th2);
set(gca, 'box', 'on'); axis xy;
xlabel('x'); ylabel('y');
zlabel('q2', 'fontname', 'symbol');
tmp = th2;
index = find(isnan(tmp));
tmp(index) = zeros(size(index));
axis([bound(1,:) bound(2,:) min(min(tmp)) max(max(tmp))]);
view([-20 50])
% End of inverse kinematics
%=======================================================
