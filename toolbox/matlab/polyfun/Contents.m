% Interpolation and polynomials.
%
% Data interpolation.
%   pchip       - Piecewise cubic Hermite interpolating polynomial.
%   interp1     - 1-D interpolation (table lookup).
%   interp1q    - Quick 1-D linear interpolation.
%   interpft    - 1-D interpolation using FFT method.
%   interp2     - 2-D interpolation (table lookup).
%   interp3     - 3-D interpolation (table lookup).
%   interpn     - N-D interpolation (table lookup).
%   griddata    - Data gridding and surface fitting.
%   griddata3   - Data gridding and hyper-surface fitting for 3-dimensional data.
%   griddatan   - Data gridding and hyper-surface fitting (dimension >= 2).
%
% Spline interpolation.
%   spline      - Cubic spline interpolation.
%   ppval       - Evaluate piecewise polynomial.
%
% Geometric analysis.
%   delaunay    - Delaunay triangulation.
%   delaunay3   - 3-D Delaunay tessellation.
%   delaunayn   - N-D Delaunay tessellation.
%   dsearch     - Search Delaunay triangulation for nearest point.
%   dsearchn    - Search N-D Delaunay tessellation for nearest point.
%   tsearch     - Closest triangle search.
%   tsearchn    - N-D closest triangle search.
%   convhull    - Convex hull.
%   convhulln   - N-D convex hull.
%   voronoi     - Voronoi diagram.
%   voronoin    - N-D Voronoi diagram.
%   inpolygon   - True for points inside polygonal region.
%   rectint     - Rectangle intersection area.
%   polyarea    - Area of polygon.
% 
% Polynomials.
%   roots       - Find polynomial roots.
%   poly        - Convert roots to polynomial.
%   polyval     - Evaluate polynomial.
%   polyvalm    - Evaluate polynomial with matrix argument.
%   residue     - Partial-fraction expansion (residues).
%   polyfit     - Fit polynomial to data.
%   polyder     - Differentiate polynomial.
%   polyint     - Integrate polynomial analytically.
%   conv        - Multiply polynomials.
%   deconv      - Divide polynomials.

% Utilities.
%   xychk       - Check arguents to 1-D and 2-D data routines.
%   xyzchk      - Check arguments to 3-D data routines.
%   xyzvchk     - Check arguments to 3-D volume data routines.
%   automesh    - True if inputs should be automatically meshgridded.
%   mkpp        - Make piecewise polynomial.
%   unmkpp      - Supply details about piecewise polynomial.
%   splncore    - N-D Spline interpolation.
%   resi2       - Residue of a repeated pole.
%   tzero       - Transmission zeros.
%   abcdchk     - Check consistency of A,B,C,D matrices.
%   ss2tf       - Convert state-space system to tranfer function.
%   ss2zp       - Convert state-space system to zero-pole.
%   tf2ss       - Convert transfer function to state-space.
%   tf2zp       - Convert transfer function to zero-pole.
%   tfchk       - Check for proper transfer function.
%   zp2ss       - Convert zero-pole system to state-space.
%   zp2tf       - Convert zero-pole system to transfer function.
%   mpoles      - Identify repeated poles and their multiplicities.
%   qhullmx     - Gateway function for Qhull.
%   qhull       - Copyright information for Qhull.
%   padecoef    - Pade approximation of time delays.
%   
% Obsolete functions.
%   icubic      - 1-D cubic interpolation.
%   interp4     - 2-D bilinear data interpolation.
%   interp5     - 2-D bicubic data interpolation.
%   interp6     - 2-D nearest neighbor interpolation.
%   table1      - 1-D table lookup.
%   table2      - 2-D table lookup.

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 5.27 $  $Date: 2002/06/17 13:35:49 $
