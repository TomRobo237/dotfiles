#!/bin/sh
MYDIR="$(dirname "$(realpath "$0")")"
VIMGITFOLDER=$MYDIR'/vim_git/'
ZSHGITFOLDER=$MYDIR'/zsh_git/'
MYOUTPUT="/tmp/dotfile_replace.txt"

if test -f "$MYOUTPUT" ; then
  true > "$MYOUTPUT"
fi 

if test $1 = '-z' ; then
  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

  if test -z $ZSH_CUSTOM ; then
    ZSHGITDIR_PLUGINS="$HOME"'/.oh-my-zsh/custom/plugins'
    ZSHGITDIR_THEMES="$HOME"'/.oh-my-zsh/custom/themes'
  else
    ZSHGITDIR_PLUGINS="$HOME"'/'"$ZSH_CUSTOM"'/plugins'
    ZSHGITDIR_THEMES="$HOME"'/'"$ZSH_CUSTOM"'/themes'
  fi
  

  for i in $(perl -n -e '/\((.*)\)/ && print $1." "' zshplugin_externals.md) ; do
    PLUGIN="$(printf '%s' "$i" | awk 'BEGIN {FS="/"};{print $NF}')"
    printf 'getting: %s\n' "$PLUGIN"
    if ! git clone "$i"'.git' "$ZSHGITFOLDER$PLUGIN" ; then
      printf 'Folder already present, running git pull\n'
      git -C "$ZSHGITFOLDER$PLUGIN" pull
    fi
  done

  for i in $(perl -n -e '/\((.*)\)/ && print $1." "' zshplugin_externals.md) ; do
    PLUGIN="$(printf '%s' "$i" | awk 'BEGIN {FS="/"};{print $NF}')"
    printf 'linking: %s\n' "$PLUGIN"
    if test -L "$ZSHGITDIR_PLUGINS"'/'"$PLUGIN" ; then
      printf '%s is already symlinked to %s, removing.\n' "$PLUGIN" "$(readlink "$ZSHGITDIR"'/'"$PLUGIN")"
      rm "$ZSHGITDIR_PLUGINS"'/'"$PLUGIN"
    elif test -f "$ZSHGITDIR_PLUGINS"'/'"$PLUGIN" ; then
      printf '%s is a real file, backing up to %s.bak' "$ZSHGITDIR_PLUGINS"'/'"$PLUGIN" \
             "$PLUGIN"
      if ! cp -pn "$ZSHGITDIR_PLUGINS"'/'"$PLUGIN" "$ZSHGITDIR_PLUGINS"'/'"$PLUGIN"'.bak' ; then
        printf '%s.bak already exists, exiting to allow manual intervention.' \
               "$PLUGIN"
        exit 1
      else
        rm "$ZSHGITDIR_PLUGINS"'/'"$PLUGIN" 
      fi
    fi
    ln -vs "$MYDIR"'/zsh_git/'"$PLUGIN" "$ZSHGITDIR_PLUGINS"'/'"$PLUGIN" >> "$MYOUTPUT"
  done

  for i in $(perl -n -e '/\((.*)\)/ && print $1." "' zshtheme_externals.md) ; do
    PLUGIN="$(printf '%s' "$i" | awk 'BEGIN {FS="/"};{print $NF}')"
    printf 'getting: %s\n' "$PLUGIN"
    if ! git clone "$i"'.git' "$ZSHGITFOLDER$PLUGIN" ; then
      printf 'Folder already present, running git pull\n'
      git -C "$ZSHGITFOLDER$PLUGIN" pull
    fi
  done

  for i in $(perl -n -e '/\((.*)\)/ && print $1." "' zshtheme_externals.md) ; do
    PLUGIN="$(printf '%s' "$i" | awk 'BEGIN {FS="/"};{print $NF}')"
    printf 'linking: %s\n' "$PLUGIN"
    if test -L "$ZSHGITDIR_THEMES"'/'"$PLUGIN" ; then
      printf '%s is already symlinked to %s, removing.\n' "$PLUGIN" "$(readlink "$ZSHGITDIR"'/'"$PLUGIN")"
      rm "$ZSHGITDIR_THEMES"'/'"$PLUGIN"
    elif test -f "$ZSHGITDIR_THEMES"'/'"$PLUGIN" ; then
      printf '%s is a real file, backing up to %s.bak' "$ZSHGITDIR_THEMES"'/'"$PLUGIN" \
             "$PLUGIN"
      if ! cp -pn "$ZSHGITDIR_THEMES"'/'"$PLUGIN" "$ZSHGITDIR_THEMES"'/'"$PLUGIN"'.bak' ; then
        printf '%s.bak already exists, exiting to allow manual intervention.' \
               "$PLUGIN"
        exit 1
      else
        rm "$ZSHGITDIR_THEMES"'/'"$PLUGIN" 
      fi
    fi
    ln -vs "$MYDIR"'/zsh_git/'"$PLUGIN" "$ZSHGITDIR_THEMES"'/'"$PLUGIN" >> "$MYOUTPUT"
  done
fi

RCFILES='bashrc.sh vimrc.vim zshrc.zsh'

