function [tbList, bsList]=finddemo
% FINDDEMO Search for paths containing Demos.m, Demos.mat and set
%   up toolbox and blockset demo lists for Demo.m

%   Kelly Liu 8-6-96, jae Roh 1-30-97
%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.26.4.3 $  $Date: 2004/04/10 23:24:41 $

toolboxes=which('demos.m', '-all');

k=1;             % toolbox list count
j=1;             % blockset list count
tbList=[];
bsList=[];
simExist = (exist('simdemos\demos.xml','file')==2);

for i=1:size(toolboxes, 1),

   % Use fopen to avoid checking out the toolbox license keys
   % This code is not robust to changes in the variable name "tbxStruct"
   fcnStr = '';
   demosFile = char(toolboxes(i));
   fid = fopen(demosFile,'r');
   if (fid == -1)
      warning('MATLAB:finddemo:FileNotFound', ...
         '"%s" could not be found.\nYour path cache may be out of date. Use "rehash toolboxcache" to update it.', ...
         demosFile);
   else
      saveFlag = 0;
      while 1,
         fcnLine = fgetl(fid);
         if ~ischar(fcnLine), break, end
         if any(findstr(fcnLine,'tbxStruct.')), saveFlag = 1; end
         if saveFlag,
            dotsIndex = findstr(fcnLine,'...');
            if isempty(dotsIndex),
               fcnStr=[fcnStr fcnLine 13];
            else
               % We're removing the "..." and literally concatenating the
               % two affected lines to make one line
               fcnLine = strrep(fcnLine,'...','');
               % Note: this will remove the "..."s inside any quoted strings
               fcnStr=[fcnStr fcnLine];
            end
         end
      end
      fclose(fid);

      if ~isempty(fcnStr),
         tbxStruct = '';
         eval(fcnStr);
         out = tbxStruct;

         step=size(out.DemoList, 2);
         tempList=LocalGetList(step, out, simExist);
         if ~isempty(tempList)
            if strcmp(lower(out.Type), 'toolbox')
               tbList(k).Name=out.Name;
               tbList(k).Type=out.Type;
               tbList(k).Help=out.Help;
               tbList(k).DemoList=tempList.DemoList;
               tbList(k).FcnList=tempList.FcnList;
               k=k+1;
            else
               bsList(j).Name=out.Name;
               bsList(j).Type=out.Type;
               bsList(j).Help=out.Help;
               bsList(j).DemoList=tempList.DemoList;
               bsList(j).FcnList=tempList.FcnList;
               j=j+1;
            end
         end
      else
         % If there's no tbxStruct, just ignore the entry and keep on going...
      end
   end
end

function thisList=LocalGetList(step, out, simExist)
% LocalGetList
thisList={};
k=1;
s = size(out.DemoList,1);
if (s>0)
   for m=1:s
      if step==2 || (step==3 && isempty(char(out.DemoList(m, 3))))
         thisList.DemoList(k)=out.DemoList(m,1);
         thisList.FcnList(k)=out.DemoList(m,2);
         k=k+1;
      elseif step==3 && ~isempty(char(out.DemoList(m, 3))) && simExist
         thisList.DemoList(k)=out.DemoList(m,1);
         thisList.FcnList(k)=out.DemoList(m,2);
         thisList.DemoList{k}= ...
            [deblank(char(thisList.DemoList(m))) ' (sim)'];
         k=k+1;
      end
   end
else
   % No demos are available but we have some 'about' text
   % then it doesn't seem to come up at all...
end
