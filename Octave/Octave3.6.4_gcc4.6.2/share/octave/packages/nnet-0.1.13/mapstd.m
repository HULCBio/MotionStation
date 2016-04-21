## Copyright (C) 2009 Luiz Angelo Daros de Luca <luizluca@gmail.com>
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
## @deftypefn {Function File} [@var{YY},@var{PS}] = mapstd (@var{XX},@var{ymean},@var{ystd})
## Map values to mean 0 and standard derivation to 1.
##
## @example
## [YY,PS] = mapstd(XX,ymean,ystd)
##
##    Apply the conversion and returns YY as (YY-ymean)/ystd.
##
## [YY,PS] = mapstd(XX,FP)
##
##    Apply the conversion but using an struct to inform target mean/stddev.
##    This is the same of [YY,PS]=mapstd(XX,FP.ymean, FP.ystd).
##
## YY = mapstd('apply',XX,PS)
##
##    Reapply the conversion based on a previous operation data.
##    PS stores the mean and stddev of the first XX used.
##
## XX = mapstd('reverse',YY,PS)
##
##    Reverse a conversion of a previous applied operation.
##
## dx_dy = mapstd('dx',XX,YY,PS)
##
##    Returns the derivative of Y with respect to X.
##
## dx_dy = mapstd('dx',XX,[],PS)
##
##    Returns the derivative (less efficient).
##
## name = mapstd('name');
##
##    Returns the name of this convesion process.
##
## FP = mapstd('pdefaults');
##
##    Returns the default process parameters.
##
## names = mapstd('pnames');
##
##    Returns the description of the process parameters.
##
## mapstd('pcheck',FP);
##
##    Raises an error if FP has some inconsistent.
## @end example
##
## @end deftypefn

