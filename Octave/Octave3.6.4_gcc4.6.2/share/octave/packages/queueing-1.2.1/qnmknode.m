## Copyright (C) 2008, 2009, 2010, 2011, 2012 Moreno Marzolla
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
## @deftypefn {Function File} {@var{Q} =} qnmknode (@var{"m/m/m-fcfs"}, @var{S})
## @deftypefnx {Function File} {@var{Q} =} qnmknode (@var{"m/m/m-fcfs"}, @var{S}, @var{m})
## @deftypefnx {Function File} {@var{Q} =} qnmknode (@var{"m/m/1-lcfs-pr"}, @var{S})
## @deftypefnx {Function File} {@var{Q} =} qnmknode (@var{"-/g/1-ps"}, @var{S})
## @deftypefnx {Function File} {@var{Q} =} qnmknode (@var{"-/g/1-ps"}, @var{S}, @var{s2})
## @deftypefnx {Function File} {@var{Q} =} qnmknode (@var{"-/g/inf"}, @var{S})
## @deftypefnx {Function File} {@var{Q} =} qnmknode (@var{"-/g/inf"}, @var{S}, @var{s2})
##
## Creates a node; this function can be used together with
## @code{qnsolve}. It is possible to create either single-class nodes
## (where there is only one customer class), or multiple-class nodes
## (where the service time is given per-class). Furthermore, it is
## possible to specify load-dependent service times.
##
## @strong{INPUTS}
##
## @table @var
##
## @item S
## Mean service time.
##
## @itemize
##
## @item If @math{S} is a scalar,
## it is assumed to be a load-independent, class-independent service time.
##
## @item If @math{S} is a column vector, then @code{@var{S}(c)} is assumed to
## the the load-independent service time for class @math{c} customers.
##
## @item If @math{S} is a row vector, then @code{@var{S}(n)} is assumed to be
## the class-independent service time at the node, when there are @math{n}
## requests. 
##
## @item Finally, if @var{S} is a two-dimensional matrix, then
## @code{@var{S}(c,n)} is assumed to be the class @math{c} service time
## when there are @math{n} requests at the node.
##
## @end itemize
##
## @item m
## Number of identical servers at the node. Default is @code{@var{m}=1}.
##
## @item s2
## Squared coefficient of variation for the service time. Default is 1.0.
##
## @end table
##
## The returned struct @var{Q} should be considered opaque to the client.
##
## @c The returned struct @var{Q} has the following fields:
##
## @c @table @var
##
## @c @item Q.node
## @c (String) type of the node; valid values are @code{"m/m/m-fcfs"}, 
## @c @code{"-/g/1-lcfs-pr"}, @code{"-/g/1-ps"} (Processor-Sharing) 
## @c and @code{"-/g/inf"} (Infinite Server, or delay center).
##
## @c @item Q.S
## @c Average service time. If @code{@var{Q}.S} is a vector, then
## @c @code{@var{Q}.S(i)} is the average service time at that node
## @c if there are @math{i} requests.
##
## @c @item Q.m
## @c Number of identical servers at a @code{"m/m/m-fcfs"}. Default is 1.
##
## @c @item Q.c
## @c Number of customer classes. Default is 1.
##
## @c @end table
##
## @seealso{qnsolve}
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function Q = qnmknode( node, S, varargin )

  ischar(node) || \
      error( "Parameter \"node\" must be a string" );

  node = tolower(node);

  isvector(S) || ismatrix(S) || \
      error( "Parameter \"S\" must be a vector" );
  m = 1;
  s2 = ones( size(S) );
  if ( strcmp(node, "m/m/m-fcfs") )
    ## M/M/k multiserver node
    if ( nargin > 3 )
      print_usage();
    endif
    if ( 3 == nargin )
      m = varargin{1};
    endif
  elseif ( strcmp(node, "m/m/1/k-fcfs") )
    ## M/M/1/k finite capacity node
    if ( nargin > 3 )
      print_usage();
    endif
    if ( 3 == nargin )
      k = varargin{1};
    endif
  elseif ( strcmp(node, "-/g/1-lcfs-pr") )
    ## -/G/1-LCFS-PR node
    ( 2 == nargin || 3 == nargin ) || \
	print_usage();
    if ( 3 == nargin ) 
      s2 = varargin{1};
    endif
  elseif ( strcmp(node, "-/g/1-ps") )
    ## -/G/1-PS (processor sharing) node
    ( 2 == nargin || 3 == nargin ) || \
	print_usage();
    if ( 3 == nargin )
      s2 = varargin{1};
    endif
  elseif ( strcmp(node, "-/g/inf") )
    ## -/G/inf (Infinite Server) node
    ( 2 == nargin || 3 == nargin ) || \
	print_usage();
    if ( 3 == nargin )
      s2 = varargin{1};
    endif
  else
    error( "Unknown node type \"%s\". node type must be one of \"m/m/m-fcfs\", \"-/g/1-lcfs-pr\", \"-/g/1-ps\" and \"-/g/inf\"", node );
  endif
  ( isnumeric(m) && m>=1 ) || \
      error("m must be >=1");
  ( isnumeric(s2) && s2>= 0 ) || \
      error("s2 must be >=0");
  Q = struct( "node", node, "m", m, "S", S, "s2", s2, "c", rows(S), "comment", "" );
endfunction
%!test
%! fail( "qnmknode( 'pippo', 1 )", "must be one" );
%! fail( "qnmknode( '-/g/1-ps', 1, 1, 1)", "Invalid call" );
