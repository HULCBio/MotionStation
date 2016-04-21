function names=getxpcbio(biofile,hierarchical)

% GETXPCBIO -  xPC Scope Helper Function

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.5 $ $Date: 2002/03/25 04:22:24 $

eval(['bio=',biofile,'bio;']);
names1={};
for i=1:length(bio)
   name=bio(i).blkName;
   if bio(i).portIdx==0
      if i~=length(bio)
         if(bio(i+1).portIdx==1)
          if strcmp(bio(i).blkName, bio(i+1).blkName)
            name=[name,'/p',num2str(bio(i).portIdx+1)];
          end
         end;
      end;
   else
      name=[name,'/p',num2str(bio(i).portIdx+1)];
   end;
   names1=[names1;{name}];
end;

names=names1;

names1={};
for i=1:length(names)
   name=names{i};
   if bio(i).sigWidth==1
      names1=[names1;{name}];
   else
      for j=1:bio(i).sigWidth
         names1=[names1;{[name,'/s',num2str(j)]}];
      end;
   end;
end;
names=names1;
