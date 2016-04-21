function r=set_table(r,varargin)
%SET_TABLE set table properties
%   R=SET_TABLE(R,arg1,arg2,arg3,...)
%   Creates another entry in r's reference table.  Input
%   arguments (in order) are:
%   
%   id - a unique string with no spaces
%   componentName - name of the looping component
%                   associated with this object type
%   getCmd - name of the command used to get parameters 
%   defaultParams - parameters associated with the object
%   displayName (optional) - name that the user
%                            sees when referring to object
%   btnImg (optional) - image user sees on obj select btn
%   linkid (optional) - string sent to linkid method in
%            execute when creating a link entry.
%   displayName2 (optional) - plural form of the display name
%

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 1998/06/01 17:41:16

if isempty(r.Table)
   r.Table=LocAssignTable;
end

if ~isempty(varargin)
   r.Table(end+1)=LocAssignTable(varargin{:});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function e=LocAssignTable(id,...
   componentName,...
   getCmd,...
   defaultParams,...
   displayName,...
   btnImg,...
   linkid,...
   displayName2);

if nargin<1
   id={};
   displayName={};
   componentName={};
   defaultParams={};
   getCmd={};
   btnImg={};
   linkid={};
   displayName2={};
else
   if nargin<8
      displayName2='';
      if nargin<7
         linkid='';
         if nargin<6
            btnImg=[];
            if nargin<5
               displayName='';
               if nargin<4
                  defaultParams={};
               end
            end
         end
      end
   end
   
   if isempty(displayName)
      displayName=id;
   end
   if isempty(displayName2)
      displayName2=[displayName 's'];
   end
   if isempty(linkid)
      linkid=id;
   end
   
   if iscell(componentName)
      componentName = {componentName};
   end
   
   defaultParams={defaultParams};
end

e=struct('id',id,...
   'componentName',componentName,...
   'getCmd',getCmd,...
   'defaultParams',defaultParams,...
   'displayName',displayName,...
   'btnImg',btnImg,...
   'linkid',linkid,...
   'displayName2',displayName2);
