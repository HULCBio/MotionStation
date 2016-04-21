## Copyright (C) 2005-2006 Chih-Jen Lin <cjlin@csie.ntu.edu.tw>
## All rights reserved.
##
## Redistribution and use in source and binary forms, with or without
## modification, are permitted provided that the following conditions are met:
##
##     1 Redistributions of source code must retain the above copyright notice,
##       this list of conditions and the following disclaimer.
##     2 Redistributions in binary form must reproduce the above copyright
##       notice, this list of conditions and the following disclaimer in the
##       documentation and/or other materials provided with the distribution.
##
## THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS ''AS IS''
## AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
## IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
## ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR
## ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
## DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
## SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
## CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
## OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
## OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
##
## The views and conclusions contained in the software and documentation are
## those of the authors and should not be interpreted as representing official
## policies, either expressed or implied, of the copyright holders.

## -*- texinfo -*-
## @deftypefn {Function File} {[@var{W}, @var{H}] =} nmf_pg (@var{V}, @var{Winit}, @
## @var{Hinit}, @var{tol}, @var{timelimit}, @var{maxiter})
##
## Non-negative matrix factorization by alternative non-negative least squares
## using projected gradients.
##
## The matrix @var{V} is factorized into two possitive matrices @var{W} and
## @var{H} such that @code{V = W*H + U}. Where @var{U} is a matrix of residuals
## that can be negative or positive. When the matrix @var{V} is positive the order
## of the elements in @var{U} is bounded by the optional named argument @var{tol}
## (default value @code{1e-9}).
##
## The factorization is not unique and depends on the inital guess for the matrices
## @var{W} and @var{H}. You can pass this initalizations using the optional
## named arguments @var{Winit} and @var{Hinit}.
##
## timelimit, maxiter: limit of time and iterations
##
## Examples:
##
## @example
##   A     = rand(10,5);
##   [W H] = nmf_pg(A,tol=1e-3);
##   U     = W*H -A;
##   disp(max(abs(U)));
## @end example
##
## @end deftypefn

## 2012 - Modified and adapted to Octave 3.6.1 by
## Juan Pablo Carbajal <carbajal@ifi.uzh.ch>

function [W, H] = nmf_pg (V, varargin)

