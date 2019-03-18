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

USER $NB_UID

RUN pip install --upgrade setuptools
RUN pip install --upgrade pip

# COPY ./config/requirements.txt /tmp/
# RUN pip install --requirement /tmp/requirements.txt && \
#     fix-permissions $CONDA_DIR && \
#     fix-permissions /home/$NB_USER

RUN conda install --quiet --yes -c\
    'conda-forge' \
    'conda-build' \
    'dask' \
    'blas=*=openblas' \
    'cython=0.28*' \
    'cloudpickle=0.5*' \
    'dill=0.2*' \
    'sqlalchemy=1.2*' \
    'hdf5=1.10*' \
    'h5py=2.7*' \
    'vincent=0.4.*' \
    'beautifulsoup4=4.6.*' \
    'feedparser==5.2.1' \
    'flask==1.0.2' \
    'google-api-python-client==1.7.8' \
    'geopy==1.18.1' \
    'ipywidgets=7.2*' \
    'jpype1' \
    'jupyter_contrib_nbextensions' \
    'matplotlib' \
    'networkx==2.2' \
    'nltk==3.4' \
    'numexpr=2.6*' \
    'osmnx' \
    'pandas=0.22*' \
    'patsy=0.5*' \
    'Pillow==5.4.1' \
    'protobuf=3.*' \
    'pymongo==3.7.2' \
    'PyGithub==1.43.5' \
    'prettytable==0.7.2' \
    'requests==2.21.0' \
    'spacy' \
    'pymongo' \
    'psycopg2' \
    'sqlalchemy' \
    'pyodbc==4.0.25' \
    'PyMySQL==0.9.3' \
    'scipy=1.0*' \
    'scikit-learn=0.19*' \
    'scikit-image=0.13*' \
    'statsmodels=0.8*' \
    'sympy=1.1*' \
    'xlrd'  && \
    conda remove --quiet --yes --force qt pyqt && \
    conda clean -tipsy && \
    # Activate ipywidgets extension in the environment that runs the notebook server
    jupyter contrib nbextension install --user && \
    jupyter nbextension enable --py widgetsnbextension --sys-prefix && \
    npm cache clean --force && \
    rm -rf $CONDA_DIR/share/jupyter/lab/staging && \
    rm -rf /home/$NB_USER/.cache/yarn && \
    rm -rf /home/$NB_USER/.node-gyp && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

RUN conda build purge-all

RUN pip install -q --no-cache-dir charade \
boilerpipe3 \
envoy==0.0.3 \
twitter==1.18.0 \
facebook-sdk==3.1.0 \
cluster==1.4.0 \
python3-linkedin==1.0.2 \
mailbox==0.4 \
twitter-text==3.0 \
simplekml==1.3.1

# Import matplotlib the first time to build the font cache.
ENV XDG_CACHE_HOME /home/$NB_USER/.cache/
RUN MPLBACKEND=Agg python -c "import matplotlib.pyplot" && \
    fix-permissions /home/$NB_USER

USER root

# Download NLTK data
# RUN python -m nltk.download('all')

COPY ./config/odbcinst.ini /etc/odbcinst.ini
RUN odbcinst -q -d -i -f /etc/odbcinst.ini

# Install X Virtual Framebuffer
RUN apt-get install -y xvfb
#ENV DISPLAY=:0
USER $NB_UID

# Load all the sample code and resources for Mining the Social Web, 3rd Edition
RUN rm -rf /home/$NB_USER/work
COPY ./config/matplotlibrc /home/$NB_USER/.config/matplotlib/

USER root
RUN chown $NB_UID:users /home/$NB_USER -R
RUN chmod 755 /home/$NB_USER -R
USER $NB_UID

COPY ./config/fonts /usr/share/fonts/truetype/

RUN fc-cache
RUN fc-list

VOLUME /notebooks
WORKDIR /notebooks

# CMD is required by Heroku
CMD /opt/conda/bin/jupyter notebook --port=8888 --no-browser --allow-root --NotebookApp.token='demo'
