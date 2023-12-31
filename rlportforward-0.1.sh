#!/bin/bash
##
# versao: 0.1 | 31 de agosto de 2023 
##############################################

Ajuda()
{
   # Display Help
   echo "Script para criação e gerencia de SSH Port Forward Local e Remoto!"
   echo
   echo "sintaxe: rportforward [-l|h|v|k]"
   echo "opções:"
   echo "l     Mostra licença."
   echo "h     Mostra ajuda."
   echo "k     Mata túneis abertos."
   echo "v     Mostra a versão."
   echo "R     Forward remoto - conexão com a porta TCP no host remoto será encaminhado para o host e porta local."
   echo "L     Forward local - conexão com a porta TCP local será encaminhado para porta e host remoto."
   echo
}

Kill(){
  tunnels=$(ps -ef |grep -E "[[:space:]]ssh.*[RL]" |awk '{print $2}'|xargs) 
  if [ -z ${tunnels} ]; then
    sleep 1
    echo "Não há túnel reverso ssh aberto!"
    echo "Tchau...o/"
    exit 0
  else
    echo
    echo "Encontrado tunel forward SSH e matando geral... :)"
    sleep 1
    echo ${tunnels} |xargs kill -9 
    echo "Finalizado todos os tuneis!!"
    exit 0
  fi
}

BSD()
{
  # Display licença
  echo "
  SPDX-License-Identifier: BSD-3-Clause
 
  BSD 3-Clause License
  
  Copyright (c) 2023, 0xttfx
  
  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
  
  1. Redistributions of source code must retain the above copyright notice, this
     list of conditions and the following disclaimer.
  
  2. Redistributions in binary form must reproduce the above copyright notice,
     this list of conditions and the following disclaimer in the documentation
     and/or other materials provided with the distribution.
  
  3. Neither the name of the copyright holder nor the names of its
     contributors may be used to endorse or promote products derived from
     this software without specific prior written permission.
  
  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  "  
  
  echo " "
}

Versao(){
  echo "
    Sou um programa feito na correria! hehe
    Portanto, aponte melhorias para que sejam implementadas...

    Data criação: 31 de agosto de 2023
    Versão: 0.1
    "
}


# verificando tuneis ativos
tuneis=$(ps -ef |grep -E "[[:space:]]ssh.*[RL]" |awk '{print $2}'|xargs)

Local(){
if [[ -z ${tuneis} ]]; then

  sleep 1; echo -n ". "; sleep 1; echo -n  ".. "; sleep 1; echo "..."

  if [[ -z "${ssh_user}"  ]]; then
    sleep 1
    echo ""
    read -p 'Nome do usuário: ' ssh_user
    if [[ -z "${ssh_user}"  ]]; then
      echo ""
      echo "Ops!"
      echo "Um nome de usuário é requerido!"
      exit 1
    fi
  fi
  
  if [[ -z "${local_port}"  ]]; then
    echo ""
    sleep 1
    read -p 'Porta TCP local!É o listening socket da sua aplicação na sua máquina: ' local_port
    echo ""
    if [[ -z "${local_port}"  ]]; then
      echo "Ops! ...o/"
      echo "Uma porta local é requerido!"
      echo ""
      exit 1
    fi
  fi

  if [[ -z "${remote_port}"  ]]; then
    echo ""
    sleep 1
    read -p 'Porta TCP remoto!Será o listening socket no host remoto: ' remote_port
    echo ""
    if [[ -z "${remote_port}"  ]]; then
      echo "Ops! ...o/"
      echo "Um número de porta é requerido!"
      echo ""
      exit 1
    fi
  fi

  if [[ -z "${ssh_host}"  ]]; then
    echo ""
    sleep 1
    read -p 'IP ou nome DNS do host remoto: ' ssh_host
    echo ""
    if [[ -z "${ssh_host}"  ]]; then
      echo "Ops! ...o/"
      echo "Endereço de host é requerido!"
      echo ""
      exit 1
    fi
  fi


  ssh_user=$(echo ${ssh_user})
  # set your host name here
  ssh_host=$(echo ${ssh_host})
  # set the local port to map
  local_port=$(echo ${local_port})
  # set the remote port to map
  remote_port=$(echo ${remote_port})



  echo 
  echo "Opa..o/"
  echo "Vou fazer forward da porta remota ${remote_port} em ${ssh_user}@${ssh_host} para a porta local 127.0.0.1:${local_port} da sua máquina"
  echo ""
  sleep 1
  read -n1 -rsp $'Pressione qualquer tecla pra continuar ou Ctrl+C pra sair dessa treta...\n'

  # criando tunel remoto e redirecionando porta remota para local
  ssh -nNT -L ${remote_port}:localhost:${local_port} ${ssh_user}@${ssh_host} &
  ssh_pid=$!
  echo "Quando não precisar mais do túnel! Basta me executar com a opção '-k' que eu limpo tudo pra você!"
  echo "...o/"
else
  echo "Olha a treta!"
  echo "Já existe túnel aberto!Feche-o antes de abrir outro túnel..."
  echo "Execute-me novamente com a opção '-k'"
  exit 0
fi
}


