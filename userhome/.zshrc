# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

has() {
    which $1 >& /dev/null
}

export EDITOR='vim'

export ZSH=~/.oh-my-zsh

export ZSH_THEME="afowler"

plugins=(
  git
)

fpath=(~/.zsh/completion $fpath)
autoload -Uz compinit && compinit

# asdf version manager
. $HOME/.asdf/asdf.sh

if has kubectl; then
    plugins+=(kube-ps1)

    export KUBE_PS1_SYMBOL_ENABLE=false
    export KUBE_PS1_PREFIX="["
    export KUBE_PS1_SEPARATOR=""


    kns() {
        if [[ -n $1 ]]; then
            kubectl config set-context --current --namespace=$1
        fi
        echo `kubectl config view --minify --output 'jsonpath={..namespace}'`
    }

    kubecx() {
        if [[ -n $1 ]]; then
            kubectl config use-context $1
        else
            kubectl config current-context
        fi
    }
    alias kcx=kubecx


    alias k=kubectl
    source <(kubectl completion zsh)

    # Automatically alias kg* to kubectl get <resource>
    declare -A resources
    resources[p]=pods; resources[d]=deployments; resources[ns]=namespace; resources[j]=job; resources[in]=ingresses; resources[no]=nodes; resources[cm]=configmaps; resources[i]=ingresses; resources[s]=services; resources[sec]=secrets; resources[rs]=replicasets;
    declare -A verbs
    verbs[g]=get; verbs[d]=describe; verbs[rm]=delete; verbs[c]=create
    for shortVerb in ${(k)verbs}; do
        for shortName in ${(k)resources}; do
            local shortCommand=k$shortVerb$shortName
            alias $shortCommand="kubectl ${verbs[$shortVerb]} ${resources[$shortName]}"
        done
    done


    if [[ -d ~/.kube ]]; then
        # Make the first entry a default file called config becaus some people *cough KinD* think it's ok to just insert themselves into the first file they see in $KUBECONFIG
        export KUBECONFIG=~/.kube/config.yaml:$KUBECONFIG
        for configFile in ~/.kube/*.yaml; do
            export KUBECONFIG=$KUBECONFIG:"$configFile"
        done
    fi

    function podname() { kubectl get pods | grep $1 | cut -d ' ' -f 1 }
    function podnode() { kubectl get pods $1 -o json | jq '.spec.nodeName' -r }
fi

if has docker; then
    # Set docker host
    dockerhost() {
        if [[ -n $1 ]]; then
            export DOCKER_HOST=tcp://$1:2376
        else
            echo $DOCKER_HOST
        fi
    }

    alias dkr=docker
fi

if has nvim; then
    alias vi=nvim
    export EDITOR=nvim
fi


source $ZSH/oh-my-zsh.sh

export SKIP_ADDRESULT=1


#source <(jx completion zsh)
#source <(argo completion zsh) # This doesn't work for some reason

alias py3="source ~/3venv/bin/activate"

export PATH=$PATH:/opt/sas/viya/home/bin/
export PATH=$PATH:~/.porter
export PATH=$PATH:~/.cargo/bin
export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:~/.local/bin
export PATH=$PATH:~/bin
export PATH=$PATH:$HOME/node_modules/.bin
export PATH=$PATH:~/go/bin

# Telekenesisport
tkp() {
    mv $1 $2 && cd $2
}


# Either activates an existing python virtualenvironment in the current directory tree or creates one in the current directory
snek() {
    venvpath=$PWD
    while ! [[ -d $venvpath/venv ]] && [[ "$venvpath" != "/" ]]; do
        venvpath=$(dirname $venvpath)
    done
    if [[ -d $venvpath/venv ]]; then
        source $venvpath/venv/bin/activate
    else
        echo "Creating a new virtual environment in $PWD"
        python3.12 -m venv --prompt ${PWD##*/} ./venv
        source ./venv/bin/activate
        pip install --upgrade pip

        pip install pyflakes black isort ruff mypy debugpy
        pip install python-lsp-server pyls-isort pyls-black pylsp-mypy
        if [[ -f ./requirements.txt ]]; then
            echo "Found requirements.txt. Installing."
            pip install -r ./requirements.txt
        fi
    fi
}
alias pytestdebug='python -m debugpy --listen localhost:5678 --wait-for-client -m pytest'

alias kafkacat='docker run -it confluentinc/cp-kafkacat kafkacat'

if has kubectl; then
    PROMPT='$(kube_ps1) '$PROMPT
fi
# alias pbcopy='xsel --clipboard --input'
# alias pbpaste='xsel --clipboard --output'

# This lets me use aliases one level deep in watch commands. e.g. watch kgp or watch ll
alias watch='watch '

alias szsh='source ~/.zshrc'

function watchuntil() {
    while !$1; do
        sleep 3
    done
}

function mvtmp() {
    local tmpdir=$(mktemp -d)
    mv $1 $tmpdir
    cd $tmpdir
}


export HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew";
export HOMEBREW_CELLAR="/home/linuxbrew/.linuxbrew/Cellar";
export HOMEBREW_REPOSITORY="/home/linuxbrew/.linuxbrew/Homebrew";
export PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin${PATH+:$PATH}";
export MANPATH="/home/linuxbrew/.linuxbrew/share/man${MANPATH+:$MANPATH}:";
export INFOPATH="/home/linuxbrew/.linuxbrew/share/info:${INFOPATH:-}";
export GPG_TTY=$(tty)

if [[ -f ~/workstuff.zsh ]]; then
    source ~/workstuff.zsh
fi

alias y2j='python3 -c "import sys; import json; import yaml; json.dump(yaml.safe_load(sys.stdin), sys.stdout)"'

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
