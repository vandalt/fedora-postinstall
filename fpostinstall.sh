#!/usr/bin/bash

########################
### INSTALL SOFTWARE ###
########################

shopt -s expand_aliases

PKGS_DNF=(

    # STYLE
    'google-noto-emoji-color-fonts'
    'papirus-icon-theme'
    'libreoffice-icon-theme-papirus'
    'paper-icon-theme'
    'qt5-qtstyleplugins'

    # BROWSER
    'firefox'
    'chromium'

    # LATEX
    'texlive-scheme-full'

    # OFFICE
    'thunderbird'
    'onedrive'

    # IMAGE EDITING
    'gimp'

    # PDF
    'okular'
    'xournalpp'

    # VIDEO
    'vlc'

    # ASTRO
    'stellarium'

    # UTILS
    'gvim'
    'htop'
    'screen'
    'gnome-tweak'
    'gnome-extensions-app'
)

PKGS_COPR=(
    # For copr packages, the repo is specified first and all other packages are specified after

    # JOPLIN
    'taw/joplin joplin'

    # SLACK
    'jdoss/slack-repo slack-repo slack'

)

PKGS_FLATPAK=(

    # OFFICE
    'org.kde.kdenlive'
    'us.zoom.Zoom'
    'org.zotero.Zotero'
)

PKGS_RM=(
    #GNOME DEFAULT
    'evince*'
    'gnome-maps'
    'gnome-weather'
    'gnome-contacts'
    'rhythmbox'
    'gnome-photos'
)

bypass() {
  sudo -v
  while true;
  do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
  done 2>/dev/null &
}

bypass

# install miniconda python
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3.sh
bash ~/miniconda3.sh -b -p $HOME/miniconda3

# remove unused built-in packages
for PKG in "${PKGS_RM[@]}"; do
    echo "REMOVING: ${PKG}"
    sudo dnf remove -y "$PKG"
done

# install with dnf from default repos
for PKG in "${PKGS_DNF[@]}"; do
    echo "INSTALLING: ${PKG}"
    sudo dnf install -y "$PKG"
done

# COPR packages
for PKG in "${PKGS_COPR[@]}"; do
    repo=$(echo "$PKG" | cut -d " " -f 1)
    sudo dnf copr enable "$repo" -y
    pkgs=$(echo "$PKG" | cut -d " " -f2-)
    for pkg in $pkgs; do
        echo "INSTALLING: $pkg"
        sudo dnf install -y "$pkg"
    done
done

# Flatpaks
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
for PKG in "${PKGS_FLATPAK[@]}"; do
    echo "INSTALLING: ${PKG}"
    sudo flatpak install "$PKG" -y
done

# Spotify
sudo dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm -y
sudo dnf install https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y
sudo dnf install lpf-spotify-client -y
yes | DISPLAY= lpf update

# Safe Eyes
sudo dnf install libappindicator-gtk3 python3-psutil -y
sudo pip3 install safeeyes
sudo gtk-update-icon-cache /usr/share/icons/hicolor

##################
#### DOTFILES ####
##################
alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
echo ".dotfiles" >> .gitignore
git clone --bare git@github.com:vandalt/dotfiles.git $HOME/.dotfiles
config checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} rm -rf {}
config checkout
config config --local status.showUntrackedFiles no
config checkout fedora

##################
### EXTENSIONS ###
##################

# enable
gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com
gnome-extensions enable tray-icons@zhangkaizhao.com
gnome-extensions enable hide-keyboard-layout@sitnik.ru
gnome-extensions enable putWindow@clemens.lab21.org
gnome-extensions enable hidetopbar@mathieu.bidon.ca
gnome-extensions enable dash-to-dock@micxgx.gmail.com
gnome-extensions enable auto-move-windows@gnome-shell-extensions.gcampax.github.com

