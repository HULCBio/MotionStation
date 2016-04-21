function pdedemos
%PDEDEMOS Set up PDE Toolbox command-line demos for The MATLAB Expo.

%   Magnus Ringh, 11-Oct-1996.
%   Copyright 1994-2001 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2001/02/09 17:03:14 $

labelList=str2mat( ...
    'Poisson''s equation',...
    'Helmholtz''s equation',...
    'Minimal surface problem',...
    'Domain decomposition',...
    'Heat equation',...
    'Wave equation',...
    'Adaptive solver',...
    'Fast Poisson solver');

nameList = [...
      'pdedemo1';
      'pdedemo2';
      'pdedemo3';
      'pdedemo4';
      'pdedemo5';
      'pdedemo6';
      'pdedemo7';
      'pdedemo8'];

cmdlnwin(labelList, nameList)
