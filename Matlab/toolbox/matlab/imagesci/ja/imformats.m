% IMFORMATS   �t�@�C���̏����̓o�^���Ǘ�
%
% FORMATS = IMFORMATS �́A�t�@�C���t�H�[�}�b�g�����̓o�^���̒l�̂��ׂ�
% ���܂ލ\���̂��o�͂��܂��B���̍\���̂̃t�B�[���h�͈ȉ��̂Ƃ���ł��B:
%
%    ext         - ���̏����ɑ΂���t�@�C���̊g���q�̃Z���z��
%    isa         - �t�@�C���� "IS A" �̃^�C�v�̏ꍇ�ɒ�`���邽�߂̊֐�
%    info        - �t�@�C���ɂ��Ă̏���ǂݍ��ނ��߂̊֐�
%    read        - �C���[�W�f�[�^�t�@�C����ǂݍ��ނ��߂̊֐�
%    write       - MATLAB�f�[�^���t�@�C���ɏ������ނ��߂̊֐�
%    alpha       - ������alpha�`�����l�������ꍇ��1�A����ȊO��0
%    description - �t�@�C�������̃e�L�X�g�̏ڍ�
% 
% isa�Ainfo�A read�A����� write �t�B�[���h�ɑ΂���l�́AMATLAB�̃T�[�`
% �p�X��ɂ���֐����A�܂��́Afunction handle �łȂ���΂Ȃ�܂���B
%
% FORMATS = IMFORMATS(FMT) �́A������ "FMT." ���ŗ^������g���q������
% �����ɑ΂�����m�̏�����T�����܂��B���������ꍇ�A�\���̂́A�L����
% �N�^�Ɗ֐������܂�ŕԂ���܂��B����ȊO�́A��̍\���̂��Ԃ���܂��B
% 
% FORMATS = IMFORMATS(FORMAT_STRUCT) �́A"FORMAT_STRUCT" �\���̓��̒l��
% �܂ޏ����o�^��ݒ肵�܂��B�o�͂̍\���� FORMATS �́A�V�����o�^�ݒ��
% �܂݂܂��B�ȉ��� "Warning" �X�e�[�g�����g���Q�Ƃ��Ă��������B
% 
% FORMATS = IMFORMATS('factory') �́A�t�@�C���̏����o�^���f�t�H���g��
% �����o�^�̒l�ɍĐݒ肵�܂��B����́A���ׂẴ��[�U��`�̐ݒ���폜
% ���܂��B
% 
% IMFORMATS �́A�T�|�[�g���ꂽ�����ɑ΂���t�@�C�������̏��� 
% �e�[�u���ɔC�ӂ̓��͂܂��͏o�͈��� prettyprints �������܂���B
%
% ���[�j���O:
%
%   �����o�^�̊g���@�\��ύX����ɂ́AIMFORMATS ���g�p���Ă��������B
%   �������Ȃ��g�p�@�́A�C���[�W�t�@�C���̓ǂݍ��݂�W���܂��B
%   �g�p�\�ȏ�Ԃɏ����o�^��߂����߂ɁA'factory' �ݒ�ɂ��āA
%   IMFORMATS ���g�p���Ă��������B
%   
% ����:
%
%   �����o�^�̕ύX�́AMATLAB�Z�b�V�����Ԃŕێ����܂���B
%   MATLAB���J�n����Ƃ��ɁA��������ɗ��p�\�ɂ��Ă������߂ɁA
%   $MATLAB/toolbox/local �� startup.m �ɁA�K�؂� IMFORMATS �R�}���h
%   �������Ă��������B
%
%  �Q�l:  IMREAD, IMWRITE, IMFINFO, FILEFORMATS, PATH.


%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/28 01:57:06 $

