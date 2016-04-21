function outStruct=signalstruct(z,...
   blkName   ,...
   sfcnName  ,...
   outNumber ,...
   inStruct)
%SIGNALSTRUCT
%   SIGNALSTRUCT
%
%   See also

% Copyright 1994-2002 The MathWorks, Inc.
%   $Revision: 1.8 $  $Date: 2002/04/10 16:56:43 $

if nargin<5
   inStruct=[];
   if nargin<4
      outNumber=1;
      if nargin<3
            sfcnName='';
         %try
         %   sfcnName=get_param(blkName,'FunctionName');
         %catch
         %   sfcnName='';
         %end
      end
   end
end

dataType=LocEvalParam(blkName,'OutDataType');
if isempty(dataType) | ~isstruct(dataType)
   dataType=struct('Class','','IsSigned',[],'MantBits',[]);
end

%
% if logging is off for a block, inStruct will be empty or
% it will only contain information about out of range errors.
%
if isempty(inStruct) | ~isfield(inStruct,'DataType')
   %Try to reconstruct as much of the structure as
   %possible given the information we have

   inStruct=LocSlopeAndBias(blkName,dataType);

   outStruct.IsLogged=logical(0);
else
   outStruct.IsLogged=logical(1);
end

defaultFields = {
'Name',      [];
'DataType',  'Unknown';
'MantBits',  [];
'ExpBits',   [];
'FixExp',    0;
'Slope',     1;
'Bias',      0;
'MinValue',  [];
'TimeOfMin', [];
'MaxValue',  [];
'TimeOfMax', [];
'OverflowOccurred', 0;
'SaturationOccurred',0;
'ParameterSaturationOccurred',0;
'DivisionByZeroOccurred',0;
};   
 
for i=1:size(defaultFields,1)
 
    if isfield(inStruct,defaultFields{i,1})
       fldValue  = getfield( inStruct, defaultFields{i,1} );
    else
       fldValue = defaultFields{i,2};
    end
    outStruct = setfield(outStruct, defaultFields{i,1}, fldValue );
end

outStruct.IsSigned=(outStruct.MantBits<0);
outStruct.MantBits=abs(outStruct.MantBits);

switch outStruct.DataType
case 'FixPt'
   outStruct.Resolution = outStruct.Slope * (2^outStruct.FixExp);

   if outStruct.IsSigned
      Qmin=-1*2^(outStruct.MantBits-1);
   else
      Qmin=0;
   end
   Qmax=2^(outStruct.MantBits-outStruct.IsSigned)-1;
   
   outStruct.MinLim=outStruct.Resolution*Qmin+outStruct.Bias;
   outStruct.MaxLim=outStruct.Resolution*Qmax+outStruct.Bias;
case 'FltPt'
   outStruct.Resolution = [];
   max_val = ieeemax( outStruct.ExpBits, outStruct.MantBits );
   outStruct.MinLim= max_val;
   outStruct.MaxLim=-max_val;   
case 'Double'
   outStruct.MantBits = 52;
   outStruct.ExpBits  = 11;
   outStruct.Resolution = [];
   max_val = ieeemax( outStruct.ExpBits, outStruct.MantBits );
   outStruct.MinLim= max_val;
   outStruct.MaxLim=-max_val;   
case 'Single'
   outStruct.MantBits = 23;
   outStruct.ExpBits  =  8;
   outStruct.Resolution = [];
   max_val = ieeemax( outStruct.ExpBits, outStruct.MantBits );
   outStruct.MinLim= max_val;
   outStruct.MaxLim=-max_val;   
otherwise
   outStruct.Resolution = [];
   outStruct.MinLim= [];
   outStruct.MaxLim= [];   
end

outStruct.Block=blkName;
%outStruct.Sfcn=sfcnName;
outStruct.OutputNumber=outNumber;

%-------- SCALING -------------

