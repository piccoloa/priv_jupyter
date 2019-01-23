FROM jupyter/all-spark-notebook:137a295ff71b

USER root


RUN conda install --quiet --yes -c conda-forge osmnx dask

RUN conda install --yes --name root spacy pymongo

RUN ["bash", "-c", "source activate root"]

RUN apt-get update && \
    apt-get -qy install --reinstall build-essential && \
    apt-get -qy install gcc freetds-dev freetds-bin unixodbc-dev tdsodbc

RUN pip install --upgrade pip && \
    pip install pyodbc pymysql

RUN pip install -U nltk \
                   twitter

ADD odbcinst.ini /etc/odbcinst.ini
RUN odbcinst -q -d -i -f /etc/odbcinst.ini


# USER jovyan
USER root
ADD fonts /usr/share/fonts/truetype/

RUN [ "python", "-c", "import nltk; nltk.download('all')" ]

RUN fc-cache
RUN fc-list

VOLUME /notebooks
WORKDIR /notebooks
CMD jupyter notebook --no-browser --ip=0.0.0.0 --allow-root --NotebookApp.token='demo'
