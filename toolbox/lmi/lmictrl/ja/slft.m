% sys=slft(sys1,sys2,udim,ydim)
%
% 2�̃V�X�e��SYS1��SYS2�̐��`�������ݐڑ����\�����܂��B
%
%		       _________
%          w1 -------->|       |-------> z1
%		       |  SYS1 |
%            +-------->|_______|-------+
%            |	 	               |
%         u  |                         | y
%            |         _________       |
%            +---------|       |<------+
%		       |  SYS2 |
%         z2 <---------|_______|-------- w2
%
% ���ʂ̃V�X�e��SYS�́A(w1,w2)��(z1,z2)�Ɏʑ����܂��B
%
% UDIM��YDIM�́A�x�N�g��u��y�̒����ł��B�ȗ������Ƃ��́A�f�t�H���g�l�ɐ�
% �肳��܂��B
% 
%  * SYS1�̓���/�o�͂�SYS2���������ꍇ
%        UDIM = SYS2�̏o�͐�
%        YDIM = SYS2�̓��͐�
%  * SYS2�̓���/�o�͂�SYS1���������ꍇ
%        UDIM = SYS1�̓��͐�
%        YDIM = SYS1�̏o�͐�
%
% �Q�l�F    SLOOP, SCONNECT, LTISYS.



% Copyright 1995-2002 The MathWorks, Inc. 
