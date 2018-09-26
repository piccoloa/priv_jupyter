FROM jupyter/all-spark-notebook:137a295ff71b

USER root

RUN ["bash", "-c", "source activate root"]

USER jovyan

ADD fonts /usr/share/fonts/truetype/

RUN fc-cache
RUN fc-list

VOLUME /notebooks
WORKDIR /notebooks
CMD jupyter notebook --no-browser --ip=0.0.0.0 --allow-root --NotebookApp.token='demo'
