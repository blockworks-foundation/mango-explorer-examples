FROM jupyter/scipy-notebook:latest

USER root
RUN apt-get update && apt-get -y install jq libxml2-dev libxslt-dev libffi-dev zlib1g-dev
USER ${NB_UID}

COPY --chown=${NB_UID}:${NB_GID} requirements.txt /tmp/
RUN pip install --index-url https://test.pypi.org/simple/ --extra-index-url https://pypi.org/simple/ --quiet --no-cache-dir --requirement /tmp/requirements.txt && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

# Create our profile directory.
RUN ipython profile create

# Install the extensions we want
RUN jupyter contrib nbextension install --user
RUN jupyter nbextension enable codefolding/edit && \
    jupyter nbextension enable codefolding/main && \
    jupyter nbextension enable highlighter/highlighter && \
    jupyter nbextension enable select_keymap/main && \
    jupyter nbextension enable toc2/main && \
    jupyter nbextension enable varInspector/main

RUN jq '. += {"select_keymap_local_storage": false, "stored_keymap": "sublime"}' \
        /home/jovyan/.jupyter/nbconfig/notebook.json > \
        /home/jovyan/.jupyter/nbconfig/newnotebook.json && \
    mv -f /home/jovyan/.jupyter/nbconfig/newnotebook.json /home/jovyan/.jupyter/nbconfig/notebook.json

ENV PATH="/home/jovyan/work/bin:${PATH}:/home/jovyan/work/scripts:/home/jovyan/.local/share/solana/install/active_release/bin"
ADD . /home/jovyan/work

WORKDIR /home/jovyan/work