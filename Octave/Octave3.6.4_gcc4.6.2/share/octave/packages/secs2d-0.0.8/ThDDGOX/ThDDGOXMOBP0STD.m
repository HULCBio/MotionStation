function x = ThDDGOXMOBP0STD (imesh,Simesh,Sinodes,Sielements,idata)
  Nnodes    = columns(Simesh.p);
  Nelements = columns(Simesh.t);
  x = idata.up * ones(Nelements,1);
endfunction

