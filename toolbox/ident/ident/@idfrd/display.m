function txtx = display(sys)
%DISPLAY   Pretty-print for IDFRD models.
%
%   DISPLAY(G) is invoked by typing G followed
%   by a carriage return.   
%
 

 
%       Copyright 1986-2003 The MathWorks, Inc.
%       $Revision: 1.13.4.1 $ $Date: 2004/04/10 23:16:40 $

maxCols = 80;

sysName = sys.Name;
if isempty(sysName)
   sysName = inputname(1);
end

 
freq = sys.Frequency;
Ts = sys.Ts; 
[ny,nu,nf] = size(sys.ResponseData);
[Ny,Ny,Nf] = size(sys.SpectrumData);
if isempty(sys.ResponseData)&isempty(sys.SpectrumData)
   text = 'Empty frequency response model.';
   if nargout == 0
      disp(text)
      end
   return
end
text = sprintf(['IDFRD model ',sysName,'.']);
if ny>1, addy = 's';else addy = '';end
if nu >1, addu = 's';else addu ='';end
if nu == 0
  if strcmp(tsflag(sys),'TimeSeries')
   text = str2mat(text,sprintf(['  Contains SpectrumData for %d signal' ...
							     '%s'],Ny,addy));
  else
     text = str2mat(text,sprintf(['  Contains SpectrumData for' ...
		    ' disturbances at %d output%s'],Ny,addy));
     end
else
   text = str2mat(text,sprintf(['  Contains Frequency Response Data for %d output%s ',...
         'and %d input%s'],ny,addy,nu,addu));
   if Ny>0
      text = str2mat(text,sprintf(['  and SpectrumData for disturbances' ...
      ' at %d output%s'],Ny,addy));
   end
end

text = str2mat(text,sprintf('  at %d frequency points, ranging from %0.5g %s to %0.5g %s.',...
   max(nf,Nf),min(freq),sys.Units,max(freq),sys.Units));
inputNames = sys.InputName;
outputNames = sys.OutputName;
yna =[];
for kk=1:length(outputNames)
   yna = [yna,outputNames{kk},', '];
end
una =[];
for kk=1:length(inputNames)
   una = [una,inputNames{kk},', '];
end

text = str2mat(text,sprintf('  Output Channels: %s',yna(1:end-2)));
if nu >0
   text = str2mat(text,sprintf('  Input Channels:  %s',una(1:end-2)));
end 
text = str2mat(text,sprintf('  Sampling time:   %0.5g',sys.Ts));
id = pvget(sys,'InputDelay');
if any(id),
   text = str2mat(text,[sprintf('Input delays (listed by channel): ')...
           sprintf('%0.3g  ',id')]);
end

ei = sys.EstimationInfo;
try 
   meth = ei.Method;
catch
   meth = [];
end

if strcmp(ei.Status(1:3),'Not');
   text = str2mat(text,['  ',ei.Status]);
else
   if ~isempty(ei.DataName)&~isempty(meth)
      text = ...
         str2mat(text,['  Estimated from data set ',ei.DataName,' using ',meth,'.']);
   elseif ~isempty(meth)
      text = str2mat(text,['  Estimated using ',meth,'.']);
   elseif ~isempty(ei.DataName)
      text = str2mat(text,['  Estimated from data set ',ei.DataName,'.']);
   end
end

if nargout == 0
   disp(text)
else
  txtx = text;
end