# hide top bar
gsettings --schemadir ~/.local/share/gnome-shell/extensions/hidetopbar@mathieu.bidon.ca/schemas/ set org.gnome.shell.extensions.hidetopbar enable-intellihide true
gsettings --schemadir ~/.local/share/gnome-shell/extensions/hidetopbar@mathieu.bidon.ca/schemas/ set org.gnome.shell.extensions.hidetopbar enable-active-window true
gsettings --schemadir ~/.local/share/gnome-shell/extensions/hidetopbar@mathieu.bidon.ca/schemas/ set org.gnome.shell.extensions.hidetopbar mouse-sensitive true
gsettings --schemadir ~/.local/share/gnome-shell/extensions/hidetopbar@mathieu.bidon.ca/schemas/ set org.gnome.shell.extensions.hidetopbar shortcut-toggles true
gsettings --schemadir ~/.local/share/gnome-shell/extensions/hidetopbar@mathieu.bidon.ca/schemas/ set org.gnome.shell.extensions.hidetopbar shortcut-keybind "['<Shift><Super>i']"
gsettings --schemadir ~/.local/share/gnome-shell/extensions/hidetopbar@mathieu.bidon.ca/schemas/ set org.gnome.shell.extensions.hidetopbar pressure-timeout 100
gsettings --schemadir ~/.local/share/gnome-shell/extensions/hidetopbar@mathieu.bidon.ca/schemas/ set org.gnome.shell.extensions.hidetopbar pressure-threshold 200
gsettings --schemadir ~/.local/share/gnome-shell/extensions/hidetopbar@mathieu.bidon.ca/schemas/ set org.gnome.shell.extensions.hidetopbar shortcut-delay 1.0

# dash-to-dock
gsettings --schemadir ~/.local/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com/schemas/ set org.gnome.shell.extensions.dash-to-dock dock-position 'BOTTOM'
gsettings --schemadir ~/.local/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com/schemas/ set org.gnome.shell.extensions.dash-to-dock intellihide true
gsettings --schemadir ~/.local/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com/schemas/ set org.gnome.shell.extensions.dash-to-dock intellihide-mode 'ALL_WINDOWS'
gsettings --schemadir ~/.local/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com/schemas/ set org.gnome.shell.extensions.dash-to-dock autohide true
gsettings --schemadir ~/.local/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com/schemas/ set org.gnome.shell.extensions.dash-to-dock autohide-in-fullscreen false
gsettings --schemadir ~/.local/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com/schemas/ set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 50
gsettings --schemadir ~/.local/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com/schemas/ set org.gnome.shell.extensions.dash-to-dock show-favorites true
gsettings --schemadir ~/.local/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com/schemas/ set org.gnome.shell.extensions.dash-to-dock show-running true
gsettings --schemadir ~/.local/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com/schemas/ set org.gnome.shell.extensions.dash-to-dock show-trash false
gsettings --schemadir ~/.local/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com/schemas/ set org.gnome.shell.extensions.dash-to-dock show-mounts false
gsettings --schemadir ~/.local/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com/schemas/ set org.gnome.shell.extensions.dash-to-dock hot-keys false
gsettings --schemadir ~/.local/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com/schemas/ set org.gnome.shell.extensions.dash-to-dock custom-theme-shrink true
gsettings --schemadir ~/.local/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com/schemas/ set org.gnome.shell.extensions.dash-to-dock transparency-mode 'FIXED'
gsettings --schemadir ~/.local/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com/schemas/ set org.gnome.shell.extensions.dash-to-dock background-opacity 0.0
gsettings --schemadir ~/.local/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com/schemas/ set org.gnome.shell.extensions.dash-to-dock force-straight-corner false