for FILE in $RCFILES ext_*; do # Space splitting intentional
  DOTFILE='.'"$(printf '%s' "$FILE" | rev | cut -f 2- -d '.' | rev)"
  if test -L "$HOME"'/'"$DOTFILE" ; then
    printf '%s is already symlinked to %s, removing.\n' "$DOTFILE" "$(readlink "$HOME"'/'"$DOTFILE")"
    rm "$HOME"'/'"$DOTFILE"
  elif test -f "$HOME"'/'"$DOTFILE" ; then
    printf '%s is a real file, backing up to %s.bak' "$DOTFILE" "$DOTFILE"
    if ! cp -pn "$HOME"'/'"$DOTFILE" "$HOME"'/'"$DOTFILE"'.bak' ; then
      printf '%s.bak already exists, exiting to allow manual intervention.' \
             "$DOTFILE"
      exit 1
    else # Copy good, remove file
      rm "$HOME"'/'"$DOTFILE"
    fi
  fi
  ln -vs "$MYDIR"'/'"$FILE" "$HOME"'/'"$DOTFILE" >> "$MYOUTPUT"
done


if ! test -d "$HOME/.vim/plugin" ; then
  printf 'Creating %s/.vim/plugin.' "$HOME"
  mkdir -p "$HOME/.vim/plugin/"
fi
VIMDIR="$HOME/.vim/plugin"

for FILE in "$MYDIR"'/vimplugins/'*'.vim' ; do
  FILENAME="$(basename "$FILE")"
  if test -L "$VIMDIR"'/'"$FILENAME" ; then
    printf '%s is already symlinked to %s, removing.\n' "$FILENAME" "$(readlink "$VIMDIR"'/'"$FILENAME")"
    rm "$VIMDIR"'/'"$FILENAME"
  elif test -f "$VIMDIR"'/'"$FILENAME" ; then
    printf '%s is a real file, backing up to %s.bak' "$VIMDIR"'/'"$FILENAME" \
           "$FILENAME"
    if ! cp -pn "$VIMDIR"'/'"$FILENAME" "$VIMDIR"'/'"$FILENAME"'.bak' ; then
      printf '%s.bak already exists, exiting to allow manual intervention.' \
             "$FILENAME"
      exit 1
    fi
  fi
  ln -vs "$FILE" "$VIMDIR"'/'"$FILENAME" >> "$MYOUTPUT"
done

if ! test -d "$VIMDIR" ; then
  printf 'Making folder for external git files from vim.'
  mkdir "$VIMDIR"
fi

for i in $(perl -n -e '/\((.*)\)/ && print $1." "' vimplugin_externals.md) ; do
  PLUGIN="$(printf '%s' "$i" | awk 'BEGIN {FS="/"};{print $NF}')"
  printf 'getting: %s\n' "$PLUGIN"
  if ! git clone "$i"'.git' "$VIMGITFOLDER$PLUGIN" ; then
    printf 'Folder already present, running git pull\n'
    git -C "$VIMGITFOLDER$PLUGIN" pull
  fi
done

if ! test -d "$HOME/.vim/pack/default/start" ; then
  printf 'Creating %s/.vim/pack/default/start' "$HOME"
  mkdir -p "$HOME/.vim/pack/default/start/"
fi
VIMGITDIR="$HOME/.vim/pack/default/start/"

for i in $(perl -n -e '/\((.*)\)/ && print $1." "' vimplugin_externals.md) ; do
  PLUGIN="$(printf '%s' "$i" | awk 'BEGIN {FS="/"};{print $NF}')"
  printf 'linking: %s\n' "$PLUGIN"
  if test -L "$VIMGITDIR"'/'"$PLUGIN" ; then
    printf '%s is already symlinked to %s, removing.\n' "$PLUGIN" "$(readlink "$VIMGITDIR"'/'"$PLUGIN")"
    rm "$VIMGITDIR"'/'"$PLUGIN"
  elif test -f "$VIMGITDIR"'/'"$PLUGIN" ; then
    printf '%s is a real file, backing up to %s.bak' "$VIMGITDIR"'/'"$PLUGIN" \
           "$PLUGIN"
    if ! cp -pn "$VIMGITDIR"'/'"$PLUGIN" "$VIMGITDIR"'/'"$PLUGIN"'.bak' ; then
      printf '%s.bak already exists, exiting to allow manual intervention.' \
             "$PLUGIN"
      exit 1
    fi
  fi
  ln -vs "$MYDIR"'/vim_git/'"$PLUGIN" "$VIMGITDIR""$PLUGIN" >> "$MYOUTPUT"
done

if test "$OSTYPE" = "darwin" ; then
  NIXFLDR="$HOME"'/.nixpkgs/'
  if ! test -d "$NIXFLDR"; then
    mkdir -p "$NIXFLDR"
  fi

  DARWINCONF="$NIXFLDR"'darwin-configuration.nix'
  if test -L  ; then
    printf '%s is already symlinked to %s, removing.\n' "$DARWINCONF" "$(readlink "$DARWINCONF")"
    rm "$DARWINCONF"
  elif test -f "$DARWINCONF" ; then
    printf '%s is a real file, backing up to %s.bak' "$DARWINCONF" "$DARWINCONF"
    if ! cp -pn "$DARWINCONF" "$DARWINCONF"'.bak' ; then
      printf '%s.bak already exists, exiting to allow manual intervention.' \
       "$DARWINCONF"
    exit 1
    fi
  fi
  ln -vs "$MYDIR"'/darwin-configuration.nix' "$DARWINCONF" >> "$MYOUTPUT"
fi

cat "$MYOUTPUT"
