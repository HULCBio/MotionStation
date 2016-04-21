### Copyright (c) 2007-, Tyzx Corporation. All rights reserved.

### [isFmt, fmtContents, labelFmt] = _g_parse_oct_fmt (FMT, plotn, wantLabel)
###
### Take a string FMT, e.g. "-5;Foobar;", in octave's plot (x,y,FMT) format and
### tries to translate it into fmtContents, a gnuplot string like 
###
###     "with lines linetype 5 title 'Foobar'".
##
### isFmt is 1 if FMT makes sense in octave's plot syntax, 0 otherwise.
###
### If the wantLabel is true, or if the "format" part of FMT ("-5", in the
### example above) contains a "#", then labelFmt will hold a gnuplot string that
### plots a label with each data point.
function [isFmt, fmtContents, labelFmt] = _g_parse_oct_fmt (str,plotn, wantLabel)

  if nargin<2, plotn =     0; endif
  if nargin<3, wantLabel = 1; endif

  isFmt =        0; 
  defaultTitle = "";
  if plotn, defaultTitle = sprintf ("Line %i",plotn); endif

  fmtContents = sprintf ("with lines lt %i title '%s'", plotn, defaultTitle);

  labelFmt = "";
  if (iscell (wantLabel) && !isempty (wantLabel)) || (!iscell (wantLabel) && wantLabel)
    wantLabel = 1;
    labelFmt = sprintf ("with labels tc lt %i offset 0,1 notitle ", plotn);
  end

  if !ischar(str)
    return; 
  endif

  ## Matches style, color, key
  ##re = "^(\\.|@|-[@+*x]?|[L\\+\\*ox\\^]|)([1-6][1-6]?|[krgbmcw]|)(;[^;]*;|)$";
  re10 = "^(\\.|@|-[@\\+\\*xo]?|[L\\+\\*ox\\^]|)([#1-6krgbmcw][1-6]?|)";
  re11 = "^(with[^;]*)";
  re2 = "(;[^;]*;)$";
  ## re seems to fail on ';aaa;'
  ##[S, E, TE, M, T, NM] = regexp (str, re)

  style = "with lines lw 5 ";
  color = "";
  title = "title ''";
  ##pointstyle = ""; Unused

  T = regexp (str, re11, "tokens"); # Try gnuplot-like style
  if ! isempty (T)
    ## workaround for regexp's bug
    if ! isempty (T) && length (T{1}) == 1 
      T{1} = {"",T{1}{:}};
    end
    style = T{1}{2};
    color = "";
    title = "";
  else
    T = regexp (str, re10, "tokens");

    if !isempty (T)
      ## workaround for regexp's bug
      if ! isempty (T) && length (T{1}) == 1 
	T{1} = {"",T{1}{:}};
      end

      xt = " lw 3 ";
				# TODO: more correct way of dealing w/ T{1}{1}
      style0 = "lines";
      ##T{1}{1}
      if length (T{1}{1})		# Style
	switch T{1}{1}
	  case "-+", style0 = "linespoints"; xt = " pointtype 1 ";
	  case "-*", style0 = "linespoints"; xt = " pointtype 3 ";
	  case "-o", style0 = "linespoints"; xt = " pointtype 6 ";
	  case "-@", style0 = "linespoints"; xt = " pointtype 6 ";
	  case "^",  style0 = "impulses";    xt = "";
	  case "@",  style0 = "points";      xt = " pointtype 6 ";
	  case "*",  style0 = "points";      xt = " pointtype 3 ";
	  case "+",  style0 = "points";      xt = " pointtype 1 ";
	  case "x",  style0 = "points";      xt = " pointtype 2 ";
	  case "o",  style0 = "points";      xt = " pointtype 6 ";
	  case "-",  style0 = "lines";       xt = "";
	  case "L",  style0 = "steps";       xt = "";
	  case ".",  style0 = "dots";        xt = "";
	  otherwise  style0 = "lines";       xt = " lw 3 ";
	endswitch
      endif
      style = ["with ",style0, xt];
    
      if length (T{1}{2})		# Label wanted?
	if index (T{1}{2}, "#")
	  wantLabel = 1;
	  T{1}{2} = T{1}{2}(T{1}{2} != "#");
	end			# Now, there is no "#" in T{1}{2}, so T{1}{2}
				# should be color and/or point
      end				# 
      if length (T{1}{2})		# Color (and maybe pointstyle)
				# First character is color, as number or letter
	
	if index ("123456789", T{1}{2}(1))
	  color = T{1}{2}(1);
	else			# Convert letter to digit
	  color = struct(qw("k 6 r 1 g 2 b 3 m 4 c 5 w 7"){:}).(T{1}{2}(1));
	endif
	if length (T{1}{2}) > 1 && index ("123456789", T{1}{2}(2))
	  ## pointstyle = ["pt ",T{1}{2}(2)];
	endif
	if strcmp (style0, "lines")
	  color = ["ls ",color];
	else
	  color = ["lt ",color];
	end
      endif
    end				# EOF !isempty (T): Matlab-like style spec
  endif
  T = regexp (str, re2, "tokens");

  if !isempty (T)
    if length (T{1}{1})		# title (aka key, label)
      title = ["title '",T{1}{1}(2:end-1),"'"];
    endif
  endif
  ##fmtContents = [style," ",color," ",title," lw 3 "];
  fmtContents = [style," ",color," ",title];
  isFmt = 1;

  if iscell (wantLabel)
    wantLabel = ! isempty (wantLabel);
  end
  if wantLabel
    labelColor = "";
    if length (color)
      labelColor = [" tc ", color];
    end
    
    labelFmt = ["with labels ",labelColor," offset 0,1 notitle "];
  end

endfunction