# put-windows
gsettings --schemadir ~/.local/share/gnome-shell/extensions/putWindow@clemens.lab21.org/schemas/ set org.gnome.shell.extensions.org-lab21-putwindow move-center-only-toggles 1
gsettings --schemadir ~/.local/share/gnome-shell/extensions/putWindow@clemens.lab21.org/schemas/ set org.gnome.shell.extensions.org-lab21-putwindow put-to-side-w "['<Shift><Super>h']"
gsettings --schemadir ~/.local/share/gnome-shell/extensions/putWindow@clemens.lab21.org/schemas/ set org.gnome.shell.extensions.org-lab21-putwindow put-to-side-n "['<Shift><Super>k']"
gsettings --schemadir ~/.local/share/gnome-shell/extensions/putWindow@clemens.lab21.org/schemas/ set org.gnome.shell.extensions.org-lab21-putwindow put-to-side-e "['<Shift><Super>l']"
gsettings --schemadir ~/.local/share/gnome-shell/extensions/putWindow@clemens.lab21.org/schemas/ set org.gnome.shell.extensions.org-lab21-putwindow put-to-side-s "['<Shift><Super>j']"
gsettings --schemadir ~/.local/share/gnome-shell/extensions/putWindow@clemens.lab21.org/schemas/ set org.gnome.shell.extensions.org-lab21-putwindow put-to-corner-sw "['<Shift><Super>m']"
gsettings --schemadir ~/.local/share/gnome-shell/extensions/putWindow@clemens.lab21.org/schemas/ set org.gnome.shell.extensions.org-lab21-putwindow put-to-corner-nw "['<Shift><Super>u']"
gsettings --schemadir ~/.local/share/gnome-shell/extensions/putWindow@clemens.lab21.org/schemas/ set org.gnome.shell.extensions.org-lab21-putwindow put-to-corner-se "['<Shift><Super>question']"
gsettings --schemadir ~/.local/share/gnome-shell/extensions/putWindow@clemens.lab21.org/schemas/ set org.gnome.shell.extensions.org-lab21-putwindow put-to-corner-ne "['<Shift><Super>p']"
gsettings --schemadir ~/.local/share/gnome-shell/extensions/putWindow@clemens.lab21.org/schemas/ set org.gnome.shell.extensions.org-lab21-putwindow put-to-right-screen "['<Super>semicolon']"
gsettings --schemadir ~/.local/share/gnome-shell/extensions/putWindow@clemens.lab21.org/schemas/ set org.gnome.shell.extensions.org-lab21-putwindow put-to-left-screen "['<Super>colon']"
gsettings --schemadir ~/.local/share/gnome-shell/extensions/putWindow@clemens.lab21.org/schemas/ set org.gnome.shell.extensions.org-lab21-putwindow put-to-center "['<Shift><Super>space']"
gsettings --schemadir ~/.local/share/gnome-shell/extensions/putWindow@clemens.lab21.org/schemas/ set org.gnome.shell.extensions.org-lab21-putwindow move-focus-west "['<Super>h']"
gsettings --schemadir ~/.local/share/gnome-shell/extensions/putWindow@clemens.lab21.org/schemas/ set org.gnome.shell.extensions.org-lab21-putwindow move-focus-north "['<Super>k']"
gsettings --schemadir ~/.local/share/gnome-shell/extensions/putWindow@clemens.lab21.org/schemas/ set org.gnome.shell.extensions.org-lab21-putwindow move-focus-east "['<Super>l']"
gsettings --schemadir ~/.local/share/gnome-shell/extensions/putWindow@clemens.lab21.org/schemas/ set org.gnome.shell.extensions.org-lab21-putwindow move-focus-south "['<Super>j']"
gsettings --schemadir ~/.local/share/gnome-shell/extensions/putWindow@clemens.lab21.org/schemas/ set org.gnome.shell.extensions.org-lab21-putwindow move-focus-left-screen "[]"
gsettings --schemadir ~/.local/share/gnome-shell/extensions/putWindow@clemens.lab21.org/schemas/ set org.gnome.shell.extensions.org-lab21-putwindow move-focus-right-screen "[]"
gsettings --schemadir ~/.local/share/gnome-shell/extensions/putWindow@clemens.lab21.org/schemas/ set org.gnome.shell.extensions.org-lab21-putwindow move-focus-cycle "[]"
gsettings --schemadir ~/.local/share/gnome-shell/extensions/putWindow@clemens.lab21.org/schemas/ set org.gnome.shell.extensions.org-lab21-putwindow move-focus-left-screen-enabled 0
gsettings --schemadir ~/.local/share/gnome-shell/extensions/putWindow@clemens.lab21.org/schemas/ set org.gnome.shell.extensions.org-lab21-putwindow move-focus-right-screen-enabled 0
gsettings --schemadir ~/.local/share/gnome-shell/extensions/putWindow@clemens.lab21.org/schemas/ set org.gnome.shell.extensions.org-lab21-putwindow move-focus-cycle-enabled 0

