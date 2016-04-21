% COMPONENTINFO   MATLAB Excel Builder�R���|�[�l���g�ɑ΂������
%                 ��ދy�ѓo�^
%
% COMPONENTINFO(varargin) �́A0����3�̊Ԃ̓��͂�^���A�R���|�[�l���g��
% �ǂݍ��݋y�юg�p�ɕK�v�Ȃ��ׂĂ̏��̓o�^�Ə��������\���̔z����o��
% ���܂��B
%
% componentinfo �̌Ăяo���ɑ΂����ʓI�ȃV���^�b�N�X�͈ȉ��̒ʂ�ł�:
%
% INFO = COMPONENTINFO([COMPONENT_NAME], [MAJOR_REV], [MINOR_REV])
%
% COMPONENT_NAME (optional) - �R���|�[�l���g��(�啶������������ʂ��܂�)�B
%                             �C���X�g�[�����ꂽ���ׂẴR���|�[�l���g��
%                             �f�t�H���g�ł��B
% MAJOR_REV (optional)      - ���W���[�o�[�W�����i���o�[�B���ׂĂ�
%                             �o�[�W�������f�t�H���g�ł��B
% MINOR_REV (optional)      - �}�C�i�[�o�[�W�����i���o�[�B0���f�t�H���g�ł��B
%
% �R���|�[�l���g�����^����ꂽ�Ƃ��AMAJOR_REV �� MINOR_REV �́A�ȉ���
% �悤�ɉ��߂���܂��B:
% MAJOR_REV > 0 �̏ꍇ�Acomponentinfo �́A����� MAJOR_REV.MINOR_REV ��
% �����o�͂��܂��B
% MAJOR_REV = 0 �̏ꍇ�Acomponentinfo �́A�ł��߂��o�[�W�����̏����o��
% ���܂��B
% MAJOR_REV < 0 �̏ꍇ�Acomponentinfo �́A���ׂẴo�[�W�����̏����o��
% ���܂��B
% �R���|�[�l���g�����^�����Ȃ������ꍇ�A���́A�V�X�e���ɃC���X�g�[��
% ���ꂽ���ׂẴR���|�[�l���g�ɑ΂��ďo�͂���܂��B
%
% ���:
%   INFO = COMPONENTINFO('mycomponent',1,0) - �o�[�W����1.0��"mycomponent"
%                                             �ɑ΂�������o��
%   INFO = COMPONENTINFO('mycomponent')     - "mycomponent"�̂��ׂĂ�
%                                             �o�[�W�����ɑ΂�������o��
%   INFO = COMPONENTINFO                    - �C���X�g�[�����ꂽ���ׂĂ�
%                                             �R���|�[�l���g�ɑ΂������
%                                             �o��


% Copyright 2002 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2003/06/25 14:31:10 $
