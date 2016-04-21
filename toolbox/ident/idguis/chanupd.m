function  chanupd(datas)
%CHANUPD
%
% Updates the channels menues with the input/oupt/experiment names
% of data
%
% If no input argument. The update is made from scratch, be reading
% the data and model boards.


%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2000/02/08 09:04:45 

Xsum = findobj(get(0,'children'),'flat','tag','sitb16');
XID = get(Xsum,'Userdata');
restart = 0;
try
   test = XID.names.unames;
catch
   restart =1;
end
if restart|nargin==0
   
   XID.names.unames ={};
   XID.names.ynames ={};
   XID.names.uynames ={};
   XID.names.yynames ={};
   XID.names.exp ={};
   XID.names.ts =[];
end

flagc = 0;
flage = 0;
unames = XID.names.unames;
uynames = XID.names.uynames;
yynames = XID.names.yynames;
ynames = XID.names.ynames;
xnames = XID.names.exp;
ts = XID.names.ts;
if nargin == 0
end
if ~iscell(datas)
   datas = {datas};
   end
for kk= 1:length(datas)
   data = datas{kk};
   ydatn = pvget(data,'OutputName');
   udatn = pvget(data,'InputName');
    if length(udatn)==0
         tsflag = 1; % marks Time series
      else
         tsflag = 0;
      end

   for ku = 1:length(udatn);  
      nr = find(strcmp(unames,udatn{ku}));
      if isempty(nr) 
         flagc = 1;
         unames = [unames;udatn(ku)];
         uynames{length(unames)} = ydatn;
      else
         yoldn = uynames{nr};
         for ky = 1:length(ydatn)
            if ~any(strcmp(yoldn,ydatn{ky}))
               flagc = 1;
               yoldn = [yoldn;ydatn(ky)];
            end
         end
         uynames{nr} = yoldn;
      end
   end
   for ku = 1:length(ydatn);  
           
      nr = find(strcmp(ynames,ydatn{ku}));
      if isempty(nr) 
         flagc = 1;
         ynames = [ynames;ydatn(ku)];
         yynames{length(ynames)} = ydatn;
         ts(length(ynames)) = tsflag;
      else
         tstemp = (ts(nr)+tsflag>0);
         if tstemp~=ts(nr)
            ts(nr) =tstemp;
            flagc = 1;
            end
         yyoldn = yynames{nr};
         for ky = 1:length(ydatn)
            if ~any(strcmp(yyoldn,ydatn{ky}))
               flagc = 1;
               yyoldn = [yyoldn;ydatn(ky)];
            end
         end
         yynames{nr} = yyoldn;
      end
   end
   if isa(data,'iddata')
      Exp = pvget(data,'ExperimentName');
      if length(Exp)>1
         for ku = 1:length(Exp);
            if ~any(strcmp(xnames,Exp{ku}))
               flage = 1;
               xnames = [xnames;Exp(ku)];
            end
         end
      end
   end
end
if flagc|flage
   XID.names.unames = unames;
   XID.names.uynames = uynames;
   XID.names.ynames = ynames;
   XID.names.yynames = yynames;
   XID.names.exp = xnames;
   XID.names.ts = ts;
   set(Xsum,'UserData',XID);
   if flagc
      iduiiono('set',XID.names);
   end
   if flage
      iduiexp('set');
   end
end
