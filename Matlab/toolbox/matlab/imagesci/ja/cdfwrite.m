% CDFWRITE   CDF�t�@�C���Ƀf�[�^�̏����o��
% 
% CDFWRITE(FILE, VARIABLELIST) �́AFILE �ɂ���Ďw�肳�ꂽ���O��
% CDF�t�@�C���ɏ����o���܂��BVARIABLELIST �́ACDF�ϐ���(����)��
% �Ή�����CDF�ϐ��l���琬�鏇���ɑΉ������Z���z��ł��B�ϐ��ɑ΂���
% �����̃��R�[�h�������o���ɂ́A�Z���z��ɕϐ��̒l�����Ă��������B
% �Z���z�񒆂̊e�v�f�́A���R�[�h���Ӗ����܂��B
%
% CDFWRITE(..., 'PadValues', PADVALS) �́A�^����ꂽ�ϐ����ɑ΂���
% �l�𖄂ߍ��񂾂��̂������o���܂��BPADVALS �́A�ϐ���(����)�ƑΉ�
% ���閄�ߍ��ݒl���琬�鏇���ɑΉ������Z���z��ł��B���O�̃��R�[�h
% ���A�N�Z�X�����Ƃ��A���ߍ��ݒl�͕ϐ��Ɋ֘A����f�t�H���g�l�ł��B
% PADVALS �ɏo�Ă���ϐ����́AVARIABLELIST �ɂ��o�Ă��Ȃ���΂Ȃ��
% ����B
%
% CDFWRITE(..., 'GlobalAttributes', GATTRIB) �́ACDF�ɑ΂���O���[�o��
% meta-data�Ƃ��č\���� GATTRIB �������o���܂��B�\���̂̊e�t�B�[���h�́A
% �O���[�o�������̖��O�ł��B�e�t�B�[���h�̒l�́A�����̒l���܂݂܂��B
% �����ɑ΂��ĕ����̒l�������o���ɂ́A�t�B�[���h�l�̓Z���z��łȂ����
% �Ȃ�܂���B
%
% MATLAB���ŕs���ȃO���[�o�����������w�肷�邽�߂ɂ́A�����̍\���̂�
% ���ɁA"CDFAttributeRename"�ƌĂ΂��t�B�[���h���쐬���Ă��������B
% "CDFAttribute Rename" �́A�����ɑΉ������Z���z��̒l�������Ȃ����
% �Ȃ�܂���BGlobalAttributes �\���̂� CDF �ɏ����o����鑮���ɑΉ�
% ���閼�O�Ƀ��X�g�����悤�ɁA�I���W�i���̑����̖��O�̏����ɑΉ�����
% �\���ɂȂ�܂��B
%
% CDFWRITE(..., 'VariableAttributes', VATTRIB) �́ACDF�ɑ΂���
% meta-data�̕ϐ��Ƃ��č\���� VATTRIB �������o���܂��B�\���̂�
% �e�t�B�[���h�́A�ϐ��̑����̖��O�ł��B�e�t�B�[���h�̒l�́Am ��
% �����̕ϐ��̐��Ƃ���ƁAm�~2 �̃Z���z��ł��B�Z���z��̍ŏ��̗v�f��
% �ϐ����ŁA2�Ԗڂ̗v�f�́A�ϐ��ɑ΂��鑮���̒l�ł���K�v������܂��B
%
% MATLAB���ŕs���ȕϐ��̑��������w�肷�邽�߂ɂ́A�����̍\���̓��� 
% "CDFAttributeRename" �ƌĂ΂��t�B�[���h���쐬���Ă��������B
% "CDFAttributeRename" �t�B�[���h�́A�����ɑΉ������Z���z��̒l��
% �����Ȃ���΂Ȃ�܂���BVariableAttributes �\���̂� CDF �ɏ����o��
% ���Ή����鑮�����Ƀ��X�g�����悤�ɁA�I���W�i���̑����̖��O��
% �����ɑΉ������\���ɂȂ�܂��B���O��ύX����CDF �ϐ��̕ϐ��̑�����
% �w�肷��ꍇ�AVariableAttributes �\���̂̕ϐ����́A���O��ύX����
% �ϐ��Ɠ����łȂ���΂Ȃ�܂���B
%
% CDFWRITE(..., 'WriteMode', MODE) �́AMODE �� 'overwrite' �� 'append'
% �̂ǂ��炩�ŁA�w�肳�ꂽ�ϐ����A�܂��̓t�@�C�������ɑ��݂���ꍇ�ɁA
% CDF �ɕt�������邩�ǂ����������܂��B�f�t�H���g�� CDFWRITE ���ϐ���
% ������t�����Ȃ����Ƃ����� 'overwrite' �ł��B
%
% CDFWRITE(..., 'Format', FORMAT) �́AFORMAT �� 'multifile' �� 
% 'singlefile' �̂ǂ��炩�ŁA�f�[�^�� multi-file CDF �Ƃ��ď����o��
% ���ǂ����������܂��Bmulti-file CDF �ł́A�e�ϐ��́AN �� CDF �ɏ���
% �o���ϐ��̐��Ƃ���ƁA *.vN �t�@�C���Ɋi�[����܂��B�f�t�H���g�́A
% CDFWRITE ���P��� CDF �ɏ����o�����Ƃ����� 'singlefile' �ł��B
% 'WriteMode' �� 'Append' �ɐݒ肳�ꂽ�ꍇ�A'Format' �I�v�V������
% ��������A���ɑ��݂��� CDF �̌`�����g���܂��B
%
% ����: CDFWRITE �́ACDF �t�@�C���ɏ������݂�����ꍇ�A�e���|�����t�@�C����
% �쐬���܂��B���̃t�@�C���̃^�[�Q�b�g�f�B���N�g���ƃJ�����g�̍�ƃf�B���N�g��
% �́A��������������݉\�ł���K�v������܂��B
%
% ���:
%
%      >> cdfwrite('example', {'Longitude', 0:360});
%
%         �l�� [0:360] �� 'Longitude' �̕ϐ����܂ރt�@�C�� 'example.cdf'
%         �������o���܂��B
%
%      >> cdfwrite('example', {'Longitude', 0:360, 'Latitude', 10:20}, ...
%                  'PadValues', {'Latitude', 10});
%
%         ���O�̃��R�[�h�̃A�N�Z�X�̂��ׂĂɑ΂���10�̖��ߍ��ݒl������
%         �ϐ� 'Latitude' �ƂƂ��ɁA'Longitude' �� 'Latitude' �̕ϐ���
%         �܂ރt�@�C�� 'example.cdf' �������o���܂��B
%
%      >> varAttribStruct.validmin = {'longitude' [10]};
%      >> cdfwrite('example', {'Longitude' 0:360}, 'VariableAttributes', ...
%                  varAttribStruct);
%
%         �l10�ł��� 'validmin' �̕ϐ��̑����ƁA[0:360] �̒l ������
%         'Longitude' �̕ϐ����܂ރt�@�C�� 'example.cdf' �������o���܂��B
%
% �Q�l : CDFREAD, CDFINFO, CDFEPOCH.



%   binky
%   Copyright 1984-2002 The MathWorks, Inc.
