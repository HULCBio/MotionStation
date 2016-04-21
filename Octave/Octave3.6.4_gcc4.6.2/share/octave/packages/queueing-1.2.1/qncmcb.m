## Copyright (C) 2012 Moreno Marzolla
##
## This file is part of the queueing toolbox.
##
## The queueing toolbox is free software: you can redistribute it and/or
## modify it under the terms of the GNU General Public License as
## published by the Free Software Foundation, either version 3 of the
## License, or (at your option) any later version.
##
## The queueing toolbox is distributed in the hope that it will be
## useful, but WITHOUT ANY WARRANTY; without even the implied warranty
## of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with the queueing toolbox. If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
##
## @deftypefn {Function File} {[@var{Xl}, @var{Xu}, @var{Rl}, @var{Ru}] =} qncmcb (@var{N}, @var{D})
## @deftypefnx {Function File} {[@var{Xl}, @var{Xu}, @var{Rl}, @var{Ru}] =} qncmcb (@var{N}, @var{S}, @var{V})
##
## @cindex multiclass network, closed
## @cindex closed multiclass network
## @cindex bounds, composite
## @cindex composite bounds
##
## Composite Bound (CB) on throughput and response time for closed multiclass networks.
##
## This function implements the Composite Bound Method described in T.
## Kerola, @cite{The Composite Bound Method (CBM) for Computing
## Throughput Bounds in Multiple Class Environments}, Technical Report
## CSD-TR-475, Purdue University, march 13, 1984 (revised august 27,
## 1984).
##
## @strong{INPUTS}
##
## @table @var
##
## @item N
## @code{@var{N}(c)} is the number of class @math{c} requests in the system.
##
## @item D
## @code{@var{D}(c, k)} is class @math{c} service demand
## at center @math{k} (@code{@var{S}(c,k) @geq{} 0}).
##
## @item S
## @code{@var{S}(c, k)} is the mean service time of class @math{c}
## requests at center @math{k} (@code{@var{S}(c,k) @geq{} 0}).
##
## @item V
## @code{@var{V}(c,k)} is the average number of visits of class @math{c}
## requests to center @math{k} (@code{@var{V}(c,k) @geq{} 0}).
##
## @end table
##
## @strong{OUTPUTS}
##
## @table @var
##
## @item Xl
## @itemx Xu
## Lower and upper class @math{c} throughput bounds.
##
## @item Rl
## @itemx Ru
## Lower and upper class @math{c} response time bounds.
##
## @end table
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function [Xl Xu Rl Ru] = qncmcb( varargin )

  if ( nargin < 2 || nargin > 3 )
    print_usage();
  endif

  [err N S V m Z] = qncmchkparam( varargin{:} );
  isempty(err) || error(err);

  all(m == 1) || \
      error("this function only supports single-server FCFS centers");

  all(Z == 0) || \
      error("this function does not support think time");

  [C K] = size(S);

  D = S .* V;

  [Xl] = qncmbsb(N, D);
  Xu = zeros(1,C);

  D_max = max(D,[],2)';
  for r=1:C # FIXME: vectorize this

    ## This is equation (13) from T. Kerola, The Composite Bound Method
    ## (CBM) for Computing Throughput Bounds in Multiple Class
    ## Environments, Technical Report CSD-TR-475, Purdue University,
    ## march 13, 1984 (revised august 27, 1984)
    ## http://docs.lib.purdue.edu/cgi/viewcontent.cgi?article=1394&context=cstech

    ## The only modification here is to apply also the upper bound
    ## 1/D_max(r), eveb though it seems redundant.

    s = (1:C != r); # boolean array
    tmp = (1 .- Xl(s)*D(s,:)) ./ D(r,:);
    Xu(r) = min([tmp 1/D_max(r)]);
  endfor

  Rl = N ./ Xu;
  Ru = N ./ Xl;
endfunction

%!demo
%! S = [10 7 5 4; \
%!      5  2 4 6];
%! NN=20;
%! Xl = Xu = Xmva = zeros(NN,2);
%! for n=1:NN
%!   N=[n,10];
%!   [a b] = qncmcb(N,S);
%!   Xl(n,:) = a; Xu(n,:) = b;
%!   [U R Q X] = qncmmva(N,S,ones(size(S)));
%!   Xmva(n,:) = X(:,1)';
%! endfor
%! subplot(2,1,1);
%! plot(1:NN,Xl(:,1),"linewidth", 2, 1:NN,Xu(:,1),"linewidth", 2, \
%!      1:NN,Xmva(:,1),";MVA;");
%! title("Class 1 throughput");
%! subplot(2,1,2);
%! plot(1:NN,Xl(:,2),"linewidth", 2, 1:NN,Xu(:,2), "linewidth", 2,\
%!      1:NN,Xmva(:,2),";MVA;");
%! title("Class 2 throughput");
%! xlabel("Number of class 1 requests");
