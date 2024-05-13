.. include:: links.rst

------------
Installation
------------

There are two easy ways to use qsipost:
in a `Docker Container`_, or in a `Singularity Container`_.
Using a local container method is highly recommended.
Once you are ready to run qsipost, see Usage_ for details.

To install::

    $ pip install --user --upgrade qsipost-container

.. _`Docker Container`:

Docker Container
================

In order to run qsipost in a Docker container, Docker must be `installed
<https://docs.docker.com/engine/installation/>`_.
Once Docker is installed, the recommended way to run qsipost is to use the
``qsipost-docker`` wrapper, which requires Python and an Internet connection
and that you install the ``qsipost-container`` package with ``pip``.

.. note:: If running Docker Desktop on MacOS (or via Docker Desktop), be sure to set
    the memory to 6 or more GB. Too little memory assigned to Docker Desktop can result
    in a message like ``Killed.``

When run, ``qsipost-docker`` will generate a Docker command line for you,
print it out for reporting purposes, and then run the command, e.g.::

    $ qsipost-docker /path/to/data/dir /path/to/output/dir participant
    RUNNING: docker run --rm -it -v /path/to/data/dir:/data \
        -v /path/to_output/dir:/out pennlinc/qsipost:latest \
        /data /out participant
    ...

You may also invoke ``docker`` directly::

    $ docker run -ti --rm \
        -v /filepath/to/data/dir \
        -v /filepath/to/output/dir \
        -v ${FREESURFER_HOME}/license.txt:/opt/freesurfer/license.txt \
        pennlinc/qsipost:latest \
        /filepath/to/data/dir /filepath/to/output/dir participant \
        --fs-license-file /opt/freesurfer/license.txt

For example: ::

    $ docker run -ti --rm \
        -v $HOME/fullds005 \
        -v $HOME/dockerout \
        -v ${FREESURFER_HOME}/license.txt:/opt/freesurfer/license.txt \
        pennlinc/qsipost:latest \
        $HOME/fullds005 $HOME/dockerout participant \
        --ignore fieldmaps \
        --fs-license-file /opt/freesurfer/license.txt

If you are running Freesurfer as part of QSIPost,
you will need to mount your Freesurfer license.txt file when invoking ``docker`` ::

    $ docker run -ti --rm \
        -v $HOME/fullds005 \
        -v $HOME/dockerout \
        -v ${FREESURFER_HOME}/license.txt:/opt/freesurfer/license.txt \
        pennlinc/qsipost:latest \
        $HOME/fullds005 -v $HOME/dockerout participant \
        --fs-license-file /opt/freesurfer/license.txt


See `External Dependencies`_ for more information on what is included in the Docker image
and how it's built.



Singularity Container
=====================

The easiest way to get a Sigularity image is to run::

    $ singularity build qsipost-<version>.sif docker://pennlinc/qsipost:<version>

Where ``<version>`` should be replaced with the desired version of qsipost that you want to download.
Do not use ``latest`` or ``unstable`` unless you are performing limited testing.

As with Docker, you will need to bind the Freesurfer license.txt when running Singularity ::

    $ singularity run --containall --writable-tmpfs \
        -B $HOME/fullds005,$HOME/dockerout,${FREESURFER_HOME}/license.txt:/opt/freesurfer/license.txt \
        qsipost-<version>.sif \
        $HOME/fullds005 $HOME/dockerout participant \
        --fs-license-file /opt/freesurfer/license.txt


External Dependencies
---------------------

qsipost is written using Python 3.10 (or above), and is based on
nipype_. The external dependencies are built in the `qsipost_build
<https://github.com/PennLINC/qsipost_build>`_ repository. There
you can find the URLs used to download the dependency source code
and the steps to compile each dependency.
