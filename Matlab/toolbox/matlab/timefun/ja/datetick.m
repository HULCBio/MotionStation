% DATETICK   ���t�������������ڐ���̃��x����t���� 
% 
% DATETICK(TICKAXIS,DATEFORM) �́A�w�肵�����̖ڐ���ɁA���t������������
% �ڐ��胉�x����t�������܂��BTICKAXIS �́A������ 'x','y','z' �̂����ꂩ��
% �Ȃ���΂Ȃ�܂���B�f�t�H���g�́A'x' �ł��B���x���́A�����ԍ��܂���
% ������ DATEFORM(���̕\���Q��)�ɏ]���ď���������܂��BDATEFORM �̈�����
% ���͂���Ȃ���΁ADATETICK �͎w�肳�ꂽ�����̃I�u�W�F�N�g�ɑ΂���f�[�^
% �Ɋ�Â��Đ������܂��B�������o�͂��邽�߂ɂ́A�w�肵�����ɑ΂���f�[�^�́A
% (DATENUM �ŏo�͂���悤��)�V���A���ȓ��t�ԍ��łȂ���΂Ȃ�܂���B
%
% DATEFORM�ԍ�         DATEFORM������	     ���
%      0             'dd-mmm-yyyy HH:MM:SS'   01-Mar-2000 15:45:17 
%      1             'dd-mmm-yyyy'            01-Mar-2000  
%      2             'mm/dd/yy'               03/01/00     
%      3             'mmm'                    Mar          
%      4             'm'                      M            
%      5             'mm'                     3            
%      6             'mm/dd'                  03/01        
%      7             'dd'                     1            
%      8             'ddd'                    Wed          
%      9             'd'                      W            
%     10             'yyyy'                   2000         
%     11             'yy'                     00           
%     12             'mmmyy'                  Mar00        
%     13             'HH:MM:SS'               15:45:17     
%     14             'HH:MM:SS PM'             3:45:17 PM  
%     15             'HH:MM'                  15:45        
%     16             'HH:MM PM'                3:45 PM     
%     17             'QQ-YY'                  Q1-01        
%     18             'QQ'                     Q1        
%     19             'dd/mm'                  01/03        
%     20             'dd/mm/yy'               01/03/00     
%     21             'mmm.dd,yyyy HH:MM:SS'   Mar.01,2000 15:45:17 
%     22             'mmm.dd,yyyy'            Mar.01,2000  
%     23             'mm/dd/yyyy'             03/01/2000 
%     24             'dd/mm/yyyy'             01/03/2000 
%     25             'yy/mm/dd'               00/03/01 
%     26             'yyyy/mm/dd'             2000/03/01 
%     27             'QQ-YYYY'                Q1-2001        
%     28             'mmmyyyy'                Mar2000       
%
% DATETICK(...,'keeplimits') �́A���͈̔͂�ێ����āA�ڐ��胉�x������t��
% �x�[�X�ɂ������x���ɕς��܂��B
% 
% DATETICK(...,'keepticks') �́A�ڐ��胉�x���̈ʒu��ς��Ȃ��ŁA���t
% �x�[�X�̃��x����ύX���܂��B'keepticks' �� 'keeplimits' �́A�����Ɏg��
% ���Ƃ͂ł��܂���B
%
% DATETICK(AX,...) �́A�J�����gaxes�ł͂Ȃ��w�肵��axes�𗘗p���܂��B
%
% DATETICK �́A���t�ԍ�����t������ɕϊ����邽�߂� DATESTR ���Ăяo���܂��B
%
% ���(1990�N�̕č��̐l���Ɋ�Â�):
% 
%    t = (1900:10:1990)';      %  ���ԋ��
%    p = [75.995 91.972 105.711 123.203 131.669 ...
%        150.697 179.323 203.212 226.505 249.633]';     % �l��
%    plot(datenum(t,1,1),p)   % �N�𐔒l�f�[�^�ɕϊ����ăv���b�g���܂��B
%    datetick('x','yyyy')     %  x���̖ڐ����4���̔N�̃��x���ɒu�������܂��B
%    
% �Q�l�FDATESTR, DATENUM.


%   Author(s): C.F. Garvin, 4-03-95, Clay M. Thompson 1-29-96
%   Copyright 1984-2002 The MathWorks, Inc. 
