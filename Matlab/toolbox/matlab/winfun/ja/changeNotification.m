% changeNotification   Windows 9x/NT �f�B���N�g���ύX�̒ʒm
%
% MATLAB�́A�֘A����f�B���N�g�����̃t�@�C�����ύX���ꂽ���Ƃ�MATLAB�ɒ�
% �m����Windows��Change Notification Handle�̋@�\���g�p���܂��B������
% �󋵉��ł́AWindows�͗L���Ȕ����̃n���h����MATLAB�ɗ^���Ȃ����Ƃ���
% ��܂��B��Ȍ����́A����3�ł��B
%
%  * Windows�́Anotification handle���g���ʂ����܂����B
%
%  * �w�肵���f�B���N�g�����Achange notification���T�|�[�g���Ȃ��t�@�C��
%    �V�X�e���ɑ��݂��܂��BSAMBA �t�@�C���T�[�o���t���[�Ŕz�z���Ă���
%    Syntax TAS �t�@�C���T�[�o�Ƒ�����NFS�t�@�C���T�[�o�́A���̐�������
%    ���Ƃ��m���Ă��܂��B
%
%  * �l�b�g���[�N�܂��̓t�@�C���T�[�o�����ݓI��change notification�̓���
%    ��x�点�邽�߂ɁA�ύX���^�C�����[�Ɍ��o����܂���B
%
% MATLAB���Ή�����Change Notification Handle�𓾂邱�Ƃ��ł��Ȃ��Ƃ��́A
% �f�B���N�g���ƃt�@�C���ɑ΂���ύX�������I�Ɍ��o���邱�Ƃ��ł��܂���B
% ���Ƃ��΁A�f�B���N�g���ɒǉ����ꂽ�V�K�̃t�@�C���͉��ł͂Ȃ��A������
% ���ŕύX���ꂽ�֐��̓����[�h����܂���B
%
% �t�@�C���V�X�e�����AUNIX�X�^�C���̃f�B���N�g���̃^�C���X�^���v�̍X�V��
% �T�|�[�g���Ă���(�܂�A�f�B���N�g���̃^�C���X�^���v�́A�t�@�C�����f
% �B���N�g���ɒǉ������Ƃ��ɍX�V�����)�̏ꍇ�A���̃R�}���h�̂�����
% ���܂��͗�����matlabrc.m�t�@�C���ɒǉ����āA�f�B���N�g���̃^�C���X�^��
% �v���e�X�g���邱�Ƃɂ���ĕύX�����o���܂��B
%
%      system_dependent RemotePathPolicy TimecheckDirFile;
%      system_dependent RemoteCWDPolicy  TimecheckDirFile;
%
% �ύX�����o��������ŁA�^�C���X�^���v�̃`�F�b�N�̂��߂Ɏ��Ԃ��K�v�Ȃ�
% �ŁA���\���ቺ����ꍇ������܂��B
%
% �t�@�C���V�X�e�����A(NT�̃t�@�C���V�X�e���̂悤��)UNIX�X�^�C���̃f�B��
% �N�g���̃^�C���X�^���v�̍X�V���T�|�[�g���Ȃ��̏ꍇ�A���̃R�}���h�̂�
% ���ꂩ�܂��͗�����matlabrc.m�t�@�C���ɒǉ����āA�p�ɂɐ�����Ԋu�ŉe��
% ���󂯂��f�B���N�g�����ēǂݍ��݂��邱�Ƃɂ���āA�����I�ɕύX�����o��
% �܂��B
%
%      system_dependent RemotePathPolicy Reload;
%      system_dependent RemoteCWDPolicy  Reload;
%
% �ύX�����o��������ŁA�f�B���N�g���̍ēǂݍ��݂̂��߂Ɏ��Ԃ��K�v�Ȃ�
% �ŁA���\���傫���ቺ����ꍇ������܂��B
%
% �x�����b�Z�[�W��\�����������Ȃ��ꍇ�́A���̃R�}���h��matlabrc.m�ɋL
% �q���邱�Ƃł��ׂĂ̌x����}�����邱�Ƃ��o���܂��B
%
%    system_dependent DirChangeHandleWarn Never;
% 
% �Q�l�FchangeNotificationAdvanced, ADDPATH.



% $Revision: 1.9 $
%   Copyright 1984-2002 The MathWorks, Inc. 
