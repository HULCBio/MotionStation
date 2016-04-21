% LMI-LAB DEMO: EXAMPLE 2.3.1 IN THE USER'S MANUAL

% Author: P. Gahinet
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.9.2.3 $

echo off
load lmidem;
clc

disp(' ');
disp(' ');
disp('                 LMI  CONTROL  TOOLBOX ');
disp('                 ********************* ');
disp(' ');
disp(' ');
disp('                   DEMO  OF  LMI-LAB   ');
disp(' ');
disp(' ');
disp('          Specification and manipulation of LMI systems ');
disp(' ');
disp('              Example 2.3.1 of the Tutorial Section');
disp(' ');
disp(' ');
disp(' ');
disp(' ');

echo on

pause  % Strike any key to continue...
clc
%    
%                                                          -1
%  Scaled RMS gain of the transfer function G(s) = C (sI-A)  B
%
%                                                      -1
%  We want to minimize the H-infinity norm of  D G(s) D   over
%  a set of scaling matrices D with some given structure. This
%  problem arises in Mu theory (robust stability analysis)
%
%  The system of LMIs is:
%
%       ( A'X + XA + C'SC   XB )
%       (                      )   <  0
%       (      B'X          -S )
%
%                              X   >  0
%                              
%                              S   >  I
%  where 
%    X  is symmetric
%    S = D'*D  is symmetric block diagonal with prescribed structure 
%
%                  ( s11   0    0    0  )
%            S  =  (  0   s11   0    0  )
%                  (  0    0   s22  s23 )
%                  (  0    0   s23  s33 )


A


pause  % Strike any key to continue...
clc
%
%       ( A'X + XA + C'SC   XB )
%       (                      )   <  0
%       (      B'X          -S )
%
%                              X   >  0
%                              
%                              S   >  I
%  
%
%                                 ( s11   0    0    0  )
%       X  is symmetric,    S  =  (  0   s11   0    0  )
%                                 (  0    0   s22  s23 )
%                                 (  0    0   s23  s33 )



% To specify this LMI system with LMIVAR and LMITERM,


% (1) initialize the LMI system to void

setlmis([]);



% (2) define the 2 matrix variables X,S 

X=lmivar(1,[6 1]);
S=lmivar(1,[2 0;2 1]);




pause  % Strike any key to continue...
clc
%
%       ( A'X + XA + C'SC   XB )
%       (                      )   <  0
%       (      B'X          -S )
%
%                              X   >  0
%                              
%                              S   >  I

% (3) specify the terms appearing in each LMI. For 
%     convenience, you can give a name to each LMI 
%     with NEWLMI (optional)


% 1st LMI
BRL=newlmi;
lmiterm([BRL 1 1 X],1,A,'s');
lmiterm([BRL 1 1 S],C',C);
lmiterm([BRL 1 2 X],1,B);
lmiterm([BRL 2 2 S],-1,1);

% 2nd LMI
Xpos=newlmi;
lmiterm([-Xpos 1 1 X],1,1);

% 3rd LMI
Slmi=newlmi;
lmiterm([-Slmi 1 1 S],1,1);
lmiterm([Slmi 1 1 0],1);


% (4) get the internal description of this LMI system 
%     with GETLMIS

lmisys=getlmis;


% Done!  A full description of this LMI system is now 
%        stored in the MATLAB variable LMISYS



pause  % Strike any key to continue...
clc
%
%  You can also specify this system with the LMI editor:
%
%  >> lmiedit
%
%
echo off

lmiedit
echo on


%  Here you specify the variables in the upper half of the 
%  window and type the LMIs as MATLAB expressions in the 
%  lower half ...
%
%  To see how this should look like,  click "LOAD" and 
%  load the string called  "demolmi".


pause  % Strike any key to continue...

%
%  You can 
%    * save this description in a MATLAB string of your 
%      choice ("SAVE") 
%    * generate the internal representation "lmisys" of 
%      this LMI system by clicking on "CREATE" 
%    * visualize the  LMIVAR  and  LMITERM  commands that
%      create "lmisys"  (click on "VIEW COMMANDS")
%    * write in a file this series of commands (click on 
%      "WRITE")
% 
%
%  Click on "CLOSE" to exit LMIEDIT


pause  % Strike any key to continue...
clc
%
% You can retrieve various information about the LMI system
% you just defined


% number of LMIs:

lminbr(lmisys)



% number of matrix variables:

matnbr(lmisys)
pause  % Strike any key to continue...


% variables and terms in each LMI (type q to exit lmiinfo):

lmiinfo(lmisys)


pause  % Strike any key to continue...
clc
%
% We now call FEASP to solve our system of LMIs
%
%       ( A'X + XA + C'SC   XB )
%       (                      )   <  0
%       (      B'X          -S )
%
%                              X   >  0
%                              
%                              S   >  I

pause  % Strike any key to continue...


[tmin,xfeas]=feasp(lmisys);


% tmin=-1.839011 < 0 : the problem is feasible!
%                                                    -1
%  -> there exists a scaling D such that  || D G(s) D  ||oo < 1
% 
%
% The output XFEAS is a feasible value of the vector of decision
% variables (the free entries of X and S).



pause  % Strike any key to continue...
clc
%
%  Use DEC2MAT to get the corresponding values of the matrix
%  variables X and S:

 
Xf=dec2mat(lmisys,xfeas,X);
Sf=dec2mat(lmisys,xfeas,S);


eig(Xf) 
eig(Sf)
%  the constraints  X > 0  and  S > I are satisfied!



pause  % Strike any key to continue...
clc
%
%  To verify that the first LMI is satisfied,
%
%   (1) evaluate the LMI system for the computed decision 
%       vector XFEAS:


evlmi = evallmi(lmisys,xfeas);


%   (2) get the values of the left and right-hand sides of 
%       the first LMI with  SHOWLMI:


[lhs1,rhs1]=showlmi(evlmi,1); 


eig(lhs1-rhs1)
% the first LMI is indeed satisfied.


pause  % Strike any key to continue...
clc
%
%  Finally, let us check that the H-infinity norm of  G(s) 
%  was not less than one from the start. To do this, we 
%  can remove the scaling  D  by setting S = 2*I and solve 
%  the resulting feasibility problem:
% 
%    Find X such that
%
%       ( A'X + XA + C'C   XB )
%       (                     )   <  0
%       (      B'X         -I )
%
%                              X   >  0


%  This new LMI system is derived from the previous one 
%  by setting  S = 2*I  with SETMVAR:


newsys=setmvar(lmisys,S,2);


%  Now call FEASP to solve the modified LMI problem:


pause  % Strike any key to continue...



[tmin,xfeas]=feasp(newsys);


%  Infeasible!  The H-infinity norm of  G(s) was larger than one


pause  % Strike any key to continue...

echo off
close all
return