Reverso(){
if [[ -z ${tuneis} ]]; then
  
  sleep 1; echo -n ". "; sleep 1; echo -n  ".. "; sleep 1; echo "..."

  if [[ -z "${ssh_user}"  ]]; then
    sleep 1
    echo ""
    read -p 'Nome do usuário: ' ssh_user
    if [[ -z "${ssh_user}"  ]]; then
      echo ""
      echo "Ops!"
      echo "Um nome de usuário é requerido!"
      exit 1
    fi
  fi
  
  if [[ -z "${local_port}"  ]]; then
    sleep 1
    echo ""
    read -p 'Porta TCP local!É o listening socket da sua aplicação na sua máquina: ' local_port
    if [[ -z "${local_port}"  ]]; then
      echo "Ops! ...o/"
      echo "Uma porta local é requerido!"
      echo ""
      exit 1
    fi
  fi

  if [[ -z "${remote_port}"  ]]; then
    sleep 1
    echo ""
    read -p 'Porta TCP remoto! Será o listening socket no host remoto: ' remote_port
    if [[ -z "${remote_port}"  ]]; then
      echo "Ops! ...o/"
      echo "Um número de porta é requerido!"
      echo ""
      exit 1
    fi
  fi

  if [[ -z "${ssh_host}"  ]]; then
    echo ""
    sleep 1
    read -p 'IP ou nome DNS do host remoto: ' ssh_host
    echo ""
    if [[ -z "${ssh_host}"  ]]; then
      echo "Ops! ...o/"
      echo "Endereço de host é requerido!"
      echo ""
      exit 1
    fi
  fi


  ssh_user=$(echo ${ssh_user})
  # set your host name here
  ssh_host=$(echo ${ssh_host})
  # set the local port to map
  local_port=$(echo ${local_port})
  # set the remote port to map
  remote_port=$(echo ${remote_port})



  echo 
  echo "Opa..o/"
  echo "Farei o SSH forward da porta remota ${remote_port} em ${ssh_user}@${ssh_host} para a porta local 127.0.0.1:${local_port} da sua máquina!"
  echo ""
  sleep 1
  read -n1 -rsp $'Pressione qualquer tecla pra continuar ou Ctrl+C pra sair dessa treta...\n'

  # criando tunel remoto e redirecionando porta remota para local
  ssh -nNT -R ${remote_port}:localhost:${local_port} ${ssh_user}@${ssh_host} &
  ssh_pid=$!
  echo "Quando não precisar mais do túnel!Execute-me com a opção '-k', que eu limpo tudo pra você!"
  echo "...o/"
else
  echo "Olha a treta!"
  echo "Já existe túnel aberto!Feche-o antes de abrir outro túnel."
  echo "Execute-me novamente com a opção '-k'"
  exit 0
fi
}

if [ -z "$*" ]; then 
  sleep 1
  echo
  Ajuda
  echo
  exit 1
fi

# Lendo opções
###############################################################################
while getopts ":hlvkLR" option; do
   case $option in
      h) # mostra Help
         Ajuda
         exit 0;;
      l) # mostra licença
         BSD
         exit 0;;
      k) # kilando tuneis reversos ssh
         Kill
         exit 0;;
      v) # Versão
         Versao
         exit 0;;
      R) # Túnel reverso
         Reverso
         exit 0;;
      L) # Tunel local
         Local
         exit 0;;
      \?) # incorrect option
         echo "Error: Opção inválida"
         exit 1;;
   esac
done

