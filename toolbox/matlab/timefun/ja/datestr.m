% DATESTR   ���t�̕����񏑎�
% 
% DATESTR(D,DATEFORM) �́A(DATEVEC�ŏo�͂����悤��)���t�x�N�g���܂�
% ��(DATENUM �ŏo�͂����悤��)�V���A���ȓ��t�ԍ� D�A�܂��̓t���[����
% ���t��������A�����ԍ��܂��͕����� DATEFORM �Ŏw�肵������(���L�̕\1)
% ���g�������t������ɕϊ����܂��B�f�t�H���g�ł́ADATEFORM �́AD ����
% �t�A���ԁA���邢�͓��t�Ǝ��Ԃ̗����̂����ꂩ���܂ނ��ɂ��A1�A16�A0
% �̂����ꂩ�ł��B�N��\�킷2�����̕�����́A���݂̔N�𒆐S�Ƃ���100�N
% �̈ȓ��̔N�Ɖ��߂���܂��BDATEFORM �́A���L�̕\2�̂悤�ɏ����g�[�N��
% �ō\������鎩�R�`���̓��t������������܂ނ��Ƃ��ł��܂��BDATESTR �́A
% �w�肵�����R�ȓ��t�����ɂ���ē��tD��\�킵�܂��B
%
% DATESTR(D,DATEFORM,PIVOTYEAR) �́A�N��\�킷2�����̕�����ɑ΂��ẮA
% 100�N�͈̔͂̊J�n�N�Ƃ��Ďw�肵���s�{�b�g�N���g���܂��B�f�t�H���g��
% �s�{�b�g�N�́A���݂̔N�̃}�C�i�X50�N�ł��BDATEFORM = -1 �́A�f�t�H���g
% �̏������g���܂��B
%
% DATESTR(...,'local') �́A���[�J���C�Y���ꂽ�����ŕ�������o�͂��܂��B
% �f�t�H���g('en_US�Ƃ������O�ł�')�́AUS English�ł��B���̈����́A��
% ���V�[�P���X�̈�ԍŌ�łȂ���΂Ȃ�܂���B
%
% �\1: �W����MATLAB���t������`
%
% DATEFORM�ԍ�	     DATEFORM������	      ���
% ==================================================================
%      0             'dd-mmm-yyyy HH:MM:SS'   01-Mar-2000 15:45:17 
%      1             'dd-mmm-yyyy'            01-Mar-2000  
%      2             'mm/dd/yy'               03/01/00     
%      3             'mmm'                    Mar          
%      4             'm'                      M            
%      5             'mm'                     03            
%      6             'mm/dd'                  03/01        
%      7             'dd'                     01            
%      8             'ddd'                    Wed          
%      9             'd'                      W            
%     10             'yyyy'                   2000         
%     11             'yy'                     00           
%     12             'mmmyy'                  Mar00        
%     13             'HH:MM:SS'               15:45:17     
%     14             'HH:MM:SS PM'             3:45:17 PM  
%     15             'HH:MM'                  15:45        
%     16             'HH:MM PM'                3:45 PM     
%     17             'QQ-YY'                  Q1-96        
%     18             'QQ'                     Q1           
%     19             'dd/mm'                  01/03        
%     20             'dd/mm/yy'               01/03/00     
%     21             'mmm.dd,yyyy HH:MM:SS'   Mar.01,2000 15:45:17 
%     22             'mmm.dd,yyyy'            Mar.01,2000  
%     23             'mm/dd/yyyy'             03/01/2000 
%     24             'dd/mm/yyyy'             01/03/2000 
%     25             'yy/mm/dd'               00/03/01 
%     26             'yyyy/mm/dd'             2000/03/01 
%     27             'QQ-YYYY'                Q1-1996        
%     28             'mmmyyyy'                Mar2000        
%     29 (ISO 8601)  'yyyy-mm-dd'             2000-03-01
%     30 (ISO 8601)  'yyyymmddTHHMMSS'        20000301T154517 
%     31             'yyyy-mm-dd HH:MM:SS'    2000-03-01 15:45:17 
%
% �\2: ���R�`�����t�����V���{��
%   
% �V���{���@�����V���{���̉���
% ===================================================================
% yyyy    4���̔N, ��. 1990, 2000, 2002
% yy      2���̔N, ��. 90, 00, 02
% mmmm    calendar locale�ɏ]�������̃t���l�[��, 
%         ��."March", "April" (UK �����USA English locales). 
% mmm     calendar locale�ɏ]�������̍ŏ���3����, 
%	  �@��. "Mar", "Apr" (UK �����USA English locales). 
% mm      �擪�Ƀ[����t���������l�̌�, ��. ../03/..  �܂���../12/.. 
% m       calendar locale�ɏ]�������̑啶���̓�����; ���ʌ݊����̂���.
% dddd    calendar locale�ɏ]���j���̃t���l�[��, 
%         ��. "Monday", "Tueday" (UK �����USA calendar locales). 
% ddd     calendar locale�ɏ]���j���̍ŏ���3����
%	  ��. "Mon", "Tue"(UK �����USA calendar locales). 
% dd      �擪�Ƀ[����t��������, ��. 05/../..  �܂��� 20/../.. 
% d       ���̑啶���̓�����; ���ʌ݊����̂���
% HH      ���ԏ����ɏ]�����B���ԏ���AM | PM ���ݒ肳��Ă���ꍇ�́A
%	   HH �͐擪�Ƀ[����t�����܂���BAM | PM ���ݒ肳��Ă��Ȃ�
%	   �ꍇ�́A�擪�Ƀ[����t�����Ď���\�����܂��B�� 10:20 PM�́A
%	   22:20; 9:00 AM�A�����09:00�Ɠ����ł��B
% MM      �擪�Ƀ[����t���������ƕ��B��. 10:15, 10:05, 10:05 AM.
% SS      �擪�Ƀ[����t��������/��/�b�B��. 10:15:30, 10:05:30, 
%	  10:05:30 AM. 
% PM      �ߑO�܂��͌ߌ�Ƃ��Ď��ԏ�����ݒ�BAM �܂���PM �́A�K�X
%	  ���t������ɕt������܂��B 
%
% ���:
% DATESTR(now)�́AUS English locale�ł́A����̓��t�ɑ΂���
% '24-Jan-2003 11:58:15' ���o�͂��܂��B
% DATESTR(now,2) �́A01/24/03���o�͂��ADATESTR(now,'mm/dd/yy')��
% �����ł��B
% DATESTR(now,'dd.mm.yyyy') �́A24.01.2003 ���o�͂��܂��B
% ��W���̓��t������W����MATLAB���t�����ɕϊ�����ɂ́A�ŏ��ɁADATENUM
% ���g���Ĕ�W�����t��������t�ԍ��ɕϊ����܂��B
% ���Ƃ��΁ADATESTR(DATENUM('24.01.2003','dd.mm.yyyy'),2) �́A01/24/03
% ���o�͂��܂��B
%
% �Q�l�FDATE, DATENUM, DATEVEC, DATETICK.


%   Copyright 1984-2002 The MathWorks, Inc. 
