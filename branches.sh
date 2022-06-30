#!/bin/bash

# Creating a directory for all git scripts
directory="$HOME/git-scripts"
if [ ! -d $directory ]; then
	echo "Creating directory for git scripts..."
	mkdir $directory
else
	echo "Directory for git scripts already exist!"
fi

# Adding script for git branches command
cd ~/git-scripts;
filename="git-branches"
if [ ! -f "$filename" ]; then
	echo "Creating the script for git branches command..."
	touch $filename
	chmod +x git-branches; cd ..
else
	echo "File already exist!"
	echo "Updating the script with new version..."
	> $filename
fi

cat > $HOME/git-scripts/git-branches << 'EOL'
#!/bin/bash

# @desc Print current branch name with color
function listBranchesWithColor() {
  branch=$1
  description=$2
  if [ "${branch::1}" == "*" ]; then
    printf "$branch - $description\n"
  else
    printf "  $branch - $description\n"
  fi
}

# @desc Print all branch names and their corresponding descriptions
# @param Pass either --color or --no-color tag as parameter
# @example output:
# $ ./git-branches.sh
# * master        this is the master branch
#   develop       this is the development branch for testing
function listBranchesWithDescription() {
  branches=`git branch $1`

  # A branch description can be set using the command:
  # git branch --edit-description
  # This opens the configured text editor. Enter message, save and exit.
  # You can also set the branch's description with the command:
  # git config branch.<branch name>.description "<branch description>"

  # You can see branch's description using
  # git config branch.<branch name>.description

  output=""
  while read -r branch; do
    # Git marks current branch with "* ", remove it
    branch_name=${branch//\*\ /}
    # Replace colors if any
    if [ "$1" == "--color" ]; then
      branch_name=`echo $branch_name | tr -d '[:cntrl:]' | sed -E "s/\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g"`
    fi
    # Replace symbolic-ref like `HEAD -> master`
    branch_name=`echo $branch_name | sed -E "s/^.+ -> //g"`

    description=`git config branch.$branch_name.description`
    if [ ! "$description" ]; then
      description="-"
    fi

    if [ "$1" == "--color" ]; then
      listBranchesWithColor "$branch" "$description"
    else
      if [ "${branch::1}" == "*" ]; then
        output+="* $branch_name\t$description\n"
      else
        output+="  $branch_name\t$description\n"
      fi
    fi
  done <<< "$branches"
  printf "$output" | column -ts $'\t'
}

if [[ "$@" = "" ]]; then
  listBranchesWithDescription "--no-color"
elif [[ "$@" =~ "--color" || "$@" =~ "--no-color" ]]; then
  listBranchesWithDescription "$@"
else
  branch_operation_result=`git branch $@`
  printf "$branch_operation_result\n"
fi
EOL

filename=".bashrc"
if [ ! -f "$filename" ]; then
	touch $filename
fi

filename=".bash_profile"
if [ ! -f "$filename" ]; then
touch $filename
cat > $HOME/$filename << 'EOL'
test -f ~/.profile && . ~/.profile
test -f ~/.bashrc && . ~/.bashrc
EOL
fi

if ! $(echo "$PATH" | tr ":" "\n" | grep -qx "$directory") ; then
	echo "Adding git-scripts directory to the path variable..."
	echo 'export PATH=$PATH:$HOME/git-scripts' >> ~/.bashrc
	source ~/.bashrc
fi

# Use <git branch-ed> to add description for current branch
git config --global alias.branch-ed 'branch --edit-description'
printf "Successfully ran the script for git branches command\n\n"
printf "Add descriptions to git branches easily with:\n\t $ git branch-ed\n
View all git branches and their description using:\n\t $ git branches\n"
