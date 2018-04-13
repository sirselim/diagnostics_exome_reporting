FROM r-base:3.4.4

# Copy script files and set the working directory
COPY . /usr/src/app/
WORKDIR /usr/src/app

RUN PACKAGES=`cat r-packages.txt` && Rscript -e "install.packages(c($PACKAGES))"


