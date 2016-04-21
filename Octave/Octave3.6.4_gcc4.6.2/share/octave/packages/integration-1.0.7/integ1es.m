## Copyright (C) Not copyrighted, but placed in the public domain.
## However, it would be appreciated if the statement of authorship
## is preserved.
##
##

## -*- texinfo -*-
## @deftypefn {Function File} {} integrator(@var{y},@var{x-lower},@var{x-upper})
## Given a vector of evenly spaced y values on x-lower through
## x-upper, end points included, the numerical integral of y is
## returned.
##
## Unlike "Function" integrators, which need a function routine that
## the integrator can evaluate as it wishes, this is a "Data"
## integrator that enables the integration of the whatever values are
## provided without reference to any other information.  Since data
## usually comes in the form of evenly spaced values, this is the
## approach taken.  However, this can be used as a "Function"
## integrator as it is in the demo sited below.
##
## This uses a (up through, depending on the number of values 
## furnished) ninth order polynomial approximation method and all the
## standard polynomial approximation rules apply hereto.
##
## This is "exact" for 8'th and 9'th orders in x if 9 or more values
## are supplied, 6'th and 7'th for 7 or more, 4'th and 5'th for 5 or
## more, and 2'nd and 3'rd for 3 or more.  For higher orders, the
## result will generally become usably accurate with enough data
## points.  For illustrations, please see the 'Demo Instructions'.
##
## The function need not be powers of x.  Any function that can be
## adequately represented by a ninth order power series will work,
## e.g. exp(-k*x), exp(-k*x^2), sin(k*x), etc.  See below.
##
## Demo Instructions:      To see how this works with a variety of
## functions, the included demo is run by entering 'demo integ1es',
## without the single quotation marks, at the command line.  When the
## source code display, has finished press 'q' to get out of it, and
## then follow the on screen directions.  Several test functions are
## available, both with and without experimental error.  Note that
## when experimental error, a tolerance of 1%, is included, the error
## in the result, usually in the tenths of a percent, is fairly
## independent of the number of points.
## 
## This test serves the purpose, amongst others, of determining how
## many points need be provided to achieve the desired accuracy
## before the data is created.
##
## Beware of trying null value integrals since calculating the
## relative error results in a division by zero.  Also, the error for
## e^(ord*x^2) for positive 'ord' is reported as 'NaN' since there is
## no function for comparison.
## @end deftypefn

##
## Author: Douglas M. Elliott, V1.0, July 1, 2009.
##
## Keywords: numerical integration
##
##


function I=integ1es(f,xl,xu);


  if nargin<3
    disp(" Three inputs are required: the function values, and the lower and upper bounds.");
    return
  endif

  if xu<xl
    disp(" The lower bound must precede the upper."); return
  endif

  if xu==xl
    disp(" The lower bound can not be the same as the upper."); return
  endif


  C{1}=[1];
  C{2}=[0.5;0.5];
  C{3}=[1;4;1]/3;
  C{4}=[3;9;9;3]/8;
  C{5}=[14;64;24;64;14]/45;
  C{6}=[95;375;250;250;375;95]/288;
  C{7}=[41;216;27;272;27;216;41]/140;
  C{8}=[751;3577;1323;2989;2989;1323;3577;751]/17280*7;
  C{9}=[989;5888;-928;10496;-4540;10496;-928;5888;989]/14175*4;
  C{10}=[2857;15741;1080;19344;5778;5778;19344;1080;15741;2857]/89600*9;
  C{11}=[16067;106300;-48525;272400;-260550;427368;-260550;272400;-48525; ...
         106300;16067]/299376*5;
  C{12}=[2034625;11965622;-1423314;19815805;-4825526;12349588;12349588; ...
         -4825526;19815805;-1423314;11965622;2034625]/7257600;
  C{13}=[2034625;11965622;-1471442;20354366;-7574721;20812812;-5151324; ...
         20812812;-7574721;20354366;-1471442;11965622;2034625]/7257600;
  C{14}=[2034625;11965622;-1471442;20306238;-7036160;18063617;3311900; ...
         3311900;18063617;-7036160;20306238;-1471442;11965622;2034625]/7257600;
  C{15}=[2034625;11965622;-1471442;20306238;-7084288;18602178; ...
         562705;11775124;562705;18602178;-7084288;20306238; ...
         -1471442;11965622;2034625]/7257600;
  C{16}=[2034625;11965622;-1471442;20306238;-7084288;18554050;1101266; ...
         9025929;9025929;1101266;18554050;-7084288;20306238;-1471442; ...
         11965622;2034625]/7257600;
  C{17}=[2034625;11965622;-1471442;20306238;-7084288;18554050;1053138; ...
         9564490;6276734;9564490;1053138;18554050;-7084288;20306238; ...
         -1471442;11965622;2034625]/7257600;
  C{18}=[2034625;11965622;-1471442;20306238;-7084288;18554050;1053138; ...
         9516362;6815295;6815295;9516362;1053138;18554050;-7084288; ...
         20306238;-1471442;11965622;2034625]/7257600;
  C{19}=[2034625;11965622;-1471442;20306238;-7084288;18554050; ...
         1053138;9516362;6767167;7353856;6767167;9516362;1053138; ...
         18554050;-7084288;20306238;-1471442;11965622;2034625]/7257600;
  C{20}=[2034625;11965622;-1471442;20306238;-7084288;18554050; ...
         1053138;9516362;6767167;7305728;7305728;6767167;9516362; ...
         1053138;18554050;-7084288;20306238;-1471442;11965622;2034625]/7257600;
  C10L=[2034625;11965622;-1471442;20306238;-7084288;18554050;1053138; ...
        9516362;6767167;7305728]/7257600;
  C10R=[7305728;6767167;9516362;1053138;18554050;-7084288;20306238; ...
        -1471442;11965622;2034625]/7257600;


  g=f; [r,c]=size(g); n=c; if r>c; g=g'; n=r; endif

  if n<21; C10=C{n}; else; C10=[C10L;ones(n-20,1);C10R]; endif

  I=g*C10*(xu-xl)/max(n-1,1);


