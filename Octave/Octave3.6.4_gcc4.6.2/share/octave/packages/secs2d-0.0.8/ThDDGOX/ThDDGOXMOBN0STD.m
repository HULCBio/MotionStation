function x = ThDDGOXMOBN0STD (imesh,Simesh,Sinodes,Sielements,idata)
  Nnodes    = columns(Simesh.p);
  Nelements = columns(Simesh.t);
  x = idata.un * ones(Nelements,1);
endfunction

