function mn = setpname(m,mode)
%SETPNAME   Sets Parameter Names (PName) for black box models.
%
%   M2 = SETPNAME(M1)
%
%   M1 is a model structure of type IDARX, IDPOLY, or IDSS.
%   M2 is retured as the same model, with the Property PName set to
%   mnemonic names for the parameters.
%
%   For IDPOLY models the naming is as follows:
%   A(q)y(t) = [B(q)/F(q)] u(t) + [C(q)/D(q)] e(t).
%   The coefficient for y(t-k) is called 'ak'. The coefficient for u_s(t-k),
%   where s is input channel number s, is called 'bk(1,s)'. If the system is
%   single input '(1,1)' is omitted. Similarly, the F-coefficients are called
%   'fk(1,s)' or 'fk'. The coefficients for q^{-k} in the C and D polynomials
%   are, analogoulsy, called 'ck', and 'dk'. Note that, e.g., M1.a returns the
%   A-polynomial in vector form, including the leading '1' for the zero delay.
%   That means that the parameter with name 'ak' is M1.a(k+1).
%
%   For IDSS models, xn = Ax + Bu + Ke; y = C x + Du + e, the parameters have
%   name according to their matrix element, e.g. 'A(3,1)'.
%
%   For IDARX models 
%      y(t) + A1 y(t-1) + A2 y(t-2) + ... Ana y(t-na) = ...
%                       B0 u(t) + B1 u(t-1) + ... +Bnb u(t-n)
%   Ak are ny-by-ny matrices and Bk are ny-by-nu matrices.
%   The internal representation is implemented as state-space matrices, and
%   therefore the parameters containing the elements of the A-matrices have
%   reversed signs. Consequently, the naming is as follows:
%   The parameter giving the ky,ku element of Br is called 'Br(ky,ku)'.
%   The parameter giving minus the value if the k1,k2 element of Ar is 
%   called '-Ar(k1,k2)'.
%   Note that M1.A is a ny-by-ny-by-(na+1) array so that A(k1,k2,ka+1) has the
%   name '-A(k1,k2,ka)'.
%
%   The parameter names are particularily useful in connection with fixing
%   parameters for the iterative search. See FixedParameter in IDPROPS ALGORITHM.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.8.4.1 $ $Date: 2004/04/10 23:20:25 $


if nargin<2
   mode = 1;
end

if mode < 3
   switch class(m)
   case 'idproc'
       typec = i2type(m);%pvget(m,'Type');
       if ~iscell(typec),typec={typec};end
       nu = length(typec);
       pnam = {};
       for ku=1:nu
           type = typec{ku};
       pn = eval(type(2));
       pname={};
       if nu==1
           ex = [];
       else
           ex = ['(',int2str(ku),')'];
       end
       pname{1} = ['Kp',ex];
       switch pn
       case 0
           if any(type=='D')
               pname{2} = ['Td',ex];
           end
       case {1,2,3}
           
           pname{2} = ['Tp1',ex];
           if pn >= 2;
               if any(type=='U')
                   pname{2} = ['Tw',ex];
                   pname{3} = ['Zeta',ex];
               else
                   pname{3} = ['Tp2',ex];
               end
               if pn ==3
                   pname{4} = ['Tp3',ex];
                   nr = 4;
               else
                   nr = 3;
               end
           else
               nr = 2;
           end
           if any(type=='D')
               pname{nr+1} = ['Td',ex];
               nr = nr+1;
           end
           
           if any(type=='Z')
               pname{nr+1} = ['Tz',ex];
           end
       end
       pnam=[pnam;pname(:)];
   end
   %% Now set the disturbancemodelparameters
   dist = pvget(m,'DisturbanceModel'); dist = dist{1};
   switch dist
       case 'ARMA1'
       pnam = [pnam;{'d1';'c1'}];
   case 'ARMA2'
       pnam=[pnam;{'d1';'d2';'c1';'c2'}];
