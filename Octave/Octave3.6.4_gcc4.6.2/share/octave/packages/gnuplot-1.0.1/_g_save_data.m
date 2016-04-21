### Copyright (c) 2007, Tyzx Corporation. All rights reserved.

function _g_save_data (filename, data, stops, labels)

  [R,C] = size (data);
  if nargin<3,        stops = R; endif
  if nargin<4,        labels = 0; endif
  if isempty(stops),  stops = R; endif
  if stops(1)!=0,     stops = [0, stops(:)']; endif
  if stops(end) != R, stops = [stops(:)', R]; endif

  ## ndecimals = max (1,                                          \
  ##		   ceil (    abs(log10 (max (abs (data(:)))))  \
  ##			 + 4*abs(log10 (min (std (data))))     \
  ##			 ));
  ndecimals = 18;
  tpl = ["%.",sprintf("%ig ",ndecimals)];
  tpl = char (kron (ones(1,C),toascii (tpl)));
  if !iscell (labels) && labels, 
    tpl =  [tpl, " %i"];
    data = [data, (1:R)'];
    C++;
  end
  tpl0 = tpl;
  tpl =  [tpl, "\n"];

  no_text_labels = ! iscell (labels) || isempty (labels);

  if ! no_text_labels
    for j = 1:length(labels)
      if isnumeric (labels{j})
	if abs (labels{j} - round (labels{j})) < eps
	  labels{j} = sprintf ("%i", labels{j});
	else
	  labels{j} = sprintf ("%g", labels{j});
	end
      end
    endfor
  endif

  [fid, msg] = fopen (filename,"w");
  if fid<0, 
    error ("Can't open data file '%s': %s", filename, msg); 
  endif

  for i = 2:length(stops)
    if no_text_labels
      fprintf (fid, tpl, data(stops(i-1)+1:stops(i),:)');
    else
      for j = stops(i-1)+1:stops(i)
	fprintf (fid, tpl0, data(j,:)');
	fprintf (fid, " ");
	j_label = 1 + rem (j-1, length (labels));
	fprintf (fid, ['"', labels{j_label}, '"']);
	fprintf (fid, "\n");
      endfor
    end
    fprintf (fid, "\n");
  endfor

  if fclose (fid)
    error ("Can't close data file '%s': %s", filename); 
  endif
endfunction