if strcmp(outStruct.DataType,'FixPt')
   if  ~isempty(outStruct.Slope) & ( outStruct.Slope ~= 1 )
      prettyScaling = sprintf('V=Q*%g',...
         outStruct.Slope*(2^outStruct.FixExp));
   elseif ~isempty(outStruct.FixExp) & ( outStruct.FixExp ~= 0 )
      prettyScaling = sprintf('V=Q*2^%g',outStruct.FixExp);
   else
      prettyScaling = sprintf('V=Q');
   end
   
   if ~isempty(outStruct.Bias)
      if ( outStruct.Bias > 0 )
         prettyScaling = sprintf('%s+%g',prettyScaling,outStruct.Bias);
      elseif ( outStruct.Bias < 0 )
         prettyScaling = sprintf('%s-%g',prettyScaling,-outStruct.Bias);
      end
   end
   
          
   if ~isempty(outStruct.MantBits) & ~isempty(outStruct.IsSigned)
      if ~outStruct.IsSigned
         prettyDataType = sprintf('U%-3d',outStruct.MantBits);
      else
         prettyDataType = sprintf('S%-3d',outStruct.MantBits);
      end
   else
      prettyDataType=outStruct.DataType;
   end
else
   prettyScaling='';
   prettyDataType='';
end      

outStruct.Scaling=prettyScaling;
outStruct.DataType=prettyDataType;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function rez=LocEvalParam(objH,param);

try
   rezString=get_param(objH,param);
   rez=evalin('base',rezString);
catch
   rez=[];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function   myStruct = LocSlopeAndBias(blkName,dataType)

switch dataType.Class
case 'INT'
   myStruct.DataType = 'FixPt';
   myStruct.MantBits=dataType.MantBits * ( (-1)^dataType.IsSigned );
   myStruct.FixExp = 0;
   myStruct.Slope  = 1;
   myStruct.Bias   = 0; 
case 'FIX'
   myStruct.DataType = 'FixPt';
   myStruct.MantBits=dataType.MantBits * ( (-1)^dataType.IsSigned );

   outScale=LocEvalParam(blkName,'OutScaling');
   
   osLen=length(outScale);
   
   if osLen==2
      slope = outScale(1);
      [fslope,fixexp] = log2( slope );
      myStruct.Slope  = fslope * 2;
      myStruct.FixExp = fixexp - 1;
      myStruct.Bias   = outScale(2);
   elseif osLen==1
      slope = outScale(1);
      [fslope,fixexp] = log2( slope );
      myStruct.Slope  = fslope * 2;
      myStruct.FixExp = fixexp - 1;
      myStruct.Bias   = 0;
   else
      myStruct.FixExp = [];
      myStruct.Slope  = [];
      myStruct.Bias   = []; 
   end
case 'FRAC'
   myStruct.DataType = 'FixPt';
   myStruct.MantBits=dataType.MantBits * ( (-1)^dataType.IsSigned );
   myStruct.FixExp = dataType.IsSigned-dataType.MantBits;
   myStruct.Slope  = 1;
   myStruct.Bias   = 0; 
case 'FLOAT'
   myStruct.DataType = 'FltPt';
   myStruct.MantBits = -dataType.MantBits;
   myStruct.ExpBits  =  dataType.ExpBits;
   myStruct.FixExp = [];
   myStruct.Slope  = [];
   myStruct.Bias   = []; 
case 'DOUBLE'
   myStruct.DataType = 'Double';
   myStruct.MantBits = 52;
   myStruct.ExpBits  = 11;
   myStruct.FixExp = [];
   myStruct.Slope  = [];
   myStruct.Bias   = []; 
case 'SINGLE'
   myStruct.DataType = 'Single';
   myStruct.MantBits = 23;
   myStruct.ExpBits  =  8;
   myStruct.FixExp = [];
   myStruct.Slope  = [];
   myStruct.Bias   = []; 
otherwise
   myStruct.DataType = 'Unknown';
   myStruct.FixExp = [];
   myStruct.Slope  = [];
   myStruct.Bias   = []; 
end

%----------------------------------
function max_val = ieeemax( ExpBits, MantBits );
%
% Form the maximum value that can be represented by
% an IEEE STYLE floating point number
%
max_exp       = ((2^ExpBits-2)-(2^(ExpBits-1)-1));
max_norm_frac = (2-2^(-MantBits));
max_val       = max_norm_frac * ( 2^max_exp );

%----------------------------------
