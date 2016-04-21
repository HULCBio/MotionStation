function childdisp(children, varargin)
%CHILDDISP Display helper function for channels or lines.
%

%    CHILDPROPS is the list of OBJ's child properties that will be
%    displayed.  To change what is listed in the child summary table,
%    the only modification required is CHILDPROPS.  The table displays the
%    CHILDPROPS properties in the order they are listed in the array.  
%    CHILDPROPS must be contain the actual child property name.

%    DAQDEVICE object OBJ fields:
%       .handle     - hidden unique handle from DAQMEX associated with the
%                     channel.
%       .version    - class version number.
%       .info       - Structure containing strings used to provide object
%                     methods with information regarding the object.  Its
%                     fields are:
%                       .prefix     - 'a' or 'an' prefix that would preceed the
%                                     object type name.
%                       .objtype    - object type with first characters capitalized.
%                       .addchild   - method name to add children, ie. 'addchannel'
%                                     or 'addline'.
%                       .child      - type of children associated with the object
%                                     such as 'Channel' or 'Line'.
%                       .childconst - constructor used to create children, ie. 'aichannel',
%                                     'aochannel' or 'dioline'.

%    CP 5-18-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.13.2.5 $  $Date: 2003/12/04 18:38:37 $

if nargin==4,
   % DAQDEVICE objects are being passed from the object's
   % DISP method with the syntax:
   %   CHILDDISP(CHILDREN, INFO, FID, NEWLINE);
   
   [info, fid, newline] = deal(varargin{:});
   children = daqmex(children,'get',info.child);
   
   %  If no channels / lines exist, then break out with correct header:
   if isempty(children),
      fprintf(fid,'%s %s%s\n%s','no',lower(info.child),'s.',newline);
      return
   else
      %  Title for channel / line summary table.
      fprintf(fid,'%s%s\n%s',lower(info.child),'(s):',newline);
   end
   
else   
   % We need to get variables that will be used in the display routine.

   % File identifier...fid=1 outputs to the screen.
   fid=1;
   
   % Determine if we want a compact or loose display.
   isloose = strcmp(get(0,'FormatSpacing'),'loose');
   if isloose,
      newline=sprintf('\n');
   else
      newline=sprintf('');
   end
   
   % Get the structure containing object descriptions.
   Hstruct=struct(children);
   for i = 1:length(Hstruct.handle)
      if daqmex('IsValidHandle', Hstruct.handle(i));
         s=struct(daqmex(Hstruct.handle(i),'get','parent'));
         info=s.info;
         break;
      end
   end
end   

% =============================================================================
% CHILD SUMMARY TABLE BEGINS HERE... 
% =============================================================================
%   - CHILDREN OBJECT PROPERTIES:
% =============================================================================
%  Create the list of property names to be used as the heading for the summary table.  Upper
%  is used to just emphasize the list as a heading when it's displayed, for example:
%  INDEX:  CHANNELNAME:  HWCHANNEL:  INPUTRANGE:  ....
if strcmpi(info.childconst,'aichannel'),
   childprops={'Index', [info.child, 'Name'], ['Hw', info.child], ...
         'InputRange','SensorRange', 'UnitsRange', 'Units'};
elseif strcmpi(info.childconst, 'aochannel'),
   childprops={'Index', [info.child, 'Name'], ['Hw', info.child], ...
         'OutputRange', 'UnitsRange', 'Units'};
elseif strcmpi(info.childconst, 'dioline')
   childprops={'Index', 'LineName', 'HwLine', 'Port', 'Direction'};
end

%  Initialize variables for channel / line table display
nprops=length(childprops);
ValSets=length(children);
ValsGrp=cell(ValSets,nprops);
ValLength=cell(1,nprops);
propNames=cell(1,nprops);

% Get the structure informaiton of the channels:
Hstruct=struct(children);

% Store property names - propNames - after appending ':'.
% propNames is later used for padding names and values with blanks.
% Values are converted to strings so character blanks can later be 
% appended to them.  Store the lengths of each value - ValLength -
% as we loop through.
for i=1:nprops,
   propNames{i}=sprintf('%s:',childprops{i});
   for j=1:ValSets,
      % If the handle is not valid, do nothing otherwise get the proeprty 
      % information.
      try
         ValsGrp{j,i} = daqmex(Hstruct.handle(j),'get',childprops{i});
         
         % Convert value to proper display format.
         if ~ischar(ValsGrp{j,i}),
            if size(ValsGrp{j,i},2)>1,
               % A numerical row vector is found, store it as a string with [].
               ValsGrp{j,i}=sprintf('[%0.5g %0.5g]',ValsGrp{j,i}(1),ValsGrp{j,i}(2));
            else
               % A single numerical value found.
               ValsGrp{j,i}=sprintf('%d',ValsGrp{j,i});
            end         
         else
            % A string - add single quotes around property value.
            ValsGrp{j,i}=sprintf('%s','''', ValsGrp{j,i}, '''');
         end
            
         ValLength{i}(j)=length(ValsGrp{j,i});
     catch
     end
   end
end

%  Using the stored value lengths - ValLength - determine the longest value for
%  each property column.
%  Pad any short values with - valspad - so all property values are the same length.
%  Pad the property headings with - hdspad - based on the longest value found within
%  each column.
space = ' ';
for k=1:nprops,
   clmnMax=max(ValLength{k});
   for p=1:ValSets,
      valspad=clmnMax-length(ValsGrp{p,k});
      hdspad=clmnMax-length(propNames{k});
      
      if valspad > 0,
         ValsGrp{p,k}=sprintf('%s%s',ValsGrp{p,k},space(ones(1,valspad)));
      end
      if hdspad < 0,
         ValsGrp{p,k}=sprintf('%s%s',ValsGrp{p,k},space(ones(1,abs(hdspad))));
      elseif hdspad > 0,
         propNames{k}=sprintf('%s%s',propNames{k},space(ones(1,hdspad)));
      end
      
   end
end

%  Indentation for each table row displayed.
indent=sprintf('%3s',' ');

% Write out the headings (property names).
str=indent;
str=[str sprintf('%s  ',propNames{:})];
fprintf(fid','%s\n',str);
% Build the channel output
out='';
for h=1:ValSets
   if sum(isspace(ValsGrp{h,1})) == length(ValsGrp{h,1})
     out=[out indent sprintf('Element #%d is an invalid %s.\n',h,info.child)];
   else
     out=[out indent sprintf('%s  ',ValsGrp{h,:}) newline];
   end
   iscompact = strcmp(get(0,'FormatSpacing'),'compact');
   if iscompact,
	   out = [out sprintf('\n')];
   end
end
fprintf(fid,'%s\n',out);
