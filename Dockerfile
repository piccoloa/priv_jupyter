FROM jupyter/all-spark-notebook

LABEL maintainer="Jupyter Project <jupyter@googlegroups.com>"
# Modified by David Guardia for Data Science development

USER root

RUN apt-get update && \
    apt-get -qy --no-install-recommends install --reinstall build-essential && \
    apt-get -qy install gcc \
    apt-utils \
    freetds-dev \
    freetds-bin \
    unixodbc-dev \
    tdsodbc \
    default-jdk

RUN update-alternatives --config java
COPY ./config/odbcinst.ini /etc/odbcinst.ini
RUN odbcinst -q -d -i -f /etc/odbcinst.ini

# Install X Virtual Framebuffer
RUN apt-get install -y xvfb

USER $NB_UID

RUN pip install --upgrade pip \
                setuptools

COPY ./config/requirements.txt /tmp/
RUN pip install --requirement /tmp/requirements.txt && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

RUN conda install --quiet --yes -c\
    'conda-forge' \
    'conda-build' \
    'dask' \
    'blas=*=openblas' \
    'cython' \
    'cloudpickle' \
    'dill' \
    'sqlalchemy' \
    'hdf5' \
    'h5py' \
    'vincent' \
    'beautifulsoup4' \
    'feedparser' \
    'flask' \
    'google-api-python-client' \
    'geopy' \
    'ipywidgets' \
    'jpype1' \
    'jupyter_contrib_nbextensions' \
    'matplotlib' \
    'networkx' \
    'nltk' \
    'numexpr' \
    'osmnx' \
    'pandas' \
    'patsy' \
    'pillow' \
    'protobuf' \
    'pymongo' \
    'pygithub' \
    'prettytable' \
    'requests' \
    'spacy' \
    'pymongo' \
    'psycopg2' \
    'sqlalchemy' \
    'pyodbc' \
    'pymysql' \
    'scipy' \
    'scikit-learn' \
    'scikit-image' \
    'statsmodels' \
    'sympy' \
    'xlrd'  && \
    conda remove --quiet --yes --force qt pyqt && \
    conda build purge-all && \
    # Activate ipywidgets extension in the environment that runs the notebook server
    jupyter contrib nbextension install --user && \
    jupyter nbextension enable --py widgetsnbextension --sys-prefix && \
    npm cache clean --force && \
    rm -rf $CONDA_DIR/share/jupyter/lab/staging && \
    rm -rf /home/$NB_USER/.cache/yarn && \
    rm -rf /home/$NB_USER/.node-gyp && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

# RUN pip install -q --no-cache-dir charade \
#                         boilerpipe3 \
#                         envoy \
#                         twitter \
#                         facebook-sdk \
#                         cluster \
#                         python3-linkedin \
#                         mailbox \
#                         twitter-text \
#                         simplekml

# Import matplotlib the first time to build the font cache.
ENV XDG_CACHE_HOME /home/$NB_USER/.cache/
RUN MPLBACKEND=Agg python -c "import matplotlib.pyplot" && \
    fix-permissions /home/$NB_USER

USER root
RUN chown $NB_UID:users /home/$NB_USER -R
RUN chmod 755 /home/$NB_USER -R

# Load all the sample code and resources for Mining the Social Web, 3rd Edition
RUN rm -rf /home/$NB_USER/work
COPY ./config/matplotlibrc /home/$NB_USER/.config/matplotlib/

# Download NLTK data
# RUN python -m nltk.download('all')

ENV DISPLAY=:0
USER $NB_UID


# USER $NB_UID

COPY ./config/fonts /usr/share/fonts/truetype/

RUN fc-cache
RUN fc-list

VOLUME /notebooks
WORKDIR /notebooks

# CMD is required by Heroku
CMD /opt/conda/bin/jupyter notebook --port=8888 --no-browser --allow-root --NotebookApp.token='demo'
