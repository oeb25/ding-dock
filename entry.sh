[ -z "$DING_DOCK_DIR" ] && DING_DOCK_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
[ -z "$DD_CONFIG_DIR" ] && DD_CONFIG_DIR=$DING_DOCK_DIR/go

dd-refresh() {
	. "$DING_DOCK_DIR/entry.sh"
}

dd-build-image() {
	LAST_DIR=$(pwd)

	cd $DING_DOCK_DIR

	docker build -t dd-$1 $1

	cd $LAST_DIR
}

dd-build-all-images() {
	build-image elixir
	build-image node
	build-image kakoune
	build-image docker-compose
}

dd-runner() {
	dd-refresh
	docker run --rm -it -v $PWD:/cwd -w /cwd $@
}

# This is a little to specific, a more dynamic function would be appropriate,
# maybe like jessfraz's relies_on?
dd-runner-pg() {
	local state
	local container
	container="dd-postgres-host"
	state=$(docker inspect --format "{{.State.Running}}" "$container" 2>/dev/null)

	if [[ "$state" == "false" ]] || [[ "$state" == "" ]]; then
		echo "Postgres is not running, starting it for you."
		dd-postgres-start
	fi

	dd-runner --link dd-postgres-host:postgres $@
}

dd-elixir() {
	dd-runner-pg -p 4000:4000 -v $DD_CONFIG_DIR/mix:/root/.mix dd-elixir $@
}

dd-java() {
	dd-runner java:7 $@
}

dd-php() {
	dd-runner -v $DD_CONFIG_DIR/composer:/composer composer $@
}

dd-node() {
	dd-runner -v $DD_CONFIG_DIR/node/yarn:/root/.config/yarn \
		-v $DD_CONFIG_DIR/node/bin:/cache/bin \
		dd-node $@
}

dd-haskell() {
	dd-runner haskell $@
}

dd-docker-compose() {
	dd-runner -v /var/run/docker.sock:/var/run/docker.sock dd-docker-compose $@
}

dd-go() {
	[ -z "$GOPATH" ] && GOPATH=$HOME/go
	dd-runner -v $GOPATH:/go golang $@
}

dd-postgres-start() {
	docker run --rm --name dd-postgres-host -d \
		-e POSTGRES_PASSWORD=$PG_PASS \
		-e POSTGRES_INITDB_ARGS="--data-checksums" \
		-e PGDATA=/var/lib/postgresql/data/pgdata \
		-v $DD_CONFIG_DIR/pg:/var/lib/postgresql/data/pgdata \
		postgres
}

alias docker-compose="dd-docker-compose docker-compose"

alias psql="dd-runner postgres psql -h postgres"

alias elixir="dd-elixir elixir"
alias mix="dd-elixir mix"
alias erl="dd-elixir erl"

alias java="dd-java java"
alias javac="dd-java javac"

alias kak="dd-runner -v $DD_CONFIG_DIR/kak:/usr/share/kak dd-kakoune kak"

alias php="dd-php php"
alias composer="dd-php composer"

alias node="dd-node node"
alias yarn="dd-node yarn"
alias npm="echo \"Please use yarn instead. Here, I'll run it for you!\" && yarn"
alias webpack="dd-node webpack"

alias ghc="dd-haskell ghc"
alias ghci="dd-haskell ghci"
alias alex="dd-haskell alex"
alias cabal-install="dd-haskell cabal-install"
alias stack="dd-haskell stack"

alias go="dd-go go"

# Misc

get-awesome-jess-apps() {
	curl https://raw.githubusercontent.com/jessfraz/dotfiles/master/.dockerfunc -o apps.sh
	. apps.sh
	rm apps.sh
}
