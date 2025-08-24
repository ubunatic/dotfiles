# shellcheck disable=SC2155,SC2046

proxmox-upgrade() {
    # taken from https://perfectmediaserver.com/03-installation/manual-install-proxmox/#base-os-installation
    sudo apt update &&
    sudo pveupgrade
}

proxmox-download-mergerfs(){
    # clean version of https://perfectmediaserver.com/03-installation/manual-install-proxmox/#base-os-installation

    local url_latest="https://api.github.com/repos/trapexit/mergerfs/releases/latest"
    local url_prefix="https://github.com/trapexit/mergerfs/releases/download"
    local url codename arch tag_name

    (grep VERSION_CODENAME /etc/os-release || echo "VERSION_CODENAME=debian-bookworm") | cut -d= -f2 | read codename
    if test -z "$codename"
    then err "failed top get codename"; return $!
    fi

    (dpkg --print-architecture || echo amd64) | read arch
    if test -z "$arch"
    then err "failed to read dpkg arch"; return $!
    fi

    curl -s "$url_latest" | jq -r .tag_name | read tag_name
    if test -z "$tag_name"
    then err "failed to read tag name from release"; return $!
    fi

    local deb="mergerfs_${tag_name}.${codename}_${arch}.deb"
    local url="$url_prefix/$tag_name/$deb"

    inf "codename: '$codename'"
    inf "arch:     '$arch'"
    inf "tag_name: '$tag_name'"
    inf "deb:      '$deb'"
    inf "url:      '$url'"

    wget -q "$url"
    echo "$deb"
}

proxmox-install-mergerfs() {
    local deb="$1"
    if test -e "$deb"
    then deb="$(proxmox-download-mergerfs)"
    fi
    sudo dpkg -i "$deb" &&
    apt list mergerfs
}

proxmox-list-disks() {
    # https://perfectmediaserver.com/03-installation/manual-install-proxmox/#identifying-drives
    inxi -xD
    ls /dev/disk/by-id
}

proxmox-burnin-disk() {
    # https://perfectmediaserver.com/06-hardware/new-drive-burnin/
    err "proxmox-burnin-disk not implemented, see https://perfectmediaserver.com/06-hardware/new-drive-burnin for what to do"
}

proxmox-install-helpers() {
    # see https://github.com/community-scripts/ProxmoxVE/
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/tools/pve/post-pve-install.sh)"
}

proxmox-add-disk() {
    sudo apt install inxi

    # gdisk /dev/sdX
    # o: creates a new GPT partition table (GPT is good for large drives over 3TB)
    # n: creates a new partition, num: 1, Hex/GUID (L to show codes): 8300
    # p: validate 1 large partition to be created
    # w: writes the changes (until this point, gdisk has been non-destructive)

    # mkfs.ext4 /dev/sdX1

    # mkdir /mnt/manualdiskmounttest
    # mount /dev/disk/by-id/ata-HGST_HDN728080ALE604_R6GPPDTY-part1 /mnt/manualdiskmounttest
    err "proxmox-add-disk not implemented"
}

proxmox-install-snapraid() {
    apt install snapraid
    inf "snapraid installed, please setup your config"
}

proxmox-init-storage() {
    # See https://perfectmediaserver.com/03-installation/manual-install-proxmox/#hard-drive-setup

    # mkdir /mnt/disk{1,2,3,4}
    # mkdir /mnt/parity1 # adjust this command based on your parity setup
    # mkdir /mnt/storage # this will be the main mergerfs mountpoint

    ##/etc/fstab example
    #
    # /dev/disk/by-id/ata-WDC_WD100EMAZ-00WJTA0_16G0Z7RZ-part1 /mnt/parity1 ext4 defaults 0 0
    # /dev/disk/by-id/ata-WDC_WD100EMAZ-00WJTA0_16G10VZZ-part1 /mnt/disk1   ext4 defaults 0 0
    # /dev/disk/by-id/ata-WDC_WD100EMAZ-00WJTA0_2YHV69AD-part1 /mnt/disk2   ext4 defaults 0 0
    # /dev/disk/by-id/ata-WDC_WD100EMAZ-00WJTA0_2YJ15VJD-part1 /mnt/disk3   ext4 defaults 0 0
    # /dev/disk/by-id/ata-HGST_HDN728080ALE604_R6GPPDTY-part1  /mnt/disk4   ext4 defaults 0 0

    # /mnt/disk* /mnt/storage fuse.mergerfs defaults,nonempty,allow_other,use_ino,cache.files=off,moveonenospc=true,dropcacheonclose=true,minfreespace=200G,fsname=mergerfs 0 0

    ## SnapRAID configuration file

    # # Parity location(s)
    # 1-parity /mnt/parity1/snapraid.parity
    # 2-parity /mnt/parity2/snapraid.parity

    # # Content file location(s)
    # content /var/snapraid.content
    # content /mnt/disk1/.snapraid.content
    # content /mnt/disk2/.snapraid.content

    # # Data disks
    # data d1 /mnt/disk1
    # data d2 /mnt/disk3
    # data d3 /mnt/disk4

    # # Excludes hidden files and directories
    # exclude *.unrecoverable
    # exclude /tmp/
    # exclude /lost+found/
    # exclude downloads/
    # exclude appdata/
    # exclude *.!sync

    err "proxmox-init-storage not implemented"
}