function [out1,out2]=mapstd(in1,in2,in3,in4)
  #
  # Map values to mean 0 and standard derivation to 1.
  #
  # [YY,PS] = mapstd(XX,ymean,ystd)
  #
  #    Apply the conversion and returns YY as (YY-ymean)/ystd.
  #
  # [YY,PS] = mapstd(XX,FP)
  #
  #    Apply the conversion but using an struct to inform target mean/stddev.
  #    This is the same of [YY,PS]=mapstd(XX,FP.ymean, FP.ystd).
  #
  # YY = mapstd('apply',XX,PS)
  #
  #    Reapply the conversion based on a previous operation data.
  #    PS stores the mean and stddev of the first XX used.
  #
  # XX = mapstd('reverse',YY,PS)
  #
  #    Reverse a conversion of a previous applied operation.
  #
  # dx_dy = mapstd('dx',XX,YY,PS)
  #
  #    Returns the derivative of Y with respect to X.
  #
  # dx_dy = mapstd('dx',XX,[],PS)
  #
  #    Returns the derivative (less efficient).
  #
  # name = mapstd('name');
  #
  #    Returns the name of this convesion process.
  #
  # FP = mapstd('pdefaults');
  #
  #    Returns the default process parameters.
  #
  # names = mapstd('pnames');
  #
  #    Returns the description of the process parameters.
  #
  # mapstd('pcheck',FP);
  #
  #    Raises an error if FP has some inconsistent.
  #

  if nargin==0
    error("Not enough arguments.")
  endif

  # Defaults
  ps.name="mapstd";
  ps.ymean=0;
  ps.ystd=1;

  if ischar(in1)
    switch in1
        case "name"
            if nargout>1
                error("Too many output arguments");
            endif
            if nargin>1
                error("Too many input arguments");
            endif
            out1="Map Mean and Standard Deviation";
            return;
        case "pdefaults"
            if nargout>1
                error("Too many output arguments");
            endif
            if nargin>1
                error("Too many input arguments");
            endif
            out1=ps;
        case "pcheck"
            if nargout>1
                error("Too many output arguments");
            endif
            if nargin<2
                error("Not enough input arguments");
            endif
            if nargin>2
                error("Too many input arguments");
            endif
            
            fp=in2;           
            if ~isstruct(fp)
                error("FP must be a struct")                
            elseif ~isfield(fp,"ymean")
                error("FP must include ymean field")
            elseif ~isfield(fp,"ystd")
                error("FP must include ystd field")
            elseif isdouble(fp.ymean)
                error("FP.ymean must be a real scalar value")
            elseif isdouble(fp.ystd)
                error("FP.ystd must be a real scalar value")
            else
                out1='';
            endif
            return;
        # MATLAB uses pnames but documents as pdesc (that does not work)
        case "pnames"
            if nargout>1
                error("Too many output arguments");
            endif
            if nargin>1
                error("Too many input arguments");
            endif
            # MATLAB seems to be buggy in the second element
            #out1={'Mean value for each row of Y.','Maximum value for each
            #row of Y.'};            
            out1={"Mean value for each row of Y.","Standart deviation value for each row of Y."};                        
        case "apply"
            if nargin<3
                error("Not enough input arguments");
            endif
            if nargin>3
                error("Too many input arguments");
            endif
            if nargout>1
                error("Too many output arguments");
            endif
            xx=in2;
            ps=in3;
            yy=apply(xx,ps);
            out1=yy;
            out2=ps;
            return;
        case "reverse"
            if nargin<3
                error("Not enough input arguments");
            endif
            if nargin>3
                error("Too many input arguments");
            endif
            if nargout>1
                error("Too many output arguments");
            endif
            yy=in2;
            ps=in3;
            xx=reverse(yy,ps);
            out1=xx;
            out2=ps;
            return;
        case "dx"
            if nargin<3
                error("Not enough input arguments");
            endif
            if nargin>3
                error("Too many input arguments");
            endif
            if nargout>1
                error("Too many output arguments");
            endif
            xx=in2;
            yy=in3;
            ps=in4;
            xx_yy=derivate(xx,yy,ps);
            out1=xx_yy;
            return;
    endswitch
  else
    xx=in1;
    ps.xrows=size(xx,1);
    ps.yrows=size(xx,1);
    ps.xmean=mean(xx,2);
    ps.xstd=std(xx,0,2);      
    
    if nargin==1
        # All correct
    elseif nargin==2
        if isstruct(in2)
            ps.ymean=in2.ymean;
            ps.ystd=in2.ystd;
        else
            ps.ymean=in2;
        endif
    elseif nargin == 3
        ps.ymean=in2;
        ps.ystd=in3;
    else
        error("Too many input arguments");
    endif
    
    out1=apply(xx,ps);   
    out2=ps;
  endif

  # Verify args
  function checkargs(values,ps)
    # check xx is matrix
    if ~isnumeric(values)
        error("Just numeric values are accepted")
    endif
    # check ps is struct
    if ~isstruct(ps)
        error("PS should be a struct")
    endif
    # check ymean,ystd
    if ~isa(ps.ymean,"double")
        error("PS.ymean should be a double")
    endif
    if ~isa(ps.ystd,"double")
        error("PS.ystd should be a double")
    endif
    if ~all(size(ps.ymean)==[1 1])
        error("PS.ymean should be a scalar")
    endif
    if ~all(size(ps.ystd)==[1 1])
        error("PS.ystd should be a scalar")
    endif
    # check xmean,ystd
    if ~isnumeric(ps.xmean)
        error("PS.xmean should be a numeric")
    endif
    if ~isnumeric(ps.xstd)
        error("PS.xstd should be a numeric")
    endif
    if ~all(size(ps.xmean)==size(ps.xstd))
        error("Size of PS.xmean and PS.xstd must match")
    endif
  endfunction

  # Apply the mapping operation
  function [yy]=apply(xx,ps)
    checkargs(xx,ps)

    if ~all(size(xx,1)==size(ps.xmean,1))
        error("Size of XX rows should match PS.xmean and PS.xstd")
    endif
    # Avoid multiply/division by zero
    ps.xstd(ps.xstd == 0) = 1;
    yy=(xx - (ps.xmean*ones(1,size(xx,2)))) ./ (ps.xstd*ones(1,size(xx,2)));
    yy=(yy + ps.ymean) .* ps.ystd;
  endfunction

  # Reverse the mapping operation
  function [xx]=reverse(yy,ps)
    checkargs(yy,ps)
    if ~all(size(yy,1)==size(ps.xmean,1))
        error("Size of YY rows should match PS.xmean and PS.xstd")
    endif
    # Avoid multiply/division by zero
    ps.xstd(ps.xstd == 0) = 1;
    yy=(yy ./ ps.ystd) - ps.ymean;
    xx=(yy .* (ps.xstd*ones(1,size(yy,2)))) + (ps.xmean*ones(1,size(yy,2)));
  endfunction

  # I don't know why this exists but matlab implements it
  function [dy_dx]=derivate(xx,yy,ps)
    checkargs(yy,ps)
    checkargs(xx,ps)

    cols = size(xx,2);
    diagonal = diag(ps.ystd ./ ps.xstd);
    dy_dx = diagonal(:,:,ones(1,cols));
  endfunction

#end

endfunction