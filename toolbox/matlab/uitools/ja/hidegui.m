% HIDEGUI   GUI�̕\��/��\��
% 
% HIDEGUI �́A�R�}���h���C������A�J�����g��figure���\���ɂ��܂��B
% HIDEGUI(state) �́A�J�����g��figure�̔�\����Ԃ�ݒ肵�܂�(state �́A
% 'on'  'off', 'callback' �̂����ꂩ�ł�)�B
% state = HIDEGUI �́A�J�����g��figure�̔�\����Ԃ��o�͂��܂��B
% HIDEGUI(H,state) �́A�I�u�W�F�N�gH�̔�\����Ԃ�ݒ�܂��͊m�F���܂��B
%
% ���̊֐��́AHandleVisibility �v���p�e�B�ւ̃C���^�t�F�[�X��񋟂��܂��B
% ���̃v���p�e�B�́A�q�I�u�W�F�N�g�̐e�̃��X�g���ŃI�u�W�F�N�g�̃n���h��
% �ԍ������o�\�ł���Ƃ������肵�܂��B�I�u�W�F�N�g�� HandleVisibility ��
% 'off' �̏ꍇ�A�n���h���ԍ��͎q�I�u�W�F�N�g�̐e�̃��X�g���Ŏ��o�\�ł�
% ����܂���B���̃I�u�W�F�N�g�́APLOT�ACLOSE�AGCF�AGCA�AGCO�AFINDOBJ
% �̂悤�ȁA�I�u�W�F�N�g�K�w����I�u�W�F�N�g��]������֐�����́A���o�\
% �ł͂���܂���B�I�u�W�F�N�g�� HandleVisibility ���A'callback' �̏ꍇ�́A
% �n���h���ԍ��̓R�[���o�b�N���͎��o�\�ł����A�R�[���o�b�N�����s�����
% ���Ȃ��Ƃ��ɃR�}���h���C������Ăэ��܂ꂽ�֐�����͌����܂���B
% HandleVisibility �� 'on' �̂Ƃ��A�n���h���ԍ��͏�Ɏ��o�\�ł��B
%
% HandleVisibility �́ANextPlot 'new' �̑ւ��ŁA�R�}���h���C������̊֐�
% ���s�ɂ���ċN����s�K�؂ȃ_���[�W����AGUI��ی삵�܂��BNextPlot 'new'
% �́ANextPlot �ɏ]�� PLOT �̂悤�ȍ����x���O���t�B�b�N�X�֐�����figure��
% �ی삷�����ŁAGCF�AGCA�AGCO�AFINDOBJ �ɂ���ăn���h���ԍ����o�͂���
% ���� CLOSE �܂��� CLOSE('all') �ɂ���đ��삳��邱�Ƃ���A�n���h����
% �ی삵�Ă��܂���ł����B
%
% GUI�̍쐬���ɁAHIDEGUI �܂��� HandleVisibility ���g���ƁA�R�}���h���C��
% ����Ăэ��܂��֐�����GUI��figure�̃n���h���ԍ��́A���̓_�ȍ~�̓I�u
% �W�F�N�g�K�w���ł͎��o�\�ł͂���܂���B���̗��R�ɂ��AGUI�쐬��
% �Ō�ŁAHIDEGUI ���Ăяo�����Ƃ𐄏����܂��B��������ƁAGC F�� GCA ��
% �悤�Ȋ֐��Ɉˑ�����쐬�R�[�h�́A�ʏ�ʂ���s���܂��B


%   Damian Packer, Revised by Loren Dean
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.9.4.1 $ $Date: 2004/04/28 02:08:13 $
