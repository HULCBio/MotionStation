% STARTAT   �w�肳�ꂽ���ԂɃ^�C�}�[���ғ�
%
% STARTAT(OBJ,TIME) �́A�V���A���ȓ��t�ԍ� TIME �Ŏw�肳�ꂽ���ԂɁA
% timer �I�u�W�F�N�g OBJ �ŕ\�����^�C�}�[�̎��s���J�n���܂��BOBJ �́A
% timer �I�u�W�F�N�g�̔z��ł���ꍇ�ASTARTAT �͂��ׂẴ^�C�}�[��
% �w�肳�ꂽ���ԉғ����܂��BTIMER �֐��́Atimer �I�u�W�F�N�g���쐬����
% ���߂Ɏg���܂��B
%
% START �́Atimer �I�u�W�F�N�g OBJ �� Running �v���p�e�B�� 'On' �ɐݒ肵�A
% TimerFcn �R�[���o�b�N�����������AStartFcn �R�[���o�b�N�����s���܂��B
%
% �V���A���ȓ��t�ԍ� TIME �́A1-Jan-0000 ����o�߂������̐��������܂�
% (�J�n��1�ł�)�B�V���A���ȓ��t�ԍ��ɂ��Ă̒ǉ����́ADATENUM ���Q��
% ���Ă��������B
% 
% STARTAT(OBJ,S) �́A���t�̕����� S �Ŏw�肳�ꂽ���ԂɃ^�C�}�[���J�n
% ���܂��B���t�̕�����́ADATESTR �֐��Œ�`���ꂽ 0,1,2,6,13,14,15,16,23 
% �̓��t�̏������g�p���Ȃ���΂Ȃ�܂���B�N��\��2�����̓��t�̕�����́A
% ���݂̔N�𒆐S�Ƃ���100�N�͈͓̔��Ɖ��߂���܂��B
%
% STARTAT(OBJ,S,PIVOTYEAR) �́A�N��\��2�����̏ꍇ�ɁA100�N�͈̔͂��J�n�N
% �Ƃ��āA�w�肵���s�{�b�g�N���g���܂��B�f�t�H���g�̃s�{�b�g�N�́A���݂�
% �N�̃}�C�i�X50�N�ł��B
% 
% STARTAT(OBJ,Y,M,D) �� STARTAT(OBJ, [Y,M,D]) �́A�w�肳�ꂽ�N(Y)�A
% ��(M)�A��(D) �Ƀ^�C�}�[���ғ����܂��BY,M,D�́A�����T�C�Y�̔z��(�܂���
% �X�J��)�łȂ���΂Ȃ�܂���B
% 
% STARTAT(OBJ,Y,M,D,H,MI,S) �� STARTAT(OBJ,[Y,M,D,H,MI,S]) �́A�w�肳�ꂽ
% �N(Y)�A��(M)�A��(D)�A����(H)�A��(MI)�A�b(S) �Ƀ^�C�}�[���ғ����܂��B
% Y,M,D,H,MI,S �́A�����T�C�Y�̔z��(�܂��̓X�J��)�łȂ���΂Ȃ�܂���B
% �e�z��̒ʏ�͈̔͂̊O���̒l�́A�����I�Ɏ��̒P�ʂɈڍs����܂�(�Ⴆ�΁A
% 12�����傫�����̒l�́A�N�Ɉڍs����܂�)�B1�������������̒l�́A1��
% �ݒ肳��A����ȊO�̒P�ʂ͂��ׂĂ܂Ƃ߂��A�L���ȕ��̒l�������܂��B
%
% �ȉ��̏����̈���K�p���ꂽ�ꍇ�A�^�C�}�[���~���܂��B:
%  - ���s���ꂽ TimerFcn �R�[���o�b�N�̐����ATasksToExecute �v���p�e�B
%    �Ŏw�肳�ꂽ���ɓ������Ȃ����ꍇ
%  - STOP(OBJ) �R�}���h�����s���ꂽ�ꍇ
%  - TimerFcn �R�[���o�b�N�̎��s���ɃG���[�����������ꍇ
%
% ���:
%        t1=timer('TimerFcn','disp(''it is 10 o''''clock'')');
%        startat(t1,'10:00:00');
%
%        t2=timer('TimerFcn','disp(''It has been an hour now.'')');
%        startat(t2,now+1/24);
%
% �Q�l : TIMER, TIMER/START, TIMER/STOP, DATENUM, DATESTR, NOW.


%    RDD 11-20-2001
%    Copyright 2001-2002 The MathWorks, Inc. 
%    $Revision: 1.1.4.1 $  $Date: 2004/04/28 01:57:47 $

