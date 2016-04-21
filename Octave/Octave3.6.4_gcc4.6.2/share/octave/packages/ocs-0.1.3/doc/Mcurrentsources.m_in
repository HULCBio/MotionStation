function [a,b,c] =...
      Mcurrentsources(string,parameters,parameternames,extvar,intvar,t)
  
  ## [a,b,c] = ...
  ## Mcurrentsources(string,parameters,parameternames,extvar,intvar,t)
  
  switch string 
      
    case "DC"
      for ii=1:length(parameternames)
	eval([parameternames{ii} "=" num2str(parameters(ii)) ";"])	
      end
      
      a = zeros(2);
      b = a;
      c = [I -I]';
      break
      
    case "sinwave"
      for ii=1:length(parameternames)
	eval([parameternames{ii} "=" num2str(parameters(ii)) ";"])	
      end
      
      I = shift+Ampl * sin(2*pi*(t+delay)*f );
      a = zeros(2);
      b = a;
      c = [I -I]';
      break
    otherwise
      error (["unknown section:" string])
  end
