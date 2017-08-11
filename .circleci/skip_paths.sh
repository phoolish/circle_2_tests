#!/bin/bash
#
# This is a helper script for CircleCI to help you skip steps based on paths touched during the commit.

# Paths can be full path to file or regex
# Step vars trump image vars
# Trigger var trumps ignore var

# Check for step vars.
  # If none, check for image vars
    # if set, check if RUN_IMAGE is set.
      # If set, quit and go.
      # If not, decide to RUN_IMAGE or not.
# Else use step vars
  # Decide to RUN_IMAGE or not

# If necessary, set defaults for image/step.
is_array() {
  local variable_name=$1
  [[ "$(declare -p $variable_name)" =~ "declare -a" ]]
}

make_array() {
  local var1=$1

  if ! is_array $var1; then
    var1=($var1)
  fi

  return $var1
}

IGNORE_PATHS=${IGNORE_PATHS:-}
TRIGGER_PATHS=${TRIGGER_PATHS:-}

RUN_STEP=${RUN_STEP:-}

TRIGGER_PATHS=`make_array $TRIGGER_PATHS`
IGNORE_PATH=`make_array $IGNORE_PATHS`

if [ ${#STEP_IGNORE_PATH[@]} -eq 0 ]; then
  echo "Nothing to skip"
  echo "export RUN_STEP=true" >> $BASH_ENV
  exit 0
fi

MASTER_SHA1=`git merge-base origin/master HEAD`

for git_path in `git diff --name-only $MASTER_SHA1`; do
  for trigger in ${TRIGGER_PATHS[@]}; do
    if [[ $git_path =~ $trigger ]]; then
      echo "export RUN_STEP=true" >> $BASH_ENV
      exit 0
    fi
  done

  for ignore in ${IGNORE_PATHS[@]}; do
    if [[ $git_path =~ $trigger ]]; then
      echo "export RUN_STEP=false" >> $BASH_ENV
      exit 0
    fi
  done
done
