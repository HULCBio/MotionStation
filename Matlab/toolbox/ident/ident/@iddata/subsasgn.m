function sys = subsasgn(sys,Struct,rhs)
%SUBSASGN  Subscripted assignment for IDDATA objects.
%
%   The following assignment operations can be applied to any 
%   IDDATA set DAT: 
%     DAT(Samples,Outputs,Inputs,Experiments)=RHS  reassigns a subset
%         of the data channels
%     Arguments can be omitted to mean ':', so DAT(:,3)=DAT(:,3,:)
%     DAT.Fieldname=RHS  is equivalent to SET(DAT,'Fieldname',RHS)
%   The left-hand-side expressions themselves can be followed by any 
%   valid subscripted reference, as in DAT(:,:,3).inputname='u' or
%   DAT(11:20,2).y=[1:10]'.
%
%   A new experiment to be merged with old ones is obtained by 
%   DAT{:,:,:,expno) = DAT2;
%
%   Samples, channels, and experiments will be overwritten if the
%   indicated indices correspond to existing data, otherwise new 
%   samples/channels/experiments will be added.
%
%   The numbers in the arguments OUTPUT, INPUT, and EXPERIMENT
%   can be replaced by the curresponding names, like
%   DAT(1:59,'Speed',{'Current','Feed'},'Day5').
%
%   The syntax
%   DAT(Samp,Outp,Inp,Exp) = []
%   has a special interpretation: The indicated Experiments, Samples,
%   output and input channels will be deleted. That is, the complements
%   of the indicated items are selected. Omitted arguments are here
%   treated as empty matrices, i.e. no action on these channels. Moreover,
%   Samp = ':' is treated as the empty matrix in this case.
%   When you combine deleting some experiments with deleting all input or
%   output channels, write explicitly the channels to be deleted, like
%   dat([],[],[1:Nu],2).
%
%   See also IDDATA/SET, IDDATA/SUBSREF, IDDATA/MERGE.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.12.4.1 $ $Date: 2004/04/10 23:16:23 $



if nargin==1,
   return
end

if strcmp(Struct(1).type,'{}') % This is the experiment number
   expind = Struct(1).subs;
    substemp = {':',':',':'};
   if length(Struct)>1&strcmp(Struct(2).type,'()')
      substemp(1:length(Struct(2).subs))=Struct(2).subs;
      Struct = Struct(2:end); 
   else
      Struct(1).type='()';
   end
   substemp(4)=expind;
   Struct(1).subs = substemp;   
end

StructL = length(Struct);
% Peel off first layer of subassignment
switch Struct(1).type
case '.'
   % Assignment of the form sys.fieldname(...)=rhs
   FieldName = Struct(1).subs;
   try
      if StructL==1,
         FieldValue = rhs;
      else
         FieldValue = subsasgn(get(sys,FieldName),Struct(2:end),rhs);
      end
      set(sys,FieldName,FieldValue)
   catch
      error(lasterr)
   end
   
case '()'
   % Assignment of the form sys(indices)...=rhs  rhs is iddata structue
   
   try
      if StructL==1,
         try
            sys = indexasgn(sys,Struct(1).subs,rhs);
         catch
            error(lasterr)
         end
         
      else
         % First reassign tmp = sys(indices)
         try
            tmp = subsasgn(subsref(sys,Struct(1)),Struct(2:end),rhs);
         catch
            error(lasterr)
         end
         
         % Then set sys(indices) to tmp
         try
            sys = indexasgn(sys,Struct(1).subs,tmp);
            
         catch
            error(lasterr)
         end
         
      end
   catch
      error(lasterr)
   end
   
case '{}'
   sys = setexp(sys,Struct(1).subs{1},rhs);
   %error('Cell contents reference from a non-cell array object')
   
otherwise
   error(['Unknown type: ' Struct(1).type])
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function    sys = indexasgn(sys,indices,rhs);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isempty(rhs)
   sys = emptyasg(sys,indices);
   return
end

ln=length(indices);
ind=indices{1}; 
if islogical(ind),ind=find(ind);end

if strcmp(ind,':'),newindex=0;else newindex=1;end  
if ln>1
   indy=indices{2}; 
else 
   indy=':';
end
[N,ny,nu,ne] = size(sys);
if ~isa(rhs,'iddata')
   error('The assigning variable must be an iddata object or empty.')
end

if strcmp(indy,':'),indy=1:ny;end
if isstr(indy)&~(strcmp(indy,':'))|iscell(indy)
   [indy,newnamey] = indname(indy,sys.OutputName,'Output','add',rhs.OutputName);
else
   newnamey = rhs.OutputName;
end

if ln>2
   indu=indices{3};
else 
   indu=':';
end
if strcmp(indu,':'),indu=1:nu;end
if isstr(indu)&~(strcmp(indu,':'))|iscell(indu)
   [indu,newnameu] = indname(indu,sys.InputName,'Input','add',rhs.InputName);
