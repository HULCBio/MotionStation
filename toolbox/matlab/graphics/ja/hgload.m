% HGLOAD   �t�@�C������Handle Graphics�I�u�W�F�N�g�����[�h
%
% H = HGLOAD('filename')�́A'filename'�Ŏw�肳�ꂽMAT�t�@�C��������΁A
% handle graphics�I�u�W�F�N�g�Ƃ��̎q�I�u�W�F�N�g�����[�h���܂��B'filename' ��
% �g���q���܂܂Ȃ��ꍇ�́A�g���q '.fig' ���t���������܂��B
%
% [H, OLD_PROPS] = HGLOAD(..., PROPERTIES) �́APROPERTIES ���̒l��
% �g����.fig�t�@�C�����Ɋi�[���ꂽ�ŏ�ʃ��x���̃v���p�e�B��ύX���A�����
% �̈ȑO�̒l���o�͂��܂��BPROPERTIES �́A�t�B�[���h������]����v���p
% �e�B�l���܂ރv���p�e�B���ł���A�\���̂łȂ���΂Ȃ�܂���BOLD_PROPS 
% �́A�e�I�u�W�F�N�g�̕ύX���ꂽ�v���p�e�B�̌��̒l���܂ށAH�Ɠ��������̃Z
% ���z��Ƃ��ďo�͂���܂��B�e�Z���́A�t�B�[���h�����v���p�e�B���ł���\��
% �̂��܂݂܂��B�t�B�[���h���́A�ŏ�ʃ��x���I�u�W�F�N�g�ɑ΂���e�v���p
% �e�B�̃I���W�i���̒l���܂݂܂��BPROPERTIES �Ŏw�肳��A�t�@�C�����̍�
% ��ʃ��x���I�u�W�F�N�g�ɂȂ��v���p�e�B�́A�o�͂����I���W�i���̒l�̍\��
% �̂ɂ͊܂܂�܂���B
.
% HGLOAD(..., 'all') �́A�t�@�C�����ɕۑ�����Ă����V���A���I�u�W�F�N�g�������[�h
% ���珜�O����f�t�H���g�̋�����ύX���܂��BFIG-�t�@�C���̒��Ɋ܂܂�Ă����
% ���ł��A��V���A���ƃ}�[�N���ꂽ�f�t�H���g�̃c�[���o�[��f�t�H���g�̃��j���[��
% �悤�ȃA�C�e���́A�ʏ�̂悤�ɂ̓����[�h����܂���B����́Afigure �̍쐬����
% �ʁX�ȃt�@�C�����烍�[�h����Ă��邩��ł��B����́A���ɑ��݂��Ă��� FIG �t�@
% �C���ɉe����^���Ȃ��ŁA�f�t�H���g�̃��j���[��c�[���o�[�̉������s�����Ƃ���
% ���܂��BHGLOAD �� 'all' ��n�����Ƃ́A�t�@�C���̒��Ɋ܂܂�Ă����V���A������
% �ꂽ�I�u�W�F�N�g���A�ă��[�h����邱�Ƃ�ۏ؂��܂��BHGSAVE �̃f�t�H���g�̋���
% �́A�ۑ����Ƀt�@�C�������V���A�������ꂽ�I�u�W�F�N�g�����O���AHGSAVE �� 'all' 
% �t���O���g���ď����������܂��B
% 
% �Q�l�F HGSAVE, HANDLE2STRUCT, STRUCT2HANDLE.
%



% $Revision: 1.8 $
%   Copyright 1984-2002 The MathWorks, Inc. 
