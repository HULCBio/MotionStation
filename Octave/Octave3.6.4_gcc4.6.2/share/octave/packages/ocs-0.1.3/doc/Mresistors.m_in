function [a,b,c] =...
      Mresistors(string,parameters,parameternames,extvar,intvar,t)
  
  ## [a,b,c] =  Mresistors(string,parameters,parameternames,extvar,intvar,t)

  switch string 
      
    case "LIN"
      for ii=1:length(parameternames)
	eval([parameternames{ii} "=" num2str(parameters(ii)) ";"])	
      end
      
      vp = extvar(1);
      vm = extvar(2);
      
      a = zeros(2);
      b = [1 -1 ;-1 1]/R;
      c = -[0; 0];
      
      break
      
    otherwise
      
      error (["unknown section:" string])
      
  end
