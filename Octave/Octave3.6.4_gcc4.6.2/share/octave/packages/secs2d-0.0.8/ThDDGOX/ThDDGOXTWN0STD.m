function x = ThDDGOXTWN0STD (imesh,Simesh,Sinodes,Sielements,idata)
  Nnodes    = columns(Simesh.p);
  Nelements = columns(Simesh.t);
  x = 1.5 * idata.un * ones(Nelements,1) ./ idata.vsatn^2;
endfunction

