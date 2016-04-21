function varargout = dspblkdb(action)
% DSPBLKDB Mask helper function for dB block.


% Copyright 1995-2002 The MathWorks, Inc.
% $Revision: 1.5 $ $Date: 2002/04/14 20:57:04 $


if nargin==0, action = 'dynamic'; end

blk=gcb;
isAmp =  strcmp(get_param(blk,'intype'),'Amplitude');


switch action
   
   case 'checkparam'
   
      R = get_param(blk,'R');
      if str2num(R) <= 0
         error('Load resistance must be greater than zero.');
      end
   
      
   case 'dynamic'
      % Enable the Elements edit dialog:
      ena = get_param(blk,'MaskEnables');
      if isAmp==1,
         new_ena = 'on';
      else
         new_ena = 'off';
      end
      
      % Don't dirty model until absolutely necessary:
      if ~strcmp(ena{3},new_ena),
         ena{3} = new_ena;
         set_param(blk,'MaskEnables',ena);
      end
      
   case 'init'
      
      dBtype = get_param(blk,'dBtype');
      
      if isAmp == 1
         R = get_param(blk,'R');
         if str2num(R) <= 0
            str = sprintf('%s \n %s','Invalid','resistance.');
         else
            str = sprintf('%s \n (%s ohm)',dBtype,R);            
         end
      else
         str = dBtype;
      end
             
      varargout{1} = str;
         
   case 'update'
      
      %%%%%%%%% Add eps checkbox %%%%%%%%%%%%%
      if strcmp(get_param(blk,'fuzz'),'on')
         % Add eps to input to protect againts log(0)=-inf
         % Add sum and constant block
         insert_eps_blocks(blk);       
      else
         % Don't add eps: Remove the sum and const blocks
         remove_eps_blocks(blk);
      end   
      
      %%%%%%%%% Convert to popup menu %%%%%%%%
      if strcmp(get_param(blk,'dBtype'),'dBm');
         % Decibels relative to 1 mW (milliWatt)
         % Add sum and constant block
         insert_dbm_blocks(blk);       
      else
         % Decibels: Remove the sum and const blocks
         remove_dbm_blocks(blk);
      end   
            
      %%%%%%%%% Input signal popup menu %%%%%%%
      opts(1).name = 'Magsq'; 
      opts(1).src  = 'built-in/Math'; 
      opts(1).args = {'Operator','magnitude^2'};
      
      opts(2).name = 'R'; 
      opts(2).src  = 'built-in/Gain'; 
      opts(2).args = {'Gain','1/R'};
      
      if isAmp == 1
         % AMPLITUDE: Add the magsq and 1/R blocks  
         replace = 0;
      else
         % POWER: Remove the magsq and 1/R blocks
         replace = 1;         
      end   
      dspskipblk(blk,opts, replace);
   
   otherwise
      error('unhandled case');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function insert_dbm_blocks(blk)
% If the blocks don't exist, then insert them

fullblk  = getfullname(blk);
dbm_blk  = [fullblk '/dbm'];
Sum2_blk = [fullblk '/Sum2'];    

if ~exist_block(blk, 'dbm') & ~exist_block(blk, 'Sum2')
   delete_line(fullblk,'Gain/1','out/1');
   add_block('built-in/Sum',Sum2_blk);
   set_param(Sum2_blk,'Position',[415    25   435    45]);
   add_line(fullblk,'Gain/1','Sum2/1');
   add_line(fullblk,'Sum2/1','out/1');
   
   add_block('built-in/Constant',dbm_blk);
   set_param(dbm_blk,'Value','30');
   set_param(dbm_blk,'Position',[295    74   350   106]);                        
   add_line(fullblk,'dbm/1','Sum2/2');    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function remove_dbm_blocks(blk)
%If the blocks exist, then remove them

fullblk   = getfullname(blk);
dbm_blk  = [fullblk '/dbm'];
Sum2_blk = [fullblk '/Sum2'];    

if exist_block(blk, 'dbm') & exist_block(blk, 'Sum2')
   delete_line(fullblk,'Gain/1','Sum2/1');
   delete_line(fullblk,'dbm/1','Sum2/2');
   delete_line(fullblk,'Sum2/1','out/1');

   delete_block(dbm_blk);
   delete_block(Sum2_blk);
   add_line(fullblk,'Gain/1','out/1')
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function insert_eps_blocks(blk)
% If the blocks don't exist, then insert them

fullblk  = getfullname(blk);
fuzz_blk  = [fullblk '/fuzz'];
Sum1_blk = [fullblk '/Sum1'];    

if ~exist_block(blk, 'fuzz') & ~exist_block(blk, 'Sum1')
   delete_line(fullblk,'in/1','Magsq/1');
   add_block('built-in/Sum',Sum1_blk);
   set_param(Sum1_blk,'Position',[95    20   115    40]);
   add_line(fullblk,'in/1','Sum1/1');
   add_line(fullblk,'Sum1/1','Magsq/1');
   
   add_block('built-in/Constant',fuzz_blk);
   set_param(fuzz_blk,'Value','eps');
   set_param(fuzz_blk,'Position',[15    74    60    96]);                        
   add_line(fullblk,'fuzz/1','Sum1/2');    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function remove_eps_blocks(blk)
%If the blocks exist, then remove them

fullblk   = getfullname(blk);
fuzz_blk  = [fullblk '/fuzz'];
Sum1_blk = [fullblk '/Sum1'];    

if exist_block(blk, 'fuzz') & exist_block(blk, 'Sum1')
   delete_line(fullblk,'in/1','Sum1/1');
   delete_line(fullblk,'fuzz/1','Sum1/2');
   delete_line(fullblk,'Sum1/1','Magsq/1');

   delete_block(fuzz_blk);
   delete_block(Sum1_blk);
   add_line(fullblk,'in/1','Magsq/1')
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function present = exist_block(sys, name)

present = ~isempty(find_system(sys,'searchdepth',1,...
         'followlinks','on','lookundermasks','on','name',name));



% [EOF] dspblkdb.m
