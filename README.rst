Vocker
======
A simple wrapper around frequently used docker commands and workflows as well as a Dockerfile with some standard tools.
Most of the arguments are inferred from the repo in which you run it but some things are customized via ``project.env``, which currently has no set format or values.

Setup
=====

.. code-block: bash
   :linenos:

    # Check out the repo
    cd ~/src
    git clone git@github.com:sneakypanda/vocker.git 

    # Symlink the script somewhere on your path
    ln -s ~/src/vocker/vocker.sh ~/.local/bin/vocker

    # Use the script
    cd ~/src/my_project
    vocker build
    vocker run
