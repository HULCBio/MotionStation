% CDFINFO   CDF�t�@�C���Ɋւ���ڍׂ̎擾
%
% INFO = CDFINFO(FILE) �́ACommon Data Format(CDF)�t�@�C���Ɋւ���
% �����o�͂��܂��BINFO �́A���̃t�B�[���h���܂ލ\���̂ł��B
%
%     Filename             �t�@�C�������܂ޕ�����
%
%     FileModDate          �t�@�C���̏C�������܂ޕ�����
%
%     FileSize             �o�C�g�P�ʂŃt�@�C���̃T�C�Y����������
%
%     Format               �t�@�C���t�H�[�}�b�g(CDF)���܂ޕ�����
%
%     FormatVersion        �t�@�C���̍쐬�ɗp����CDF���C�u������
%			   �o�[�W�������܂ޕ�����
%
%     FileSettings         �t�@�C���̍쐬�ɗp���郉�C�u�����ݒ���܂ލ\����
%
%     Subfiles             ������CDF�̏ꍇ��CDF�t�@�C���̃f�[�^���܂�
%			   �t�@�C�����̃Z���z��
%
%     Variables            �t�@�C�����̕ϐ��Ɋւ���ڍׂ��܂ރZ���z��
%			   (���L���Q��)
%
%     GlobalAttributes     �O���[�o��metadata���܂ލ\����
%
%     VariableAttributes   �ϐ��ɑ΂���metadata���܂ލ\����
%
% "Variables" �t�B�[���h�́ACDF�t�@�C�����̕ϐ��Ɋւ���ڍׂ���Ȃ�Z��
% �z����܂݂܂��B�e�s�́A�t�@�C�����̕ϐ���\�킵�܂��B��͈ȉ��̒ʂ�
% �ł��B
%
%     (1) ������Ƃ��Ă̕ϐ���
%
%     (2) MATLAB�̊֐�SIZE�ɏ]�����ϐ��̎���
%
%     (3) ���̕ϐ��ɑ΂��Ċ��蓖�Ă�ꂽ���R�[�h��
%
%     (4) CDF�t�@�C���Ɋi�[�����ϐ��̃f�[�^�^�C�v
%
%     (5) �ϐ��ɑ΂��郌�R�[�h�Ǝ����̐ݒ�̈Ⴂ�B
%         �X���b�V���̍����̒l�́A�l�����R�[�h���Ƃɕω����邱�Ƃ������܂��B
%		  �E���̒l�́A�l���e�����ŕω����邱�Ƃ������܂��B
%
%     (6) �ϐ����R�[�h�̃X�p�[�X���B��蓾��l�́A
%         'Full', 'Sparse (padded)', 'Sparse (nearest)' �ł��B
%
% "GlobalAttributes" �� "VariableAttributes" �\���̂́A�e�����ɑ΂���
% �t�B�[���h���܂݂܂��A�e�t�B�[���h�̖��O�͑����̖��O�ɑΉ����A�t�B�[���h��
% �����ɑ΂�����͒l���܂ރZ���z����܂݂܂��B�ϐ��̑����ɑ΂��ẮA
% �Z���z���1��ڂ͓��͂ɑΉ����� Variable �����܂݁A2��ڂ͓��͒l��
% �܂݂܂��B
%
% ����: CDFINFO �� "GlobalAttributes" �����"VariableAttributes"����
% �t�B�[���h���ɑ΂��ėp���鑮�����́ACDF�t�@�C�����̑������Ƃ͐��m��
% ��v���Ȃ��ꍇ������܂��B�������́AMATLAB�t�B�[���h���Ƃ��Ă͖�����
% �L�����N�^���܂ޏꍇ������̂ŁA�����͗L���ȃt�B�[���h���ɕϊ�����܂��B
% �����̐擪�ɕ\���閳���ȃL�����N�^�͍폜����A���̑��̖����L�����N
% �^�̓A���_�[�X�R�A ('_') �Œu���������܂��B�����̖��O���C�����ꂽ�ꍇ
% �́A�����̓����ԍ��t�B�[���h���̖����ɕt���������܂��B���Ƃ��΁A
% '  Variable%Attribute ' ��'Variable_Attribute_013' �ɂȂ�܂��B
%
% ����: CDFINFO �́ACDF �t�@�C���ɃA�N�Z�X����ꍇ�A�e���|�����t�@�C����
% �쐬���܂��B�J�����g�̍�ƃf�B���N�g���́A�������݉\�ł���K�v������܂��B
%
% �Q�l �F CDFREAD, CDFWRITE.



%   Copyright 1984-2002 The MathWorks, Inc. 
