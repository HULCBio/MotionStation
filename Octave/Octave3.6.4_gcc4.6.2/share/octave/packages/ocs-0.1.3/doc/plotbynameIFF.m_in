function plotbynameIFF(t,out,outstruct,namelist)

  ## plotbynameIFF(t,out,outstruct,namelist)
  
  nn = length(outstruct.namesn);

  for ip = 1:nn
    for in = 1:length(namelist)
      if strcmp(namelist{in},outstruct.namess{ip})
	plot(t,out(outstruct.namesn(ip),:),[";" outstruct.namess{ip} ";"]);
	hold on
      end
    end
  end
  
  hold off