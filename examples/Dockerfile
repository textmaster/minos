######################
# Stage: builder
FROM nginx as builder

ENV HOME /home/app
WORKDIR $HOME

RUN touch builder

CMD ["ls", "-l"]

###############################
# Stage release
FROM nginx as release

ENV HOME /home/app
WORKDIR $HOME

RUN touch release

CMD ["ls", "-l"]

ARG ENV=production
ARG REVISION

ENV REVISION $REVISION
