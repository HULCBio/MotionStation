function out=rptsetupfile(varargin)
%RPTSETUPFILE is the constructor for the @rptsetupfile class

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:17:12 $


if nargin==0
   out=LocGetProtoSetfile;
elseif isa(varargin{1},'rptsetupfile')
   out=LocStructWrite(LocGetProtoSetfile,struct(varargin{1}));
elseif isa(varargin{1},'struct')
   out=LocStructWrite(LocGetProtoSetfile,varargin{1});
else
   out=LocGetProtoSetfile;
end

out = class(out,'rptsetupfile',rptparent);

%we actually return a POINTER to the setup file
out=rptsp(out);

%validate subcomponents
%(if the setup file has just been read in, its component
% children will be structures)
outlineHandle=children(out);
         r=rptparent;
         oldSet=nenw(r);
validate(outlineHandle);
         nenw(r,oldSet);

indexlist(out,outlineHandle);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function p=LocGetProtoSetfile

%p.Setfile.AutoSaveOnGenerate=logical(0); obsolete
p.Setfile.EchoDetail=3;

p.ref.Path = [pwd filesep];
p.ref.ID= [];
p.ref.OutlineHandle=[];
%changed is a "dirty" flag
p.ref.changed=logical(0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function s=LocStructWrite(s,o)
%s is the template setfile
%o is the structure which will overwrite "s"

grabfields={'Setfile' 'ref'};

for i=1:length(grabfields)
   tograb=grabfields{i};
   
   if isfield(o,tograb)
      ograb=getfield(o,tograb);
      eval(['sgrab=s.',tograb,';']);
      %cgrab=getfield(c,tograb);
      fields=fieldnames(ograb);
      for j=1:length(fields)
         sgrab=setfield(sgrab,fields{j},getfield(ograb,fields{j}));      
      end %for length(fields)
      eval(['s.',tograb,'=sgrab;']);
      %c=setfield(c,tograb,cgrab);
   end %if isfield 
end %for i=1:length(grabfields)