## Copyright (C) 1999 Paul Kienzle
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
## @deftypefn {Function File} {[@var{y},@var{t},@var{scale}] = } auplot (@var{x})
## @deftypefnx {Function File} {[@var{y},@var{t},@var{scale}] = } auplot (@var{x},@var{fs})
## @deftypefnx {Function File} {[@var{y},@var{t},@var{scale}] = } auplot (@var{x},@var{fs},@var{offset})
## @deftypefnx {Function File} {[@var{y},@var{t},@var{scale}] = } auplot (@var{...},@var{plotstr})
##
## Plot the waveform data, displaying time on the @var{x} axis.  If you are
## plotting a slice from the middle of an array, you may want to specify
## the @var{offset} into the array to retain the appropriate time index. If
## the waveform contains multiple channels, then the data are scaled to
## the range [-1,1] and shifted so that they do not overlap. If a @var{plotstr}
## is given, it is passed as the third argument to the plot command. This 
## allows you to set the linestyle easily. @var{fs} defaults to 8000 Hz, and 
## @var{offset} defaults to 0 samples.
##
## Instead of plotting directly, you can ask for the returned processed 
## vectors. If @var{y} has multiple channels, the plot should have the y-range
## [-1 2*size(y,2)-1]. scale specifies how much the matrix was scaled
## so that each signal would fit in the specified range.
##
## Since speech samples can be very long, we need a way to plot them
## rapidly. For long signals, auplot windows the data and keeps the
## minimum and maximum values in the window.  Together, these values
## define the minimal polygon which contains the signal.  The number of
## points in the polygon is set with the global variable auplot_points.
## The polygon may be either 'filled' or 'outline', as set by the global
## variable auplot_format.  For moderately long data, the window does
## not contain enough points to draw an interesting polygon. In this
## case, simply choosing an arbitrary point from the window looks best.
## The global variable auplot_window sets the size of the window
## required for creating polygons.  You can turn off the polygons
## entirely by setting auplot_format to 'sampled'.  To turn off fast
## plotting entirely, set auplot_format to 'direct', or set
## auplot_points=1. There is no reason to do this since your screen
## resolution is limited and increasing the number of points plotted
## will not add any information.  auplot_format, auplot_points and
## auplot_window may be set in .octaverc.  By default auplot_format is
## 'outline', auplot_points=1000 and auplot_window=7.
## @end deftypefn

## 2000-03 Paul Kienzle
##     accept either row or column data
##     implement fast plotting
## 2000-04 Paul Kienzle
##     return signal and time vectors if asked

## TODO: test offset and plotstr
## TODO: convert offset to time range in the form used by au
## TODO: rename to au; if nargout return data within time range
## TODO:     otherwise plot the data
function [y_r, t_r, scale_r] = auplot(x, fs, offset, plotstr)

  global auplot_points=1000;
  global auplot_format="outline";
  global auplot_window=7;

  if nargin<1 || nargin>4
    usage("[y, t, scale] = auplot(x [, fs [, offset [, plotstr]]])");
  endif
  if nargin<2, fs = 8000; offset=0; plotstr = []; endif
  if nargin<3, offset=0; plotstr = []; endif
  if nargin<4, plotstr = []; endif
  if ischar(fs), plotstr=fs; fs=8000; endif
  if ischar(offset), plotstr=offset; offset=0; endif
  if isempty(plotstr), plotstr=";;"; endif
  

  if (size(x,1)<size(x,2)), x=x'; endif

  [samples, channels] = size(x);
  r = ceil(samples/auplot_points);
  c = floor(samples/r);
  hastail = (samples>c*r);

  if r==1 || strcmp(auplot_format,"direct")
    ## full plot
    t=[0:samples-1]*1000/fs;
    y=x;
  elseif r<auplot_window || strcmp(auplot_format,"sampled")
    ## sub-sampled plot
    y=x(1:r:samples,:);
    t=[0:size(y,1)-1]*1000*r/fs;
  elseif strcmp(auplot_format,"filled")
    ## filled plot
    if hastail
      t=zeros(2*(c+1),1);
      y=zeros(2*(c+1),channels);
      t(2*c+1)=t(2*c+2)=c*1000*r/fs;
    else
      t=zeros(2*c,1);
      y=zeros(2*c,channels);
    endif
    t(1:2:2*c) = t(2:2:2*c) = [0:c-1]*1000*r/fs;
    for chan=1:channels
      head=reshape(x(1:r*c,chan),r,c);
      y(1:2:2*c,chan) = max(head)';
      y(2:2:2*c,chan) = min(head)';
      if (hastail)
      	tail=x(r*c+1:samples,chan);
      	y(2*c+1,chan)=max(tail);
      	y(2*c+2,chan)=min(tail);
      endif
    endfor
  elseif strcmp(auplot_format,"outline")
    ## outline plot
    if hastail
      y=zeros(2*(c+1)+1,channels);
      t=[0:c]; 
    else 
      y=zeros(2*c+1,channels);
      t=[0:c-1]; 
    endif
    t=[t, fliplr(t), 0]*1000*r/fs;
    for chan=1:channels
      head=reshape(x(1:r*c,chan),r,c);
      if hastail
      	tail=x(r*c+1:samples,chan);
      	y(:,chan)=[max(head), max(tail), min(tail), \
		   fliplr(min(head)),  max(head(:,1))]';
      else
      	y(:,chan)=[max(head), fliplr(min(head)), max(head(:,1))]';
      endif
    endfor
  else
    error("auplot_format must be 'outline', 'filled', 'sampled' or 'direct'");
  endif

  t=t+offset*1000/fs;
  grid;
  if channels > 1
    scale = max(abs(y(:)));
    if (scale > 0) y=y/scale; endif
    for i=1:channels
      y(:,i) = y(:,i) + 2*(i-1);
    end
  else
    scale = 1;
  end

  if nargout >= 1, y_r = y; endif
  if nargout >= 2, t_r = t; endif
  if nargout >= 3, scale_r = scale; endif
  if nargout == 0
    if channels > 1
      unwind_protect ## protect plot state
      	ylabel(sprintf('signal scaled by %f', scale));
      	axis([min(t), max(t), -1, 2*channels-1]);
      	plot(t,y,plotstr);
      unwind_protect_cleanup
      	axis(); ylabel("");
      end_unwind_protect
    else
      plot(t,y,plotstr);
    end
  endif
end

%!demo
%! [x, fs] = auload(file_in_loadpath("sample.wav"));
%! subplot(211); title("single channel"); auplot(x,fs);
%! subplot(212); title("2 channels, x and 3x"); auplot([x, 3*x], fs);
%! oneplot(); title("");

%!demo
%! [x, fs] = auload(file_in_loadpath("sample.wav"));
%! global auplot_points; pts=auplot_points; 
%! global auplot_format; fmt=auplot_format;
%! auplot_points=300;
%! subplot(221); title("filled"); auplot_format="filled"; auplot(x,fs);
%! subplot(223); title("outline"); auplot_format="outline"; auplot(x,fs);
%! auplot_points=900;
%! subplot(222); title("sampled"); auplot_format="sampled"; auplot(x,fs);
%! subplot(224); title("direct"); auplot_format="direct"; auplot(x,fs);
%! auplot_format=fmt; auplot_points=pts; title(""); oneplot();

%!demo
%! [x, fs] = auload(file_in_loadpath("sample.wav"));
%! title("subrange example"); auplot(au(x,fs,300,450),fs)
%! title("");

%!error auplot
%!error auplot(1,2,3,4,5)
