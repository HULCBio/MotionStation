## Copyright (C) 2012 Juan Pablo Carbajal <carbajal@ifi.uzh.ch>
## 
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
## 
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
## 
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {} function_name ()
## @end deftypefn

function varargout = subsref (obj, idx)

  persistent __method__ method4field typeNotImplemented
  if isempty(__method__)

    __method__ = struct();

    __method__.plot = @(o,varargin) plot (o, varargin{:});
    __method__.getpath = @(o,varargin) getpath (o, varargin{:});
    __method__.pathid = @(o,varargin) pathid(o,varargin{:});
    __method__.path2polygon = @(o,varargin) path2polygon (o, varargin{:});
    __method__.normalize = @(o,varargin) normalize (o, varargin{:});
    __method__.height = @(o,varargin) height(o, varargin{:});
    __method__.width = @(o,varargin) width(o,varargin{:});

    # Error strings
    method4field = "Class #s has no field #s. Use #s() for the method.";
    typeNotImplemented = "#s no implemented for class #s.";

  end

  if ( !strcmp (class (obj), 'svg') )
    error ("Object must be of the svg class but '#s' was used", class (obj) );
  elseif ( idx(1).type != '.' )
    error ("Invalid index for class #s", class (obj) );
  endif

  method = idx(1).subs;
  if ~isfield(__method__, method)
    error('Unknown method #s.',method);
  else
    fhandle = __method__.(method);
  end

  if strcmp(method,'normalize')
    warning("svg:Devel",["Not returning second output argument of #s" ...
                         " use method(obj) API to get it"],method);
  end

  if numel (idx) == 1 # can't access properties, only methods

    error (method4field, class (obj), method, method);

  end

  if strcmp (idx(2).type, '()')

    args = idx(2).subs;
    if isempty(args)
     out = fhandle (obj);
    else
      out = fhandle (obj, args{:});
    end

    varargout{1} = out;

  else

    error (typeNotImplemented,[method idx(2).type], class (obj));

  end

endfunction
