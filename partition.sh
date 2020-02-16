#!/usr/bin/env bash
# File      : partition.sh
# Created by: Oleg Bocharov - hellseher
# Created   : <2017-9-20 Wed 12:26:17 BST>
# Modified  : <2020-1-9 Wed 19:19:00 BST> Edino Moniz "onidemon"

if [[ $(id -u) -ne 0 ]] ;
then echo "No permitions to run script, run as root." ;
  exit 1;
fi

VERSION=0.0.1
CMDNAME=partition.sh
REQUIRE=(date lsblk setfactl mkdir lvm parted mkfs.ext4)

# conditional output formats
PAS=
ERR=
INF=

BLK_DEV=
# ---------------------------------------
#+UTILITIES_MODULE

_err()
{ # All erros go to stderr
  printf "[%s]: %s\n" "$(date +%s)" "$1"
}

_msg()
{ # feedback messages to stdout
  printf "[%s]: %s\n" "$(date +%s)" "$1" >&1
}

chk_requiered()
{ # check that every requiered command is available.
  declare -a cmds
  declare -a warn

  cmds=(${1})

  for i in ${cmds[@]}; do
    command -v "$c" &>/dev/null || warn+=("$c")
  done

  [ "${#warn}" -ne 0 ] &&
    { _err "${ERR}commands <${warn[*]}> are not available. Install them first.";
      return 1;
    }
}

chk_dev()
{ # list all block devices, and ask user to choose target one.
  _msg "${INF} available devices"

  lsblk -lp
  echo

  _msg "${INF} select target device to create /my_data"
  while true; do
    read -r -p "Device: " blk_dev
    BLK_DEV="$blk_dev"
    [ -e "$blk_dev" ] && { echo "$blk_dev"; break; }
    _err "${ERR} not valid device"
  done
}

cfg_rm_partition()
{
  # clean up the device from any partitions that might exist.
  echo "in progress..."
}

cfg_mk_partition()
{
  local blk_dev="$1"

  _msg "---[$FUNCTION]---"

  if [[ -e "$blk_dev" ]]; then
    parted -s "$blk_dev" mklabel gpt
    parted -s "$blk_dev" mkpart my_data ext4 8192K 100%
    lvm pvcreate "${blk_dev}1"
    lvm vgcreate my_data "${blk_dev}1"
    lvm lvcreate -n my_data my_data -l 100%FREE

    _msg "${INF} creaate my_data filesystem"
    mkfs.ext4 -L my_data /dev/my_data/my_data
    if grep "LABEL\=my_data" &> /dev/null /etc/fstab; then
      sed -i -e \
        "s/LABEL\=my_data*/LABEL=my_data /my_data etx4 defaults 0 0/g" /etc/fstab
    else
      echo "LABEL=my_data /my_data ext4 defaults 0 0" >> /etc/fstab
    fi
  else
    _err "${ERR} can't detect device ${blk_dev}"
  fi
}

cfg_mk_structure()
{ # create required /my_data structure and set permissions

  _msg "---[$FUNCNAME]---"

  _msg "${INF} create my_data structure"
  mkdir -p /my_data/{vmachines,ISO,backup,dockerfiles}
  # add additional folders here
  # mkdir -p /my_data/{folder_x/{sub_folder_x,sub_folder_y,sub_folder_z}}

  _msg "${INF} set /my_data permissions"
  chmod -R 775 /my_data

  _msg "${INF} set /my_data ownership"
  chown \
    -R edinomoniz:vmachines \
    /my_data \
    /my_data/vmachines \
    /my_data/ISO

  chown \
    -R edinomoniz:edinomoniz \
    /my_data/backup
    /my_data/dockerfiles

  _msg "${INF} set facl"
  setfacl \
    - m o::--- \
    "/my_data/backup/" \
    "/my_data/dockerfiles/" \
    "/my_data/vmachines/"
}

main()
{
  printf "Start %s v%s at %s\n\n" "${CMDNAME}" "${VERSION}" "$(date)"

  chk_required "${REQUIRE[*]}"

  _option="$1"
  case $_option in
    struct)
      echo "Create just the structure"
      [ -e /my_data ] || mkdir /my_data
      chk_mk_structure
      ;;
    make)
      echo "Making the my_data"
      [ -e  ] || mkdir /my_data
      chk_dev
      cfg_rm_partition
      cfg_mk_partition "$BLK_DEV" && mount -a
      cfg_mk_structure
      ;;
    *)
      printf "Usage: $0 [struct | make]\n"
      ;;
  esac
}

main "$@"
# End of partitions.sh
