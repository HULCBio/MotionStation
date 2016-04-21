function res = funres(x,xdot,T)
  global A_MATRIX_IFF B_MATRIX_IFF C_MATRIX_IFF OUTSTRUCT_IFF
  [A,Jac,res] = buildsystemIFF(OUTSTRUCT_IFF,x,T);
  res += (A+A_MATRIX_IFF) * xdot + B_MATRIX_IFF  * x + C_MATRIX_IFF;
endfunction
