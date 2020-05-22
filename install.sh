#!/usr/bin/env bash
# based on https://github.com/alexanderepstein/Bash-Snippets/blob/v1.23.0/install.sh

# bash ./install.sh
# bash ./install.sh --prefix="/usr/local" all

declare -a tools=(yt)
prefix="/usr/local"


singleInstall()
{
  cd $1 || exit 1
  echo -n "Installing $1: "
  chmod a+x $1
  cp "$1" "$prefix/bin" > /dev/null 2>&1 || { echo "Failure"; echo "Error copying file, try running install script as sudo"; exit 1; }
  echo "Success"
  cd .. || exit 1
}

askInstall()
{
  read -p "Do you wish to install $1 in $prefix/bin [Y/n]: " answer
  answer=${answer:-Y}

  if [[ "$answer" == [Yy] ]]; then
    cd $1 || return 1
    echo -n "Installing $1: "
    chmod a+x $1
    cp "$1" "$prefix/bin" > /dev/null 2>&1 || { echo "Failure"; echo "Error copying file, try running install script as sudo"; exit 1; }
    echo "Success"
    cd .. || return 1
  fi
}

# check for --prefix argument (should be first argument)
response=$( echo "$@" | grep -Eo "\-\-prefix")

if [[ $response == "--prefix" ]]; then
  prefix=$(echo -n "$@" | sed -e 's/--prefix=\(.*\) .*/\1/' | cut -d " " -f 1)
  mkdir -p $prefix/bin
  if [[ $2 == "all" ]];then
    for tool in "${tools[@]}"; do
      singleInstall $tool || exit 1
    done
  else
    for tool in "${@:2}"; do
      singleInstall $tool || exit 1
    done
  fi
elif [[ $# == 0 ]]; then
  for tool in "${tools[@]}"; do
    askInstall $tool || exit 1
  done
elif [[ $1 == "all" ]]; then
  for tool in "${tools[@]}"; do
    singleInstall $tool || exit 1
  done
else
  singleInstall $1 || exit 1
fi

echo -n "( •_•)"
sleep 1
echo -n -e "\r( •_•)>⌐■-■"
sleep 1
echo -n -e "\r               "
echo -e "\r(⌐■_■)"
