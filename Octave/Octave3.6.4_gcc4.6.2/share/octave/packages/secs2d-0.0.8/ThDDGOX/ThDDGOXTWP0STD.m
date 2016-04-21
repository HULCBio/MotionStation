function x = ThDDGOXTWP0STD (imesh,Simesh,Sinodes,Sielements,idata)
  Nnodes    = columns(Simesh.p);
  Nelements = columns(Simesh.t);
  x = 1.5 * idata.up * ones(Nelements,1) ./ idata.vsatp^2;
endfunction

