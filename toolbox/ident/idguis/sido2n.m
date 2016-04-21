% SCRIPT FILE SIDO2N
% Translates *.sid file-information from SITB ver 4
% to the new format.

%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2001/04/06 14:22:43 $


stopp=0;
eval('board_numbers;','stopp=1;')
if stopp
   errordlg('The file is not an ident session file. Please check file name.','Error Dialog','modal');
   return
end
Data={};
Model={};
[kDc,dum]=size(dats);
[kMc,dum]=size(mods);
for kc = 1:kDc
   datn=['dat',int2str(kc)];
   dai = eval([datn,'_info']);
   datnn = eval(datn);
   
   if ~isa(datnn,'iddata')  
      Ts = eval(deblank(dai(1,:)));
      ny = eval(deblank(dai(2,:)));
      nu = eval(deblank(dai(5,:)));
      Tstart = eval(deblank(dai(3,:)));
      nnu = eval(['[',deblank(dai(7,:)),']']);
      nny = eval(['[',deblank(dai(6,:)),']']);
      inpn=[];outpn=[];
      for kk=1:nu
         inpn{kk,1}=['u',int2str(nnu(kk))];
      end
      for kk=1:ny
         outpn{kk,1}=['y',int2str(nny(kk))];
      end
      data = iddata(datnn(:,1:ny),datnn(:,ny+1:end),Ts);
      % Work around PCODE issue
      eval('ut.axinfo = datp(kc,:);');
      Data{kc} = pvset(data,'Tstart',Tstart,...
         'InputName',inpn,'OutputName',outpn,'Notes',dai(8:end,:),...
         'Name',deblank(dats(kc,:)),'Utility',ut);
   end
end
for kc = 1:kMc
   modn=['mod',int2str(kc)];
   modinfo = eval([modn,'_info']);
   ny = eval(deblank(modinfo(3,:)));
   nu = eval(deblank(modinfo(6,:)));
   nnu = eval(['[',deblank(modinfo(8,:)),']']);
   nny = eval(['[',deblank(modinfo(7,:)),']']);
   inpn=[];outpn=[];
   for kk=1:nu
      inpn{kk,1}=['u',int2str(nnu(kk))];
   end
   for kk=1:ny
      outpn{kk,1}=['y',int2str(nny(kk))];
   end
   
   if strcmp(modinfo(1,1:3),'spa')
      modn = fqf2ido(eval(modn)); %%LL%% When spectrum is involved, think
      % Work around PCODE issue
      eval('ut.axinfo = modp(kc,:);'); 
      modn = pvset(modn,'OutputName',outpn,'InputName',inpn,...
         'Notes',modinfo(9:end,:),...
         'Name',deblank(mods(kc,:)),'Utility',ut);
      
   elseif strcmp(modinfo(1,1:3),'cra')
      modn = eval(modn);
      Nr = size(modn,1);
     % ir = zeros(ny,nu,3,Nr-2);
      kcc = 1;
      for ky = 1:ny
         for ku = 1:nu
            B(ky,ku,:) = modn(3:end,kcc);
            sdir(ky,ku,:) = modn(2,kcc)*ones(1,Nr-2)/2.58;  
            sdstep(ky,ku,:)= cumsum(sdir(ky,ku,:));
            %ir(ky,ku,3,:) = [0:Nr-3]*modn(1,kcc);
            kcc = kcc+1;
         end
      end
      % Work around PCODE issue
      modn = idarx(eye(ny),B,modn(1,1));
      %eval('modn.ir = ir;');
      eval('ut.axinfo = modp(kc,:);');
      eval('ut.impulse.dB = sdir;');
      eval('ut.impulse.dBstep = sdstep;');

      modn = pvset(modn,'InputName',inpn,'OutputName',outpn,...
         'Name',deblank(mods(kc,:)),'Notes',modinfo(9:end,:),...
         'Utility',ut);
                else
      modn = th2ido(eval(modn));
      % Work around PCODE issue
      eval('ut.axinfo = modp(kc,:);');
      modn = pvset(modn,'OutputName',outpn,'InputName',inpn,...
         'Notes',modinfo(9:end,:),...
         'Name',deblank(mods(kc,:)),'Utility',ut);
   end
   Model{kc} = modn;
end
% Work around PCODE issue
eval('Board.nr = board_numbers;');
for kc = 1:length(Board.nr)
   if Board.nr(kc)==1
      notes{kc} = ['This was the main window in the session ',file_name,'.'];
   else
      notes{kc} = eval(['notes',int2str(Board.nr(kc))]);
   end
end
Board.notes = notes;
