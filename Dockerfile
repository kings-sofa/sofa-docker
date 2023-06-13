FROM mikelitu/sofa-docker:latest

RUN echo "export PATH=/home/${USER}/miniconda3/bin:$PATH" >> ~/.bashrc &&\
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh &&\
bash Miniconda3-latest-Linux-x86_64.sh -b &&\
rm -f Miniconda3-latest-Linux-x86_64.sh &&\
eval "$(/home/${USER}/miniconda3/bin/conda shell.bash hook)" &&\
conda init &&\
conda create -n pySOFA python=3.10 -y &&\
conda activate pySOFA &&\

COPY requirements.txt requirements.txt

RUN pip3 install -r requirements.txt
