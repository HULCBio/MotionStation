## y = _g_map (the_map, x)
function  y = _g_map (the_map, x)

if     isempty (the_map)

  y = x;

elseif ischar (the_map)

  if isvarname (the_map)	# Assume a function name

    y = feval (the_map, x);

  else				# Assume an expression like "x.*sin(x)"

    y = eval (the_map);
  end

elseif ismatrix (the_map) && rows (the_map) == 2 

  N = columns (the_map);
  y = interp1 (the_map(1,:), the_map(2,:), "linear", "extrap");
  y(x < the_map(1,1)) = the_map(2,1);
  y(x > the_map(1,N)) = the_map(2,N);

else
  printf ("Don't know what to do w/ map of type %s", typeinfo (the_map))
  whos the_map
  keyboard
end

  