endfunction


%!demo
%!
%!  clc; input("  Please press 'Enter' to continue. ","s"); 
%! %
%!  clc; disp(" ");
%! %
%!  W$=["  Needs four inputs: the order, the lower and upper"];
%!  W$=[W$,[" bounds, and the integrand function type.\n"]];
%!  X$=["  To add 1% noise, add 0.5 to the integer function number, e.g. 2.5.\n"];
%!    disp(W$);
%!    disp("\n  The integrand function types are:\n");
%!    disp("    1. x^ord");
%!    disp("    2. exp(ord*x)");
%!    disp("    3. exp(ord*x^2)");
%!    disp("    4. sin(ord*x)");
%!    disp("    5. 1/(ord^2 + x^2)\n");
%!    disp(X$);
%! %
%!  disp(" "); ord=input("  Enter the order: ");
%! %  
%!  xl=input("  Enter the lower limit: ");
%!  xu=input("  Enter the upper limit: ");
%!  if xu<xl
%!    disp("\n  The lower bound must precede, and can not be greater than the upper.\n");
%!    return
%!  endif
%!  if xu==xl
%!    disp("\n  The lower bound can not be the same as the upper.\n"); return
%!  endif
%! %
%!  fun=input("  Enter the integrand function type: "); fun=abs(round(fun*2))/2;
%!  if 5.5<fun
%!    disp("\n\n  The fourth input, function type, must be 5.5 or less.\n\n");
%!    return
%!  endif
%! %
%! %
%!  tn=floor(fun);
%!  F$={["   x^",num2str(ord)];["   e^(",num2str(ord),"*x)"]; ...
%!       ["   e^(",num2str(ord),"*x^2)"];["   sin(",num2str(ord),"*x)"]; ...
%!       ["   1/(",num2str(ord),"^2+x^2)"];["  x^",num2str(ord),"+1+noise"]};
%!  D$=[" on (",num2str(xl),",",num2str(xu),") "];
%!    if fun~=tn; D$=[", with 1% tolerance,",D$]; endif
%!  clc; disp(" "); disp([F${tn},D$]);
%!  wn$="      #.##e-014 is just numerical noise.\n";
%!  if fun==tn; disp(wn$); else; disp(" "); endif
%! %
%! %
%!  for pts=[2:39,50,100,200,500,1000,10000,100000];
%! %
%!    x=linspace(xl,xu,pts);
%! %
%!    if tn==1
%!      f=x.^ord; if fun==1.5; f=f.*(1+(rand(1,pts)-0.5)./50); endif
%!      I=integ1es(f,xl,xu); E=I*(ord+1)/(xu^(ord+1)-xl^(ord+1))-1;
%!    elseif tn==2
%!      f=exp(ord*x); if fun==2.5; f=f.*(1+(rand(1,pts)-0.5)./50); endif
%!      I=integ1es(f,xl,xu); E=I*ord/(exp(xu*ord)-exp(xl*ord))-1;
%!    elseif tn==3
%!      f=exp(ord*x.^2); if fun==3.5; f=f.*(1+(rand(1,pts)-0.5)./50); endif
%!      I=integ1es(f,xl,xu);
%!      if 0<ord; E=NaN;
%!      elseif ord==0; E=I/(xu-xl)-1;
%!      else; k=sqrt(-ord); E=2*k/pi()^0.5*I/(erf(k*xu)-erf(k*xl))-1;
%!      endif
%!    elseif tn==4
%!      f=sin(ord*x); if fun==4.5; f=f.*(1+(rand(1,pts)-0.5)./50); endif
%!      I=integ1es(f,xl,xu); E=ord*I/(cos(ord*xl)-cos(ord*xu))-1;
%!    elseif tn==5
%!      f=1./(ord^2+x.^2); if fun==5.5; f=f.*(1+(rand(1,pts)-0.5)./50); endif
%!      I=integ1es(f,xl,xu); E=ord*I/(atan(xu/ord)-atan(xl/ord))-1;
%!    endif
%! %   
%!    printf("     Points = %6.0d    I = %12.4e    %% RelErr = %9.1e\n",pts,I,E*100);
%! %
%!  endfor
%! %
%! %
%!  disp(" ");