"""
Steinhardt Order Parameters
^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. autofunction:: init_steinhardt_order_param_wf

"""

import logging

import nipype.pipeline.engine as pe
from nipype.interfaces import utility as niu

from ...engine import Workflow
from ...interfaces.anatomical import CalculateSOP
from ...interfaces.interchange import recon_workflow_input_fields
from ...interfaces.mrtrix import MRConvert
from qsipost.interfaces.bids import ReconDerivativesDataSink

LOGGER = logging.getLogger("nipype.interface")


def init_steinhardt_order_param_wf(
    available_anatomical_data, name="sop_recon", qsirecon_suffix="", params={}
):
    """Compute Steinhardt order parameters based on ODFs or FODs

    Inputs

        *qsipost outputs*

    Outputs

        directions_image
            Image of directions
        icvf_image
            Voxelwise ICVF.
        od_image
            Voxelwise Orientation Dispersion
        isovf_image
            Voxelwise ISOVF
        config_file
            Pickle file with model configurations in it
        fibgz

    """

    inputnode = pe.Node(
        niu.IdentityInterface(fields=recon_workflow_input_fields + ["fod_sh_mif"]),
        name="inputnode",
    )
    outputnode = pe.Node(
        niu.IdentityInterface(fields=["q2_file", "q4_file", "q6_file", "q8_file"]),
        name="outputnode",
    )

    workflow = Workflow(name=name)
    sop_order = params.get("order", 8)
    desc = """Steinhardt Order Parameter Calculation:

: """
    sh_mif_to_nifti = pe.Node(
        MRConvert(out_file="SH.nii", args="-strides -1,-2,3"), name="sh_mif_to_nifti"
    )
    calc_sop = pe.Node(CalculateSOP(**params), name="calc_sop")
    desc += """\
A series of Steinhardt order parameters (up to order %d) were calculated.
""" % (
        sop_order
    )

    workflow.connect([
        (inputnode, sh_mif_to_nifti, [('fod_sh_mif', 'in_file')]),
        (sh_mif_to_nifti, calc_sop, [('out_file', 'sh_nifti')]),
        (calc_sop, outputnode, [
            ('q2_file', 'q2_file'),
            ('q4_file', 'q4_file'),
            ('q6_file', 'q6_file'),
            ('q8_file', 'q8_file'),
        ]),
    ])  # fmt:skip

    sop_sinks = {}
    if qsirecon_suffix:
        for sop_order in range(2, sop_order + 1, 2):
            key = "q%d_file" % sop_order
            sop_sinks[key] = pe.Node(
                ReconDerivativesDataSink(model="steinhardt", mfp=f"q{sop_order}", compress=True),
                name="ds_sop_q%d" % sop_order,
                run_without_submitting=True,
            )
            workflow.connect(outputnode, key, sop_sinks[key], 'in_file')  # fmt:skip

    workflow.__desc__ = desc
    return workflow
