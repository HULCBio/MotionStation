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
## @deftypefn {Function File} {@var{netoutput} =} sim (@var{net}, @var{mInput})
## @code{sim} is usuable to simulate a before defined neural network.
## @code{net} is created with newff(@dots{}) and @var{mInput} should be the
## corresponding input data set!
## @end deftypefn

## Author: Michel D. Schmid


## Comments: see in "A neural network toolbox for Octave User's Guide" [4]
##  for variable naming... there have inputs or targets only one letter,
## e.g. for inputs is written P. To write a program, this is stupid, you can't
##  search for 1 letter variable... that's why it is written here like Pp, or Tt
## instead only P or T.

function [netoutput] = sim(net,mInput)

  ## check range of input arguments
  error(nargchk(2,2,nargin))

  ## check input args
  ## check "net", must be a net structure
  if !__checknetstruct(net)
    error("Structure doesn't seem to be a neural network")
  endif
  ## check "mInput", must have defined size
  [nRows, nColumns] = size(mInput);
  if (nRows != net.inputs{1}.size)
    error(["Simulation input data must have: " num2str(net.inputs{1}.size) " rows."])
  endif

  ## first get weights...
  IW = net.IW{1};
  b1 = net.b{1};
  b1 = repmat(b1,1,size(mInput,2));
  nLoops = net.numLayers;
  for i=1:nLoops

    trf = net.layers{i}.transferFcn;
    ## calculate the outputs for each layer from input to output

    if i==1
      Nn{i,1} = IW*mInput + b1;
    else
      LWx = net.LW{i,i-1};
      bx = net.b{i};
      bx = repmat(bx,1,size(Aa{i-1,1},2));
      Nn{i,1} = LWx*Aa{i-1,1} + bx;
    endif

    switch(trf)
      case "tansig"
        Aa{i,1} = tansig(Nn{i,1});
      case "purelin"
        Aa{i,1} = purelin(Nn{i,1});
      case "logsig"
        Aa{i,1} = logsig(Nn{i,1});
      otherwise
        error(["sim:Unknown transfer fucntion: " trf "!"]);
    endswitch
  endfor

  netoutput = Aa{i,1};

endfunction

