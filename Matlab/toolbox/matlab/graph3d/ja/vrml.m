% VRML   �O���t�B�b�N�X��VRML 2.0�t�@�C���ɕۑ�
% 
% VRML(H,FILENAME) �́A�n���h���ԍ��� H �ł���I�u�W�F�N�g�Ƃ��̎q��
% VRML 2.0�t�@�C���ɕۑ����܂��B
% FILENAME ���g���q�������Ȃ���΁A".wrl" ���ǉ�����܂��BFILENAME ��
% �����t�@�C�������݂���΁A�㏑������܂��B
% VRML(H) �́A H �Ƃ��̎q���t�@�C�� "matlab.wrl" �ɕۑ����܂��B
%
% VRML�t�@�C���́A�u���E�U��VRML 2.0�v���O�C�����g���Č��邱�Ƃ��ł��܂��B
% �g�p�\�ȃv���O�C��������������܂��B�v���O�C��Live3D��Cosmoplayer
% �́AVRML�̏o�͂Ɏg�����Ƃ��ł��܂��B�����̃v���O�C���́A����URL��
% ��_�E�����[�h�ł��܂��B
% 
%     http://vrml.sgi.com/cosmoplayer/index.html
%     http://www.netscape.com/comprod/products/navigator/version_3.0...
%           /multimedia/live3d/index.html
% 
% �d�v�_�F
% VRML 1.0�v���O�C���̏ꍇ�AVRML 2.0�t�@�C���͖��Ȃ��ǂ߂܂��B�������A
% �\���͂���܂���BVRML 2.0�v���O�C�����g���Ă��������B
%
% MATLAB�ƃv���O�C���Ԃł́A�����_�����O���قȂ邱�Ƃɒ��ӂ��Ă��������B
% �����̈Ⴂ�̈ꕔ�́A�v���O�C�����������Ă��Ȃ�VRML 2.0 spec�̋@�\��
% �����̂ł��B����ȊO�́AVRML.m���������Ă��Ȃ��@�\�ɂ����̂ł��B
% MATLAB���񋟂��Ă���@�\���AVRML 2.0 spec�̈ꕔ�ł͂Ȃ��ꍇ������܂��B
%
% �v���O�C�����ɃT�|�[�g����Ă���@�\�̏ڍׂɂ��ẮA�x���_�[�̃����[�X
% �m�[�g���Q�Ƃ��Ă��������BCosmoPlayer Beta 3a�ł́A����URL�ɂ���܂��B
% 
%    http://vrml.sgi.com/cosmoplayer/beta3/releasenotes.html.
%
% CosmoPlayer�ŃT�|�[�g����Ă��Ȃ��d�v�ȋ@�\�F
% 
%    �J���[�̕��
%    �e�L�X�g
%    
% ����MATLAB�̋@�\�́AVRML.m�ł̓T�|�[�g����Ă��܂���B������
% �����[�X�Œǉ�����邱�Ƃ�\�肵�Ă��܂��B
% 
%    �e�N�X�`���}�b�v
%    ���̖ڐ���
%    'Box'�v���p�e�B(���on�ɐݒ肳��Ă��܂�)
%    Axes �� X,Y,Z �� Dir �v���p�e�B
%    �}�[�J
%    NaN �̈���
%    �g�D���[�J���[�� CData
%
% ����MATLAB�̋@�\�́AVRML 2.0 spec�ɂ͂���܂���B
% 
%   VRML 2.0�̃��C���X�^�C��
%   ���ˉe
%   Phong���C�e�B���O��Gouraud���C�e�B���O
%   �p�b�`�ƃT�[�t�F�X�I�u�W�F�N�g�̘g�̃��C����'Stitching'


%   R. Paxson, 4-10-97.
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $
