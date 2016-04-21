## Copyright (C) 2004-2011 David Legland <david.legland@grignon.inra.fr>
## Copyright (C) 2004-2011 INRA - CEPIA Nantes - MIAJ (Jouy-en-Josas)
## Copyright (C) 2012 Adapted to Octave by Juan Pablo Carbajal <carbajal@ifi.uzh.ch>
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

## -*- texinfo -*-
## @deftypefn {Function File} drawLabels (@var{x}, @var{y}, @var{lbl})
## @deftypefnx {Function File} drawLabels (@var{pos}, @var{lbl})
## @deftypefnx {Function File} drawLabels (@dots{}, @var{numbers}, @var{format})
## Draw labels at specified positions.
##   
##   DRAWLABELS(X, Y, LBL) draw labels LBL at position X and Y.
##   LBL can be either a string array, or a number array. In this case,
##   string are created by using sprintf function, with '#.2f' mask.
##
##   DRAWLABELS(POS, LBL) draw labels LBL at position specified by POS,
##   where POS is a N*2 int array.
##
##   DRAWLABELS(..., NUMBERS, FORMAT) create labels using sprintf function,
##   with the mask given by FORMAT (e. g. '#03d' or '5.3f'), and the
##   corresponding values.
## @end deftypefn

function varargout = drawLabels(varargin)

  # check if enough inputs are given
  if isempty(varargin)
      error('wrong number of arguments in drawLabels');
  end

  # process input parameters
  var = varargin{1};
  if size(var, 2)==1
      if length(varargin)<3
          error('wrong number of arguments in drawLabels');
      end
      px  = var;
      py  = varargin{2};
      lbl = varargin{3};
      varargin(1:3) = [];
  else
      if length(varargin)<2
          error('wrong number of arguments in drawLabels');
      end
      px  = var(:,1);
      py  = var(:,2);
      lbl = varargin{2};
      varargin(1:2) = [];
  end

  format = '%.2f';
  if ~isempty(varargin)
      format = varargin{1};
  end
  if size(format, 1)==1 && size(px, 1)>1
      format = repmat(format, size(px, 1), 1);
  end

  labels = cell(length(px), 1);
  if isnumeric(lbl)
      for i=1:length(px)
          labels{i} = sprintf(format(i,:), lbl(i));
      end
  elseif ischar(lbl)
      for i=1:length(px)
          labels{i} = lbl(i,:);
      end
  elseif iscell(lbl)
      labels = lbl;
  end
  labels = char(labels);

  h = text(px, py, labels);

  if nargout>0
      varargout{1}=h;
  end

endfunction