else
   newnameu = rhs.InputName;
end


if ln>3
   indexp=indices{4};
else
   indexp{1}=':';
end
if ~iscell(indexp),indexp={indexp};end
if strcmp(indexp,':'),indexp{1}=1:ne;end
if ischar(indexp)&~(strcmp(indexp,':'))|(iscell(indexp)&ischar(indexp{1}))
   [indexp,newnamee] = indname(indexp,sys.ExperimentName,'Experiment',...
      'add',rhs.ExperimentName);
else
   indexp = indexp{1};
   newnamee = rhs.ExperimentName;
end
if isempty(indexp)
   error('No experiment selected.')
end

mindy = min(indy(find(indy>ny)));
if mindy>ny+1
   error('New output channel numbers must dircetly follow old ones.')
end
mindu = min(indu(find(indu>nu)));
if mindu>nu+1
   error('New input channel numbers must dircetly follow old ones.')
end
minde = min(indexp(find(indexp>ne)));
if minde>ne+1
   error('New experiment numbers must dircetly follow old ones.')
end

 if ~isa(rhs,'iddata')
   error('The Right Hand Side  must be an IDDATA object.')
end
if get(rhs,'nu')~=length(indu)
   error(sprintf(['The indicated number of input channels does not ',...
         'match the right hand side. \n If you have specified several new input',...
          ' channels by name, use curly brackets.\n (dat(:,:,{''name1'',''name2''})).']))
end
if get(rhs,'ny')~=length(indy)
     error(sprintf(['The indicated number of output channels does not ',...
         'match the right hand side. \n If you have specified several new output',...
          ' channels by name, use curly brackets.\n (dat(:,{''name1'',''name2''})).']))
end
if get(rhs,'Ne')~=length(indexp)
   error('The indicated number of experiments does not math the right hand side.')
end
yname=sys.OutputName;
uname=sys.InputName;
yunit=sys.OutputUnit;
uunit=sys.InputUnit;
y=sys.OutputData;
yn=rhs.OutputData;
u=sys.InputData;
un=rhs.InputData;
ts=sys.Ts;
tstart=sys.Tstart;
samp=sys.SamplingInstants;
period=sys.Period;
intsa=sys.InterSample;
kc=1;  %  
for ke=indexp
   replaceflag = 0;
   if ke<=size(sys,4);
      if strcmp(ind,':'), 
         ind = 1:size(yn{kc},1);
         ln=length(ind);%size(y{ke},1);
         replaceflag = 1;
      else 
         ln=length(ind);
              end
      if size(yn{kc},1)~=ln
         error('The number of data points in the RHS does not match the index in the LHS.')
      end
      if ~isempty(samp{ke})
          if rhs.Domain == 'Frequency' % Reason is that SamplingInstants may be empty in TD
         news=pvget(rhs,'SamplingInstants');
     else
         news = get(rhs,'SamplingInstants');
     end
         if ~iscell(news),news={news};end
         samp{ke}(ind)=news{kc};
      end
      
   end
   
   y{ke}(ind,indy)=yn{kc};
   
   u{ke}(ind,indu)=un{kc};
   if replaceflag
      y{ke}=y{ke}(1:length(ind),:);
      u{ke}=u{ke}(1:length(ind),:);
   end
   
   ts(ke)=rhs.Ts(kc);
   tstart(ke)=rhs.Tstart(kc);
   period{ke}(indu,1)=rhs.Period{kc};
   ku1=1;
   for ku=indu
      intsa{ku,ke}=rhs.InterSample{ku1,kc};
      ku1=ku1+1;
   end
   kc=kc+1;
end
[dum,newnameu,ov] = defnum3(sys.InputName,'u',newnameu,indu);
if ~isempty(ov)
   error('Some new input channels have specified names that coincide with old ones.')
end
[dum,newnamey,ov] = defnum3(sys.OutputName,'y',newnamey,indy);
if ~isempty(ov)
   error('Some new output channels have specified names that coincide with old ones.')
end
[dum,newnamee,ov] = defnum3(sys.ExperimentName,'Exp',newnamee,indexp);
if ~isempty(ov)
   error('Some new Experiments have specified names that coincide with old ones.')
end
if ~isempty(indy)
   yname(indy)=newnamey; 
end
if ~isempty(indu)
   uname(indu)=newnameu; 
end

ename=sys.ExperimentName;
ename(indexp)=newnamee;
yunit(indy)=rhs.OutputUnit;
uunit(indu)=rhs.InputUnit;
try
   sys=pvset(sys,'InputData',u,'OutputData',y,'InputName',uname,...
      'OutputName',yname,'OutputUnit',yunit,'InputUnit',uunit,...
      'SamplingInstants',samp,'Ts',ts,'Tstart',tstart,...
      'Period',period,'InterSample',intsa,'ExperimentName',ename);
catch    
   error(lasterr)
end
