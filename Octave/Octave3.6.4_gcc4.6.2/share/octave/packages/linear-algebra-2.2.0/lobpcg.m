## Copyright (C) 2000-2011 A.V. Knyazev <Andrew.Knyazev@ucdenver.edu>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU Lesser General Public License as published by the Free
## Software Foundation; either version 3 of the License, or (at your option) any
## later version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License
## for more details.
##
## You should have received a copy of the GNU Lesser General Public License
## along with this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {[@var{blockVectorX}, @var{lambda}] =} lobpcg (@var{blockVectorX}, @var{operatorA})
## @deftypefnx {Function File} {[@var{blockVectorX}, @var{lambda}, @var{failureFlag}] =} lobpcg (@var{blockVectorX}, @var{operatorA})
## @deftypefnx {Function File} {[@var{blockVectorX}, @var{lambda}, @var{failureFlag}, @var{lambdaHistory}, @var{residualNormsHistory}] =} lobpcg (@var{blockVectorX}, @var{operatorA}, @var{operatorB}, @var{operatorT}, @var{blockVectorY}, @var{residualTolerance}, @var{maxIterations}, @var{verbosityLevel})
## Solves Hermitian partial eigenproblems using preconditioning.
##
## The first form outputs the array of algebraic smallest eigenvalues @var{lambda} and
## corresponding matrix of orthonormalized eigenvectors @var{blockVectorX} of the
## Hermitian (full or sparse) operator @var{operatorA} using input matrix
## @var{blockVectorX} as an initial guess, without preconditioning, somewhat
## similar to:
##
## @example
## # for real symmetric operator operatorA
## opts.issym  = 1; opts.isreal = 1; K = size (blockVectorX, 2);
## [blockVectorX, lambda] = eigs (operatorA, K, 'SR', opts);
##
## # for Hermitian operator operatorA
## K = size (blockVectorX, 2);
## [blockVectorX, lambda] = eigs (operatorA, K, 'SR');
## @end example
##
## The second form returns a convergence flag. If @var{failureFlag} is 0 then
## all the eigenvalues converged; otherwise not all converged.
##
## The third form computes smallest eigenvalues @var{lambda} and corresponding eigenvectors
## @var{blockVectorX} of the generalized eigenproblem Ax=lambda Bx, where 
## Hermitian operators @var{operatorA} and @var{operatorB} are given as functions, as
## well as a preconditioner, @var{operatorT}. The operators @var{operatorB} and
## @var{operatorT} must be in addition @emph{positive definite}. To compute the largest
## eigenpairs of @var{operatorA}, simply apply the code to @var{operatorA} multiplied by
## -1. The code does not involve @emph{any} matrix factorizations of @var{operatorA} and
## @var{operatorB}, thus, e.g., it preserves the sparsity and the structure of
## @var{operatorA} and @var{operatorB}.
##
## @var{residualTolerance} and @var{maxIterations} control tolerance and max number of
## steps, and @var{verbosityLevel} = 0, 1, or 2 controls the amount of printed
## info. @var{lambdaHistory} is a matrix with all iterative lambdas, and
## @var{residualNormsHistory} are matrices of the history of 2-norms of residuals
##
## Required input:
## @itemize @bullet
## @item
## @var{blockVectorX} (class numeric) - initial approximation to eigenvectors,
## full or sparse matrix n-by-blockSize. @var{blockVectorX} must be full rank.
## @item
## @var{operatorA} (class numeric, char, or function_handle) - the main operator
## of the eigenproblem, can be a matrix, a function name, or handle
## @end itemize
##
## Optional function input:
## @itemize @bullet
## @item
## @var{operatorB} (class numeric, char, or function_handle) - the second operator,
## if solving a generalized eigenproblem, can be a matrix, a function name, or
## handle; by default if empty, @code{operatorB = I}.
## @item
## @var{operatorT} (class char or function_handle) - the preconditioner, by
## default @code{operatorT(blockVectorX) = blockVectorX}.
## @end itemize
##
## Optional constraints input:
## @itemize @bullet
## @item
## @var{blockVectorY} (class numeric) - a full or sparse n-by-sizeY matrix of
## constraints, where sizeY < n. @var{blockVectorY} must be full rank. The
## iterations will be performed in the (operatorB-) orthogonal complement of the
## column-space of @var{blockVectorY}.
## @end itemize
##
## Optional scalar input parameters:
## @itemize @bullet
## @item
## @var{residualTolerance} (class numeric) - tolerance, by default, @code{residualTolerance = n * sqrt (eps)}
## @item
## @var{maxIterations} - max number of iterations, by default, @code{maxIterations = min (n, 20)}
## @item
## @var{verbosityLevel} - either 0 (no info), 1, or 2 (with pictures); by
## default, @code{verbosityLevel = 0}.
## @end itemize
##
## Required output:
## @itemize @bullet
## @item
## @var{blockVectorX} and @var{lambda} (class numeric) both are computed
## blockSize eigenpairs, where @code{blockSize = size (blockVectorX, 2)}
## for the initial guess @var{blockVectorX} if it is full rank.
## @end itemize
##
## Optional output:
## @itemize @bullet
## @item
## @var{failureFlag} (class integer) as described above.
## @item
## @var{lambdaHistory} (class numeric) as described above.
## @item
## @var{residualNormsHistory} (class numeric) as described above.
## @end itemize
##
## Functions @code{operatorA(blockVectorX)}, @code{operatorB(blockVectorX)} and
## @code{operatorT(blockVectorX)} must support @var{blockVectorX} being a matrix, not
## just a column vector.
##
## Every iteration involves one application of @var{operatorA} and @var{operatorB}, and
## one of @var{operatorT}.
##
## Main memory requirements: 6 (9 if @code{isempty(operatorB)=0}) matrices of the
## same size as @var{blockVectorX}, 2 matrices of the same size as @var{blockVectorY}
## (if present), and two square matrices of the size 3*blockSize.
##
## In all examples below, we use the Laplacian operator in a 20x20 square
## with the mesh size 1 which can be generated in MATLAB by running:
## @example
## A = delsq (numgrid ('S', 21));
## n = size (A, 1);
## @end example
##
## or in MATLAB and Octave by:
## @example
## [~,~,A] = laplacian ([19, 19]);
## n = size (A, 1);
## @end example
##
## Note that @code{laplacian} is a function of the specfun octave-forge package.
##
## The following Example:
## @example
## [blockVectorX, lambda, failureFlag] = lobpcg (randn (n, 8), A, 1e-5, 50, 2);
## @end example
##
## attempts to compute 8 first eigenpairs without preconditioning, but not all
## eigenpairs converge after 50 steps, so failureFlag=1.
##
## The next Example:
## @example
## blockVectorY = [];
## lambda_all = [];
## for j = 1:4
##   [blockVectorX, lambda] = lobpcg (randn (n, 2), A, blockVectorY, 1e-5, 200, 2);
##   blockVectorY           = [blockVectorY, blockVectorX];
##   lambda_all             = [lambda_all' lambda']';
##   pause;
## end
## @end example
##
## attemps to compute the same 8 eigenpairs by calling the code 4 times with
## blockSize=2 using orthogonalization to the previously founded eigenvectors.
##
## The following Example:
## @example
## R       = ichol (A, struct('michol', 'on'));
## precfun = @@(x)R\(R'\x);
## [blockVectorX, lambda, failureFlag] = lobpcg (randn (n, 8), A, [], @@(x)precfun(x), 1e-5, 60, 2);
## @end example
##
## computes the same eigenpairs in less then 25 steps, so that failureFlag=0
## using the preconditioner function @code{precfun}, defined inline. If @code{precfun}
## is defined as an octave function in a file, the function handle
## @code{@@(x)precfun(x)} can be equivalently replaced by the function name @code{precfun}. Running:
##
## @example
## [blockVectorX, lambda, failureFlag] = lobpcg (randn (n, 8), A, speye (n), @@(x)precfun(x), 1e-5, 50, 2);
## @end example
##
## produces similar answers, but is somewhat slower and needs more memory as
## technically a generalized eigenproblem with B=I is solved here.
##
## The following example for a mostly diagonally dominant sparse matrix A
## demonstrates different types of preconditioning, compared to the standard
## use of the main diagonal of A:
##
## @example
## clear all; close all;
## n       = 1000;
## M       = spdiags ([1:n]', 0, n, n);
## precfun = @@(x)M\x;
## A       = M + sprandsym (n, .1);
## Xini    = randn (n, 5);
## maxiter = 15;
## tol     = 1e-5;
## [~,~,~,~,rnp] = lobpcg (Xini, A, tol, maxiter, 1);
## [~,~,~,~,r]   = lobpcg (Xini, A, [], @@(x)precfun(x), tol, maxiter, 1);
## subplot (2,2,1), semilogy (r'); hold on;
## semilogy (rnp', ':>');
## title ('No preconditioning (top)'); axis tight;
## M(1,2)  = 2;
## precfun = @@(x)M\x; % M is no longer symmetric
## [~,~,~,~,rns] = lobpcg (Xini, A, [], @@(x)precfun(x), tol, maxiter, 1);
## subplot (2,2,2), semilogy (r'); hold on;
## semilogy (rns', '--s');
## title ('Nonsymmetric preconditioning (square)'); axis tight;
## M(1,2)  = 0;
## precfun = @@(x)M\(x+10*sin(x)); % nonlinear preconditioning
## [~,~,~,~,rnl] = lobpcg (Xini, A, [], @@(x)precfun(x), tol, maxiter, 1);
## subplot (2,2,3),  semilogy (r'); hold on;
## semilogy (rnl', '-.*');
## title ('Nonlinear preconditioning (star)'); axis tight;
## M       = abs (M - 3.5 * speye (n, n));
## precfun = @@(x)M\x;
## [~,~,~,~,rs] = lobpcg (Xini, A, [], @@(x)precfun(x), tol, maxiter, 1);
## subplot (2,2,4),  semilogy (r'); hold on;
## semilogy (rs', '-d');
## title ('Selective preconditioning (diamond)'); axis tight;
## @end example
##
## @heading References
## This main function @code{lobpcg} is a version of the preconditioned conjugate
## gradient method (Algorithm 5.1) described in A. V. Knyazev, Toward the Optimal
## Preconditioned Eigensolver:
## Locally Optimal Block Preconditioned Conjugate Gradient Method,
## SIAM Journal on Scientific Computing 23 (2001), no. 2, pp. 517-541. 
## @uref{http://dx.doi.org/10.1137/S1064827500366124}
##
## @heading Known bugs/features
## @itemize @bullet
## @item
## an excessively small requested tolerance may result in often restarts and
## instability. The code is not written to produce an eps-level accuracy! Use
## common sense.
## @item
## the code may be very sensitive to the number of eigenpairs computed,
## if there is a cluster of eigenvalues not completely included, cf.
## @example
## operatorA = diag ([1 1.99 2:99]);
## [blockVectorX, lambda] = lobpcg (randn (100, 1),operatorA, 1e-10, 80, 2);
## [blockVectorX, lambda] = lobpcg (randn (100, 2),operatorA, 1e-10, 80, 2);
## [blockVectorX, lambda] = lobpcg (randn (100, 3),operatorA, 1e-10, 80, 2);
## @end example
## @end itemize
##
## @heading Distribution
## The main distribution site: @uref{http://math.ucdenver.edu/~aknyazev/}
##
## A C-version of this code is a part of the @uref{http://code.google.com/p/blopex/}
## package and is directly available, e.g., in PETSc and HYPRE.  
## @end deftypefn

