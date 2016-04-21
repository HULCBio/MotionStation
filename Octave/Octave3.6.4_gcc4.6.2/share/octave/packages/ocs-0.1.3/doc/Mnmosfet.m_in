function [a,b,c]=Mnmosfet...
  (string,parameters,parameternames,extvar,intvar,t) 
  
  ##  [a,b,c]=Mnmosfet...
  ##  (string,parameters,parameternames,extvar,intvar,t)

  switch string
    case 'simple',
      
      rd = 1e6;
      
      for ii=1:length(parameternames)
	eval([parameternames{ii} "=",...
	      num2str(parameters(ii)) " ;"])	
      end

      vg   = extvar(1);
      vs   = extvar(2);
      vd   = extvar(3);
      vb   = extvar(4);

      vgs  = vg-vs;
      vds  = vd-vs;
      
      if (vgs < Vth)

	
	gm = 0;
	gd = 1/rd;
	id = vds*gd;
	
      elseif ((vgs-Vth)>=(vds))&(vds>=0)
	
	id = k*((vgs-Vth)*vds-(vds^2)/2)+vds/rd;
	gm = k*vds;
	gd = k*(vgs-Vth-vds)+1/rd;

      elseif ((vgs-Vth)>=(vds))&(vds<0)
	
	gm = 0;
	gd = 1/rd;
	id = vds*gd;

      else # (i.e. if 0 <= vgs-vth <= vds)

	id = k*(vgs-Vth)^2/2+vds/rd;
	gm = k*(vgs-Vth);
	gd = 1/rd;

      end
      a = zeros(4);
      
      b = [0    0       0 0;
	   -gm  (gm+gd) -gd 0; 
	   gm -(gm+gd)  gd 0;
	   0    0       0  0];
      
      c = [0 -id id 0]';
      break;
    otherwise
      error(["unknown option:" string]);
  end 
