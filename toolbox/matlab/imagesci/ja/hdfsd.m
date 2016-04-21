% HDFSD   
% HDF�}���`�t�@�C���Ȋw�Z�p�f�[�^�Z�b�g�C���^�t�F�[�X��MATLAB�Q�[�g�E�F�C
% 
% HDFSD�́AHDF�}���`�t�@�C���Ȋw�Z�p�f�[�^�Z�b�g�C���^�t�F�[�X(SD)��
% �Q�[�g�E�F�C�ł��B���̊֐����g�����߂ɂ́AHDF version 4.1r3��User's Guide
% ��Reference Manual�Ɋ܂܂�Ă���ASD�C���^�t�F�[�X�Ɋւ�����ɂ���
% �m���Ă��Ȃ���΂Ȃ�܂���B���̃h�L�������g�́ANational Center for 
% Supercomputing Applications (NCSA�A<http://hdf.ncsa.uiuc.edu>)���瓾��
% ���Ƃ��ł��܂��B
%
% HDFSD�ɑ΂����ʓI�ȃV���^�b�N�X�́AHDFSD(funcstr,param1,param2,...)
% �ł��BHDF���C�u��������SD�֐��ƁAfuncstr�ɑ΂���L���Ȓl�́A1��1�őΉ�
% ���܂��B���Ƃ��΁AHDFSD('endaccess',sds_id) �́AC���C�u�����R�[��
% SDendaccess(sds_id) �ɑΉ����܂��B
%
% �V���^�b�N�X�̎g����
% --------------------
% �X�e�[�^�X�܂��͎��ʎq�̏o�͂�-1�̂Ƃ��A���삪���s�������Ƃ������܂��B
% 
% SD_id �́A�}���`�t�@�C���Ȋw�Z�p�f�[�^�Z�b�g�C���^�t�F�[�X�̎��ʎq���Q
% �Ƃ��܂��Bsds_id �́A�X�̃f�[�^�Z�b�g�̎��ʎq���Q�Ƃ��܂��B
% hdfsd('end',SD_id) �܂��� hdfsd('endaccess',sds_id) ���g���āA���ׂẴI�[�v
% �����Ă��鎯�ʎq�ւ̃A�N�Z�X���I�����Ȃ���΂Ȃ�܂���B�����łȂ���΁A
% HDF���C�u�����́A���ׂẴf�[�^�𐳏�Ƀt�@�C���ɏ����o���܂���B 
% 
% HDF�t�@�C���́A�������z��ɑ΂���C�X�^�C���̏����t����p���܂��B����A
% MATLAB��FORTRAN�X�^�C���̏����t����p���܂��B����́AHDF�f�[�^
% �t�B�[���h�̒�`���ꂽ�����̑傫���ɑ΂��āAMATLAB�z��̑傫�����A�]�u
% ����Ȃ���΂Ȃ�Ȃ����Ƃ��Ӗ����Ă��܂��B���Ƃ��΁A�O���b�h�t�B�[���h���A
% 3 x 4 x 5 �Œ�`����Ă���ꍇ�́ADATA�� 5 x 4 x 3 �̑傫���łȂ���΂�
% ��܂���BPERMUTE �R�}���h�́A�����ŕK�v�ȕϊ����s�����߂̃R�}���h�ł��B
% 
% ������͂ɑ΂��āANULL���󂯓����HDF C���C�u�����ł́A��s��([])���g
% ���܂��B
% 
% �A�N�Z�X�Ɋւ���֐�
% --------------------
% �A�N�Z�X�Ɋւ���֐��́AHDF�t�@�C���ƃf�[�^�Z�b�g�̃A�N�Z�X�����������A
% �I�����܂��B
%
%   status = hdfsd('end',SD_id)
%   �Ή�����t�@�C���ւ̃A�N�Z�X���I�����܂��B
%
%   status = hdfsd('endaccess',sds_id)
%   �Ή�����f�[�^�Z�b�g�ւ̃A�N�Z�X���I�����܂��B
%
%   sds_id = hdfsd('select',SD_id�Asds_index)
%   �w�肵���C���f�b�N�X�����f�[�^�Z�b�g�̎��ʎq���o�͂��܂��B
%
%   SD_id = hdfsd('start',filename,access_mode)
%   ����̃t�@�C���ɑ΂���SD�C���^�t�F�[�X�����������܂��B
%   access_mode �́A'read', 'write', 'create', 'rdwr', 'rdonly' ��
%   �����ꂩ�ł��B
% 
% �ǂݍ��݂Ə����o���Ɋւ���֐�
% ------------------------------
% �ǂݍ��݂Ə����o���Ɋւ���֐��́A�����A�����N�A�f�[�^�^�C�v�𑀍삵�āA
% �f�[�^�Z�b�g�̓ǂݍ��݂Ə����o�����s���܂��B
%
%   sds_id = hdfsd('create',SD_id,name,data_type,rank,dimsizes)
%   �V�����f�[�^�Z�b�g���쐬���܂��B
%
%   [data,status] = hdfsd('readdata',sds_id,start,stride,edge)
%   �`�����N�����ꂽ�f�[�^�Z�b�g�܂��̓`�����N������Ă��Ȃ��f�[�^�Z�b�g
%   ����A�f�[�^��ǂݍ��݂܂��B���ӁF�x�N�g���̎n�_�̍��W�́A1�x�[�X�ł�
%   �Ȃ��A0�x�[�X�łȂ���΂Ȃ�܂���B
% 
%   status = hdfsd('setexternalfile', sds_id, filename, offset)
%   �O���t�@�C���ɕۑ������f�[�^�^�C�v���`���܂��B
%
%   status = hdfsd('writedata',sds_id, start, stride, edge, data)
%   �`�����N�����ꂽ�f�[�^�Z�b�g�܂��̓`�����N������Ă��Ȃ��f�[�^�Z�b�g�ɁA
%   �f�[�^�������o���܂��B
%   ���ӁF�f�[�^�̃N���X�́AHDF�f�[�^�Z�b�g�ɑ΂��āA��`�����HDF�̐��l�^
%   �C�v�ƈ�v���Ȃ���΂Ȃ�܂���BMATLAB������́A�����I�ɁAHDF char�^
%   �C�v�̂����ꂩ�Ɉ�v����悤�ɕϊ�����܂��B�����āA���̃f�[�^�^�C�v�́A
%   �����ȈӖ��ň�v���Ȃ���΂Ȃ�܂���B
% 
% ���ӁF
% �x�N�g���̎n�_�̍��W�́A1�x�[�X�ł͂Ȃ��A0�x�[�X�łȂ���΂Ȃ�܂���B
% 
% ��ʏ��Ɋւ���֐�
% --------------------
% ��ʏ��Ɋւ���֐��́AHDF�t�@�C�����̉Ȋw�Z�p�f�[�^�̈ʒu�A���e�A
% �L�q�Ɋւ�������o�͂��܂��B
%
%   [ndatasets,nglobal_attr,status] = hdfsd('fileinfo',SD_id)
%   �t�@�C���̓��e�Ɋւ�������o�͂��܂��B
%
%   [name,rank,dimsizes,data_type,nattrs,status] = hdfsd('getinfo',...
%                   sds_id)
%   �f�[�^�Z�b�g�Ɋւ�������o�͂��܂��B
%
%  ref = hdfsd('idtoref',sds_id)
%   �w�肵���f�[�^�Z�b�g�ɑΉ�����Q�Ɣԍ����o�͂��܂��B
%
%   tf = hdfsd('iscoordvar',sds_id)
%   �f�[�^�Z�b�g�Ǝ����̃X�P�[������ʂ��܂��B
%
%   idx = hdfsd('nametoindex',SD_id,name)
%   ���O�t����ꂽ�f�[�^�Z�b�g�̃C���f�b�N�X�̒l���o�͂��܂��B
%
%   sds_index = hdfsd('reftoindex',SD_id,ref)
%   �^����ꂽ�Q�Ɣԍ��ɑΉ�����A�f�[�^�Z�b�g�̃C���f�b�N�X���o�͂��܂��B
% 
% �����̃X�P�[���Ɋւ���֐�
% --------------------------
% �����̃X�P�[���Ɋւ���֐��́A�f�[�^�Z�b�g���Ŏ����̃X�P�[�����`���A
% �A�N�Z�X���܂��B
%
%   [name,count,data_type,nattrs,status] = hdfsd('diminfo',dim_id)
%   �����Ɋւ�������擾���܂��B
%
%   dim_id = hdfsd('getdimid',sds_id,dim_number)
%   �����̎��ʎq���擾���܂��B
%
%   status = hdfsd('setdimname',dim_id,name)
%   ���O�Ǝ�����Ή��t���܂��B
%
%   [scale,status] = hdfsd('getdimscale',dim_id)
%   �����ɑ΂���X�P�[���l���o�͂��܂��B
%
%   status = hdfsd('setdimscale',dim_id,scale)
%   �����̒l���`���܂��B
%
% ���[�U��`�̑����Ɋւ���֐�
% ----------------------------
% ���[�U��`�̑����Ɋւ���֐��́AHDF���[�U����`����HDF�t�@�C���A
% �f�[�^�Z�b�g�A�����̓������L�q���A�A�N�Z�X���܂��B
%
%   [name,data_type,count,status] = hdfsd('attrinfo',id,attr_idx)
%  �����Ɋւ�������擾���܂��Bid �́ASD_id�Asds_id�Adim_id �̂����ꂩ�ł��B
% 
%   attr_index = hdfsd('findattr',id,name)
%   �w�肵���C���f�b�N�X���o�͂��܂��Bid �́ASD_id�Asds_id�Adim_id ��
%   �����ꂩ�ł��B
%
%   [data,status] = hdfsd('readattr',id,attr_index)
%   �w�肵�������̒l��ǂݍ��݂܂��Bid �́ASD_id�Asds_id�Adim_id ��
%   �����ꂩ�ł��B
%
%   status = hdfsd('setattr',id,name,A)
%   �V���ȑ������쐬���A��`���܂��Bid �́ASD_id�Asds_id�Adim_id ��
%   �����ꂩ�ł��B
%
% ���ɒ�`���ꂽ�����Ɋւ���֐�
% ------------------------------
% ���ɒ�`���ꂽ�����Ɋւ���֐��́A���ɒ�`����HDF�t�@�C���A�f�[�^�Z�b
% �g�A�����̓����ɃA�N�Z�X���܂��B
%
%   [cal,cal_err,offset,offset_err,data_type,status] = .....
%              hdfsd('getcal',sds_id)
%   �L�����u���[�V�����̏����o�͂��܂��B
%
%   [label,unit,format,coordsys,status] = ....
%                  hdfsd('getdatastrs',sds_id,maxlen)
%   �f�[�^�Z�b�g�̃��x���A�͈́A�����A���W�n���o�͂��܂��B
%
%   [label,unit,format,status] = hdfsd('getdimstrs',dim_id)
%   �w�肵�������ɂ��Ă̑����̕�������o�͂��܂��B
%
%   [fill,status] = hdfsd('getfillvalue',sds_id)
%   fill�����݂���΂��̒l��ǂݍ��݂܂��B
%
%   [rmax,rmin,status] = hdfsd('getrange',sds_id)
%   �w�肵���f�[�^�Z�b�g�̒l�͈̔͂��o�͂��܂��B
%
%   status = ....
%    hdfsd('setcal',sds_id,cal,cal_err,offset,offset_err,data_type)
%   �L�����u���[�V�����̏����`���܂��B
%
%   status = hdfsd('setdatastrs',sds_id,label,unit,format,coordsys)
%   �w�肵���f�[�^�Z�b�g�̑����̕�������`���܂��B
%
%   status = hdfsd('setdimstrs',dim_id,label,unit,format)
%   �w�肵�������̑����̕�������`���܂��B
%
%   status = hdfsd('setfillvalue',sds_id,value)
%   �w�肵���f�[�^�Z�b�g��fill�̒l���`���܂��B
%
%   status = hdfsd('setfillmode',SD_id,mode)
%   �w�肵���t�@�C���́A���ׂẲȊw�Z�p�f�[�^�Z�b�g�ɓK�p�����fill���[�h
%   ���`���܂��B
%
%   status = hdfsd('setrange',sds_id,max,min)
%   �L���Ȕ͈͂̍ő�l�ƍŏ��l���`���܂��B
%
% ���k�֐�
% --------
% ���k�֐��́A�Ȋw�Z�p�f�[�^�Z�b�g�̈��k���@���w�肵�܂��B
%
%   status = hdfsd('setcompress',SD_id,comp_type,...)
%   �f�[�^�Z�b�g�ɓK�p����鈳�k���@���`���܂��Bcomp_type �́A'none',
%   'jpeg', 'rle', 'deflate', 'skphuff' �̂����ꂩ�ł��B
%
%   ���k���@�̒��ɂ́A�ǉ��̃p�����[�^�ƒl�̑g���킹��^���Ȃ���΂Ȃ��
%    �����@������܂��B���̃��[�`���́A���̃p�����[�^�ƒl�̑g���킹������
%    ���܂��B
% 
%       'jpeg_quality'        �A����
%       'jpeg_force_baseline' �A����
%       'skphuff_skp_size'    �A����
%       'deflate_level'       �A����
%
% �`�����N�ƃ^�C���Ɋւ���֐�
% ----------------------------
% �`�����N�ƃ^�C���Ɋւ���֐��́ASDS�f�[�^�ɑ΂���`�����N�̍\�����w��
% ���܂��B
%
%   [chunk_lengths,chunked,compressed,status] = ....
%                           hdfsd('getchunkinfo',sds_id)
%   �`�����N������Ă���Ȋw�Z�p�f�[�^�Z�b�g�Ɋւ�������擾���܂��BSDS
%   ���`�����N���܂��͈��k����Ă���ꍇ�A�`�����N���܂��͈��k��1(�^)�ł��B
%
%   status = hdfsd('setchunkcache',sds_id,maxcache,flags)
%   �`�����N�L���b�V���̃T�C�Y��ݒ肵�܂��B
%
%   status = hdfsd('setchunk',sds_id,chunk_lengths,comp_type,...)
%   �`�����N������Ă��Ȃ��Ȋw�Z�p�f�[�^�Z�b�g���A�`�����N�����ꂽ�Ȋw�Z�p
%   �f�[�^�Z�b�g�ɕύX���܂��B
%
%   comp_type �́A'none', 'jpeg', 'rle', 'deflate', 'skphuff' �̂����ꂩ�ł��B
%   'none' �́AHDF_CHUNK ���A���̒l�� HDF_CHUNK | HDF_COMP ��������
%   ���B���̕��@�̒��ɂ́A�ǉ��̃p�����[�^�ƒl�̑g���킹��^���Ȃ���΂Ȃ�
%   �Ȃ����@������܂��B���̃��[�`���́A���̃p�����[�^�ƒl�̑g���킹����
%   �߂��܂��B 
%       'jpeg_quality'        �A����
%       'jpeg_force_baseline' �A����
%       'skphuff_skp_size'    �A����
%       'deflate_level'       �A����
%
%   status = hdfsd('writechunk',sds_id,origin,data)
%   �f�[�^���`�����N�����ꂽ�Ȋw�Z�p�f�[�^�Z�b�g�ɏ����o���܂��B
%
%   [data,status] = hdfsd('readchunk',sds_id,origin)
%   �f�[�^���`�����N�����ꂽ�Ȋw�Z�p�f�[�^�Z�b�g����ǂݍ��݂܂��B
%
% N�r�b�g�f�[�^�Z�b�g�Ɋւ���֐�
% -------------------------------
% N�r�b�g�f�[�^�Z�b�g�Ɋւ���֐��́A�Ȋw�Z�p�f�[�^�Z�b�g�̃f�[�^�ɑ΂�
% ��A��W���f�[�^�r�b�g�����w�肵�܂��B
%
%   status = ....
%    hdfsd('setnbitdataset',sds_id,start_bit,bit_len,sign_ext,fill_one)
%   �f�[�^�Z�b�g�̃f�[�^�̔�W���r�b�g�����`���܂��B
%
% �Q�l�FHDF, HDFAN, HDFDF24, HDFDFR8, HDFH, HDFHD, HDFHE,
%       HDFML, HDFV, HDFVF, HDFVH, HDFVS.


%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/28 01:56:59 $
