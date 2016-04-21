function datn = emptyasg(sys,index)
% EMPTYASG
% Help function to iddata\subsasgn

%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2001/04/06 14:22:00 $

[N,Ny,Nu,Ne] = size(sys);
ucflag = 0; % This is to handle the automatic ':' that come from dat{ex}
ycflag = 0;
N = max(N);
ind = [1:N];
ln = length(index);
indsamp = index{1};
if islogical(indsamp),
   indsamp=find(indsamp);
end

if strcmp(indsamp,':')
   indsamp =[];
end
if ~isempty(indsamp)
   try
      if all(indsamp==[1:N])
         indsamp =[];
      end
   catch
   end
end
if ln>1
   yind = index{2};
else
   yind = [];
end
if strcmp(yind,':')
   yind = [1:Ny];
   ycflag = 1;
end

if ischar(yind)
   yind = {yind};
end
if iscell(yind)
   yyi=[];
   for kk = 1:length(yind)
      if ~ischar(yind{kk})
         error('Use ''[ ]'' to enclose channel numbers.')
      end
      
      yi = find(strcmp(yind{kk},sys.OutputName));
      if isempty(yi)
         warning(['Output ',yind{kk},' not found.'])
      end
      
      yyi=[yyi,yi];
   end
   yind = yyi;
end
if any(yind>Ny)|any(yind<1)
   error('Output indices out of range.')
end

if ln>2
   uind = index{3};
else
   uind = [];
end
if strcmp(uind,':')
   uind = [1:Nu];
   ucflag = 1;
end
if ischar(uind)
   uind = {uind};
end
if iscell(uind)
   yyi=[];
   for kk = 1:length(uind)
      if ~ischar(uind{kk})
         error('Use ''[ ]'' to enclose channel numbers.')
      end
      
      yi = find(strcmp(uind{kk},sys.InputName));
      if isempty(yi)
         warning(['Input ',uind{kk},' not found.'])
      end
      
      yyi=[yyi,yi];
   end
   uind = yyi;
end
if isa(uind,'double')
   if any(uind>Nu)|any(uind<1)
      error('Input indices out of range.')
   end
end

if ln >3
   exind = index{4};
else
   exind =[];
end
if iscell(exind)
   exind=exind{1};
end
if ischar(exind)
   exind = {exind};
end
if iscell(exind)
   yyi=[];
   for kk = 1:length(exind)
      if ~ischar(exind{kk})
         error('Use ''[ ]'' to enclose Experiment numbers (when given as numbers).')
      end
      
      yi = find(strcmp(exind{kk},sys.ExperimentName));
      if isempty(yi)
         warning(['Experiment ',exind{kk},' not found.'])
      end
      
      yyi=[yyi,yi];
   end
   exind = yyi;
end
if any(exind>Ne)|any(exind<1)
   error('Experiment indices out of range.')
end
yy = [1:Ny];
yy(yind) = [];
uu = [1:Nu];
uu(uind) = [];
ee = [1:Ne];
ee(exind) = [];
if isempty(indsamp)
   ind = ':';
else
   ind(indsamp) = [];
end
Struct.type ='()';
if ~isempty(exind)
   if  ucflag 
      uu=':';
   end
   if ycflag
      yy=':';
   end
end
if isempty(ee)
   datn = iddata;
else
   Struct.subs ={ind,yy,uu,ee};
   datn = subsref(sys,Struct);
end
