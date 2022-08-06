#!/bin/bash
apk add samba
rc-update add samba
os=$1
workgroup=$2
allow=$(echo "$3"|tr "#" " ")
user1=$4
user2=$5
group=$6
path1=$7
path2=$8
path3=$9
path4=${10}
path5=${11}
path6=${12}
path7=${13}
path8=${14}
cat << EOF >> /tmp/smb.conf
[global]
#General
  workgroup = $workgroup
  server role = standalone
  smb ports = 445
  server string = Serveur SAMBA
#Mot de passe
  security = user
  passdb backend = tdbsam
#Securite
  min protocol = SMB2
  case sensitive = true
  inherit permissions = yes
  nt acl support = no
  inherit acls = yes
  disable netbios = yes
  mangled names = illegal
  store dos attributes = no
  veto files = /.zfs/.snapshot/.DS_Store/
  hosts allow = $allow
  hosts deny = 0.0.0.0/0
#Mapping de comptes
  map archive = no
  map hidden = no
  map readonly = no
  map system = no
  map to guest = Bad User
#apple like
  vfs objects = catia fruit streams_xattr #Apple
  fruit:metadata = stream #Apple
  fruit:resource = xattr #Apple
  fruit:aapl = yes #Apple
  fruit:model = MacSamba #Apple
  fruit:veto_appledouble = no #Apple
  fruit:posix_rename = yes #Apple
  fruit:zero_file_id = yes #Apple
  fruit:wipe_intentionally_left_blank_rfork = yes #Apple
  fruit:delete_empty_adfiles = yes #Apple
  fruit:nfs_aces = no #Apple
  fruit:time machine = no #Apple
  ea support = yes #Apple
#Impression desactive
  load printers = no
  printing = bsd
  printcap name = /dev/null
  disable spoolss = yes
#Recherche
  spotlight = no #Apple
  #spotlight backend = elasticsearch #Apple
  #elasticsearch:address = 127.0.0.1 #Apple
  #elasticsearch:port = 9200 #Apple
  #elasticsearch:index = storage #Apple
#Liens
  widelinks = yes
  follow symlinks = yes
  unix extensions = no
#Performances
  strict sync = no
  aio read size = 1
  aio write size = 1
  server multi channel support = yes
  log level = 1 auth_audit:5
  socket options = TCP_NODELAY
  min receivefile size = 16384
  use sendfile = true
  max xmit = 65535
  read raw = yes
  write raw = yes
  dead time = 15
  getwd cache = yes

[commun]
  comment = Dossier commun
  path = ${path4}
  force group = $group
  guest ok = no
  public = no
  read only = no
  browseable = yes
  create mask = 0664
  directory mask = 0775
  valid users = $user1,$user2
  write list = $user1,$user2
  posix locking = no
  strict locking = no
  oplocks = no
  level2 oplocks = no
  kernel share modes = no

[media]
  comment = Dossier media
  path = ${path3}
  guest ok = no
  public = no
  read only = no
  browseable = yes
  create mask = 0644
  directory mask = 0755
  force group = media
  force user = media
  valid users = $user1,$user2,media
  write list = $user1,media
  posix locking = no
  strict locking = no
  oplocks = no
  level2 oplocks = no
  kernel share modes = no

[$user2]
  comment = Dossier de $user2
  path = ${path2}
  guest ok = no
  public = no
  read only = no
  browseable = yes
  valid users = $user2
  write list = $user2
  create mask = 0600
  directory mask = 0700
  posix locking = no
  strict locking = no
  oplocks = no
  level2 oplocks = no
  kernel share modes = no
  
[serveur]
  comment = Dossier serveur
  path = ${path5}
  guest ok = no
  public = no
  read only = no
  valid users = $user1
  force user = root
  force group = root
  browseable = yes
  write list = $user1
  create mask = 0600
  directory mask = 0700
  posix locking = no
  strict locking = no
  oplocks = no
  level2 oplocks = no
  kernel share modes = no

[$user1]
  comment = Dossier de $user1
  path = ${path1}
  guest ok = yes
  public = no
  read only = no
  valid users = $user1
  browseable = yes
  write list = $user1
  create mask = 0600
  directory mask = 0700
  posix locking = no
  strict locking = no
  oplocks = no
  level2 oplocks = no
  kernel share modes = no

[timemachine] #Apple
  comment = Time Machine #Apple
  path = ${path8} #Apple
  guest ok = yes #Apple
  public = no #Apple
  browseable = yes #Apple
  write list = time #Apple
  read list = $user1 #Apple
  create mask = 0600 #Apple
  directory mask = 0700 #Apple
  fruit:time machine = yes #Apple
  fruit:time machine max size = 1050G #Apple
  strict sync #Apple
  durable handles = yes #Apple
  kernel oplocks = no #Apple
  kernel share modes = no #Apple
  posix locking = no #Apple
#Apple
[temporaire]
  comment = Dossier temporaire
  path = ${path6}
  force group = $group
  guest ok = yes
  public = no
  read only = no
  browseable = yes
  create mask = 0664
  directory mask = 0775
  valid users = $user1
  write list = $user1
  posix locking = no
  strict locking = no
  oplocks = no
  level2 oplocks = no
  kernel share modes = no

[sauvegarde]
  comment = Dossier de sauvegardes
  path = ${path7}
  force group = $group
  guest ok = yes
  public = no
  read only = no
  browseable = yes
  create mask = 0664
  directory mask = 0775
  valid users = $user1
  write list = $user1
  posix locking = no
  strict locking = no
  oplocks = no
  level2 oplocks = no
  kernel share modes = no
EOF
if [ "$os" == "macos" ]; then
        cat /tmp/smb.conf|sed 's/#Apple//g' > /etc/samba/smb.conf
else
        cat /tmp/smb.conf|grep -v "#Apple" > /etc/samba/smb.conf
fi
rc-service samba start
