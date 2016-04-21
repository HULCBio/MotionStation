% Spline Toolbox
% Version 3.2.1 (R14) 05-May-2004 
%
% GUIs.
%   splinetool - Demonstrate some spline approximation methods.
%   bspligui   - Experiment with a B-spline as a function of its knots.
%
% Constructions of splines.
%
%   csape    - Cubic spline interpolation with various end-conditions.
%   csapi    - Cubic spline interpolant with not-a-knot end condition.
%   csaps    - Cubic smoothing spline.
%   cscvn    - `Natural' or periodic cubic spline curve.
%   getcurve - Interactive creation of a cubic spline curve.
%   ppmak    - Put together a spline in ppform.
%
%   spap2    - Least squares spline approximation.
%   spapi    - Spline interpolation.
%   spaps    - Smoothing spline.
%   spcrv    - Spline curve from control points by uniform subdivision.
%   spmak    - Put together a spline in B-form.
%
%   rpmak    - Put together a rational spline in rpform.
%   rsmak    - Put together a rational spline in rBform.
%
%   stmak    - Put together a function in stform.
%   tpaps    - Thin-plate smoothing spline.
%
% Operations on splines (in whatever form, B-form, ppform, rBform, stform, ...
%                          univariate or multivariate)
%   fnbrk    - Name and part(s) of a form.
%   fnchg    - Change part of a form.
%   fncmb    - Arithmetic with function(s).
%   fnder    - Differentiate a function.
%   fndir    - Directional derivative of a function.
%   fnint    - Integrate a function.
%   fnjmp    - Jumps, i.e., f(x+) - f(x-) .
%   fnmin    - Minimum of a function (in a given interval).
%   fnplt    - Plot a function.
%   fnrfn    - Refine the breaks or knots in a form.
%   fntlr    - Taylor coefficients or polynomial.
%   fnval    - Evaluate a function.
%   fnzeros  - Zeros of a function (in a given interval).
%   fn2fm    - Convert to specified form.
%
% Work on knots, breaks, and sites.
%   aptknt   - Acceptable knot sequence.
%   augknt   - Augment knot sequence.
%   aveknt   - Knot averages.
%   brk2knt  - Breaks with multiplicities into knots.
%   chbpnt   - Good data sites (the Chebyshev-Demko points).
%   knt2brk  - From knots to breaks and their multiplicities.
%   knt2mlt  - Knot multiplicities.
%   newknt   - New break distribution.
%   optknt   - Optimal knot distribution.
%   sorted   - Locate sites with respect to meshsites.
%
% Spline construction tools.
%   spcol    - B-spline collocation matrix.
%   stcol    - Scattered translates collocation matrix.
%   slvblk   - Solve almost block-diagonal linear system.
%   bkbrk    - Part(s) of an almost block-diagonal matrix.
%   chckxywp - Check and adjust input for *AP* commands.
%
% Spline conversion tools.
%   splpp    - Left Taylor coefficients from local B-coefficients.
%   sprpp    - Right Taylor coefficients from local B-coefficients.
%
% Demonstrations.
%   splexmpl - Some simple examples.
%   spalldem - Intro to B-form.
%   ppalldem - Intro to ppform.
%   bspline  - Plots a B-spline and its polynomial pieces.
%   pckkntdm - Knot choices.
%   csapidem - Cubic spline interpolation demo.
%   csapsdem - Cubic smoothing spline demo.
%   spapidem - Spline interpolation demo.
%   getcurv2 - Slideshow version of GETCURVE.
%   histodem - Smoothing a histogram demo.
%   chebdem  - Equioscillating spline demo.
%   difeqdem - ODE solved by collocation at Gauss points.
%   spcrvdem - Spline curve demo.
%   tspdem   - Demo of bivariate tensor product spline work.
%
% Functions and data.
%   franke   - Franke's bivariate test function.
%   subplus  - Positive part.
%   titanium - Test data.
%
% Information about splines and the toolbox.
%   spterms  - Explanation of spline toolbox terms.
%
% Obsolete functions.
%   pplst    - Summary of available operations on splines in ppform.
%   splst    - Summary of available operations on splines in B-form.
%   bsplidem - Some B-splines.

%   Copyright 1987-2004  C. de Boor and The MathWorks, Inc.
%   Generated from Contents.m_template revision 1.1  $Date: 2003/01/27 20:58:27 $
