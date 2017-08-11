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

IGNORE_PATHS=${IGNORE_PATHS:-}
RUN_STEP=${RUN_STEP:-true}
TRIGGER_PATHS=${TRIGGER_PATHS:-}

IGNORE_PATHS=($IGNORE_PATHS)
TRIGGER_PATHS=($TRIGGER_PATHS)

if [ ${#IGNORE_PATHS[@]} -eq 0 ]; then
  echo "Nothing to skip"
  echo "export RUN_STEP=true" >> $BASH_ENV
  exit 0
fi

MASTER_SHA1=`git merge-base origin/master HEAD`

for git_path in `git diff --name-only $MASTER_SHA1`; do
  for trigger in ${TRIGGER_PATHS[@]}; do
    if [[ $git_path =~ $trigger ]]; then
      break
    fi
  done

  for ignore in ${IGNORE_PATHS[@]}; do
    if [[ $git_path =~ $trigger ]]; then
      RUN_STEP=false
      break
    fi
  done
done

echo "export RUN_STEP=$RUN_STEP" >> $BASH_ENV
