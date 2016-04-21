function [a,b,c] =...
      Mvoltagesources(string,parameters,parameternames,extvar,intvar,t)
  
  ## Mvoltagesources(string,parameters,parameternames,extvar,intvar,t)

if isempty(intvar)
	intvar = 0;
end

  switch string 
      
    case "DC"
      for ii=1:length(parameternames)
	eval([parameternames{ii} "=" num2str(parameters(ii)) ";"])	
      end
      
      j = intvar(1);
      
      a = zeros(3);
      b = [0 0 1;0 0 -1;1 -1 0];
      c = [0 0 -V];
      break
      
    case "sinwave"
      for ii=1:length(parameternames)
	eval([parameternames{ii} "=" num2str(parameters(ii)) ";"])	
      end
     
      DV = shift+Ampl * sin(2*pi*(t+delay)*f );
      j = intvar(1);
      
      a = zeros(3);
      b = [0 0 1;0 0 -1;1 -1 0];
      c = [0 0 -DV]' + b * [extvar;intvar];
      break
      
    case "squarewave"
      for ii=1:length(parameternames)
	eval([parameternames{ii} "=" num2str(parameters(ii)) ";"])	
      end
      
      if t<delay
	DV=low;
      else
	T = tlow+thigh;
	t = mod(t-delay,T);
	if t<tlow
	  DV = low;
	else
	  DV = high;
	end
      end
      j = intvar(1);
      
      a = zeros(3);
      b = [0 0 1;0 0 -1;1 -1 0];
      c = [0 0 -DV]' - b * [extvar;intvar];
      break
    otherwise
      error (["unknown section:" string])
  end
