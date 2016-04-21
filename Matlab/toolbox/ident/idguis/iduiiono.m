function [ny,nu,ky,ku] = iduiiono(arg,info,type,win,noclick)
%IDUIIONO Handles everything related to input-output numbers
%      The argument ARG takes the following values
%   'old': With INFO being the data/model info matrix and
%          TYPE being either 'dat' or 'mod', the functionm
%          returns as NU and NY the number of inputs and outputs
%          in the data/model. With WIN containing the physical
%          input and output numbers, KU and KY are returned as
%          the corresponding logical numbers in the representation
%   'set': Sets all the submenus to 'Channel'.
%          INFO may then contain (as row 6) the physical output
%          numbers to be represented and (as row 7) the physical
%          input numbers to be represented in the submenus
%          TYPE contains the plot window numbers for which to set
%          the submenus (default 1 2 4 5 7 13 )
%   'unpack': returns as NY and NU the chosen channel in window
%          number INFO
%   'update': Marks the correct channel

%   L. Ljung 4-4-94
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.14.4.1 $ $Date: 2004/04/10 23:19:46 $

Xsum = findobj(get(0,'children'),'flat','tag','sitb16');
XID = get(Xsum,'Userdata');
ny=[];nu=[];ky=[];ku=[];
npr = noiprefi('e');


if strcmp(arg,'set')
	iduistat('Modifying Channel menus...')
	if isempty(info)
		info = XID.names;
    else %%LL ??
       % info.uynames = {info.ynames,info.ynames};
       % info.yynames = info.uynames;
    end
	
	if nargin<3
		win=[1 2 3 4 5 6 7 13 40];
	else
		win=type;
	end
	
	for kwin=win
		if ~isempty(iduiwok(kwin)) 
			skwin=int2str(kwin);
			try
				oldsubm=get(XID.plotw(kwin,3),'children');
			catch 
				oldsubm=[];
			end
			try
				usd=get(XID.plotw(kwin,3),'Userdata');
                usd = usd{1};
			catch
				usd=[];
			end
			if isempty(usd),usd={-1,-1};end
			delete(idnonzer(oldsubm))
			oldok=0;
			oldstr=[]; 
			%%
			if any(kwin==[1 13])&length(info.unames)>0&any(info.ts) 
				ychan = find(info.ts);
				ynamests = info.ynames(ychan); %extracts the timeseries names
				for kyc=1:length(ynamests)
					sky = ynamests{kyc};
					kycc = ychan(kyc);
					if strcmp(usd{1},sky)&usd{2}==0,
						oldok=1;che=1;
					else 
						che=0;
					end
					sku=0;
					mu=uimenu(XID.plotw(kwin,3),'Label',[sky],...
						'callback',['iduipoin(1);',...
							'iduiiono(''update'',',int2str(kycc),',',...
							int2str(0),',',skwin,');iduipoin(2);']);
					if che,
						%set(mu,'checked','on');
					end
					if kyc==1
						muc=mu;
					end
				end
				if ~oldok,
					str=[': ',ynamests{1}];usd={ynamests{1},0};
					set(XID.plotw(kwin,3),'Userdata',{usd,info});
					%set(muc,'checked','on')
					figna=get(XID.plotw(kwin,1),'name');
					colno=find(figna==':');
					if ~isempty(colno)
						figna=figna(1:colno(1)-1);
					end
					set(XID.plotw(kwin,1),'name',[figna,str]);
				end
			end
			%%%%%%%
            y3men = 0;% only y's in compare  and resid window
            if ~isa(iduigetd('v'),'idfrd')&(kwin==3|kwin==7)
                y3men = 1;
            end
			if (length(info.unames)==0&any(kwin==[6,1,13,14,15]))|y3men
				for kyc=1:length(info.ynames)
					sky = info.ynames{kyc};
					if strcmp(usd{1},sky)&usd{2}==0,
						oldok=1;che=1;
					else 
						che=0;
					end
					sku=0;
					mu=uimenu(XID.plotw(kwin,3),'Label',[sky],...
						'callback',['iduipoin(1);',...
							'iduiiono(''update'',',int2str(kyc),',',...
							int2str(0),',',skwin,');iduipoin(2);']);
					if che,
						set(mu,'checked','on');
					end
					if kyc==1
						muc=mu;
					end
				end
				if ~oldok,
					str=[': ',info.ynames{1}];usd={info.ynames{1},0};
					set(XID.plotw(kwin,3),'Userdata',{usd,info});
					set(muc,'checked','on')
					figna=get(XID.plotw(kwin,1),'name');
					colno=find(figna==':');
					if ~isempty(colno)
						figna=figna(1:colno(1)-1);
					end
					set(XID.plotw(kwin,1),'name',[figna,str]);
				end
			elseif ~(length(info.unames)==0&kwin==2) % u--> menues including noise sources
				nu = length(info.unames);
				ny = length(info.ynames);
				if (nu+ny)*ny>9, %% Could have other criterion
					submen=1;
				else
					submen=0;
				end
				if kwin==4|kwin==5,
					nuseq = [1:nu,-1:-1:-ny];
				else  
					nuseq = 1:nu;
				end
				for kuc=nuseq
					if kuc<0&(kwin==4|kwin==5),
						sku=[npr,info.ynames{-kuc},'->']; 
						rhsname = info.yynames{-kuc};
						nyl = length(rhsname);
					else
						sku=[info.unames{kuc},'->'];%sku=int2str(ku);
						if any(kwin == [14 15])
							rhsname = info.ynames;
						else
							rhsname = info.uynames{kuc};
						end
						nyl = length(rhsname);
					end
					if submen
						dum=uimenu(XID.plotw(kwin,3),'Label',sku);
					end
					for kyc=1:nyl
						sky=rhsname{kyc};
						if submen, 
							far=dum;
						else
							far=XID.plotw(kwin,3);
						end
						mu=uimenu(far,'Label',[sku,sky],...
							'callback',['iduipoin(1);',...
								'iduiiono(''update'',',int2str(kyc),',',int2str(kuc),',',skwin,');iduipoin(2);']);
						if strcmp(usd{1},sky)&strcmp(usd{2},sku) 
							oldok=1;set(mu,'checked','on');
						end
						if kyc==1
							if max(nuseq)>0
								if kuc==1 
									muc=mu;
								end
							elseif kuc ==-1
								muc = mu;
							end
						end
					end
				end  % for ku
				if ~oldok,
					if nu==0
						str=[[': ',npr],info.ynames{1},'->',info.ynames{1}];
						%usd={info.ynames{1}, [[':',npr],info.ynames{1}]};
						usd={info.ynames{1}, [[npr],info.ynames{1}]};
					else
						str=[': ',info.unames{1},'->',info.ynames{1}];
						usd={info.ynames{1},info.unames{1}};
					end
					set(XID.plotw(kwin,3),'Userdata',{usd,info});
					set(muc,'checked','on');
					figna=get(XID.plotw(kwin,1),'name');
					colno=find(figna==':');
					if ~isempty(colno)
						figna=figna(1:colno(1)-1);
					end
					set(XID.plotw(kwin,1),'name',[figna,str]);
				end % if not OK
			end   % if nu==0
		end % if iduigetp
        %%Let here INFO be set at a suitable USERDATA item. Retrieve it
        %%in UPDATE as XID.names
	end    % for kwin
	%      iduistat('')
