% FREESERIAL    �V���A���|�[�g���MATLAB�z�[���h������
%
% FREESERIAL �́A���ׂẴV���A���|�[�g��MATLAB�̃z�[���h��Ԃ��J����
% �܂��B
%
% FREESERIAL('PORT') �́A�w�肵���|�[�g PORT ���MATLAB�̃z�[���h��
% �Ԃ��J�����܂��BPORT �́A�����񂩂�Ȃ�Z���z��ł��B
%
% FREESERIAL(OBJ) �́A�V���A���|�[�g�I�u�W�F�N�g�Ɋ֘A����|�[�g���
% MATLAB�̃z�[���h��Ԃ��J�����܂��BOBJ �́A�V���A���|�[�g�I�u�W�F�N�g��
% �z��ł��\���܂���B
%   
% �V���A���|�[�g�I�u�W�F�N�g���A�J�����ꂽ�̂܂܂̃|�[�g�ɐڑ����悤�Ƃ���Ƃ�
% �ɂ̓G���[���o�͂���܂��BFCLOSE �R�}���h�́A�V���A���|�[�g����V���A��
% �|�[�g�I�u�W�F�N�g��ؒf����ꍇ�Ɏg���܂��B
%
% FREESERIAL �́A�V���A���|�[�g�I�u�W�F�N�g�����̃|�[�g�ɐڑ����ꂽ��ŁA
% ���̃A�v���P�[�V��������V���A���|�[�g�ɐڑ�����K�v������AMATLAB��
% �I���������Ȃ��ꍇ�ɂ̂ݗ��p����܂��B
% 
% ���ӁF���̊֐��́AWindows �v���b�g�t�H�[���ł̂ݎg���܂��B
%  
% ���:
%      freeserial('COM1');
%      s = serial('COM1');
%      fopen(s);
%      fprintf(s, '*IDN?')
%      idn = fscanf(s);
%      fclose(s)
%      freeserial(s)
%
% �Q�l�FINSTRUMENT/FCLOSE.


%    MP 4-11-00
%    Copyright 1999-2002 The MathWorks, Inc. 
