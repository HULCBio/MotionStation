% N4SID �́A������Ԗ@���g���āA��ԋ�ԃ��f���𐄒肵�܂��B
%   
%   MODEL = N4SID(DATA) 
%   MODEL = N4SID(DATA,ORDER) 
%
%   MODEL : ���肳�ꂽ��ԋ�ԃ��f�����AIDSS �t�H�[�}�b�g�ŏo��
%   DATA  : �o�́A���̓f�[�^�� IDDATA �I�u�W�F�N�g�Őݒ�BHELP IDDATA ��
%           �Q�ƁB
%   ORDER : ���f���̎���(��ԃx�N�g���̎���)�B��̃x�N�g��(���Ƃ��΁A
%           3:10)�Ƃ��ē��͂����ꍇ�A���ׂĂ̏�Ԃ̎����Ɋւ�����Ƃ�
%           �āA�v���b�g�̒��ɗ^�����܂��B( 1 �����傫�����͒x��(�ȉ�
%           �Ɏ��� NK )���w�肷��Ɨ]���ȏ�Ԃ�t�����A���ʂƂ��Ă�莟��
%           �̍������f���ɂȂ�܂��B) ORDER�Ƃ��� 'best' ���w�肷��ƁA
%           1:10 �̃f�t�H���g�����̒�����I������܂��B�f�t�H���g�ł́A
%           'best' �ɂȂ�܂��B
%           ORDER �́AIDSS ���f���I�u�W�F�N�g�Őݒ肷�邱�Ƃ��ł��A����
%           �ꍇ�A���ׂẴ��f���\���ƃA���S���Y���̃v���p�e�B���A���̃I
%           �u�W�F�N�g���瓾�邱�Ƃ��ł��܂��B
%
% MODEL = N4SID(DATA,ORDER,Property_1,Value_1, ...., Property_n,Value_n)
% �́A���f���\���ƃA���S���Y���Ɋ֘A�������ׂẴv���p�e�B��^���邱�Ƃ�
% �ł��܂��B�v���p�e�B��/�l�̑g�̈ꗗ�ɂ��ẮAIDSS ���Q�Ƃ��Ă��������B
% �L���ȃ��f���\���v���p�e�B�́A���̂��̂ł��B
%     'Focus' : ['Prediction'|'Simulation'|�t�B���^|'Stability']
%               'Simu' �� 'Stab' �́A���f���̈��萫��⏞���܂��B
%     'nk': ���ꂼ��̓��͂���̒x���ݒ肵���s�x�N�g��
%     ������Ԃ͏�ɐ��肳��܂����AMODEL �ɔ��f���邽�߂ɂ́A
%     'InitialState' = 'Estimate' ��ݒ肵�Ȃ���΂����܂���B
%     'DisturbanceModel' = 'None' �Ƃ���ƁAK �s��Ƃ��� 0 ���o�͂���A
%     ���f���̈��萫���⏞����܂��B�f�t�H���g�́A'DisturbanceModel' =
%     'None' �ł��B
%
% �v�Z�̂قƂ�ǂ̎��Ԃ́A���U�̐���ɂ�����܂��B'CovarianceMatrix' =
% 'None' �Ƃ��邱�ƂŁA���U�̌v�Z���ȗ����܂��B
%
% �A���S���Y���́A���̃v���p�e�B�ŗ^�����܂��B
%   'N4Weight'      : ['Auto'|'MOESP'|'CVA']  �d�݂̌���B
%                     SVD �̑O�B'Auto' �́A�����I�����s���܂��B
%   'N4Horizon'     : �A���S���Y���Ŏg�p����\�����ʂ̌���B
%      
%    N4Horizon  = [r,sy,su], �����ŁA
%       r  : �ő�\������
%       sy : �\���Ɏg�p����ߋ��̏o�͐�
%       su : �\���Ɏg�p����ߋ��̓��͐�
%       N4Horizon �������̍s�����ꍇ�A�e�s��������܂��B
%       N4Horizon = 'Auto' (�f�t�H���g) �́A�Ó��ȕ��ʂ𐄒肵�܂��B
%       'DisturbanceModel' = 'None' ���f�t�H���g�ŁA���̏ꍇ�Asy = 0 ��
%       �Ȃ�܂��B
%
%   'Trace'         : ['On'|'Off']  'On' �́A�X�N���[����ɁA�K���󋵂�
%                     N4Horizon �̑I���󋵂�\�����܂��B
%   'MaxSize'       : maxsize �v�f���傫���s��͍쐬����܂���B�傫��
%                     ���̂��K�v�ȏꍇ�́A���[�v���g���Ă��������B
%
% �Q�l�F  PEM , HELP IDPROPS

%   M. Viberg, 8-13-1992, T. McKelvey, L. Ljung 9-26-1993.
%   Rewritten; L. Ljung 8-3-2000.


%   Copyright 1986-2001 The MathWorks, Inc.%