# JuanPi Fri 16 Mar 2012 10:49:11 AM CET
# TODO:
# - finish docstring
# - avoid multiple transpositions

  # --- Parse arguments --- #
  parser = inputParser ();
  parser.FunctionName = "nmf_pg";
  parser = addParamValue (parser,'Winit', [], @ismatrix);
  parser = addParamValue (parser,'Hinit', [], @ismatrix);
  parser = addParamValue (parser,'Tol', 1e-6, @(x)x>0);
  parser = addParamValue (parser,'TimeLimit', 10, @(x)x>0);
  parser = addParamValue (parser,'MaxIter', 100, @(x)x>0);
  parser = addParamValue (parser,'MaxSubIter', 1e3, @(x)x>0);
  parser = addParamValue (parser,'Verbose', true);
  parser = parse(parser,varargin{:});

  Winit      = parser.Results.Winit;
  Hinit      = parser.Results.Hinit;
  tol        = parser.Results.Tol;
  timelimit  = parser.Results.TimeLimit;
  maxiter    = parser.Results.MaxIter;
  maxsubiter = parser.Results.MaxSubIter;
  verbose    = parser.Results.Verbose;

  clear parser
  # ------ #

  # --- Initialize matrices --- #
  [r c] = size (V);
  Hgiven = !isempty (Hinit);
  Wgiven = !isempty (Winit);
  if Wgiven && !Hgiven

    W = Winit;
    H = ones (size (W,2),c);

  elseif !Wgiven && Hgiven

    H = Hinit;
    W = ones (r, size(H,2));

  elseif !Wgiven && !Hgiven

    if r == c
      W = ones (r)
      H = W
    else
      W = ones (r);
      H = ones (r,c);
    end

  else

    W = Winit;
    H = Hinit;

  end
  [Hr,Hc] = size(H);
  [Wr,Wc] = size(W);

  # start tracking time
  initt = cputime ();

  gradW = W*(H*H') - V*H';
  gradH = (W'*W)*H - W'*V;

  initgrad = norm([gradW; gradH'],'fro');

  # Tolerances for matrices
  tolW = max(0.001,tol)*initgrad;
  tolH = tolW;

  # ------ #

  # --- Main Loop --- #
  if verbose
    fprintf ('--- Factorizing %d-by-%d matrix into %d-by-%d times %d-by-%d\n',...
         r,c,Wr,Wc,Hr,Hc);
    fprintf ("Initial gradient norm = %f\n", initgrad);
    fflush (stdout);
    text_waitbar(0,'Please wait ...');
  end

  for iter = 1:maxiter

    # stopping condition
    projnorm = norm ( [ gradW(gradW<0 | W>0); gradH(gradH<0 | H>0) ] );
    stop_cond = [projnorm < tol*initgrad , cputime-initt > timelimit];
    if any (stop_cond)
      if stop_cond(2)
        warning('mnf_pg:MaxIter',["Time limit exceeded.\n" ...
                                  "Could be solved increasing TimeLimit.\n"]);
      end
      break
    end


    # FIXME: avoid multiple transpositions
    [W, gradW, iterW] = nlssubprob(V', H', W', tolW, maxsubiter, verbose);
    W = W';
    gradW = gradW';

    if iterW == 1,
      tolW = 0.1 * tolW;
    end

    [H, gradH, iterH] = nlssubprob(V, W, H, tolH, maxsubiter, verbose);
    if iterH == 1,
      tolH = 0.1 * tolH;
    end

    if (iterW == 1 && iterH == 1 && tolH + tolW < tol*initgrad),
      warning ('nmf_pg:InvalidArgument','Failed to move');
      break
    end

     if verbose
      text_waitbar (iter/maxiter);
     end
  end

  if iter == maxiter
    warning('mnf_pg:MaxIter',["Reached maximum iterations in main loop.\n" ...
                              "Could be solved increasing MaxIter.\n"]);
  end

  if verbose
    fprintf ('\nIterations = %d\nFinal proj-grad norm = %f\n', iter, projnorm);
    fflush (stdout);
  end
endfunction

function [H, grad,iter] = nlssubprob(V,W,Hinit,tol,maxiter,verbose)
% H, grad: output solution and gradient
% iter: #iterations used
% V, W: constant matrices
% Hinit: initial solution
% tol: stopping tolerance
% maxiter: limit of iterations

  H = Hinit;
  WtV = W'*V;
  WtW = W'*W;

  alpha = 1;
  beta = 0.1;

  for iter=1:maxiter
    grad = WtW*H - WtV;
    projgrad = norm ( grad(grad < 0 | H >0) );

    if projgrad < tol,
      break
    end

    % search step size
    Hn = max(H - alpha*grad, 0);
    d = Hn-H;
    gradd = sum ( sum (grad.*d) );
    dQd = sum ( sum ((WtW*d).*d) );

    if gradd + 0.5*dQd > 0.01*gradd,
      % decrease alpha
      while 1,
        alpha *= beta;
        Hn = max (H - alpha*grad, 0);
        d = Hn-H;
        gradd = sum (sum (grad.*d) );
        dQd = sum (sum ((WtW*d).*d));

        if gradd + 0.5*dQd <= 0.01*gradd || alpha < 1e-20
          H = Hn;
          break
        end

      endwhile

    else
      % increase alpha
      while 1,
        Hp = Hn;
        alpha /= beta;
        Hn = max (H - alpha*grad, 0);
        d = Hn-H;
        gradd = sum ( sum (grad.*d) );
        dQd = sum (sum ( (WtW*d).*d ) );

        if gradd + 0.5*dQd > 0.01*gradd || Hn == Hp || alpha > 1e10
          H = Hp;
          alpha *= beta;
          break
        end

      endwhile
    end

  endfor

  if iter == maxiter
    warning('mnf_pg:MaxIter',["Reached maximum iterations in nlssubprob\n" ...
                              "Could be solved increasing MaxSubIter.\n"]);
  end

endfunction

%!demo
%! t = linspace (0,1,100)';
%!
%! ## --- Build hump functions of different frequency
%! W_true = arrayfun ( @(f)sin(2*pi*f*t).^2, linspace (0.5,2,4), ...
%!                                                     'uniformoutput', false );
%! W_true = cell2mat (W_true);
%! ## --- Build combinator vectors
%! c      = (1:4)';
%! H_true = arrayfun ( @(f)circshift(c,f), linspace (0,3,4), ...
%!                                                     'uniformoutput', false );
%! H_true = cell2mat (H_true);
%! ## --- Mix them
%! V = W_true*H_true;
%! ## --- Give good inital guesses
%! Winit = W_true + 0.4*randn(size(W_true));
%! Hinit = H_true + 0.2*randn(size(H_true));
%! ## --- Factorize
%! [W H] = nmf_pg(V,'Winit',Winit,'Hinit',Hinit,'Tol',1e-6,'MaxIter',1e3);
%! disp('True mixer')
%! disp(H_true)
%! disp('Rounded factorized mixer')
%! disp(round(H))
%! ## --- Plot results
%! plot(t,W,'o;factorized;')
%! hold on
%! plot(t,W_true,'-;True;')
%! hold off
%! axis tight