# auto-move-apps
gsettings --schemadir ~/.local/share/gnome-shell/extensions/auto-move-windows@gnome-shell-extensions.gcampax.github.com/schemas/ set org.gnome.shell.extensions.auto-move-windows application-list "['firefox.desktop:2', 'chromium.desktop:2', 'thunderbird.desktop:6', 'joplin.desktop:3', 'spotify.desktop:7', 'slack.desktop:6', 'cpod.desktop:7']"

###################
### GNOME THEME ###
###################

# Download Dracula theme
mkdir ~/.themes
cd ~/.themes
wget https://github.com/dracula/gtk/archive/slim.zip
unzip slim.zip
rm slim.zip
mv gtk-slim Dracula-slim
cd ~

# Set themes
gsettings set org.gnome.shell.extensions.user-theme name 'Dracula-slim'
gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'
gsettings set org.gnome.desktop.interface gtk-theme 'Dracula-slim'
gsettings set org.gnome.desktop.interface cursor-theme 'Paper'

# Change papirus folder color
wget -qO- https://git.io/papirus-folders-install | sh
papirus-folders -C violet --theme Papirus-Dark
wget -qO- https://git.io/papirus-folders-install | env uninstall=true sh

#############
### FONTS ###
#############
cat fontconfig >> ~/.config/fontconfig/fonts.conf
fc-cache -f

