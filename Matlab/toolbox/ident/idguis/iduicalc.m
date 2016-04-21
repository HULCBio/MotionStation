function [result,modelky]=iduicalc(arg,model,ky,ku,ax)
%IDUICALC Unpacks the (vectorized) theta model and provides help to idgenfig.
%   The help is for ff spe and zp.

%   L. Ljung 9-27-94
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.10 $ $Date: 2001/04/06 14:22:36 $
if nargin<5, ax =0;end
if strcmp(arg,'extract')
   [Ny,Nu]=size(model);
   if ku >= 0
      if isa(model,'idpoly')
         result = model;
         return
         else
            [poly,model,flag] = idpolget(model,[],'b');
            end
   else
      [poly,model,flag] = idpolget(model,[],'b');
   end
   %
   if flag&ax>0
    set(ax,'Userdata',model)
   end
   if isempty(poly)
      result = [];
      return
      end
   if ku==0
      result = poly{ky}(1:Nu);
   elseif ku>0
      result = poly{ky}(ku);
   else
      result = poly{ky}(-ku);
   end
   
   
elseif strcmp(arg,'unpack')
   result=model;
   modelky = model(ky,:);
% elseif strcmp(arg,'zp')
%     modelky = model(ky,:);
%     
%     if isa(modelky,'idss')
%         if ssky
%             nu = size(modelky,'nu');
%             %if ku<0,kku=nu+abs(ku);else kku=ku;end
%             kku = ku;
%             zeposd=th2zp(modelky,kku); %%LL%%!!
%             
%             if ku<0, zeposd(1,:)=500+abs(ku)+[0 60 20 80];end
%             zeposd(1,:)=zeposd(1,:)+1000*(ky-1);
%             result=zeposd;
%         else
%             result=zp(model,ku,ky); %%LL%%!!
%         end
%         %result=[zepo(:,1) zeposd(:,2) zepo(:,2) zeposd(:,4)];
%     else
%         result=th2zp(model,ku,ky); %%LL%%!!
%     end
end