end
   pname = pnam;
   case 'idpoly'
       na = pvget(m,'na');
       nb = pvget(m,'nb');
       nc = pvget(m,'nc');
       nd = pvget(m,'nd');
       nf = pvget(m,'nf');
       nk = pvget(m,'nk');
       nu = size(nb,2);
       pname = cell(sum([na,nb,nc,nd,nf]),1);
       for ka = 1:na
           pname{ka} = ['a',int2str(ka)];
       end
       snr = na+1; snb = na+sum(nb)+nc+nd+1;
       if nu == 1
           for kb = 1:nb
               pname{na+kb} = ['b',int2str(kb+nk-1)];
           end
           for kf = 1:nf
               pname{na+nb+nc+nd+kf} = ['f',int2str(kf)];
           end
       elseif nu >1
           for ku = 1:nu
               for kb = 1:nb(ku)
                   pname{snr} = ['b',int2str(kb+nk(ku)-1),'(1,',int2str(ku),')'];
                   snr =snr + 1;
               end
               
               for kf = 1:nf(ku)
                   pname{snb} = ['f',int2str(kf),'(1,',int2str(ku),')'];
                   snb =snb + 1;
               end
           end
       end
       for kc = 1:nc
           pname{na+sum(nb)+kc} = ['c',int2str(kc)];
       end
       for kd = 1:nd
           pname{na+sum(nb)+nc+kd} = ['d',int2str(kd)];
       end
   case 'idss'
       as = pvget(m,'As'); bs = pvget(m,'Bs');
       cs = pvget(m,'Cs'); ds = pvget(m,'Ds');
       ks = pvget(m,'Ks'); x0s = pvget(m,'X0s');
       knr = 1;
       for k1 = 1:size(as,1)
           for k2 = 1:size(as,1)
               if isnan(as(k1,k2))
                   pname{knr} = ['A(',int2str(k1),',',int2str(k2),')'];
                   knr = knr+1;
               end
           end
       end
       for k1 = 1:size(bs,1)
           for k2 = 1:size(bs,2)
               if isnan(bs(k1,k2))
                   pname{knr} = ['B(',int2str(k1),',',int2str(k2),')'];
                   knr = knr+1;
               end
           end
       end
       for k1 = 1:size(cs,1)
           for k2 = 1:size(cs,2)
               if isnan(cs(k1,k2))
                   pname{knr} = ['C(',int2str(k1),',',int2str(k2),')'];
                   knr = knr+1;
               end
           end
       end
       for k1 = 1:size(ds,1)
           for k2 = 1:size(ds,2)
               if isnan(ds(k1,k2))
                   pname{knr} = ['D(',int2str(k1),',',int2str(k2),')'];
                   knr = knr+1;
               end
           end
       end
       for k1 = 1:size(ks,1)
         for k2 = 1:size(ks,2)
            if isnan(ks(k1,k2))
               pname{knr} = ['K(',int2str(k1),',',int2str(k2),')'];
               knr = knr+1;
            end
         end
      end
      for k1 = 1:size(x0s,1)
         for k2 = 1:size(x0s,2)
            if isnan(x0s(k1,k2))
               pname{knr} = ['X0(',int2str(k1),',',int2str(k2),')'];
               knr = knr+1;
            end
         end
      end
   case 'idarx'
      par = pvget(m,'ParameterVector');
      na = pvget(m,'na');
      ny = size(na,1);
      par = [1:length(par)]';
      pname = cell(length(par),1);
      m1 = parset(m,par);
      [A,B] = arxdata(m1);
      [dum,nu,nb] = size(B);
      for ka = 1:max(max(na)')+1
         for ky1 = 1:ny
            for ky2 = 1:ny
               pn = A(ky1,ky2,ka);
               if pn<0
                  pname{abs(pn)} = ['-A',int2str(ka-1),'(',int2str(ky1),',',int2str(ky2),')'];
               end
            end
         end
      end
      for kb = 1:nb
         for ky1 = 1:ny
            for ku = 1:nu
               pn = B(ky1,ku,kb);
               if pn>0
                  pname{pn} = ['B',int2str(kb-1),'(',int2str(ky1),',',int2str(ku),')'];
               end
            end
         end
      end
   case 'idgrey'
      error('SETPNAME does not apply to IDGREY models.')
   end
   if mode == 1
      mn = pvset(m,'PName',pname);
   else
      mn = pname;
   end
else % translate IDPOLY/ARX to IDARX
   pname = m;
   for k = 1:length(pname)
      kp = pname{k};
      if kp(1)=='a'
         kp = ['-A',kp(2:end),'(1,1)'];
      elseif ~isempty(findstr(kp,'('))
         
         kp = ['B',kp(2:end)];
      else
         kp = ['B',kp(2:end),'(1,1)'];
      end
      pname{k} = kp;
   end
   mn = pname;
end

   
   