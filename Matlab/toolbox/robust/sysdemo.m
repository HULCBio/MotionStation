%
%SYSDEMO Demo of system matrix data structure.
%

echo off
clf
clc
echo on

                           % SYSTEM DEMO %

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% This demo illustrates the use of the following functions         %%
  %% from the Robust-Control Toolbox:                                 %%
  %%                                                                  %%
  %%                 TREE      MKSYS      BRANCH                      %%
  %%                                                                  %%
  %% These commands endow MATLAB with a special data structure called %%
  %% a TREE which enables many matrices, along with their names and   %%
  %% relationships to each other to be represented by a single TREE   %%
  %% variable.  A SYSTEM is a special kind of tree.                   %%
  %%------------------------------------------------------------------%%
  %% Many MATLAB commands such as  SIGMA, H2LQG, and HINF make use of %%
  %% the TREE and SYSTEM data structures to simplify user interaction %%
  %% and reduce the amount of typing required to get a job done!      %%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% R. Y. Chiang & M. G. Safonov 11/11/90
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.10.4.3 $
% All Rights Reserved.
% ----------------------------------------------------------------------

pause                % Press any key to continue
clc
                  %  LOAD SOME MATRICES %

% Lets load a few matrices and see what SYSTEM and TREE can do:

echo off
hplant
echo on

who

% The matrices [ag,bg,cg,dg] describe a standard state-space system,viz.,
% the logitudinal dynamics of an aircraft.  The set of matrices
% [A,B1,B2,C1,C2,D11,D12,D21,D22] also describe a two-port state-space
% system, such as might be obtained by augmenting the aircraft in
% preparation for HINF or H2LQG control design.

pause                % Press any key to continue
clc
                              % MKSYS %

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%    The MKSYS command packs matrices describing a system into          %%
%%    a single vector.                                                   %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% For example,
      ss_g = mksys(ag,bg,cg,dg);

% MKSYS also creates two-port systems:
      TSS_ = mksys(A,B1,B2,C1,C2,D11,D12,D21,D22,'tss');


% Other sorts of systems can be created too, e.g., descriptor systems ('des')
% transfer function systems ('tf'), general polynomial system matrices
% ('gpsm'), etc.



pause                % Press any key to continue
echo off
clc
help mksys
pause                % Press any key to continue
clc
echo on

                            % BRANCH %

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  The BRANCH function recovers matrices packed in a SYSTEM or     %%
%%  other TREE vector.                                              %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Let's clear the matrices the matrices [ag,bg,cg,dg] and [A,B1,B2, ..
% C1,C2,D11,D12,D21,D22] from the workspace so we can see how BRANCH
% works.

clear ag bg cg dg A B1 B2 C1 C2 D11 D12 D21 D22
who


pause                % Press any key to continue
clc
% To recover the matrices D11 and C2 from the SYSTEM vector TSS_
% we can type:

       [D11,C2] = branch(TSS_,'d11,c2')


pause                % Press any key to continue
echo off
clc
help branch
echo on



pause                % Press any key to continue
clc




% To get the matrix ag from the state space system ss_g, we can type

ag=branch(ss_g,'a')



pause                % Press any key to continue
clc
% To recover all the matrices from ss_g at once one may type

[ag,bg,cg,dg]=branch(ss_g);

who

pause                % Press any key to continue
clc
echo on

                  % H2LGQ, HINF and SIGMA examples %

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Now we will illustrate how the use of SYSTEM vectors saves typing %%
%% when using system related functions like H2LGQ, HINF and SIGMA.   %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Let's do an H2LQG control design for the two-port system TSS_
% and compute the resultant controller's singular value bode plot.

% One could do this by typing
%      [af,bf,cf,df,acl,bcl,ccl,dcl]=h2lqg(A,B1,B2,C1,C2,D11,D12,D21,D22);
%      sv=sigma(af,bf,cf,df,1,w)
%
% but the following is much simpler to type

%    ( .... be patient, this computation may take awhile .... )

       w = logspace(-3,3,10);
       sv=sigma(h2lqg(TSS_),1,w);

pause                % Press any key to continue

echo off
       loglog(w,sv)
       title('loglog(sigma(sv,1,w))')
pause                % Press any key to continue
clc
echo on

% H-infinity control design is easy too using the SYSTEM data
% structure TSS_.  To compute the HINF controller SYSTEM ss_f
% and the closed-loop transfer function SYSTEM ss_cl, we type:

       [ss_f,ss_cl]=hinf(TSS_);

pause                % Press any key to continue
clc
% To recover the closed-loop state-space matrices [af,bf,cf,df]
% from the SYSTEM vector ss_f, one may type

    [af,bf,cf,df] = branch(ss_f);


    who


pause                % Press any key to continue
clc
                           % TREE %

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% The TREE function provides a general purpose tool for creating  %%
%% hierarchical data structures containing matrices, strings and   %%
%% even other TREEs.                                               %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% For example, suppose one wishes to keep track of the plant
% [A,B1,B2,C1,C2,D11,D12,D21,D22], along with the control law
% [af,bf,cf,df], the frequency response [w,sv] along with the
% name 'Aircraft Design Data'.  No problem!

% First put the frequency response data in a TREE:
            fr=tree('w,sv',w,sv);

% Now pack TSS_, ss_f, fr, along with the string 'Aircraft Design Data'
% into the TREE vector DesignData:
DesignData=...
  tree('plant,controller,freqresp,name',TSS_,ss_f,fr,'Aircraft Design Data');

pause                % Press any key to continue
clc

% The TREE DesignData has the following hierarchical structure:

%        plant
%            [a,b1,b2,c1,c2,d11,d12,d21,d22,ty]
%        controller
%            [a,b,c,d,ty]
%        freqresp
%            [w,sv]
%        [name]

% This TREE vector has two levels, as indicated by the indentation.
% However there is in general no limit to the number of levels a TREE
% vector can have.

% To recover the variable called 'name' from the TREE vector DesignData,
% we type:
           name=branch(DesignData,'name')
pause                % Press any key to continue
clc
% To see the names of all the "root branches" of the TREE DesignData, type
% the following (root branch names are always in branch no. 0 of a TREE):

           branch(DesignData,0)

% The names of the root branches of the sub-tree 'plant' are returned by

           branch(DesignData,'plant/0')

pause                % Press any key to continue
clc

% To recover the value of the matrix named 'c1' in the branch 'plant'
% of the tree DesignData, we could define the "path" to the variable
% 'c1' in the tree as 'plant/c1'.  Namely, we can descend two levels
% into the TREE DesignData to recover the C1 matrix of the plant TSS_
% with the command:

     C1 = branch(DesignData,'plant/c1')

pause                % Press any key to continue
clc
                             % SUMMARY %

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% The function MKSYS and the function TREE upon which it is based    %%
%% endow MATLAB with a new data structure consisting of a collection  %%
%% of one or more matrices, strings and even sub-TREE's.              %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% The power to represent systems by a single symbol considerably
% simplifies user interaction with the functions in the Robust-Control
% Toolbox.  However, those who don't mind typing a lot still have the
% option to type in the entire list of variables describing a system
% if they prefer!

echo off

% ------------ End of SYSDEMO.M -------- RYC/MGS 11/11/90 %
