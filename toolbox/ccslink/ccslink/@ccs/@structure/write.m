function write(st,varargin)
% WRITE Stores a value to the location pointed to by a STRUCTURE object.
% 
% 	WRITE(st,val,member) - writes the value VAL to the STRUCTURE member specified by MEMBER.
%     
% 	WRITE(st,val,member,varargin) - writes the value VAL to the STRUCTURE member specified 
% 	by member, where VARARGIN are extra WRITE options. See WRITE options of MEMBER.
% 
% 	WRITE(st,index,val,member) - writes the value VAL to the STRUCTURE member of the STRUCTURE 
%     element INDEX.
%     
% 	WRITE(st,index,val,member,varargin) - writes the value VAL to the STRUCTURE member of the STRUCTURE 
%     element INDEX, where VARARGIN are extra WRITE options. See WRITE options of MEMBER.
% 
%   NOTE: Structure WRITE just performs the basix write operation:  write(member_obj,value)
%                                                                            
%   If you need to perform a special write operation to a specific struct      
%   member, do the following:                                                  
%   a. Get member object                                                       
%      member_obj = getmember(obj,membername) or                                        
%      member_obj = getmember(obj,index,membername)                                     
%   b. Use special write operation (indexed writing, writebin,...)             
    
%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $  $Date: 2003/11/30 23:13:50 $

if ~ishandle(st),
    error(generateccsmsgid('InvalidHandle'),...
        'First Parameter must be a valid STRUCTURE handle.');
end
if length(varargin)==1
    error(generateccsmsgid('InvalidStructureHandle'),...
        'Structure WRITE can only be used to write to specific structure members.');
end
write_structure(st,varargin);

% [EOF] write.m 