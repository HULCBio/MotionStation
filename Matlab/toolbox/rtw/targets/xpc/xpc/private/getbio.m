function names=getbio(biofile,hierarchical)

% GETBIO - xPC Target private function

% Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.6.4.1 $ $Date: 2004/04/08 21:04:28 $

eval(['bio=',biofile,'bio;']);
names1={};
for i=1:length(bio)
   name=bio(i).blkName;
   names1=[names1;{name}];
end

names=names1;

names1={};
for i=1:length(names)
   name=names{i};
   if bio(i).sigWidth==1
      names1=[names1;{name}];
   else
      for j=1:bio(i).sigWidth
         names1=[names1;{[name,'/s',num2str(j)]}];
      end
   end
end
names=names1;
