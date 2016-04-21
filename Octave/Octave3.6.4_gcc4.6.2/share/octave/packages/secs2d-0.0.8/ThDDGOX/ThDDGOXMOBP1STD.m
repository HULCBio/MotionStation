function x = ThDDGOXMOBP1STD (imesh,Simesh,Sinodes,Sielements,idata)
  Nnodes    = columns(Simesh.p);
  Nelements = columns(Simesh.t);
  x = idata.Tl./idata.Tp;
endfunction
