% LSIM  �́A�^����ꂽ�_�C�i�~�b�N�V�X�e�����V�~�����[�V�������܂��B
% 
%   Y = LSIM(MODEL,UE)
%
%  MODEL: IDMODEL �t�H�[�}�b�g�AIDSS, IDPOLY, IDARX, GREYBOX �̂����ꂩ
%         �ŋL�q���ꂽ���f���̃p�����[�^���܂݂܂��B
%
%    UE : ���� - �o�̓f�[�^�AUE = [U E]�B�����ŁAU �́A(���͂Ƃ��Ē�`��
%         ��Ă���M�����܂�)IDDATA �I�u�W�F�N�g�Ƃ��ė^��������̂��A
%         �܂��́Ak �Ԗڂ̓��͂���x�N�g�� Uk �̒��Ɋ܂܂�Ă���s�� U =
%         [U1 U2 ..Un] �Ƃ�����̓f�[�^�ł��B���l�ɁAE ���m�C�Y���͂� 
%         IDDATA �I�u�W�F�N�g���A�܂��́A(�o�̓`�����l�����Ɠ����񐔂�)
%         �s��̂ǂ��炩�ł��BE ���ȗ�����ƁA�m�C�Y�̂Ȃ��V�~�����[�V��
%         ���������܂��B�m�C�Y�̉e���́AMODEL �̒��Ɋ܂܂�镪�U����
%         �X�P�[�����O����Ă��܂��B
%
%      Y�F�V�~�����[�V�����o�́BU �� IDDATA �I�u�W�F�N�g�̏ꍇ�AY �� 
%         IDDATA �I�u�W�F�N�g�Ƃ��ďo�͂���܂����A����ȊO�̏ꍇ�Ak ��
%         �ڂ̏o�̓`�����l���� k ��ɑΉ�����s��ƂȂ�܂��B
%
% UE �������̎����� IDDATA �I�u�W�F�N�g�̏ꍇ�AY �� IDDATA �I�u�W�F�N�g
% �ɂȂ�܂��B
%
% MODEL ���A�����Ԃł���ꍇ�A�܂��A���� U �̒��̏��('Ts' �� 'InterSa-
% mple' �v���p�e�B)�ɏ]���ăT���v�����O����A���̌�AIDDATA �I�u�W�F�N�g
% �ɂ��܂��B
%
% [Y,YSD] = LSIM(MODEL,UE) ���g���āA�V�~�����[�V�����o�͂̐��肳���W
% ���΍� YSD ���v�Z����܂��BYSD �́AY �Ɠ������������Ă��܂��B
%
% Y = LSIM(MODEL,UE,INIT) �́A���̏�����Ԃ̂����ꂩ�ɃA�N�Z�X���܂��B
%       INIT = 'm' (�f�t�H���g) �́A���f���̏�����Ԃ��g�p���܂��B
%       INIT = 'z' �́A�[�������������g�p���܂��B
%       INIT = X0 (��x�N�g��)�B������ԂƂ��āAX0 ���g�p���܂��B
%
% �V�~�����[�V�����⃂�f���쐬�̏ڍׂ́AIDINPUT, IDMODEL ���Q�Ƃ��Ă���
% �����B
% ���f���̕]���́ACOMPARE �� PREDICT ���Q�Ƃ��Ă��������B

% $Revision: 1.2 $ $Date: 2001/03/01 22:55:02 $
%   Copyright 1986-2001 The MathWorks, Inc.
