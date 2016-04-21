### Copyright (c) 2007, Tyzx Corporation. All rights reserved.
function val_str = _g_stringify (name, value)

  ## Use double quotes rather than simple quote, so that newlines are recognized
  ## as such
  if ischar (value), 
    if index (name, "range")
      val_str = value; 
    else
      val_str = ["\"",value,"\""]; 
    endif
    return;
  end
  switch name
    case {"xrange", "yrange", "x2range", "y2range", "range"}
      if prod (size (value)) != 2
	error ("Argument to %s should have size 2",name); 
      endif
      val_str = sprintf ("[%g:%g]", value);
      val_str = strrep (val_str, "NaN","*");
      val_str = strrep (val_str, "Inf","*");
    case "geometry"
      if prod (size (value)) != 2
	error ("Argument to %s should have size 2",name); 
      endif
      val_str = sprintf ("%ix%i", value);
    otherwise
      error ("Unknown argument to stringify '%s'", name);
  endswitch
endfunction