###############
### FIREFOX ###
###############
for profile in ~/.mozilla/firefox/*.default-release
do
	mkdir $profile/chrome
	cat userContent.CSS > $profile/chrome/userContent.css

################
### TERMINAL ###
################
git clone https://github.com/dracula/gnome-terminal
cd gnome-terminal
./install.sh
cd ..
rm -rf gnome-terminal
proflist=$(gsettings get org.gnome.Terminal.ProfilesList list | tr -d \[ | tr -d \] | tr -d \' | tr -d , | tr -d \s)
for prof in $proflist; do
    name=$(gsettings get org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$prof/ visible-name | tr -d \')
    if [ $name == Default ]; then
        gsettings set org.gnome.Terminal.ProfilesList default $prof
	gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$prof/ visible-name Dracula
        termprof=$prof
    fi
done
gsettings set org.gnome.Terminal.Legacy.Settings headerbar false
gsettings set org.gnome.Terminal.Legacy.Settings default-show-menubar false
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$termprof/ use-transparent-background true
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$termprof/ background-transparency-percent 20
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$termprof/ audible-bell false
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$termprof/ scrollbar-policy 'never'

#####################################
#### WORKSPACES AND APPLICATIONS ####
#####################################

# dynamic workspaces
gsettings set org.gnome.shell.overrides dynamic-workspaces false
gsettings set org.gnome.mutter dynamic-workspaces false
gsettings set org.gnome.desktop.wm.preferences num-workspaces 7
gsettings set org.gnome.shell.app-switcher current-workspace-only true

# favorite applications
gsettings set org.gnome.shell favorite-apps "['org.gnome.Terminal.desktop', 'firefox.desktop', 'mozilla-thunderbird.desktop', 'org.joplinapp.Joplin.desktop', 'org.gnome.Nautilus.desktop', 'gvim.desktop', 'org.zotero.Zotero.desktop', 'spotify.desktop', 'libreoffice-impress.desktop','slack.desktop', 'us.zoom.Zoom.desktop']"

##################
#### SETTINGS ####
##################
# sound
gsettings set org.gnome.desktop.wm.preferences audible-bell 'false'

# power
gsettings  set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'nothing'
gsettings  set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
gsettings  set org.gnome.settings-daemon.plugins.power power-button-action 'interactive'

# night light
gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-automatic false
gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-from 12.0
gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-to 12.0
gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature 4000

# mouse and touchpad
gsettings set org.gnome.desktop.peripherals.touchpad natural-scroll true
gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true
gsettings set org.gnome.desktop.peripherals.touchpad two-finger-scrolling-enabled true
gsettings set org.gnome.desktop.peripherals.mouse natural-scroll false

# window top bar tweaks
gsettings set org.gnome.desktop.wm.preferences button-layout 'close,minimize,maximize:appmenu'

############################
#### KEYBOARD SHORTCUTS ####
############################

### SYSTEM ###

# disable favorites
for i in {1..9}; do
    gsettings set org.gnome.shell.keybindings switch-to-application-$i "[]"
done

# workspace swithcing/moving
for i in {1..4}; do
    gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-$i "['<Super>$i']"
    gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-$i "['<Super><Shift>$i']"
done
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-5 "['<Super>8']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-5 "['<Super><Shift>8']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-6 "['<Super>9']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-6 "['<Super><Shift>9']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-7 "['<Super>0']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-7 "['<Super><Shift>0']"
for i in {8..9}; do
    gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-$i "[]"
    gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-$i "[]"
done

# window switching
gsettings set org.gnome.desktop.wm.keybindings switch-applications "['<Super>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-applications-backward "['<Shift><Super>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-windows "['<Alt>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-windows-backward "['<Shift><Alt>Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-group "['<Super>Above_Tab', '<Alt>Above_Tab']"
gsettings set org.gnome.desktop.wm.keybindings switch-group-backward "['<Shift><Super>Above_Tab', '<Shift><Alt>Above_Tab']"
gsettings set org.gnome.mutter.keybindings switch-monitor "['XF86Display']"

# system
gsettings set org.gnome.settings-daemon.plugins.media-keys screensaver "['<Super>comma']"
gsettings set org.gnome.settings-daemon.plugins.media-keys logout "['<Shift><Super>e']"
gsettings set org.gnome.desktop.wm.keybindings panel-run-dialog "['<Super>r']"
gsettings set org.gnome.shell.keybindings toggle-application-view "['<Super>a']"
gsettings set org.gnome.shell.keybindings focus-active-notification "[]"
gsettings set org.gnome.shell.keybindings toggle-message-tray "['<Super>v']"

# windows general
gsettings set org.gnome.desktop.wm.keybindings close "['<Super>q']"
gsettings set org.gnome.desktop.wm.keybindings minimize "['<Super>d']"
gsettings set org.gnome.desktop.wm.keybindings toggle-fullscreen "['<Shift><Super>f']"
gsettings set org.gnome.desktop.wm.keybindings switch-input-source-backward "['<Shift>XF86Keyboard']"

## APPLICATIONS ##
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom5/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom6/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom7/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom8/']"

# terminal
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name 'Terminal'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command 'gnome-terminal'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding '<Super>Return'

# browser
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ name 'Browser'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ command 'firefox'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ binding '<Super>i'

# email
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ name 'Mail'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ command 'thunderbird'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ binding '<Super>m'

# notes
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/ name 'Notes'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/ command 'joplin-desktop'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/ binding '<Super>n'

# pdf
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/ name 'PDF'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/ command 'env QT_QPA_PLATFORMTHEME=gtk2 okular'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/ binding '<Super>p'

# music
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom5/ name 'Music'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom5/ command 'spotify'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom5/ binding '<Super>u'

# chat
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom6/ name 'Chat'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom6/ command 'slack'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom6/ binding '<Super>c'

# file manager
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom7/ name 'Files'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom7/ command 'nautilus'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom7/ binding '<Super>f'

# zotero
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom8/ name 'Zotero'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom8/ command 'zotero'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom8/ binding '<Super>z'

echo "Do not forget to activate toolkit.legacyUserProfileCustomizations.stylesheets in Firefox"
