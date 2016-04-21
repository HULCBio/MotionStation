exmpl ="nmos"
out=[];
nrm=[];


switch exmpl
  case "nmos"
    outstruct = parseIFF("nmos2");
    x = [0 1 1 0 0 0 ]';
    t = linspace(0,10,200);
    pltvars={"Vgate","Vdrain"};
  case "TLelement"
    outstruct = parseIFF("TLelement");
    x = [0 0 0 0 0 ]';
    t = linspace(0,1,200);
    pltvars={"Vin","Vout"};
end

global A_MATRIX_IFF B_MATRIX_IFF C_MATRIX_IFF OUTSTRUCT_IFF

[A_MATRIX_IFF,Jac,res,B_MATRIX_IFF,C_MATRIX_IFF,OUTSTRUCT_IFF] =...
 initsystemIFF(outstruct,x,0);


daspk_options("algebraic variables",[1 1 1 1 1 0 ]');
daspk_options("compute consistent initial condition",2);
#daspk_options("relative tolerance",1e-);

[x,xdot,istate,msg]= daspk(["funres";"funjac"],x,zeros(size(x)),t);


axis([min(t) max(t) 0 1]);
plotbynameIFF(t,x',OUTSTRUCT_IFF,pltvars)
