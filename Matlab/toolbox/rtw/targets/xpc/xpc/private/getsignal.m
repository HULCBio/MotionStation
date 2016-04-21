function signal=getsignal(signal)

% GETSIGNAL - xPC Target private function

% Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.5.4.1 $ $Date: 2004/04/08 21:04:30 $

name=signal;
name(find(name<47 | (name > 57 & name <65) | (name > 90 & name <95) | (name >95 & name < 97) | name > 122))='_';
  
%index=find(name=='/');
%name(1:(index(1)-1))=[];
index=find(name=='/');
name(index)='.';
name=['.',name];

signal=name;