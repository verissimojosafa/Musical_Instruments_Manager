#!/bin/bash

function showMenu() {
  echo "${ACTION_RETRIEVEALL}. Listar"
  echo "${ACTION_CREATE}. Cadastrar"
  echo "${ACTION_RETRIEVE}. Buscar"
  echo "${ACTION_DELETE}. Remover"
}

function getAction() {
  read action
}

function doValidNumber() {
  local number=$1

  if [ "$(echo $number | grep "^[ [:digit:] ]*$")" ]; then
    return 0
  else
    return 1
  fi
}

function doValidAction() {
  if [ "${action}" != "" ]; then
    doValidNumber $action
    if [ $? -eq $TRUE ]; then
      if [ $action -ge $MIN_ACTION -a $action -le $MAX_ACTION ]; then
        errorMsg=""
        error=1
      else
        errorMsg="Acao invalida"
        error=0
      fi
    else
      errorMsg="Insira um numero"
      error=0
    fi
  else
    errorMsg="A acao nao foi inserida"
    error=0
  fi
}

function doAction() {
  if [ $action -eq $ACTION_RETRIEVEALL ]; then
    retrieveAll

  elif [ $action -eq $ACTION_CREATE ]; then
    create

  elif [ $action -eq $ACTION_RETRIEVE ]; then
    retrieve

  elif [ $action -eq $ACTION_DELETE ]; then
    delete

  fi
}

#CR[U]D

#Retrieve All
function retrieveAll() {
  content="$(cat $FILENAME)"

  if [ -n "$content" ]; then
    printf "\nInstrumentos:\n"
    printf "%s\n" "$content"
  else
    echo "Não há instrumentos cadastrados"
  fi
}

function getNumberValue() {
  while :; do
    echo $1
    read number

    doValidNumber "$number"
    if [ $? -eq $TRUE ]; then
      break
    else
      echo "Insira um numero"
      echo ""
    fi
  done
}

#Create
function create() {
  printf "\nAdicionar instrumento:\n"

  echo "Digite o nome do instrumento"
  read name

  msg="Digite o preco do instrumento(R$)"
  getNumberValue "$msg"
  price=$number

  msg="Digite o peso do instrumento(Kg)"
  getNumberValue "$msg"
  weight=$number

  msg="Digite o tamanho do instrumento(cm)"
  getNumberValue "$msg"
  size=$number

  row="${name}: R$ ${price} - ${weight}Kg - ${size}cm"

  echo $row >>$FILENAME
}

#Retrieve
function retrieve() {
  printf "\nBuscar instrumento:\n"

  echo "Digite um texto para ser usado como busca"
  read text

  cat $FILENAME | grep "$text"
}

#Delete
function delete() {
  printf "\nDeletar instrumento:\n"

  echo "Digite um texto para ser usado como busca para deletar o registro"
  read text

  sed -i /"$text"/d $FILENAME
}

function waitEnter() {
    echo ""
    echo "Pressione enter"
    read
}

function interface() {
  echo "CR[U]D - Instrumentos Musicais"

  local flag=0
  local stop=1
  while [ $stop -ne $flag ]; do
    echo "Insira o número 0 para parar"
    echo ""

    showMenu
    getAction
    doValidAction
    
    if [ $action -eq $flag ]; then
        break
    fi

    if [ $error -eq $FALSE ]; then
      if [ $action -eq $flag ]; then
        break
      fi
      doAction
    else
      echo $errorMsg
    fi

    waitEnter

    clear
  done
}

function generateFile() {
  if [ ! -e $FILENAME ]; then
    >$FILENAME
  fi
}

function init() {
  ACTION_RETRIEVEALL=1
  ACTION_CREATE=2
  ACTION_RETRIEVE=3
  ACTION_DELETE=4

  MIN_ACTION=$ACTION_RETRIEVEALL
  MAX_ACTION=$ACTION_DELETE

  FILENAME="instruments.txt"

  FALSE=1
  TRUE=0

  generateFile

  interface
}

init
