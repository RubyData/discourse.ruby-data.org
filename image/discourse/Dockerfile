FROM discourse/base:2.0.20171008

ENV RAILS_ENV production
ENV UNICORN_WORKERS 3
ENV UNICORN_SIDEKIQS 1
ENV RUBY_GLOBAL_METHOD_CACHE_SIZE 131072
# stop heap doubling in size so aggressively, this conserves memory
ENV RUBY_GC_HEAP_GROWTH_MAX_SLOTS 40000
ENV RUBY_GC_HEAP_INIT_SLOTS 400000
ENV RUBY_GC_HEAP_OLDOBJECT_LIMIT_FACTOR 1.5

ARG DISCOURSE_DB_SOCKET=''
ARG DISCOURSE_DB_HOST=postgres
ARG DISCOURSE_DB_PORT=5432
ARG DISCOURSE_DB_USERNAME=discourse
ARG DISCOURSE_DB_PASSWORD=''
ARG DISCOURSE_REDIS_HOST=redis
ARG DISCOURSE_DEVELOPER_EMAILS=muraken@gmail.com
ARG DISCOURSE_HOSTNAME=discourse.ruby-data.org

ADD . /tmp/discourse.ruby-data.org

RUN /tmp/discourse.ruby-data.org/bin/wait-for postgres:5432
# RUN /tmp/discourse.ruby-data.org/bin/wait-for redis:6379

RUN env | sort

RUN cd /tmp/discourse.ruby-data.org \
	&& git submodule update --init \
	&& templates="discourse_docker/templates/web.template.yml discourse_docker/templates/web.ratelimited.template.yml" \
        && input="$(bin/generate_pups_input app.yml)" \
	&& input="hack: true"; for template in $templates; do input="$input _FILE_SEPERATOR_ $(cat ${template})"; done \
	&& cd /pups \
	&& echo "$input" | /pups/bin/pups --stdin \
	&& rm -rf /tmp/discourse.ruby-data.org

CMD ["/sbin/boot"]
