function [a,b,c] =...
      Minductors(string,parameters,parameternames,extvar,intvar,t)
  
  ## Minductors(string,parameters,parameternames,extvar,intvar,t)

if isempty(intvar)
	intvar = [0 0];
end

  switch string 
      
    case "LIN"
      for ii=1:length(parameternames)
	eval([parameternames{ii} "=" num2str(parameters(ii)) ";"])	
      end
      
      phi = intvar(1);
      jl  = intvar(2);

      a = [0 0 0 0; 0 0 0 0; 0 0 0 0; 0 0 0 -L];
      b = [0 0 -1 0; 0 0 0 1; 1 -1 -1 0; 0 0 1 0];
      c = [0 0 0 0]';
    otherwise
      error (["unknown section:" string])
  end
