% LIGHT   light�I�u�W�F�N�g�̍쐬
% 
% LIGHT �́A���ׂẴv���p�e�B���f�t�H���g�l�ɐݒ肵��LIGHT�I�u�W�F�N�g���A
% �J�����g��axes�ɒǉ����܂��B
% 
% LIGHT(Param1�AValue1�A...�AParamN�AValueN) �́A�v���p�e�B Param1-ParamN
% �̑g�ɑ΂��āAValue1-ValueN �Ŏw�肵���l�ɐݒ肵��LIGHT�I�u�W�F�N�g���A
% �J�����g��axes�ɒǉ����܂��B
% 
% L = LIGHT(...) �́ALIGHT�I�u�W�F�N�g�̃n���h���ԍ����o�͂��܂��B
%
% LIGHT�I�u�W�F�N�g�́AAXES�I�u�W�F�N�g�̎q�ł��BLIGHT�I�u�W�F�N�g�́A
% �`�悳��܂��񂪁ASURFACE��PATCH�I�u�W�F�N�g�̊O�ςɉe����^���܂��B
% LIGHT�I�u�W�F�N�g�̉e���́AColor�AStyle�APosition�AVisible ���܂�LIGHT
% �̃v���p�e�B�ɂ���Đ��䂳��܂��B���C�g�̈ʒu�́A�f�[�^�͈͓��ł��B
%
% SURFACE��PATCH�I�u�W�F�N�g���LIGHT�I�u�W�F�N�g�̌��ʂ́AAXES�̃v��
% �p�e�B AmbientLightColor �ƁASURFACE��PATCH�̃v���p�e�B AmbientStrength�A
% DiffuseStrength�ASpecularColorReflectance�ASpecularExponent�A
% SpecularStrength,VertexNormals�AEdgeLighting�AFaceLighting�ɂ�萧��
% ����܂��B
%
% figure��Renderer�́ALIGHT�I�u�W�F�N�g��L���ɂ��邽�߂ɁA'zbuffer'�A
% �܂��� 'OpenGL' �̂����ꂩ�ɐݒ肳��Ă��Ȃ���΂Ȃ�܂���(�܂��́A
% figure��RendererMode �́A'auto' �ɐݒ肵�Ȃ���΂Ȃ�܂���)�B
% ���C�e�B���O�̌v�Z�́ARenderer �� 'painters' �ɐݒ肳��Ă���Ƃ���
% �s���܂���B
%
% H ��LIGHT�̃n���h���ԍ��̂Ƃ��ALIGHT�I�u�W�F�N�g�̃v���p�e�B�̃��X�g�ƁA
% ���̃J�����g�l�����邽�߂ɂ́AGET(H) �����s���Ă��������BLIGHT�I�u�W�F
% �N�g�̃v���p�e�B�Ɛݒ�ł���v���p�e�B�l�����邽�߂ɂ́ASET(H) �����s��
% �Ă��������B
%
% �Q�l�FLIGHTING, MATERIAL, CAMLIGHT, LIGHTANGLE, SURF, PATCH.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:55:56 $
%   Built-in function.
