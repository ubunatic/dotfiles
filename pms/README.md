# PMS - Setup Notes

This doc and the file tree in the [PMS](.) space document my personal media server (PMS) setup journey.

## Why build a PMS?

1. Have a **central place** for my family to store data, such as pictures, videos, and backups of other data (less data on scattered disks and usb sticks)

2. Replace our "Fotos" disk with 24/7 available setup with better backups than my random copies of the disk and with good search by topic/person/location and more; plus albums, editing, etc. (Immich)

3. Host apps, such Home Assistant, Grafana, PiHole, Immich, and more (running on Pi4s now with mixed quality)

4. Start building media collection of TV shows and movies, and games. As EU citizen I have the right to copy from GOG, Steam, and others. Also keep copies of all my old console games and abandonware.

5. Manage other hosts (via Cockpit, Portainer, or similar, depending on the build).

## How to get started?

Start small, using a 1 liter PC with low idle power consumption. It should be able to run most parts.
Be ready to switch to another machine (maybe an AI mini PC later). However, low idle power draw always remains main criteria. Move dedicated apps to more powerful/extra host or dedicated hosts (RPi4+).

> [!Note]
> Why focus on low idle power draw? Because it costs! Every 10W of 24/7 operation costs: \
> `0.30€/kWh * 0.01kW * 24h * 365d = 26.28€/y`

Either I put systems on a schedule or make sure my 24h systems are only a few and are very low power.
Having a std. Tower PC with big PC-PSU may end up at 30-40W idle power, which is 80-100€/y just for the idle system. Not sure how my old PC-PSUs perform these days, but also the fan noise and access heat would be an issue. My current (unused) Tower PC, makes quite some noise during idle. Noise means heat, heat means high power and that I won's consider running it 24/7.

There are many Mini PCs, SSF PCs, Mini NAS builds and guides. However, what stopped me so far was
that I have a lot of old hardware that still works well and should be reused.
Many solutions required a lot of new stuff, like buyng a 8/12/X-bay NAS cases
or 2/4/X-bay Mini NASes. Also many builds were focussed on big homegeneously sized HDDs
rather than mixed-size SSDs. And it always seemed to required going all-in on RAID.

> [!Note]
> RAID systems always seemed weird to me when thinking of the buch of disks I own.
> I want my disks to have plain files in case somethings goes off in my hand-crafted,
> single-person maintainer setup.

### The mixed-disk non-RAID homelab!
This is when I found [Wolgang's Channel]() and thereby [Alex's]() PMS site and knew immediately:
This is what I want, because their setup works in a way I can understand and control.

1. All disks contain files. No "striping"! While still providing an std. way to safety.

2. Disk sizes can be mixed. I can keep my old disks until they die and replace them with bigger disks.

3. Fully OSS, with the option to replace components if an OSS project goes down the river.

4. TrueNAS, Unraid, custom OSes are build around RAID concepts and seemed less portable to me.

There is a super simple disk setup proposed by Wolfgang[<sup>1</sup>](https://www.youtube.com/watch?v=qyGbkEtjJ90&t=1299s). Here is my idea for this where my bunch of disks can be put to use.
```
MergerFS {
   ZFS      (fast)   { SSD1 <=> SSD2    } ---daily-move---.
   MergerFS (big)    { HDD1, USB1, USB2 } <--of-old-data--'
   Snapraid (parity) { BIG1, BIG2 }
}
```
This is what I can start with. If my old small disks draw too much power or eat up the PCI lanes, or whatever, this setup allows me to kick them out and add bigger drives easily.

For the rest, I would just follow roughly Alex's PMS guide.

## OS Options
For completeness I will also leave some more options and thought or two on them.

### Proxmox
This is what Alex's recommends as of 2025.
Everything I heard so far is good. Enterprise features can be disabled.
The EU/Vienna company looks healthy[<sup>2</sup>](https://www.northdata.com/Proxmox%20Server%20Solutions%20GmbH,%20Wien), but investors may push for paywalls some day.

### NixOS
Not my thing yet. I think some click ops for base setups is always OK, or even better, esp.
for the core system that I setup at most once a year. Ideally only every 3-5 years.

> [!Note]
> IMHO, the IaC industry is struggling anyway! Because every new IaC layer or approach
> is prone to add more complexity than it removes. In IaC tech everything must be "module"
> and thus a copy/wrapper of the original. And this copy is usually less flexible and needs
> to be maintained. When the underlying API is already very good, goodness may be lost in IaC.
>
> Is a Nix script or TF code easier to manage than some very focussed scripts or infra-deploy
> apps written against a good SDK?
>
> I am not sure. It depends on the quality of the modules
> and the IaC tech overall.

A "module" means I have another dependency between me and the API/SDK of a cloud vendor.
I want to have fewer dependencies! And I am willing to follow some official up-to-date guide
and spend some time with the tech I am using. Also I like to have full admin-access to my
resources in my private spaces and use an admin UI without being afraid that resource "state"
becomes out of sync due to my click ops.

This is why I keep my [dotfiles](../) clean of big automation tools. \
My `Makefiles` and `bash` and `go` scripts will always be easy to fix for me,
relying only on `coreutils` and the SDK/API for the tech at hand.

I can always complemented the setup with Terraform modules, Ansible playbooks,
or Containers Stacks if that makes things easier.

### Other Linuxes
It seems a Debian-based Proxmox fills all Linux needs already and has all the extras needed for a PMS.

### ZimaOS (CasaOS)
Had a quick look and it looked too Zima-hardware focussed.
Also this may be too much click ops for me and the vendor is too new.
The GH page seems focussed on Windows users who need hand-holding to flash a USB stick.
I like that the underlying CasaOS is Go-based but it is too much for the root-level system.

Proxmox is EU-based and instead of Casa I will use Nextcloud DE/EU-based and used by
EU/DE goverments. I expect some stability in these two, esp. with the ongoing growth of
"off-cloud" needs of private users and "souvereign" needs of organizations.

### Unraid
Not OSS and may not support the "I want files" setup.

### TrueNAS
Mostly RAID-focussed (afaik) and reported to be bulky and hard to maintain in some areas.

### Vendor OS
Nope! I want to be more in control and be able to switch hardware and not the main software.
I think the Chinese devs do a great job, but they will always be under the eyes of their
superiors and will (have to) deliver a few extras or a few left-outs.
I prefer my AI models to not rewrite history and KVMs to have no hidden blobs.


## Steps Taken
1. Add main scripts and stubs in new [proxmox.sh](../shell/proxmox.sh) shell funcs.

## Steps Planned
2. Reboot and [Install Proxmox](https://perfectmediaserver.com/03-installation/manual-install-proxmox/#base-os-installation) and VE scripts (wipe out the system I am typing this)
3. Get access to my dotfiles and start an IDE + browser to continue
4. Install main storage tools and setup storage (incl. host disk?)
5. Add parity storage (via USB)
6. Install and schedule snapraid to write parity
7. Continue with PMS guide

...

## More Plans

10. Install apps and backup app-init setup in dotfiles (?)
11. Install/migrate Immich and get "Fotos" up and running
12. Encrypted Cloud Backup + non-encrypted "Fotos" backup
13. Encrypted offsite backup

## Detailed Journal

### Day 1: Write things down + start scripting
- added this README to summarize what I know
- check out Zima sice it was hyped by NASCompares
- drafted the storage based on Wolfgang's setup
- cleanup up old SSD to host main OS
- cleanup Mini PC SSD to make a disk free for storage
- made a Proxmox USB stick
- copied and enhanced Alex's scripts before installing Proxmox
- install Proxmox and switch over to use as desktop
