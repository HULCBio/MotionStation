% CPSELECT �R���g���[���|�C���g�I���c�[��
% CPSELECT �́A2�̊֘A�����C���[�W����R���g���[���|�C���g��I���ł���
% �O���t�B�J�����[�U�C���^�t�F�[�X�ł��B
%
% CPSELECT(INPUT,BASE) �́ACPSTRUCT �ɁA�R���g���[���|�C���g���o�͂���
% ���BINPUT �́ABASE �C���[�W�̍��W�V�X�e���ɁA��荞�ނ��߂ɕK�v�ȃC��
% �[�W�ł��BINPUT �� BASE �́A�O���[�X�P�[���C���[�W���܂ރt�@�C������
% �ʂ��镶����A�܂��́A�O���[�X�P�[���C���[�W�A�܂��́A��������܂ޕ�
% ���̂����ꂩ�ł��B
%
% CPSELECT(INPUT,BASE,CPSTRUCT_IN) �́ACPSTRUCT_IN �ɃX�g�A����R���g��
% �[���|�C���g�̏����W�������� CPSELECT ���N�����܂��B���̃V���^�b�N�X�́A
% CPSTRUCT_IN �ɑO�����ăZ�[�u�����R���g���[���|�C���g������ CPSELECT ��
% �ċN�����܂��B
%
% CPSELECT(INPUT,BASE,XYINPUT_IN,XYBASE_IN) �́A�R���g���[���|�C���g�̏�
% ���̑g�̏W�����g���āACPSELECT ���N�����܂��BXYINPUT_IN �� XYBASE_IN 
% �́A���ꂼ��AINPUT ���W�� BASE ���W���X�g�A���� M �s 2 ��̍s��ł��B
%
% H = CPSELECT(INPUT,BASE,...) �́A�c�[���̃n���h�� H ���o�͂��܂��BDIS-
% POSE(H) �� H.dispose �́A���ɁA�R�}���h���C������c�[�����N���[�Y�ł���
% ���B
%
% �N���X�T�|�[�g
% -------------
% ���̓C���[�W�́Auint8, uint16, double �܂��́Alogical �̂�����̃N���X
% �ł��\���܂���B
%
%   ���
%   --------
% �Z�[�u�����C���[�W�Ƌ��ɁA�c�[�����N�����܂��B
%       aerial = imread('westconcordaerial.png');
%       cpselect(aerial(:,:,1),'westconcordorthophoto.png')
%
% ���[�N�X�y�[�X�C���[�W�ƃ|�C���g�Q�Ƌ��ɁA�c�[�����N�����܂��B
%       I = checkerboard;
%       J = imrotate(I,30);
%       base_points = [11 11; 41 71];
%       input_points = [14 44; 70 81];
%       cpselect(J,I,input_points,base_points);
%
% �Q�l�FCPCORR, CP2TFORM, IMTRANSFORM.


%   Copyright 1993-2002 The MathWorks, Inc.
