% TIMERFIND   �w�肳�ꂽ�v���p�e�B�l�ɂ�� timer �I�u�W�F�N�g�̌��o
%
% OUT = TIMERFIND �́A���������ɑ��݂��邷�ׂĂ� timer �I�u�W�F�N�g��
% �o�͂��܂��Btimer �I�u�W�F�N�g�́A�z�� OUT �Ƃ��ďo�͂���܂��B
%
% OUT = TIMERFIND('P1', V1, 'P2', V2,...)�́A�v���p�e�B���ƃv���p�e�B
% �l���A�����̃p�����[�^�l�̑g�ݍ��킹 P1, V1, P2, V2,... �Ƃ���
% �n���ꂽ���̂ƈ�v���� timer �I�u�W�F�N�g�̔z�� OUT ���o�͂��܂��B
% �p�����[�^�l�̑g�ݍ��킹�́A�Z���z��Ƃ��Ďw�肷�邱�Ƃ��ł��܂��B
%
% OUT = TIMERFIND(S) �́A�v���p�e�B�l���A�t�B�[���h���� timer �I�u�W�F
% �N�g�̃v���p�e�B���ŁA�t�B�[���h�l���K�v�ȃv���p�e�B�l�ł���\���� 
% S ���Œ�`���ꂽ���̂ƈ�v����timer �I�u�W�F�N�g�̔z�� OUT ���o�͂�
% �܂��B
%   
% OUT = TIMERFIND(OBJ, 'P1', V1, 'P2', V2,...) �́A�p�����[�^�l��v
% �������AOBJ ���Ƀ��X�g���ꂽ timer �I�u�W�F�N�g�݂̂ɐ������܂��B
% OBJ �́Atimer �I�u�W�F�N�g�̔z��ł��\���܂���B
%
% TIMERFIND �ւ̓����R�[���Ƃ��āA�p�����[�^�l�̕�����̑g�ݍ��킹�A
% �\���́A����уp�����[�^�l�̃Z���z��̑g�ݍ��킹���g�p���邱�Ƃ�
% �ł��邱�Ƃɒ��ӂ��Ă��������B
%
% �v���p�e�B�l���w�肳�ꂽ�ꍇ�AGET �ŕԂ������̂Ɠ����������g���
% ����΂Ȃ�܂���B�Ⴆ�΁AGET �� 'MyObject' �Ƃ��Ė��O���o�͂���ꍇ�A
% TIMERFIND �́A'myobject' �̖��O�̃v���p�e�B�l�����I�u�W�F�N�g��
% ���o���܂���B�������A�v���p�e�B�l�ɑ΂��ĒT������ꍇ�A�񋓂��ꂽ
% ���X�g�f�[�^�^�C�v�����v���p�e�B�́A�啶���A�������͋�ʂ���܂���B
% �Ⴆ�΁ATIMERFIND �́A'singleShot' �܂��� 'singleshot' �� ExecutionMode 
% �v���p�e�B�l�����I�u�W�F�N�g�����o���܂��B
%
% ���:
%      t1 = timer('Tag', 'broadcastProgress', 'Period', 5);
%      t2 = timer('Tag', 'displayProgress');
%      out1 = timerfind('Tag', 'displayProgress')
%      out2 = timerfind({'Period', 'Tag'}, {5, 'broadcastProgress'})
%
% �Q�l:  TIMER/GET.
%


%    RDD 11-20-2001
%    Copyright 2001-2002 The MathWorks, Inc. 
%   $Revision: 1.1 $  $Date: 2003/04/18 16:32:21 $
