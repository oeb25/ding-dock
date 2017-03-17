FROM elixir:latest

RUN curl -sL https://deb.nodesource.com/setup_7.x | bash - && apt-get install -y nodejs
RUN apt-get update -y && apt-get install -y inotify-tools

CMD ["iex"]
