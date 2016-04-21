## Copyright (C) 2006 Michel D. Schmid  <michaelschmid@users.sourceforge.net>
##
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {}[@var{net}] = train (@var{MLPnet},@var{mInputN},@var{mOutput},@var{[]},@var{[]},@var{VV})
## A neural feed-forward network will be trained with @code{train}
##
## @example
## [net,tr,out,E] = train(MLPnet,mInputN,mOutput,[],[],VV);
## @end example
## @noindent
##
## @example
## left side arguments:
##   net: the trained network of the net structure @code{MLPnet}
## @end example
## @noindent
##
## @example
## right side arguments:
##   MLPnet : the untrained network, created with @code{newff}
##   mInputN: normalized input matrix
##   mOutput: output matrix (normalized or not)
##   []     : unused parameter
##   []     : unused parameter
##   VV     : validize structure
## @end example
## @end deftypefn

## @seealso{newff,prestd,trastd}

## Author: Michel D. Schmid

## Comments: see in "A neural network toolbox for Octave User's Guide" [4]
## for variable naming... there have inputs or targets only one letter,
## e.g. for inputs is P written. To write a program, this is stupid, you can't
## search for 1 letter variable... that's why it is written here like Pp, or Tt
## instead only P or T.

function [net] = train(net,Pp,Tt,notUsed1,notUsed2,VV)

  ## check range of input arguments
  error(nargchk(3,6,nargin))

  ## set defaults
  doValidation = 0;
  if nargin==6
    # doValidation=1;
    ## check if VV is in MATLAB(TM) notation
    [VV, doValidation] = checkVV(VV);
  endif

  ## check input args
  checkInputArgs(net,Pp,Tt)

  ## nargin ...
  switch(nargin)
  case 3
    [Pp,Tt] = trainArgs(net,Pp,Tt);
    VV = [];
  case 6
    [Pp,Tt] = trainArgs(net,Pp,Tt);
    if isempty(VV)
      VV = [];
    else
      if !isfield(VV,"Pp")
        error("VV.Pp must be defined or VV must be [].")
      endif
      if !isfield(VV,"Tt")
        error("VV.Tt must be defined or VV must be [].")
      endif
      [VV.Pp,VV.Tt] = trainArgs(net,VV.Pp,VV.Tt);
    endif
  otherwise
    error("train: impossible code execution in switch(nargin)")
  endswitch


  ## so now, let's start training the network
  ##===========================================

  ## first let's check if a train function is defined ...
  if isempty(net.trainFcn)
    error("train:net.trainFcn not defined")
  endif

  ## calculate input matrix Im
  [nRowsInputs, nColumnsInputs] = size(Pp);
  Im = ones(nRowsInputs,nColumnsInputs).*Pp{1,1};

  if (doValidation)
    [nRowsVal, nColumnsVal] = size(VV.Pp);
    VV.Im = ones(nRowsVal,nColumnsVal).*VV.Pp{1,1};
  endif

  ## make it MATLAB(TM) compatible
  nLayers = net.numLayers;
  Tt{nLayers,1} = Tt{1,1};
  Tt{1,1} = [];
  if (!isempty(VV))
    VV.Tt{nLayers,1} = VV.Tt{1,1};
    VV.Tt{1,1} = [];
  endif

  ## which training algorithm should be used
  switch(net.trainFcn)
    case "trainlm"
      if !strcmp(net.performFcn,"mse")
        error("Levenberg-Marquardt algorithm is defined with the MSE performance function, so please set MSE in NEWFF!")
      endif
      net = __trainlm(net,Im,Pp,Tt,VV);
    otherwise
      error("train algorithm argument is not valid!")
  endswitch


# =======================================================
#
# additional check functions...
#
# =======================================================

  function checkInputArgs(net,Pp,Tt)
      
    ## check "net", must be a net structure
    if !__checknetstruct(net)
      error("Structure doesn't seem to be a neural network!")
    endif

    ## check Pp (inputs)
    nInputSize = net.inputs{1}.size; #only one exists
    [nRowsPp, nColumnsPp] = size(Pp);
    if ( (nColumnsPp>0) )
      if ( nInputSize==nRowsPp )
      # seems to be everything i.o.
      else
        error("Number of rows must be the same, like in net.inputs.size defined!")
      endif
    else
      error("At least one column must exist")
    endif
    
    ## check Tt (targets)
    [nRowsTt, nColumnsTt] = size(Tt);
    if ( (nRowsTt | nColumnsTt)==0 )
      error("No targets defined!")
    elseif ( nColumnsTt!=nColumnsPp )
      error("Inputs and targets must have the same number of data sets (columns).")
    elseif ( net.layers{net.numLayers}.size!=nRowsTt )
      error("Defined number of output neurons are not identically to targets data sets!")
    endif

  endfunction
# -------------------------------------------------------
  function [Pp,Tt] = trainArgs(net,Pp,Tt);

    ## check number of arguments
    error(nargchk(3,3,nargin));

    [PpRows, PpColumns] = size(Pp);
    Pp = mat2cell(Pp,PpRows,PpColumns);    # mat2cell is the reason
    									   # why octave-2.9.5 doesn't work
										   # octave-2.9.x with x>=6 should be
										   # ok
    [TtRows, TtColumns] = size(Tt);
    Tt = mat2cell(Tt,TtRows,TtColumns);

  endfunction

# -------------------------------------------------------

  function [VV, doValidation] = checkVV(VV)

    ## check number of arguments
    error(nargchk(1,1,nargin));

	if (isempty(VV))	
	  doValidation = 0;	
	else
	  doValidation = 1;
      ## check if MATLAB(TM) naming convention is used
      if isfield(VV,"P")
        VV.Pp = VV.P;
        VV.P = [];
      elseif !isfield(VV,"Pp")
        error("VV is defined but inside exist no VV.P or VV.Pp")
      endif

      if isfield(VV,"T")
        VV.Tt = VV.T;
        VV.T = [];
      elseif !isfield(VV,"Tt")
        error("VV is defined but inside exist no VV.TP or VV.Tt")
      endif
	
	endif


  endfunction

# ============================================================

endfunction