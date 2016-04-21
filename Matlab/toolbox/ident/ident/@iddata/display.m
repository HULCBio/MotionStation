function txt = display(dat)
%IDDATA/DISPLAY
%   Concise information about an IDDATA object.

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.13.2.2 $ $Date: 2004/04/10 23:15:46 $

 
[N,ny,nu,Ne] = size(dat);
yna=dat.OutputName;
una=dat.InputName;yu=dat.OutputUnit;uu=dat.InputUnit; 
exno=dat.ExperimentName;
Ts=dat.Ts; 
name = dat.Name;
if isempty(name)
   name=inputname(1);
end

if ny==0&nu==0
   disp('Empty data set')
   return
end

if nu==1, inp=' input.';else inp=' inputs.';end
if ny==1, outp=' output'; else outp=' outputs';end
dom = dat.Domain;
offs = max(max(cellfun('length',[yna(:); una(:); exno(:)])), 6);
if Ne>1
	
   txt  = sprintf('\n%s domain data set containing %i experiments.\n', dom,Ne);
   if lower(dom(1))=='f'
       txt2 = sprintf('Experiment%sFrequencies%sRange',...
		  repmat(' ',1,offs-3),repmat(' ',1,6));
      freq = dat.SamplingInstants;
      unit = dat.Tstart;
   else
   txt2 = sprintf('Experiment%sSamples%sSampling Interval',...
		  repmat(' ',1,offs-3),repmat(' ',1,6));
   end
   for kn=1:Ne
      thisoffs = offs + 2 - length(exno{kn});
      if lower(dom(1))=='f'
           freq1=freq{kn};
          thistxt = sprintf('   %s%s%8i%s%g to %g %s', exno{kn},repmat(' ',1,thisoffs),...
			                    N(kn), repmat(' ',1,8),min(freq1),max(freq1),unit{kn}); 
      else
      thistxt = sprintf('   %s%s%8i%s%g', exno{kn},repmat(' ',1,thisoffs),...
			                    N(kn), repmat(' ',1,12),Ts{kn});
      end
      txt2 = str2mat(txt2,thistxt);
   end
else
	if strcmp(exno{1},'Exp1')
		prea = '\n';
	else
		prea = ['\nExperiment ',exno{1},'. '];
	end
	if strcmp(lower(dom),'frequency')
		freq = dat.SamplingInstants; freq=freq{1};
		unit = dat.Tstart; unit = unit{1};
		txt = sprintf([prea,'Frequency domain data set with responses at %i',...
				' frequencies,'],N);
		
		txt = str2mat(txt,sprintf('ranging from %0.5g to %0.5g %s',...
			min(freq),max(freq),unit));
	else
		txt = sprintf([prea,'Time domain data set with %i samples.'],N);
	end
	

   if ~isempty(Ts{1}), % Fixa olika samplingsintervall
      txt2=sprintf('Sampling interval: %g %s',Ts{1}, dat.TimeUnit);
   else
      txt2='The data are unequally sampled.';
   end
end
txt = str2mat(txt,txt2,' ');

taby = sprintf('Outputs%sUnit (if specified)',repmat(' ',1,offs));%' '*ones(1,offs));
for ky=1:ny 
   thisoffs = offs + 7 - length(yna{ky});
   taby=str2mat(taby,['   ',yna{ky},' '*ones(1,thisoffs),yu{ky}]);
end

tabu=sprintf('Inputs %sUnit (if specified)',repmat(' ',1,offs));%*ones(1,offs));
for ku=1:nu %Kolla har med antalet
   thisoffs = offs + 7 - length(una{ku});
   tabu=str2mat(tabu,['   ',una{ku},' '*ones(1,thisoffs), uu{ku}]);
end
 
if ny>0,txt = str2mat(txt,taby,' ');end
if nu>0,txt = str2mat(txt,tabu,' ');end
if isnan(dat)
   txt = str2mat(txt,'The data set contains missing data.');
end

if ~nargout
   disp(txt)
end
 
%disp(['To retrieve the data, use ',name,'.y, and ',name,'.u.'])

