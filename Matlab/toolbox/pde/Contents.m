% Partial Differential Equation Toolbox
% Version 1.0.5 (R14) 05-May-2004
%
% PDE algorithms.
%   adaptmesh   - Adaptive mesh generation and PDE solution.
%   assema      - Assemble area integral contributions.
%   assemb      - Assemble boundary condition contributions.
%   assempde    - Assemble a PDE problem.
%   hyperbolic  - Solve hyperbolic problem.
%   parabolic   - Solve parabolic problem.
%   pdeeig      - Solve eigenvalue PDE problem.
%   pdenonlin   - Solve nonlinear PDE problem.
%   poisolv     - Fast solution of Poisson's equation on a rectangular grid.
%
% User interface algorithms and utilities.
%   pdecirc     - Draw circle.
%   pdeellip    - Draw ellipse.
%   pdemdlcv    - Convert MATLAB 4.2c Model M-files for use with MATLAB 5.
%   pdepoly     - Draw polygon.
%   pderect     - Draw rectangle.
%   pdetool     - PDE Toolbox graphical user interface (GUI).
%
% Geometry algorithms.
%   csgchk      - Check validity of Geometry Description matrix.
%   csgdel      - Delete borders between minimal regions.
%   decsg       - Decompose Constructive Solid Geometry into minimal regions.
%   initmesh    - Build an initial triangular mesh.
%   jigglemesh  - Jiggle internal points of a triangular mesh.
%   pdearcl     - Interpolation between parametric representation and arc length.
%   poimesh     - Make regular mesh on a rectangular geometry.
%   refinemesh  - Refines a triangular mesh.
%   wbound      - Write boundary condition specification data file.
%   wgeom       - Write geometry specification data file.
%
% Plot functions.
%   pdecont     - Shorthand command for contour plot.
%   pdegplot    - Plot a PDE geometry.
%   pdemesh     - Plot a PDE triangular mesh.
%   pdeplot     - Generic PDE Toolbox plot function.
%   pdesurf     - Shorthand command for surface plot.
%
% Utility algorithms.
%   dst         - Discrete sine transform.
%   idst        - Inverse discrete sine transform.
%   pdeadgsc    - Pick bad triangles using a relative tolerance criterion.
%   pdeadworst  - Pick bad triangles relative to the worst value.
%   pdecgrad    - Compute the flux of a PDE solution.
%   pdeent      - Indices of triangles neighboring a given set of triangles.
%   pdegrad     - Compute the gradient of the PDE solution.
%   pdeintrp    - Interpolate function values to triangle midpoints.
%   pdejmps     - Error estimates for adaption.
%   pdeprtni    - Interpolate function values to mesh nodes.
%   pdesde      - Indices of edges adjacent to a set of subdomains.
%   pdesdp      - Indices of points in a set of subdomains.
%   pdesdt      - Indices of triangles in a set of subdomains.
%   pdesmech    - Compute structural mechanics tensor functions.
%   pdetrg      - Triangle geometry data.
%   pdetriq     - Measure the quality of mesh triangles.
%   poiasma     - Boundary point matrix contributions for Poisson's equation.
%   poicalc     - Fast solution of Poisson's equation on a rectangular grid.
%   poiindex    - Indices of points in canonical ordering for rectangular grid.
%   sptarn      - Solve generalized sparse eigenvalue problem.
%   tri2grid    - Interpolate from PDE triangular mesh to rectangular mesh.
%
% User defined algorithms.
%   pdebound    - Boundary M-file.
%   pdegeom     - Geometry M-file.
%
% Demonstrations.
%   pdedemo1    - Exact solution of Poisson's equation on unit disk.
%   pdedemo2    - Solve Helmholtz's equation and study the reflected waves.
%   pdedemo3    - Solve a minimal surface problem.
%   pdedemo4    - Solve PDE problem using subdomain decomposition.
%   pdedemo5    - Solve a parabolic PDE (the heat equation).
%   pdedemo6    - Solve a hyperbolic PDE (the wave equation).
%   pdedemo7    - Adaptive solution with point source.
%   pdedemo8    - Solve Poisson's equation on rectangular grid.

%   Copyright 2004 The MathWorks, Inc. 
%   Generated from Contents.m_template revision 1.1.6.1  $Date: 2003/08/29 04:52:45 $
