%% Finite Difference Laplacian
% This demo illustrates the computation and representation of the finite
% difference Laplacian on an L-shaped domain.
%
% Copyright 1984-2002 The MathWorks, Inc. 
% $Revision: 5.12 $5.11 $Date: 2002/04/15 03:36:34 $

%% The domain
% For this example, NUMGRID numbers points within an L-shaped domain.  The SPY
% function is a very useful tool for visualizing the pattern of non-zero
% elements in a given matrix.

R = 'L'; % Other possible shapes include S,N,C,D,A,H,B
% Generate and display the grid.
n = 32;
G = numgrid(R,n);
spy(G)
title('A finite difference grid')
% Show a smaller version as sample.
g = numgrid(R,12)

%% The discrete Laplacian
% Use DELSQ to generate the discrete Laplacian.  The SPY function gives a
% graphical feel of the population of the matrix.

D = delsq(G);
spy(D)
title('The 5-point Laplacian')
% Number of interior points
N = sum(G(:)>0)

%% The Dirichlet boudary value problem
% Finally, we solve the Dirichlet boundary value problem for the sparse linear
% system.  The problem is setup as follows:
%
%    delsq(u) = 1 in the interior,
%    u = 0 on the boundary.

rhs = ones(N,1);
if (R == 'N') % For nested dissection, turn off minimum degree ordering.
    spparms('autommd',0)
    u = D\rhs;
    spparms('autommd',1)
else
    u = D\rhs; % This is used for R=='L' as in this example
end

%% The solution
% Map the solution onto the grid and show it as a contour map.

U = G;
U(G>0) = full(u(G(G>0)));
clabel(contour(U));
prism
axis square ij

%% 
% Now show the solution as a mesh plot.

colormap((cool+1)/2);
mesh(U)
axis([0 n 0 n 0 max(max(U))])
axis square ij
