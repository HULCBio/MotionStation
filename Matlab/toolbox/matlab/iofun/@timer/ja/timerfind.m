% TIMERFIND   timer �I�u�W�F�N�g�̌��o
%
% OUT = TIMERFIND �́A���������ɂ��邷�ׂĂ� timer �I�u�W�F�N�g��z��
% OUT �ɏo�͂��܂��B
%
% OUT = TIMERFIND('P1', V1, 'P2', V2,...) �́A�p�����[�^/�l�̑g�ݍ��킹
% P1, V1, P2, V2 �Ƃ��ēn���ꂽ�v���p�e�B�l�ƈ�v���� timer �I�u�W�F�N�g
% ��z�� OUT �ɏo�͂��܂��B�p�����[�^-�l�̑g�ݍ��킹�́A�Z���z��Ƃ���
% �w�肷�邱�Ƃ��ł��܂��B
%
% OUT = TIMERFIND(S) �́A�\���� S ���ɒ�`���ꂽ�v���p�e�B�l�ƈ�v����
% timer �I�u�W�F�N�g��z�� OUT �ɏo�͂��܂��BS �̃t�B�[���h���́Atimer 
% �I�u�W�F�N�g�̃v���p�e�B���ŁA�t�B�[���h�̒l�́A�Ή�����v���p�e�B�l
% �ł��B
%   
% OUT = TIMERFIND(OBJ, 'P1', V1, 'P2', V2,...) �́A��v����p�����[�^-�l
% �̑g�ݍ��킹�� timer �I�u�W�F�N�g OBJ �ɐ������܂��BOBJ �́Atimer 
% �I�u�W�F�N�g�̔z��ł��B
%
% �p�����[�^-�l�̕�����̑g�ݍ��킹�̍\���̂ƁA�p�����[�^-�l�̃Z���z��́A
% TIMERFIND �ւ̓����Ăяo�����g�p���邱�Ƃ��ł��܂��B
%
% TIMERFIND �́A�����̃v���p�e�B�ɑ΂��āA�v���p�e�B�l�̌����ɑ啶��
% ����������ʂ��邱�Ƃɒ��ӂ��Ă��������B�Ⴆ�΁A�I�u�W�F�N�g�� Name 
% �v���p�e�B�l�� 'MyObject' �̏ꍇ�A'myobject' ���w�肷��ƁATIMERFIND 
% �́A��v������̂��������܂���B�v���p�e�B�l�̐��m�Ȍ`�����`����ɂ́A
% GET �֐����g�p���Ă��������B�������Ȃ���A�񋓂��ꂽ���X�g�̃f�[�^
% �^�C�v�����v���p�e�B�́A�v���p�e�B�l�ɑ΂��錟�����s���Ƃ��ɑ啶��
% ����������ʂ��܂���B�Ⴆ�΁AExecutionMode �̃v���p�e�B�l�� 
% 'singleShot' �܂��� 'singleshot' �̒l�Ƃ��Ă��ATIMERFIND �́A�I�u
% �W�F�N�g�������邱�Ƃ��ł��܂��B
%
% ���:
%      t1 = timer('Tag', 'broadcastProgress', 'Period', 5);
%      t2 = timer('Tag', 'displayProgress');
%      out1 = timerfind('Tag', 'displayProgress')
%      out2 = timerfind({'Period', 'Tag'}, {5, 'broadcastProgress'})
%
% �Q�l : TIMER/GET.


%    RDD 11-20-2001
%    Copyright 2001-2002 The MathWorks, Inc. 
