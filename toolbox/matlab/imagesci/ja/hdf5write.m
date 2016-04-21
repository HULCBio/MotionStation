%HDF5WRITE  Hierarchical Data Format version 5 �t�@�C���̏�������
%
% HDF5WRITE(FILENAME, LOCATION, DATASET) �́ADATASET �̃f�[�^�� 
% FILENAME �Ƃ������O�� HDF5 �t�@�C���ɒǉ����܂��BLOCATION �́A
% �t�@�C���� DATASET ���������ޏꏊ���`���AUnix �X�^�C���̃p�X
% �Ɏ��Ă��܂��BDATASET �̃f�[�^�́A���L�̋K�����g�p���āAHDF5 
% �f�[�^�^�C�v�Ƀ}�b�s���O����܂��B
%
% HDF5WRITE(FILENAME, DETAILS, DATASET) �́ADETAILS �\���̂̒l��
% �g�p���āAFILENAME �� DATASET ��ǉ����܂��B���̍\���̂́A�f�[�^
% �Z�b�g�ɑ΂��āA���̃t�B�[���h���܂ނ��Ƃ��ł��܂��B
%
%      Location     �t�@�C�����̃f�[�^�Z�b�g�̈ʒu (�����z��)�B
%
%      Name         �f�[�^�Z�b�g�ɕt���閼�O (�����z��)�B
%
% HDF5WRITE(FILENAME, DETAILS, ATTRIBUTE) �́ADETAILS �\���̂̒l��
% �g�p���āAFILENAME �ɁA���^�f�[�^ ATTRIBUTE ��ǉ����܂��B
%
% �����ɑ΂��āA���̃t�B�[���h���K�v�ɂȂ�܂��B
%
%      AttachedTo   ���̑������C������A�I�u�W�F�N�g�̈ʒu�B
%
%      AttachType   ���̑������C������A�I�u�W�F�N�g�̎�ނ𓯒肷��
%                   ������B�Ƃ蓾��l�́A'group' ��'dataset'�ł��B
%
%      Name         �f�[�^�Z�b�g�ɕt���閼�O (�����z��)�B
%
% HDF5WRITE(FILENAME, DETAILS1, DATASET1, DETAILS2, ATTRIBUTE1, ...)
% �́AFILENAME �� 1�̑���ŁA�����́A�f�[�^�Z�b�g �����/�܂��� 
% �������������ޕ��@��񋟂��܂��B�e�f�[�^�Z�b�g�Ƒ����́ADETAILS 
% �\���̂����K�v������܂��B
%
% HDF5WRITE(FILENAME, ... , 'WriteMode', MODE, ...) �́A�����̃t�@�C
% ���ւ̏������݂��A�㏑��(�f�t�H���g) �ɂ��邩�A���邢�́A������
% �t�@�C���ւ̃f�[�^�Z�b�g�Ƒ����̒ǉ��ɂ��邩�ǂ������w�肵�܂��B
% MODE ���Ƃ蓾��l�́A'overwrite' �� 'append' �ł��B
%
%
% �f�[�^�ϊ��K��:
%
%   (1) �f�[�^�����l�̏ꍇ�AHDF5 �f�[�^�Z�b�g�́A�K����HDF5 �̃f�[�^
%       �^�C�v���܂݁A�f�[�^�X�y�[�X�̃T�C�Y�́A�z��Ɠ����T�C�Y�ł��B
% 
%   (2) �f�[�^��������̏ꍇ�AHDF5 �t�@�C���́A1�v�f�̃f�[�^�Z�b�g
%       ���܂݂܂��B���̗v�f�́A�k���ŏI��镶����ł��B
% 
%   (3) �f�[�^��������̃Z���z��̏ꍇ�AHDF5 �f�[�^�Z�b�g �܂��́A
%       �����́AHDF5 ������f�[�^�^�C�v�������܂��B�f�[�^�X�y�[�X�́A
%       �Z���z��Ɠ����T�C�Y�������܂��B������̗v�f�́A�k���ŏI��
%       ��܂����A���蓖�Ă͂��ׂāA�����ő�̒����������܂��B
% 
%   (4) �f�[�^���Z���z��ŁA�Z���̂��ׂĂ��A���l�f�[�^�̂݊܂ޏꍇ�A
%       HDF5 �f�[�^�^�C�v�́A�z��ł��B�z��̗v�f�́A���ׂĐ��l�ŁA
%       �����T�C�Y�ƃ^�C�v�����K�v������܂��B�z��̃f�[�^�X�y�[�X
%       �́A�Z���z��Ɠ��������������܂��B�v�f�̃f�[�^�^�C�v�́A�ŏ���
%�@�@ �@�v�f�Ɠ��������������܂��B
% 
%   (5) �f�[�^���\���̔z��̏ꍇ�AHDF5 �f�[�^�^�C�v�́A�����̃^�C�v
%       �ɂȂ�܂��B�\���̂̌X�̃t�B�[���h�́A �f�[�^�^�C�v�ɑ΂��A
%�@ �@�@�����f�[�^�ϊ����g�p���܂�(���Ƃ��΁A������A�܂��́A�z���
%�@   �@�֘A����Z���A�Ȃ�)�B
% 
%   (6) �f�[�^��HDF5 �I�u�W�F�N�g�ɂ��\�������ꍇ�AHDF5 �f�[�^
%�@�@ �@�^�C�v���I�u�W�F�N�g�̃^�C�v�ɑΉ����܂��B
%       - H5ENUM �I�u�W�F�N�g�ɑ΂��A�f�[�^�X�y�[�X�́A�I�u�W�F�N�g��
%�@�@ �@�@Data �t�B�[���h�Ɠ��������������܂��B
%       - ���̂��ׂẴI�u�W�F�N�g�ɑ΂��A�f�[�^�X�y�[�X�́A�֐���
%         �n����� HDF5 �I�u�W�F�N�g�̔z��Ɠ��������������܂��B
%
%
% ���:
%
% % (A) ���[�g�O���[�v�� 5�~5 UINT8 �l�f�[�^�Z�b�g����������
%   hdf5write('myfile.h5', '/dataset1', uint8(magic(5)))
%
% % (B) �T�u�O���[�v�� 2�~2 ������f�[�^�Z�b�g����������
%   dataset = {'north', 'south'; 'east', 'west'};
%   hdf5write('myfile2.h5', '/group1/dataset1.1', dataset);
%
% % (C) �����̃O���[�v�Ƀf�[�^�Z�b�g�Ƒ�������������
%   dset = single(rand(10,10));
%   dset_details.Location = '/group1/dataset1.2';
%   dset_details.Name = 'Random';
%
%   attr = 'Some random data';
%   attr_details.Name = 'Description';
%   attr_details.AttachedTo = '/group1/dataset1.2';
%   attr_details.AttachType = 'dataset';
%    
%   hdf5write('myfile2.h5', dset_details, dset, attr_details, attr, ...
%              'WriteMode', 'append');
%
% % (D) �I�u�W�F�N�g���g�p���ăf�[�^�Z�b�g����������
%   dset = hdf5.h5array(magic(5));
%   hdf5write('myfile3.h5', '/g1/objects', dset);
%
%
% �Q�l HDF5READ, HDF5INFO, HDF5COPYRIGHT.TXT.


% Process input arguments.

% Verify the data.






% Call MEX implementation.
