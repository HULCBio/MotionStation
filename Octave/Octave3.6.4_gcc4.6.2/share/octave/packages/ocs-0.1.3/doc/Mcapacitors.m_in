function [a,b,c] =...
      Mcapacitors(string,parameters,parameternames,extvar,intvar,t)
  
  ## Mcapacitors(string,parameters,parameternames,extvar,intvar,t)

if isempty(intvar)
	intvar = 0;
end

  switch string 
      
    case "LIN"
      for ii=1:length(parameternames)
	eval([parameternames{ii} "=" num2str(parameters(ii)) ";"])	
      end
      
      q = intvar(1);
      
      a = [0 0 1; 0 0 -1; 0 0 0];
      b = [0 0 0;0 0 0;C -C -1];
      c = [0 0 0]';
      break
    otherwise
      error (["unknown section:" string])
  end
