function nvol = cquadnd (fun,lowerlim,upperlim,nquad)
%usage:  nvol = cquadnd (fun,lowerlim,upperlim,nquad);
%	n	-- number of dimensions to integrate
%	nvol	-- value of the n-dimensional integral
%	fun	-- fun(x) (function to be integrated) in this case treat
%                  all the different values of x as different variables
%                  as opposed to different instances of the same variable
%	x	-- n length vector of coordinates
%	lowerlim-- n length vector of lower limits of integration
%	upperlim-- n length vector of upper limits of integration
%	nquad	-- n length vector of number of gauss points 
%		   in each integration

n=length(lowerlim);
level=n;
x=zeros(n,1);

nvol = innerfun(fun,lowerlim,upperlim,nquad,n,level,x,'crule');

endfunction
