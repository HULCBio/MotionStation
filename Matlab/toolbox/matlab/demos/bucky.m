function [B,V] = bucky
%BUCKY  Connectivity graph of the Buckminster Fuller geodesic dome.
%   B = BUCKY is the 60-by-60 sparse adjacency matrix of the
%       connectivity graph of the geodesic dome, the soccer ball,
%       and the carbon-60 molecule.
%   [B,V] = BUCKY also returns xyz coordinates of the vertices.

%   C. B. Moler, 2-14-91, 10-8-91, 8-11-92, 9-7-93.
%   Thanks to Bih-Yaw Jin, Carnegie Mellon University.
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.7 $  $Date: 2002/04/15 03:34:01 $

% Golden ratio
phi = (1+sqrt(5))/2;

% Vertex of a regular icosahedron.
v = [1, 0, phi];

% Vertices of a truncated icosahedron.
T = [2/3,  1/3*phi , 2/3*phi+1/3
     1/3,  2/3*phi , 2/3+1/3*phi
    -1/3,  2/3*phi , 2/3+1/3*phi
    -1/3*phi,  2/3*phi+1/3, 2/3];

% Projections.
P = T - (T*v'/norm(v)^2) * v;
P = P*P';

% Polar angles.
alfa = asin(T*v'./sqrt(diag(T*T'))/norm(v));
beta = acos(P(3:4,1)./sqrt(diag(P(3:4,3:4)))/sqrt(P(1,1)));

% Northern hemisphere
B = sparse(30,30);
phi = zeros(30,1);
theta = zeros(30,1);
k = 5;
for j = 1:5
   t = 2*(j-1)*pi/5;
   phi(j) = alfa(1);
   theta(j) = t;
   B(j,k+1) = 1;
   B(j,rem(j,5)+1) = 1;

   k = k+1;
   phi(k) = alfa(2);
   theta(k) = t;
   B(k,k+1) = 1;
   B(k,k+4) = 1;

   k = k+1;
   phi(k) = alfa(3);
   theta(k) = t-beta(1);
   B(k,k+1) = 1;

   k = k+1;
   phi(k) = alfa(4);
   theta(k) = t-beta(2);
   B(k,k+1) = 1;

   k = k+1;
   phi(k) = alfa(4);
   theta(k) = t+beta(2);
   B(k,k+1) = 1;

   k = k+1;
   phi(k) = alfa(3);
   theta(k) = t+beta(1);
   if k+2 < 30, B(k,k+2) = 1;
   else B(k,7) = 1; end
end
B = B + B';

% Reflect into southern hemisphere
k = 60:-1:31;
phi(k) = -phi;
theta(k) = pi+theta;
B(k,k) = B;

% Connect the two hemispheres
k = find(sum(B)==2);
j = k(1:10);
k = k([15:-1:11 20:-1:16]);
c = sparse(j,k,ones(size(j)),60,60);
B = B + c + c';

% Generate the 3-D coordinates
if nargout > 1
   V = [cos(phi).*cos(theta) cos(phi).*sin(theta) sin(phi)];
end