function [blockVectorX,lambda,varargout] = lobpcg(blockVectorX,operatorA,varargin)
  %Begin

  % constants

  CONVENTIONAL_CONSTRAINTS = 1;
  SYMMETRIC_CONSTRAINTS = 2;

  %Initial settings

  failureFlag = 1;
  if nargin < 2
      error('BLOPEX:lobpcg:NotEnoughInputs',...
      strcat('There must be at least 2 input agruments: ',...
          'blockVectorX and operatorA'));
  end
  if nargin > 8
      warning('BLOPEX:lobpcg:TooManyInputs',...
          strcat('There must be at most 8 input agruments ',...
          'unless arguments are passed to a function'));
  end

  if ~isnumeric(blockVectorX)
      error('BLOPEX:lobpcg:FirstInputNotNumeric',...
          'The first input argument blockVectorX must be numeric');
  end
  [n,blockSize]=size(blockVectorX);
  if blockSize > n
      error('BLOPEX:lobpcg:FirstInputFat',...
      'The first input argument blockVectorX must be tall, not fat');
  end
  if n < 6
      error('BLOPEX:lobpcg:MatrixTooSmall',...
          'The code does not work for matrices of small sizes');
  end

  if isa(operatorA,'numeric')
      nA = size(operatorA,1);
      if any(size(operatorA) ~= nA)
          error('BLOPEX:lobpcg:MatrixNotSquare',...
              'operatorA must be a square matrix or a string');
      end
      if size(operatorA) ~= n
          error('BLOPEX:lobpcg:MatrixWrongSize',...
          ['The size ' int2str(size(operatorA))...
              ' of operatorA is not the same as ' int2str(n)...
              ' - the number of rows of blockVectorX']);
      end
  end

  count_string = 0;

  operatorT = [];
  operatorB = [];
  residualTolerance = [];
  maxIterations = [];
  verbosityLevel = [];
  blockVectorY = []; sizeY = 0;
  for j = 1:nargin-2
      if isequal(size(varargin{j}),[n,n])
          if isempty(operatorB)
              operatorB = varargin{j};
          else
              error('BLOPEX:lobpcg:TooManyMatrixInputs',...
          strcat('Too many matrix input arguments. ',...
          'Preconditioner operatorT must be an M-function'));
          end
      elseif isequal(size(varargin{j},1),n) && size(varargin{j},2) < n
          if isempty(blockVectorY)
              blockVectorY = varargin{j};
              sizeY=size(blockVectorY,2);
          else
              error('BLOPEX:lobpcg:WrongConstraintsFormat',...
              'Something wrong with blockVectorY input argument');
          end
      elseif ischar(varargin{j}) || isa(varargin{j},'function_handle')
          if count_string == 0
              if isempty(operatorB)
                  operatorB = varargin{j};
                  count_string = count_string + 1;
              else
                  operatorT = varargin{j};
              end
          elseif count_string == 1
              operatorT = varargin{j};
          else
              warning('BLOPEX:lobpcg:TooManyStringFunctionHandleInputs',...
                  'Too many string or FunctionHandle input arguments');
          end
      elseif isequal(size(varargin{j}),[n,n])
          error('BLOPEX:lobpcg:WrongPreconditionerFormat',...
          'Preconditioner operatorT must be an M-function');
      elseif max(size(varargin{j})) == 1
          if isempty(residualTolerance)
              residualTolerance = varargin{j};
          elseif isempty(maxIterations)
              maxIterations = varargin{j};
          elseif isempty(verbosityLevel)
              verbosityLevel = varargin{j};
          else
              warning('BLOPEX:lobpcg:TooManyScalarInputs',...
                  'Too many scalar parameters, need only three');
          end
      elseif isempty(varargin{j})
          if isempty(operatorB)
              count_string = count_string + 1;
          elseif ~isempty(operatorT)
              count_string = count_string + 1;
          elseif ~isempty(blockVectorY)
              error('BLOPEX:lobpcg:UnrecognizedEmptyInput',...
                 ['Unrecognized empty input argument number ' int2str(j+2)]);
          end
      else
          error('BLOPEX:lobpcg:UnrecognizedInput',...
              ['Input argument number ' int2str(j+2) ' not recognized.']);
      end
  end

  if verbosityLevel
      if issparse(blockVectorX)
          fprintf(['The sparse initial guess with %i colunms '...
          'and %i raws is detected  \n'],n,blockSize);
      else
          fprintf(['The full initial guess with %i colunms '...
              'and %i raws is detected  \n'],n,blockSize);
      end
      if ischar(operatorA) 
          fprintf('The main operator is detected as an M-function %s \n',...
              operatorA);
      elseif isa(operatorA,'function_handle')
          fprintf('The main operator is detected as an M-function %s \n',...
              func2str(operatorA));
      elseif issparse(operatorA)
          fprintf('The main operator is detected as a sparse matrix \n');
      else
          fprintf('The main operator is detected as a full matrix \n');
      end
      if isempty(operatorB)
          fprintf('Solving standard eigenvalue problem, not generalized \n');
      elseif ischar(operatorB) 
          fprintf(['The second operator of the generalized eigenproblem \n'...
          'is detected as an M-function %s \n'],operatorB);
      elseif isa(operatorB,'function_handle')
          fprintf(['The second operator of the generalized eigenproblem \n'...
          'is detected as an M-function %s \n'],func2str(operatorB));
      elseif issparse(operatorB)
          fprintf(strcat('The second operator of the generalized',... 
              'eigenproblem \n is detected as a sparse matrix \n'));
      else
          fprintf(strcat('The second operator of the generalized',... 
              'eigenproblem \n is detected as a full matrix \n'));        
      end
      if isempty(operatorT)
          fprintf('No preconditioner is detected \n');
      elseif ischar(operatorT) 
          fprintf('The preconditioner is detected as an M-function %s \n',...
              operatorT);
      elseif isa(operatorT,'function_handle')
          fprintf('The preconditioner is detected as an M-function %s \n',...
              func2str(operatorT));
      end
      if isempty(blockVectorY)
          fprintf('No matrix of constraints is detected \n')
      elseif issparse(blockVectorY)
          fprintf('The sparse matrix of %i constraints is detected \n',sizeY);
      else
          fprintf('The full matrix of %i constraints is detected \n',sizeY);
      end
      if issparse(blockVectorY) ~= issparse(blockVectorX)
          warning('BLOPEX:lobpcg:SparsityInconsistent',...
              strcat('The sparsity formats of the initial guess and ',...
              'the constraints are inconsistent'));
      end
  end

  % Set defaults

  if isempty(residualTolerance)
      residualTolerance = sqrt(eps)*n;
  end
  if isempty(maxIterations)
      maxIterations = min(n,20);
  end
  if isempty(verbosityLevel)
      verbosityLevel = 0;
  end

  if verbosityLevel
      fprintf('Tolerance %e and maximum number of iterations %i \n',...
          residualTolerance,maxIterations)
  end

  %constraints preprocessing
  if isempty(blockVectorY)
      constraintStyle = 0;
  else
      %    constraintStyle = SYMMETRIC_CONSTRAINTS; % more accurate?
      constraintStyle = CONVENTIONAL_CONSTRAINTS;
  end

  if constraintStyle == CONVENTIONAL_CONSTRAINTS
      
      if isempty(operatorB)
          gramY = blockVectorY'*blockVectorY;
      else
          if isnumeric(operatorB)
              blockVectorBY = operatorB*blockVectorY;
          else
              blockVectorBY = feval(operatorB,blockVectorY);
          end
          gramY=blockVectorY'*blockVectorBY;
      end
      gramY=(gramY'+gramY)*0.5;
      if isempty(operatorB)
          blockVectorX = blockVectorX - ...
              blockVectorY*(gramY\(blockVectorY'*blockVectorX));
      else
          blockVectorX =blockVectorX - ...
              blockVectorY*(gramY\(blockVectorBY'*blockVectorX));
      end
      
  elseif constraintStyle == SYMMETRIC_CONSTRAINTS
      
      if ~isempty(operatorB)
          if isnumeric(operatorB)
              blockVectorY = operatorB*blockVectorY;
          else
              blockVectorY = feval(operatorB,blockVectorY);
          end
      end
      if isempty(operatorT)
          gramY = blockVectorY'*blockVectorY;
      else
          blockVectorTY = feval(operatorT,blockVectorY);
          gramY = blockVectorY'*blockVectorTY;
      end
      gramY=(gramY'+gramY)*0.5;
      if isempty(operatorT)
          blockVectorX = blockVectorX - ...
              blockVectorY*(gramY\(blockVectorY'*blockVectorX));
      else
          blockVectorX = blockVectorX - ...
              blockVectorTY*(gramY\(blockVectorY'*blockVectorX));
      end
      
  end

  %Making the initial vectors (operatorB-) orthonormal
  if isempty(operatorB)
      %[blockVectorX,gramXBX] = qr(blockVectorX,0);
      gramXBX=blockVectorX'*blockVectorX;
      if ~isreal(gramXBX)
          gramXBX=(gramXBX+gramXBX')*0.5;
      end
      [gramXBX,cholFlag]=chol(gramXBX);
      if  cholFlag ~= 0
          error('BLOPEX:lobpcg:ConstraintsTooTight',...
             'The initial approximation after constraints is not full rank');
      end
      blockVectorX = blockVectorX/gramXBX;
  else
      %[blockVectorX,blockVectorBX] = orth(operatorB,blockVectorX);
      if isnumeric(operatorB)
          blockVectorBX = operatorB*blockVectorX;
      else
          blockVectorBX = feval(operatorB,blockVectorX);
      end
      gramXBX=blockVectorX'*blockVectorBX;
      if ~isreal(gramXBX)
          gramXBX=(gramXBX+gramXBX')*0.5;
      end
      [gramXBX,cholFlag]=chol(gramXBX);
      if  cholFlag ~= 0
          error('BLOPEX:lobpcg:InitialNotFullRank',...
              sprintf('%s\n%s', ...
              'The initial approximation after constraints is not full rank',...
              'or/and operatorB is not positive definite'));
      end
      blockVectorX = blockVectorX/gramXBX;
      blockVectorBX = blockVectorBX/gramXBX;
  end

  % Checking if the problem is big enough for the algorithm, 
  % i.e. n-sizeY > 5*blockSize
  % Theoretically, the algorithm should be able to run if 
  % n-sizeY > 3*blockSize,
  % but the extreme cases might be unstable, so we use 5 instead of 3 here.
  if n-sizeY < 5*blockSize
      error('BLOPEX:lobpcg:MatrixTooSmall','%s\n%s', ...
      'The problem size is too small, relative to the block size.',... 
      'Try using eig() or eigs() instead.');
  end

  % Preallocation
  residualNormsHistory=zeros(blockSize,maxIterations);
  lambdaHistory=zeros(blockSize,maxIterations+1);
  condestGhistory=zeros(1,maxIterations+1);

  blockVectorBR=zeros(n,blockSize);
  blockVectorAR=zeros(n,blockSize);
  blockVectorP=zeros(n,blockSize);
  blockVectorAP=zeros(n,blockSize);
  blockVectorBP=zeros(n,blockSize);

  %Initial settings for the loop
  if isnumeric(operatorA)
      blockVectorAX = operatorA*blockVectorX;
  else
      blockVectorAX = feval(operatorA,blockVectorX);
  end

  gramXAX = full(blockVectorX'*blockVectorAX);
  gramXAX = (gramXAX + gramXAX')*0.5;
  % eig(...,'chol') uses only the diagonal and upper triangle - 
  % not true in MATLAB
  % Octave v3.2.3-4, eig() does not support inputting 'chol'
  [coordX,gramXAX]=eig(gramXAX,eye(blockSize));

  lambda=diag(gramXAX); %eig returns non-ordered eigenvalues on the diagonal

  if issparse(blockVectorX)
      coordX=sparse(coordX);
  end

  blockVectorX  =  blockVectorX*coordX;
  blockVectorAX = blockVectorAX*coordX;
  if ~isempty(operatorB)
      blockVectorBX = blockVectorBX*coordX;
  end
  clear coordX

  condestGhistory(1)=-log10(eps)/2;  %if too small cause unnecessary restarts

  lambdaHistory(1:blockSize,1)=lambda;

  activeMask = true(blockSize,1);
  % currentBlockSize = blockSize; %iterate all
  %
  % restart=1;%steepest descent

  %The main part of the method is the loop of the CG method: begin
  for iterationNumber=1:maxIterations
      
      %     %Computing the active residuals
      %     if isempty(operatorB)
      %         if currentBlockSize > 1
      %             blockVectorR(:,activeMask)=blockVectorAX(:,activeMask) - ...
      %                 blockVectorX(:,activeMask)*spdiags(lambda(activeMask),0,currentBlockSize,currentBlockSize);
      %         else
      %             blockVectorR(:,activeMask)=blockVectorAX(:,activeMask) - ...
      %                 blockVectorX(:,activeMask)*lambda(activeMask);
      %                   %to make blockVectorR full when lambda is just a scalar
      %         end
      %     else
      %         if currentBlockSize > 1
      %             blockVectorR(:,activeMask)=blockVectorAX(:,activeMask) - ...
      %                 blockVectorBX(:,activeMask)*spdiags(lambda(activeMask),0,currentBlockSize,currentBlockSize);
      %         else
      %             blockVectorR(:,activeMask)=blockVectorAX(:,activeMask) - ...
      %                 blockVectorBX(:,activeMask)*lambda(activeMask);
      %                       %to make blockVectorR full when lambda is just a scalar
      %         end
      %     end
      
      %Computing all residuals
      if isempty(operatorB)
          if blockSize > 1
              blockVectorR = blockVectorAX - ...
                  blockVectorX*spdiags(lambda,0,blockSize,blockSize);
          else
              blockVectorR = blockVectorAX - blockVectorX*lambda;
              %to make blockVectorR full when lambda is just a scalar
          end
      else
          if blockSize > 1
              blockVectorR=blockVectorAX - ...
                  blockVectorBX*spdiags(lambda,0,blockSize,blockSize);
          else
              blockVectorR = blockVectorAX - blockVectorBX*lambda;
              %to make blockVectorR full when lambda is just a scalar
          end
      end
      
      %Satisfying the constraints for the active residulas
      if constraintStyle == SYMMETRIC_CONSTRAINTS
          if isempty(operatorT)
              blockVectorR(:,activeMask) = blockVectorR(:,activeMask) - ...
                  blockVectorY*(gramY\(blockVectorY'*...
                  blockVectorR(:,activeMask)));
          else
              blockVectorR(:,activeMask) = blockVectorR(:,activeMask) - ...
                  blockVectorY*(gramY\(blockVectorTY'*...
                  blockVectorR(:,activeMask)));
          end
      end
      
      residualNorms=full(sqrt(sum(conj(blockVectorR).*blockVectorR)'));
      residualNormsHistory(1:blockSize,iterationNumber)=residualNorms;
      
      %index antifreeze
      activeMask = full(residualNorms > residualTolerance) & activeMask;
      %activeMask = full(residualNorms > residualTolerance);
      %above allows vectors back into active, which causes problems with frosen Ps
      %activeMask = full(residualNorms > 0);      %iterate all, ignore freeze
      
      currentBlockSize = sum(activeMask);
      if  currentBlockSize == 0
          failureFlag=0; %all eigenpairs converged
          break
      end
      
      %Applying the preconditioner operatorT to the active residulas
      if ~isempty(operatorT)
          blockVectorR(:,activeMask) = ...
              feval(operatorT,blockVectorR(:,activeMask));
      end
      
      if constraintStyle == CONVENTIONAL_CONSTRAINTS
          if isempty(operatorB)
              blockVectorR(:,activeMask) = blockVectorR(:,activeMask) - ...
                  blockVectorY*(gramY\(blockVectorY'*...
                  blockVectorR(:,activeMask)));
          else
              blockVectorR(:,activeMask) = blockVectorR(:,activeMask) - ...
                  blockVectorY*(gramY\(blockVectorBY'*...
                  blockVectorR(:,activeMask)));
          end
      end
      
      %Making active (preconditioned) residuals orthogonal to blockVectorX
      if isempty(operatorB)
          blockVectorR(:,activeMask) = blockVectorR(:,activeMask) - ...
              blockVectorX*(blockVectorX'*blockVectorR(:,activeMask));
      else
          blockVectorR(:,activeMask) = blockVectorR(:,activeMask) - ...
              blockVectorX*(blockVectorBX'*blockVectorR(:,activeMask));
      end
      
      %Making active residuals orthonormal
      if isempty(operatorB)
          %[blockVectorR(:,activeMask),gramRBR]=...
          %qr(blockVectorR(:,activeMask),0); %to increase stability
          gramRBR=blockVectorR(:,activeMask)'*blockVectorR(:,activeMask);
          if ~isreal(gramRBR)
              gramRBR=(gramRBR+gramRBR')*0.5; 
          end
          [gramRBR,cholFlag]=chol(gramRBR);
          if  cholFlag == 0
              blockVectorR(:,activeMask) = blockVectorR(:,activeMask)/gramRBR;
          else
              warning('BLOPEX:lobpcg:ResidualNotFullRank',...
                  'The residual is not full rank.');
              break
          end
      else
          if isnumeric(operatorB)
              blockVectorBR(:,activeMask) = ...
                  operatorB*blockVectorR(:,activeMask);
          else
              blockVectorBR(:,activeMask) = ...
                  feval(operatorB,blockVectorR(:,activeMask));
          end
          gramRBR=blockVectorR(:,activeMask)'*blockVectorBR(:,activeMask);
          if ~isreal(gramRBR)
              gramRBR=(gramRBR+gramRBR')*0.5; 
          end
          [gramRBR,cholFlag]=chol(gramRBR);
          if  cholFlag == 0
              blockVectorR(:,activeMask) = ...
                  blockVectorR(:,activeMask)/gramRBR;
              blockVectorBR(:,activeMask) = ...
                  blockVectorBR(:,activeMask)/gramRBR;
          else
              warning('BLOPEX:lobpcg:ResidualNotFullRankOrElse',...
              strcat('The residual is not full rank or/and operatorB ',...
              'is not positive definite.'));
              break
          end
          
      end
      clear gramRBR;
      
      if isnumeric(operatorA)
          blockVectorAR(:,activeMask) = operatorA*blockVectorR(:,activeMask);
      else
          blockVectorAR(:,activeMask) = ...
              feval(operatorA,blockVectorR(:,activeMask));
      end
      
      if iterationNumber > 1
          
          %Making active conjugate directions orthonormal
          if isempty(operatorB)
              %[blockVectorP(:,activeMask),gramPBP] = qr(blockVectorP(:,activeMask),0);
              gramPBP=blockVectorP(:,activeMask)'*blockVectorP(:,activeMask);
              if ~isreal(gramPBP)
                  gramPBP=(gramPBP+gramPBP')*0.5; 
              end
              [gramPBP,cholFlag]=chol(gramPBP);
              if  cholFlag == 0
                  blockVectorP(:,activeMask) = ...
                      blockVectorP(:,activeMask)/gramPBP;
                  blockVectorAP(:,activeMask) = ...
                      blockVectorAP(:,activeMask)/gramPBP;
              else
                  warning('BLOPEX:lobpcg:DirectionNotFullRank',...
                      'The direction matrix is not full rank.');
                  break
              end
          else
              gramPBP=blockVectorP(:,activeMask)'*blockVectorBP(:,activeMask);
              if ~isreal(gramPBP)
                  gramPBP=(gramPBP+gramPBP')*0.5; 
              end
              [gramPBP,cholFlag]=chol(gramPBP);
              if  cholFlag == 0
                  blockVectorP(:,activeMask) = ...
                      blockVectorP(:,activeMask)/gramPBP;
                  blockVectorAP(:,activeMask) = ...
                      blockVectorAP(:,activeMask)/gramPBP;
                  blockVectorBP(:,activeMask) = ...
                      blockVectorBP(:,activeMask)/gramPBP;
              else
                  warning('BLOPEX:lobpcg:DirectionNotFullRank',...
                 strcat('The direction matrix is not full rank ',...
              'or/and operatorB is not positive definite.'));
                  break
              end
          end
          clear gramPBP
      end
      
      condestGmean = mean(condestGhistory(max(1,iterationNumber-10-...
          round(log(currentBlockSize))):iterationNumber));
      
      %  restart=1;
      
      % The Raileight-Ritz method for [blockVectorX blockVectorR blockVectorP]
      
      if  residualNorms > eps^0.6
          explicitGramFlag = 0;
      else
          explicitGramFlag = 1;  %suggested by Garrett Moran, private 
      end
      
      activeRSize=size(blockVectorR(:,activeMask),2);
      if iterationNumber == 1
          activePSize=0;
          restart=1;
      else
          activePSize=size(blockVectorP(:,activeMask),2);
          restart=0;
      end
      
      gramXAR=full(blockVectorAX'*blockVectorR(:,activeMask));
      gramRAR=full(blockVectorAR(:,activeMask)'*blockVectorR(:,activeMask));
      gramRAR=(gramRAR'+gramRAR)*0.5;
      
      if explicitGramFlag
          gramXAX=full(blockVectorAX'*blockVectorX);
          gramXAX=(gramXAX'+gramXAX)*0.5;
          if isempty(operatorB)
              gramXBX=full(blockVectorX'*blockVectorX);
              gramRBR=full(blockVectorR(:,activeMask)'*...
                  blockVectorR(:,activeMask));
              gramXBR=full(blockVectorX'*blockVectorR(:,activeMask));
          else
              gramXBX=full(blockVectorBX'*blockVectorX);
              gramRBR=full(blockVectorBR(:,activeMask)'*...
                  blockVectorR(:,activeMask));
              gramXBR=full(blockVectorBX'*blockVectorR(:,activeMask));
          end
          gramXBX=(gramXBX'+gramXBX)*0.5;
          gramRBR=(gramRBR'+gramRBR)*0.5;
          
      end
      
      for cond_try=1:2,           %cond_try == 2 when restart
          
          if ~restart
              gramXAP=full(blockVectorAX'*blockVectorP(:,activeMask));
              gramRAP=full(blockVectorAR(:,activeMask)'*...
                  blockVectorP(:,activeMask));
              gramPAP=full(blockVectorAP(:,activeMask)'*...
                  blockVectorP(:,activeMask));
              gramPAP=(gramPAP'+gramPAP)*0.5;
              
              if explicitGramFlag
                  gramA = [ gramXAX     gramXAR     gramXAP
                      gramXAR'    gramRAR     gramRAP
                      gramXAP'     gramRAP'    gramPAP ];
              else
                  gramA = [ diag(lambda)  gramXAR  gramXAP
                      gramXAR'      gramRAR  gramRAP
                      gramXAP'      gramRAP'  gramPAP ];
              end
              
              clear gramXAP  gramRAP gramPAP
              
              if isempty(operatorB)
                  gramXBP=full(blockVectorX'*blockVectorP(:,activeMask));
                  gramRBP=full(blockVectorR(:,activeMask)'*...
                      blockVectorP(:,activeMask));
              else
                  gramXBP=full(blockVectorBX'*blockVectorP(:,activeMask));
                  gramRBP=full(blockVectorBR(:,activeMask)'*...
                      blockVectorP(:,activeMask));
                  %or blockVectorR(:,activeMask)'*blockVectorBP(:,activeMask);
              end
              
              if explicitGramFlag
                  if isempty(operatorB)
                      gramPBP=full(blockVectorP(:,activeMask)'*...
                          blockVectorP(:,activeMask));
                  else
                      gramPBP=full(blockVectorBP(:,activeMask)'*...
                          blockVectorP(:,activeMask));
                  end
                  gramPBP=(gramPBP'+gramPBP)*0.5;
                  gramB = [ gramXBX  gramXBR  gramXBP
                      gramXBR' gramRBR  gramRBP
                      gramXBP' gramRBP' gramPBP ];
                  clear   gramPBP
              else
                  gramB=[eye(blockSize) zeros(blockSize,activeRSize) gramXBP
                      zeros(blockSize,activeRSize)' eye(activeRSize) gramRBP
                      gramXBP' gramRBP' eye(activePSize) ];
              end
              
              clear gramXBP  gramRBP;
              
          else
              
              if explicitGramFlag
                  gramA = [ gramXAX   gramXAR
                      gramXAR'    gramRAR  ];
                  gramB = [ gramXBX  gramXBR
                      gramXBR' eye(activeRSize)  ];
                  clear gramXAX gramXBX gramXBR
              else
                  gramA = [ diag(lambda)  gramXAR
                      gramXAR'        gramRAR  ];
                  gramB = eye(blockSize+activeRSize);
              end
              
              clear gramXAR gramRAR;
              
          end
          
          condestG = log10(cond(gramB))+1;
          if (condestG/condestGmean > 2 && condestG > 2 )|| condestG > 8
              %black magic - need to guess the restart
              if verbosityLevel
                  fprintf('Restart on step %i as condestG %5.4e \n',...
                      iterationNumber,condestG);
              end
              if cond_try == 1 && ~restart
                  restart=1; %steepest descent restart for stability
              else
                  warning('BLOPEX:lobpcg:IllConditioning',...
                      'Gramm matrix ill-conditioned: results unpredictable');
              end
          else
              break
          end
          
      end
      
      [gramA,gramB]=eig(gramA,gramB);
      lambda=diag(gramB(1:blockSize,1:blockSize)); 
      coordX=gramA(:,1:blockSize);
      
      clear gramA gramB
      
      if issparse(blockVectorX)
          coordX=sparse(coordX);
      end
      
      if ~restart
          blockVectorP =  blockVectorR(:,activeMask)*...
              coordX(blockSize+1:blockSize+activeRSize,:) + ...
              blockVectorP(:,activeMask)*...
              coordX(blockSize+activeRSize+1:blockSize + ...
              activeRSize+activePSize,:);
          blockVectorAP = blockVectorAR(:,activeMask)*...
              coordX(blockSize+1:blockSize+activeRSize,:) + ...
              blockVectorAP(:,activeMask)*...
              coordX(blockSize+activeRSize+1:blockSize + ...
              activeRSize+activePSize,:);
          if ~isempty(operatorB)
              blockVectorBP = blockVectorBR(:,activeMask)*...
                  coordX(blockSize+1:blockSize+activeRSize,:) + ...
                  blockVectorBP(:,activeMask)*...
                  coordX(blockSize+activeRSize+1:blockSize+activeRSize+activePSize,:);
          end
      else %use block steepest descent
          blockVectorP =   blockVectorR(:,activeMask)*...
              coordX(blockSize+1:blockSize+activeRSize,:);
          blockVectorAP = blockVectorAR(:,activeMask)*...
              coordX(blockSize+1:blockSize+activeRSize,:);
          if ~isempty(operatorB)
              blockVectorBP = blockVectorBR(:,activeMask)*...
                  coordX(blockSize+1:blockSize+activeRSize,:);
          end
      end
      
      blockVectorX = blockVectorX*coordX(1:blockSize,:) + blockVectorP;
      blockVectorAX=blockVectorAX*coordX(1:blockSize,:) + blockVectorAP;
      if ~isempty(operatorB)
          blockVectorBX=blockVectorBX*coordX(1:blockSize,:) + blockVectorBP;
      end
      clear coordX
      %%end RR
      
      lambdaHistory(1:blockSize,iterationNumber+1)=lambda;
      condestGhistory(iterationNumber+1)=condestG;
      
      if verbosityLevel
          fprintf('Iteration %i current block size %i \n',...
              iterationNumber,currentBlockSize);
          fprintf('Eigenvalues lambda %17.16e \n',lambda);
          fprintf('Residual Norms %e \n',residualNorms');
      end
  end
  %The main step of the method was the CG cycle: end

  %Postprocessing

  %Making sure blockVectorX's "exactly" satisfy the blockVectorY constrains??

  %Making sure blockVectorX's are "exactly" othonormalized by final "exact" RR
  if isempty(operatorB)
      gramXBX=full(blockVectorX'*blockVectorX);
  else
      if isnumeric(operatorB)
          blockVectorBX = operatorB*blockVectorX;
      else
          blockVectorBX = feval(operatorB,blockVectorX);
      end
      gramXBX=full(blockVectorX'*blockVectorBX);
  end
  gramXBX=(gramXBX'+gramXBX)*0.5;

  if isnumeric(operatorA)
      blockVectorAX = operatorA*blockVectorX;
  else
      blockVectorAX = feval(operatorA,blockVectorX);
  end
  gramXAX = full(blockVectorX'*blockVectorAX);
  gramXAX = (gramXAX + gramXAX')*0.5;

  %Raileigh-Ritz for blockVectorX, which is already operatorB-orthonormal
  [coordX,gramXBX] = eig(gramXAX,gramXBX);
  lambda=diag(gramXBX);

  if issparse(blockVectorX)
      coordX=sparse(coordX);
  end

  blockVectorX  =   blockVectorX*coordX;
  blockVectorAX  =  blockVectorAX*coordX;
  if ~isempty(operatorB)
      blockVectorBX  =  blockVectorBX*coordX;
  end

  %Computing all residuals
  if isempty(operatorB)
      if blockSize > 1
          blockVectorR = blockVectorAX - ...
              blockVectorX*spdiags(lambda,0,blockSize,blockSize);
      else
          blockVectorR = blockVectorAX - blockVectorX*lambda;
          %to make blockVectorR full when lambda is just a scalar
      end
  else
      if blockSize > 1
          blockVectorR=blockVectorAX - ...
              blockVectorBX*spdiags(lambda,0,blockSize,blockSize);
      else
          blockVectorR = blockVectorAX - blockVectorBX*lambda;
          %to make blockVectorR full when lambda is just a scalar
      end
  end

  residualNorms=full(sqrt(sum(conj(blockVectorR).*blockVectorR)'));
  residualNormsHistory(1:blockSize,iterationNumber)=residualNorms;

  if verbosityLevel
      fprintf('Final Eigenvalues lambda %17.16e \n',lambda);
      fprintf('Final Residual Norms %e \n',residualNorms');
  end

  if verbosityLevel == 2
      whos
      figure(491)
      semilogy((abs(residualNormsHistory(1:blockSize,1:iterationNumber-1)))');
      title('Residuals for Different Eigenpairs','fontsize',16);
      ylabel('Eucledian norm of residuals','fontsize',16);
      xlabel('Iteration number','fontsize',16);
      %axis tight;
      %axis([0 maxIterations+1 1e-15 1e3])
      set(gca,'FontSize',14);
      figure(492);
      semilogy(abs((lambdaHistory(1:blockSize,1:iterationNumber)-...
          repmat(lambda,1,iterationNumber)))');
      title('Eigenvalue errors for Different Eigenpairs','fontsize',16);
      ylabel('Estimated eigenvalue errors','fontsize',16);
      xlabel('Iteration number','fontsize',16);
      %axis tight;
      %axis([0 maxIterations+1 1e-15 1e3])
      set(gca,'FontSize',14);
      drawnow;
  end

  varargout(1)={failureFlag};
  varargout(2)={lambdaHistory(1:blockSize,1:iterationNumber)};
  varargout(3)={residualNormsHistory(1:blockSize,1:iterationNumber-1)};
end
