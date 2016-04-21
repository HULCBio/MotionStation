function symdemos
%SYMDEMOS Set up Symbolic Math Toolbox command-line demos.
%   See also SYMCALCDEMO, FUNTOOL.

%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.8 $  $Date: 2002/04/15 03:13:59 $

labelList = str2mat( ...
    'Introduction',...
    'Variable Precision Arithmetic',...
    'Plane Rotations',...
    'Linear Algebra',...
    'Symbolic Equation Solving');

nameList = [...
      'symintro  '
      'symvpademo'
      'symrotdemo'
      'symlindemo'
      'symeqndemo'];
  
figureFlagList = zeros(length(nameList),1);

cmdlnwin(labelList,nameList,figureFlagList);
