# List out this
alias lisa='cat ~/.bash_aliases'

# Environment Variables
# This is written in .bashrc and it should be excuted when starting terminal
alias kconfig='export KUBECONFIG=~/.kube/config.onap'

# kubectl -n onap series
alias kgetp='kubectl -n onap get pods'
alias kgeta='kubectl -n onap get all'
alias kdscp='kubectl -n onap describe pod'
alias klogp='kubectl -n onap logs'

# helm series
alias hls='helm list'

# h2 series
alias j2nfs='ssh -i ~/.ssh/danielshihkey.pem ubuntu@203.145.218.77'
alias j2w1='ssh -i ~/.ssh/danielshihkey.pem ubuntu@203.145.218.241'
alias j2w2='ssh -i ~/.ssh/danielshihkey.pem ubuntu@203.145.218.23'
alias j2w3='ssh -i ~/.ssh/danielshihkey.pem ubuntu@203.145.218.71'
alias j2w4='ssh -i ~/.ssh/danielshihkey.pem ubuntu@203.145.218.44'
alias j2w5='ssh -i ~/.ssh/danielshihkey.pem ubuntu@203.145.218.228'
alias j2w6='ssh -i ~/.ssh/danielshihkey.pem ubuntu@103.124.72.8'
