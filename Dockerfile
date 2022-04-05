# Use python as the base image
FROM selenium/standalone-chrome

# Install ruby
USER root
RUN \
  sudo apt-get update && \
  sudo apt-get install -y ruby ruby-dev git python3-pip 

# Install pip/selenium
RUN python3 -m pip install selenium

# Install southwest-headers
RUN mkdir /home/swcheckin
RUN mkdir /home/swcheckin/data
WORKDIR /home/swcheckin
RUN git clone https://github.com/byalextran/southwest-headers.git
RUN \
  cd /home/swcheckin/southwest-headers && \
  pip install -r requirements.txt
# Modify chromedriver
RUN sudo perl -pi -e 's/cdc_/swc_/g' /usr/bin/chromedriver
RUN ln -s /usr/bin/chromedriver /home/swcheckin/southwest-headers/chromedriver

# Install southwest-checkin
WORKDIR /home/swcheckin
RUN git clone https://github.com/byalextran/southwest-checkin.git
ADD ./runner.sh /home/swcheckin


ENTRYPOINT ["/home/swcheckin/runner.sh"]


