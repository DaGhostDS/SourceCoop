#!/bin/bash -e

# Install packages for SteamCMD and Black Mesa Dedicated Server.
sudo dpkg --add-architecture i386
sudo apt-get update -y
sudo apt-get install unzip -y
sudo apt-get install wget -y
# Required for running SteamCMD.
sudo apt-get install lib32gcc-s1 -y
# Required for running Black Mesa Dedicated Server.
sudo apt-get install lib32stdc++6 -y
sudo apt-get install libncurses5 libncurses5:i386 -y

# Create working directories in /steam
sudo mkdir -p /steam/SteamCMD
sudo mkdir -p /steam/BMDS
sudo chown -R $USER:$USER /steam

cd /steam

# Install SteamCMD.
wget "http://media.steampowered.com/client/steamcmd_linux.tar.gz" -O ".tmp.tar.gz"
tar -xf ".tmp.tar.gz" -C "./SteamCMD"
rm ".tmp.tar.gz"

# Install Black Mesa Dedicated Server.
echo -e "force_install_dir \"../BMDS\"\nlogin anonymous\napp_update 346680 validate\nquit" | ./SteamCMD/steamcmd.sh

# Install the latest version of Metamod Source.
wget $(wget -qO- "https://www.sourcemm.net/downloads.php" | grep "<a class='quick-download download-link'" | grep -m1 "linux.tar.gz" | sed -n 's/.*href='\''//; s/'\''.*//p') -O ".tmp.tar.gz"
tar -xf ".tmp.tar.gz" -C "./BMDS/bms"
rm ".tmp.tar.gz"

# Install SourceMod version 7163 (recommended version)
wget "https://sm.alliedmods.net/smdrop/1.12/sourcemod-1.12.0-git7163-linux.tar.gz" -O ".tmp.tar.gz"
tar -xf ".tmp.tar.gz" -C "./BMDS/bms"
rm ".tmp.tar.gz"

# Install the latest version of Accelerator.
wget "https://builds.limetech.io/"$(wget -qO- "https://builds.limetech.io/?p=accelerator" | grep -m1 "linux.zip" | cut -d '"' -f2) -O ".tmp.zip"
unzip -o ".tmp.zip" -d "./BMDS/bms"
rm ".tmp.zip"

# Install the latest release of SourceCoop.
wget $(wget -qO- "https://api.github.com/repos/ampreeT/SourceCoop/releases/latest" | grep "browser_download_url" | grep -m1 "bms.zip" | cut -d '"' -f 4) -O ".tmp.zip"
unzip -o ".tmp.zip" -d "./BMDS/bms"
rm ".tmp.zip"

# Create a script to run and automatically restart the server.
cat > "./BMDS/srcds_coop.sh" << 'EOF'
#!/bin/bash
./srcds_run -console -game bms -ip 0.0.0.0 +maxplayers 32 +mp_teamplay 1 +map bm_c0a0a
EOF
chmod +x "./BMDS/srcds_coop.sh"

# Create a `mapcycle.txt` consisting of the starting chapter maps.
cat > "./BMDS/bms/mapcycle.txt" << 'EOF'
bm_c0a0a
bm_c1a0a
bm_c1a1a
bm_c1a2a
bm_c1a3a
bm_c1a4a
bm_c2a1a
bm_c2a1a
bm_c2a2a
bm_c2a3a
bm_c2a4a
bm_c2a4e
bm_c2a5a
bm_c3a1a
bm_c3a2a
bm_c4a1a
bm_c4a2a
bm_c4a3a
EOF

# Create a `server.cfg` with ideal default settings.
cat > "./BMDS/bms/cfg/server.cfg" << 'EOF'
// SourceCoop settings.
mp_timelimit 0      // Prevents map switch from round timers.
mp_fraglimit 0      // Prevents the match from ending when a player has a high enough score.
mp_teamplay 1       // Enables the scientist team.
mp_friendlyfire 0   // Disables friendly fire.
mp_forcerespawn 1   // Forces the player to respawn.

// Add your settings below.
hostname "Black Mesa: Cooperative"  // The name of the server.
sv_password ""                      // Sets a server password for locking the server.
rcon_password ""                    // Sets a RCON password for accessing adminstrative features. This is not recommended and SourceMod should be used instead.
EOF

# Empty the default `autoexec.cfg` and create `userconfig.cfg` to suppress warnings.
> "./BMDS/bms/cfg/autoexec.cfg"
> "./BMDS/bms/cfg/userconfig.cfg"

## OPTIONAL: Remove textures to save ~9 GB.
## On the server, materials are needed but textures are not.
## If the server ever needs to be updated, these files will be redownloaded again.
#rm /steam/BMDS/bms/bms_textures*
#rm /steam/BMDS/hl2/hl2_textures*
