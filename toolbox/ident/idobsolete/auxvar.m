function auxvar
%AUXVAR  Auxiliary variables for the parameter estimation schemes.
%   MAXITER: The maximum number of iterations to be performed when search-
%   ing for the minimum. Default is MAXITER=10. With MAXITER=0 only a non-
%   iterative initial value estimation procedure is carried out.
%
%   TOL: The iterations are continued until the candidate update vector
%   has a norm less than TOL. Default is TOL=0.01. This norm is measured
%   as the expected improvement of fit, expressed in percent.
%   The iterations are also terminated when MAXITER is reached, or when
%   the search procedure fails to find a lower value of the criterion
%   along the candidate direction (first Gauss-Newton, then gradient).
%
%   LIM: The criterion is robustified, so that a residual that is larger
%   than LIM*(estimated standard deviation) carries a linear, rather than
%   quadratic weight. Default is LIM=1.6. LIM=0 means that a non-
%   robustified (truly quadratic) criterion is used.
%
%   MAXSIZE: No matrix with more than MAXSIZE elements is formed by the
%   algorithms. The default value is set by the .m-file idmsize. (On a
%   PC the default value is MAXSIZE = 4096). If you run into
%   memory problems try lower values of MAXSIZE. See also MEMORY.
%
%   T: The sampling interval. Default is T=1. T is essential to obtain
%   physical frequency scales, and when transforming to continuous time.
%
%   Omitting trailing arguments or entering them as [] gives default.
%   The output argument IT_INF contains information about the iterations
%   when stopped:
%   IT_INF=[last iter #,last fit improvement,norm of search vector]
%   The norm is measured as explained under TOL above.

%   L. Ljung
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2001/04/06 14:21:37 $
