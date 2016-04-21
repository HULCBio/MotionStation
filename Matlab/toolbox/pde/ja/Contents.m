% Partial Differential Equation Toolbox
% Version 1.0.5 (R14) 05-May-2004
%
% PDE�A���S���Y��
%   adaptmesh   - �A�_�v�e�B�u���b�V�����쐬��PDE���������܂�
%   assema      - �����}�g���b�N�X�Ǝ��ʃ}�g���b�N�X�ƉE�Ӄx�N�g����g��
%               ���Ă܂�
%   assemb      - ���E��������s��ƃx�N�g����g�ݗ��Ă܂�
%   assempde    - �����}�g���b�N�X�� PDE ���̉E�ӂ�g�ݗ��Ă܂�
%   hyperbolic  - �o�Ȍ^���������܂�
%   parabolic   - �����^���������܂�
%   pdeeig      - �ŗL�l PDE ���������܂�
%   pdenonlin   - ����` PDE ���������܂�
%   poisolv     - �����`�O���b�h��ł̃|�A�\���������̍�����@
%
% ���[�U�C���^�t�F�[�X�A���S���Y���ƃ��[�e�B���e�B
%   pdecirc     - �~�̕`��
%   pdeellip    - �ȉ~�̕`��
%   pdemdlcv    - MATLAB 4.2c Model M-�t�@�C���� MATLAB 5 �Ŏg�����߂ɕϊ�
%   pdepoly     - ���p�`�̕`��
%   pderect     - �����`�̕`��
%   pdetool     - PDE Toolbox �O���t�B�J�����[�U�C���^�t�F�[�X(GUI)
%
% Geometry�A���S���Y��
%   csgchk      - Geometry Description �s��̑Ó����̃`�F�b�N
%   csgdel      - �ŏ��̈�Ԃ̃{�[�_���폜
%   decsg       - Constructive Solid Geometry ���ŏ��̈�ɕ���
%   initmesh    - �O�p�`���b�V����������
%   jigglemesh  - �O�p�`���b�V���̓����_�����炵�A���b�V���̗v�f����ς���
%               �ɗv�f�`���ς��܂�
%   pdearcl     - �p�����[�^�\�����ꂽ���̂ƌʂ̒�������
%   poimesh     - �����`�̌`���ɓ��Ԋu�̃��b�V����`��
%   refinemesh  - �O�p�`���b�V�����ו���
%   wbound      - ���E������ݒ肷��f�[�^�t�@�C���������܂�
%   wgeom       - �`���ݒ肷��f�[�^�t�@�C���������܂�
%
% �v���b�g�֐�
%   pdecont     - �R���^�[�v���b�g��\�����邽�߂̃R�}���h
%   pdegplot    - PDE �`����v���b�g
%   pdemesh     - PDE �O�p�`���b�V�����v���b�g
%   pdeplot     - PDE Toolbox �̃v���b�g�֐�
%   pdesurf     - �T�[�t�F�X�v���b�g��\�����邽�߂̃R�}���h
%
% ���[�e�B���e�B�A���S���Y��
%   dst         - ���U�T�C���ϊ�
%   idst        - �t���U�T�C���ϊ�
%   pdeadgsc    - ���΋��e�K�͂��g���ĎO�p�`��I��
%   pdeadworst  - ���x�̈����Ɋ֌W�̂���O�p�`�v�f��I��
%   pdecgrad    - PDE �̉��̃t���b�N�X(����)�̌v�Z
%   pdeent      - �^�����O�p�`�W���̋ߖT�ɂ���O�p�`�̃C���f�b�N�X
%   pdegrad     - PDE �̉��̌��z���v�Z
%   pdeintrp    - �ߓ_�f�[�^����O�p�`�̒��_�̃f�[�^�ɕ��
%   pdejmps     - �A�_�v�e�B�u�\���o�̂��߂Ɍ덷��]��
%   pdeprtni    - �O�p�`�̒��_�̃f�[�^����ߓ_�̃f�[�^�ɕ��
%   pdesde      - �T�u�h���C���W���ɂ����鋫�E�����̃C���f�b�N�X
%   pdesdp      - �T�u�h���C���W���ɂ�����ߓ_�̃C���f�b�N�X
%   pdesdt      - �T�u�h���C���W���ɂ�����O�p�`�v�f�̃C���f�b�N�X
%   pdesmech    - �\���͊w�̃e���\���֐��̌v�Z
%   pdetrg      - �O�p�`�v�f�̌`��̃f�[�^
%   pdetriq     - �O�p�`�v�f�̐�������l
%   poiasma     - �|�A�\���������̍����\���o�̂��߂ɋ��E��̐ߓ_���獄���}
%               �g���b�N�X��g�ݗ��Ă܂�
%   poicalc     - �����`���b�V����ł̃|�A�\���������̂��߂̍����\���o
%   poiindex    - �����`�O���b�h�̐��������ɂ�����_�̃C���f�b�N�X
%   sptarn      - ��ʉ��X�p�[�X�ŗL�l���������܂�
%   tri2grid    - PDE �̎O�p�`���b�V�����璷���`���b�V���ɕ�Ԃ��܂�
%
% ���[�U��`�A���S���Y��
%   pdebound    - Boundary M-�t�@�C��
%   pdegeom     - Geometry M-�t�@�C��
%
% �f��
%   pdedemo1    - �P�ʉ~��ł̃|�A�\���������̉�
%   pdedemo2    - �w�����z���c�������̉��Ɣ��˔g�̌���
%   pdedemo3    - �ɏ��Ȗʖ��
%   pdedemo4    - �T�u�h���C���������g���� FEM ���̉�
%   pdedemo5    - �����^��PDE�̉�(�M�`��)
%   pdedemo6    - �o�Ȍ^��PDE�̉�(�g��������)
%   pdedemo7    - �A�_�v�e�B�u���b�V����@
%   pdedemo8    - �����`�O���b�h��̃|�A�\��������

%   Copyright 2004 The MathWorks, Inc. 
%   Generated from Contents.m_template revision 1.1.6.1  $Date: 2003/08/29 04:52:48 $