elseif strcmp(arg,'unpack')
	nn=get(XID.plotw(info,3),'userdata');
    nn=nn{1};
	if isempty(nn),ny=1;nu=1;return,end % This is just a fix for freq resp
	ny=nn(1);
	if length(nn)>1,nu=nn(2);end
elseif strcmp(arg,'update')
	if nargin<5
		curobj=gcbo;%get(gcf,'currentmenu');
	else
		sku=int2str(type);sky=int2str(info);skwin=int2str(win);
		cbf=['iduipoin(1);',...
				'iduiiono(''update'',',sky,',',sku,',',skwin,');iduipoin(2);'];
		curobj=findobj(XID.plotw(win,1),'callback',cbf);
	end
	if nargin<4,win=iduigetp(gcf);end
	usd1=get(XID.plotw(win,3),'UserData');
    usd = usd1{1};
    XID.names = usd1{2};
	if isempty(type), type = 0;end
	if type<0
		una  =[npr,XID.names.ynames{-type}];
		uynames = XID.names.yynames{-type};
	elseif type == 0
		una = 0;
		uynames = XID.names.ynames;
	else
		una = XID.names.unames{type};
		uynames = XID.names.uynames{type};
	end
	
	if strcmp(usd{1},uynames{info})&...
			strcmp(usd{2},una)%usd(1)==info&usd(2)==type,
		return,
	end
	iduistat('Changing channel...')
	chanch=get(XID.plotw(win,3),'children');
	choff=chanch(:);
	for kc=chanch(:)'
		choff=[choff;get(kc,'children')];
	end
	set(choff,'checked','off')
	set(curobj,'checked','on')
	ky=info;ku=type;
	if ku==0
		label=[': ',XID.names.ynames{ky}];%y',int2str(ky)];
	else
		if ku<0,
			label=[': ',[npr,XID.names.ynames{-ku}],'->'];
		else
			label=[': ',XID.names.unames{ku},'->'];%int2str(ku),'->'];
		end
		label=[label,uynames{ky}];%'y',int2str(ky)];
	end
	if ku==0
		usdx = {XID.names.ynames{ky},0};
	elseif ku<0
		usdx ={uynames{ky},[npr,XID.names.ynames{-ku}]};
	else
		usdx = {uynames{ky},XID.names.unames{ku}};
	end
	
	set(XID.plotw(win,3),'Userdata',{usdx,XID.names});
	figna=get(XID.plotw(win,1),'name');
	colno=find(figna==':');
	if ~isempty(colno),
		figna=figna(1:colno(1)-1);
	end
	set(XID.plotw(win,1),'name',[figna,label]);
	
	iduiclpw(win,1);
	iduistat('')
end
