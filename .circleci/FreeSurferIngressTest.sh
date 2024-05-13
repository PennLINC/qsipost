#!/bin/bash

cat << DOC

Test the FreeSurfer Ingress workflow
====================================

Test the case where QSIPost has processed the anatomical data and an external
(likely run as part of fmriprep) freesurfer run has happened as well

This tests the following features:
 - Blip-up + Blip-down DWI series for TOPUP/Eddy
 - Eddy is run on a CPU
 - Denoising is skipped
 - A follow-up reconstruction using the dsi_studio_gqi workflow

Inputs:
-------

 - freesurfer SUBJECTS_DIR (data/freesurfer)
 - qsipost multi shell results with anatomical outputs (data/qsipost_with_anat)

DOC

set +e
source ./get_data.sh
TESTDIR=${PWD}
#get_config_data ${TESTDIR}
#get_bids_data ${TESTDIR} freesurfer
#get_bids_data ${TESTDIR} abcd_output

CFG=${TESTDIR}/data/nipype.cfg
EDDY_CFG=${TESTDIR}/data/eddy_config.json
export FS_LICENSE=${TESTDIR}/data/license.txt

# Test dipy_mapmri
TESTNAME=fs_ingress_test
# setup_dir ${TESTDIR}/${TESTNAME}
TEMPDIR=${TESTDIR}/${TESTNAME}/work
OUTPUT_DIR=${TESTDIR}/${TESTNAME}/derivatives
BIDS_INPUT_DIR=${TESTDIR}/data/qsipost_with_anat
SUBJECTS_DIR=${TESTDIR}/data/freesurfer
QSIPOST_CMD=$(run_qsipost_cmd ${BIDS_INPUT_DIR} ${OUTPUT_DIR})

${QSIPOST_CMD} \
	 -w ${TEMPDIR} \
	 --recon-input ${BIDS_INPUT_DIR} \
	 --sloppy \
	 --recon-spec ${PWD}/test_5tt_hsv.json \
	 --freesurfer-input ${SUBJECTS_DIR} \
	 --recon-only \
	 -vv



