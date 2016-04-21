function out=propfixpt(z,action,varargin)
%PROPFIXPT gets fixed-point properties
%   FLIST  = PROPFIXPT(RPTFPMETHODS,'GetFilterList');
%   PLIST  = PROPFIXPT(RPTFPMETHODS,'GetPropList',FILTERNAME);
%   PVALUE = PROPFIXPT(RPTFPMETHODS,'GetPropValue',OBJHANDLES,PROPNAME);
%            We assume that OBJHANDLES is a vector of signal (port)
%            handles or a cell array of block names

% Copyright 1994-2002 The MathWorks, Inc.
%   $Revision: 1.9 $  $Date: 2002/04/10 16:56:34 $

z=rptfpmethods;

switch action
case 'GetFilterList'
   out={
      'main','Main Fixed-Point Properties'
      'slmain','Main Block Properties'
      'mask','Block Mask Properties'
      'signal','Logged Signal Properties'
      'errors','Out-Of-Range Errors'
      'all' 'All Fixed-Point Properties'
      'blkall','All Block Properties'
   };   
case 'GetPropList'
   out=LocGetPropList(varargin{1});
case 'GetPropValue'
   Property=varargin{2};
   Objects=varargin{1};
   
   switch Property
   case LocGetPropList('signal')
      out=LocGetStructInfo(z,Objects,Property);
   case LocGetPropList('errors')
      out=LocGetStructInfo(z,Objects,Property);
   %case LocGetPropList('sim')
   otherwise
      out=propblock(zslmethods,'GetPropValue',Objects,Property);
   end %case Property
end %primary case

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function list=LocGetPropList(filter)

switch filter
case 'main'
   list={
      'OutDataType'
      'Scaling'
      'Min'
      'MinValue'
      'Max'
      'MaxValue'
   };
case 'mask'
   list={
      'OutDataType'
      'OutScaling'
      'LockScale'
      'RndMeth'
      'DoSatur'
      'DblOver'
   };
case 'signal'
   list={
      'Block'
      'DataType' %'Sfcn'
      'MantBits'
      'FixExp'
      'Slope'
      'Bias'
      'Scaling'
      'MinValue'
      'TimeOfMin'
      'MaxValue'
      'TimeOfMax'
      'MinLim'
      'MaxLim'
      'Resolution'
   };
case 'errors'
    list={
        'OverflowOccurred'
        'SaturationOccurred'
        'ParameterSaturationOccurred'
        'DivisionByZeroOccurred'
        };
case 'all'
   list=[LocGetPropList('mask');...
         LocGetPropList('signal');...
         LocGetPropList('errors')];
case 'blkall'
   list=propblock(zslmethods,'GetPropList','all');
case 'slmain'
    list=propblock(zslmethods,'GetPropList','main');
otherwise
   list={};
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=LocGetStructInfo(z,Objects,Property);

numObj=length(Objects);

out=cell(numObj,1);

fpInfo=subsref(z,substruct('.','SignalInfo'));

if isempty(fpInfo)
   blkNames={};
   bIndex=[];
else
   blkNames={fpInfo.Block}';
   [sameNames,aIndex,bIndex]=intersect(blkNames,Objects);
end

if length(bIndex)<numObj
   %some of the objects requested are not present in the
   %data structure
   notLogged=setdiff([1:numObj],bIndex);
   for i=1:length(notLogged)
      blkStruct=signalstruct(z,Objects{notLogged(i)});
      if ~isempty(fpInfo)
         fpInfo(end+1)=blkStruct;
      else
         fpInfo=blkStruct;
      end
      
   end
   
   subsasgn(z,substruct('.','SignalInfo'),fpInfo);
   blkNames={fpInfo.Block}';
   [sameNames,aIndex,bIndex]=intersect(blkNames,Objects);
end

for i=1:length(bIndex)
   out{bIndex(i)}=getfield(fpInfo(aIndex(i)),Property);
end


%for now we'll convert the struct field to cell the stupid way
%improve this for speed
%varValues={};
%for i=length(fpInfo):-1:1
%   varValues{i}=getfield(fpInfo(i),Property);
%end
%
%out(bIndex)=varValues(aIndex);





