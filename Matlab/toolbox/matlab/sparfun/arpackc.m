function arpackc(varargin)
%ARPACKC  C mex-interface to ARPACK library used by EIGS.
%   ARPACKC('dsaupd',IDO,BMAT,N,WHICH,NEV,TOL,RESID,NCV,V,LDV,...
%           IPARAM,IPNTR,WORKD,WORKL,LWORKL,INFO)
%   IDO: reverse communication parameter, initialized to 0. {int32}
%   BMAT: 'I' for standard problem, 'G' for generalized. {char}
%   N: size of problem. {int32}
%   WHICH: 'LM','SM','LA','SA','BE'. {length 2 char}
%   NEV: number of eigenvalues requested. {int32}
%   TOL: convergence tolerance. Default is eps/2. {double}
%   RESID: may be initialized to start vector. {length N double}
%   NCV: number of Lanczos vectors. {int32}
%   V: Lanczos basis vectors. {length N*NCV double}
%   LDV: leading dimension of V. {int32}
%   IPARAM: {length 11 int32}
%   IPNTR: {length 15 int32}
%   WORKD: {length 3*N double}
%   WORKL: {length LWORKL double}
%   LWORKL: length of WORKL >= NCV^2+8*NCV {int32}
%   INFO {int32}
%
%   ARPACKC('dseupd',RVEC,HOWMNY,SELECT,D,Z,LDZ,SIGMA,...
%           BMAT,N,WHICH,NEV,TOL,RESID,NCV,V,LDV,...
%           IPARAM,IPNTR,WORKD,WORKL,LWORKL,INFO)
%   RVEC: Compute eigenvectors or not. {int32}
%   HOWMNY: 'A' for all Ritz vectors, 'S' selects from SELECT. {char}
%   SELECT: which Ritz vectors are computed. {length NEV int32}
%   D: eigenvalues. {length NEV double}
%   Z: Ritz vectors. {length N*NEV double}
%   LDZ: leading dimension of Z. {int32}
%   SIGMA: Scalar eigenvalue shift. {double}
%   Remaining inputs must be unchanged from last 'dsaupd' call.
%
%   ARPACKC('dnaupd',IDO,BMAT,N,WHICH,NEV,TOL,RESID,NCV,V,LDV,...
%           IPARAM,IPNTR,WORKD,WORKL,LWORKL,INFO)
%   Same for 'dsaupd', except:
%   WHICH: 'LM','SM','LR','SR','LI','SI'. {length 2 char}
%   LWORKL: length of WORKL >= 3*NCV*(NCV+2) {int32}
%
%   ARPACKC('dneupd',RVEC,HOWMNY,SELECT,D,DI,Z,LDZ,SIGMAR,SIGMAI,WORKEV,...
%           BMAT,N,WHICH,NEV,TOL,RESID,NCV,V,LDV,...
%           IPARAM,IPNTR,WORKD,WORKL,LWORKL,INFO)
%   Same as 'dseupd' and 'dnaupd' except:
%   HOWMNY: 'A' for all Ritz vectors, 'P' for all Schur vectors,
%           'S' for select Ritz vectors from SELECT. {char}
%   D: real part Ritz values {length NEV+1 double}
%   DI: imaginary part Ritz values {length NEV+1 double}
%   Z: {length N*(NEV+1) double}
%   SIGMAR: real part of scalar eigenvalue shift {double}
%   SIGMAI: imaginary part of scalar eigenvalue shift {double}
%   WORKEV: {length 3*NCV double}
%
%   ARPACKC('znaupd',IDO,BMAT,N,WHICH,NEV,TOL,RESID,NCV,V,LDV,...
%           IPARAM,IPNTR,WORKD,WORKL,LWORKL,RWORK,INFO)
%   Same as 'dnaupd' except:
%   RESID: {length 2*N double}
%   V: {length 2*N*NCV double}
%   WORKD: {length 2*3*N double}
%   WORKL: {length 2*LWORKL double}
%   LWORKL: length of complex WORKL >= 3*NCV^2+5*NCV {int32}
%   RWORK: {2*NCV double}
%
%   ARPACKC('zneupd',RVEC,HOWMNY,SELECT,D,Z,LDZ,SIGMA,WORKEV,...
%           BMAT,N,WHICH,NEV,TOL,RESID,NCV,V,LDV,...
%           IPARAM,IPNTR,WORKD,WORKL,LWORKL,RWORK,INFO)
%   Same as 'dneupd' and 'znaupd' except:
%   D: {length 2*(NEV+1) double}
%   Z: {length 2*N*NEV double}
%   SIGMA: complex shift stored in real vector. {length 2 double}
%   WORKEV: {length 2*2*NCV double}
%
%   Note: for znaupd and zneupd all double variable are twice as long as
%   required by ARPACK since they store complex values.
%   MATLAB complex inputs RESID and WORKD need to be converted to interleaved
%   FORTRAN storage before being passed to znaupd.  D and V need to be
%   converted from FORTRAN storage after being returned from zneupd.  The
%   other "complex" vectors are neither input nor output so do not need to be
%   modified once they are allocated.
%
%   ARPACK is a collection of FORTRAN subroutines and is available from:
%      http://www.caam.rice.edu/software/ARPACK/
%
%   For more information, consult:
%
%   R.B. Lehoucq, D.C. Sorensen and C. Yang,
%   ARPACK Users' Guide: Solution of Large-Scale Eigenvalue Problems
%   with Implicitly Restarted Arnoldi Methods
%   SIAM Publications, Philadelphia, (1998).
%   ISBN 0-89871-407-9
%
%   D.C. Sorensen,
%   Implicit application of polynomial filters in a k-Step Arnoldi Method,
%   SIAM J. Matrix Analysis and Applications, 13, pp. 357-385, (1992).
%
%   R.B. Lehoucq  and D.C. Sorensen,
%   Deflation Techniques for an Implicitly Re-started Arnoldi Iteration,
%   SIAM J. Matrix Analysis and Applications, 17, pp. 789-821, (1996).
%
%   The MathWorks version of ARPACK includes the patch dated June 2, 2000.
%
%   The MathWorks modified ARPACK slightly by increasing the length of IPNTR to
%   15 so that the current iteration number could be returned in IPNTR(15) to
%   the calling program at each reverse communication call.
%   The MathWorks has compiled the top level FORTRAN subroutines:
%      dsaupd and dseupd (real symmetric)
%      dnaupd and dneupd (real nonsymmetric)
%      znaupd and zneupd (complex)
%   and all the supporting subroutines including the LAPACK 2.0 version of DLAHQR
%   into a shared library which links against LAPACK 3.0 and optimized BLAS.
%   The C mex-file ARPACKC processes the MATLAB inputs and calls the corresponding
%   ARPACK routine.  ARPACKC is used by EIGS, which performs the ARPACK reverse
%   communication and matrix application.
%
%   See also EIGS.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.5.4.2 $  $Date: 2004/04/16 22:08:17 $
%#mex

error('MATLAB:arpackc:InvalidMexFile', 'mex-file not found')


