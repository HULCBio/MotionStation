## Copyright (C) 2007 Thomas Kasper, <thomaskasper@gmx.net>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; If not, see <http://www.gnu.org/licenses/>. 

## -*- texinfo -*-
## @deftypefn {Function File} {} __ga__ (@var{name}, @var{varargin})
## @deftypefnx {Function File} {} __ga__ (@var{fid})
## Testscript for the gradient algebra implemented by the package AD
##
## If the first argument is a character string, assert functionality 
## @var{name} complies with the specification. Otherwise run a set of 
## predefined tests and report failures to the stream @var{fid}
## (defaulting to @var{stderr})
##
## Intended use is:
##
## @example
## @group
## fid = fopen ("errors.log", "wt");
## __ga__ (fid)
## @result{} PASSES [#] out of [#] tests ([#] expected failures)
## @end group
## @end example
## @end deftypefn
## @seealso{test}

function [] = __ga__ (varargin)

  verbose = 0;
  tol = 1e-10;
    
  if nargin < 2
    if nargin == 0
      test ("__ga__", "quiet", stderr);
    else
      test ("__ga__", "quiet", varargin{1});
    endif
    return
  endif
  
  name = varargin{1};
  varargin(1) = [];
  sig = {"a", "adx", "b", "bdx"};
  switch name
  
    %% binary ops...
    
    case {"+"}
      [op1, op2, a, b, adx, bdx, msg] = ...
        binopargs (varargin{:});
      got = op1 + op2;
      assert (isgradient (got)); 
      assert (got.x, a+b, eps);
      assert (got.dx, elbop (a, adx, b, bdx, ...
	    inline ("adx+bdx", sig{:})), tol);
    case {"-"}
      [op1, op2, a, b, adx, bdx, msg] = ...
        binopargs (varargin{:});
	  got = op1 - op2; 
	  assert (isgradient (got)); 
	  assert (got.x, a-b, eps);
	  assert (got.dx, elbop (a, adx, b, bdx, ...
        inline ("adx-bdx", sig{:})), tol);
    case {".*"}
      [op1, op2, a, b, adx, bdx, msg] = ...
        binopargs (varargin{:});
      got = op1 .* op2; 
      assert (isgradient (got));
      assert (got.x, a.*b, eps);
      assert (got.dx, elbop (a, adx, b, bdx, ...
        inline ("adx*b + a*bdx", sig{:})), tol);
    case {"./"}
      [op1, op2, a, b, adx, bdx, msg] = ...
        binopargs (varargin{:});
      got = op1 ./ op2; 
      assert (isgradient (got)); 
      assert (got.x, a./b, eps);
      assert (got.dx, elbop (a, adx, b, bdx, ...
        inline ("adx/b - a*bdx/b^2", sig{:})), tol);
    case {".^"}
      [op1, op2, a, b, adx, bdx, msg] = ...
        binopargs (varargin{:});
      got = op1 .^ op2; 
      assert (isgradient (got)); 
	  assert (got.x, a.^b, eps);
	  assert (got.dx, elbop (a, adx, b, bdx, ...
	    inline ("b*(a^(b-1))*adx + log(a)*bdx*(a^b)", sig{:})), tol);
    case {"*"}
      [op1, op2, a, b, adx, bdx, msg] = ...
        binopargs (varargin{:});
      got = op1 * op2; 
	  assert (isgradient (got)); 
	  assert (got.x, a*b, eps);
	  if isscalar (a) || isscalar (b)
	    assert (got.dx, elbop (a, adx, b, bdx, ...
	      inline ("adx*b + a*bdx", sig{:})), tol);
	  else
	    assert (got.dx, prodrule (a, adx, b, bdx), tol);
      endif
    case {"\\"}
      [op1, op2, a, b, adx, bdx, msg] = ...
        binopargs (varargin{:});
      got = op1 \ op2;
	  assert (isgradient (got)); 
	  assert (got.x, a\b, tol);
	  if isscalar (a) || isscalar (b)
	    assert (got.dx, elbop (a, adx, b, bdx, ... 
	      inline ("bdx/a - b*adx/a^2", sig{:})), tol);
	  elseif rows (a) > columns (a)
	    lhs = op1' * op1 * got; rhs = op1' *op2;
	    assert (lhs.dx, rhs.dx, tol);
	  elseif rows (a) < columns (a)
	    expected = op1' * ((op1 * op1') \ op2);
	    assert (got.dx, expected.dx, tol);
	  else
        assert (prodrule (a, adx, got.x, got.dx), bdx, tol);
	  endif
    case {"/"}
      [op1, op2, a, b, adx, bdx, msg] = ...
        binopargs (varargin{:});
      got = op1 / op2;
	  assert (isgradient (got)); 
	  assert (got.x, a/b, tol);
	  if isscalar (a) || isscalar (b)
	    assert (got.dx, elbop (a, adx, b, bdx, ...
	      inline ("adx/b - a*bdx/b^2", sig{:})), tol);
	  elseif rows (b) < columns (b)
	    lhs = got * op2 * op2'; rhs = op1 * op2';
	    assert (lhs.dx, rhs.dx, tol);
	  elseif rows (b) > columns (b)
	    expected = (op1 / (op2' * op2)) * op2';
	    assert (got.dx, expected.dx, tol);
	  else
        assert (prodrule (got.x, got.dx, b, bdx), adx, tol);
	  endif
	case {"^"}
      [op1, op2, a, b, adx, bdx, msg] = ...
        binopargs (varargin{:});
      got = op1 ^ op2; 
	  assert (isgradient (got)); 
	  assert (got.x, a^b, tol);
	  if isscalar (a) && isscalar (b)
	    assert (got.dx, elbop (a, adx, b, bdx, ...
	      inline ("b*(a^(b-1))*adx + log(a)*bdx*(a^b)", sig{:})), tol);
	  else
	    c = a; cdx = adx;
	    for k = 1 : b-1
	      cdx = prodrule (c, cdx, a, adx);
	      c = c * a;
	    endfor
	    assert (got.dx, cdx, tol);
      endif
      
	%% mappers etc...
	
	case {"acos"}
	    [op, a, adx, params, msg] = ...
	      unopargs (varargin{:});
	    got = acos (op);
	    assert (isgradient (got));
	    assert (got.x, acos (a), eps);
	    assert (got.dx, maprule (a, adx, ...
	      inline ("-adx / sqrt (1 - a^2)", sig{1:2})), tol);
	  case {"acosh"}
	    [op, a, adx, params, msg] = ...
	      unopargs (varargin{:});
		got = acosh (op);
		assert (isgradient (got));
		assert (got.x, acosh (a), eps);
		assert (got.dx, maprule (a, adx, ...
		  inline ("adx / sqrt (a^2 - 1)", sig{1:2})), tol);
	  case {"asin"}
	  	[op, a, adx, params, msg] = ...
	      unopargs (varargin{:});
		got = asin (op);
		assert (isgradient (got));
		assert (got.x, asin (a), eps);
		assert (got.dx, maprule (a, adx, ...
		  inline ("adx / sqrt (1 - a^2)", sig{1:2})), tol);
	  case {"asinh"}
	    [op, a, adx, params, msg] = ...
	      unopargs (varargin{:});
		got = asinh (op);
		assert (isgradient (got));
		assert (got.x, asinh (a), eps);
		assert (got.dx, maprule (a, adx, ...
		  inline ("adx / sqrt (1 + a^2)", sig{1:2})), tol);
	  case {"atan"}
	    [op, a, adx, params, msg] = ...
	      unopargs (varargin{:});
		got = atan (op);
		assert (isgradient (got));
		assert (got.x, atan (a), eps);
		assert (got.dx, maprule (a, adx, ...
		  inline ("adx / (1 + a^2)", sig{1:2})), tol);	      
	  case {"atanh"}
	    [op, a, adx, params, msg] = ...
	      unopargs (varargin{:});
		got = atanh (op);
		assert (isgradient (got));
		assert (got.x, atanh (a), eps);
		assert (got.dx, maprule (a, adx, ...
		  inline ("adx / (1 - a^2)", sig{1:2})), tol);	      
	  case {"cos"}
	    [op, a, adx, params, msg] = ...
	      unopargs (varargin{:});
		got = cos (op);
		assert (isgradient (got));
		assert (got.x, cos (a), eps);
		assert (got.dx, maprule (a, adx, ...
		  inline ("adx * (-sin (a))", sig{1:2})), tol);	      
	  case {"exp"}
	    [op, a, adx, params, msg] = ...
	      unopargs (varargin{:});
		got = exp (op);
		assert (isgradient (got));
		assert (got.x, exp (a), eps);
		assert (got.dx, maprule (a, adx, ...
		  inline ("adx * exp (a)", sig{1:2})), tol);	           
	  case {"log"}
	    [op, a, adx, params, msg] = ...
	      unopargs (varargin{:});
		got = log (op);
		assert (isgradient (got));
		assert (got.x, log (a), eps);
		assert (got.dx, maprule (a, adx, ...
		  inline ("adx / a", sig{1:2})), tol);	           
	  case {"sin"}
	    [op, a, adx, params, msg] = ...
	      unopargs (varargin{:});
		got = sin (op);
		assert (isgradient (got));
		assert (got.x, sin (a), eps);
		assert (got.dx, maprule (a, adx, ...
		  inline ("adx * cos (a)", sig{1:2})), tol);	      
	  case {"sqrt"}
	    [op, a, adx, params, msg] = ...
	      unopargs (varargin{:});
		got = sqrt (op);
		assert (isgradient (got));
		assert (got.x, sqrt (a), eps);
		assert (got.dx, maprule (a, adx, ...
		  inline ("adx / (2 * sqrt (a))", sig{1:2})), tol);
	  case {"tan"}
	    [op, a, adx, params, msg] = ...
	      unopargs (varargin{:});
		got = tan (op);
		assert (isgradient (got));
		assert (got.x, tan (a), eps);
		assert (got.dx, maprule (a, adx, ...
		  inline ("adx / (cos (a)^2)", sig{1:2})), tol);
    otherwise
	  error (sprintf ("test not implemented: %s", name));
  endswitch

  if verbose
    printf ("%s %s\n", name, msg);
  endif
endfunction

function [op1, op2, a, b, adx, bdx, s] = binopargs (varargin)
  if nargin == 2 && ...
    (isgradient (op1 = varargin{1}) |
     isgradient (op2 = varargin{2}))
     
    op1 = varargin{1};
    op2 = varargin{2};
                 
    if isgradient (op1)
      nda = size (op1.dx, 1);
      a = op1.x; adx = op1.dx;
    else
      nda = size (op2.dx, 1);
      a = op1; adx = zeros (nda, numel (a));
    endif
    if isgradient (op2)
      ndb = size (op2.dx, 1);
      b = op2.x; bdx = op2.dx;
    else
      ndb = size (op1.dx, 1);
      b = op2; bdx = zeros (ndb, numel (b));
    endif
    s = sprintf ("\top1: %s\n\top2: %s", ...
          arginfo (op1), arginfo (op2));      
  else 
    error ("bad arguments");
  endif
endfunction
 
function [op, a, adx, params, s] = unopargs (varargin)
  if nargin > 0 && isgradient (op = varargin{1})
    a = op.x; adx = op.dx;
    s = sprintf ("\top:  %s", arginfo (op));
    params = varargin(2:end);
    if !isempty (params)
      s = sprintf ("%s p = %s", s, sprintf ("%d ", params{:}));
    endif
  else
    error ("bad arguments");
  endif
endfunction
  
function cdx = elbop (a, adx, b, bdx, rule)
  nd = size (adx, 1);
  if isscalar (a)
    cdx = zeros (nd, numel(b));
    for i = 1 : numel (b)
      for k = 1 : size (adx, 1)
        cdx(k,i) = rule (a, adx(k,1), b(i), bdx(k,i));
      endfor
    endfor
  elseif isscalar (b)
    cdx = zeros (nd, numel(a));
    for i = 1 : numel (a)
	  for k = 1 : size (adx, 1)
        cdx(k,i) = rule (a(i), adx(k,i), b, bdx(k,1));
      endfor
    endfor
  elseif size (a) == size (b)
    cdx = zeros (nd, numel(b));
    for i = 1 : numel (a)
      for k = 1 : size (adx, 1)
        cdx(k,i) = rule (a(i), adx(k,i), b(i), bdx(k,i));
      endfor
    endfor
  else error ("operands mismatch");
  endif
endfunction

function cdx = prodrule (a, adx, b, bdx)
  nd = size (adx, 1);
  sa = size (a);
  sb = size (b);
  adx = reshape (full (adx), [nd, size(a)]);
  bdx = reshape (full (bdx), [nd, size(b)]);
  cdx = zeros ([nd, sa(1), sb(2)]);
  for i = 1 : sa(1)
    for j = 1 : sb(2)
      for l = 1 : sa(2)
        for k = 1 : nd
          cdx(k, i, j) += adx(k, i, l) * b(l, j) + a(i, l) * bdx(k, l, j);
        endfor
      endfor
    endfor
  endfor
  cdx = reshape (cdx, nd, sa(1)*sb(2));
endfunction

function cdx = maprule (a, adx, rule)
  cdx = zeros (size (adx));
  for i = 1 : numel (a)
    for k = 1 : size (adx, 1);
      cdx(k, i) = rule (a(i), adx(k, i));
    endfor
  endfor
endfunction

function s = arginfo (v)
  set = {"complex", "real"};
  s = sprintf ("%s\t%s\t(%s)", class (v), set{isreal(v)+1}, ...
    sprintf ("%dx", size (v))(1:end-1));
  if isgradient (v)
    s = sprintf ("%s[%d]", s, size (v.dx, 1));
  endif
endfunction

%!shared t, d
%! d = 5;
%! %% =======================================================
%! %% auxiliary functions to create random data
%! %% =======================================================
%!function ret = g (nd, s, r)
%!  v1 = 2*rand (s) -1;
%!  v2 = 2*rand (s) -1;
%!  v1(find (v1==0)) = 1e-3; % saves some trouble for / and ^
%!  if use_sparse_jacobians () == 1
%!    nz = sprand (nd, prod (s), .5);
%!    v3 = 2*sprand (nz) - sparse (nz != 0);
%!    v4 = 2*sprand (nz) - sparse (nz != 0);
%!  else
%!    v3 = 2*rand (nd, prod (s)) -1;
%!    v4 = 2*rand (nd, prod (s)) -1;
%!  endif
%!  ret    = gradinit (1:nd);
%!  ret.x  = v1 + i*v2;
%!  ret.dx = v3 + i*v4;
%! endfunction
%! %% =======================================================
%! %% operator +
%! %% =======================================================
%! %% sc x sc 
%!test __ga__ ("+", g (d,[1,1]), rand (1));
%!test __ga__ ("+", g (d,[1,1]), rand (1)+i*rand (1));
%!test __ga__ ("+", rand (1), g (d,[1,1]));
%!test __ga__ ("+", rand (1)+i*rand (1), g (1,[1,1]));
%!test __ga__ ("+", g (d,[1,1]), g (d,[1,1]));
%! %% sc x nd
%!test __ga__ ("+", g (d,[1,1]), rand ([3,4,5]));
%!test __ga__ ("+", g (d,[1,1]), rand ([3,4,5])+i*rand ([3,4,5]));
%!test __ga__ ("+", g (d,[1,1]), t=sprand (8,6,.5));
%!test __ga__ ("+", g (d,[1,1]), sprand (t)+i*sprand (t));
%!test __ga__ ("+", rand (1), g (d,[3,5,2]));
%!test __ga__ ("+", rand (1)+i*rand (1), g (d,[3,5,2]));
%!test __ga__ ("+", g (d,[1,1]), g (d,[4,5,2]));
%! %% nd x sc
%!test __ga__ ("+", g (d,[3,4,5]), rand (1));
%!test __ga__ ("+", g (d,[4,5,2]), rand (1)+i*rand (1));
%!test __ga__ ("+", rand ([3,4,5]), g (d,[1,1]));
%!test __ga__ ("+", rand ([4,5,2])+i*rand ([4,5,2]), g (d,[1,1]));
%!test __ga__ ("+", t=sprand (8,6,.5), g (d,[1,1]));
%!test __ga__ ("+", sprand (t)+i*sprand (t), g (d,[1,1]));
%!test __ga__ ("+", g (d,[4,5,2]), g (d,[1,1]));
%! %% nd x nd
%!test __ga__ ("+", g (d,[3,4,5]), rand ([3,4,5]));
%!test __ga__ ("+", g (d,[4,5,2]), rand ([4,5,2])+i*rand ([4,5,2]));
%!test __ga__ ("+", g (d,[8,6]), t=sprand (8,6,0.5));
%!test __ga__ ("+", g (d,[8,6]), sprand (t)+i*sprand (t));
%!test __ga__ ("+", rand ([3,4,5]), g (d,[3,4,5]));
%!test __ga__ ("+", rand ([4,5,2])+i*rand ([4,5,2]), g (d,[4,5,2]));
%!test __ga__ ("+", t=sprand (8,6,.5), g (d,[8,6]));
%!test __ga__ ("+", sprand (t)+i*sprand (t), g (d,[8,6]));
%!test __ga__ ("+", g (d,[4,5,2]), g (d,[4,5,2]));
%! %% op matching
%!fail ("g (d,[3,2]) + g (d+1,[3,2])", "number of derivatives");
%! %% =======================================================
%! %% operator -
%! %% =======================================================
%! %% sc x sc 
%!test __ga__ ("-", g (d,[1,1]), rand (1));
%!test __ga__ ("-", g (d,[1,1]), rand (1)+i*rand (1));
%!test __ga__ ("-", rand (1), g (d,[1,1]));
%!test __ga__ ("-", rand (1)+i*rand (1), g (1,[1,1]));
%!test __ga__ ("-", g (d,[1,1]), g (d,[1,1]));
%! %% sc x nd
%!test __ga__ ("-", g (d,[1,1]), rand ([3,4,5]));
%!test __ga__ ("-", g (d,[1,1]), rand ([3,4,5])+i*rand ([3,4,5]));
%!test __ga__ ("-", g (d,[1,1]), t=sprand (8,6,.5));
%!test __ga__ ("-", g (d,[1,1]), sprand (t)+i*sprand (t));
%!test __ga__ ("-", rand (1), g (d,[3,5,2]));
%!test __ga__ ("-", rand (1)+i*rand (1), g (d,[3,5,2]));
%!test __ga__ ("-", g (d,[1,1]), g (d,[4,5,2]));
%! %% nd x sc
%!test __ga__ ("-", g (d,[3,4,5]), rand (1));
%!test __ga__ ("-", g (d,[4,5,2]), rand (1)+i*rand (1));
%!test __ga__ ("-", rand ([3,4,5]), g (d,[1,1]));
%!test __ga__ ("-", rand ([4,5,2])+i*rand ([4,5,2]), g (d,[1,1]));
%!test __ga__ ("-", t=sprand (8,6,.5), g (d,[1,1]));
%!test __ga__ ("-", sprand (t)+i*sprand (t), g (d,[1,1]));
%!test __ga__ ("-", g (d,[4,5,2]), g (d,[1,1]));
%! %% nd x nd
%!test __ga__ ("-", g (d,[3,4,5]), rand ([3,4,5]));
%!test __ga__ ("-", g (d,[4,5,2]), rand ([4,5,2])+i*rand ([4,5,2]));
%!test __ga__ ("-", g (d,[8,6]), t=sprand (8,6,0.5));
%!test __ga__ ("-", g (d,[8,6]), sprand (t)+i*sprand (t));
%!test __ga__ ("-", rand ([3,4,5]), g (d,[3,4,5]));
%!test __ga__ ("-", rand ([4,5,2])+i*rand ([4,5,2]), g (d,[4,5,2]));
%!test __ga__ ("-", t=sprand (8,6,.5), g (d,[8,6]));
%!test __ga__ ("-", sprand (t)+i*sprand (t), g (d,[8,6]));
%!test __ga__ ("-", g (d,[4,5,2]), g (d,[4,5,2]));
%! %% op matching
%!fail ("g (d,[3,2]) - g (d+1,[3,2])", "number of derivatives");
%! %% =======================================================
%! %% operator .*
%! %% =======================================================
%! %% sc x sc 
%!test __ga__ (".*", g (d,[1,1]), rand (1));
%!test __ga__ (".*", g (d,[1,1]), rand (1)+i*rand (1));
%!test __ga__ (".*", rand (1), g (d,[1,1]));
%!test __ga__ (".*", rand (1)+i*rand (1), g (1,[1,1]));
%!test __ga__ (".*", g (d,[1,1]), g (d,[1,1]));
%! %% sc x nd
%!test __ga__ (".*", g (d,[1,1]), rand ([3,4,5]));
%!test __ga__ (".*", g (d,[1,1]), rand ([3,4,5])+i*rand ([3,4,5]));
%!test __ga__ (".*", g (d,[1,1]), t=sprand (8,6,.5));
%!test __ga__ (".*", g (d,[1,1]), sprand (t)+i*sprand (t));
%!test __ga__ (".*", rand (1), g (d,[3,5,2]));
%!test __ga__ (".*", rand (1)+i*rand (1), g (d,[3,5,2]));
%!test __ga__ (".*", g (d,[1,1]), g (d,[4,5,2]));
%! %% nd x sc
%!test __ga__ (".*", g (d,[3,4,5]), rand (1)); % fixed in ov-2.9.19
%!test __ga__ (".*", g (d,[4,5,2]), rand (1)+i*rand (1));
%!test __ga__ (".*", rand ([3,4,5]), g (d,[1,1]));
%!test __ga__ (".*", rand ([4,5,2])+i*rand ([4,5,2]), g (d,[1,1]));
%!test __ga__ (".*", t=sprand (8,6,.5), g (d,[1,1]));
%!test __ga__ (".*", sprand (t)+i*sprand (t), g (d,[1,1]));
%!test __ga__ (".*", g (d,[4,5,2]), g (d,[1,1]));
%! %% nd x nd
%!test __ga__ (".*", g (d,[3,4,5]), rand ([3,4,5]));
%!test __ga__ (".*", g (d,[4,5,2]), rand ([4,5,2])+i*rand ([4,5,2]));
%!test __ga__ (".*", g (d,[8,6]), t=sprand (8,6,0.5));
%!test __ga__ (".*", g (d,[8,6]), sprand (t)+i*sprand (t));
%!test __ga__ (".*", rand ([3,4,5]), g (d,[3,4,5]));
%!test __ga__ (".*", rand ([4,5,2])+i*rand ([4,5,2]), g (d,[4,5,2]));
%!test __ga__ (".*", t=sprand (8,6,.5), g (d,[8,6]));
%!test __ga__ (".*", sprand (t)+i*sprand (t), g (d,[8,6]));
%!test __ga__ (".*", g (d,[4,5,2]), g (d,[4,5,2]));
%! %% op matching
%!fail ("g (d,[3,2]) .* g (d+1,[3,2])", "number of derivatives");
%! %% =======================================================
%! %% operator ./ 
%! %% =======================================================
%! %% Note: behaviour not defined for division by zero
%! %% +-Inf, NaN, etc. may not match in this case!
%! %% sc x sc 
%!test __ga__ ("./", g (d,[1,1]), rand (1)+.1);
%!test __ga__ ("./", g (d,[1,1]), rand (1)+i*rand (1)+.1);
%!test __ga__ ("./", rand (1), g (d,[1,1]));
%!test __ga__ ("./", rand (1)+i*rand (1), g (1,[1,1]));
%!test __ga__ ("./", g (d,[1,1]), g (d,[1,1]));
%! %% sc x nd
%!test __ga__ ("./", g (d,[1,1]), rand ([3,4,5])+.1);
%!test __ga__ ("./", g (d,[1,1]), rand ([3,4,5])+i*rand ([3,4,5])+.1);
%!test __ga__ ("./", g (d,[1,1]), sparse (rand ([8,6])+.1));
%!test __ga__ ("./", g (d,[1,1]), sparse (rand ([8,6])+i*rand ([8,6])+.1));
%!test __ga__ ("./", rand (1), g (d,[3,5,2]));
%!test __ga__ ("./", rand (1)+i*rand (1), g (d,[3,5,2]));
%!test __ga__ ("./", g (d,[1,1]), g (d,[4,5,2]));
%! %% nd x sc
%!test __ga__ ("./", g (d,[3,4,5]), rand (1)+.1);
%!test __ga__ ("./", g (d,[4,5,2]), rand (1)+i*rand (1)+.1);
%!test __ga__ ("./", rand ([3,4,5]), g (d,[1,1]));
%!test __ga__ ("./", rand ([4,5,2])+i*rand ([4,5,2]), g (d,[1,1]));
%!test __ga__ ("./", t=sprand (8,6,.5), g (d,[1,1]));
%!test __ga__ ("./", sprand (t)+i*sprand (t), g (d,[1,1]));
%!test __ga__ ("./", g (d,[4,5,2]), g (d,[1,1]));
%! %% nd x nd
%!test __ga__ ("./", g (d,[3,4,5]), rand ([3,4,5])+.1);
%!test __ga__ ("./", g (d,[4,5,2]), rand ([4,5,2])+i*rand ([4,5,2])+.1);
%!test __ga__ ("./", g (d,[8,6]), sparse (rand ([8,6])+.1));
%!test __ga__ ("./", g (d,[8,6]), sparse (rand ([8,6])+i*rand ([8,6])+.1));
%!test __ga__ ("./", rand ([3,4,5]), g (d,[3,4,5]));
%!test __ga__ ("./", rand ([4,5,2])+i*rand ([4,5,2]), g (d,[4,5,2]));
%!test __ga__ ("./", t=sprand (8,6,.5), g (d,[8,6]));
%!test __ga__ ("./", sprand (t)+i*sprand (t), g (d,[8,6]));
%!test __ga__ ("./", g (d,[4,5,2]), g (d,[4,5,2]));
%! %% op matching
%!fail ("g (d,[3,2]) ./ g (d+1,[3,2])", "number of derivatives");
%! %% =======================================================
%! %% operator .^
%! %% =======================================================
%! %% sc x sc 
%!test __ga__ (".^", g (d,[1,1]), rand (1));
%!test __ga__ (".^", g (d,[1,1]), rand (1)+i*rand (1));
%!test __ga__ (".^", rand (1)+.1, g (d,[1,1]));
%!test __ga__ (".^", rand (1)+i*rand (1)+.1, g (1,[1,1]));
%!test __ga__ (".^", g (d,[1,1]), g (d,[1,1]));
%! %% sc x nd
%!test __ga__ (".^", g (d,[1,1]), rand ([3,4,5]));
%!test __ga__ (".^", g (d,[1,1]), rand ([3,4,5])+i*rand ([3,4,5]));
%!test __ga__ (".^", g (d,[1,1]), t=sprand (8,6,.5));
%!test __ga__ (".^", g (d,[1,1]), sprand (t)+i*sprand (t));
%!test __ga__ (".^", rand (1)+.1, g (d,[3,5,2]));
%!test __ga__ (".^", rand (1)+i*rand (1)+.1, g (d,[3,5,2]));
%!test __ga__ (".^", g (d,[1,1]), g (d,[4,5,2]));
%! %% nd x sc
%!test __ga__ (".^", g (d,[3,4,5]), rand (1));
%!test __ga__ (".^", g (d,[4,5,2]), rand (1)+i*rand (1));
%!test __ga__ (".^", rand ([3,4,5])+.1, g (d,[1,1]));
%!test __ga__ (".^", rand ([4,5,2])+i*rand ([4,5,2])+.1, g (d,[1,1]));
%!test __ga__ (".^", sparse (rand([8,6])+.1), g (d,[1,1]));
%!test __ga__ (".^", sparse (rand([8,6])+i*rand([8,6])+.1), g (d,[1,1]));
%!test __ga__ (".^", g (d,[4,5,2]), g (d,[1,1]));
%! %% nd x nd
%!test __ga__ (".^", g (d,[3,4,5]), rand ([3,4,5]));
%!test __ga__ (".^", g (d,[4,5,2]), rand ([4,5,2])+i*rand ([4,5,2]));
%!test __ga__ (".^", g (d,[8,6]), t=sprand (8,6,0.5));
%!test __ga__ (".^", g (d,[8,6]), sprand (t)+i*sprand (t));
%!test __ga__ (".^", rand ([3,4,5])+.1, g (d,[3,4,5]));
%!test __ga__ (".^", rand ([4,5,2])+i*rand ([4,5,2])+.1, g (d,[4,5,2]));
%!test __ga__ (".^", sparse (rand([8,6])+.1), g (d,[8,6]));
%!test __ga__ (".^", sparse (rand([8,6])+i*rand([8,6])+.1), g (d,[8,6]));
%!test __ga__ (".^", g (d,[4,5,2]), g (d,[4,5,2]));
%! %% op matching
%!fail ("g (d,[3,2]) .^ g (d+1,[3,2])", "number of derivatives");
%! %% =======================================================
%! %% operator *
%! %% =======================================================
%! %% sc x sc 
%!test __ga__ ("*", g (d,[1,1]), rand (1));
%!test __ga__ ("*", g (d,[1,1]), rand (1)+i*rand (1));
%!test __ga__ ("*", rand (1), g (d,[1,1]));
%!test __ga__ ("*", rand (1)+i*rand (1), g (1,[1,1]));
%!test __ga__ ("*", g (d,[1,1]), g (d,[1,1]));
%! %% sc x nd
%!test __ga__ ("*", g (d,[1,1]), rand ([3,4,5]));
%!test __ga__ ("*", g (d,[1,1]), rand ([3,4,5])+i*rand ([3,4,5]));
%!test __ga__ ("*", g (d,[1,1]), t=sprand (8,6,.5));
%!test __ga__ ("*", g (d,[1,1]), sprand (t)+i*sprand (t));
%!test __ga__ ("*", rand (1), g (d,[3,5,2]));
%!test __ga__ ("*", rand (1)+i*rand (1), g (d,[3,5,2]));
%!test __ga__ ("*", g (d,[1,1]), g (d,[4,5,2]));
%! %% nd x sc
%!test __ga__ ("*", g (d,[3,4,5]), rand (1));
%!test __ga__ ("*", g (d,[4,5,2]), rand (1)+i*rand (1));
%!test __ga__ ("*", rand ([3,4,5]), g (d,[1,1]));
%!test __ga__ ("*", rand ([4,5,2])+i*rand ([4,5,2]), g (d,[1,1]));
%!test __ga__ ("*", t=sprand (8,6,.5), g (d,[1,1]));
%!test __ga__ ("*", sprand (t)+i*sprand (t), g (d,[1,1]));
%!test __ga__ ("*", g (d,[4,5,2]), g (d,[1,1]));
%! %% mx x mx
%!test __ga__ ("*", g (d,[3,4]), rand ([4,2]));
%!test __ga__ ("*", g (d,[4,2]), rand ([2,3])+i*rand ([2,3]));
%!test __ga__ ("*", g (d,[8,6]), t=sprand (6,4,0.5));
%!test __ga__ ("*", g (d,[8,6]), sprand (t)+i*sprand (t));
%!test __ga__ ("*", rand ([3,4]), g (d,[4,2]));
%!test __ga__ ("*", rand ([4,2])+i*rand ([4,2]), g (d,[2,3]));
%!test __ga__ ("*", t=sprand (8,6,.5), g (d,[6,4]));
%!test __ga__ ("*", sprand (t)+i*sprand (t), g (d,[6,4]));
%!test __ga__ ("*", g (d,[4,3]), g (d,[3,2]));
%! %% op matching
%!fail ("g (d,[3,2]) * g (d+1,[2,4])", "number of derivatives");
%! %% =======================================================
%! %% operator \
%! %% =======================================================
%! %% sc x sc 
%!test __ga__ ("\\", g (d,[1,1]), rand (1));
%!test __ga__ ("\\", g (d,[1,1]), rand (1)+i*rand (1));
%!test __ga__ ("\\", rand (1)+.1, g (d,[1,1]));
%!test __ga__ ("\\", rand (1)+i*rand (1)+.1, g (1,[1,1]));
%!test __ga__ ("\\", g (d,[1,1]), g (d,[1,1]));
%! %% sc x nd
%!test __ga__ ("\\", g (d,[1,1]), rand ([3,4,5]));
%!test __ga__ ("\\", g (d,[1,1]), rand ([3,4,5])+i*rand ([3,4,5]));
%!test __ga__ ("\\", g (d,[1,1]), t=sprand (8,6,.5));
%!test __ga__ ("\\", g (d,[1,1]), sprand (t)+i*sprand (t));
%!test __ga__ ("\\", rand (1)+.1, g (d,[3,5,2]));
%!test __ga__ ("\\", rand (1)+i*rand (1)+.1, g (d,[3,5,2]));
%!test __ga__ ("\\", g (d,[1,1]), g (d,[4,5,2]));
%! %% nd x sc (not supported by octave 2.9.19, though matlab does ...)
%! %% mx x mx (regular case)
%!test __ga__ ("\\", g (d,[4,4]), rand ([4,3]));
%!test __ga__ ("\\", g (d,[4,4]), rand ([4,2])+i*rand ([4,2]));
%!test __ga__ ("\\", g (d,[3,3]), t=sprand (3,4,0.6));
%!test __ga__ ("\\", g (d,[3,3]), sprand (t)+i*sprand (t));
%!test __ga__ ("\\", rand ([4,4]), g (d,[4,2]));
%!test __ga__ ("\\", rand ([4,4])+i*rand ([4,4]), g (d,[4,2]));
%!test __ga__ ("\\", sparse (rand ([3,3])), g (d,[3,4]));
%!test __ga__ ("\\", sparse (rand ([3,3])+i*rand ([3,3])), g (d,[3,4]));
%!test __ga__ ("\\", g (d,[4,4]), g (d,[4,2]));
%! %% mx x mx (overdetermined case)
%!test __ga__ ("\\", g (d,[4,2]), rand ([4,3]));
%!test __ga__ ("\\", g (d,[4,2]), rand ([4,2])+i*rand ([4,2]));
%!test __ga__ ("\\", g (d,[3,2]), t=sprand (3,4,0.6));
%!test __ga__ ("\\", g (d,[3,2]), sprand (t)+i*sprand (t));
%!test __ga__ ("\\", rand ([4,2]), g (d,[4,3]));
%!test __ga__ ("\\", rand ([4,2])+i*rand ([4,2]), g (d,[4,3]));
%!test __ga__ ("\\", sparse (rand ([3,2])), g (d,[3,4]));
%!test __ga__ ("\\", sparse (rand ([3,2])+i*rand ([3,2])), g (d,[3,4]));
%!test __ga__ ("\\", g (d,[4,3]), g (d,[4,2]));
%! %% mx x mx (underdetermined case)
%!test __ga__ ("\\", g (d,[2,4]), rand ([2,3]));
%!test __ga__ ("\\", g (d,[2,4]), rand ([2,3])+i*rand ([2,3]));
%!test __ga__ ("\\", g (d,[2,3]), t=sprand (2,4,0.6));
%!test __ga__ ("\\", g (d,[2,3]), sprand (t)+i*sprand (t));
%!test __ga__ ("\\", rand ([2,4]), g (d,[2,3]));
%!test __ga__ ("\\", rand ([2,4])+i*rand ([2,4]), g (d,[2,3]));
%!test __ga__ ("\\", sparse (rand ([2,3])), g (d,[2,4]));
%!test __ga__ ("\\", sparse (rand ([2,3])+i*rand ([2,3])), g (d,[2,4]));
%!test __ga__ ("\\", g (d,[2,4]), g (d,[2,3]));
%! %% op matching
%!fail ("g (d,[3,3]) \\ g (d+1,[3,4])", "number of derivatives");
%! %% =======================================================
%! %% operator /
%! %% =======================================================
%! %% sc x sc 
%!test __ga__ ("/", g (d,[1,1]), rand (1));
%!test __ga__ ("/", g (d,[1,1]), rand (1)+i*rand (1));
%!test __ga__ ("/", rand (1)+.1, g (d,[1,1]));
%!test __ga__ ("/", rand (1)+i*rand (1)+.1, g (1,[1,1]));
%!test __ga__ ("/", g (d,[1,1]), g (d,[1,1]));
%! %% sc x nd (not supported by octave 2.9.19, though matlab does ...)
%! %% nd x sc
%!test __ga__ ("/", g (d,[3,4,5]), rand (1)+.1);
%!test __ga__ ("/", g (d,[4,5,2]), rand (1)+i*rand (1)+.1);
%!test __ga__ ("/", rand ([3,4,5]), g (d,[1,1]));
%!test __ga__ ("/", rand ([4,5,2])+i*rand ([4,5,2]), g (d,[1,1]));
%!test __ga__ ("/", t=sprand (8,6,.5), g (d,[1,1]));
%!test __ga__ ("/", sprand (t)+i*sprand (t), g (d,[1,1]));
%!test __ga__ ("/", g (d,[4,5,2]), g (d,[1,1]));
%! %% mx x mx (regular case)
%!test __ga__ ("/", g (d,[2,3]), rand ([3,3]));
%!test __ga__ ("/", g (d,[2,3]), rand ([3,3])+i*rand ([3,3]));
%!test __ga__ ("/", g (d,[2,4]), sparse (rand ([4,4])));
%!test __ga__ ("/", g (d,[2,4]), sparse (rand ([4,4])+i*rand ([4,4])));
%!test __ga__ ("/", rand ([2,3]), g (d,[3,3]));
%!test __ga__ ("/", rand ([2,3])+i*rand ([2,3]), g (d,[3,3]));
%!test __ga__ ("/", t=sprand (3,4,.6), g (d,[4,4]));
%!test __ga__ ("/", sprand (t)+i*sprand (t), g (d,[4,4]));
%!test __ga__ ("/", g (d,[4,3]), g (d,[3,3]));
%! %% mx x mx (overdetermined case)
%!test __ga__ ("/", g (d,[2,4]), rand ([3,4]));
%!test __ga__ ("/", g (d,[2,4]), rand ([3,4])+i*rand ([3,4]));
%!test __ga__ ("/", g (d,[3,4]), sparse (rand ([2,4])));
%!test __ga__ ("/", g (d,[3,4]), sparse (rand ([2,4])+i*rand([2,4])));
%!test __ga__ ("/", rand ([2,4]), g (d,[3,4]));
%!test __ga__ ("/", rand ([2,4])+i*rand ([2,4]), g (d,[3,4]));
%!test __ga__ ("/", t=sprand (3,4,.6), g (d,[2,4]));
%!test __ga__ ("/", sprand (t)+i*sprand (t), g (d,[2,4]));
%!test __ga__ ("/", g (d,[2,4]), g (d,[3,4]));
%! %% mx x mx (underdetermined case)
%!test __ga__ ("/", g (d,[2,3]), rand ([4,3]));
%!test __ga__ ("/", g (d,[2,3]), rand ([4,3])+i*rand ([4,3]));
%!test __ga__ ("/", g (d,[2,3]), sparse (rand ([5,3])));
%!test __ga__ ("/", g (d,[2,3]), sparse (rand ([5,3])+i*rand ([5,3])));
%!test __ga__ ("/", rand ([6,3]), g (d,[4,3]));
%!test __ga__ ("/", rand ([2,3])+i*rand ([2,3]), g (d,[4,3]));
%!test __ga__ ("/", t=sprand (6,3,.6), g (d,[4,3]));
%!test __ga__ ("/", sprand(t)+i*sprand (t), g (d,[5,3]));
%!test __ga__ ("/", g (d,[2,3]), g (d,[4,3]));
%! %% op matching
%!fail ("g (d,[2,3]) / g (d+1,[3,3])", "number of derivatives");
%! %% =======================================================
%! %% operator ^
%! %% =======================================================
%! %% sc x sc 
%!test __ga__ ("^", g (d,[1,1]), rand (1));
%!test __ga__ ("^", g (d,[1,1]), rand (1)+i*rand (1));
%!test __ga__ ("^", rand (1)+.1, g (d,[1,1]));
%!test __ga__ ("^", rand (1)+i*rand (1)+.1, g (1,[1,1]));
%!test __ga__ ("^", g (d,[1,1]), g (d,[1,1]));
%! %% mx x sc
%!test __ga__ ("^", g (d,[2,2]), 5);
%! %% op-matching
%!fail ("g (d,[3,2]) ^ 4", "square");
%!fail ("g (d,[2,2]) ^ (-2)", "non-negative");
%!fail ("g (d,[2,2]) ^ 3.1", "integer");
%!fail ("g (d,[2,2]) ^ (3+i)", "integer");
%!fail ("g (d,[1,1]) ^ g (d+1,[1,1])", "number of derivatives");
%! %% =======================================================
%! %% mappers etc...
%! %% =======================================================
%!test __ga__ ("acos", g (d,[1,1]));
%!test __ga__ ("acos", g (d,[3,4,2]));
%!test __ga__ ("acosh", g (d,[1,1]));
%!test __ga__ ("acosh", g (d,[3,4,2]));
%!test __ga__ ("asin", g (d,[1,1]));
%!test __ga__ ("asin", g (d,[3,4,2]));
%!test __ga__ ("asinh", g (d,[1,1]));
%!test __ga__ ("asinh", g (d,[3,4,2]));
%!test __ga__ ("atan", g (d,[1,1]));
%!test __ga__ ("atan", g (d,[3,4,2]));
%!test __ga__ ("atanh", g (d,[1,1]));
%!test __ga__ ("atanh", g (d,[3,4,2]));
%!test __ga__ ("cos", g (d,[1,1]));
%!test __ga__ ("cos", g (d,[3,4,2]));
%!test __ga__ ("exp", g (d,[1,1]));
%!test __ga__ ("exp", g (d,[3,4,2]));
%!test __ga__ ("log", g (d,[1,1]));
%!test __ga__ ("log", g (d,[3,4,2]));
%!test __ga__ ("sin", g (d,[1,1]));
%!test __ga__ ("sin", g (d,[3,4,2]));
%!test __ga__ ("sqrt", g (d,[1,1]));
%!test __ga__ ("sqrt", g (d,[3,4,2]));
%!test __ga__ ("tan", g (d,[1,1]));
%!test __ga__ ("tan", g (d,[3,4,2]));
