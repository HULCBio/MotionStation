% function [gostop,op,iblk,ord,irow,icol,perctol,maxord,m1,m2] = ...
% 		fitchose(c,blk,iblk,irow,icol,fitstat,pimp,curord,...
% 			perctol,maxord);

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.9.2.3 $

function [gostop,op,iblk,ord,irow,icol,perctol,maxord,m1,m2] = ...
		fitchose(c,blk,iblk,irow,icol,fitstat,pimp,curord,...
			perctol,maxord);

	gostop=[]; op=[]; ord=[]; m1=[]; m2=[];

	num = str2double(c);
	if ~isempty(num) & ~isnan(num)
		if floor(num)==ceil(num) & num >= 0
			ord = num;
			op = 'newfit';
			m1 = ['     Fitting with order = ' int2str(ord) '...'];
			m2 = ['Done'];
			gostop = 1;
		else
			m1 = 'Order should be Nonegative Integer';
			op = 'tryagain';
			gostop = 1;
		end
	elseif strcmp(deblank(c),'ch')
		gostop = 1;
		op = 'hold';
		disp('  Choices:')
		disp('		nd	Move to Next D-scaling');
		disp('		nb	Move to Next D-Block');
		disp('		i	Increment Fit Order');
		disp('		d	Decrement Fit Order');
		disp('		apf	Auto-PreFit');
		disp('		mx 3	Change Max-Order to 3');
		disp('		at 1.01	Change Auto-Prefit Tol to 1.01');
		disp('		0	Fit with zeroth order');
		disp('		2	Fit with second order');
		disp('		n	Fit with n''th order');
		disp('		e	Exit with Current Fittings');
		disp('		s	See Status');
		m1 = [];
		m2 = [];
	elseif strcmp(deblank(c),'apf')	% autofit (overrides your choises)
		m1 = 'Starting Auto-PreFit...';
		op = 'autofit';
		gostop = 1;
		m2 = 'Done';
	elseif strcmp(deblank(c),'s')	%
		m1 = ' ';
		op = 'status';
		gostop = 1;
		m2 = ' ';
	elseif strcmp(deblank(c),'nd')		% moves to next d
		nblk = size(blk,1);
		if blk(iblk,2) == 0 & blk(iblk,1) > 1
			if irow == blk(iblk,1) & icol == blk(iblk,1)
				irow = 1;
				icol = 1;
				if iblk == nblk
					iblk = 1;
				else
					iblk = iblk + 1;
				end
			elseif irow == blk(iblk,1) & icol < blk(iblk,1)
				irow = 1;
				icol = icol + 1;
			elseif irow < blk(iblk,1)
				irow = irow + 1;
			end
		else
			irow = 1;
			icol = 1;
			if iblk == nblk
				iblk = 1;
			else
				iblk = iblk + 1;
			end
		end
		pp = pimp(iblk) + (icol-1)*blk(iblk,1) + (irow-1);
		gostop = 1;
		if fitstat(pp) == 1
			op = 'changedisplay';
		else
			op = 'onlydata';
		end
		m1 = ['     Moving to next scaling entry...'];
		m2 = ['Done'];
	elseif strcmp(deblank(c),'nb')		% moves to (1,1) of next block
		nblk = size(blk,1);
		if iblk == nblk
			iblk = 1;
		else
			iblk = iblk + 1;
		end
		irow = 1;
		icol = 1;
		pp = pimp(iblk) + (icol-1)*blk(iblk,1) + (irow-1);
		gostop = 1;
		if fitstat(pp) == 1
			op = 'changedisplay';
		else
			op = 'onlydata';
		end
		m1 = ['     Moving to next block...'];
		m2 = ['Done'];
	elseif strcmp(deblank(c),'e')		% exits, if done
		if all(fitstat==1)
			gostop = 0;
		else
			fl = min(find(fitstat==0));
			bnum = max(find(pimp<=fl));
			bp = pimp(bnum);
			colnum = floor((fl-bp)/blk(iblk,1)) + 1;
			rownum = fl - bp - (colnum-1)*blk(iblk,1) + 1;
			m1 = ['Fitting is Not Complete: ' ...
					'Block #' int2str(bnum) ', ' ...
					'Row #' int2str(rownum) ', ' ...
					'Col #' int2str(colnum)];
			op = 'tryagain';
			gostop = 1;
		end
	elseif strcmp(deblank(c),'i')		% increment order
		pp = pimp(iblk) + (icol-1)*blk(iblk,1) + (irow-1);
		op = 'newfit';
		gostop = 1;
		if fitstat(pp) == 1
			ord = curord + 1;
		else
			ord = 0;
		end
		m1 = ['     Incrementing fit order to ' int2str(ord) '...'];
		m2 = ['Done'];
	elseif strcmp(deblank(c),'d')		% decrement order
		pp = pimp(iblk) + (icol-1)*blk(iblk,1) + (irow-1);
		if curord > 0 & fitstat(pp) == 1
			ord = curord - 1;
			op = 'newfit';
			gostop = 1;
		else
			m1 = 'Can''t Decrease from 0 Order';
			op = 'tryagain';
			gostop = 1;
		end
		m1 = ['     Decrementing fit order to ' int2str(ord) '...'];
		m2 = ['Done'];
	else
		dbc = deblank(c);
		if length(dbc) >2
			if strcmp(dbc(1:2),'mx')
				num = str2double(dbc(3:length(dbc)));
				if floor(num)==ceil(num) & num >= 0
					maxord = num;
					op = 'hold';
					m1 = ['     Changing Max-Ord...'];
					m2 = ['Done'];
					gostop = 1;
				else
					m1 = 'Maxord should be Integer, >=0';
					op = 'tryagain';
					gostop = 1;
				end
			elseif strcmp(dbc(1:2),'at')
				num = str2double(dbc(3:length(dbc)));
				if num > 1
					perctol = num;
					op = 'hold';
					m1 = ['     Changing AutoTol...'];
					m2 = ['Done'];
					gostop = 1;
				else
					m1 = 'AutoTol should be > 1';
					op = 'tryagain';
					gostop = 1;
				end
			else
				m1 = 'Unrecognized Message';
				op = 'tryagain';
				gostop = 1;
			end
		else
			m1 = 'Unrecognized Message';
			op = 'tryagain';
			gostop = 1;
		end
	end
