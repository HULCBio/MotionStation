function jac = funjac(x,xdot,T,d)
  global A_MATRIX_IFF B_MATRIX_IFF C_MATRIX_IFF OUTSTRUCT_IFF
  [A,B,res] = buildsystemIFF(OUTSTRUCT_IFF,x,T);
  jac = (B+B_MATRIX_IFF) + d * (A+A_MATRIX_IFF);
endfunction