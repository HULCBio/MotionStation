% Numerical Integration Toolbox 
%
% MATLAB Toolbox for 1-D, 2-D, and n-D Numerical Integration
%
% Edited Version for OCTAVE
% 
% The original 1-D routines were obtained from NETLIB and were 
% written by
%          Howard Wilson
%          Department of Engineering Mechanics
%          University of Alabama
%          Box 870278
%          Tuscaloosa, Alabama 35487-0278
%          Phone 205 348-1617
%          Email address: HWILSON @ UA1VM.UA.EDU
% 
% The rest of the routines were written by
%          Bryce Gardner
%          Ray W. Herrick Laboratories
%          Purdue University
%          West Lafayette, IN 47906
%          Phone: 317-494-0231
%          Fax:  317-494-0787
%          Email:  gardner@ecn.purdue.edu
%
% Easy to use routines:  (these routines iteratively integrate with 
%			  higher order quadratures until the integral has
%			  converged--use these routine unless you want to
%			  specify the order of integration quadrature that
%			  is to be used)
%	   quadg.m	-- High accuracy replacement for QUAD and QUAD8 (1-D)
%	   quad2dg.m	-- 2-D integration over a rectangular region
%	   quad2dggen.m	-- 2-D integration over a general region
%	   quadndg.m	-- n-D integration over a n-D hyper-rectangular region
%          README.nit	-- introductory readme file
%
% The 1-D routines:
%          README	-- The original readme file by Howard Wilson
%          gquad.m	-- Integrates a 1-D function with input Gauss 
%			   points and weights (modified by Bryce Gardner to
%			   handle an optional parameter in the function to be
%			   integrated and also to calculate the Gauss points
%			   and weights on the fly)
%          gquad6.m	-- Integrates a 1-D function with a 6-point quadrature
%          grule.m	-- Calculates the Gauss points and weights
%          run.log	-- File with examples
%
%    New 1-D routines:
%	   quadg.m	-- High accuracy replacement for QUAD and QUAD8
%	   quadc.m	-- 1-D Gauss-Chebyshev integration routine
%          crule.m	-- Calculates the Gauss-Chebyshev points and weights
%          ncrule.m	-- Calculates the Newton-Coates points and weights
%
% The 2-D routines:
%	   quad2dg.m	-- 2-D integration over a rectangular region
%	   quad2dc.m	-- 2-D integration over a rectangular region with
%			   a 1/sqrt(1-x.^2)/sqrt(1-y.^2) sinqularity
%          gquad2d.m	-- Integrates a 2-D function over a square region
%          gquad2d6.m	-- Integrates a 2-D function over a square region with
%			   a 6-point quadrature
%	   quad2dggen.m	-- 2-D integration over a general region
%	   quad2dcgen.m	-- 2-D integration over a general region with
%			   a 1/sqrt(1-x.^2)/sqrt(1-y.^2) sinqularity
%          gquad2dgen.m -- Integrates a 2-D function over a variable region
%			   (That is the limits on the inner integration are
%			   defined by a function of the variable of integration
%			   of the outer integral.)
%          grule2d.m	-- Calculates the Gauss points and weights for gquad2d.m
%          grule2dgen.m -- Calculates the Gauss points and weights for 
%			   gquad2dgen.m
%          crule2d.m	-- Calculates the Gauss-Chebyshev points and weights 
%			   for gquad2d.m
%          crule2dgen.m -- Calculates the Gauss-Chebyshev points and weights 
%			   for gquad2dgen.m
%
% The n-D routines:
%          quadndg.m	-- n-D integration over an n-D hyper-rectangular region
%          gquadnd.m    -- Integrates a n-D function over 
%                          an n-D hyper-rectangular 
%			   region using a Gauss quadrature
%          cquadnd.m    -- Integrates a n-D function over 
%                          an n-D hyper-rectangular 
%			   region using a Gauss-Chebyshev quadrature
%          innerfun.m   -- used internally to gquadnd.m and cquadnd.m
%
% Utility routines:
%	   count.m	-- routine to count the number of function calls
%	   zero_count.m	-- routine to report the number of function calls and
%			   then to reset the counter
%
% Test scripts:
%          run2dtests.m	-- 2-D examples and 1-D Gauss-Chebyshev examples
%	   tests2d.log  -- output of run2dtests.m -- Matlab 4.1 on a Sparc 10
%	   test_ncrule.m-- m-file to check the Newton-Coates quadrature
%	   testsnc.log  -- output of test_ncrule.m -- Matlab 4.1 on a Sparc 10
%	   test_quadg.m -- m-file to check the quadg routine
%	   testsqg.log  -- output of test_quadg.m -- Matlab 4.1 on a Sparc 10
%
% Test functions:
%          xsquar.m	-- xsquar(x)=x.^2
%          xcubed.m	-- xcubed(x)=x.^3
%          x25.m	-- x25(x)=x.^25
%	   fxpow.m	-- fxpow(x,y)=x.^y
%          hx.m         -- hx(x)=sum(x.^2)
%          gxy.m	-- gxy(x,y)=x.^2+y.^2
%          gxy1.m	-- gxy1(x,y)=ones(size(x))
%          gxy2.m	-- gxy2(x,y)=sqrt(x.^2+y.^2)
%          glimh.m	-- glimh(y)=3
%          glimh2.m	-- glimh(y)=y
%          gliml.m	-- gliml(y)=0
%          lcrcl.m	-- lcrcl(y)=-sqrt(4-y.^2)
%          lcrcu.m	-- lcrcu(y)=sqrt(4-y.^2)
%
